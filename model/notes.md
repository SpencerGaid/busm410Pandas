# CP2 station-level analysis plan

## Question and grain

Which station-level characteristics are associated with Citi Bike directional imbalance across the system?

The analysis will use the April–December 2017 trip-start window already documented for CP1. Each output row represents one station across that period. The target population is every station with at least one departure or arrival event; no 10,000-event threshold will be applied to the main CP2 panel.

## Outcome and candidate predictors

- **Y, signed imbalance rate:** (departures - arrivals) / (departures + arrivals). Positive values indicate more departures; negative values indicate more arrivals. The denominator is station events, not unique rides.
- **X1, casual-rider share:** station endpoint events from Customer rides divided by all station events.
- **X2, weekend-ride share:** station endpoint events whose trip start date is Saturday or Sunday divided by all station events.
- **X3, total rides involving the station:** distinct source trip rows with the station as either endpoint. A trip is counted once for a station even if its start and end station are the same. The SQL identifies a source row by its complete JSON representation; exact duplicate source rows therefore count once.
- **Eligibility:** stations with a positive event denominator. A zero-denominator rate is undefined and is excluded; the panel SQL reports only stations with observed events.

The measures are calculated over the same period, so this is a cross-sectional association analysis. It is not a forecast and does not establish that rider mix or volume causes imbalance. If CP2 requires prediction, the team must instead construct earlier-period predictors and a later-period target with a chronological holdout.

## Reproducible panel

Run [02_station_level_panel.sql](02_station_level_panel.sql) in BigQuery. It produces one row per station ID and includes station name as a display label. Verify the row count equals the number of distinct non-null station IDs in the endpoint event set and inspect the returned values before modeling.

## Cleaning provenance and BigQuery evidence

Do not merge two different evidence sources:

- The CP1 cleaning values in [the SQL process notes](../sql/README.md) are described as an independent reproduction from official monthly Citi Bike archives. They are not evidence that sql/01_data_quality.sql was run in BigQuery.
- The historical monthly coverage file says its counts came from a user-run BigQuery query.
- The CP1 benchmark audit entry records that Spencer ran sql/03_gap_benchmark.sql in BigQuery and checked its returned benchmark values.

No BigQuery job URL or fresh result grid for sql/01_data_quality.sql is currently recorded here. Until Spencer runs that query and saves the job/result evidence, describe its cleaning counts as archive-reproduction results, not as BigQuery-verified results. The chat has no connected BigQuery execution tool.

## Audit-log correction

The audit log is reserved for checks Spencer actually performed. Delegating a task to the agent is an instruction/workflow event, not a check of the result. Do not invent new audit entries. Add a real entry only after Spencer has questioned, verified, or corrected a specific agent output, recording what he checked and the outcome; follow the approval process in [the audit protocol](../Other/audit_protocol.md).
