/*
==========================================
Exploratory Data Analysis Queries
==========================================
Purpose:
    This script contains queries designed to explore and analyse
    the cleaned data available in the Gold layer. It provides insights
    into customer behaviour, product performance, and sales trends
    by summarising and aggregating key metrics.

    These queries help identify patterns, anomalies, and opportunities
    for further analysis or reporting, using the final, processed
    and reliable data from the Gold layer.
==========================================
*/


-- Dimension Distributions

-- What countries do we operate in?
-- Which countries are our customers from?
-- How many customers are in each country?
select 
country,
count(*) as total_country_customers
from gold.dim_customer
group by country
order by count(*) desc;


-- What categories, subcategories and products exist?
-- How many different products do we offer?
select
distinct
category,
subcategory,
product_name
from gold.dim_product;



-- Date Ranges

-- What was the date of the first order in the business?
-- What was the date of the most recent order?
-- How many years has the business been operating based on order history?
select
min(order_date) as first_order,
max(order_date) as last_order,
datediff(year, min(order_date), max(order_date)) as years_operating
from gold.fact_sales;


-- What are the birth dates and ages of the oldest and youngest customers?
-- How old are the oldest and youngest customers?
select
min(birth_date) as oldest_birth_date,
datediff(year, min(birth_date), getdate()) as oldest_customer_age,
max(birth_date) as oldest_birth_date,
datediff(year, max(birth_date), getdate()) as youngest_customer_age
from gold.dim_customer;



-- Measure Aggregations (Easy To Read Format)

-- What is the total revenue? 
select
format(sum(sales_amount), 'N2') as revenue
from gold.fact_sales;


-- How many orders have been made?
select
format(count(distinct order_number), 'N0') total_orders
from gold.fact_sales;


-- How many products are sold?
select
format(sum(quantity), 'N0') total_products_sold
from gold.fact_sales;


-- How many customers made an order?
select
format(count(distinct customer_key), 'N0') active_customers
from gold.fact_sales;


-- What is the average order value?

with order_totals as
(
select
sum(sales_amount) total_order_sales
from gold.fact_sales
group by order_number
)
select
format(avg(total_order_sales), 'N2') as average_order_value
from order_totals;

-- Report summarising the key metrics above:

with order_totals as (
    select sum(sales_amount) as total_order_sales
    from gold.fact_sales
    group by order_number
)
select 'Revenue' as measure_name, format(sum(sales_amount), 'n2') as value
from gold.fact_sales

union all

select 'Total Orders', format(count(distinct order_number), 'n0')
from gold.fact_sales

union all

select 'Total Products Sold', format(sum(quantity), 'n0')
from gold.fact_sales

union all

select 'Active Customers', format(count(distinct customer_key), 'n0')
from gold.fact_sales

union all

select 'Average Order Value', format(avg(total_order_sales), 'n2')
from order_totals;



-- Magnitude Analysis

-- Which countries are our customers from?
-- How many customers are in each country? (total_country_customers)
-- What is each country’s share of the total customer base? (percent_of_total)
-- Which countries have the highest number of customers?
select 
country,
count(*) as total_country_customers,
cast(cast(count(*) as decimal(10,2))  / sum(count(*)) over()  * 100 as decimal(10,2)) as percent_of_total
from gold.dim_customer
group by country
order by count(*) desc;


-- How many customers belong to each gender? 
-- What percentage of the total customer base does each gender represent? 
select 
gender,
count(*) as total_gender_customers,
cast(cast(count(*) as decimal(10,2))  / sum(count(*)) over()  * 100 as decimal(10,2)) as percent_of_total
from gold.dim_customer
group by gender
order by count(*) desc;


-- How many products are in each category overall? (category_total_prod)
-- How many products are in each category and subcategory combination? (cat_and_subcat_total_prod)
-- Which category-subcategory combinations have the most products?
select
category,
subcategory,
sum(count(*)) over (partition by category) as category_total_prod,
count(*) as cat_and_subcat_total_prod
from gold.dim_product
group by category, subcategory
order by sum(count(*)) over (partition by category) desc, count(*) desc;


-- What is the average product cost per category?
-- What are the most expensive categories?
select
category,
avg(product_cost) as avg_cost
from gold.dim_product
group by category
order by avg(product_cost) desc;


-- What is the total revenue per country?
-- What countries generate the most revenue?
-- What percentage of total revenue does each country generate?
select
dc.country,
format(sum(fc.sales_amount), 'N2') as revenue,
format(cast(sum(fc.sales_amount) as decimal(10,2)) / sum(sum(fc.sales_amount)) over() * 100, 'N2') as percent_of_total
from gold.fact_sales fc
left join gold.dim_customer dc
on dc.customer_key = fc.customer_key
group by dc.country
order by sum(fc.sales_amount) desc;


-- What is the total revenue per category?
-- What categories generate the most revenue?
-- What percentage of total revenue does each category contribute?
select
pc.category,
format(sum(fc.sales_amount), 'N2') as revenue,
format(cast(sum(fc.sales_amount) as decimal(10,2)) / sum(sum(fc.sales_amount)) over() * 100, 'N2') as percent_of_total
from gold.fact_sales fc
left join gold.dim_product pc
on pc.product_key = fc.product_key
group by pc.category
order by sum(fc.sales_amount) desc;


-- What is the total revenue per customer?
-- What customers generate the most revenue?
select
dc.customer_id,
dc.first_name,
dc.last_name,
format(sum(fc.sales_amount), 'N2') as revenue
from gold.fact_sales fc
left join gold.dim_customer dc
on dc.customer_key = fc.customer_key
group by  dc.customer_id, dc.first_name, dc.last_name
order by sum(fc.sales_amount) desc;


-- How much revenue does each country-category combination generate?
-- Within each country, which product categories generate the most revenue?
select
dc.country,
dp.category,
format(sum(fc.sales_amount), 'N2') as revenue
from gold.fact_sales fc
left join gold.dim_customer dc
on dc.customer_key = fc.customer_key
left join gold.dim_product dp
on dp.product_key = fc.product_key
group by  dc.country, dp.category
order by dc.country, sum(fc.sales_amount) desc;


--What is the customer retention rate across years?
--Which countries have the highest repeat purchase rates?
with customer_years as
(
select
dc.customer_key,
dc.country,
year(fc.order_date) as order_year
from gold.fact_sales fc
left join gold.dim_customer dc
on dc.customer_key = fc.customer_key
where fc.order_date is not null 
group by dc.customer_key, dc.country, year(fc.order_date)
),

retained as
(
select
cy.customer_key,
cy.country,
cy.order_year,
case when ny.customer_key is not null then 1 else 0 end as retained
from customer_years cy
left join customer_years ny
on cy.customer_key = ny.customer_key
and ny.order_year  = cy.order_year + 1
)
select
country,
order_year,
count(distinct customer_key) as customers_current_year,
sum(retained) as retained_next_year,
cast(cast(sum(retained) as decimal(10,2)) / count(distinct customer_key)  * 100 as decimal(10,2)) as retention_percentage
from retained
group by country, order_year
order by country, order_year;


-- Ranking Analysis

--What are the top 10 best performing products?
with ranked as
(
select
dp.product_name,
format(sum(fc.sales_amount),'N2') as total_sales,
row_number() over( order by sum(fc.sales_amount) desc) as rank_sales
from gold.fact_sales fc
left join gold.dim_product dp
on dp.product_key = fc.product_key
group by dp.product_name
)
select
*
from ranked
where rank_sales < 11;


--What are the bottom 10 worst performing products?
with ranked as
(
select
dp.product_name,
format(sum(fc.sales_amount),'N2') as total_sales,
row_number() over( order by sum(fc.sales_amount) asc) as rank_sales
from gold.fact_sales fc
left join gold.dim_product dp
on dp.product_key = fc.product_key
group by dp.product_name
)
select
*
from ranked
where rank_sales < 11;


--What are the top 3 most purchased products in each country?
with ranked_pur as
(
select
dc.country,
dp.product_name,
count(fc.product_key) as product_purchases,
row_number() over (partition by dc.country order by count(fc.product_key) desc) as rank_purchases
from gold.fact_sales fc
left join gold.dim_customer dc
on dc.customer_key = fc.customer_key
left join gold.dim_product dp
on dp.product_key = fc.product_key
group by  dc.country, dp.product_name
)
select
*
from ranked_pur
where rank_purchases <4;
