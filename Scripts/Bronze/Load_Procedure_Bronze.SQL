/*
==========================================
Bronze Layer Data Load Procedure
==========================================
Purpose:
    This procedure loads data into the Bronze schema tables from
    CRM and ERP source files. It truncates existing tables before
    inserting fresh data, ensuring that the Bronze layer reflects
    the latest available information. Execution of this procedure
    also prints load durations for monitoring purposes.
==========================================
*/


CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN

DECLARE @start_time DATETIME, @end_time DATETIME

	BEGIN TRY
		PRINT '-----------------------------------';
		PRINT 'Loading Bronze Layer';
		PRINT '-----------------------------------';
		PRINT'';
		PRINT'Truncating & Loading CRM Tables:';
		PRINT'crm_cust_info . crm_prd_info . crm_sales_details';
			--Load CRM data into tables

			SET @start_time = GETDATE();

			TRUNCATE TABLE bronze.crm_cust_info;

			BULK INSERT bronze.crm_cust_info
			FROM 'C:\Users\AronasZilys\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
			WITH
			(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);


			TRUNCATE TABLE bronze.crm_prd_info;

			BULK INSERT bronze.crm_prd_info
			FROM 'C:\Users\AronasZilys\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
			WITH
			(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);


			TRUNCATE TABLE bronze.crm_sales_details;

			BULK INSERT bronze.crm_sales_details
			FROM 'C:\Users\AronasZilys\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
			WITH
			(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);

			SET @end_time = GETDATE();

			PRINT'-----------------------------------'
			PRINT'CRM Load Duration:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
			PRINT'-----------------------------------'

			-- Load ERP data into tables

			SET @start_time = GETDATE();

		PRINT'';
		PRINT'Truncating & Loading ERP Tables:';
		PRINT'erp_cust_az12 . erp_loc_a101 . erp_px_cat_g1v2';


			TRUNCATE TABLE bronze.erp_cust_az12;

			BULK INSERT bronze.erp_cust_az12
			FROM 'C:\Users\AronasZilys\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
			WITH
			(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);


			TRUNCATE TABLE bronze.erp_loc_a101;

			BULK INSERT bronze.erp_loc_a101
			FROM 'C:\Users\AronasZilys\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
			WITH
			(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);


			TRUNCATE TABLE bronze.erp_px_cat_g1v2;

			BULK INSERT bronze.erp_px_cat_g1v2
			FROM 'C:\Users\AronasZilys\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
			WITH
			(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);

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
