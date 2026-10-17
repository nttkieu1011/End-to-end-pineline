create table staging.stg_distributor_master as
with cleaned as (
    select
        nullif(trim(distributor_id), '') as distributor_id,
        nullif(trim(distributor_name), '') as distributor_name,
        nullif(trim(tier), '') as tier,
        nullif(trim(channel), '') as channel,
        nullif(trim(province), '') as province,
        nullif(trim(region), '') as region,
        nullif(trim(contact_person), '') as contact_person,
        nullif(trim(phone), '') as phone,
        nullif(trim(email), '') as email,
        nullif(trim(tax_code), '') as tax_code,
        nullif(trim(join_date), '')::date as join_date,
        nullif(trim(credit_limit), '')::numeric as credit_limit,
        nullif(trim(status), '') as status,
        nullif(trim(assigned_supervisor_id), '') as assigned_supervisor_id,

        row_number() over (
            partition by distributor_id
            order by _ingestion_at desc
        ) as rn
    from raw.distributor_master
)
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
from cleaned
where rn = 1;