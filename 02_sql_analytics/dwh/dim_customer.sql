
create view dwh.dim_customers as
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
from staging.stg_customer_master;
