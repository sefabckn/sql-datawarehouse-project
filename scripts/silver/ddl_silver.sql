/**********************************************************************************************
 Script:        create_silver_tables.sql
 Author:        Sefa Bockun ( Tutor Baraa Salkini - Youtube Tutorial)
 Date:          v1.0.0
 Database:      SQL Server
 Project:       Data Engineering Portfolio – Data Warehouse (Medallion Architecture)

 Description:
 -----------------------------------------------------------------------------------------------
 This script creates all **Silver Layer tables** used in the Data Warehouse as part of the 
 **Medallion Architecture** (Bronze → Silver → Gold).

 The Silver Layer represents the **curated and cleaned data zone**, where raw Bronze data is 
 standardized, typed, and structured for analytical processing and loading into the Gold Layer.

 Purpose:
 -----------------------------------------------------------------------------------------------
   1. Define the data structures for cleaned and conformed Silver tables.
   2. Separate CRM and ERP data domains to maintain logical organization.
   3. Add metadata tracking columns (e.g., `dwh_create_date`) for ETL auditing and lineage.

 Layer Overview:
 -----------------------------------------------------------------------------------------------
   - **CRM Tables**
       • `silver.crm_cust_info` – Customer master information (ID, name, marital status, gender).
       • `silver.crm_prd_info` – Product master data (category, cost, product line, start/end dates).
       • `silver.crm_sales_details` – Transactional sales data (orders, products, prices, quantities).

   - **ERP Tables**
       • `silver.erp_loc_a101` – Customer location and country data.
       • `silver.erp_cust_az12` – Additional ERP customer attributes (birthdate, gender).
       • `silver.erp_px_cat_g1v2` – Product category and maintenance hierarchy.

 Notes:
 -----------------------------------------------------------------------------------------------
   - Each table includes a `dwh_create_date` metadata column populated automatically with `GETDATE()`.
   - Existing tables are **dropped and recreated** to ensure schema consistency.
   - Data is later populated via the `silver.load_silver` stored procedure.

 Execution:
 -----------------------------------------------------------------------------------------------
   Run this script once during initial environment setup or when table structure updates are required.
   Example:
       ```sql
       :r .\create_silver_tables.sql
       ```

**********************************************************************************************/


-- CRM TABLES

IF OBJECT_ID('silver.crm_cust_info' , 'U') IS NOT NULL
	DROP TABLE silver.crm_cust_info

CREATE TABLE silver.crm_cust_info (
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE() -- Metadata column 
);

IF OBJECT_ID('silver.crm_prd_info' , 'U') IS NOT NULL
	DROP TABLE silver.crm_prd_info

CREATE TABLE silver.crm_prd_info(
	prd_id INT,
	cat_id NVARCHAR(50),
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE() -- Metadata column 
);


IF OBJECT_ID('silver.crm_sales_details' , 'U') IS NOT NULL
	DROP TABLE silver.crm_sales_details

CREATE TABLE silver.crm_sales_details(
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt DATE,
	sls_ship_dt DATE,
	sls_due_dt DATE,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE() -- Metadata column 
);


-- ERP TABLES

IF OBJECT_ID('silver.erp_loc_a101' , 'U') IS NOT NULL
	DROP TABLE silver.erp_loc_a101

CREATE TABLE silver.erp_loc_a101(
	CID NVARCHAR(50),
	CNTRY NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE() -- Metadata column 
);

IF OBJECT_ID('silver.erp_cust_az12' , 'U') IS NOT NULL
	DROP TABLE silver.erp_cust_az12

CREATE TABLE silver.erp_cust_az12(
	CID NVARCHAR(50),
	BDATE DATE,
	GEN NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE() -- Metadata column 
);

IF OBJECT_ID('silver.erp_px_cat_g1v2' , 'U') IS NOT NULL
	DROP TABLE silver.erp_px_cat_g1v2

CREATE TABLE silver.erp_px_cat_g1v2(
	ID NVARCHAR(50),
	CAT NVARCHAR(50),
	SUBCAT NVARCHAR(50),
	MAINTENANCE NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE() -- Metadata column 
);
