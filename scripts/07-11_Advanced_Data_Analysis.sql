/* Advanced Data Analysis */

--7. change-over-time trends

select
    order_Date,
    date_trunc(year,order_date) order_date1,
    year(order_date) order_year,
    month(order_date) order_month,
    date_trunc(month,order_date) order_date2,
    TO_CHAR(order_date, 'YYYY-MON-dd') formated_date,
    sum(sales_amount) total_sales,
    count(distinct(customer_key)) total_customers,
    sum(quantity) total_quantity
from fact_sales
where order_date is not null
group by order_date,order_date1,order_year, order_month,order_date2,formated_date
order by order_date,order_date1,order_year,order_month,order_date2,formated_date;



-- 8. Cumulative Analysis

-- calculate the total sales per month and the running total os sales over time

select
    order_by_month,
    total_sales,
    sum(total_sales) over(partition by year(order_by_month) order by order_by_month ROWS BETWEEN unbounded preceding AND current row) running_total,
    avg_price,
    avg(avg_price) over( partition by order_by_month order by order_by_month) moving_avg
from(
select 
    date_trunc(month,order_date) order_by_month,
    sum(sales_amount) total_sales,
    avg(price) avg_price
from fact_sales
where order_date is not null
group by order_by_month
)t
order by order_by_month;


--9. Performance Analysis

-- Analyze the yearly performance of products by comparing each product's sales to both 
-- it's average sales performance and the previous year sales


with yearly_product_sales as (
select
    year(f.order_date) order_year,
    p.product_name,
    sum(f.sales_amount) current_sales,
from fact_sales f
left join dim_products p 
on p.product_key = f.product_key
where f.order_date is not null
group by order_year,p.product_name
order by order_year)

select 
    order_year,
    product_name,
    current_sales,
    avg(current_sales) over(partition by product_name) avg_sales,
    current_sales - avg_sales diff_avg,
    case
        when diff_avg >0 then 'Above Average'
        when diff_avg <0 then 'Below Average'
        else 'Average'
    end avg_change,
    -- year-over-year analysis
    LAG(current_sales) over(partition by product_name order by order_year ) prev_sales, 
    current_sales - prev_sales diff_prev,
     case
        when diff_prev >0 then 'Increase Sales'
        when diff_prev <0 then 'Decrease Sales'
        else 'No Change'
    end py_change
from yearly_product_sales
order by product_name,order_year;


-- 10. Part-to-whole (Propotional ANalysis)

-- write categories contribute to the overall sales

with category_sales  as (
select
    p.category,
    sum(f.sales_amount) total_sales
from fact_sales f
left join dim_products p
on p.product_key =f.product_key
group by p.category
)

select 
    category,
    total_sales,
    sum(total_sales) over() overall_sales,
    concat(round((total_sales/ overall_sales)*100,2),'%') as percentage_of_total
from category_sales
order by total_sales DESC;

-- 11. Data Segemantation

-- segment products into cost range and count how many products fall into each segment

with product_segment as (
select
    product_key,
    product_name,
    cost,
    case 
        when cost < 100 then 'Below 100'
        when cost BETWEEN 100 and 500 then '100-500'
        when cost between 500 and 1000 then '500-1000'
        else 'Above 1000'
    end  cost_range
from dim_products)

select
     cost_range,
     count(product_key) total_products,
from product_segment
group by cost_range
order by total_products DESC;

/* 
    Group the customers into three segments based on their spending behaviour:
    - VIP: Customers with at least 12 months of history and spending more than $ 5000.
    - Regular: Customer with at least 12 months of history and spending $5000 or less.
    - New: Customer with a lifespan of less than 12 months.
    and find the total number of customers in each group
*/


with customer_spending as (
select
    c.customer_key,
    sum(f.sales_amount) total_spending,
    min(f.order_date) as first_order,
    max(f.order_date) as last_order,
    datediff(month,first_order,last_order) life_span,
    case 
        when life_span > 12 and total_spending > 5000 then 'VIP'
        when life_span > 12 and total_spending <= 5000 then 'Regular'
        else 'New'
    end customer_segments
from fact_sales f
left join dim_customers c
on c.customer_key = f.customer_key
group by c.customer_key
)

select 
    customer_segments,
    count(customer_key) total_cust_per_segment
from customer_spending
group by customer_segments
order by total_cust_per_segment desc;


-- 12. Reporting
-- Creating a report for products and customers is the final step, which will be uploaded in the next page
