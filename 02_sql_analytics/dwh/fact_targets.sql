
create view dwh.fact_targets as
select
    target_id,
    version_label,
    source_file,
    source_sheet,
    employee_id,
    employee_name,
    region,
    team,
    year,
    month_col,
    make_date(
        year,
        regexp_replace(month_col, '[^0-9]', '', 'g')::integer,
        1
    ) as target_month,
    target_revenue,
    target_quantity,
    target_new_customers,
    version_date,
    effective_from,
    effective_to,
    is_latest
from staging.stg_sales_targets_versioned;
