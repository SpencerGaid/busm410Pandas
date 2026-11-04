# Dataset documentation

## Source

The project uses the Google BigQuery public table:

```text
bigquery-public-data.new_york_citibike.citibike_trips
```

Official background and access documentation:

- [Citi Bike system data](https://citibikenyc.com/system-data), including the public trip-history field descriptions.
- [Google Cloud BigQuery public datasets](https://cloud.google.com/bigquery/public-data), including how public datasets are accessed and billed.

## Source-table grain

One source row represents one recorded Citi Bike trip. The table does not provide a durable `trip_id`, station inventory snapshots, station capacity history, blocked-trip demand, outage duration, or operator bicycle moves.

## Fields used by this analysis

| Column | Meaning in this project | Use |
|---|---|---|
| `starttime` | Local trip start date and time | Sets the April–December 2017 scope. |
| `stoptime` | Local trip stop date and time | Supports the time-quality audit. |
| `tripduration` | Reported trip duration in seconds | Helps distinguish daylight-saving ambiguity from nonpositive trips. |
| `start_station_id` | Start station identifier | Station key for departure events. |
| `start_station_name` | Display label recorded for the start station | Candidate label; station ID remains the grouping key. |
| `end_station_id` | End station identifier | Station key for arrival events. |
| `end_station_name` | Display label recorded for the end station | Candidate label; station ID remains the grouping key. |
| `bikeid` | Bicycle identifier | Part of the duplicate-trip identity check. |
| `usertype`, `birth_year`, `gender` | Rider attributes in the public trip history | Not used to select or value the CP1 gap. |

## Analysis tables

The SQL uses common table expressions rather than joining multiple physical datasets:

1. `scoped_trips` filters source trips by `starttime`.
2. `station_events` reshapes each trip into two rows: one start-station departure and one end-station arrival.
3. `station_totals` groups events by `station_id`.
4. `eligible` keeps stations with at least 10,000 events and calculates the imbalance rate.
5. `target` selects the station with the greatest absolute net imbalance.
6. `peers` excludes the target and supplies the median benchmark.

There is no physical-table join in the CP1 result. The diagram documents the source-to-derived flow and the columns passed between steps.

## Derived measures

```text
station events = departures + arrivals
net departures = departures - arrivals
net imbalance rate = net departures / station events
absolute imbalance rate = ABS(net imbalance rate)
```

A positive net value means more recorded trips left the station than arrived during the period. It is a directional flow signal, not direct proof of outages or the exact number of operator moves.

