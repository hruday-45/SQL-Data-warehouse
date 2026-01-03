/********************************************************************************
Report: AOV by customer state
Source Views: gold.fact_sales, gold.dim_date
Created: 2026-01-03
***********************************************************************************/

SELECT 
    c.customer_state,
    COUNT(DISTINCT f.order_key) AS total_orders,
    SUM(f.total_product_value) AS total_revenue,
    SUM(f.total_product_value) / COUNT(DISTINCT f.order_key) AS average_order_value
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_state
ORDER BY average_order_value DESC;
