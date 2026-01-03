/*********************************************************************************************************
                                            Quality Checks
============================================================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency, and accuracy of the Gold Layer.
    These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
**********************************************************************************************************/



/************************************************************************
                DATA QUALITY AUDIT: gold.dim_customers
************************************************************************/

-- ----------------------------------------------------------------------------
-- 1. GEOSPATIAL BOUNDARY AUDIT
-- ----------------------------------------------------------------------------
-- Goal: Identify coordinate values that would fail in Tableau/Power BI maps.
-- Expectation: 0 rows per issue.
-- ----------------------------------------------------------------------------
SELECT 
    'Latitude Out of Range' AS issue_description, 
    COUNT(*) AS fault_count 
FROM gold.dim_customers 
WHERE latitude NOT BETWEEN -90 AND 90
  
UNION ALL
  
SELECT 
    'Longitude Out of Range', 
    COUNT(*) 
FROM gold.dim_customers 
WHERE longitude NOT BETWEEN -180 AND 180

UNION ALL
  
SELECT 
    'Duplicate Unique IDs', 
    COUNT(*) 
FROM (
    SELECT customer_id 
    FROM gold.dim_customers 
    GROUP BY customer_id 
    HAVING COUNT(*) > 1
) AS duplicate_subquery;

-- ----------------------------------------------------------------------------
-- 2. CRITICAL ATTRIBUTE COMPLETENESS CHECK
-- ----------------------------------------------------------------------------
-- Goal: Detect missing values in columns used for slicing and dicing data.
-- Expectation: 0 rows per issue.
-- ----------------------------------------------------------------------------
SELECT 
    'Null City' AS issue_description, 
    COUNT(*) AS fault_count 
FROM gold.dim_customers
WHERE customer_city IS NULL
  
UNION ALL
  
SELECT 
    'Null State Name', 
    COUNT(*) 
FROM gold.dim_customers 
WHERE customer_state IS NULL
  
UNION ALL
  
SELECT 
    'Null Unique ID', 
    COUNT(*) 
FROM gold.dim_customers
WHERE customer_unique_id IS NULL;

-- ----------------------------------------------------------------------------
-- 3. CITY NAME NORMALIZATION AUDIT
-- ----------------------------------------------------------------------------
-- Goal: Confirm that no duplicate cities exist due to casing or spacing issues.
-- Expectation: 0 rows (Shows that 'sao paulo' and 'Sao Paulo' are consolidated).
-- ----------------------------------------------------------------------------
SELECT 
    customer_city, 
    COUNT(*) AS record_count
FROM gold.dim_customers 
GROUP BY customer_city 
HAVING COUNT(DISTINCT LOWER(customer_city)) > 1;

-- ----------------------------------------------------------------------------
-- 4. REGIONAL BOUNDARY AUDIT (BRAZIL BOX)
-- ----------------------------------------------------------------------------
-- Goal: Identify coordinates that fall outside the landmass of Brazil.
-- Logic: Brazil's approximate boundaries are:
--        Lat: 6°N to 35°S | Long: 30°W to 75°W
-- Expectation: 0 outliers.
-- ----------------------------------------------------------------------------
SELECT 
    'Coordinates Outside Brazil' AS issue_description, 
    COUNT(*) AS fault_count
FROM gold.dim_customers 
WHERE latitude > 6 OR latitude < -35 
   OR longitude > -34 OR longitude < -74; -- Tuned to Brazilian coastal limits


/****************************************************************************
            DATA QUALITY AUDIT: gold.dim_date
****************************************************************************/

-- ----------------------------------------------------------------------------
-- 1. PRIMARY KEY INTEGRITY (DUPLICATE AUDIT)
-- ----------------------------------------------------------------------------
-- Goal: Ensure each date exists only once in the dimension.
-- Expectation: 0 rows returned.
-- ----------------------------------------------------------------------------
SELECT 
    date_key, 
    COUNT(*) AS occurrence_count
FROM gold.dim_date 
GROUP BY date_key 
HAVING COUNT(*) > 1;


-- ----------------------------------------------------------------------------
-- 2. CHRONOLOGICAL RANGE & CONTINUITY
-- ----------------------------------------------------------------------------
-- Goal: Verify the table covers the full business period without gaps.
-- Expectation: Min/Max dates align with Olist operations (e.g., 2016 - 2018+).
-- ----------------------------------------------------------------------------
SELECT 
    MIN(date_key) AS earliest_date, 
    MAX(date_key) AS latest_date, 
    COUNT(*) AS total_days_covered
FROM gold.dim_date
WHERE date_key <> -1; -- Exclude "Unknown" member


-- ----------------------------------------------------------------------------
-- 3. LOGICAL FLAG VALIDATION (WEEKEND CHECK)
-- ----------------------------------------------------------------------------
-- Goal: Ensure the 'is_weekend' flag is only applied to Saturdays and Sundays.
-- Expectation: Observe the pattern in the date (eg., 02, 03 | 09, 10 | 16, 17).
-- ----------------------------------------------------------------------------
SELECT DISTINCT 
    date, 
    is_weekend
FROM gold.dim_date 
WHERE is_weekend = 1;


/***********************************************************************
                DATA QUALITY AUDIT: gold.dim_orders
*************************************************************************/

-- ----------------------------------------------------------------------------
-- 1. PRIMARY KEY INTEGRITY (DUPLICATE AUDIT)
-- ----------------------------------------------------------------------------
-- Goal: Ensure each order exists only once at the Gold grain.
-- Expectation: 0 rows returned.
-- ----------------------------------------------------------------------------
SELECT 
    order_key, 
    COUNT(*) AS occurrence_count
FROM gold.dim_orders 
GROUP BY order_key 
HAVING COUNT(*) > 1;

-- ----------------------------------------------------------------------------
-- 2. PLACEHOLDER VALIDATION (REFERENTIAL INTEGRITY)
-- ----------------------------------------------------------------------------
-- Goal: Confirm the '-1' record exists to handle late-arriving or missing data.
-- Expectation: 1 row returned with "Unknown" or default values.
-- ----------------------------------------------------------------------------
SELECT * FROM gold.dim_orders 
WHERE order_key = -1;

-- ----------------------------------------------------------------------------
-- 3. CHRONOLOGICAL SEQUENCE AUDIT
-- ----------------------------------------------------------------------------
-- Goal: Detect "Time-Travel" errors where delivery occurs before purchase.
-- Expectation: 0 rows (A physical impossibility in standard e-commerce).
-- ----------------------------------------------------------------------------
SELECT 
    order_id, 
    order_purchase_timestamp, 
    order_delivered_customer_date
FROM gold.dim_orders
WHERE order_delivered_customer_date < order_purchase_timestamp;


/*****************************************************************************
                DATA QUALITY AUDIT: gold.dim_location
******************************************************************************/

-- ----------------------------------------------------------------------------
-- 1. ENCODING & NOISE AUDIT (TEXT INTEGRITY)
-- ----------------------------------------------------------------------------
-- Goal: Detect "Dirty" data that escaped the silver.fn_CleanSilverEncoding logic.
-- Expectation: 0 rows returned.
-- ----------------------------------------------------------------------------
SELECT 
    city,
    'Symbol Noise Detected' AS issue_type
FROM gold.dim_location 
WHERE city LIKE '%*%' 
   OR city LIKE '%´%' 
   OR city LIKE '%...%';

-- ----------------------------------------------------------------------------
-- 2. GEOSPATIAL BOUNDARY AUDIT (BRAZIL BOX)
-- ----------------------------------------------------------------------------
-- Goal: Identify coordinate "glitches" located outside South America.
-- Logic: Brazil limits are roughly Lat (-35 to 6) and Long (-75 to -30).
-- Expectation: 0 outliers (excluding the unknown placeholder).
-- ----------------------------------------------------------------------------
SELECT 
    location_key,
    city,
    state_code,
    latitude,
    longitude
FROM gold.dim_location 
WHERE (latitude NOT BETWEEN -35 AND 6 
   OR longitude NOT BETWEEN -75 AND -30)
  AND location_key <> -1;

-- ----------------------------------------------------------------------------
-- 3. REFERENTIAL INTEGRITY CHECK (UNKNOWN MEMBER)
-- ----------------------------------------------------------------------------
-- Goal: Ensure the '-1' placeholder exists for orders with missing zip codes.
-- Expectation: 1 row returned.
-- ----------------------------------------------------------------------------
SELECT * FROM gold.dim_location 
WHERE location_key = -1;


/***************************************************************************
                DATA QUALITY AUDIT: gold.dim_products
****************************************************************************/

-- ----------------------------------------------------------------------------
-- 1. PRIMARY KEY INTEGRITY (DUPLICATE AUDIT)
-- ----------------------------------------------------------------------------
-- Goal: Ensure each product SKU exists only once in the Gold Layer.
-- Expectation: 0 rows returned.
-- ----------------------------------------------------------------------------
SELECT 
    product_id, 
    COUNT(*) AS occurrence_count
FROM gold.dim_products 
GROUP BY product_id 
HAVING COUNT(*) > 1;

-- ----------------------------------------------------------------------------
-- 2. CATEGORIZATION COMPLETENESS
-- ----------------------------------------------------------------------------
-- Goal: Identify products without a valid business category.
-- Expectation: Minimal count (only the '-1' placeholder).
-- ----------------------------------------------------------------------------
SELECT 
    product_category_name,
    COUNT(*) AS product_count
FROM gold.dim_products
WHERE product_category_name IS NULL 
   OR product_category_name = 'unknown'
GROUP BY product_category_name;

-- ----------------------------------------------------------------------------
-- 3. PHYSICAL ATTRIBUTE REALITY CHECK
-- ----------------------------------------------------------------------------
-- Goal: Detect "Ghost Products" with 0 or negative weight/length.
-- Expectation: 0 rows (Ensures logistics KPIs aren't skewed by impossible data).
-- ----------------------------------------------------------------------------
SELECT 
    product_id, 
    product_weight_g, 
    product_length_cm
FROM gold.dim_products
WHERE (product_weight_g <= 0 OR product_length_cm <= 0)
  AND product_key <> -1;

-- ----------------------------------------------------------------------------
-- 4. REFERENTIAL INTEGRITY (PLACEHOLDER RECORD)
-- ----------------------------------------------------------------------------
-- Goal: Verify the '-1' row exists to handle orphaned Fact table records.
-- Expectation: 1 row returned.
-- ----------------------------------------------------------------------------
SELECT * FROM gold.dim_products 
WHERE product_key = -1;


/*********************************************************************************
                DATA QUALITY AUDIT: gold.dim_sellers
*********************************************************************************/

-- ----------------------------------------------------------------------------
-- 1. GRAIN INTEGRITY (DUPLICATE AUDIT)
-- ----------------------------------------------------------------------------
-- Goal: Ensure each Seller exists only once at the Gold Layer grain.
-- Expectation: 0 rows returned.
-- ----------------------------------------------------------------------------
SELECT 
    seller_id, 
    COUNT(*) AS occurrence_count
FROM gold.dim_sellers 
GROUP BY seller_id 
HAVING COUNT(*) > 1;

-- ----------------------------------------------------------------------------
-- 2. GEOSPATIAL BOUNDARY AUDIT (BRAZIL BOX)
-- ----------------------------------------------------------------------------
-- Goal: Detect coordinates that would appear outside the Brazilian landmass.
-- Expectation: 0 outliers (excluding the unknown placeholder).
-- ----------------------------------------------------------------------------
SELECT 
    seller_id, 
    seller_city, 
    latitude, 
    longitude
FROM gold.dim_sellers
WHERE (latitude NOT BETWEEN -35 AND 7 
   OR longitude NOT BETWEEN -75 AND -30)
  AND seller_key <> -1;

-- ----------------------------------------------------------------------------
-- 3. ATTRIBUTE COMPLETENESS AUDIT
-- ----------------------------------------------------------------------------
-- Goal: Identify raw NULLs that should have been handled in the Silver Layer.
-- Expectation: 0 rows (All missing values should be 'unknown' strings).
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(*) AS null_attributes
FROM gold.dim_sellers
WHERE (seller_city IS NULL OR seller_state IS NULL)
  AND seller_key <> -1;

-- ----------------------------------------------------------------------------
-- 4. REFERENTIAL INTEGRITY (PLACEHOLDER RECORD)
-- ----------------------------------------------------------------------------
-- Goal: Verify the '-1' row exists to allow for Fact table joins without data loss.
-- Expectation: 1 row returned.
-- ----------------------------------------------------------------------------
SELECT * FROM gold.dim_sellers 
WHERE seller_key = -1;

/*****************************************************************************
                DATA QUALITY AUDIT: gold.fact_payments
*****************************************************************************/

-- ----------------------------------------------------------------------------
-- 1. REFERENTIAL INTEGRITY (ORPHAN CHECK)
-- ----------------------------------------------------------------------------
-- Goal: Ensure every payment record is correctly mapped to a Gold Customer Key.
-- Expectation: 0 broken links.
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(*) AS broken_customer_links
FROM gold.fact_payments f
LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;

-- ----------------------------------------------------------------------------
-- 2. PAYMENT METHOD STANDARDIZATION
-- ----------------------------------------------------------------------------
-- Goal: Verify that payment methods are standardized (credit_card, boleto, etc).
-- Expectation: No NULLs or empty strings.
-- ----------------------------------------------------------------------------
SELECT 
    payment_type, 
    COUNT(*) AS transaction_count
FROM gold.fact_payments 
GROUP BY payment_type
ORDER BY transaction_count DESC;

-- ----------------------------------------------------------------------------
-- 3. INSTALLMENT REALITY CHECK
-- ----------------------------------------------------------------------------
-- Goal: Detect impossible data where installments are zero or negative.
-- Expectation: 0 rows.
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(*) AS zero_installment_rows
FROM gold.fact_payments
WHERE payment_installments < 1;


/************************************************************************
                DATA QUALITY AUDIT: gold.fact_reviews
************************************************************************/

-- ----------------------------------------------------------------------------
-- 1. SCORE & TEMPORAL INTEGRITY CHECK
-- ----------------------------------------------------------------------------
-- Goal: Ensure metrics fall within physical and logical boundaries.
-- Logic: Scores outside 1-5 or negative response times are data glitches.
-- Expectation: 0 rows.
-- ----------------------------------------------------------------------------
SELECT 
    'Invalid Metrics detected' AS issue_description,
    COUNT(*) AS fault_count
FROM gold.fact_reviews
WHERE (avg_review_score NOT BETWEEN 1 AND 5)
   OR (review_response_lag_days < 0);

-- ----------------------------------------------------------------------------
-- 2. STAR SCHEMA JOIN INTEGRITY (ORPHAN AUDIT)
-- ----------------------------------------------------------------------------
-- Goal: Count records mapped to the '-1' (Unknown) member.
-- Logic: High counts here indicate missing parent data in Dim_Orders/Customers.
-- Expectation: Low to Zero counts.
-- ----------------------------------------------------------------------------
SELECT 
    'Missing Order Links' AS link_type, 
    SUM(CASE WHEN order_key = -1 THEN 1 ELSE 0 END) AS unknown_count
FROM gold.fact_reviews

UNION ALL

SELECT 
    'Missing Customer Links', 
    SUM(CASE WHEN customer_key = -1 THEN 1 ELSE 0 END)
FROM gold.fact_reviews;

-- ----------------------------------------------------------------------------
-- 3. SENTIMENT CONFLICT AUDIT
-- ----------------------------------------------------------------------------
-- Goal: Identify orders where a customer left multiple, different scores.
-- Logic: Helps decide if the BI tool should take the MAX, MIN, or AVG score.
-- Expectation: Identifies edge cases for data modeling decisions.
-- ----------------------------------------------------------------------------
SELECT 
    order_key, 
    COUNT(DISTINCT avg_review_score) AS score_variance_count
FROM gold.fact_reviews
WHERE order_key <> -1
GROUP BY order_key
HAVING COUNT(DISTINCT avg_review_score) > 1;


/****************************************************************************
                DATA QUALITY AUDIT: gold.fact_sales
*****************************************************************************/

-- ----------------------------------------------------------------------------
-- 1. REFERENTIAL INTEGRITY (ORPHAN AUDIT)
-- ----------------------------------------------------------------------------
-- Goal: Detect "Orphan" sales that don't belong to a known product.
-- Expectation: 0 rows (Your -1 placeholder should handle unknown products).
-- ----------------------------------------------------------------------------
SELECT 
    'Orphaned Records Found' AS issue_description,
    COUNT(*) AS fault_count
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p 
    ON f.product_key = p.product_key
WHERE p.product_key IS NULL;

-- ----------------------------------------------------------------------------
-- 2. REVENUE GRAIN VALIDATION
-- ----------------------------------------------------------------------------
-- Goal: Ensure the transformation didn't add or lose order line items.
-- Expectation: Counts should be identical.
-- ----------------------------------------------------------------------------
SELECT 'Gold Fact Table' AS layer, COUNT(*) AS row_count FROM gold.fact_sales
UNION ALL
SELECT 'Silver Source Table', COUNT(*) FROM silver.order_items;

-- ----------------------------------------------------------------------------
-- 3. FINANCIAL ANOMALY DETECTION
-- ----------------------------------------------------------------------------
-- Goal: Identify "Impossible" financial records.
-- Expectation: 0 rows (Ensures revenue isn't under-reported).
-- ----------------------------------------------------------------------------
SELECT 
    order_key, 
    product_price, 
    freight_value
FROM gold.fact_sales
WHERE product_price <= 0 OR freight_value < 0;

-- ----------------------------------------------------------------------------
-- 4. JOIN FAN-OUT AUDIT (DUPLICATE DETECTION)
-- ----------------------------------------------------------------------------
-- Goal: Detect if a join (like with payments) caused row multiplication.
-- Expectation: extra_rows_detected = 0.
-- ----------------------------------------------------------------------------
WITH FactCounts AS (
    -- Count rows per order in your final Gold Fact table
    SELECT 
        order_key, 
        COUNT(*) AS fact_row_count
    FROM gold.fact_sales
    GROUP BY order_key
),
SourceCounts AS (
    -- Count rows per order in the original Silver items table
    SELECT 
        order_id, 
        COUNT(*) AS source_item_count
    FROM silver.order_items
    GROUP BY order_id
)
SELECT 
    f.order_key,
    f.fact_row_count,
    s.source_item_count,
    (f.fact_row_count - s.source_item_count) AS extra_rows_detected
FROM FactCounts f
JOIN SourceCounts s ON f.order_key = s.source_item_count
WHERE f.fact_row_count > s.source_item_count;


/*************************************************************************
                            END OF AUDIT
*************************************************************************/
