-- Check for duplicates and Nulls
-- Expectation : No result

SELECT prd_id, count(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
Having count(*) > 1 OR prd_id IS NULL;


SELECT top 10 * 
FROM bronze.crm_prd_info;

-- Check for unwanted spaces
-- Expectation: No result

SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

-- Check for nulls and negative numbers
-- expectation no results

SELECT prd_cost
FROM bronze.crm_prd_info
where prd_cost is null or prd_cost < 0

SELECT DISTINCT prd_line
from bronze.crm_prd_info


-- Check for invalid Date order
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

--Data Standardization & consistency
SELECT  DISTINCT cst_gndr
FROM bronze.crm_cust_info

SELECT DISTINCT cst_marital_status
from bronze.crm_cust_info


--- Checking the quality issuses of Silver Table cust_info
-- Check for duplicates and Nulls
-- Expectation : No result

SELECT cst_id, count(*)
FROM silver.crm_cust_info
GROUP BY cst_id
Having count(*) > 1 OR cst_id IS NULL;


-- Check for unwanted spaces
-- Expectation: No result

SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

--Data Standardization & consistency
SELECT  DISTINCT cst_gndr
FROM silver.crm_cust_info

SELECT DISTINCT cst_marital_status
from silver.crm_cust_info

-----------------------------------------------------------------------
-- Check for duplicates and Nulls
-- Expectation : No result

SELECT prd_id, count(*)
FROM silver.crm_prd_info
GROUP BY prd_id
Having count(*) > 1 OR prd_id IS NULL;



-- Check for unwanted spaces
-- Expectation: No result

SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

-- Check for nulls and negative numbers
-- expectation no results

SELECT prd_cost
FROM silver.crm_prd_info
where prd_cost is null or prd_cost < 0

SELECT DISTINCT prd_line
from silver.crm_prd_info


-- Check for invalid Date order
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

--Data Standardization & consistency
SELECT  DISTINCT cst_gndr
FROM silver.crm_cust_info

SELECT DISTINCT cst_marital_status
from silver.crm_cust_info


--- Checking the quality issuses of Silver Table cust_info
-- Check for duplicates and Nulls
-- Expectation : No result

SELECT cst_id, count(*)
FROM silver.crm_cust_info
GROUP BY cst_id
Having count(*) > 1 OR cst_id IS NULL;


-- Check for unwanted spaces
-- Expectation: No result

SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

--Data Standardization & consistency
SELECT  DISTINCT cst_gndr
FROM silver.crm_cust_info

SELECT DISTINCT cst_marital_status
from silver.crm_cust_info


SELECT sls_ord_num
      ,sls_prd_key
      ,sls_cust_id
      ,sls_order_dt
      ,sls_ship_dt
      ,sls_due_dt
      ,sls_sales
      ,sls_quantity
      ,sls_price
  FROM [DataWareHouse].[bronze].[crm_sales_details]
  WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)

-- Checking dates in sales details table for quality purposes

SELECT sls_due_dt
FROM silver.crm_sales_details
WHERE  sls_due_dt <= 0 OR 
       LEN(sls_due_dt) != 8 OR-- Its in date formatelike YYYYMMDD, covers 8 char. as lenght
       sls_due_dt > 20500101 OR
       sls_due_dt < 19000101;

SELECT sls_order_dt, sls_due_dt, sls_ship_dt
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR
      sls_order_dt > sls_due_dt


--- Checking the sales amount by calculating the sales_quantity * sales_price
SELECT DISTINCT sls_quantity, 
                sls_price ,
                 sls_sales,
               sls_price
FROM silver.crm_sales_details


SELECT * FROM silver.crm_sales_details



-- Checking the bdate boundries for silver_erp_cust-az12 table
SELECT DISTINCT BDATE
FROM silver.erp_cust_az12
WHERE BDATE < '1925-01-01' or BDATE > GETDATE()

SELECT DISTINCT GEN,
CASE WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
            ELSE 'n/a'
        END GEN2
FROM silver.erp_cust_az12


SELECT TOP 10 cst_key
FROM silver.crm_cust_info --  AW-00011000 CID 
                          --  AW00011000 cst_key

SELECT CID, CNTRY
FROM silver.erp_loc_a101

SELECT
     CID,
    CNTRY
FROM silver.erp_loc_a101
WHERE CNTRY = 'Germany'

-- DATA STD
SELECT DISTINCT CNTRY
FROM (SELECT
    CASE WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
         WHEN TRIM(CNTRY) IN ('US', 'USA') THEN 'United States'
         WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'n/a'
         ELSE TRIM(CNTRY) 
    END AS CNTRY
FROM bronze.erp_loc_a101) as t



------------------
SELECT 
    ID,
    CAT,
    SUBCAT,
    MAINTENANCE
FROM bronze.erp_px_cat_g1v2

-- Checking empty spaces 
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE CAT != TRIM(CAT) OR SUBCAT !=  TRIM(Subcat)


SELECT DISTINCT SUBCAT
FROM bronze.erp_px_cat_g1v2
