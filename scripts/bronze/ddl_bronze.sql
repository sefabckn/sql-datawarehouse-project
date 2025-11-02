/**********************************************************************************************
 Script:        create_bronze_tables.sql
 Author:        Sefa Bockun (Tutor Baraa Salkini - Youtube tutorial))
 Date:          v1.0.0
 Database:      SQL Server
 Project:       Data Engineering Portfolio – Data Warehouse (Medallion Architecture)

 Description:
 -----------------------------------------------------------------------------------------------
 This script creates all **Bronze Layer tables** used in the Data Warehouse as part of the 
 **Medallion Architecture** (Bronze → Silver → Gold).

 The Bronze Layer serves as the **raw data ingestion zone**, where data is loaded directly from 
 source systems (CRM and ERP). At this stage, the data is stored with minimal or no transformation, 
 preserving its original structure for traceability and auditing.

 Purpose:
 -----------------------------------------------------------------------------------------------
   1. Define base tables for staging raw CRM and ERP data.
   2. Maintain raw column names and data types consistent with source systems.
   3. Act as a historical landing zone before data cleansing and transformation in the Silver Layer.

 Layer Overview:
 -----------------------------------------------------------------------------------------------
   - **CRM Tables**
       • `bronze.crm_cust_info` – Raw customer data with identifiers, names, and demographic info.
       • `bronze.crm_prd_info` – Product reference data, including cost, lifecycle dates, and type.
       • `bronze.crm_sales_details` – Raw transactional sales data (orders, quantities, and prices).

   - **ERP Tables**
       • `bronze.erp_loc_a101` – Customer location data from ERP source.
       • `bronze.erp_cust_az12` – ERP customer information (birthdate, gender).
       • `bronze.erp_px_cat_g1v2` – Product category and maintenance hierarchy data.

 Notes:
 -----------------------------------------------------------------------------------------------
   - Tables are **dropped and recreated** each time to ensure a clean ingestion environment.
   - No data cleansing or type normalization is applied in this layer.
   - These tables act as inputs for the Silver Layer ETL process (`silver.load_silver`).

 Execution:
 -----------------------------------------------------------------------------------------------
   Run this script during environment setup or when resetting the data ingestion layer.
   Example:
       ```sql
       :r .\create_bronze_tables.sql
       ```

**********************************************************************************************/


-- CRM TABLES

IF OBJECT_ID('bronze.crm_cust_info' , 'U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info

CREATE TABLE bronze.crm_cust_info (
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE
);

IF OBJECT_ID('bronze.crm_prd_info' , 'U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info

CREATE TABLE bronze.crm_prd_info(
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATETIME,
	prd_end_dt DATETIME
);


IF OBJECT_ID('bronze.crm_sales_details' , 'U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details

CREATE TABLE bronze.crm_sales_details(
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT
);


-- ERP TABLES

IF OBJECT_ID('bronze.erp_loc_a101' , 'U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a101

CREATE TABLE bronze.erp_loc_a101(
	CID NVARCHAR(50),
	CNTRY NVARCHAR(50)
);

IF OBJECT_ID('bronze.erp_cust_az12' , 'U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12

CREATE TABLE bronze.erp_cust_az12(
	CID NVARCHAR(50),
	BDATE DATE,
	GEN NVARCHAR(50)
);

IF OBJECT_ID('bronze.erp_px_cat_g1v2' , 'U') IS NOT NULL
	DROP TABLE bronze.erp_px_cat_g1v2

CREATE TABLE bronze.erp_px_cat_g1v2(
	ID NVARCHAR(50),
	CAT NVARCHAR(50),
	SUBCAT NVARCHAR(50),
	MAINTENANCE NVARCHAR(50)
);
