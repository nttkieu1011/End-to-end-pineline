
create view dwh.dim_products as
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
from staging.stg_product_master;
