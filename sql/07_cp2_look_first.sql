-- Step 07: run these checks on the CP2 analysis table before interpreting the model.
-- Five checks: row count, missing values, invalid ranges, impossible negatives,
-- and duplicate station rows. A zero issue count means that check passed.
WITH checks AS (
  SELECT '1. analysis row count' AS check_name,
         COUNT(*) AS observed,
         '552 rows expected from recorded run' AS interpretation
  FROM `busm-410-123.busm410_cp2.station_analysis`
  UNION ALL
  SELECT '2. null cells in Y and four X columns',
    COUNTIF(y_abs_imbalance_rate IS NULL)
      + COUNTIF(x_prior_station_events IS NULL)
      + COUNTIF(x_prior_net_imbalance_rate IS NULL)
      + COUNTIF(x_prior_subscriber_share IS NULL)
      + COUNTIF(x_prior_mean_tripduration_seconds IS NULL),
    '0 expected'
  FROM `busm-410-123.busm410_cp2.station_analysis`
  UNION ALL
  SELECT '3. out-of-range Y or subscriber share',
    COUNTIF(y_abs_imbalance_rate < 0 OR y_abs_imbalance_rate > 1)
      + COUNTIF(x_prior_subscriber_share < 0 OR x_prior_subscriber_share > 1),
    '0 expected'
  FROM `busm-410-123.busm410_cp2.station_analysis`
  UNION ALL
  SELECT '4. negative prior counts, rates, or duration',
    COUNTIF(x_prior_station_events < 0 OR x_prior_net_imbalance_rate < -1
      OR x_prior_net_imbalance_rate > 1 OR x_prior_mean_tripduration_seconds < 0),
    '0 expected'
  FROM `busm-410-123.busm410_cp2.station_analysis`
  UNION ALL
  SELECT '5. duplicate station rows',
    COUNT(*) - COUNT(DISTINCT station_id),
    '0 expected'
  FROM `busm-410-123.busm410_cp2.station_analysis`
)
SELECT * FROM checks ORDER BY check_name;

-- Independent second-way check: rebuild the qualifying station count and mean Y
-- directly from raw trips, then compare them with the saved analysis table.
WITH raw_events AS (
  SELECT e.station_id, e.is_departure
  FROM `bigquery-public-data.new_york_citibike.citibike_trips` AS t
  CROSS JOIN UNNEST([
    STRUCT(t.start_station_id AS station_id, TRUE AS is_departure),
    STRUCT(t.end_station_id AS station_id, FALSE AS is_departure)
  ]) AS e
  WHERE t.starttime >= DATETIME '2017-04-01 00:00:00'
    AND t.starttime < DATETIME '2018-01-01 00:00:00'
    AND e.station_id IS NOT NULL
),
raw_station AS (
  SELECT station_id, COUNTIF(is_departure) AS departures,
    COUNTIF(NOT is_departure) AS arrivals, COUNT(*) AS station_events
  FROM raw_events GROUP BY station_id
),
raw_summary AS (
  SELECT COUNT(*) AS station_count,
    AVG(SAFE_DIVIDE(ABS(departures-arrivals),station_events)) AS mean_y
  FROM raw_station WHERE station_events >= 10000
),
table_summary AS (
  SELECT COUNT(*) AS station_count, AVG(y_abs_imbalance_rate) AS mean_y
  FROM `busm-410-123.busm410_cp2.station_analysis`
)
SELECT raw.station_count AS raw_station_count,
  saved.station_count AS analysis_table_station_count,
  raw.mean_y AS raw_mean_y, saved.mean_y AS analysis_table_mean_y,
  raw.station_count = saved.station_count AS counts_match,
  ABS(raw.mean_y-saved.mean_y) < 1e-12 AS means_match
FROM raw_summary AS raw CROSS JOIN table_summary AS saved;

-- Part A, way 1: break down later station imbalance by previous net-flow direction.
SELECT
  CASE
    WHEN x_prior_net_imbalance_rate < 0 THEN 'Negative prior net flow'
    WHEN x_prior_net_imbalance_rate > 0 THEN 'Positive prior net flow'
    ELSE 'Zero prior net flow'
  END AS prior_net_flow_group,
  AVG(y_abs_imbalance_rate) AS mean_y, COUNT(*) AS stations
FROM `busm-410-123.busm410_cp2.station_analysis`
GROUP BY prior_net_flow_group ORDER BY prior_net_flow_group;

-- Part A, way 2: compare three CP1-planned suspects across quintiles.
-- NTILE is computed in a CTE before aggregation (BigQuery does not allow window
-- functions directly in GROUP BY).
WITH subscriber_groups AS (
  SELECT NTILE(5) OVER (ORDER BY x_prior_subscriber_share) AS quintile,
    y_abs_imbalance_rate
  FROM `busm-410-123.busm410_cp2.station_analysis`
)
SELECT quintile, AVG(y_abs_imbalance_rate) AS mean_y, COUNT(*) AS stations
FROM subscriber_groups GROUP BY quintile ORDER BY quintile;

WITH duration_groups AS (
  SELECT NTILE(5) OVER (ORDER BY x_prior_mean_tripduration_seconds) AS quintile,
    y_abs_imbalance_rate
  FROM `busm-410-123.busm410_cp2.station_analysis`
)
SELECT quintile, AVG(y_abs_imbalance_rate) AS mean_y, COUNT(*) AS stations
FROM duration_groups GROUP BY quintile ORDER BY quintile;

WITH volume_groups AS (
  SELECT NTILE(3) OVER (ORDER BY x_prior_station_events) AS tertile,
    y_abs_imbalance_rate
  FROM `busm-410-123.busm410_cp2.station_analysis`
)
SELECT tertile, AVG(y_abs_imbalance_rate) AS mean_y, COUNT(*) AS stations
FROM volume_groups GROUP BY tertile ORDER BY tertile;
