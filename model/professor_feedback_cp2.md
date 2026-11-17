# Professor feedback and CP2 revision

## Feedback received

The professor recommended expanding the CP2 analysis from a single station to all stations, with one station per row, imbalance rate as the response, and station-level predictors such as casual-rider share, weekend-ride share, and total rides. The professor also asked the team to clarify whether the cleaning results were actually run in BigQuery and to strengthen the audit log with genuine checks of agent work.

## Revised modeling direction

- **Unit of analysis:** one station, aggregated over a clearly specified modeling period.
- **Response (Y):** signed station imbalance rate, `(departures - arrivals) / (departures + arrivals)`. State explicitly whether CP2 predicts signed imbalance or its absolute magnitude; the current recommendation is signed rate because departures versus arrivals carries direction.
- **Candidate predictors (X):** casual-rider share, weekend-ride share, and total rides, calculated at the station level over the same period.
- **Population:** all stations with a nonzero denominator in the defined period. Report how many are excluded for zero events and consider a minimum activity threshold only if justified and disclosed.
- **Modeling caution:** if predictors and Y use the same period, the analysis describes/explains station differences rather than forecasting. For a predictive claim, derive X from an earlier period and Y from a later period, with a chronological holdout. Avoid including total rides if the response denominator mechanically overlaps in a way that makes the relationship misleading.
- **Next step:** build and inspect the all-station station-level panel, confirm time period, variable definitions, eligibility, and CP2 rubric, then fit a baseline before more complex models.

This revision supersedes the single-station station-month proposal in `model/notes.md` for CP2. The earlier coverage notes remain relevant only if the team retains a month-ahead forecasting design.

## BigQuery execution and cleaning provenance

The current `model/data_coverage.md` says its coverage counts came from a user-run BigQuery query. Separately, `sql/README.md` describes several 2017 cleaning counts as an independent reproduction using official monthly archives. Those are different sources and should not be conflated.

The repository contains SQL and reported outputs, but this feedback thread does not provide BigQuery job links, screenshots, or a fresh query result for the cleaning checks. Therefore, this note does **not** claim that the SQL cleaning query has been run and verified in BigQuery. Before making that claim, run `sql/01_data_quality.sql` in BigQuery, record the job/result evidence, and reconcile its output with the archive reproduction. Preserve a clear source label for each result.

## Audit-log follow-up

The existing audit entries document one workflow correction and one verified benchmark claim. The professor's feedback identifies a genuine review issue: delegating work to the agent is not itself an audit check. Do not invent additional checks or mark this feedback as a completed verification. Add future entries only when Spencer has actually questioned, checked, or corrected a specific agent claim, and record the evidence and outcome under the matching category. Any new official entry remains subject to the approval process in `Other/audit_protocol.md`.
