/********************************************************************************
Report: 6-month and 12-month customer retention rate
Source Views: gold.dim_orders, gold.dim_customers
Created: 2026-01-03
***********************************************************************************/

-- Removing the bridge table if it already exists from a previous run to avoid errors.
DROP TABLE IF EXISTS gold.bridge_customer_orders;

-- Creating a temporary Bridge Table
SELECT
    dc.customer_unique_id,
    do.order_key,
    -- Converts date to an integer: May 2018 becomes 201805
    (YEAR(do.order_purchase_timestamp) * 100 
     + MONTH(do.order_purchase_timestamp)) AS order_year_month
INTO gold.bridge_customer_orders
FROM gold.dim_orders do
JOIN gold.dim_customers dc
    ON do.customer_id = dc.customer_id;

-- Optimizing with a Clustered Index
CREATE CLUSTERED INDEX CX_bridge_customer_orders
ON gold.bridge_customer_orders (customer_unique_id, order_year_month);

--  Calculate Retention using Common Table Expressions (CTEs)
WITH FirstPurchase AS (
    -- Finds the 'Cohort Month' (the very first time we ever saw this customer)
    SELECT
        customer_unique_id,
        MIN(order_year_month) AS first_year_month
    FROM gold.bridge_customer_orders
    GROUP BY customer_unique_id
),
RetentionFlags AS (
    -- Flags if a customer returned within specific windows
    SELECT
        b.customer_unique_id,

        -- 6-Month Flag: Did they return between 1 and 6 months after the first?
        MAX(CASE WHEN b.order_year_month - fp.first_year_month BETWEEN 1 AND 6
            THEN 1 ELSE 0 END) AS retained_6_months,

        -- 12-Month Flag: Did they return between 1 and 12 months after the first?
        MAX(CASE WHEN b.order_year_month - fp.first_year_month BETWEEN 1 AND 12
                THEN 1 ELSE 0 END) AS retained_12_months
    FROM gold.bridge_customer_orders b
    JOIN FirstPurchase fp
        ON b.customer_unique_id = fp.customer_unique_id
    GROUP BY b.customer_unique_id
)
-- Final Aggregation
SELECT
    COUNT(*) AS total_customers,
    SUM(retained_6_months) AS customers_retained_6_months,
    CAST(100.0 * SUM(retained_6_months) / COUNT(*) AS DECIMAL(5,2))
        AS retention_rate_6_months_percent,
    SUM(retained_12_months) AS customers_retained_12_months,
    CAST(100.0 * SUM(retained_12_months) / COUNT(*) AS DECIMAL(5,2))
        AS retention_rate_12_months_percent
FROM RetentionFlags;

-- Clean up the temporary bridge table
DROP TABLE gold.bridge_customer_orders;
