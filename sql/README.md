# SQL process

All queries use GoogleSQL in BigQuery against `bigquery-public-data.new_york_citibike.citibike_trips`. Run the files in numeric order. Each file starts with a short note that points back here.

## Query sequence

| Step | File | Purpose |
|---|---|---|
| 1 | [01_data_quality.sql](01_data_quality.sql) | Check the columns used by the gap for blanks, duplicates, invalid duration/time logic, label changes, and monthly coverage. |
| 2 | [02_station_balance.sql](02_station_balance.sql) | Turn each trip into one departure and one arrival event, aggregate by station, and rank high-volume stations. |
| 3 | [03_gap_benchmark.sql](03_gap_benchmark.sql) | Select the leading station and compare it with the median absolute rate among the other qualifying stations. |
| 4 | [04_value.sql](04_value.sql) | Apply documented 2017 rider-revenue and trip totals to the excess event count. |
| 5 | [05_chart_data.sql](05_chart_data.sql) | Return the two percentages plotted in `visuals/gap_chart.png`. |

## Scope and grain

- The date filter is based on `starttime`: April 1, 2017 inclusive through January 1, 2018 exclusive.
- A source row is one recorded trip.
- The analysis reshapes each trip into two station events: one departure and one arrival.
- A final analysis row is one station aggregated across the nine-month period.
- A station qualifies for the ranking and benchmark after 10,000 station events.

## Cleaning checks and choices

### Blanks

Step 01 counts null or blank station IDs/names and null timestamps and duration. The independent reproduction from the official monthly Citi Bike archives found **no blank key fields** among 14,118,669 scoped trips. Step 02 still removes an individual endpoint if that endpoint's station ID is null, so a missing start ID would not also erase a valid end event.

### Duplicates

Step 01 checks both exact duplicate rows and a narrower trip identity made from bicycle, timestamps, duration, and endpoint IDs. The independent reproduction found **zero duplicates** under both definitions. No deduplication is applied silently; if a future rerun returns a positive count, investigate before using Steps 02–05.

### Impossible or ambiguous times

- No scoped row has a nonpositive `tripduration`.
- There are 49 rows where local `stoptime` is earlier than `starttime`. They all occur during the repeated 1 a.m. hour on November 5, 2017, when daylight-saving time ended, and each reported duration is positive. They are retained as timezone ambiguity rather than treated as impossible trips.
- There are 43 trips that start by December 31 and stop in January 2018. They are retained because the scope consistently uses trip start time.
- A future-date count remains in Step 01 as a reusable guard.

### End-of-data coverage and station continuity

The scoped start-time range is April 1, 2017 00:00:58 through December 31, 2017 23:58:56. Station 281 appears from April 1 through December 31, and its net flow is positive in seven of the nine months. This makes an early station closure an implausible explanation for the period total.

### Station labels

Station ID is the aggregation key. Because a single ID can appear with label variations, Steps 02 and 03 use the most frequent observed station name for display, with alphabetical order as the tie-breaker. `ANY_VALUE` is not used for the final label.

## Reconciliation to the finding

Step 03 returns:

| Measure | Expected result |
|---|---:|
| Target station ID | 281 |
| Departures | 74,006 |
| Arrivals | 63,297 |
| Station events | 137,303 |
| Net departures | 10,709 |
| Target absolute imbalance rate | 7.7995% |
| Other qualifying stations | 551 |
| Peer median absolute imbalance rate | 0.5575% |
| Rate difference | 7.2420 percentage points |
| Benchmark events at target volume | 765.49 |
| Excess events | 9,943.51 |

These are the canonical query outputs used by `README.md`, `findings.md`, `charter.md`, `AGENTS.md`, and the chart.

## Value inputs

Step 04 uses two external, contemporaneous inputs:

- April–December 2017 rider revenue of $29,628,227, calculated from the [December](https://d21xlh2maitm24.cloudfront.net/nyc/December-2017-Citi-Bike-Monthly-Report.pdf?mtime=20180216162543) and [March](https://d21xlh2maitm24.cloudfront.net/nyc/March-2017-Citi-Bike-Monthly-Report.pdf?mtime=20170531110546) operating reports.
- Q2–Q4 ridership of 14,161,293 from NYC's [Bike Share Usage Data Report](https://a860-gpp.nyc.gov/downloads/s1784q72z?locale=en).

The query calculates $2.0922 per completed trip and about $20,803.80 in revenue equivalent. This is a scale comparison, not measured lost revenue.

## Cost and reproducibility

The station queries scan the public trip table for the selected dates. Preview the estimated bytes in BigQuery before running if cost controls apply. The project does not commit CSV or spreadsheet extracts; the SQL, expected outputs, source links, and finished chart remain in the repository.

