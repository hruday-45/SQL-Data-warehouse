/********************************************************************************
Report: Percentage of repeat buying customers
Source Views: gold.fact_sales, gold.dim_customers
Created: 2026-01-03
***********************************************************************************/

WITH OrderCounts AS (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT f.order_key) AS order_count
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
    GROUP BY c.customer_unique_id
)
SELECT 
    COUNT(*) AS total_unique_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_buyers,
    (CAST(SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 AS retention_rate_percentage
FROM OrderCounts;
