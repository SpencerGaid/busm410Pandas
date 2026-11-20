# CP2 BigQuery results

Run in project `busm-410-123`, dataset `busm410_cp2`, on 2026-11-19.

## Analysis table and checks
The analysis table is built from public Citi Bike trips and uses one row per qualifying station. The outcome window is April–December 2017; stations require at least 10,000 station events. The recorded table has **552 stations**. The recorded quality output showed **0 nulls** in Y and each of the four X columns.

The five-check summary and an independent raw-data reconciliation are now in `sql/07_cp2_look_first.sql`, but their output has not been captured in this log. Run that file and record its check results before submission.

Y is the numeric absolute imbalance rate, so the matching model is linear regression. Predictors are September 2016 station events, net imbalance rate, subscriber share, and mean trip duration. September is the last observed month before the documented October 2016–March 2017 data gap; it is a distant baseline, not activity immediately before April 2017.

## Part A: gap and predictor comparisons

The Y means below are averages of station-level April–December 2017 absolute imbalance rates.

| Comparison | Group | Mean Y | Stations |
|---|---|---:|---:|
| Prior net-flow direction | Negative | 0.010668 | 283 |
| Prior net-flow direction | Positive | 0.015866 | 229 |
| Prior net-flow direction | Zero | 0.012375 | 40 |
| Prior subscriber-share quintile | 1 (lowest) | 0.017320 | 111 |
| Prior subscriber-share quintile | 5 (highest) | 0.009991 | 110 |
| Prior mean-duration quintile | 1 (lowest) | 0.010791 | 111 |
| Prior mean-duration quintile | 5 (highest) | 0.018859 | 110 |

- Stations with positive September 2016 net flow averaged a higher later imbalance rate than stations with negative prior net flow (1.59% vs. 1.07%).
- Stations in the lowest prior subscriber-share quintile averaged 1.73% imbalance, compared with 1.00% in the highest quintile.
- Stations in the highest prior duration quintile averaged 1.89% imbalance, compared with 1.08% in the lowest quintile.

The monthly second view has four captured results so far:

| Month | Station 281 rate | Other-station median | Other stations |
|---|---:|---:|---:|
| April 2017 | 8.88% | 0.89% | 535 |
| May 2017 | 10.06% | 0.82% | 540 |
| November 2017 | 3.39% | 0.95% | 532 |
| December 2017 | 3.14% | 1.14% | 531 |

These four rows are not the complete nine-month trend. Run `sql/10_cp2_monthly_split.sql` to capture all months.

## Part B: model evaluation

Recorded BigQuery ML output:

| Measure | Result |
|---|---:|
| r2_score | -0.01956 |
| mean_absolute_error | 0.012136 |
| mean_squared_error | 0.00003373 |
| median_absolute_error | 0.008863 |
| explained_variance | 0.004845 |

**Verdict:** The negative r2_score means the model explains very little variation and performs worse than a simple mean baseline on the held-out evaluation. It is not suitable for business prediction.

## Coefficients

Rounded from the recorded `ML.ADVANCED_WEIGHTS` output; verify exact values against a fresh query before submitting.

| X | Coefficient | p-value | Reading |
|---|---:|---:|---|
| Prior station events | -2.7041 | 0.2154 | Negative estimate; not significant. |
| Prior net imbalance rate | +0.07724 | 0.00253 | Positive association; significant at 0.05. |
| Prior subscriber share | -0.01027 | 0.05596 | Negative estimate; not significant at 0.05. |
| Prior mean trip duration | +6.9933 | 0.05227 | Positive estimate; not significant at 0.05. |

Only one predictor meets the p < 0.05 threshold. The two smallest recorded p-values are prior net imbalance (positive, p = 0.00253) and mean trip duration (positive, p = 0.05227); the latter does not meet the 0.05 cutoff. Neither result proves causation.

## AI assistance
AI assistance was used to organize and edit the SQL and written analysis, interpret the recorded output, and prepare this repository update. The student should rerun the included queries, verify the recorded figures, and review the final wording before submission.
