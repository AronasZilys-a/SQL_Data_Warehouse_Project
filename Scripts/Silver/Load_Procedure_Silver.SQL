/*
==========================================
Silver Layer Data Transformation Procedure
==========================================
Purpose:
    This procedure loads data from the Bronze layer into the
    Silver schema tables. Target tables are truncated before
    loading to ensure only the latest snapshot is stored.

    During the load, data is cleaned through standardization,
    normalization, and consistency checks. Derived columns are
    also created to add business context and analytical value.

    The result is a Silver layer that provides a clean,
    consistent, and enriched version of the Bronze data.
==========================================
*/


CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN

DECLARE @start_time DATETIME, @end_time DATETIME

	BEGIN TRY
	PRINT '-----------------------------------';
		PRINT 'Loading Silver Layer';
		PRINT '-----------------------------------';
		PRINT'';
		PRINT'Truncating & Loading CRM Tables:';
		PRINT'crm_cust_info . crm_prd_info . crm_sales_details';

-- Clean and insert data into silver layer tables

			SET @start_time = GETDATE();

-- Table 1: crm_cust_info
TRUNCATE TABLE silver.crm_cust_info;
INSERT INTO silver.crm_cust_info
(
cst_id,
cst_key,
cst_first_name,
cst_last_name,
cst_marital_status,
cst_gender,
cst_create_date
)

select
cst_id,
cst_key,
TRIM(cst_first_name) cst_first_name,
TRIM(cst_last_name) cst_last_name,
CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M' then 'Married'
	 WHEN UPPER(TRIM(cst_marital_status)) = 'S' then 'Single'
	 ELSE 'n/a' END cst_marital_status,
CASE WHEN UPPER(TRIM(cst_gender)) = 'M' then 'Male'
	 WHEN UPPER(TRIM(cst_gender)) = 'S' then 'Female'
	 ELSE 'n/a' END cst_gender,
cst_create_date
from
(
select *,
row_number() over (partition by cst_id order by cst_create_date desc) as latest_record_flag
from bronze.crm_cust_info
WHERE cst_id IS NOT NULL
) flags
WHERE latest_record_flag = 1;


--Table 2: crm_prd_info
TRUNCATE TABLE silver.crm_prd_info;
INSERT INTO silver.crm_prd_info
(
    prd_id, 
    cat_id, 
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
select
prd_id,
REPLACE(SUBSTRING(prd_key,1,5),'-','_') cat_id,
SUBSTRING(prd_key,7, LEN(prd_key)) prd_key,
prd_nm,
COALESCE(prd_cost,0) prd_cost,
CASE UPPER(TRIM(prd_line))
	 WHEN 'M' THEN 'Mountain'
	 WHEN 'R' THEN 'Road'
	 WHEN 'T' THEN 'Touring'
	 WHEN 'S' THEN 'Other'
	 ELSE 'n/a' END prd_line,
CAST(prd_start_dt AS DATE) prd_start_dt,
CAST(LEAD(prd_start_dt,1) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) prd_end_dt
from bronze.crm_prd_info;


--Table 3: crm_sales_details
TRUNCATE TABLE silver.crm_sales_details;
INSERT INTO silver.crm_sales_details
(
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
)
select
sls_ord_num,
sls_prd_key,
sls_cust_id,

CASE WHEN sls_order_dt <= 0 or LEN(sls_order_dt) !=8 THEN NULL
	 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) END sls_order_dt,
CASE WHEN sls_ship_dt <= 0 or LEN(sls_ship_dt) !=8 THEN NULL
	 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) END sls_ship_dt,
CASE WHEN sls_due_dt <= 0 or LEN(sls_due_dt) !=8 THEN NULL
	 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) END sls_due_dt,

CASE WHEN sls_sales IS NULL or sls_sales <=0 or sls_sales != sls_quantity * ABS(sls_price)
	 THEN sls_quantity * ABS(sls_price)
	 ELSE sls_sales END sls_sales,
sls_quantity,
CASE WHEN sls_price IS NULL or sls_price <=0
	 THEN sls_sales / NULLIF(sls_quantity,0)
	 ELSE sls_price END sls_price
from bronze.crm_sales_details;



			SET @end_time = GETDATE();

			PRINT'-----------------------------------'
			PRINT'CRM Load Duration:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
			PRINT'-----------------------------------'


PRINT'';
		PRINT'Truncating & Loading ERP Tables:';
		PRINT'erp_cust_az12 . erp_loc_a101 . erp_px_cat_g1v2';

			SET @start_time = GETDATE();
--Table 4: erp_cust_az12

TRUNCATE TABLE silver.erp_cust_az12;
INSERT INTO silver.erp_cust_az12
(
cid,
bdate,
gen
)
select
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
	 ELSE cid END cid,
CASE WHEN bdate > GETDATE() THEN NULL
	 ELSE bdate END bdate,
CASE WHEN UPPER(TRIM(gen)) IN ('M', 'Male') THEN 'Male'
	 WHEN UPPER(TRIM(gen)) IN ('F', 'Female') THEN 'Female'
	 ELSE 'n/a' END gen
from bronze.erp_cust_az12;


--Table 5: erp_loc_a101
TRUNCATE TABLE silver.erp_loc_a101;
INSERT INTO silver.erp_loc_a101
(
cid,
cntry
)
select
REPLACE(cid,'-','') cid,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	 WHEN TRIM(cntry) IN ('USA','US') THEN 'United States'
	 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
	 ELSE TRIM(cntry) END cntry
from bronze.erp_loc_a101;


--Table 6: erp_px_cat_g1v2

TRUNCATE TABLE silver.erp_px_cat_g1v2;
INSERT INTO silver.erp_px_cat_g1v2
(
id,
cat,
subcat,
maintenance
)
select
id,
cat,
subcat,
maintenance
from bronze.erp_px_cat_g1v2;

SET @end_time = GETDATE();

			PRINT'-----------------------------------'
			PRINT'ERP Load Duration:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
			PRINT'-----------------------------------'
	END TRY
	BEGIN CATCH
	PRINT '---------------------------------'
	PRINT 'Error Message'+' '+ ERROR_MESSAGE();
	PRINT 'Error Message'+' '+ CAST (ERROR_NUMBER() AS NVARCHAR);
	PRINT 'Error Message'+' '+ Cast (ERROR_STATE() AS NVARCHAR);
	PRINT '---------------------------------'
	END CATCH
END

