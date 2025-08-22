/*
==========================================
DDL Script for Gold Layer Views
==========================================
Purpose:
    This script defines the Gold layer views in the Gold schema.
    The views are derived from the cleaned and standardised Silver layer 
    tables, representing two dimension tables (Customer and Product) 
    and one fact table (Sales) to form a star schema. 

    All columns are enriched with user-friendly names, standardised formats,
    and additional calculated or derived fields where applicable.

    The resulting Gold layer views provide a clean, consistent, and analytics-ready
    representation of the underlying data, optimised for querying and business reporting.
==========================================
*/


-- Building the Gold Layer objects


-- Customer Dimension View Object
CREATE VIEW gold.dim_customer AS
select
row_number() over(order by ci.cst_id) as customer_key,
ci.cst_id as customer_id,
ci.cst_key as customer_number,
ci.cst_first_name as first_name,
ci.cst_last_name as last_name,
ci.cst_marital_status as marital_status,
CASE WHEN ci.cst_gender != 'n/a' THEN ci.cst_gender
	 ELSE COALESCE(ca.gen,'n/a') END gender, --Enhancing data completeness through integration of multiple sources
la.cntry as country,
ca.bdate as birth_date,
ci.cst_create_date as create_date
from silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
on ci.cst_key  = ca.cid
LEFT JOIN silver.erp_loc_a101 la
on ci.cst_key = la.cid;


--Product Dimension View Object
CREATE VIEW gold.dim_product AS
select
row_number() over (order by pdi.prd_start_dt, pdi.prd_id) as product_key,
pdi.prd_id as product_id,
pdi.prd_key as product_number,
pdi.prd_nm as product_name,
pdi.cat_id as category_id,
pc.cat as category,
pc.subcat as subcategory,
pdi.prd_line as product_line,
pc.maintenance as maintenance,
pdi.prd_cost as product_cost,
pdi.prd_start_dt as product_cost_start_date
from silver.crm_prd_info pdi
LEFT JOIN silver.erp_px_cat_g1v2 pc
on pdi.cat_id = pc.id
where prd_end_dt IS NULL; -- Keeping only the latest dimension details while removing outdated historical entries


--Sales Fact View Object
CREATE VIEW gold.fact_sales AS
select
sd.sls_ord_num as order_number,
dp.product_key,
dc.customer_key,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as shipping_date,
sd.sls_due_dt as due_date,
sd.sls_price as unit_price,
sd.sls_quantity as quantity,
sd.sls_sales as sales_amount
from silver.crm_sales_details sd
LEFT JOIN gold.dim_product dp
on sd.sls_prd_key = dp.product_number
LEFT JOIN gold.dim_customer dc
on sd.sls_cust_id = dc.customer_id;
