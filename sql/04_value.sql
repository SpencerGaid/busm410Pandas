-- Step 04 values the Step 03 excess; see sql/README.md for source links and interpretation.
WITH gap_result AS (
  SELECT
    281 AS station_id,
    'Grand Army Plaza & Central Park S' AS station_name,
    CAST(9943.514323214565 AS FLOAT64) AS excess_abs_events
),
published_inputs AS (
  SELECT
    CAST(29628227 AS FLOAT64) AS april_december_rider_revenue,
    CAST(14161293 AS FLOAT64) AS q2_q4_completed_trips
)
SELECT
  gap_result.station_id,
  gap_result.station_name,
  gap_result.excess_abs_events,
  published_inputs.april_december_rider_revenue,
  published_inputs.q2_q4_completed_trips,
  SAFE_DIVIDE(
    published_inputs.april_december_rider_revenue,
    published_inputs.q2_q4_completed_trips
  ) AS revenue_per_completed_trip,
  gap_result.excess_abs_events * SAFE_DIVIDE(
    published_inputs.april_december_rider_revenue,
    published_inputs.q2_q4_completed_trips
  ) AS completed_ride_revenue_equivalent
FROM gap_result
CROSS JOIN published_inputs;

