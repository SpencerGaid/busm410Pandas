# CP2 model card (draft)

## Question and unit
One row represents one station, matching CP1. The outcome is the station's absolute directional imbalance rate for April-December 2017. The model is linear regression because Y is numeric.

## Inputs and timing
X variables summarize September 2016 station activity, before the outcome period: station events, net imbalance rate, subscriber share, and mean trip duration. September 2016 is the last observed month before the documented October 2016-March 2017 data gap. Treat this as an old baseline, not a measure of activity immediately before April 2017. Stations with no observed September records receive 0 for the prior-month fields; interpret these as no observed baseline activity, not confirmed station closure.

Eligible outcome stations have at least 10,000 station events in April-December 2017. The analysis has one station row each. Check the final row count; if fewer than 500, BigQuery ML does not hold out rows automatically and the evaluation is in-sample.

## Data checks and Part A
Run `sql/06_cp2_analysis_table.sql` and `sql/07_cp2_look_first.sql`. Paste the query results here and add one sentence for each comparison:
- Null and range checks:
- Second-way check:
- Gap by prior volume:
- Prior net imbalance comparison:
- Prior subscriber share comparison:
- Prior trip duration comparison:

## Model evaluation
Run `sql/08_cp2_train_model.sql` then `sql/09_cp2_evaluate_and_weights.sql`.
| Measure | Result | Meaning |
|---|---:|---|
| r2_score | [paste BigQuery result] | Closer to 1 means more variation explained. |

Verdict: Our r2_score is [number], so the model explains [a lot / a little] of the ups and downs in station imbalance.

## Coefficients
Paste ML.ADVANCED_WEIGHTS output and explain the two strongest real links (smallest p-values). A coefficient describes association while holding other X variables steady; it does not prove causation.

| X | Coefficient | p-value | Reading |
|---|---:|---:|---|
| Prior station events | pending query | pending query | |
| Prior net imbalance rate | pending query | pending query | |
| Prior subscriber share | pending query | pending query | |
| Prior mean trip duration | pending query | pending query | |

## Limitations
The predictors are seven months earlier than the outcome window because the source table has no dated rows October 2016-March 2017. The trip table does not contain station capacity, dock inventory, outages, blocked demand, or operator rebalancing moves. This model explains associations in recorded trip flows and cannot establish operational causes.
