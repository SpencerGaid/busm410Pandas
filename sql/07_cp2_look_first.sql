-- Step 07 runs the five required checks on the CP2 analysis table.
-- Replace YOUR_PROJECT with your BigQuery project ID.
SELECT COUNT(*) rows, COUNTIF(y_abs_imbalance_rate IS NULL) y_nulls,
 COUNTIF(x_prior_station_events IS NULL) prior_events_nulls,
 COUNTIF(x_prior_net_imbalance_rate IS NULL) prior_rate_nulls,
 COUNTIF(x_prior_subscriber_share IS NULL) subscriber_share_nulls,
 COUNTIF(x_prior_mean_tripduration_seconds IS NULL) duration_nulls
FROM `YOUR_PROJECT.busm410_cp2.station_analysis`;

SELECT COUNTIF(y_abs_imbalance_rate < 0 OR y_abs_imbalance_rate > 1) impossible_y,
 COUNTIF(x_prior_station_events < 0) negative_prior_events,
 COUNTIF(x_prior_subscriber_share < 0 OR x_prior_subscriber_share > 1) invalid_subscriber_share,
 COUNTIF(x_prior_mean_tripduration_seconds < 0) negative_duration
FROM `YOUR_PROJECT.busm410_cp2.station_analysis`;

-- Second-way check: compare station count and mean Y calculated directly from raw data.
WITH e AS (
 SELECT x.station_id,x.departure
 FROM `bigquery-public-data.new_york_citibike.citibike_trips` t
 CROSS JOIN UNNEST([STRUCT(t.start_station_id station_id,TRUE departure),
                    STRUCT(t.end_station_id station_id,FALSE departure)]) x
 WHERE t.starttime >= DATETIME '2017-04-01' AND t.starttime < DATETIME '2018-01-01'
 AND x.station_id IS NOT NULL
), raw AS (
 SELECT station_id,COUNT(*) n,COUNTIF(departure) d,COUNTIF(NOT departure) a
 FROM e GROUP BY station_id HAVING n>=10000
)
SELECT COUNT(*) station_count,
 AVG(SAFE_DIVIDE(ABS(d-a),n)) mean_absolute_imbalance_rate
FROM raw;

-- Gap by prior activity: low/middle/high volume.
SELECT NTILE(3) OVER(ORDER BY x_prior_station_events) prior_volume_tertile,
 AVG(y_abs_imbalance_rate) mean_y, COUNT(*) stations
FROM `YOUR_PROJECT.busm410_cp2.station_analysis`
GROUP BY prior_volume_tertile ORDER BY prior_volume_tertile;

-- Suspects: compare Y with prior net imbalance, subscriber share, and duration.
SELECT ROUND(x_prior_net_imbalance_rate,1) prior_net_rate_bin, AVG(y_abs_imbalance_rate) mean_y, COUNT(*) stations
FROM `YOUR_PROJECT.busm410_cp2.station_analysis`
GROUP BY prior_net_rate_bin ORDER BY prior_net_rate_bin;
SELECT NTILE(5) OVER(ORDER BY x_prior_subscriber_share) subscriber_share_quintile,
 AVG(y_abs_imbalance_rate) mean_y, COUNT(*) stations
FROM `YOUR_PROJECT.busm410_cp2.station_analysis`
GROUP BY subscriber_share_quintile ORDER BY subscriber_share_quintile;
SELECT NTILE(5) OVER(ORDER BY x_prior_mean_tripduration_seconds) duration_quintile,
 AVG(y_abs_imbalance_rate) mean_y, COUNT(*) stations
FROM `YOUR_PROJECT.busm410_cp2.station_analysis`
GROUP BY duration_quintile ORDER BY duration_quintile;
