/********************************************************************************
Report: Total Revenue & Monthly Revenue Trend
Source Tables: gold.fact_sales, gold.dim_date
Created: 2026-01-03
***********************************************************************************/

-- Total Revenue (Grand Total)
SELECT 
    SUM(total_product_value) AS grand_total_revenue,
    COUNT(DISTINCT order_key) AS total_orders,
    SUM(total_product_value) / COUNT(DISTINCT order_key) AS average_order_value
FROM gold.fact_sales;

-- Monthly Revenue Trend
SELECT 
    d.year,
    d.month,
    d.month_name,
    SUM(f.total_product_value) AS monthly_revenue,
    COUNT(DISTINCT f.order_key) AS monthly_order_count
FROM gold.fact_sales f
LEFT JOIN gold.dim_date d ON f.order_purchase_timestamp = d.date
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year DESC, d.month DESC;
