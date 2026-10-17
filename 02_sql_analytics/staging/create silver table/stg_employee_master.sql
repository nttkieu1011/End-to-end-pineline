
create table staging.stg_employee_master as

with employee_versions as (
    select
        employee_id,
        full_name,
        gender,
        date_of_birth,
        join_date,
        position,
        region,
        team,
        email,
        phone,
        status,
        version,
        effective_date,
        resign_date,
        transfer_note
    from raw.employee_master_v1

    union all

    select
        employee_id,
        full_name,
        gender,
        date_of_birth,
        join_date,
        position,
        region,
        team,
        email,
        phone,
        status,
        version,
        effective_date,
        resign_date,
        transfer_note
    from raw.employee_master_v2
)

select
    employee_id,
    full_name,
    gender,
    nullif(trim(date_of_birth), '')::date as date_of_birth,
    nullif(trim(join_date), '')::date as join_date,
    position,
    region,
    team,
    email,
    phone,
    status,
    version,
    nullif(trim(effective_date), '')::date as effective_date,
    case
        when version = 'v1' then date '2024-06-30'
        else null
    end as effective_to,
    nullif(trim(resign_date), '')::date as resign_date,
    transfer_note
from employee_versions;
