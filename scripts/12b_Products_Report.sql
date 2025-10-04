-- 12b. Reporting
/*
------------------------------------------------------------------------------
Products Report
------------------------------------------------------------------------------
Purpose:
    -This report consolidates key product metrics and behaviours

Highlights:
    1. Gathers essential fields such as names, category, subcategory, and cost.
    2. Segment products by revenue to identify High-Performers, Mid-Range, or low-performers.
    3. Aggregate customer-level metrics:
        - total orders
        - total sales
        - total quantity sold
        - total customers (unique)
        - lifespan (in months)
    4. Calculates valuable KPIs:
        - recency (months since last order)
        - average order revenue (AOR)
        - average monthly revenue
        
------------------------------------------------------------------------------
*/
create or replace view product_report as (

-- 1. Base Query: Retrieves core columns from the tables
with base_query as(
select
    c.customer_key,
    p.product_key,
    p.product_number,
    p.product_name,
    p.category,
    p.subcategory,
    p.cost,
    f.order_number,
    f.quantity,
    f.sales_amount,
    f.order_date
from fact_sales f
left join dim_products p
on p.product_key = f.product_key
left join dim_customers c
on c.customer_key = f.customer_key
where order_date is not null -- only consider valid sales dates
),
--2.Product Aggregations: summarizes key metrics at the product level  
product_aggregation as (
    select 
        product_key,
        category,
        subcategory,
        product_name,
        cost,
        count(distinct order_number) total_orders,
        sum(sales_amount) total_sales,
        sum(quantity) total_quantity,
        count(distinct customer_key) total_customers,
        max(order_date) last_sale_date,
        datediff(month, min(order_date),last_sale_date) life_span,
        round(avg(sales_amount / nullif(quantity,0)),2) as avg_selling_price
    from base_query
    group by 
        product_key, category, subcategory, product_name, cost
)

-- final query

select 
        product_key,
        category,
        subcategory,
        product_name,
        cost,
        total_orders,
        total_sales,
        total_quantity,
        total_customers,
        avg_selling_price,
        case 
            when total_sales > 5000 then 'High-Performer'
            when total_sales >=1000 then 'Mid-Range'
            else 'Low-Performer'
        end  product_segment,
        life_span,
        last_sale_date,
        datediff(month,last_sale_date,getdate()) recency,
        --compute average order revenue (AVR)
        case when total_orders =0 then 0
             else round(total_sales /total_orders,2)
        end avg_order_revenue,
        -- compute average monthly spend
        case when life_span =0  then total_sales
             else round(total_sales/life_span,2)
        end avg_monthly_revenue   
from product_aggregation

-- final step: create a view and store the query at the top base query

);

select * from product_report;

select 
    category,
    count(product_key) total_products,
    sum(total_sales) total_sales
from product_report
group by category;
