-- Step 01 audits the fields used by the gap; see sql/README.md for choices and interpretation.
WITH scoped AS (
  SELECT *
  FROM `bigquery-public-data.new_york_citibike.citibike_trips`
  WHERE starttime >= DATETIME '2017-04-01 00:00:00'
    AND starttime < DATETIME '2018-01-01 00:00:00'
),
exact_rows AS (
  SELECT DISTINCT *
  FROM scoped
),
trip_identities AS (
  SELECT DISTINCT
    bikeid,
    starttime,
    stoptime,
    tripduration,
    start_station_id,
    end_station_id
  FROM scoped
),
station_labels AS (
  SELECT start_station_id AS station_id, start_station_name AS station_name
  FROM scoped
  UNION ALL
  SELECT end_station_id AS station_id, end_station_name AS station_name
  FROM scoped
),
monthly_coverage AS (
  SELECT
    DATE_TRUNC(DATE(starttime), MONTH) AS month,
    COUNT(*) AS trip_rows
  FROM scoped
  GROUP BY month
)
SELECT
  COUNT(*) AS trip_rows,
  MIN(starttime) AS first_starttime,
  MAX(starttime) AS last_starttime,
  MIN(stoptime) AS first_stoptime,
  MAX(stoptime) AS last_stoptime,
  COUNTIF(starttime IS NULL) AS null_starttime,
  COUNTIF(stoptime IS NULL) AS null_stoptime,
  COUNTIF(tripduration IS NULL) AS null_tripduration,
  COUNTIF(tripduration <= 0) AS nonpositive_tripduration,
  COUNTIF(start_station_id IS NULL) AS null_start_station_id,
  COUNTIF(end_station_id IS NULL) AS null_end_station_id,
  COUNTIF(start_station_name IS NULL OR TRIM(start_station_name) = '') AS blank_start_station_name,
  COUNTIF(end_station_name IS NULL OR TRIM(end_station_name) = '') AS blank_end_station_name,
  COUNTIF(stoptime < starttime) AS stop_before_start_local_time,
  COUNTIF(stoptime >= DATETIME '2018-01-01 00:00:00') AS trips_stopping_in_2018,
  COUNTIF(starttime > CURRENT_DATETIME('America/New_York')) AS future_starttime,
  COUNT(*) - (SELECT COUNT(*) FROM exact_rows) AS exact_duplicate_rows,
  COUNT(*) - (SELECT COUNT(*) FROM trip_identities) AS duplicate_trip_identities,
  (
    SELECT COUNT(*)
    FROM (
      SELECT station_id
      FROM station_labels
      WHERE station_id IS NOT NULL
      GROUP BY station_id
      HAVING COUNT(DISTINCT station_name) > 1
    )
  ) AS station_ids_with_multiple_names,
  (
    SELECT ARRAY_AGG(STRUCT(month, trip_rows) ORDER BY month)
    FROM monthly_coverage
  ) AS monthly_coverage
FROM scoped;

