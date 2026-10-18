
create view dwh.fact_returns as
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
from stg_return_transactions;
