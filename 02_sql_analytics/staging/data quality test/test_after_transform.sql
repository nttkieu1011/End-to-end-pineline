--test sale_target_versioned
select
    version_label,
    count(*) as total_rows,
    count(*) filter (where is_latest) as latest_rows,
    count(*) filter (where not is_latest) as historical_rows
from staging.stg_sales_targets_versioned
group by version_label
order by version_label;

select
    employee_id,
    year,
    month_col,
    count(*) as latest_count
from staging.stg_sales_targets_versioned
where is_latest = true
group by employee_id, year, month_col
having count(*) > 1;

--test employee_master
	--kiểm tra tổng dòng, distinct nhân viên theo version
	select
	    version,
	    count(*) as total_rows,
	    count(distinct employee_id) as distinct_employees,
	    min(effective_date) as effective_from,
	    max(effective_date) as latest_effective_date
	from stg_employee_master
	group by version
	order by version;

	--kiểm tra cột ngày
	select
	    count(*) as total_rows,
	
	    count(*) filter (
	        where date_of_birth is null
	    ) as null_date_of_birth,
	
	    count(*) filter (
	        where join_date is null
	    ) as null_join_date,
	
	    count(*) filter (
	        where effective_date is null
	    ) as null_effective_date,
	
	    count(*) filter (
	        where resign_date is not null
	    ) as rows_with_resign_date,
	
	    count(*) filter (
	        where resign_date < join_date
	    ) as resign_before_join
	from staging.stg_employee_master;
	
	--trạng thái nhân viên
	select
	    version,
	    status,
	    count(*) as total_rows,
	    count(*) filter (
	        where resign_date is not null
	    ) as rows_with_resign_date,
	    count(*) filter (
	        where effective_to is not null
	    ) as rows_with_effective_to
	from staging.stg_employee_master
	group by version, status
	order by version, status;

	--lịch sử thay đổi nhân viên
	select
	    change_type,
	    count(*) as total_rows,
	    count(distinct employee_id) as distinct_employees,
	    min(effective_date) as first_effective_date,
	    max(effective_date) as last_effective_date
	from raw.employee_master_change_log
	group by change_type
	order by change_type;