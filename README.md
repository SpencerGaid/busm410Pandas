# BUSM 410 Pandas Project

## About the Project

This repository is the working space for Team Pandas' BUSM 410 semester project. We use the NYC Citi Bike Trips public table in BigQuery to identify a measurable operating gap, compare it with other stations, and document a reproducible analysis.

## Introduction

Bike-share stations need enough bicycles for departures and enough open docks for arrivals. A sustained difference between departures and arrivals is a useful signal for where inventory pressure can build and where an operations manager may want to review rebalancing activity.

## Project Information

| Item | Detail |
|---|---|
| Team | Pandas |
| Team members | Spencer Gaid and Avalon |
| Dataset/source | NYC Citi Bike Trips in `bigquery-public-data.new_york_citibike.citibike_trips` |
| Period | Trips starting April 1 through December 31, 2017 |
| Business question | Which high-volume station has the largest directional imbalance, how does it compare with peer stations, and how large is the flow in monetary terms? |

## Problem framing

Among stations with at least 10,000 station events, **Grand Army Plaza & Central Park S** had the largest absolute net imbalance: 74,006 departures and 63,297 arrivals, or **10,709 net departures** across 137,303 station events. Its absolute imbalance rate was **7.80%**, compared with the **0.56% median** for the other 551 qualifying stations. That is a **7.24 percentage-point gap** and about **14.0 times** the peer benchmark. At the benchmark rate, the station would have about 765 net events, leaving about **9,944 excess one-way events**. Multiplying those events by the 2017 April–December rider-revenue average of $2.0922 per completed trip gives about **$20,800 in completed-ride revenue equivalent**. This amount is a scale comparison, not measured lost revenue or a rebalancing cost.

## Explore the work

| File | What it is for |
|---|---|
| [charter.md](charter.md) | Defines the question, decision, scope, and success criteria. |
| [findings.md](findings.md) | Presents the gap, benchmark, value calculation, chart, and limitations. |
| [sql/README.md](sql/README.md) | Explains the query sequence, cleaning choices, and reproducibility details. |
| [sql/01_data_quality.sql](sql/01_data_quality.sql) | Audits blanks, duplicates, time logic, and monthly coverage. |
| [sql/02_station_balance.sql](sql/02_station_balance.sql) | Converts trip endpoints into station events and ranks station imbalance. |
| [sql/03_gap_benchmark.sql](sql/03_gap_benchmark.sql) | Compares the leading station with the median of the other qualifying stations. |
| [sql/04_value.sql](sql/04_value.sql) | Converts the excess event count to a documented revenue-equivalent scale. |
| [sql/05_chart_data.sql](sql/05_chart_data.sql) | Returns the two values shown in the chart. |
| [visuals/gap_chart.png](visuals/gap_chart.png) | Shows the target station and peer benchmark side by side. |
| [Other/dataset_documentation.md](Other/dataset_documentation.md) | Records the source table, field meanings, grain, and official documentation links. |
| [Other/citibike_erd.pdf](Other/citibike_erd.pdf) | Shows the source-to-analysis table flow. |
| [Other/citibike_erd.dbml](Other/citibike_erd.dbml) | Contains the editable DBML version of the table diagram. |
| [Other/audit_protocol.md](Other/audit_protocol.md) | Describes how Spencer directs and checks the agent. |
| [Other/audit_log.md](Other/audit_log.md) | Records Spencer's checks in the five required categories. |
| [AGENTS.md](AGENTS.md) | Gives future agents the confirmed project facts and working rules. |

## Source documentation

- [Citi Bike system data](https://citibikenyc.com/system-data)
- [Google Cloud guide to BigQuery public datasets](https://cloud.google.com/bigquery/public-data)
- [Citi Bike December 2017 operating report](https://d21xlh2maitm24.cloudfront.net/nyc/December-2017-Citi-Bike-Monthly-Report.pdf?mtime=20180216162543)
- [Citi Bike March 2017 operating report](https://d21xlh2maitm24.cloudfront.net/nyc/March-2017-Citi-Bike-Monthly-Report.pdf?mtime=20170531110546)
- [NYC Bike Share Usage Data Report](https://a860-gpp.nyc.gov/downloads/s1784q72z?locale=en)

