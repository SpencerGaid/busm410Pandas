# CP2 workflow notes

## Current status

The CP2 station-level analysis table and linear regression have been built. The model uses April–December 2017 station imbalance as Y and four September 2016 station measures as X variables. September 2016 is the last observed month before the October 2016–March 2017 data gap, so it is a distant baseline rather than activity immediately before the outcome.

The recorded table contains 552 stations, and the recorded quality output showed zero nulls in Y and all four X columns. The recorded model evaluation has an `r2_score` of -0.01956, so it is not useful for business prediction. See [cp2_results.md](cp2_results.md) and [model_card.md](model_card.md) for the comparisons, model output, interpretation, and limitations.

## Evidence still to capture

The repository includes reproducible queries for the remaining checks, but their full outputs are not yet recorded:

1. Run [sql/07_cp2_look_first.sql](../sql/07_cp2_look_first.sql) and record the five check rows and the independent raw-data reconciliation in [cp2_results.md](cp2_results.md).
2. Run [sql/10_cp2_monthly_split.sql](../sql/10_cp2_monthly_split.sql) and record all nine months. Four months are currently captured.
3. Rerun [sql/09_cp2_evaluate_and_weights.sql](../sql/09_cp2_evaluate_and_weights.sql) and compare the fresh values with the recorded model card before submission.

Do not present expected or logically implied values as if BigQuery returned them. Keep the missing query outputs labeled as outstanding until they are captured.

## Historical coverage context

The dated public-table history has 53 months from July 2013 through May 2018, with a six-month gap from October 2016 through March 2017. A further 5,828,994 table rows have null `starttime` and cannot be assigned to a month. See [data_coverage.md](data_coverage.md) and [01_monthly_coverage.sql](01_monthly_coverage.sql) for the coverage counts and reproducible query.

The original one-month-ahead station-month plan was superseded by the CP2 station-level question and rubric. The six-month source gap remains relevant when interpreting the September 2016 predictors.
