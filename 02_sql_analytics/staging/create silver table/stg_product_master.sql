create table staging.stg_product_master as
with cleaned as (
    select
        nullif(trim(product_id), '') as product_id,
        nullif(trim(product_name), '') as product_name,
        nullif(trim(category), '') as category,
        nullif(trim(sub_category), '') as sub_category,
        nullif(trim(unit), '') as unit,

        nullif(trim(unit_price), '')::numeric as unit_price,
        nullif(trim(cost_price), '')::numeric as cost_price,
        nullif(trim(weight_gram), '')::integer as weight_gram,

        nullif(trim(status), '') as status,
        nullif(trim(launch_date), '')::date as launch_date,

        row_number() over (
            partition by product_id
            order by _ingestion_at desc
        ) as rn

    from raw.product_master
)
select
    product_id,
    product_name,
    category,
    sub_category,
    unit,
    unit_price,
    cost_price,
    weight_gram,
    status,
    launch_date
from cleaned
where rn = 1;