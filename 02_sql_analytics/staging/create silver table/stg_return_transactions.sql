create table staging.stg_return_transactions as
with cleaned as (
    select
        nullif(trim(return_id), '') as return_id,
        nullif(trim(original_order_id), '') as original_order_id,
        nullif(trim(return_date), '')::date as return_date,
        nullif(trim(return_month), '')::integer as return_month,
        nullif(trim(customer_id), '') as customer_id,
        nullif(trim(employee_id), '') as employee_id,
        nullif(trim(product_id), '') as product_id,
        nullif(trim(region), '') as region,
        nullif(trim(province), '') as province,
        nullif(trim(return_quantity), '')::integer as return_quantity,
        nullif(trim(unit_price), '')::numeric as unit_price,
        nullif(trim(return_amount), '')::numeric as return_amount,
        nullif(trim(return_reason), '') as return_reason,
        nullif(trim(status), '') as status,

        row_number() over (
            partition by return_id
            order by _ingestion_at desc
        ) as rn
    from raw.return_transactions
)
select
    return_id,
    original_order_id,
    return_date,
    return_month,
    customer_id,
    employee_id,
    product_id,
    region,
    province,
    return_quantity,
    unit_price,
    return_amount,
    return_reason,
    status
from cleaned
where rn = 1;