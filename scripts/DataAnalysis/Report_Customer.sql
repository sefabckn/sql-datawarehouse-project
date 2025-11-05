/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age	 groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

CREATE VIEW gold.report_customers AS
WITH cte_base_details AS (
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/
SELECT 
       s.order_number,
	   s.product_key,
	   s.order_date,
	   s.sales_amount,
	   s.quantity,
	   c.customer_key,
	   c.customer_number,
	   CONCAT(c.first_name,' ', c.last_name) as customer_name,
	   DATEDIFF(YEAR, c.birthdate, GETDATE()) as customer_age
FROM gold.fact_sales as s
LEFT JOIN gold.dim_customers as c
      ON  s.customer_key = c.customer_key
WHERE order_date is not null
), cte_customer_aggregation as (
/*---------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------------*/
SELECT customer_key,
	   customer_number,
	   customer_name,
	   customer_age,
	   COUNT(DISTINCT order_number) as total_order_num,
	   SUM(sales_amount) as total_sales,
	   SUM(quantity) as total_quantity,
	   COUNT(DISTINCT product_key) as total_product,
	   MAX(order_date) as last_order,
	   DATEDIFF(month, MIN(order_date), MAX(order_date)) as lifespan
FROM cte_base_details
GROUP BY customer_key,
	     customer_number,
	     customer_name,
	     customer_age
)
SELECT   customer_key,
	     customer_number,
	     customer_name,
	     customer_age,
		 CASE WHEN  customer_age < 20 THEN 'Under 20'
		      WHEN  customer_age BETWEEN 20 AND 29 THEN '20-29'
			  WHEN  customer_age BETWEEN 30 AND 39 THEN '30-39'
			  WHEN  customer_age BETWEEN 40 AND 49 THEN '40-49'
			  ELSE  '50 and Above'
         END AS age_segmentaion,
		 CASE WHEN  lifespan >= 12 and total_sales > 5000  THEN 'VIP'
              WHEN  lifespan >= 12 and total_sales <= 5000 THEN 'Regular'
              ELSE  'New'
         END as customer_segmentation,
		 last_order,
		 DATEDIFF(MONTH, last_order, GETDATE()) as recency_in_month,
		 total_order_num,
	     total_sales,
	     total_quantity,
	     total_product,
	     lifespan,
		 -- KPI Calculations
		 -- Average order value:
		 CASE WHEN total_sales = 0 THEN 0
		      ELSE total_sales / total_order_num
		 END AS  avg_order_value,
		 -- Average Monthly Spending:
		 CASE WHEN lifespan = 0  THEN total_sales
		      ELSE total_sales / lifespan
		 END AS avg_monthly_spending
FROM cte_customer_aggregation

