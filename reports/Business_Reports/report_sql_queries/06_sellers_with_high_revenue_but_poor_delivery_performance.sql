/********************************************************************************
Report: Sellers generated the high revenue but had poor delivery performance
Source Views: gold.fact_sales, gold.dim_sellers
Created: 2026-01-03
***********************************************************************************/

SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT f.order_key) AS total_orders,
    SUM(f.total_product_value) AS total_revenue,
    
    -- Delivery Performance Metrics
    AVG(CAST(f.total_delivery_days AS FLOAT)) AS avg_delivery_time,
    SUM(f.is_late_delivery_flag) AS total_late_orders,
    
    -- Calculating Late Ratio
    CAST(SUM(f.is_late_delivery_flag) AS FLOAT) / COUNT(DISTINCT f.order_key) * 100 AS late_delivery_rate_percent
FROM gold.fact_sales f
LEFT JOIN gold.dim_sellers s 
ON f.seller_key = s.seller_key
WHERE f.is_delivered_flag = 1
GROUP BY s.seller_id, 
         s.seller_city, 
         s.seller_state
HAVING SUM(f.total_product_value) > 10000      -- Focus on high-revenue sellers
AND (SUM(f.is_late_delivery_flag) / CAST(COUNT(*) AS FLOAT)) > 0.15 -- Late on more than 15% of orders
ORDER BY total_revenue DESC;
