## Profiling Summary

| Table | Rows | Key NULL | Duplicate Key | Other Issues |
|---|---:|---:|---:|---|
| customer_master | 2000 | 0 | 0 | tax_code missing: 1035 (51.75%) |
| distributor_master | 138 | 0 | 0 | No issues |
| distributor_orders | 35945 | 0 | 0  | key: `order_id` + `product_id` |
| employee_master_change_log | 13 | 0 | 0 | new_region/new_team blank: 8 |
| employee_master_v1 | 114 | 0 | 0 | No issues |
| employee_master_v2 | 114 | 0 | 0 | No issues |
| ingest_log | 16 | 0 | 0 | No issues |
| product_master | 100 | 0 | 0 | No issues |
| promotion_program | 40 | 0 | 0 | No issues |
| return_transactions | 3665 | 0 | 0 | No issues |
| sales_targets_raw | 1950 | 0 | 0 | No issues |
| sales_transactions | 119101 | 0 | 0 | Key: `order_id` + `product_id` |
| territory_mapping | 1843 | 0 | 0 | No issues |




## Issues & Planned Silver Treatment

| Table | Issue | Finding | Fix |
|---|---|---|---|
| customer_master | Missing tax_code | 1035/2000 rows (51.75%), concentrated in 3 customer types | Verify business rules; preserve NULL if no reliable source is available |
| distributor_master | No | No | No |
| distributor_orders | No | No | No |
| employee_master_change_log | Blank new_region/new_team | 8/13 rows; expected for resignation records | Preserve NULL; do not impute new assignments |
| employee_master_v1 | No | No | No |
| employee_master_v2 | No | No | No |
| ingest_log | No | No | No |
| product_master | No | No | No |
| product_program | No | No | No |
| return_transactions | No | No | No |
| sales_targets_raw | No | No | No |
| sales_transactions| No | No | No |
| territory_mapping| No | No | No |