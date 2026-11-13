# CP2 model planning notes

## Current status

CP1 remains a descriptive gap analysis. The station ranking, peer benchmark, value calculation, and data-quality checks have been rerun in BigQuery and matched the documented CP1 results. No predictive model has been fitted yet.

## Proposed model question

Can the team predict each station's directional imbalance one month ahead from prior Citi Bike trip activity, so an operations team can prioritize stations for review?

- **Prediction unit:** one station-month.
- **Target:** the following month's net imbalance rate, calculated as `(departures - arrivals) / (departures + arrivals)`.
- **Decision supported:** create a station review list for the coming month.
- **Interpretation limit:** trip-flow imbalance is not a direct measure of bicycle inventory, dock availability, customer outages, or operator rebalancing moves.

## Data coverage

The dated public-table history has 53 months from July 2013 through May 2018, with a six-month gap from October 2016 through March 2017. A further 5,828,994 table rows have null `starttime` and cannot be assigned to a month. See [data_coverage.md](data_coverage.md) and [01_monthly_coverage.sql](01_monthly_coverage.sql) for the observed counts and reproducible query.

Never treat the six-month gap as zero-activity months or create lag features across it. For a one-month lag, April 2017 cannot be evaluated as a target because March 2017 is absent.

## Proposed chronological evaluation

These are target months; a feature row uses the immediately preceding observed calendar month.

| Stage | Target months | Use |
|---|---|---|
| Initial training | August 2013–December 2014 | Fit candidate models using prior-month information. |
| Validation | January–December 2015 | Choose a simple model and tune it without using the later holdout. |
| Final test | May 2017–May 2018 | Evaluate on the later contiguous block; April 2017 is omitted because March 2017 is missing. |

After selecting the model, the final fit may add eligible history through September 2016. Build training pairs only where feature and target months are consecutive. Do not use the final test block for model or threshold selection. The 2015 validation period can be included in the final fit after model selection.

## Decisions still needed before building the station-month panel

1. Set an activity eligibility rule and define what happens when a station has no events in a month; do not silently assign a zero rate when the denominator is zero.
2. Define a baseline forecast and an evaluation metric suitable for the target.
3. Confirm that the proposed time split satisfies the course's CP2 requirements, if a separate rubric specifies different periods.

