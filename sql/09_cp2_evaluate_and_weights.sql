-- Step 09 reports model fit and adjusted X coefficients.
-- Replace YOUR_PROJECT with your BigQuery project ID.
SELECT * FROM ML.EVALUATE(MODEL `YOUR_PROJECT.busm410_cp2.station_imbalance_model`);
SELECT * FROM ML.ADVANCED_WEIGHTS(MODEL `YOUR_PROJECT.busm410_cp2.station_imbalance_model`);
