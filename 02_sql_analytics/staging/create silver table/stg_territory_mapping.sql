create table staging.stg_territory_mapping as
with cleaned as (
    select
        nullif(trim(territory_id), '') as territory_id,
        nullif(trim(employee_id), '') as employee_id,
        nullif(trim(customer_id), '') as customer_id,
        nullif(trim(region), '') as region,
        nullif(trim(team), '') as team,
        nullif(trim(effective_date), '')::date as effective_date,
        nullif(trim(expiry_date), '')::date as expiry_date,
        nullif(trim(version), '') as version,

        row_number() over (
            partition by territory_id
            order by _ingestion_at desc
        ) as rn
    from raw.territory_mapping
)
select
    territory_id,
    employee_id,
    customer_id,
    region,
    team,
    effective_date,
    expiry_date,
    version
from cleaned
where rn = 1;