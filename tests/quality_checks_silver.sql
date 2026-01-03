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



-- ===========================================================================
-- Use this to check if there are any " in the data for all the table-columns
-- Expectation: No results
-- ===========================================================================
SELECT *
FROM silver.customers_info
WHERE customer_id LIKE '%"%';


/*******************************************************************************
                    DATA QUALITY AUDIT: silver.customers_info
********************************************************************************/

-- ----------------------------------------------------------------------------
-- 1. PRIMARY KEY INTEGRITY CHECK
-- ----------------------------------------------------------------------------
-- Goal: Verify customer_id is Unique and Non-Null.
-- Expectation: 0 rows returned.
-- ----------------------------------------------------------------------------
SELECT 
	customer_id,
	COUNT(*)
FROM silver.customers_info
GROUP BY customer_id
HAVING COUNT(*) > 1 OR customer_id IS NULL;

-- ----------------------------------------------------------------------------
-- 2. GEOGRAPHIC STANDARDIZATION CHECK
-- ----------------------------------------------------------------------------
-- Goal: Inspect distribution of customer_state to spot encoding errors.
-- Expectation: Valid 2-letter Brazilian state codes (SP, RJ, etc.).
-- ----------------------------------------------------------------------------
SELECT 
	customer_state,
	COUNT(customer_state) 
FROM silver.customers_info
GROUP BY customer_state;

-- ----------------------------------------------------------------------------
-- 3. STRING INTEGRITY (WHITESPACE AUDIT)
-- ----------------------------------------------------------------------------
-- Goal: Identify records with leading or trailing spaces.
-- Expectation: 0 rows returned.
-- ----------------------------------------------------------------------------
SELECT 
    customer_id
FROM silver.customers_info
WHERE customer_id != TRIM(customer_id);

SELECT 
    customer_unique_id
FROM silver.customers_info
WHERE customer_unique_id != TRIM(customer_unique_id);


/****************************************************************************
                    DATA QUALITY AUDIT: silver.geolocation_info
*****************************************************************************/

-- ----------------------------------------------------------------------------
-- 1. PRIMARY KEY & UNIQUENESS CHECK
-- ----------------------------------------------------------------------------
-- Goal: Confirm that each Zip Code Prefix is unique and contains no NULLs.
-- Expectation: 0 rows returned.
-- ----------------------------------------------------------------------------
SELECT 
	geolocation_zip_code_prefix,
	COUNT(*) AS no_duplicate_zipcodes
FROM silver.geolocation_info
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(*) > 1 OR geolocation_zip_code_prefix IS NULL;

-- ----------------------------------------------------------------------------
-- 2. GEOGRAPHIC DISTRIBUTION & ENCODING CHECK
-- ----------------------------------------------------------------------------
-- Goal: Verify that all state codes follow the standard 2-letter format.
-- Expectation: 27 distinct Brazilian states/districts (SP, RJ, etc.).
-- ----------------------------------------------------------------------------
SELECT 
	geolocation_state 
FROM silver.geolocation_info
GROUP BY geolocation_state;

-- ----------------------------------------------------------------------------
-- 3. COORDINATE BOUNDARY CHECK (OPTIONAL ADDITION)
-- ----------------------------------------------------------------------------
-- Goal: Ensure no coordinates fall outside of realistic Brazilian boundaries.
-- Logic: Brazil is roughly between Lat (-35, 6) and Lng (-74, -34).
-- ----------------------------------------------------------------------------
SELECT 
    'Latitude Outliers' AS check_type,
    COUNT(*) AS outlier_count
FROM silver.geolocation_info
WHERE geolocation_lat NOT BETWEEN -35 AND 6

UNION ALL

SELECT 
    'Longitude Outliers' AS check_type,
    COUNT(*) AS outlier_count
FROM silver.geolocation_info
WHERE geolocation_lng NOT BETWEEN -74 AND -34;


/************************************************************************
            DATA QUALITY AUDIT: silver.order_items 
************************************************************************/

-- ----------------------------------------------------------------------------
-- 1. CHRONOLOGICAL BOUNDARY CHECK
-- ----------------------------------------------------------------------------
-- Goal: Verify the minimum and maximum dates to identify extreme outliers.
-- Expectation: Reasonable start/end dates matching business operations.
-- I found 4 orders for the year 2020 which I considered as test orders, remaining are under 2018.
-- ----------------------------------------------------------------------------
SELECT 
    MIN(shipping_limit_date) AS earliest_date,
    MAX(shipping_limit_date) AS latest_date,
    COUNT(*) AS total_rows
FROM silver.order_items;

-- ----------------------------------------------------------------------------
-- 2. OUTLIER CONTRIBUTION & YEARLY DISTRIBUTION
-- ----------------------------------------------------------------------------
-- Goal: Calculate the percentage of records per year to assess outlier impact.
-- Expectation: Concentrated volume in 2017/2018; negligible volume in 2020.
-- ----------------------------------------------------------------------------
SELECT 
    YEAR(shipping_limit_date) AS order_year,
    COUNT(*) AS item_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage_of_total
FROM silver.order_items
GROUP BY YEAR(shipping_limit_date)
ORDER BY order_year;

-- ----------------------------------------------------------------------------
-- 3. NULL VALUE & DATA COMPLETENESS AUDIT
-- ----------------------------------------------------------------------------
-- Goal: Check for missing values in the shipping limit date column.
-- Expectation: 0 Null dates and 0.00% missing.
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(*) AS total_items,
    SUM(CASE WHEN shipping_limit_date IS NULL THEN 1 ELSE 0 END) AS null_shipping_dates,
    CAST(SUM(CASE WHEN shipping_limit_date IS NULL THEN 1.0 ELSE 0 END) / COUNT(*) * 100 AS DECIMAL(5,2)) AS percent_missing
FROM silver.order_items;


/********************************************************************************
                    DATA QUALITY AUDIT: silver.order_payments
*********************************************************************************/

-- ----------------------------------------------------------------------------
-- 1. NEGATIVE VALUE AUDIT
-- ----------------------------------------------------------------------------
-- Goal: Identify any records with negative payment amounts.
-- Expectation: 0 rows returned.
-- ----------------------------------------------------------------------------
SELECT 
    payment_value, 
    COUNT(*) AS record_count
FROM silver.order_payments
WHERE payment_value < 0
GROUP BY payment_value;

-- ----------------------------------------------------------------------------
-- 2. PAYMENT TYPE STANDARDIZATION
-- ----------------------------------------------------------------------------
-- Goal: Check for naming consistency and identify rare/undefined types.
-- Expectation: Standard types (credit_card, boleto, voucher, debit_card).
-- ----------------------------------------------------------------------------
SELECT 
    payment_type, 
    COUNT(*) AS frequency,
    ROUND(SUM(payment_value), 2) AS total_revenue_per_type
FROM silver.order_payments
GROUP BY payment_type
ORDER BY frequency DESC;

-- ----------------------------------------------------------------------------
-- 3. INSTALLMENT LOGIC VALIDATION
-- ----------------------------------------------------------------------------
-- Goal: Verify that non-credit card payments are not processed as installments.
-- Expectation: Only 'credit_card' should typically have installments > 1.
-- ----------------------------------------------------------------------------
SELECT 
    payment_type,
    MAX(payment_installments) AS max_installments,
    MIN(payment_installments) AS min_installments
FROM silver.order_payments
GROUP BY payment_type;

-- ----------------------------------------------------------------------------
-- 4. ORDER-PAYMENT MULTIPLICITY PROFILE
-- ----------------------------------------------------------------------------
-- Goal: Analyze how many orders utilize multiple payment methods.
-- Expectation: Most orders = 1; small percentage > 1 (Split Payments).
-- ----------------------------------------------------------------------------
WITH PaymentCounts AS (
    SELECT 
        order_id, 
        COUNT(*) AS payment_method_count
    FROM silver.order_payments
    GROUP BY order_id
)
SELECT 
    payment_method_count, 
    COUNT(*) AS order_count
FROM PaymentCounts
GROUP BY payment_method_count
ORDER BY payment_method_count ASC;


/*******************************************************************************
            DATA QUALITY AUDIT: silver.order_reviews
**********************************************************************************/

-- ----------------------------------------------------------------------------
-- 1. STRING INTEGRITY (WHITESPACE AUDIT)
-- ----------------------------------------------------------------------------
-- Goal: Identify records with hidden leading/trailing spaces.
-- Expectation: 0 rows returned.
-- ----------------------------------------------------------------------------
SELECT 
    'review_id' AS column_source,
    review_id
FROM silver.order_reviews
WHERE review_id != TRIM(review_id)

UNION ALL

SELECT 
    'order_id' AS column_source,
    order_id
FROM silver.order_reviews
WHERE order_id != TRIM(order_id);

-- ----------------------------------------------------------------------------
-- 2. SCORE DISTRIBUTION & STANDARDIZATION
-- ----------------------------------------------------------------------------
-- Goal: Verify scores fall within the expected 1-5 range and check frequency.
-- Expectation: No scores outside 1-5; high concentration of 4s and 5s.
-- ----------------------------------------------------------------------------
SELECT 
    review_score, 
    COUNT(*) AS score_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage_share
FROM silver.order_reviews
GROUP BY review_score
ORDER BY review_score DESC;

-- ----------------------------------------------------------------------------
-- 3. DATA COMPLETENESS (TEMPORAL AUDIT)
-- ----------------------------------------------------------------------------
-- Goal: Check for missing dates in the feedback lifecycle.
-- Expectation: review_creation_date should be 100% complete. 
-- Note: answer_timestamp might have nulls if a customer never responded.
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(*) AS total_reviews,
    -- Audit Creation Date
    SUM(CASE WHEN review_creation_date IS NULL THEN 1 ELSE 0 END) AS null_creation_dates,
    CAST(SUM(CASE WHEN review_creation_date IS NULL THEN 1.0 ELSE 0 END) 
         / COUNT(*) * 100 AS DECIMAL(5,2)) AS pct_missing_creation,
    -- Audit Answer Timestamp
    SUM(CASE WHEN review_answer_timestamp IS NULL THEN 1 ELSE 0 END) AS null_answer_timestamps,
    CAST(SUM(CASE WHEN review_answer_timestamp IS NULL THEN 1.0 ELSE 0 END) 
         / COUNT(*) * 100 AS DECIMAL(5,2)) AS pct_missing_answer
FROM silver.order_reviews;

-- ----------------------------------------------------------------------------
-- 4. LOGICAL CONSISTENCY (DATE SEQUENCE CHECK)
-- ----------------------------------------------------------------------------
-- Goal: Ensure the answer was not submitted before the review was created.
-- Expectation: 0 rows returned (Answer must be >= Creation).
-- ----------------------------------------------------------------------------
SELECT 
    review_id, 
    review_creation_date, 
    review_answer_timestamp
FROM silver.order_reviews
WHERE review_answer_timestamp < review_creation_date;


/************************************************************************
                DATA QUALITY AUDIT: silver.orders_info
*************************************************************************/

-- ----------------------------------------------------------------------------
-- 1. KEY INTEGRITY & UNIQUENESS CHECK
-- ----------------------------------------------------------------------------
-- Goal: Ensure order_id is a unique Primary Key and customer_id is valid.
-- Expectation: 0 rows returned.
-- ----------------------------------------------------------------------------
SELECT 
    'order_id' AS key_type,
    order_id AS identifier,
    COUNT(*) AS duplicate_count
FROM silver.orders_info
GROUP BY order_id
HAVING COUNT(*) > 1 OR order_id IS NULL

UNION ALL

SELECT 
    'customer_id' AS key_type,
    customer_id AS identifier,
    COUNT(*) AS duplicate_count
FROM silver.orders_info
GROUP BY customer_id
HAVING COUNT(*) > 1 OR customer_id IS NULL;

-- ----------------------------------------------------------------------------
-- 2. STATUS STANDARDIZATION
-- ----------------------------------------------------------------------------
-- Goal: Identify the distribution of orders across different lifecycle stages.
-- Expectation: Majority of orders should be 'delivered'.
-- ----------------------------------------------------------------------------
SELECT 
    order_status, 
    COUNT(*) AS total_count_status,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS status_percentage
FROM silver.orders_info
GROUP BY order_status
ORDER BY total_count_status DESC;

-- ----------------------------------------------------------------------------
-- 3. STRING INTEGRITY (WHITESPACE AUDIT)
-- ----------------------------------------------------------------------------
-- Goal: Identify IDs with leading/trailing spaces that could break joins.
-- Expectation: 0 rows returned.
-- ----------------------------------------------------------------------------
SELECT 
    'customer_id' AS column_source,
    customer_id
FROM silver.orders_info
WHERE customer_id != TRIM(customer_id)

UNION ALL

SELECT 
    'order_id' AS column_source,
    order_id
FROM silver.orders_info
WHERE order_id != TRIM(order_id);

-- ----------------------------------------------------------------------------
-- 4. LOGISTICS LOGIC CROSS-VALIDATION
-- ----------------------------------------------------------------------------
-- Goal: Ensure 'delivered' orders actually have a delivery date.
-- Expectation: 'is_null' should be 0 for the 'delivered' status.
-- ----------------------------------------------------------------------------
SELECT 
    order_status, 
    COUNT(*) AS total_count,
    COUNT(order_delivered_customer_date) AS has_date,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS is_null,
    CASE 
        WHEN order_status = 'delivered' AND SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) > 0 
        THEN 'DATA QUALITY ISSUE' 
        ELSE 'OK' 
    END AS audit_result
FROM silver.orders_info
GROUP BY order_status;


-- Decision:
    -- Since 8 rows represent < 0.01% of delivered orders, I will be retaining them in the fact table for total sales volume, 
    -- but excluding them from average shipping time calculations to avoid skewing metrics.



/******************************************************************************
            DATA QUALITY AUDIT: silver.product_category_name_translation
********************************************************************************/

-- ----------------------------------------------------------------------------
-- 1. UNIQUENESS & MAPPING INTEGRITY
-- ----------------------------------------------------------------------------
-- Goal: Confirm that each category exists only once in the mapping table.
-- Expectation: 0 rows returned for duplicates.
-- ----------------------------------------------------------------------------
SELECT 
    product_category_name, 
    COUNT(*) AS mapping_count
FROM silver.product_category_name_translation
GROUP BY product_category_name
HAVING COUNT(*) > 1;

-- ----------------------------------------------------------------------------
-- 2. TRANSLATION DICTIONARY REVIEW
-- ----------------------------------------------------------------------------
-- Goal: Inspect the full list of English translations for standardization.
-- Expectation: Clean, readable English names without special characters.
-- ----------------------------------------------------------------------------
SELECT 
    product_category_name_english
FROM silver.product_category_name_translation
GROUP BY product_category_name_english
ORDER BY product_category_name_english;

-- ----------------------------------------------------------------------------
-- 3. STRING INTEGRITY (WHITESPACE AUDIT)
-- ----------------------------------------------------------------------------
-- Goal: Identify records with leading or trailing spaces.
-- Expectation: 0 rows returned.
-- ----------------------------------------------------------------------------
SELECT 
    'Portuguese Name' AS column_source,
    product_category_name AS record_value
FROM silver.product_category_name_translation
WHERE product_category_name != TRIM(product_category_name)

UNION ALL

SELECT 
    'English Translation' AS column_source,
    product_category_name_english AS record_value
FROM silver.product_category_name_translation
WHERE product_category_name_english != TRIM(product_category_name_english);


/*************************************************************************
                DATA QUALITY AUDIT: silver.products_info
***************************************************************************/

-- ----------------------------------------------------------------------------
-- 1. PRIMARY KEY INTEGRITY CHECK
-- ----------------------------------------------------------------------------
-- Goal: Confirm product_id is unique and contains no NULL values.
-- Expectation: 0 rows returned.
-- ----------------------------------------------------------------------------
SELECT 
    product_id, 
    COUNT(*) AS duplicate_products
FROM silver.products_info
GROUP BY product_id
HAVING COUNT(*) > 1 
   OR product_id IS NULL;

-- ----------------------------------------------------------------------------
-- 2. CATEGORY STANDARDIZATION & NAMING REVIEW
-- ----------------------------------------------------------------------------
-- Goal: Inspect all distinct categories for spelling errors or naming artifacts.
-- Expectation: Clean, standardized Portuguese category names.
-- ----------------------------------------------------------------------------
SELECT 
    product_category_name, 
    COUNT(*) AS products_per_category
FROM silver.products_info
GROUP BY product_category_name
ORDER BY product_category_name ASC;

-- ----------------------------------------------------------------------------
-- 3. PHYSICAL DIMENSION AUDIT (DATA COMPLETENESS)
-- ----------------------------------------------------------------------------
-- Goal: Identify if any products are missing critical shipping dimensions.
-- Expectation: Minimal NULLs (thanks to previous median imputation).
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(*) AS total_products,
    SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END) AS null_weights,
    SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END) AS null_lengths,
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS uncategorized_products
FROM silver.products_info;


/***********************************************************
        DATA QUALITY AUDIT: silver.sellers_info
************************************************************/

-- ----------------------------------------------------------------------------
-- 1. PRIMARY KEY INTEGRITY CHECK
-- ----------------------------------------------------------------------------
-- Goal: Confirm seller_id is unique and contains no NULL values.
-- Expectation: 0 rows returned.
-- ----------------------------------------------------------------------------
SELECT 
    seller_id, 
    COUNT(*) AS duplicate_seller
FROM silver.sellers_info
GROUP BY seller_id
HAVING COUNT(*) > 1 
   OR seller_id IS NULL;

-- ----------------------------------------------------------------------------
-- 2. GEOGRAPHIC STANDARDIZATION & DENSITY
-- ----------------------------------------------------------------------------
-- Goal: Verify state codes are standardized and identify seller concentration.
-- Expectation: Valid 2-letter codes (SP, PR, MG, etc.).
-- ----------------------------------------------------------------------------
SELECT 
    seller_state, 
    COUNT(*) AS seller_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage_share
FROM silver.sellers_info
GROUP BY seller_state
ORDER BY seller_count DESC;

-- ----------------------------------------------------------------------------
-- 3. STRING INTEGRITY (WHITESPACE AUDIT)
-- ----------------------------------------------------------------------------
-- Goal: Identify IDs with leading/trailing spaces that could break joins.
-- Expectation: 0 rows returned.
-- ----------------------------------------------------------------------------
SELECT 
    'seller_id' AS column_source,
    seller_id
FROM silver.sellers_info
WHERE seller_id != TRIM(seller_id);

/**************************************************************************
                            END OF AUDIT
***************************************************************************/
