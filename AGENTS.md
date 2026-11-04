# Agent Instructions

## Working rules

1. Read this file, `Other/audit_protocol.md`, `Other/audit_log.md`, and `.agents/skills/project-audit/SKILL.md` before changing analysis files.
2. Preserve teammate work and use a branch and pull request for material changes.
3. Keep raw CSV and Excel files out of the repository. Save reproducible SQL and small finished visuals instead.
4. Aggregate station activity by station ID. Use the most frequent observed station name only as a display label.
5. Call departures plus arrivals `station events`; do not label that sum as unique rides.
6. Do not describe net departures as proven lost rides, revenue, or rebalancing moves. The table lacks inventory snapshots, capacity, outage duration, blocked demand, and operator move records.
7. Keep one canonical set of confirmed numbers and update every document and chart when any number changes.
8. Only record a human check in `Other/audit_log.md` after Spencer reviews and approves the entry.
9. Use available links, query jobs, repository files, and connected tools before asking Spencer to repeat work or paste information again.

## Project facts

### Dataset and scope

- BigQuery table: `bigquery-public-data.new_york_citibike.citibike_trips`.
- Official background: [Citi Bike system data](https://citibikenyc.com/system-data).
- Study period: `starttime >= DATETIME '2017-04-01 00:00:00'` and `< DATETIME '2018-01-01 00:00:00'`.
- One trip contributes one start-station departure and one end-station arrival.
- One analysis row is one station aggregated across the nine-month period.

### Key columns

- Time and duration: `starttime`, `stoptime`, `tripduration`.
- Start endpoint: `start_station_id`, `start_station_name`.
- End endpoint: `end_station_id`, `end_station_name`.
- Supporting duplicate checks: `bikeid`, `usertype`, `birth_year`, `gender`.

### Cleaning decisions

- Filter the study period using trip start time.
- Retain trips that start in 2017 and stop after the year boundary.
- Retain the daylight-saving fallback rows with `stoptime < starttime` because their reported durations are positive and the reversal occurs in the repeated local hour.
- Exclude an endpoint only if that endpoint's station ID is null.
- Aggregate by station ID; choose the most frequent name for display.
- Limit benchmark analysis to stations with at least 10,000 station events.

### Confirmed gap and benchmark

- Target: station 281, Grand Army Plaza & Central Park S.
- Departures: 74,006; arrivals: 63,297; station events: 137,303.
- Net departures: 10,709; absolute imbalance rate: 7.7995%.
- Peer benchmark: 0.5575%, the median absolute rate among the other 551 qualifying stations.
- Difference: 7.2420 percentage points; target is 13.99 times the peer median.
- Benchmark events at target volume: 765.49; excess one-way events: 9,943.51.

### Confirmed value frame

- April–December 2017 rider revenue: $29,628,227, from December year-to-date less March year-to-date operating-report categories.
- Q2–Q4 2017 trips: 14,161,293 in NYC's Bike Share Usage Data Report.
- Revenue per completed trip: $2.0922.
- 9,943.51 × $2.0922 = $20,803.80, reported as about $20,800 in completed-ride revenue equivalent.
- Source links and the full caveat appear in `findings.md`.

