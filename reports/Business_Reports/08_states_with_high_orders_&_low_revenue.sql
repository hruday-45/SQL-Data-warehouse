/********************************************************************************
Report: States with high order volume but low revenue
Source Views: gold.fact_sales, gold.dim_date
Created: 2026-01-03
***********************************************************************************/

SELECT 
    c.customer_state,
    COUNT(DISTINCT f.order_key) AS total_orders,
    SUM(f.total_product_value) AS total_revenue,
    SUM(f.total_product_value) / COUNT(DISTINCT f.order_key) AS state_aov
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_state
-- for states with > 2000 orders but AOV < 170
HAVING COUNT(DISTINCT f.order_key) > 2000 
   AND (SUM(f.total_product_value) / COUNT(DISTINCT f.order_key)) < 170
ORDER BY total_orders DESC;
