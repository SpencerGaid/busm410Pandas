# CP2 model card

## Question and unit
The outcome is each station's absolute directional imbalance rate from April through December 2017. One row represents one station, the same unit as the CP1 station-level gap. Because Y is numeric, the model is linear regression.

## Inputs and timing
The four predictors are September 2016 station events, net imbalance rate, subscriber share, and mean trip duration. September is the last observed month before the documented October 2016–March 2017 source-data gap, so it is a distant baseline rather than activity immediately before the outcome period. Stations without observed September records receive 0 for prior-month fields; this means no baseline activity was observed, not that closure was confirmed.

Stations qualify with at least 10,000 station events during April–December 2017. The analysis table contains 552 station rows.

## Looked before modeling
The analysis table was built with `CREATE OR REPLACE TABLE` in `sql/06_cp2_analysis_table.sql`. The recorded quality query found zero nulls across Y and all four X columns. The separate range, uniqueness, five-check summary, and independent raw-data reconciliation have not been captured in the results log yet; run `sql/07_cp2_look_first.sql` and paste the returned results before submission.

The gap was examined by prior net-flow direction and by low-versus-high prior subscriber-share and trip-duration groups. The month-by-month check in `sql/10_cp2_monthly_split.sql` provides another view. Recorded months for station 281 were:

| Month | Station 281 rate | Other-station median | Other stations |
|---|---:|---:|---:|
| April 2017 | 8.88% | 0.89% | 535 |
| May 2017 | 10.06% | 0.82% | 540 |
| November 2017 | 3.39% | 0.95% | 532 |
| December 2017 | 3.14% | 1.14% | 531 |

These are four captured months, not a complete nine-month trend. Run Step 10 to capture June–October as well.

Three predictor comparisons:
- Stations with positive September 2016 net flow averaged a higher 2017 imbalance rate than stations with negative prior net flow (1.59% vs. 1.07%).
- Stations in the lowest prior subscriber-share quintile averaged 1.73% imbalance, versus 1.00% in the highest quintile.
- Stations in the highest prior mean-duration quintile averaged 1.89% imbalance, versus 1.08% in the lowest quintile.

These are descriptive group comparisons, not causal effects.

## Model evaluation
BigQuery ML created `station_imbalance_model`. Recorded evaluation results:

| Measure | Result |
|---|---:|
| r2_score | -0.01956 |
| mean_absolute_error | 0.012136 |
| mean_squared_error | 0.00003373 |
| median_absolute_error | 0.008863 |
| explained_variance | 0.004845 |

**Verdict:** The negative r2_score means the model explains very little station-to-station variation and performs worse than a simple mean baseline on the held-out evaluation. It is not useful for business prediction.

## Coefficients
Rounded values transcribed into the CP2 results log from `ML.ADVANCED_WEIGHTS`; rerun `sql/09_cp2_evaluate_and_weights.sql` and verify against the exact BigQuery output before submitting.

| X | Coefficient | p-value | Reading |
|---|---:|---:|---|
| Prior station events | -2.7041 | 0.2154 | Negative estimate; not statistically significant. |
| Prior net imbalance rate | +0.07724 | 0.00253 | Positive association; statistically significant at 0.05. |
| Prior subscriber share | -0.01027 | 0.05596 | Negative estimate; not statistically significant at 0.05. |
| Prior mean trip duration | +6.9933 | 0.05227 | Positive estimate; not statistically significant at 0.05. |

The two smallest recorded p-values are prior net imbalance rate and prior mean trip duration. Prior net imbalance has a positive association (p = 0.00253). Mean trip duration also has a positive estimate (p = 0.05227), but it does not meet the 0.05 significance threshold. Only one X is statistically significant in this model; the coefficients do not prove causes.

## Expected ending
**Kept** the CP1 expectation that station 281 deserved operational attention first. CP2 taught us that the recorded trip history shows associations, but these four station-level predictors explain almost none of the later differences and cannot tell us which operational change would fix the imbalance.

## Limitations
The predictors are seven months earlier than the outcome window because the source table has no dated rows from October 2016 through March 2017. The trip table does not include station capacity, dock inventory, outages, blocked demand, or operator rebalancing moves. This model describes associations in recorded trip flows and does not establish operational causes.
