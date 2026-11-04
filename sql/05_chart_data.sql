-- Step 05 returns the plotted values; see sql/README.md and visuals/notes.md for chart details.
SELECT *
FROM UNNEST([
  STRUCT(
    1 AS display_order,
    'Grand Army Plaza & Central Park S' AS comparison_group,
    CAST(7.7995382475 AS FLOAT64) AS absolute_imbalance_percent,
    137303 AS station_events
  ),
  STRUCT(
    2 AS display_order,
    'Median of 551 other qualifying stations' AS comparison_group,
    CAST(0.5575156237 AS FLOAT64) AS absolute_imbalance_percent,
    CAST(NULL AS INT64) AS station_events
  )
])
ORDER BY display_order;

