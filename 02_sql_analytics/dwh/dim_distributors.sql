
create view dwh.dim_distributors as
select
    distributor_id,
    distributor_name,
    tier,
    channel,
    province,
    region,
    contact_person,
    phone,
    email,
    tax_code,
    join_date,
    credit_limit,
    status,
    assigned_supervisor_id
from staging.stg_distributor_master;
