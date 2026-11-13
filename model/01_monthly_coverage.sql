-- CP2 coverage check: show every observed start-time month and rows without a starttime.
SELECT
  CASE
    WHEN starttime IS NULL THEN 'NULL starttime'
    ELSE FORMAT_DATE('%Y-%m-%d', DATE_TRUNC(DATE(starttime), MONTH))
  END AS trip_month,
  COUNT(*) AS trip_rows,
  MIN(starttime) AS first_starttime,
  MAX(starttime) AS last_starttime
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
GROUP BY trip_month
ORDER BY
  CASE WHEN trip_month = 'NULL starttime' THEN 0 ELSE 1 END,
  trip_month;
