/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/
CREATE or ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;

	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT('================================================');
		PRINT('LOADING BRONZE LAYER');
		PRINT('================================================');


		PRINT('------------------------------------------------');
		PRINT 'LOADING CRM TABLES'
		PRINT('------------------------------------------------');

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info
		PRINT'>> Inserting Data into bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\myDataWarehouse\data\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2, -- we have a .csv file and actual data starts from the second row, that's why it is 2
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		SET @end_time = GETDATE();
		PRINT '>> Load Duration of bronze.crm_cust_info: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------------------------------'
	
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info
		PRINT '>> Inserting Data into bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\myDataWarehouse\data\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2, -- we have a .csv file and actual data starts from the second row, that's why it is 2
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration of bronze.crm_prd_info ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------------------------------'

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details
		PRINT '>> Inserting data into bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\myDataWarehouse\data\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2, -- we have a .csv file and actual data starts from the second row, that's why it is 2
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration of bronze.crm_sales_details ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------------------------------'

		-- BULK LOAD FOR ERP DATA
	
		PRINT('------------------------------------------------');
		PRINT 'LOADING ERP TABLES'
		PRINT('------------------------------------------------');

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12
		PRINT '>> Inserting Data into bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\myDataWarehouse\data\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2, -- we have a .csv file and actual data starts from the second row, that's why it is 2
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration of bronze.erp_cust_az12 ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------------------------------'

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101
		PRINT '>> Inserting Data into bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\myDataWarehouse\data\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2, -- we have a .csv file and actual data starts from the second row, that's why it is 2
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration of erp_loc_a101 ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------------------------------'


		SET @start_time = GETDATE();
		PRINT '>> Truncating Table bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2
		PRINT '>> Inserting Data into bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\myDataWarehouse\data\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2, -- we have a .csv file and actual data starts from the second row, that's why it is 2
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration of bronze.erp_px_cat_g1v2 ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------------------------------'

		SET @batch_end_time = GETDATE();
		PRINT '====================================================';
		PRINT 'LOADING BRONZE LAYER IS COMPLETED';
		PRINT 'Total Load Duration:'+ CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) as NVARCHAR) + ' seconds';
		PRINT '====================================================';
	END TRY
	BEGIN CATCH
		PRINT '====================================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Number' + CAST(ERROR_NUMBER() as VARCHAR);
		PRINT '====================================================';
	END CATCH
END
