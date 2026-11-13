# Historical trip-month coverage

## Summary

A BigQuery coverage query found **53 calendar months with dated trip rows**, from July 2013 through May 2018. Coverage is discontinuous:

- July 2013–September 2016: 39 consecutive months.
- October 2016–March 2017: no dated trip rows.
- April 2017–May 2018: 14 consecutive months.

The year-level check also returned **5,828,994 rows with a null `starttime`**. Those rows cannot be assigned to a calendar month and are excluded from month-ahead modeling. The null count is a separate table-wide count; the 53 monthly rows below all have non-null `starttime`.

## Monthly counts

| Month | Trip rows |
|---|---:|
| 2013-07 | 843,416 |
| 2013-08 | 1,001,958 |
| 2013-09 | 1,034,359 |
| 2013-10 | 1,037,712 |
| 2013-11 | 675,774 |
| 2013-12 | 443,966 |
| 2014-01 | 300,400 |
| 2014-02 | 224,736 |
| 2014-03 | 439,117 |
| 2014-04 | 670,780 |
| 2014-05 | 866,117 |
| 2014-06 | 936,880 |
| 2014-07 | 968,842 |
| 2014-08 | 963,489 |
| 2014-09 | 953,887 |
| 2014-10 | 828,711 |
| 2014-11 | 529,188 |
| 2014-12 | 399,069 |
| 2015-01 | 285,552 |
| 2015-02 | 196,930 |
| 2015-03 | 341,826 |
| 2015-04 | 652,390 |
| 2015-05 | 961,986 |
| 2015-06 | 941,219 |
| 2015-07 | 1,085,676 |
| 2015-08 | 1,179,044 |
| 2015-09 | 1,289,699 |
| 2015-10 | 1,212,277 |
| 2015-11 | 987,245 |
| 2015-12 | 804,125 |
| 2016-01 | 509,478 |
| 2016-02 | 560,874 |
| 2016-03 | 919,921 |
| 2016-04 | 1,013,149 |
| 2016-05 | 1,212,280 |
| 2016-06 | 1,460,318 |
| 2016-07 | 1,380,110 |
| 2016-08 | 1,557,663 |
| 2016-09 | 1,648,856 |
| 2017-04 | 1,315,404 |
| 2017-05 | 1,523,268 |
| 2017-06 | 1,731,594 |
| 2017-07 | 1,735,599 |
| 2017-08 | 1,816,498 |
| 2017-09 | 1,878,098 |
| 2017-10 | 1,897,592 |
| 2017-11 | 1,330,649 |
| 2017-12 | 889,967 |
| 2018-01 | 718,994 |
| 2018-02 | 843,114 |
| 2018-03 | 976,672 |
| 2018-04 | 1,307,543 |
| 2018-05 | 1,824,710 |

## Source and reproduction

The counts were supplied from a user-run query against the public BigQuery table. Re-run [01_monthly_coverage.sql](01_monthly_coverage.sql) to reproduce the monthly counts and null-starttime bucket. The query scans the trip table; review BigQuery's estimated bytes before running if scan limits apply.

