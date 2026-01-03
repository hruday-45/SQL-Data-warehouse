/********************************************************************************
Report: Product categories that contributed the highest revenue and profit.
Source Views: gold.fact_sales, gold.fact_products
Created: 2026-01-03
***********************************************************************************/

SELECT 
    p.product_category_name,
    COUNT(DISTINCT f.order_key) AS total_orders,
    SUM(f.total_product_value) AS total_revenue,
    SUM(f.total_product_value) / COUNT(DISTINCT f.order_key) AS avg_order_value
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.product_category_name
ORDER BY total_revenue DESC;
