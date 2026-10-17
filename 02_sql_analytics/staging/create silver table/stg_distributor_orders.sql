create table staging.stg_distributor_orders as
with cleaned as (
    select
        nullif(trim(order_id), '') as order_id,
        nullif(trim(order_date), '')::date as order_date,
        nullif(trim(order_month), '')::integer as order_month,
        nullif(trim(order_quarter), '')::integer as order_quarter,
        nullif(trim(distributor_id), '') as distributor_id,
        nullif(trim(region), '') as region,
        nullif(trim(channel), '') as channel,
        nullif(trim(product_id), '') as product_id,
        nullif(trim(product_category), '') as product_category,

        nullif(trim(qty_ordered), '')::integer as qty_ordered,
        nullif(trim(qty_delivered), '')::integer as qty_delivered,
        nullif(trim(fill_rate_pct), '')::numeric as fill_rate_pct,
        nullif(trim(unit_price_list), '')::numeric as unit_price_list,
        nullif(trim(distributor_price), '')::numeric as distributor_price,
        nullif(trim(gross_amount), '')::numeric as gross_amount,
        nullif(trim(delivered_amount), '')::numeric as delivered_amount,

        nullif(trim(expected_delivery_date), '')::date
            as expected_delivery_date,
        nullif(trim(actual_delivery_date), '')::date
            as actual_delivery_date,
        nullif(trim(ontime_delivery), '') as ontime_delivery,
        nullif(trim(delivery_status), '') as delivery_status,
        nullif(trim(payment_terms), '') as payment_terms,

        row_number() over (
            partition by order_id, product_id
            order by _ingestion_at desc
        ) as rn
    from raw.distributor_orders
)
select
    order_id,
    order_date,
    order_month,
    order_quarter,
    distributor_id,
    region,
    channel,
    product_id,
    product_category,
    qty_ordered,
    qty_delivered,
    fill_rate_pct,
    unit_price_list,
    distributor_price,
    gross_amount,
    delivered_amount,
    expected_delivery_date,
    actual_delivery_date,
    ontime_delivery,
    delivery_status,
    payment_terms
from cleaned
where rn = 1;