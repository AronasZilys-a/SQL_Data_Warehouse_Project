/*
==========================================
Data Quality Checks
==========================================
Purpose:
    This procedure validates Bronze layer tables before loading
    into Silver. It checks for key integrity, duplicates, nulls,
    formatting issues, value consistency, date validity, and
    business logic errors.

    Results highlight anomalies and define corrective actions
    required to ensure clean and reliable data in the Silver layer.
==========================================
*/


-- Table 1: crm_cust_info

--Checking primary key for duplicates and nulls
select
cst_id,
count(*) flag
from bronze.crm_cust_info
group by cst_id
having count(*) > 1 or cst_id is null;
--Result: Multiple duplicate and null values

--Checking string columns for leading and trailing spaces
select
cst_first_name,
cst_last_name
from bronze.crm_cust_info
where cst_first_name != TRIM(cst_first_name)
	or cst_last_name != TRIM(cst_last_name);
--Result: Multiple entries with leading and trailing spaces

--Checking for consistency and value standardization
select
DISTINCT cst_gender
from bronze.crm_cust_info;

select
DISTINCT cst_marital_status
from bronze.crm_cust_info;
-- Result: consistent abbreviated code values


-- Table 2: crm_prd_info

--Checking primary key for duplicates and nulls
select
prd_id,
count(*) flag
from bronze.crm_prd_info
group by prd_id
having count(*) > 1 or prd_id is null;
--Result: No result / all unique values

--Checking string columns for leading and trailing spaces
select
prd_nm
from bronze.crm_prd_info
where prd_nm != TRIM(prd_nm)
	or prd_line != TRIM(prd_line);
--Result: No result / no empty spaces

--Checking if there are negative or null product costs
select
prd_cost 
from bronze.crm_prd_info
where prd_cost < 0 or prd_cost is null;
--Result: No negative values, but several NULLs

----Checking for consistency and value standardization
select
DISTINCT prd_line
from bronze.crm_prd_info;
--Result: consistent abbreviated code values

--Checking for invlaid dates
--Expectation: End date always higher than start date
select
*
from bronze.crm_prd_info
where prd_end_dt < prd_start_dt;
--Result: wrong end dates


--Table 3: crm_sales_details

--Checking for leading and traling spaces
select
*
from bronze.crm_sales_details
where sls_ord_num != TRIM(sls_ord_num);
--Result: no empty spaces

--Checking table keys
select
sls_prd_key
from bronze.crm_sales_details
where sls_prd_key NOT IN (select prd_key  from silver.crm_prd_info);

select
sls_cust_id 
from bronze.crm_sales_details
where sls_cust_id NOT IN (select cst_id  from silver.crm_cust_info);
--Result: all sls_prd_key entires are valid

--Checking for invalid intiger date inputs
select
*
from bronze.crm_sales_details
where sls_order_dt <=0 or LEN(sls_order_dt) !=8;
--Result: Invalid entires '0' and short intigers !
select
*
from bronze.crm_sales_details
where sls_ship_dt <= 0 or LEN(sls_ship_dt) != 8;
--Result: all valid
select
*
from bronze.crm_sales_details
where sls_due_dt <= 0 OR LEN(sls_due_dt) != 8;
--Result: all valid

--Checking for invalid dates
--Expectation: Order date always less than shipping or due date
select
*
from bronze.crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt;
--Result: all dates are valid

--Checking for invlaid business logic (sales/quantity/price)
select
*
from bronze.crm_sales_details
where sls_sales IS NULL or sls_quantity IS NULL or sls_price IS NULL
	or sls_sales <= 0 or sls_price <= 0 or sls_quantity <= 0
	or sls_sales != (sls_price * sls_quantity) or sls_sales / sls_quantity != sls_price;
--Results: multiple null and negative entires



--Table 4: broze.erp_cust_az12

--Checking if the table keys match
select
cid
from bronze.erp_cust_az12;

select
cst_key
from silver.crm_cust_info;
--Result: erp_cust_az12 has extra characters

--Checking if the birth dates are valid
select
bdate
from bronze.erp_cust_az12
where bdate > GETDATE();
--Result: bdate contains future dates

--Checking data standardization and consistency
select
distinct gen
from bronze.erp_cust_az12;
--Result: incosistent entries and empty spaces


--Table 5:erp_loc_a101
--Checking if the table keys match
select
cid
from bronze.erp_loc_a101;

select
cst_key
from silver.crm_cust_info;
--Result: reduntant punctuation formating

--Checking data standardization and consistency
select
distinct cntry
from bronze.erp_loc_a101;
--Result: incosistent entries and empty spaces


--Table 6: 
--Checking for trailing and leading spaces
select
*
from bronze.erp_px_cat_g1v2
where cat != trim(cat)
	or subcat != trim(subcat)
	or maintenance != trim(maintenance)
	or id != trim(id);
--Result: no empty spaces

--Checking data standardization and consistency
select 
distinct cat
from bronze.erp_px_cat_g1v2;

select 
distinct subcat
from bronze.erp_px_cat_g1v2;

select 
distinct maintenance
from bronze.erp_px_cat_g1v2;
--Result: all consistent entries
