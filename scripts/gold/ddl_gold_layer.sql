/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
================================================================================
*/

--  =================================================================
--  Create Dimension Table: gold.dim_customers
--  =================================================================

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
DROP VIEW gold.dim_customers;
GO

CREATE OR ALTER VIEW gold.dim_customers AS
WITH customer_orders AS (
    -- Aggregating order stats per customer
    SELECT 
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_order_date,
        MAX(o.order_purchase_timestamp) AS last_order_date,
        COUNT(o.order_id) AS total_orders
    FROM silver.orders_info o
    LEFT JOIN silver.customers_info c ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
),
DimensionBase AS (
    SELECT
        -- keys
        CAST(ROW_NUMBER() OVER (ORDER BY c.customer_unique_id) AS INT) AS customer_key,
        c.customer_id,
        c.customer_unique_id,

        -- Attributes
        c.customer_city,
        c.customer_state,
        c.customer_zip_code_prefix,

        -- Geolocation
        g.geolocation_lat AS latitude,
        g.geolocation_lng AS longitude,

        -- Metrics
        CAST(co.first_order_date AS DATE) AS first_order_date,
        CAST(co.last_order_date AS DATE) AS last_order_date,
        ISNULL(co.total_orders, 0) AS total_orders,

        -- Logic for Flags
        CASE WHEN co.total_orders > 1 THEN 'Yes' ELSE 'No' END AS is_repeat_customer,
        DATEDIFF(DAY, co.first_order_date, co.last_order_date) AS customer_tenure_days
    FROM silver.customers_info c
    LEFT JOIN customer_orders co ON c.customer_unique_id = co.customer_unique_id
    LEFT JOIN silver.geolocation_info g ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
)

-- Combining Real Customers with the Placeholder Row
SELECT * FROM DimensionBase

UNION ALL

SELECT 
    -1, 'UNKNOWN', 'UNKNOWN', 'unknown', 'NA', NULL, NULL, NULL, NULL, NULL, 0, 'No', 0;
GO

--  ===================================================================
--  Create Dimension Table: gold.dim_sellers
--  ===================================================================

IF OBJECT_ID('gold.dim_sellers', 'V') IS NOT NULL
DROP VIEW gold.dim_sellers;
GO

CREATE OR ALTER VIEW gold.dim_sellers AS
WITH SellerBase AS (
    -- Primary business logic for actual sellers
    SELECT 
        CAST(ROW_NUMBER() OVER(ORDER BY s.seller_id) AS INT) AS seller_key,   -- surrogate key
        s.seller_id,                                                          -- Natural business key
        s.seller_city,
        s.seller_state,
        s.seller_zip_code_prefix,
        gi.geolocation_lat AS latitude,
        gi.geolocation_lng AS longitude
    FROM silver.sellers_info s
    LEFT JOIN silver.geolocation_info gi
    ON s.seller_zip_code_prefix = gi.geolocation_zip_code_prefix
)

-- Combining Real Sellers with the Placeholder Row
SELECT * FROM SellerBase

UNION ALL

SELECT 
    -1,'UNKNOWN','unknown','NA',NULL,NULL,NULL;
GO

--  ======================================================================
--  Create Dimension Table: gold.dim_products
--  ======================================================================

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
WITH ProductBase AS(
SELECT 
    CAST(ROW_NUMBER() OVER(ORDER BY p.product_id) AS INT) AS product_key,                -- surrogate key
    p.product_id,                                                           -- Natural business key

    -- Handling names which are not present in the translation table
    ISNULL(p.product_category_name, 'outros') AS product_category_name,
    ISNULL(t.product_category_name_english, 'others') AS product_category_name_english,
    
    -- Physical Dimensions
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,
    
    -- Calculated Volume
    -- Handle NULLs using COALESCE to avoid errors in calculation
    CAST(COALESCE(p.product_length_cm, 0) * COALESCE(p.product_height_cm, 0) * COALESCE(p.product_width_cm, 0) AS DECIMAL(10,2)) AS product_volume_cm3

FROM silver.products_info p
LEFT JOIN silver.product_category_name_translation t 
    ON TRIM(p.product_category_name) = TRIM(t.product_category_name)
)
    
    SELECT * FROM ProductBase
    UNION ALL
    SELECT 
        -1, 'UNKNOWN', 'unknown', 'unknown', 0, 0, 0, 0, 0;
GO

--  =====================================================================
--  Create Dimension Table: gold.dim_orders
--  =====================================================================

IF OBJECT_ID('gold.dim_orders', 'V') IS NOT NULL
DROP VIEW gold.dim_orders;
GO

CREATE VIEW gold.dim_orders AS
WITH OrdersBase AS(
SELECT 
    CAST(ROW_NUMBER() OVER(ORDER BY order_id) AS INT) AS order_key,      -- surrogate key
    order_id,                                               -- The natural business key
    customer_id,                                            -- The natural business key
    order_status,
    
    -- Timestamps
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,

    -- derived columns
    CASE 
        WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 'On Time'
        WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 'Late'
        ELSE 'Pending/Cancelled'
    END AS delivery_performance_status
FROM silver.orders_info)

SELECT * FROM OrdersBase

UNION

SELECT 
    -1, 'UNKNOWN', 'UNKNOWN', 'unknown', NULL, NULL, NULL, NULL, NULL, 'unknown';
GO

--  ===================================================================
--  Create Dimension Table: gold.dim_date
--  ===================================================================

IF OBJECT_ID('gold.dim_date', 'V') IS NOT NULL
DROP VIEW gold.dim_date;
GO

CREATE OR ALTER VIEW gold.dim_date AS
WITH Numbers AS (
    SELECT TOP (1100)     -- Selecting no of day for this business data period
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
    FROM sys.all_objects
),
DateSeries AS (
    SELECT DATEADD(DAY, n, CAST('2016-01-01' AS DATE)) AS d
    FROM Numbers
    WHERE DATEADD(DAY, n, CAST('2016-01-01' AS DATE)) <= '2018-12-31'
)
SELECT
    CONVERT(INT, FORMAT(d, 'yyyyMMdd')) AS date_key,
    d AS date,
    DAY(d) AS day,
    DATEPART(WEEK, d) AS week,
    MONTH(d) AS month,
    DATENAME(MONTH, d) AS month_name,
    DATEPART(QUARTER, d) AS quarter,
    YEAR(d) AS year,
    CASE 
        WHEN DATENAME(WEEKDAY, d) IN ('Saturday','Sunday') THEN 1 
        ELSE 0 
    END AS is_weekend,
    CASE 
        WHEN (MONTH(d) = 1  AND DAY(d) = 1)
          OR (MONTH(d) = 4  AND DAY(d) = 21)
          OR (MONTH(d) = 5  AND DAY(d) = 1)
          OR (MONTH(d) = 9  AND DAY(d) = 7)
          OR (MONTH(d) = 10 AND DAY(d) = 12)
          OR (MONTH(d) = 11 AND DAY(d) = 2)
          OR (MONTH(d) = 11 AND DAY(d) = 15)
          OR (MONTH(d) = 12 AND DAY(d) = 25)
        THEN 1 ELSE 0
    END AS is_holiday_brazil_flag
FROM DateSeries;
GO

--  =================================================================
--  Create Dimension Table: gold.dim_location
--  =================================================================

IF OBJECT_ID('gold.dim_location', 'V') IS NOT NULL
DROP VIEW gold.dim_location;
GO

CREATE OR ALTER VIEW gold.dim_location AS
WITH CleanedGeolocation AS (
    SELECT 
        geo.geolocation_zip_code_prefix AS location_key, -- Surrogate Key
        geo.geolocation_zip_code_prefix,
        MAX(silver.fn_CleanSilverEncoding(geo.geolocation_city)) AS city,
        geo.geolocation_state AS state_code,
        sc.state_name,
        sc.region_name,

        -- Failsafe Coordinate Logic: Filter corrupted points, then fallback to state center
        CAST(COALESCE(
            AVG(CASE WHEN geo.geolocation_lat BETWEEN -34 AND 6 AND geo.geolocation_lng BETWEEN -74 AND -34 
                     THEN geo.geolocation_lat END), sc.avg_lat) AS DECIMAL(9,6)) AS latitude,
    
        CAST(COALESCE(
            AVG(CASE WHEN geo.geolocation_lat BETWEEN -34 AND 6 AND geo.geolocation_lng BETWEEN -74 AND -34 
                     THEN geo.geolocation_lng END), sc.avg_lng) AS DECIMAL(9,6)) AS longitude
    
    FROM silver.geolocation_info geo
    LEFT JOIN silver.state_centers sc ON geo.geolocation_state = sc.state_code
    GROUP BY geo.geolocation_zip_code_prefix, geo.geolocation_state, sc.avg_lat, sc.avg_lng, sc.state_name, sc.region_name
)

    --  combining real data with a placeholder for unknown locations
    SELECT * FROM CleanedGeolocation
    UNION ALL
    SELECT 
        -1, 0, 'unknown', 'NA', 'Unknown', 'Unknown', NULL, NULL;
GO
--  ======================================================================
--  Create Fact Table: gold.fact_sales
--  ======================================================================

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
DROP VIEW gold.fact_sales;
GO

CREATE OR ALTER VIEW gold.fact_sales AS
WITH SalesBase AS (
    SELECT 
        oi.order_id,
        oi.product_id,
        oi.seller_id,
        o.customer_id,
        o.order_status,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        oi.price AS product_price,
        oi.freight_value,
        (oi.price + oi.freight_value) AS total_product_value
    FROM silver.order_items oi
    JOIN silver.orders_info o ON oi.order_id = o.order_id
),
PaymentAggregation AS (
    SELECT 
        order_id, 
        SUM(payment_value) AS total_order_payment 
    FROM silver.order_payments
    GROUP BY order_id
)
SELECT DISTINCT
    -- 1. Surrogate Keys from Dimensions
    -- We join to Gold to get the INT keys and use COALESCE for the -1 placeholder
    CAST(ISNULL(do.order_key, -1) AS INT) AS order_key,
    CAST(ISNULL(dc.customer_key, -1) AS INT) AS customer_key,
    CAST(ISNULL(ds.seller_key, -1) AS INT) AS seller_key,
    CAST(ISNULL(dp.product_key, -1) AS INT) AS product_key,

    -- 4. Metrics
    sb.product_price,
    sb.freight_value,
    sb.total_product_value,
    pa.total_order_payment,

    -- 3. order_status
    sb.order_status,
    
    -- 4. Date Keys (Formatted as YYYYMMDD)
    CAST(sb.order_purchase_timestamp AS DATE) AS order_purchase_timestamp,
    CAST(sb.order_approved_at AS DATE) AS order_approved_at,
    CAST(sb.order_delivered_carrier_date AS DATE) AS order_delivered_carrier_date,
    CAST(sb.order_delivered_customer_date AS DATE) AS order_delivered_customer_date,

    -- 5. Calculated Logistics
    DATEDIFF(DAY, sb.order_purchase_timestamp, sb.order_delivered_customer_date) AS total_delivery_days,
    DATEDIFF(DAY, sb.order_purchase_timestamp, sb.order_delivered_carrier_date) AS seller_processing_days,
    DATEDIFF(DAY, sb.order_delivered_carrier_date, sb.order_delivered_customer_date) AS carrier_transit_days,

     -- 6. Flags
      CASE 
        WHEN sb.order_delivered_customer_date > sb.order_estimated_delivery_date 
        THEN DATEDIFF(DAY, sb.order_estimated_delivery_date, sb.order_delivered_customer_date) 
        ELSE 0 
    END AS delivery_delay_days,
    CASE WHEN sb.order_delivered_carrier_date IS NOT NULL THEN 1 ELSE 0 END AS is_shipped_flag,
    CASE WHEN sb.order_status = 'delivered' THEN 1 ELSE 0 END AS is_delivered_flag,
    CASE WHEN sb.order_delivered_customer_date > sb.order_estimated_delivery_date THEN 1 
         ELSE 0 
    END AS is_late_delivery_flag

    FROM SalesBase sb
    LEFT JOIN PaymentAggregation pa ON sb.order_id = pa.order_id
    LEFT JOIN gold.dim_orders do    ON sb.order_id = do.order_id
    LEFT JOIN gold.dim_customers dc ON sb.customer_id = dc.customer_id
    LEFT JOIN gold.dim_sellers ds   ON sb.seller_id = ds.seller_id
    LEFT JOIN gold.dim_products dp   ON sb.product_id = dp.product_id;
GO

--  ===================================================================
--  Create Fact Table: gold.fact_payments
--  ===================================================================

IF OBJECT_ID('gold.fact_payments', 'V') IS NOT NULL
DROP VIEW gold.fact_payments;
GO

CREATE OR ALTER VIEW gold.fact_payments AS
    SELECT 
        CAST(ISNULL(do.order_key, -1) AS INT) AS order_key,
        CAST(ISNULL(dc.customer_key, -1) AS INT) AS customer_key,
        CAST(o.order_approved_at AS DATE) AS order_approved_at,
        p.payment_value,
    
        -- FIX: Force 0 installments to 1 to maintain logical consistency
        CASE 
            WHEN p.payment_installments < 1 THEN 1 
            ELSE p.payment_installments 
        END AS payment_installments,
    
        LOWER(TRIM(p.payment_type)) AS payment_type
    FROM silver.order_payments p
    LEFT JOIN silver.orders_info o ON p.order_id = o.order_id
    LEFT JOIN gold.dim_orders do ON p.order_id = do.order_id
    LEFT JOIN gold.dim_customers dc ON o.customer_id = dc.customer_id
    WHERE o.order_approved_at IS NOT NULL;
GO

--  ====================================================================
--  Create Fact Table: gold.fact_reviews
--  ====================================================================

IF OBJECT_ID('gold.fact_reviews', 'V') IS NOT NULL
DROP VIEW gold.fact_reviews;
GO

CREATE OR ALTER VIEW gold.fact_reviews AS
WITH AggregatedReviews AS (
    SELECT 
        order_id,
        AVG(CAST(review_score AS DECIMAL(3,2))) AS avg_review_score, -- Average if they left multiple
        MAX(review_creation_date) AS latest_review_date,
        MAX(review_answer_timestamp) AS latest_answer_timestamp
    FROM silver.order_reviews
    GROUP BY order_id
)
SELECT 
    CAST(ISNULL(do.order_key, -1) AS INT) AS order_key,
    CAST(ISNULL(dc.customer_key, -1) AS INT) AS customer_key,
    CAST(ar.latest_review_date AS DATE) AS review_date,
    ar.avg_review_score,
    ar.latest_review_date,
    ar.latest_answer_timestamp,
    DATEDIFF(DAY, ar.latest_review_date, ar.latest_answer_timestamp) AS review_response_lag_days
FROM AggregatedReviews ar
LEFT JOIN silver.orders_info o ON ar.order_id = o.order_id
LEFT JOIN gold.dim_orders do ON ar.order_id = do.order_id
LEFT JOIN gold.dim_customers dc ON o.customer_id = dc.customer_id;
GO
