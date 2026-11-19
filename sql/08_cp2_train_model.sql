-- Step 08 fits a linear model for station-level absolute imbalance rate.
-- Replace YOUR_PROJECT with your BigQuery project ID.
CREATE OR REPLACE MODEL `YOUR_PROJECT.busm410_cp2.station_imbalance_model`
OPTIONS(model_type='linear_reg',input_label_cols=['y_abs_imbalance_rate'],
 calculate_p_values=TRUE,category_encoding_method='DUMMY_ENCODING',
 max_iterations=50,early_stop=FALSE) AS
SELECT y_abs_imbalance_rate,x_prior_station_events,x_prior_net_imbalance_rate,
 x_prior_subscriber_share,x_prior_mean_tripduration_seconds
FROM `YOUR_PROJECT.busm410_cp2.station_analysis`;
