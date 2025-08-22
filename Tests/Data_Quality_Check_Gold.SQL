/*
==========================================
Gold Layer Key Integrity Check
==========================================
Purpose:
    This query validates that all foreign keys in the Gold fact_sales
    view have corresponding records in the dimension views (dim_product 
    and dim_customer). 

    No rows returned indicates full referential integrity between the fact
    and dimension tables, ensuring the star schema is consistent and reliable.
==========================================
*/


-- Key Integrity Test
-- Expectation: No rows returned = All foreign keys in fact_sales have matching records in the dimension tables.
select *
from gold.fact_sales f
LEFT JOIN gold.dim_product dp
on f.product_key = dp.product_key
LEFT JOIN gold.dim_customer dc
on f.customer_key = dc.customer_key
WHERE dp.product_key IS NULL
or dc.customer_key IS NULL
-- Result: No rows returned = No NULL or unmatched keys found.
