create table staging.stg_sales_transactions as
with cleaned as (
    select
        nullif(trim(order_id), '') as order_id,
        nullif(trim(order_date), '')::date as order_date,
        nullif(trim(order_month), '')::integer as order_month,
        nullif(trim(order_quarter), '')::integer as order_quarter,
        nullif(trim(order_year), '')::integer as order_year,

        nullif(trim(customer_id), '') as customer_id,
        nullif(trim(region), '') as region,
        nullif(trim(province), '') as province,
        nullif(trim(channel), '') as channel,
        nullif(trim(employee_id), '') as employee_id,
        nullif(trim(product_id), '') as product_id,
        nullif(trim(product_category), '') as product_category,

        nullif(trim(quantity), '')::integer as quantity,
        nullif(trim(unit_price), '')::numeric as unit_price,
        nullif(trim(discount_pct), '')::numeric as discount_pct,
        nullif(trim(discount_amount), '')::numeric as discount_amount,
        nullif(trim(gross_amount), '')::numeric as gross_amount,
        nullif(trim(net_amount), '')::numeric as net_amount,

        nullif(trim(delivery_status), '') as delivery_status,
        nullif(trim(payment_method), '') as payment_method,
        nullif(trim(payment_status), '') as payment_status,
        row_number() over (
            partition by order_id, product_id
            order by _ingestion_at desc
        ) as rn
    from raw.sales_transactions
)
select
    order_id,
    order_date,
    order_month,
    order_quarter,
    order_year,
    customer_id,
    region,
    province,
    channel,
    employee_id,
    product_id,
    product_category,
    quantity,
    unit_price,
    discount_pct,
    discount_amount,
    gross_amount,
    net_amount,
    delivery_status,
    payment_method,
    payment_status
from cleaned
where rn = 1;