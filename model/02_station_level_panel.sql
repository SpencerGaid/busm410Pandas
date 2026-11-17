-- CP2 cross-sectional panel: one row per station for April–December 2017.
-- Y is signed imbalance rate. X features use the same period, so this is association,
-- not a time-forward forecast. See model/notes.md for definitions and limitations.
WITH scoped AS (
  SELECT *
  FROM `bigquery-public-data.new_york_citibike.citibike_trips`
  WHERE starttime >= DATETIME '2017-04-01 00:00:00'
    AND starttime < DATETIME '2018-01-01 00:00:00'
),
station_events AS (
  SELECT
    start_station_id AS station_id,
    start_station_name AS station_name,
    usertype,
    EXTRACT(DAYOFWEEK FROM DATE(starttime)) IN (1, 7) AS is_weekend,
    'departure' AS event_type,
    TO_JSON_STRING(t) AS trip_row
  FROM scoped AS t
  WHERE start_station_id IS NOT NULL

  UNION ALL

  SELECT
    end_station_id AS station_id,
    end_station_name AS station_name,
    usertype,
    EXTRACT(DAYOFWEEK FROM DATE(starttime)) IN (1, 7) AS is_weekend,
    'arrival' AS event_type,
    TO_JSON_STRING(t) AS trip_row
  FROM scoped AS t
  WHERE end_station_id IS NOT NULL
),
station_rollup AS (
  SELECT
    station_id,
    COUNTIF(event_type = 'departure') AS departures,
    COUNTIF(event_type = 'arrival') AS arrivals,
    COUNT(*) AS station_events,
    COUNTIF(usertype = 'Customer') AS casual_events,
    COUNTIF(is_weekend) AS weekend_events,
    COUNT(DISTINCT trip_row) AS total_rides_involving_station
  FROM station_events
  GROUP BY station_id
),
station_names AS (
  SELECT
    station_id,
    station_name,
    COUNT(*) AS name_events
  FROM station_events
  WHERE station_name IS NOT NULL AND TRIM(station_name) != ''
  GROUP BY station_id, station_name
),
display_names AS (
  SELECT station_id, station_name
  FROM station_names
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY station_id
    ORDER BY name_events DESC, station_name
  ) = 1
)
SELECT
  r.station_id,
  n.station_name,
  r.departures,
  r.arrivals,
  r.station_events,
  r.total_rides_involving_station,
  SAFE_DIVIDE(r.departures - r.arrivals, r.station_events) AS imbalance_rate,
  SAFE_DIVIDE(r.casual_events, r.station_events) AS casual_rider_share,
  SAFE_DIVIDE(r.weekend_events, r.station_events) AS weekend_ride_share
FROM station_rollup AS r
LEFT JOIN display_names AS n USING (station_id)
WHERE r.station_events > 0
ORDER BY r.station_id;
