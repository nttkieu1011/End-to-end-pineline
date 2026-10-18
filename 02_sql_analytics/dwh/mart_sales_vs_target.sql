
create view dwh.mart_sales_vs_target as
with sales_by_month as (
    select
        date_trunc('month', order_date)::date as sales_month,
        employee_id,
        sum(net_amount) as actual_revenue,
        sum(quantity) as actual_quantity,
        count(distinct order_id) as actual_orders
    from dwh.fact_sales
    group by
        date_trunc('month', order_date)::date,
        employee_id
)
select
    t.target_month,
    t.employee_id,
    t.employee_name,
    t.region,
    t.team,

    t.version_label,
    t.version_date,
    t.is_latest,

    t.target_revenue,
    t.target_quantity,
    t.target_new_customers,

    coalesce(s.actual_revenue, 0) as actual_revenue,
    coalesce(s.actual_quantity, 0) as actual_quantity,
    coalesce(s.actual_orders, 0) as actual_orders,

    coalesce(s.actual_revenue, 0) - t.target_revenue
        as revenue_variance,

    case
        when t.target_revenue > 0 then
            coalesce(s.actual_revenue, 0) / t.target_revenue * 100
        else null
    end as revenue_achievement_pct

from dwh.fact_targets t
left join sales_by_month s
    on t.employee_id = s.employee_id
    and t.target_month = s.sales_month;
