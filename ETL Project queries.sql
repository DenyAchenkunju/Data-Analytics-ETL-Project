
---find top 10 highest revenue generating products

SELECT TOP 10 product_id,SUM(sale_price) as totalPrice
FROM df_orders
GROUP BY product_id
ORDER BY totalPrice DESC;

---find top 5 highest selling products in each region
WITH CTE AS
(SELECT region,product_id, ROW_NUMBER() OVER (PARTITION BY region ORDER BY totalPrice DESC) as rn 
FROM 
(SELECT region,product_id,SUM(sale_price) as totalPrice
FROM df_orders
GROUP BY region,product_id) a)
SELECT region,product_id
FROM CTE
WHERE rn <= 5;


---Find month over month growth comparison for 2022 and 2023 sales eg: Jan 2022 vs Jan 2023

WITH cte as
(SELECT YEAR(order_date) as year_order,MONTH(order_date) as month_order ,SUM(sale_price) as total_sale
FROM df_orders
GROUP BY YEAR(order_date),MONTH(order_date)
)
SELECT month_order,SUM(CASE WHEN year_order = 2022 THEN total_sale ELSE 0 END) as sale_2022,
SUM(CASE WHEN year_order = 2023 THEN total_sale ELSE 0 END) as sale_2023
FROM cte
GROUP BY month_order
ORDER BY month_order;

---For each category which month had highest sales---

WITH cte as
(SELECT category,FORMAT(order_date,'yyyyMM') as year_month,SUM(sale_price) as total_price,
ROW_NUMBER() OVER(PARTITION BY category ORDER BY SUM(sale_price) DESC) as rn
FROM df_orders
GROUP BY category,FORMAT(order_date,'yyyyMM')
)
SELECT category,year_month
FROM cte 
WHERE rn =1;

----Which sub category had highest growth by profit in 2023 compare to 2022
WITH cte as
(SELECT sub_category,YEAR(order_date) as year_order,SUM(sale_price) as total_sale
FROM df_orders
GROUP BY sub_category,YEAR(order_date))
SELECT TOP 1 *,sale_2023 - sale_2022 as sale_growth
FROM(
SELECT sub_category, SUM(CASE WHEN  year_order = 2022 THEN total_sale ELSE 0 END) as sale_2022,
SUM(CASE WHEN  year_order = 2023 THEN total_sale ELSE 0 END) as sale_2023
FROM cte
GROUP BY sub_category) a   
ORDER BY sale_growth DESC;






