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

CREATE VIEW gold.dim_customers AS
   WITH RankedCustomers AS (
    SELECT 
        ci.customer_unique_id,
        ci.customer_id,
        ci.customer_city,
        ci.customer_state,
        ci.state_code,
        ci.customer_zip_code_prefix,
        CASE 
            WHEN gi.geolocation_lat > 6 OR gi.geolocation_lat < -35 THEN NULL 
            ELSE gi.geolocation_lat 
        END AS clean_lat,
        CASE 
            WHEN gi.geolocation_lng > -30 OR gi.geolocation_lng < -75 THEN NULL 
            ELSE gi.geolocation_lng 
        END AS clean_lng,
        ROW_NUMBER() OVER(PARTITION BY ci.customer_unique_id ORDER BY ci.customer_id DESC) as recency_rank
    FROM silver.customers_info ci
    LEFT JOIN silver.geolocation_info gi
    ON ci.customer_zip_code_prefix = gi.geolocation_zip_code_prefix),

    FinalData AS (
    SELECT 
        -1 AS customer_key,
        '000000' AS customer_unique_id,
        '000000' AS customer_id,
        'Unknown' AS customer_city,
        'Unknown' AS customer_state,
        'Unknown' AS state_code,
        0 AS customer_zipcode,
        CAST(NULL AS DECIMAL(9,6)) AS latitude,
        CAST(NULL AS DECIMAL(9,6)) AS longitude

    UNION ALL

    SELECT 
        CAST(ROW_NUMBER() OVER(ORDER BY customer_unique_id) AS INT) AS customer_key,
        customer_unique_id,
        customer_id,
        customer_city,
        customer_state,
        state_code,
        customer_zip_code_prefix AS customer_zipcode,
        CAST(clean_lat AS DECIMAL(9,6)) AS latitude,
        CAST(clean_lng AS DECIMAL(9,6)) AS longitude
    FROM RankedCustomers
    WHERE recency_rank = 1)

    SELECT * FROM FinalData;
GO

--  =====================================================================
--  Create Dimension Table: gold.dim_orders
--  =====================================================================

IF OBJECT_ID('gold.dim_orders', 'V') IS NOT NULL
DROP VIEW gold.dim_orders;
GO

CREATE VIEW gold.dim_orders AS
WITH payments_info AS (
    SELECT 
        order_id,
        SUM(payment_value) AS total_amount_paid,
        MAX(payment_installments) AS max_installments,
        COUNT(payment_sequential) AS payment_methods_count
    FROM silver.order_payments
    GROUP BY order_id),
	
review_info AS (
    SELECT
        order_id,
        CAST(AVG(CAST(review_score AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS avg_review_score
    FROM silver.order_reviews
    GROUP BY order_id)

SELECT
    CAST(ROW_NUMBER() OVER(ORDER BY oi.order_id) AS INT) AS order_key,
    oi.order_id,
    oi.customer_id,
    ISNULL(ri.avg_review_score, 0) AS avg_review_score,
    ISNULL(pa.payment_methods_count, 0) AS payment_methods_count,
    CAST(ISNULL(pa.total_amount_paid, 0) AS DECIMAL(10,2)) AS total_amount_paid,
    CAST(FORMAT(oi.order_purchase_timestamp, 'yyyy-MM-dd HH:mm') AS NVARCHAR(20)) AS purchase_date,
    CAST(FORMAT(oi.order_delivered_customer_date, 'yyyy-MM-dd HH:mm') AS NVARCHAR(20)) AS delivered_date,
    CAST(FORMAT(oi.order_estimated_delivery_date, 'yyyy-MM-dd HH:mm') AS NVARCHAR(20)) AS delivery_estimated_date,
    DATEDIFF(day, oi.order_purchase_timestamp, oi.order_delivered_customer_date) AS actual_delivered_days,
    CASE 
        WHEN oi.order_delivered_customer_date > oi.order_estimated_delivery_date THEN 1 
        ELSE 0 
    END AS late_delivery,
    CASE 
        WHEN oi.order_status = 'delivered' AND oi.order_delivered_customer_date IS NULL THEN 'shipped' 
        ELSE oi.order_status 
    END AS order_status
FROM silver.orders_info oi
LEFT JOIN payments_info pa ON oi.order_id = pa.order_id
LEFT JOIN review_info ri ON oi.order_id = ri.order_id;
GO

--  ======================================================================
--  Create Dimension Table: gold.dim_products
--  ======================================================================

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT 
	CAST(ROW_NUMBER() OVER (ORDER BY product_id) AS INT) AS product_key,
	p.product_id,
	ISNULL(pn.product_category_name_english, 'others') AS category_name,
	CAST(ISNULL(p.product_weight_g, 0)/ 1000.0 AS DECIMAL(10,3)) AS weight_kg,
	ISNULL(p.product_name_length, 0) AS name_length,
	CASE WHEN p.product_description_lenght IS NULL OR p.product_description_lenght = 0 THEN 'No Details'
		 WHEN p.product_description_lenght < 200 THEN 'Low'
		 WHEN p.product_description_lenght BETWEEN 200 AND 1000 THEN 'Standard'
		 ELSE 'High'
	END AS description_quality,
	ISNULL(p.product_photos_qty, 0) AS photos_quantity,
	(p.product_width_cm * p.product_length_cm * product_height_cm) AS volume_cm3
FROM silver.products_info p
LEFT JOIN silver.product_category_name_translation pn
ON p.product_category_name = pn.product_category_name;
GO

--  ===================================================================
--  Create Dimension Table: gold.dim_sellers
--  ===================================================================

IF OBJECT_ID('gold.dim_sellers', 'V') IS NOT NULL
DROP VIEW gold.dim_sellers;
GO

CREATE VIEW gold.dim_sellers AS
SELECT 
	CAST(ROW_NUMBER() OVER(ORDER BY seller_id) AS INT) AS seller_key,
	s.seller_id,	
	s.seller_city AS seller_city,
	s.seller_state AS seller_state,
	s.state_code,
	s.seller_zip_code_prefix AS seller_zip_code,
	gi.geolocation_lat AS latitude,
	gi.geolocation_lng AS longitude
FROM silver.sellers_info s
LEFT JOIN silver.geolocation_info gi
ON s.seller_zip_code_prefix = gi.geolocation_zip_code_prefix;
GO

--  ===================================================================
--  Create Dimension Table: gold.dim_date
--  ===================================================================

IF OBJECT_ID('gold.dim_date', 'V') IS NOT NULL
DROP VIEW gold.dim_date;
GO

CREATE VIEW gold.dim_date AS
WITH date_range AS (
    SELECT MIN(full_date) as start_date, MAX(full_date) as end_date
    FROM (
        SELECT CAST(order_purchase_timestamp AS DATE) AS full_date 
        FROM silver.orders_info
        UNION
        SELECT CAST(review_creation_date AS DATE) 
        FROM silver.order_reviews
        UNION
        SELECT CAST(shipping_limit_date AS DATE) 
        FROM silver.order_items) 
        sub),

t10 AS (SELECT n 
        FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) t(n)),
numbers AS (
    SELECT (a.n * 1000 + b.n * 100 + c.n * 10 + d.n) AS n
    FROM t10 a, t10 b, t10 c, t10 d),

date_series AS (
    SELECT DATEADD(DAY, n, start_date) AS full_date
    FROM date_range, numbers
    WHERE DATEADD(DAY, n, start_date) <= end_date)

SELECT
    full_date AS date_id, 
    DATEPART(YEAR, full_date) AS year, 
    DATEPART(QUARTER, full_date) AS quarter_number,
    'Q' + CAST(DATEPART(QUARTER, full_date) AS NVARCHAR(1)) AS quarter_name, 
    DATEPART(MONTH, full_date) AS month_number,
    DATENAME(MONTH, full_date) AS month_name, 
    CAST(FORMAT(full_date, 'yyyy-MM') AS NVARCHAR(20)) AS year_month, 
    DATEPART(WEEK, full_date) AS week_of_year,
    DATEPART(DAY, full_date) AS day_number, 
    DATENAME(WEEKDAY, full_date) AS day_name,
    DATEPART(WEEKDAY, full_date) AS day_of_week_sort,
    CASE 
        WHEN DATEPART(WEEKDAY, full_date) IN (1, 7) THEN 1 
        ELSE 0 
    END AS is_weekend
FROM date_series;
GO

--  ===================================================================
--  Create Fact Table: gold.fact_payments
--  ===================================================================

IF OBJECT_ID('gold.fact_payments', 'V') IS NOT NULL
DROP VIEW gold.fact_payments;
GO

CREATE VIEW gold.fact_payments AS
SELECT 
    CAST(ROW_NUMBER() OVER(ORDER BY do.order_id, payment_sequential) AS INT) AS payment_key,
    do.order_key,
    dd.date_id,
    payment_sequential,
    payment_type,
    payment_installments,
    op.payment_value AS payment_amount,
    CASE WHEN op.payment_value = 0 THEN 1 ELSE 0 END AS is_voucher_only
FROM silver.order_payments op
INNER JOIN gold.dim_orders do ON op.order_id = do.order_id
INNER JOIN gold.dim_date dd ON CAST(do.purchase_date AS DATE) = dd.date_id;;
GO

--  ====================================================================
--  Create Fact Table: gold.fact_reviews
--  ====================================================================

IF OBJECT_ID('gold.fact_reviews', 'V') IS NOT NULL
DROP VIEW gold.fact_reviews;
GO

CREATE VIEW gold.fact_reviews AS
SELECT 
    ro.review_key,
    do.order_key,
    CAST(ro.review_score AS INT) AS review_score,
    ro.review_comment_title,
    ro.review_comment_message,
    CAST(ro.review_creation_date AS DATE) AS date_id,
	CAST(FORMAT(ro.review_answer_timestamp, 'yyyy-MM-dd HH:mm') AS NVARCHAR(20)) AS review_answer_timestamp
FROM silver.order_reviews ro
LEFT JOIN gold.dim_orders do
ON ro.order_id = do.order_id;
GO

--  ======================================================================
--  Create Fact Table: gold.fact_sales
--  ======================================================================

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT 
	do.order_key,
	oi.order_item_id AS order_sequence_no,
	ds.seller_key,
	ISNULL(dc.customer_key, -1) AS customer_key,
	df.product_key,
	CAST(oi.price AS DECIMAL(10,2)) AS price,
	CAST(oi.freight_value AS DECIMAL(10,2)) AS freight_value,
	CAST(oi.total_value AS DECIMAL(10,2)) AS total_value,
	CAST(o.order_purchase_timestamp AS DATE) AS date_id,
	CAST(oi.shipping_limit_date AS DATE) AS shipping_limit_date
FROM silver.order_items oi
LEFT JOIN silver.orders_info o ON oi.order_id = o.order_id
LEFT JOIN gold.dim_sellers ds ON oi.seller_id = ds.seller_id
LEFT JOIN gold.dim_orders do ON oi.order_id = do.order_id
LEFT JOIN gold.dim_customers dc ON o.customer_id = dc.customer_id
LEFT JOIN gold.dim_products df ON oi.product_id = df.product_id

GO

--  ========================================================================
