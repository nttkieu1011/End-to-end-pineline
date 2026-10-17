create table staging.stg_promotion_program as
with cleaned as (
    select
        nullif(trim(promotion_id), '') as promotion_id,
        nullif(trim(promotion_name), '') as promotion_name,
        nullif(trim(promotion_type), '') as promotion_type,
        nullif(trim(target_channel), '') as target_channel,
        nullif(trim(target_region), '') as target_region,
        nullif(trim(start_date), '')::date as start_date,
        nullif(trim(end_date), '')::date as end_date,
        nullif(trim(applicable_products), '') as applicable_products,
        nullif(trim(discount_pct), '')::numeric as discount_pct,
        nullif(trim(min_order_quantity), '')::integer as min_order_quantity,
        nullif(trim(budget_vnd), '')::numeric as budget_vnd,
        nullif(trim(actual_cost_vnd), '')::numeric as actual_cost_vnd,
        nullif(trim(status), '') as status,
        nullif(trim(created_by), '') as created_by,

        row_number() over (
            partition by promotion_id
            order by _ingestion_at desc
        ) as rn
    from raw.promotion_program
)
select
    promotion_id,
    promotion_name,
    promotion_type,
    target_channel,
    target_region,
    start_date,
    end_date,
    applicable_products,
    discount_pct,
    min_order_quantity,
    budget_vnd,
    actual_cost_vnd,
    status,
    created_by
from cleaned
where rn = 1;