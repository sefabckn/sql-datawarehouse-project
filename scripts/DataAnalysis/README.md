# 🧠 Data Warehouse Project — Exploratory Data Analysis (EDA)

## 📘 Description

This SQL script performs **Exploratory Data Analysis (EDA)** on the **Gold Layer** of the Data Warehouse built using **SQL Server** and **Medallion Architecture** (Bronze → Silver → Gold).  

The purpose is to:
- Validate data integrity and consistency.
- Explore schema metadata (tables, columns).
- Generate high-level business insights.
- Analyze sales, products, customers, and geography dimensions.

---

## 🗺️ Integration Model

The diagram below illustrates the **data integration flow** across the three layers (Bronze → Silver → Gold):

![Integration Model](docs/integration_model.drawio.png)

---

# 🔍 Exploratory Data Analysis — SQL Script

## 🧾 1. SCHEMA EXPLORATION
```sql

-- Check how many tables we have and their types
SELECT * FROM INFORMATION_SCHEMA.TABLES;

-- Explore columns of a specific table
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_products';

```
## 🌍 2. GEOGRAPHIC EXPLORATION

```sql
-- Explore all countries where customers are from
SELECT DISTINCT country
FROM gold.dim_customers;

```
## 🏷️ 3. DIMENSION EXPLORATION
  ```sql
-- Explore product categories, subcategories, and names
SELECT DISTINCT category, sub_category, product_name
FROM gold.dim_products;

```
##  ⏳ 4. DATE EXPLORATION
```sql

-- Find earliest and latest order dates
SELECT MIN(order_date) AS first_order_date,  -- First order date
       MAX(order_date) AS last_order_date,   -- Last order date  
       DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS ord_range_years
FROM gold.fact_sales;

-- Find oldest and youngest customers
SELECT MIN(birthdate) AS oldest_cust,
       MAX(birthdate) AS youngest_cust
FROM gold.dim_customers;

```
## 💰 5. BUSINESS METRICS
```sql

-- Total Sales
SELECT SUM(sales_amount) AS total_sales 
FROM gold.fact_sales;

-- Total Quantity Sold
SELECT SUM(quantity) AS total_sales_quantity
FROM gold.fact_sales;

-- Average Selling Price
SELECT AVG(price) AS avg_sales_price
FROM gold.fact_sales;

-- Total Orders
SELECT COUNT(DISTINCT order_number) AS num_of_orders 
FROM gold.fact_sales;

-- Total Products
SELECT COUNT(product_key) AS num_of_products 
FROM gold.dim_products;

-- Total Customers
SELECT COUNT(DISTINCT customer_id) AS num_of_customers 
FROM gold.dim_customers;

-- Customers Who Placed Orders
SELECT COUNT(DISTINCT customer_key) AS num_of_customers
FROM gold.fact_sales;
```

##    📊 6. BUSINESS PERFORMANCE DASHBOARD (KEY METRICS)
```sql

SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' AS measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Average Price' AS measure_name, AVG(price) AS avg_sales_price FROM gold.fact_sales
UNION ALL 
SELECT 'Total nr. orders' AS measure_name, COUNT(DISTINCT order_number) AS num_of_orders FROM gold.fact_sales
UNION ALL
SELECT 'Total nr. products' AS measure_name, COUNT(product_key) AS num_of_products FROM gold.dim_products
UNION ALL
SELECT 'Total nr. customers' AS measure_name, COUNT(DISTINCT customer_id) AS num_of_customers FROM gold.dim_customers;

```
## 🌎 7. MAGNITUDE ANALYSIS
```sql
-- Customers by Country
SELECT country,
       COUNT(customer_key) AS num_of_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY num_of_customers DESC;

-- Customers by Gender
SELECT gender,
       COUNT(customer_key) AS num_of_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY num_of_customers DESC;

-- Products by Category
SELECT category,
       COUNT(product_key) AS num_of_prod
FROM gold.dim_products
GROUP BY category
ORDER BY num_of_prod DESC;

-- Average Cost per Category
SELECT category,
       AVG(cost) AS avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC;

-- Total Revenue per Category
SELECT pr.category,
       SUM(sales_amount) AS total_rev 
FROM gold.fact_sales AS sl
LEFT JOIN gold.dim_products AS pr
       ON pr.product_key = sl.product_key
GROUP BY pr.category
ORDER BY total_rev DESC;

```
## 👥 8. CUSTOMER REVENUE ANALYSIS
```sql
-- Total Revenue by Customer
SELECT cs.customer_key,
       cs.first_name,
       cs.last_name,
       SUM(sl.sales_amount) AS total_sales
FROM gold.fact_sales AS sl
LEFT JOIN gold.dim_customers AS cs
       ON cs.customer_key = sl.customer_key
GROUP BY cs.customer_key,
         cs.first_name,
         cs.last_name
ORDER BY total_sales DESC;

-- Total Revenue by Country
SELECT cs.country,
       SUM(sl.sales_amount) AS total_sales
FROM gold.fact_sales AS sl
LEFT JOIN gold.dim_customers AS cs
       ON cs.customer_key = sl.customer_key
GROUP BY cs.country
ORDER BY total_sales DESC;
```
## 📦 9. SALES DISTRIBUTION
```sql
-- Distribution of Sold Items Across Countries
SELECT cs.country,
       SUM(sl.quantity) AS sold_items_quantity
FROM gold.fact_sales AS sl
LEFT JOIN gold.dim_customers AS cs
       ON cs.customer_key = sl.customer_key
GROUP BY cs.country
ORDER BY sold_items_quantity DESC;
```

## 🏆 10. PRODUCT REVENUE RANKING
```sql
-- Top 5 Highest Revenue Products
SELECT TOP 5 
       pr.sub_category,
       SUM(sales_amount) AS total_rev   
FROM gold.fact_sales AS sl
LEFT JOIN gold.dim_products AS pr
       ON pr.product_key = sl.product_key
GROUP BY pr.sub_category
ORDER BY total_rev DESC;

-- 5 Lowest Revenue Products
SELECT TOP 5 
       pr.product_name,
       SUM(sales_amount) AS total_rev   
FROM gold.fact_sales AS sl
LEFT JOIN gold.dim_products AS pr
       ON pr.product_key = sl.product_key
GROUP BY pr.product_name
ORDER BY total_rev ASC;

```
## 🪜 11. PRODUCT RANKING (WINDOW FUNCTION)
```sql
SELECT 
    product_name,
    total_rev
FROM (
    SELECT 
           pr.product_name,
           SUM(sales_amount) AS total_rev,
           ROW_NUMBER() OVER (ORDER BY SUM(sales_amount) DESC) AS rank_products
    FROM gold.fact_sales AS sl
    LEFT JOIN gold.dim_products AS pr
           ON pr.product_key = sl.product_key
    GROUP BY pr.product_name
) t
WHERE rank_products <= 5;
```

## 💎 12. CUSTOMER RANKING (TOP CUSTOMERS)
```sql
-- Top 10 Customers by Revenue
SELECT TOP 10 
       cs.first_name,
       cs.last_name,
       SUM(sl.sales_amount) AS total_sales
FROM gold.fact_sales AS sl
LEFT JOIN gold.dim_customers AS cs
       ON cs.customer_key = sl.customer_key
GROUP BY cs.first_name,
         cs.last_name
ORDER BY total_sales DESC;

-- Top 5 Customers using Window Function
SELECT
    first_name,
    total_sales,
    order_sales
FROM (
    SELECT  
           cs.first_name,
           cs.last_name,
           SUM(sl.sales_amount) AS total_sales,
           ROW_NUMBER() OVER(ORDER BY SUM(sl.sales_amount) DESC) AS order_sales
    FROM gold.fact_sales AS sl
    LEFT JOIN gold.dim_customers AS cs
           ON cs.customer_key = sl.customer_key
    GROUP BY cs.first_name,
             cs.last_name
) t
WHERE order_sales <= 5;
```
