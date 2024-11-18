SELECT top 100 *
FROM df_orders

-- Find top 10 highest revenue generating products
SELECT TOP 10 product_id, SUM(profit) as profits
FROM df_orders
GROUP BY  product_id
ORDER BY profits DESC

-- Find top 5 highest selling products in each region
WITH CTE AS (
    SELECT region, product_id, SUM(sale_price) as sales
    FROM df_orders
    GROUP BY region, product_id 
)
SELECT * FROM (
SELECT 
	*,
	ROW_NUMBER() OVER (partition by region order by sales desc) as rn
FROM CTE) A
WHERE rn <= 5

-- Find month over month growth comparison for 2022 and 2023 sales ; Jan 2022 vs Jan 2023
WITH CTE AS(
SELECT 
	MONTH([order_date]) as month_order,
	YEAR([order_date]) as year_order,
	SUM(sale_price) as sales
FROM df_orders
GROUP BY MONTH([order_date]), YEAR([order_date]))

SELECT month_order,
	sum(CASE WHEN  year_order = 2022 then sales else 0 end) as sales_2022,
	sum(CASE WHEN year_order = 2023 then sales else 0 end) as sales_2023
FROM CTE
GROUP by month_order
ORDER BY month_order

-- For each category which month had highest sales

WITH CTE AS (
SELECT 
	category, 
	MONTH(order_date) as month_report,
	sum(sale_price) as sales
FROM [dbo].[df_orders] 
GROUP BY category, MONTH(order_date))
SELECT * FROM (
SELECT * ,
	ROW_NUMBER () OVER (PARTITION BY category ORDER BY sales DESC) as rn
	FROM CTE ) a
WHERE rn = 1

-- Which sub category had highest growh by profit in 2023 compared to 2022

WITH CTE AS(
SELECT 
	sub_category,
	YEAR([order_date]) as year_order,
	SUM(profit) as profits
FROM df_orders
GROUP BY sub_category, YEAR([order_date]))
, cte2 as (
SELECT sub_category,
	sum(CASE WHEN  year_order = 2022 then profits else 0 end) as profit_2022,
	sum(CASE WHEN year_order = 2023 then profits else 0 end) as profit_2023
FROM CTE
GROUP by sub_category)
SELECT *
, (profit_2023-profit_2022)*100/profit_2022 as growth_rate
FROM cte2
ORDER BY growth_rate DESC