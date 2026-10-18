
create table dwh.dim_date(
    full_date date primary key,
    day_of_month integer,
    day_of_week integer,
    day_name varchar(20),
    week_of_year integer,
    month integer,
    month_name varchar(20),
    quarter integer,
    year integer,
    fiscal_year integer,
    fiscal_month integer
);

truncate table dwh.dim_date;

insert into dwh.dim_date (
    full_date,
    day_of_month,
    day_of_week,
    day_name,
    week_of_year,
    month,
    month_name,
    quarter,
    year,
    fiscal_year,
    fiscal_month
)
select
    d::date as full_date,
    extract(day from d)::integer as day_of_month,
    extract(isodow from d)::integer as day_of_week,
    trim(to_char(d, 'day')) as day_name,
    extract(week from d)::integer as week_of_year,
    extract(month from d)::integer as month,
    trim(to_char(d, 'month')) as month_name,
    extract(quarter from d)::integer as quarter,
    extract(year from d)::integer as year,

    case
        when extract(month from d) >= 9
            then extract(year from d)::integer
        else extract(year from d)::integer - 1
    end as fiscal_year,

    case
        when extract(month from d) >= 9
            then extract(month from d)::integer - 8
        else extract(month from d)::integer + 4
    end as fiscal_month

from generate_series(
    date '2022-01-01',
    date '2026-12-31',
    interval '1 day'
) as d;
