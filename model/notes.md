# CP2 workflow notes

## Current status

The CP2 station-level analysis table and linear regression have been built. The model uses April–December 2017 station imbalance as Y and four September 2016 station measures as X variables. September 2016 is the last observed month before the October 2016–March 2017 data gap, so it is a distant baseline rather than activity immediately before the outcome.

The recorded table contains 552 stations, and the recorded quality output showed zero nulls in Y and all four X columns. The recorded model evaluation has an `r2_score` of -0.01956, so it is not useful for business prediction. See [cp2_results.md](cp2_results.md) and [model_card.md](model_card.md) for the comparisons, model output, interpretation, and limitations.

## Easiest way to capture the remaining output

If the BigQuery connector is unavailable but the Google Cloud console opens for you, run [11_cp2_submission_snapshot.sql](../sql/11_cp2_submission_snapshot.sql). It produces one result set containing the five checks, raw-data reconciliation, all nine monthly comparison rows, fresh evaluation measures, and coefficients. The result table can then be copied into [cp2_results.md](cp2_results.md).

The repository does not have access to a signed-in Google Cloud session, so these outputs remain outstanding until the query is run successfully. Do not present expected or logically implied values as if BigQuery returned them.

## Historical coverage context

The dated public-table history has 53 months from July 2013 through May 2018, with a six-month gap from October 2016 through March 2017. A further 5,828,994 table rows have null `starttime` and cannot be assigned to a month. See [data_coverage.md](data_coverage.md) and [01_monthly_coverage.sql](01_monthly_coverage.sql) for the coverage counts and reproducible query.

The original one-month-ahead station-month plan was superseded by the CP2 station-level question and rubric. The six-month source gap remains relevant when interpreting the September 2016 predictors.
