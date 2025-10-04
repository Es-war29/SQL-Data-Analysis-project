/*
------------------------------------------------------------------------------
Customer Report
------------------------------------------------------------------------------
Purpose:
    -This report consolidates key customer metrics and behaviours

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
    2. Segment customers into categories (VIP, Regular, New) and age groups.
    3. Aggregate customer-level metrics:
        - total orders
        - total sales
        - total quantity purchased
        - total products
        - lifespan (in months)
    4. Calculates valuable KPIs:
        - recency (months since last order)
        - average order value
        - average monthly spends
        
------------------------------------------------------------------------------
*/
Create or replace view customer_report as (
-- 1. Base Query: Retrieves core columns from the tables

with base_query as (
select 
    c.customer_key,
    c.customer_number,
    concat(c.first_name,' ',c.last_name) customer_name,
    datediff(year,c.birthdate, getdate()) customer_age,
    p.product_key,
    f.order_number,
    f.order_date,
    f.sales_amount,
    f.quantity
from fact_sales f
left join dim_customers c
on c.customer_key = f.customer_key
left join dim_products p
on p.product_key = f.product_key
where order_date is not null
),
--2.Customer Aggregations: summarizes key metrics at the customer level  

customer_aggregation as (
select 
    customer_key,
    customer_number,
    customer_name,
    customer_age,
    count(distinct order_number) total_orders,
    sum(sales_amount) total_sales,
    sum(quantity) total_quantity,
    count(distinct product_key) total_products,
    max(order_date) last_order,
    datediff(month, min(order_date),last_order) life_span
from base_query
group by customer_key,customer_number,customer_name,customer_age
)

-- final query

select 
    customer_key,
    customer_number,
    customer_name,
    customer_age,
    case
        when customer_age < 20 then 'Under 20'
        when customer_age between 20 and 29 then '20-29'
        when customer_age between 30 and 39 then '30-39'
        when customer_age between 40 and 49 then '40-49'
        else 'Above 50'
    end age_group,
    case 
        when life_span > 12 and total_sales > 5000 then 'VIP'
        when life_span > 12 and total_sales <= 5000 then 'Regular'
        else 'New'
    end customer_segments,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    life_span,
    last_order,
    datediff(month,last_order,getdate()) recency,
    --compute average order value (AVO)
    case when total_sales =0 then 0
         else total_sales /total_orders 
    end avg_order_value,
    -- compute average monthly spend
    case when life_span =0  then total_sales
         else total_sales/life_span
    end avg_monthly_spend
from customer_aggregation

-- final step: create a view and store the query at the top of the base query

);

select * from customer_report
where age_group = '30-39';

select
    age_group,
    count(customer_key) total_customers,
    sum(total_sales) total_sales
from customer_report
group by age_group;

------------------------------------------------------------------------------------------
