-- Step 03 compares the largest gap with peer stations; see sql/README.md for benchmark rationale.
WITH scoped_trips AS (
  SELECT *
  FROM `bigquery-public-data.new_york_citibike.citibike_trips`
  WHERE starttime >= DATETIME '2017-04-01 00:00:00'
    AND starttime < DATETIME '2018-01-01 00:00:00'
),
station_events AS (
  SELECT
    event.station_id,
    event.station_name,
    event.is_departure
  FROM scoped_trips AS trip
  CROSS JOIN UNNEST([
    STRUCT(trip.start_station_id AS station_id, trip.start_station_name AS station_name, TRUE AS is_departure),
    STRUCT(trip.end_station_id AS station_id, trip.end_station_name AS station_name, FALSE AS is_departure)
  ]) AS event
  WHERE event.station_id IS NOT NULL
),
station_name_counts AS (
  SELECT station_id, station_name, COUNT(*) AS name_uses
  FROM station_events
  WHERE station_name IS NOT NULL AND TRIM(station_name) != ''
  GROUP BY station_id, station_name
),
canonical_names AS (
  SELECT station_id, station_name
  FROM station_name_counts
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY station_id
    ORDER BY name_uses DESC, station_name
  ) = 1
),
station_totals AS (
  SELECT
    station_id,
    COUNTIF(is_departure) AS departures,
    COUNTIF(NOT is_departure) AS arrivals,
    COUNT(*) AS total_station_events
  FROM station_events
  GROUP BY station_id
),
eligible AS (
  SELECT
    totals.station_id,
    names.station_name,
    totals.departures,
    totals.arrivals,
    totals.total_station_events,
    totals.departures - totals.arrivals AS net_departures,
    SAFE_DIVIDE(
      totals.departures - totals.arrivals,
      totals.total_station_events
    ) AS net_imbalance_rate
  FROM station_totals AS totals
  LEFT JOIN canonical_names AS names USING (station_id)
  WHERE totals.total_station_events >= 10000
),
target AS (
  SELECT *
  FROM eligible
  QUALIFY ROW_NUMBER() OVER (
    ORDER BY ABS(net_departures) DESC, station_id
  ) = 1
),
peers AS (
  SELECT eligible.*
  FROM eligible
  CROSS JOIN target
  WHERE eligible.station_id != target.station_id
),
peer_window AS (
  SELECT
    COUNT(*) OVER () AS peer_station_count,
    PERCENTILE_CONT(ABS(net_imbalance_rate), 0.5) OVER () AS peer_median_abs_imbalance_rate
  FROM peers
),
peer_stats AS (
  SELECT
    ANY_VALUE(peer_station_count) AS peer_station_count,
    ANY_VALUE(peer_median_abs_imbalance_rate) AS peer_median_abs_imbalance_rate
  FROM peer_window
)
SELECT
  target.station_id,
  target.station_name,
  target.departures,
  target.arrivals,
  target.total_station_events,
  target.net_departures,
  target.net_imbalance_rate,
  peer_stats.peer_station_count,
  peer_stats.peer_median_abs_imbalance_rate,
  peer_stats.peer_median_abs_imbalance_rate * target.total_station_events AS benchmark_abs_events,
  ABS(target.net_departures)
    - peer_stats.peer_median_abs_imbalance_rate * target.total_station_events AS excess_abs_events,
  ABS(target.net_imbalance_rate)
    - peer_stats.peer_median_abs_imbalance_rate AS rate_gap,
  SAFE_DIVIDE(
    ABS(target.net_imbalance_rate),
    peer_stats.peer_median_abs_imbalance_rate
  ) AS target_to_benchmark_ratio
FROM target
CROSS JOIN peer_stats;

