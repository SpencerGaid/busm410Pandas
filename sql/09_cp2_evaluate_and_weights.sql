-- Step 09 returns regression fit measures and the adjusted coefficient table.
SELECT * FROM ML.EVALUATE(
  MODEL `busm-410-123.busm410_cp2.station_imbalance_model`
);

SELECT * FROM ML.ADVANCED_WEIGHTS(
  MODEL `busm-410-123.busm410_cp2.station_imbalance_model`
);
