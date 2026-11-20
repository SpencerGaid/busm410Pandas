-- Step 11 returns one compact result set for the remaining CP2 submission checks.
-- In BigQuery, run this whole file in project busm-410-123. Copy the final result
-- table into model/cp2_results.md; do not treat the recorded/expected values as
-- fresh results until this query has completed successfully.
--
-- This script scans the scoped 2017 trip rows once to independently rebuild the
-- station totals and month-by-month comparison. It also reads the saved CP2
-- table and model.

CREATE TEMP TABLE cp2_raw_monthly AS
WITH endpoint_events AS (
  SELECT
    DATE_TRUNC(DATE(t.starttime), MONTH) AS month,
    endpoint.station_id,
    endpoint.is_departure
  FROM `bigquery-public-data.new_york_citibike.citibike_trips` AS t
  CROSS JOIN UNNEST([
    STRUCT(t.start_station_id AS station_id, TRUE AS is_departure),
    STRUCT(t.end_station_id AS station_id, FALSE AS is_departure)
  ]) AS endpoint
  WHERE t.starttime >= DATETIME '2017-04-01 00:00:00'
    AND t.starttime < DATETIME '2018-01-01 00:00:00'
    AND endpoint.station_id IS NOT NULL
)
SELECT
  month,
  station_id,
  COUNTIF(is_departure) AS departures,
  COUNTIF(NOT is_departure) AS arrivals,
  COUNT(*) AS station_events
FROM endpoint_events
GROUP BY month, station_id;

CREATE TEMP TABLE cp2_raw_station AS
SELECT
  station_id,
  SUM(departures) AS departures,
  SUM(arrivals) AS arrivals,
  SUM(station_events) AS station_events
FROM cp2_raw_monthly
GROUP BY station_id;

WITH
quality_checks AS (
  SELECT
    '1. analysis row count' AS metric,
    CAST(COUNT(*) AS STRING) AS value,
    '552 expected from the recorded run' AS details
  FROM `busm-410-123.busm410_cp2.station_analysis`
  UNION ALL
  SELECT
    '2. null cells in Y and four X columns',
    CAST(
      COUNTIF(y_abs_imbalance_rate IS NULL)
      + COUNTIF(x_prior_station_events IS NULL)
      + COUNTIF(x_prior_net_imbalance_rate IS NULL)
      + COUNTIF(x_prior_subscriber_share IS NULL)
      + COUNTIF(x_prior_mean_tripduration_seconds IS NULL)
      AS STRING
    ),
    '0 means passed'
  FROM `busm-410-123.busm410_cp2.station_analysis`
  UNION ALL
  SELECT
    '3. out-of-range Y, prior rate, or subscriber share',
    CAST(
      COUNTIF(y_abs_imbalance_rate < 0 OR y_abs_imbalance_rate > 1)
      + COUNTIF(x_prior_net_imbalance_rate < -1 OR x_prior_net_imbalance_rate > 1)
      + COUNTIF(x_prior_subscriber_share < 0 OR x_prior_subscriber_share > 1)
      AS STRING
    ),
    '0 means passed'
  FROM `busm-410-123.busm410_cp2.station_analysis`
  UNION ALL
  SELECT
    '4. negative prior events or duration',
    CAST(
      COUNTIF(x_prior_station_events < 0)
      + COUNTIF(x_prior_mean_tripduration_seconds < 0)
      AS STRING
    ),
    '0 means passed'
  FROM `busm-410-123.busm410_cp2.station_analysis`
  UNION ALL
  SELECT
    '5. duplicate station rows',
    CAST(COUNT(*) - COUNT(DISTINCT station_id) AS STRING),
    '0 means passed'
  FROM `busm-410-123.busm410_cp2.station_analysis`
),
raw_station_summary AS (
  SELECT
    COUNTIF(station_events >= 10000) AS station_count,
    AVG(IF(
      station_events >= 10000,
      SAFE_DIVIDE(ABS(departures - arrivals), station_events),
      NULL
    )) AS mean_y
  FROM cp2_raw_station
),
saved_table_summary AS (
  SELECT
    COUNT(*) AS station_count,
    AVG(y_abs_imbalance_rate) AS mean_y
  FROM `busm-410-123.busm410_cp2.station_analysis`
),
monthly_qualifying AS (
  SELECT
    m.month,
    m.station_id,
    SAFE_DIVIDE(ABS(m.departures - m.arrivals), m.station_events) AS abs_imbalance_rate
  FROM cp2_raw_monthly AS m
  JOIN cp2_raw_station AS s USING (station_id)
  WHERE s.station_events >= 10000
),
monthly_summary AS (
  SELECT
    month,
    MAX(IF(station_id = 281, abs_imbalance_rate, NULL)) AS station_281_rate,
    APPROX_QUANTILES(
      IF(station_id != 281, abs_imbalance_rate, NULL), 100
    )[OFFSET(50)] AS peer_median_rate,
    COUNTIF(station_id != 281) AS peer_stations
  FROM monthly_qualifying
  GROUP BY month
),
model_evaluation AS (
  SELECT metric, metric_value
  FROM ML.EVALUATE(MODEL `busm-410-123.busm410_cp2.station_imbalance_model`) AS e
  CROSS JOIN UNNEST([
    STRUCT('r2_score' AS metric, CAST(e.r2_score AS STRING) AS metric_value),
    STRUCT('mean_absolute_error' AS metric, CAST(e.mean_absolute_error AS STRING) AS metric_value),
    STRUCT('mean_squared_error' AS metric, CAST(e.mean_squared_error AS STRING) AS metric_value),
    STRUCT('median_absolute_error' AS metric, CAST(e.median_absolute_error AS STRING) AS metric_value),
    STRUCT('explained_variance' AS metric, CAST(e.explained_variance AS STRING) AS metric_value)
  ])
)
SELECT 'quality_check' AS section, metric, value, details
FROM quality_checks

UNION ALL
SELECT
  'raw_reconciliation',
  'raw_station_count',
  CAST(raw.station_count AS STRING),
  CONCAT(
    'analysis_table_station_count=', CAST(saved.station_count AS STRING),
    '; counts_match=', CAST(raw.station_count = saved.station_count AS STRING)
  )
FROM raw_station_summary AS raw
CROSS JOIN saved_table_summary AS saved

UNION ALL
SELECT
  'raw_reconciliation',
  'raw_mean_absolute_imbalance_rate',
  CAST(raw.mean_y AS STRING),
  CONCAT(
    'analysis_table_mean_y=', CAST(saved.mean_y AS STRING),
    '; means_match=', CAST(ABS(raw.mean_y - saved.mean_y) < 1e-12 AS STRING)
  )
FROM raw_station_summary AS raw
CROSS JOIN saved_table_summary AS saved

UNION ALL
SELECT
  'monthly_gap',
  FORMAT_DATE('%Y-%m', month),
  CAST(station_281_rate AS STRING),
  TO_JSON_STRING(STRUCT(
    peer_median_rate AS peer_median_rate,
    peer_stations AS peer_stations
  ))
FROM monthly_summary

UNION ALL
SELECT 'model_evaluation', metric, metric_value, 'Fresh ML.EVALUATE output'
FROM model_evaluation

UNION ALL
SELECT
  'coefficients',
  processed_input,
  CAST(weight AS STRING),
  CONCAT('p_value=', CAST(p_value AS STRING))
FROM ML.ADVANCED_WEIGHTS(
  MODEL `busm-410-123.busm410_cp2.station_imbalance_model`
)
WHERE processed_input != '__INTERCEPT__'

ORDER BY section, metric;
