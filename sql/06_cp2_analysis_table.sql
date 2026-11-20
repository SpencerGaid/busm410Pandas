-- Step 06 builds one row per eligible 2017 station for CP2.
-- Y is the station's absolute directional imbalance rate in Apr-Dec 2017.
-- X variables are measured in Sep 2016, before the outcome window; that month
-- is the last observed month before the documented Oct 2016-Mar 2017 data gap.
CREATE OR REPLACE TABLE `busm-410-123.busm410_cp2.station_analysis` AS
WITH outcome_events AS (
  SELECT e.station_id, e.is_departure
  FROM `bigquery-public-data.new_york_citibike.citibike_trips` t
  CROSS JOIN UNNEST([
    STRUCT(t.start_station_id AS station_id, TRUE AS is_departure),
    STRUCT(t.end_station_id AS station_id, FALSE AS is_departure)
  ]) e
  WHERE t.starttime >= DATETIME '2017-04-01 00:00:00'
    AND t.starttime < DATETIME '2018-01-01 00:00:00'
    AND e.station_id IS NOT NULL
),
outcomes AS (
  SELECT station_id, COUNTIF(is_departure) departures,
         COUNTIF(NOT is_departure) arrivals, COUNT(*) station_events
  FROM outcome_events GROUP BY station_id
),
prior_events AS (
  SELECT e.station_id, e.is_departure, t.usertype, t.tripduration
  FROM `bigquery-public-data.new_york_citibike.citibike_trips` t
  CROSS JOIN UNNEST([
    STRUCT(t.start_station_id AS station_id, TRUE AS is_departure),
    STRUCT(t.end_station_id AS station_id, FALSE AS is_departure)
  ]) e
  WHERE t.starttime >= DATETIME '2016-09-01 00:00:00'
    AND t.starttime < DATETIME '2016-10-01 00:00:00'
    AND e.station_id IS NOT NULL
),
prior AS (
  SELECT station_id, COUNT(*) prior_station_events,
    SAFE_DIVIDE(COUNTIF(is_departure) - COUNTIF(NOT is_departure), COUNT(*)) prior_net_imbalance_rate,
    SAFE_DIVIDE(COUNTIF(usertype = 'Subscriber'), COUNT(*)) prior_subscriber_share,
    AVG(tripduration) prior_mean_tripduration_seconds
  FROM prior_events GROUP BY station_id
)
SELECT o.station_id, o.departures, o.arrivals, o.station_events,
  SAFE_DIVIDE(ABS(o.departures-o.arrivals),o.station_events) AS y_abs_imbalance_rate,
  COALESCE(p.prior_station_events,0) AS x_prior_station_events,
  COALESCE(p.prior_net_imbalance_rate,0) AS x_prior_net_imbalance_rate,
  COALESCE(p.prior_subscriber_share,0) AS x_prior_subscriber_share,
  COALESCE(p.prior_mean_tripduration_seconds,0) AS x_prior_mean_tripduration_seconds
FROM outcomes o LEFT JOIN prior p USING(station_id)
WHERE o.station_events >= 10000;
