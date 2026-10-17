create table staging.stg_customers as
with cleaned as (
    select
        nullif(trim(customer_id), '') as customer_id,
        nullif(trim(customer_name), '') as customer_name,
        nullif(trim(customer_type), '') as customer_type,
        nullif(trim(channel), '') as channel,
        nullif(trim(province), '') as province,
        nullif(trim(region), '') as region,
        nullif(trim(address), '') as address,
        nullif(trim(phone), '') as phone,
        nullif(trim(tax_code), '') as tax_code,
        nullif(trim(join_date), '')::date as join_date,
        nullif(trim(credit_limit), '')::numeric as credit_limit,
        nullif(trim(status), '') as status,

        row_number() over (
            partition by customer_id
            order by _ingestion_at desc
        ) as rn

    from raw.customer_master
)
select
    customer_id,
    customer_name,
    customer_type,
    channel,
    province,
    region,
    address,
    phone,
    tax_code,
    join_date,
    credit_limit,
    status
from cleaned
where rn = 1;