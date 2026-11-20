# CP2 BigQuery results (review draft)

Run in project `busm-410-123`, dataset `busm410_cp2`, on 2026-11-19.

## Analysis table
`station_analysis` was created from the public Citi Bike trips table. The outcome window is April-December 2017, at one row per station, with the CP1 minimum of 10,000 station events. The table has **552 stations**. The quality query returned **0 nulls** for Y and each of the four X columns.

The outcome is numeric absolute imbalance rate, so the fitted model is linear regression. Predictors are September 2016 station events, net imbalance rate, subscriber share, and average trip duration. September is the last observed month before the documented October 2016-March 2017 data gap; this is a distant baseline, not immediately pre-outcome activity.

## Part A comparisons
The Y means below are group averages of the station-level April-December 2017 absolute imbalance rate.

| Suspect | Group | Mean Y | Stations |
|---|---|---:|---:|
| Prior net imbalance direction | Negative | 0.010668 | 283 |
| Prior net imbalance direction | Positive | 0.015866 | 229 |
| Prior net imbalance direction | Zero | 0.012375 | 40 |
| Prior subscriber share quintile | 1 (lowest) | 0.017320 | 111 |
| Prior subscriber share quintile | 5 (highest) | 0.009991 | 110 |
| Prior mean duration quintile | 1 (lowest) | 0.010791 | 111 |
| Prior mean duration quintile | 5 (highest) | 0.018859 | 110 |

Sentence: Stations with positive September 2016 net flow averaged a higher 2017 imbalance rate than stations with negative prior net flow (1.59% vs. 1.07%). This is descriptive, not causal.
Sentence: Stations in the lowest prior subscriber-share quintile averaged 1.73% imbalance, compared with 1.00% in the highest quintile.
Sentence: Stations in the highest prior duration quintile averaged 1.89% imbalance, compared with 1.08% in the lowest quintile.

## Part B model evaluation
BigQuery ML successfully created `station_imbalance_model`. Evaluation returned:

| Measure | Result |
|---|---:|
| r2_score | -0.01956 |
| mean_absolute_error | 0.012136 |
| mean_squared_error | 0.00003373 |
| median_absolute_error | 0.008863 |
| explained_variance | 0.004845 |

Verdict: The r2_score is -0.01956, so the model explains very little of the station-to-station variation in imbalance. It is not suitable for business prediction, but its coefficients can be discussed as associations with substantial limitations.

## Coefficients
Rounded from `ML.ADVANCED_WEIGHTS`; intercept omitted.

| X | Coefficient | p-value | Reading |
|---|---:|---:|---|
| Prior station events | -2.7041 | 0.2154 | Not statistically significant; could be chance. |
| Prior net imbalance rate | +0.07724 | 0.00253 | Positive, statistically significant association with later absolute imbalance. |
| Prior subscriber share | -0.01027 | 0.05596 | Not significant at 0.05. |
| Prior mean trip duration | +6.9933 | 0.05227 | Not significant at 0.05. |

Only one predictor meets the assignment's p < 0.05 threshold. Do not claim there are two significant drivers. Prior net imbalance is associated with the outcome; this does not establish causation.

## Readiness
**Not ready to submit yet.** This file records the model and the comparisons that were run, but the Part A deliverable still needs the required second way of splitting the gap (for example, a month-by-month comparison), the full five-check results, and confirmation of the second-way check. The SQL draft should also be reconciled with the successful queries, and the model card and audit/AI-assistance disclosure still need updating. Review the station-level outcome choice and the September 2016 baseline because the input month is separated from the outcome window by the six-month source-data gap.
