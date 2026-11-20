-- Step 08 fits linear regression because CP2 Y is a numeric station rate.
-- The rows remain stations, matching the unit used for the CP1 gap.
CREATE OR REPLACE MODEL `busm-410-123.busm410_cp2.station_imbalance_model`
OPTIONS(
  model_type='linear_reg',
  input_label_cols=['y_abs_imbalance_rate'],
  calculate_p_values=TRUE,
  category_encoding_method='DUMMY_ENCODING',
  max_iterations=50,
  early_stop=FALSE
) AS
SELECT y_abs_imbalance_rate,
  x_prior_station_events,
  x_prior_net_imbalance_rate,
  x_prior_subscriber_share,
  x_prior_mean_tripduration_seconds
FROM `busm-410-123.busm410_cp2.station_analysis`;
