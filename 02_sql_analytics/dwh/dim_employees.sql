
create view dwh.dim_employees as
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
    effective_date as effective_from,
    effective_to,
    (effective_to is null) as is_current,
    resign_date,
    transfer_note
from staging.stg_employee_master;

