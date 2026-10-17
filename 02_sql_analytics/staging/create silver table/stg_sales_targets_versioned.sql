create table staging.stg_sales_targets_versioned as
with version_metadata as (
    select
        version_label,
        version_date::date as version_date,
        effective_from::date as effective_from,
        effective_to::date as effective_to
    from raw.sales_target_versions
),

cleaned as (
    select
        r.target_id,
        r.version_label,
        r.source_file,
        r.source_sheet,
        nullif(trim(r.employee_id), '') as employee_id,
        nullif(trim(r.employee_name), '') as employee_name,
        nullif(trim(r.region), '') as region,
        nullif(trim(r.team), '') as team,
        nullif(trim(r.year), '')::integer as year,
        nullif(trim(r.month_col), '') as month_col,
        nullif(trim(r.target_revenue), '')::numeric as target_revenue,
        nullif(trim(r.target_quantity), '')::numeric as target_quantity,
        nullif(trim(r.target_new_customers), '')::integer as target_new_customers
    from raw.sales_targets_raw r
),

versioned as (
    select
        c.*,
        v.version_date,
        v.effective_from,
        v.effective_to,
        case
            when c.month_col in ('T1', 'T2', 'T3', 'T4', 'T5', 'T6')
                then true
            when c.month_col in ('T7', 'T8', 'T9', 'T10', 'T11', 'T12')
                 and c.version_label = 'v2'
                then true
            when c.month_col in ('T7', 'T8', 'T9', 'T10', 'T11', 'T12')
                 and c.version_label = 'v1'
                 and not exists (
                     select 1
                     from cleaned v2
                     where v2.version_label = 'v2'
                       and v2.employee_id = c.employee_id
                       and v2.year = c.year
                       and v2.month_col = c.month_col
                 )
                then true
            else false
        end as is_latest
    from cleaned c
    join version_metadata v
        on c.version_label = v.version_label
)

select *
from versioned;