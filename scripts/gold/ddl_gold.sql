/**********************************************************************************************
 Script:        gold_layer_views.sql
 Author:        Sefa Bockun ( Tutor : Baraa Salkini - Youtube Tutorial ) 
 Date:          [Date or Version]
 Database:      SQL Server
 Project:       Data Engineering Portfolio – Data Warehouse (Medallion Architecture)

 Description:
 -----------------------------------------------------------------------------------------------
 This script creates the **Gold Layer** views for the data warehouse following the 
 **Medallion Architecture** pattern (Bronze → Silver → Gold).

 The Gold Layer represents the **business-ready presentation layer**, containing:
   - Cleaned and conformed dimension views (`dim_customers`, `dim_products`)
   - A fact view (`fact_sales`) that joins relevant dimensions to support analytics

 Data Model: **Star Schema**
   - Dimensions: Contain descriptive attributes about entities (customers, products)
   - Fact Table: Contains transactional sales data linked to the dimensions by surrogate keys

 Purpose:
 -----------------------------------------------------------------------------------------------
   1. Standardize and enrich data for business reporting and BI dashboards.
   2. Simplify complex joins across multiple Silver tables into reusable analytical views.
   3. Enable easy querying of sales data by product, customer, time, and region.

 Tables Created:
 -----------------------------------------------------------------------------------------------
   - gold.dim_customers  → Customer dimension view (from CRM and ERP sources)
   - gold.dim_products   → Product dimension view (from CRM and ERP sources)
   - gold.fact_sales     → Sales fact view (from CRM sales details enriched with dimensions)

 Notes:
 -----------------------------------------------------------------------------------------------
   - Uses LEFT JOINs to preserve all fact records even when dimension data is missing.
   - Employs surrogate keys using ROW_NUMBER() for dimension tables.
   - Filters out inactive or historical product data in `dim_products` (prd_end_dt IS NULL).
   - Designed to be refreshed periodically as new data lands in Silver layer tables.

**********************************************************************************************/


-- Dimension
CREATE VIEW gold.dim_customers AS 
SELECT 
       ROW_NUMBER() OVER(ORDER BY ci.cst_id) as customer_key,
       ci.cst_id as customer_id,
       ci.cst_key as customer_number,
       ci.cst_firstname as first_name,
       ci.cst_lastname as last_name,
       la.CNTRY as country,
       ci.cst_marital_status as marital_status,
       CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
            ELSE COALESCE(ca.GEN, 'n/a')
        END as gender,
       ca.BDATE as birthdate,  
       ci.cst_create_date as create_date
        
FROM silver.crm_cust_info as ci
LEFT JOIN silver.erp_cust_az12 as ca
ON        ci.cst_key = ca.CID

LEFT JOIN silver.erp_loc_a101 as la
ON        ci.cst_key = la.CID;

GO

-- Dimension
CREATE VIEW gold.dim_products AS 
SELECT
     ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt, pn.prd_key) as product_key,
     pn.prd_id AS product_id,
     pn.prd_key AS product_number,
     pn.prd_nm as product_name,
     pn.cat_id AS category_id,
     pc.CAT AS category,
     pc.SUBCAT as sub_category,
     pc.MAINTENANCE,
     pn.prd_cost as cost,
     pn.prd_line as product_line,
     pn.prd_start_dt as start_date
FROM silver.crm_prd_info as pn
LEFT JOIN silver.erp_px_cat_g1v2 as pc
ON        pn.cat_id = pc.ID
WHERE pn.prd_end_dt is NULL --filter out all the historical data

GO

CREATE VIEW gold.fact_sales AS
SELECT
     sd.sls_ord_num as order_number,
     dim_p.product_key,
     dim_c.customer_key,
     sd.sls_order_dt as order_date,
     sd.sls_ship_dt as shipping_date,
     sd.sls_due_dt as due_date,
     sd.sls_sales as sales_amount,
     sd.sls_quantity as quantity,
     sd.sls_price as price
FROM silver.crm_sales_details as sd
LEFT JOIN gold.dim_products as dim_p
     ON sd.sls_prd_key = dim_p.product_number
LEFT JOIN gold.dim_customers as dim_c
     ON sd.sls_cust_id = dim_c.customer_id
