/********************************************************************************
Report: Top 10% customers by lifetime value (LTV)
Source Views: gold.fact_sales, gold.dim_customers
Created: 2026-01-03
***********************************************************************************/

WITH RankedCustomers AS (
    SELECT 
        c.customer_unique_id,
        SUM(f.total_product_value) AS total_spend,
        ROW_NUMBER() OVER (ORDER BY SUM(f.total_product_value) DESC) as row_num,
        COUNT(*) OVER () as total_count
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
    GROUP BY c.customer_unique_id
)
SELECT * FROM RankedCustomers 
WHERE row_num <= (total_count * 0.10);
