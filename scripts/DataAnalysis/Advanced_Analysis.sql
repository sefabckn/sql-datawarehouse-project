/*===============================================================
🧾 PURPOSE OF THIS SQL SCRIPT
---------------------------------------------------------------
This SQL script performs a comprehensive sales and customer analysis
covering multiple business perspectives — from time-based performance
to segmentation and proportional contribution.

---------------------------------------------------------------
| SECTION NAME              | PURPOSE / INSIGHT                                    |
|----------------------------|------------------------------------------------------|
| Changes Over Time          | Analyze monthly and yearly sales trends.             |
| Cumulative Analysis        | Compute running totals and moving averages.          |
| Performance Analysis       | Compare product performance vs average & last year.  |
| Part-to-Whole Analysis     | Identify category contributions to total sales.      |
| Product Segmentation       | Group products into cost-based price ranges.         |
| Customer Segmentation      | Classify customers into VIP, Regular, or New tiers.  |
---------------------------------------------------------------

🗂  Data Sources:
   - gold.fact_sales      → Transactional sales data
   - gold.dim_products    → Product master data
   - gold.dim_customers   → Customer master data

📅 Output:
   - Trends over time
   - Product & category performance
   - Customer lifetime value segmentation

===============================================================*/

-- Analyze Sales Performance Over Time
SELECT YEAR(order_date) as year_of_sale,
       MONTH(order_date) as month_of_sale,
       SUM(sales_amount) as total_sales,
       COUNT(distinct customer_key) as num_of_customers,
       SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date),MONTH(order_date)
ORDER BY YEAR(order_date),MONTH(order_date)


-- Cumulative Analysis

-- Calculate the Total Sales for each month and the 
-- running total of sales over time
SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER(PARTITION BY order_date ORDER BY order_date) as running_total_sale,
    avg_price,
    AVG(avg_price) OVER(PARTITION BY order_date ORDER BY order_date) as moving_avg_price
FROM
    (SELECT
         DATETRUNC(MONTH, order_date) as order_date,
         SUM(sales_amount) as total_sales,
         AVG(price) as avg_price
    FROM gold.fact_sales 
    WHERE order_date is not null
    GROUP BY DATETRUNC(MONTH, order_date)
    )t

 -- Performance Analysis

 /*
     Analyze the yearly performance of products by comparing their sales to both
      the average sales performance of the product and the previous year's  sales
 */
WITH yearly_product_sales AS(
SELECT
    YEAR(sl.order_date) as order_year,
    pd.product_name,
    SUM(sl.sales_amount) as current_sales_amount
FROM gold.fact_sales as sl
LEFT JOIN gold.dim_products as pd
       ON sl.product_key = pd.product_key
WHERE sl.order_date is not null
GROUP BY YEAR(sl.order_date), product_name
)

SELECT 
    order_year,
    product_name,
    current_sales_amount,
    AVG(current_sales_amount) OVER(PARTITION BY product_name) as avg_sales,
    current_sales_amount - AVG(current_sales_amount) OVER(PARTITION BY product_name) as diff_,
    CASE 
        WHEN current_sales_amount - AVG(current_sales_amount) OVER(PARTITION BY product_name) > 0 THEN 'Above the Average'
        WHEN current_sales_amount - AVG(current_sales_amount) OVER(PARTITION BY product_name) < 0 THEN 'Below The Average'
        ELSE 'Average'
    END AS avg_change,
    --- Year over Year Analysis
    LAG(current_sales_amount) OVER(PARTITION BY product_name ORDER BY order_year) as prev_year_sales,
    current_sales_amount -  LAG(current_sales_amount) OVER(PARTITION BY product_name ORDER BY order_year) diff_prev_year,
    CASE 
        WHEN current_sales_amount - current_sales_amount -  LAG(current_sales_amount) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increasing'
        WHEN current_sales_amount - current_sales_amount -  LAG(current_sales_amount) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decreasing'
        ELSE 'No change'
    END AS prev_year_change
FROM yearly_product_sales
ORDER BY product_name, order_year


-- Part to Whole Analysis
-- AKA proportional Analysis


-- Which categories contribute the most to overall sales
WITH category_sales AS(
SELECT pr.category as category,
       SUM(sl.sales_amount) as total_sales
FROM gold.fact_sales as sl
LEFT JOIN gold.dim_products as pr
       ON sl.product_key = pr.product_key
GROUP BY  category
)

SELECT category,
       total_sales,
       SUM(total_sales) OVER() as overall_sales,
       CONCAT(ROUND(CAST(total_sales as FLOAT) / SUM(total_sales) OVER() * 100, 2), '%') as perc_of_total
FROM category_sales
ORDER BY perc_of_total DESC



-- DATA SEGMENTATION


-- Segment products into cost ranges and count
-- how many products fall into each segment

WITH product_segments as (
SELECT
     product_key,
     product_name,
     cost,
     CASE WHEN cost < 100 THEN 'Below 100'
          WHEN cost BETWEEN 100 AND 500 THEN '100-500'
          WHEN cost BETWEEN 501 AND 1000 THEN '501-1000'
          ELSE 'Above 1000'
     END as cost_range
FROM gold.dim_products
)

SELECT
    cost_range,
    COUNT(product_key) as total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC

/*
    GROUP CUSTOMERS into 3 segments based on their spendings:
    
    - VIP: Customer with at least 12 month of history and spending more than 5000
    - Regular: Customer with at least 12 month of history but spending  5000 or less.
    - New: Customer with less than 12 month of history
*/

-- I need sales and customer tables

WITH group_segment as (
    SELECT
        cs.customer_key as cust_key,
        SUM(sl.sales_amount) as total_spending,
        MIN(sl.order_date) as first_order,
        MAX(sl.order_date) as last_order,
        DATEDIFF(MONTH,  MIN(sl.order_date), MAX(sl.order_date)) as lifespan
    FROM gold.fact_sales as sl
    LEFT JOIN gold.dim_customers as cs
           ON cs.customer_key = sl.customer_key
    --WHERE sl.order_date is not null
    GROUP BY cs.customer_key
    )
    
SELECT customer_segmentation,
       COUNT(cust_key) as num_of_customers
FROM (
    SELECT cust_key,
           CASE WHEN  lifespan >= 12 and total_spending > 5000  THEN 'VIP'
                WHEN  lifespan >= 12 and total_spending <= 5000 THEN 'Regular'
                ELSE 'New'
           END as customer_segmentation
    FROM group_segment
) as t 
GROUP BY customer_segmentation
ORDER BY num_of_customers





