-- Step 10 checks how the CP1 station gap changed by month against qualifying peers.
WITH events AS (
  SELECT DATE_TRUNC(DATE(t.starttime), MONTH) AS month,
    endpoint.station_id, endpoint.is_departure
  FROM `bigquery-public-data.new_york_citibike.citibike_trips` AS t
  CROSS JOIN UNNEST([
    STRUCT(t.start_station_id AS station_id, TRUE AS is_departure),
    STRUCT(t.end_station_id AS station_id, FALSE AS is_departure)
  ]) AS endpoint
  WHERE t.starttime >= DATETIME '2017-04-01 00:00:00'
    AND t.starttime < DATETIME '2018-01-01 00:00:00'
    AND endpoint.station_id IS NOT NULL
),
monthly_station AS (
  SELECT month, station_id,
    COUNTIF(is_departure) AS departures,
    COUNTIF(NOT is_departure) AS arrivals,
    COUNT(*) AS station_events
  FROM events GROUP BY month, station_id
),
qualifying AS (
  SELECT month, station_id,
    SAFE_DIVIDE(ABS(departures-arrivals),station_events) AS abs_imbalance_rate
  FROM monthly_station
  WHERE station_id IN (
    SELECT station_id FROM monthly_station
    GROUP BY station_id HAVING SUM(station_events) >= 10000
  )
)
SELECT FORMAT_DATE('%Y-%m', month) AS month,
  MAX(IF(station_id=281,abs_imbalance_rate,NULL)) AS station_281_rate,
  APPROX_QUANTILES(IF(station_id!=281,abs_imbalance_rate,NULL),100)[OFFSET(50)]
    AS peer_median_rate,
  COUNTIF(station_id!=281) AS peer_stations
FROM qualifying
GROUP BY month ORDER BY month;
