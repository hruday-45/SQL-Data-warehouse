/*
==================================================================
Quality Check
==================================================================
Script Purpose:
  This script performs various quality checks for data consistency, accuracy,
  and standardization across the tables of 'silver' schema. It includes:
  ---> Null or duplicate primary keys.
  ---> Unwanted spaces in string fields.
  ---> Data standardization and consistency.
  ---> Invalid date ranges and orders.
  ---> Data consistency between related fields.

Usage Notes:
  ---> Run these checks after executing the Silver Layer.
  ---> Investigate and resolve any discrepancies found during the checks.
=======================================================================
*/

--  =============================================================================================

-- Use this to check if there are any " in the data for all the table-columns
-- Expectation: No results

SELECT *
FROM silver.customers_info
WHERE customer_id LIKE '%"%';

--  =============================================================================================

-- (customer_id) represents a temporary id which gets created when the person creates new orders
-- (customer_unique_id) represents actual id of a customer which won't change
-- There can be same (customer_unique_id) for multiple for (customer_id values)

-- Check for Nulls or Duplicates in unique Keys
-- Expectation: No results
SELECT 
	customer_id,
	COUNT(*)
FROM silver.customers_info
GROUP BY customer_id
HAVING COUNT(*) > 1 OR customer_id IS NULL;

-- Data Standardization & Consistency check
SELECT 
	customer_state,
	COUNT(customer_state) 
FROM silver.customers_info
GROUP BY customer_state;

-- Check for Unwanted Spaces
-- Expectations: No Result
SELECT 
    customer_id
FROM silver.customers_info
WHERE customer_id != TRIM(customer_id);

SELECT 
    customer_unique_id
FROM silver.customers_info
WHERE customer_unique_id != TRIM(customer_unique_id);

--  =============================================================================================

-- By taking the centre point of both (geolocation_lat) and (geolocation_lng) as an average for both we make (geolocation_zip_code_prefix) as a unique key

-- Check for Nulls or Duplicates in unique Keys
-- Expectation: No results
SELECT 
	geolocation_zip_code_prefix,
	COUNT(*)
FROM silver.geolocation_info
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(*) > 1 OR geolocation_zip_code_prefix IS NULL;

-- Data Standardization & Consistency check
SELECT 
	geolocation_state,
	COUNT(geolocation_state) 
FROM silver.geolocation_info
GROUP BY geolocation_state;

--  =============================================================================================

-- Checking for valid dates
-- Expection: Resonable date range
SELECT 
    MIN(shipping_limit_date) AS earliest_date,
    MAX(shipping_limit_date) AS latest_date,
    COUNT(*) AS total_rows
FROM silver.order_items;

-- Check for null values in date
-- Expectation: Zero null dates, Zero percent missing
SELECT 
    COUNT(*) AS total_items,
    SUM(CASE WHEN shipping_limit_date IS NULL THEN 1 ELSE 0 END) AS null_shipping_dates,
    CAST(SUM(CASE WHEN shipping_limit_date IS NULL THEN 1.0 ELSE 0 END) / COUNT(*) * 100 AS DECIMAL(5,2)) AS percent_missing
FROM silver.order_items;

--  =============================================================================================

-- As there can be multiple payment mode for a single order order_id cannot be a primary key

-- Data Standardization & Consistency check
SELECT 
	payment_sequential,
	COUNT(payment_sequential) 
FROM silver.order_payments
GROUP BY payment_sequential

-- Data Standardization & Consistency check
SELECT 
	payment_installments,
	COUNT(payment_installments) 
FROM silver.order_payments
GROUP BY payment_installments;

-- Data Standardization & Consistency check
-- Expectation: No Results
SELECT 
	payment_value,
	COUNT(payment_value) 
FROM silver.order_payments
WHERE payment_value < 0
GROUP BY payment_value;

--  =============================================================================================

-- Check for Unwanted Spaces
-- Expectations: No Result
SELECT 
    review_id
FROM silver.order_reviews
WHERE review_id != TRIM(review_id);

SELECT 
    order_id
FROM silver.order_reviews
WHERE order_id != TRIM(order_id);

-- Data Standardization & Consistency check
SELECT 
	review_score,
	COUNT(review_score) 
FROM silver.order_reviews
GROUP BY review_score;

-- Check for null values in date
-- Expectation: Zero null dates, Zero percent missing
SELECT 
    COUNT(*) AS total_items,
    SUM(CASE WHEN review_creation_date IS NULL THEN 1 ELSE 0 END) AS null_shipping_dates,
    CAST(SUM(CASE WHEN review_creation_date IS NULL THEN 1.0 ELSE 0 END) / COUNT(*) * 100 AS DECIMAL(5,2)) AS percent_missing
FROM silver.order_reviews;

SELECT 
    COUNT(*) AS total_items,
    SUM(CASE WHEN review_answer_timestamp IS NULL THEN 1 ELSE 0 END) AS null_shipping_dates,
    CAST(SUM(CASE WHEN review_answer_timestamp IS NULL THEN 1.0 ELSE 0 END) / COUNT(*) * 100 AS DECIMAL(5,2)) AS percent_missing
FROM silver.order_reviews;

--  =============================================================================================

-- Check for Nulls or Duplicates in Unique Keys
-- Expectation: No results
SELECT 
	order_id,
	COUNT(*)
FROM silver.orders_info
GROUP BY order_id
HAVING COUNT(*) > 1 OR order_id IS NULL;

SELECT 
	customer_id,
	COUNT(*)
FROM silver.orders_info
GROUP BY customer_id
HAVING COUNT(*) > 1 OR customer_id IS NULL;

-- Data Standardization & Consistency check
SELECT 
	order_status,
	COUNT(order_status) 
FROM silver.orders_info
GROUP BY order_status;

-- Check for Unwanted Spaces
-- Expectations: No Result
SELECT 
    customer_id
FROM silver.orders_info
WHERE customer_id != TRIM(customer_id);

SELECT 
    order_id
FROM silver.orders_info
WHERE order_id != TRIM(order_id);

-- Checking for inconsistent 'null' order_delivered_customer_date is matching with order_status
-- Expectation: 0 in the is_null for DELIVERED, if they appear should make a note and keep an eye on the and report to the scource
SELECT 
    order_status, 
    COUNT(*) AS total_count,
    COUNT(order_delivered_customer_date) AS has_date,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS is_null
FROM silver.orders_info
GROUP BY order_status;

--  =============================================================================================

-- Check for Nulls or Duplicates in unique Keys
-- Expectation: No results
SELECT 
	product_category_name,
	COUNT(*)
FROM silver.product_category_name_translation
GROUP BY product_category_name
HAVING COUNT(*) > 1 OR product_category_name IS NULL;

SELECT 
	product_category_name_english,
	COUNT(*)
FROM silver.product_category_name_translation
GROUP BY product_category_name_english
HAVING COUNT(*) > 1 OR product_category_name_english IS NULL;

-- Data Standardization & Consistency check
SELECT 
	product_category_name,
	COUNT(*) 
FROM silver.product_category_name_translation
GROUP BY product_category_name;

-- Check for Unwanted Spaces
-- Expectations: No Result
SELECT 
    product_category_name
FROM silver.product_category_name_translation
WHERE product_category_name != TRIM(product_category_name);

SELECT 
    product_category_name_english
FROM silver.product_category_name_translation
WHERE product_category_name_english != TRIM(product_category_name_english);

--  =============================================================================================

-- Check for Nulls or Duplicates in unique Keys
-- Expectation: No results
SELECT 
	product_id,
	COUNT(*)
FROM silver.products_info
GROUP BY product_id
HAVING COUNT(*) > 1 OR product_id IS NULL;

-- Data Standardization & Consistency check
SELECT 
	product_category_name,
	COUNT(*) 
FROM silver.products_info
GROUP BY product_category_name;

--  =============================================================================================

-- Check for Nulls or Duplicates in unique Keys
-- Expectation: No results
SELECT 
	seller_id,
	COUNT(*)
FROM silver.sellers_info
GROUP BY seller_id
HAVING COUNT(*) > 1 OR seller_id IS NULL;

-- Data Standardization & Consistency check
SELECT 
	seller_state,
	COUNT(seller_state) 
FROM silver.sellers_info
GROUP BY seller_state;

--  =============================================================================================
