# Project Charter

## The question

Which high-volume Citi Bike station had the largest directional imbalance from April through December 2017, how far was it from a typical peer station, and how large was the excess flow in monetary terms?

## The decision this supports

This analysis supports a **Citi Bike operations manager deciding which station to review first for rebalancing schedules, dock capacity, and nearby-station routing**. It identifies a priority location and puts its imbalance on a common scale. A follow-up operational decision would use station inventory and outage data to choose the intervention.

## Scope

- **Dataset:** `bigquery-public-data.new_york_citibike.citibike_trips`.
- **Period:** Trips with `starttime` from April 1, 2017 through December 31, 2017.
- **Population:** Stations with at least 10,000 station events in the period.
- **Gap measure:** Absolute departures minus arrivals divided by departures plus arrivals.
- **Benchmark:** Median absolute imbalance rate among the other qualifying stations.
- **Unit of analysis:** One row is one station aggregated across the study period.
- **Value frame:** 2017 completed-ride revenue equivalent of excess one-way station events.

## What success looks like

- Identify the highest absolute station imbalance with a query that another person can rerun.
- Compare the result with a clear peer benchmark and explain why the benchmark fits.
- Keep the same counts, rates, and definitions in SQL, findings, chart, README, and agent facts.
- Show transparent value math using linked 2017 sources.
- State what the trip table can and cannot prove so a manager does not read the estimate as measured lost revenue.

