/*
============================================================================================================
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
============================================================================================================
*/

--  =================================================================================================
--  gold.dim_customers Quality Checks
--  =================================================================================================

--  Purpose: This quality check is to know any duplicate IDs in the dim_customers.
--  Expectation: Row_Count = 0.

SELECT 'Latitude Out of Range' as Issue, COUNT(*) as Row_Count 
FROM gold.dim_customers 
WHERE latitude NOT BETWEEN -90 AND 90
  
UNION ALL
  
SELECT 'Longitude Out of Range', COUNT(*) 
FROM gold.dim_customers 
WHERE longitude NOT BETWEEN -180 AND 180
  
UNION ALL
  
SELECT 'Duplicate Unique IDs', COUNT(*) 
FROM (
  SELECT customer_unique_id 
  FROM gold.dim_customers 
  GROUP BY customer_unique_id 
  HAVING COUNT(*) > 1) t
UNION ALL
  
SELECT 'Null State Codes', COUNT(*) 
FROM gold.dim_customers 
WHERE state_code IS NULL;

----------------------------------------------------------------------------------------

--  Purpose: This quality check is to ensure there are any null values in the city, state, unique_ids.
--  Expectation: Row_count = 0.

SELECT 
    'Null City' AS Issue, COUNT(*) AS Row_Count 
FROM gold.dim_customers
WHERE customer_city IS NULL
  
UNION ALL
  
SELECT 'Null State Name', COUNT(*) 
FROM gold.dim_customers 
WHERE customer_state IS NULL
  
UNION ALL
  
SELECT 'Null Unique ID', COUNT(*) 
FROM gold.dim_customers
WHERE customer_unique_id IS NULL;

----------------------------------------------------------------------------------------------

--  Purpose: This quality check is to ensure there are any data normalization errors in the city names.
--  Expectation: No results

SELECT customer_city, COUNT(*) 
FROM gold.dim_customers 
GROUP BY customer_city 
HAVING COUNT(DISTINCT LOWER(customer_city)) > 1;

-------------------------------------------------------------------------------------------------

--  Purpose: This quality check is to ensure that every zip code is tagged to its state, city
--  Expectation: No results

SELECT customer_zipcode, COUNT(DISTINCT state_code) as state_count
FROM gold.dim_customers
GROUP BY customer_zipcode
HAVING COUNT(DISTINCT state_code) > 1;

---------------------------------------------------------------------------------------------------
--  Purpose: This quality check is to ensure that all the coordinates makes perfect sense according to the Brazil
--  Expectation: Coordinates Outside Brazil = 0

SELECT 'Coordinates Outside Brazil' AS Issue, COUNT(*) 
FROM gold.dim_customers 
WHERE latitude > 6 OR latitude < -35 
   OR longitude > -30 OR longitude < -75;

--  =================================================================================================
--  gold.dim_date Quality Checks
--  =================================================================================================

--  Purpose: To check any gap in the timeline
--  Expectation: Missing_Days = 0

SELECT 'Gap in Timeline' AS Issue, 
       (DATEDIFF(day, MIN(date_id), MAX(date_id)) + 1) - COUNT(*) AS Missing_Days 
FROM gold.dim_date

UNION ALL

SELECT 'Invalid Weekend Flag', COUNT(*) 
FROM gold.dim_date 
WHERE (day_name IN ('Saturday', 'Sunday') AND is_weekend = 0)
   OR (day_name NOT IN ('Saturday', 'Sunday') AND is_weekend = 1)

UNION ALL

SELECT 'Quarter Mismatch', COUNT(*) 
FROM gold.dim_date 
WHERE (month_number BETWEEN 1 AND 3 AND quarter_number <> 1)
   OR (month_number BETWEEN 4 AND 6 AND quarter_number <> 2)
   OR (month_number BETWEEN 7 AND 9 AND quarter_number <> 3)
   OR (month_number BETWEEN 10 AND 12 AND quarter_number <> 4);

--  =================================================================================================
--  gold.dim_orders Quality Checks
--  =================================================================================================

--  Purpose: To check if there are any dates where the actual delivery dates are less than zero, any missmatches between
--           the dates, any status is marked and the delivery date is not null, any amounts which are zero
--  Expectation: Row_count = 0, except if any values in the zero total amount (may be consider as discount or free samples)


SELECT 'Negative Delivery Time' AS Issue, COUNT(*) AS Row_Count 
FROM gold.dim_orders 
WHERE actual_delivered_days < 0

UNION ALL

SELECT 'SLA Flag Mismatch', COUNT(*) 
FROM gold.dim_orders 
WHERE late_delivery = 1 AND delivered_date <= delivery_estimated_date

UNION ALL

SELECT 'Inconsistent Delivery Status', COUNT(*) 
FROM gold.dim_orders 
WHERE order_status = 'delivered' AND delivered_date IS NULL

UNION ALL

SELECT 'Zero Total Amount', COUNT(*) 
FROM gold.dim_orders 
WHERE total_amount_paid <= 0;

--  =================================================================================================
--  gold.fact_payments Quality Checks
--  =================================================================================================

--  Purpose: To check whether theses valuse exist in the fact table or not
--  Expectation: Row_Count = 0

SELECT 'Orphaned Product' AS Issue, COUNT(*) AS Row_Count 
FROM gold.fact_sales fs 
LEFT JOIN gold.dim_products dp ON fs.product_key = dp.product_key 
WHERE dp.product_key IS NULL

UNION ALL

SELECT 'Orphaned Seller', COUNT(*) 
FROM gold.fact_sales fs 
LEFT JOIN gold.dim_sellers ds ON fs.seller_key = ds.seller_key 
WHERE ds.seller_key IS NULL

UNION ALL

-- Critical Math Check: Price + Freight must = Total
SELECT 'Math Discrepancy', COUNT(*) 
FROM gold.fact_sales 
WHERE ABS((price + freight_value) - total_value) > 0.01

UNION ALL

SELECT 'Zero Price Items', COUNT(*) 
FROM gold.fact_sales 
WHERE price = 0;

--  =================================================================================================
--  gold.fact_reviews Quality Checks
--  =================================================================================================

--  Purpose: To check these values exist in the data set or not
--  Expectation: Row_Count = 0

-- Check for Orphaned Reviews (No matching order)
SELECT 'Orphaned Reviews' AS Issue, COUNT(*) AS Row_Count 
FROM gold.fact_reviews fr
LEFT JOIN gold.dim_orders o ON fr.order_key = o.order_key
WHERE o.order_key IS NULL

UNION ALL

-- Check for Scores Outside the 1-5 Range
SELECT 'Invalid Review Score', COUNT(*) 
FROM gold.fact_reviews 
WHERE review_score < 1 OR review_score > 5

UNION ALL

-- Check for Timeline Paradoxes
SELECT 'Response Before Request', COUNT(*) 
FROM gold.fact_reviews 
WHERE review_answer_timestamp < date_id

UNION ALL

-- Check for Missing Dates
SELECT 'Missing Creation Date', COUNT(*) 
FROM gold.fact_reviews 
WHERE date_id IS NULL;

--  =================================================================================================
--  gold.fact_sales Quality Checks
--  =================================================================================================

-- 1. Check for Orphaned Keys (The Linkage Audit)
SELECT 'Orphaned Product' AS Issue, COUNT(*) AS Row_Count 
FROM gold.fact_sales fs 
LEFT JOIN gold.dim_products dp ON fs.product_key = dp.product_key 
WHERE dp.product_key IS NULL

UNION ALL

SELECT 'Orphaned Seller', COUNT(*) 
FROM gold.fact_sales fs 
LEFT JOIN gold.dim_sellers ds ON fs.seller_key = ds.seller_key 
WHERE ds.seller_key IS NULL

UNION ALL

-- 2. Check for Math Discrepancies (The Penny Check)
-- We use a small epsilon (0.001) to account for float precision
SELECT 'Financial Math Error', COUNT(*) 
FROM gold.fact_sales 
WHERE ABS((price + freight_value) - total_value) > 0.001

UNION ALL

-- 3. Check for Negative Values (The Reality Check)
SELECT 'Negative Price or Freight', COUNT(*) 
FROM gold.fact_sales 
WHERE price < 0 OR freight_value < 0

UNION ALL

-- 4. Check for Broken Sequences
-- Every order should have a sequence starting at 1
SELECT 'Invalid Order Sequence', COUNT(*) 
FROM (
    SELECT order_key, MIN(order_sequence_no) as start_seq 
    FROM gold.fact_sales 
    GROUP BY order_key
) t WHERE start_seq <> 1;
