/*
===========================================================================
Stored Procedure: Load Sliver Layer (Bronze ---> Silver)
===========================================================================
Script Purpose:
  This stored procedure performs the ETL (Extract, Transform, and Load) process
  to populate the 'silver" schema tables from the 'bronze' schema.

Actions Performed:
  ---> Truncates the Silver tables.
  ---> Inserts transformed and cleansed data from 'bronze' tables into 'silver' tables.

Parameters:
  None.
  This stored procedure does not accept any parameters or return any values.

Usage Example:
  EXEC silver.load_silver;
============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '===============================================================';
        PRINT 'Loading Silver Layer';
        PRINT '===============================================================';

        SET @start_time = GETDATE();

        PRINT '---> Truncating Table: silver.customers_info';
        TRUNCATE TABLE silver.customers_info;

        PRINT 'Inserting Data Info: silver.customers_info';
        INSERT INTO silver.customers_info (
            customer_id, 
            customer_unique_id, 
            customer_zip_code_prefix, 
            customer_city, 
            customer_state)

        SELECT 
            TRIM(customer_id) AS customer_id,
            TRIM(customer_unique_id) AS customer_unique_id,
            CAST(TRIM(customer_zip_code_prefix) AS INT) AS customer_zip_code_prefix,
            silver.fn_cap_city_names (customer_city) AS customer_city,
            silver.fn_states_fullnames (customer_state) AS customer_state
        FROM bronze.olist_customers_dataset;

        SET @end_time = GETDATE();

        PRINT '---> Loading Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '---------------------------------------------------------------------------------';

        SET @start_time = GETDATE();

        PRINT '---> Truncating the table: silver.geolocation_info';
        TRUNCATE TABLE silver.geolocation_info;

        PRINT '---> Inserting Data Info: silver.geolocation_info';
        INSERT INTO silver.geolocation_info (
            geolocation_zip_code_prefix,
            geolocation_lat,
            geolocation_lng,
            geolocation_city,
            geolocation_state)

        SELECT  
            CAST(TRIM(geolocation_zip_code_prefix) AS INT) AS geolocation_zip_code_prefix,
            CAST(AVG(CAST(geolocation_lat AS DECIMAL(18,10))) AS DECIMAL(8,6)) AS geolocation_lat,
            CAST(AVG(CAST(geolocation_lng AS DECIMAL(18,10))) AS DECIMAL(9,6)) AS geolocation_lng,
            MAX(silver.fn_cap_city_names(geolocation_city)) AS geolocation_city,
            MAX(silver.fn_states_fullnames(geolocation_state)) AS geolocation_state
        FROM bronze.olist_geolocation_dataset
        GROUP BY geolocation_zip_code_prefix;

        SET @end_time = GETDATE();

        PRINT '---> Loading Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '-------------------------------------------------------------------------------------------------';

        SET @start_time = GETDATE();

        PRINT '--->Truncating Table: silver.order_items';
        TRUNCATE TABLE silver.order_items;

        PRINT '---> Inserting Data Info: silver.order_items';
        INSERT INTO silver.order_items (
	        order_id,
	        order_item_id,
	        product_id,
	        seller_id,
	        shipping_limit_date,
	        price,
	        freight_value)

        SELECT 
            TRIM(order_id) AS order_id,
            CAST(TRIM(order_item_id) AS INT) AS order_item_id,
            TRIM(product_id) AS product_id,
            TRIM(seller_id) AS seller_id,
            CAST(TRIM(shipping_limit_date) AS DATETIME2) AS shipping_limit_date,
            CAST(price AS DECIMAL(10,2)) AS price,
            CAST(freight_value AS DECIMAL(10,2)) AS freight_value
        FROM bronze.olist_order_items_dataset;

        SET @end_time = GETDATE();

        PRINT '---> Loading Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '------------------------------------------------------------------------------------------------'

        SET @start_time = GETDATE();

        PRINT '---> Truncating Table: silver_order_payments';
        TRUNCATE TABLE silver.order_payments;

        PRINT '---> Inserting Data Info: silver_order_payments';
        INSERT INTO silver.order_payments (
        order_id,
        payment_sequential,
        payment_type,
        payment_installments,
        payment_value)

        SELECT
        TRIM(order_id) AS order_id,
        CAST(payment_sequential AS INT) AS payment_sequential,
        CASE payment_type
	        WHEN 'credit_card' THEN 'Credit Card'
	        WHEN 'debit_card'  THEN 'Debit Card'
	        WHEN 'boleto'	   THEN 'Boleto'
	        WHEN 'vocher'      THEN 'Vocher'
	        ELSE 'Other'
	        END AS payment_type,
        CAST(payment_installments AS INT) AS payment_installments,
        CAST(payment_value AS DECIMAL(10,2)) AS payment_value
        FROM bronze.olist_order_payments_dataset;

        SET @end_time = GETDATE();

        PRINT '---> Loading Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '----------------------------------------------------------------------------------------------'

        SET @start_time = GETDATE();

        PRINT '---> Truncating Table: silver.order_reviews';
        TRUNCATE TABLE silver.order_reviews;

        PRINT '---> Inserting Data Info: silver.order_reviews';
        INSERT INTO silver.order_reviews (
	        review_id,
	        order_id,
	        review_score,
	        review_comment_title,
	        review_comment_message,
	        review_creation_date,
	        review_answer_timestamp)

        SELECT 
	        TRIM(review_id) AS review_id,
	        TRIM(order_id) AS order_id,
	        CAST(review_score AS INT) AS review_score,
	        ISNULL(review_comment_title, 'N/A') AS review_comment_title,
	        ISNULL(review_comment_message, 'N/A') AS review_comment_message,
	        CAST(review_creation_date AS DATETIME2) AS review_creation_date,
	        CAST(review_answer_timestamp AS DATETIME2) AS review_answer_timestamp
        FROM bronze.olist_order_reviews_dataset;

        SET @end_time = GETDATE();

        PRINT '---> Loading Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '-----------------------------------------------------------------------------------------------';

        SET @start_time = GETDATE();

        PRINT '---> Truncating Table: silver.orders_info';
        TRUNCATE TABLE silver.orders_info;

        PRINT '---> Inserting Data Info: silver.orders_info';
        INSERT INTO silver.orders_info (
	        order_id,
	        customer_id,
	        order_status,
	        order_purchase_timestamp,
	        order_approved_at,
	        order_delivered_carrier_date,
	        order_delivered_customer_date,
	        order_estimated_delivery_date)

        SELECT 
            TRIM(order_id) AS order_id,
            TRIM(customer_id) AS customer_id,
            UPPER(TRIM (order_status)) AS order_status,
            CAST(order_purchase_timestamp AS DATETIME2) AS order_purchase_timestamp,
            CAST(order_approved_at AS DATETIME2) AS order_approved_at,
            CAST(order_delivered_carrier_date AS DATETIME2) AS order_delivered_carrier_date,
            CAST(order_delivered_customer_date AS DATETIME2) AS order_delivered_customer_date,
            CAST(order_estimated_delivery_date AS DATETIME2) AS order_estimated_delivery_date
        FROM bronze.olist_orders_dataset;

        SET @end_time = GETDATE();

        PRINT '---> Loading Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '------------------------------------------------------------------------------------------------'

        SET @start_time = GETDATE();

        PRINT '---> Truncating Table: silver.product_category_name_translation';
        TRUNCATE TABLE silver.product_category_name_translation;

        PRINT '---> Inserting Data Info: silver.product_category_name_translation';
        INSERT INTO silver.product_category_name_translation (
	        product_category_name,
	        product_category_name_english)

        SELECT 
            TRIM(product_category_name) AS product_category_name,
            TRIM(product_category_name_english) AS product_category_name_english
        FROM bronze.product_category_name_translation;

        SET @end_time = GETDATE();

        PRINT '---> Loading Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '------------------------------------------------------------------------------------------------'

        IF NOT EXISTS (SELECT 1 FROM silver.product_category_name_translation WHERE product_category_name = 'outros')
        BEGIN
            INSERT INTO silver.product_category_name_translation (product_category_name, product_category_name_english)
            VALUES ('outros', 'others');
            PRINT '---> Added [outros] to translation dictionary';
        END

        SET @start_time = GETDATE();

        PRINT '---> Truncating Table: silver.products_info';
        TRUNCATE TABLE silver.products_info;

        PRINT '---> Inserting Data Info: silver.products_info';
        INSERT INTO silver.products_info (
	        product_id,
	        product_category_name,
	        product_name_length,
	        product_description_lenght,
	        product_photos_qty,
	        product_weight_g,
	        product_length_cm,
	        product_height_cm,
	        product_width_cm)

          SELECT 
            TRIM(B.product_id) AS product_id,
            ISNULL(T.product_category_name, 'outros') AS product_category_name,
            CAST(B.product_name_lenght AS INT),
            CAST(B.product_description_lenght AS INT),
            CAST(B.product_photos_qty AS INT),
            CAST(B.product_weight_g AS INT),
            CAST(B.product_length_cm AS INT),
            CAST(B.product_height_cm AS INT),
            CAST(B.product_width_cm AS INT)
        FROM bronze.olist_products_dataset B
        LEFT JOIN silver.product_category_name_translation T
            ON B.product_category_name = T.product_category_name;

        SET @end_time = GETDATE();

        PRINT '---> Loading Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '------------------------------------------------------------------------------------------------';

        SET @start_time = GETDATE();

        PRINT '---> Truncating Table: silver.sellers_info';
        TRUNCATE TABLE silver.sellers_info;

        PRINT '---> Inserting Data Info: silver.sellers_info';
        INSERT INTO silver.sellers_info (
	        seller_id,
	        seller_zip_code_prefix,
	        seller_city,
	        seller_state)

        SELECT 
	        TRIM(seller_id) AS seller_id,
	        CAST(seller_zip_code_prefix AS INT) AS seller_zip_code_prefix,
	        TRIM(silver.fn_cap_city_names(seller_city)) AS seller_city,
	        TRIM(silver.fn_states_fullnames(seller_state)) AS seller_state
        FROM bronze.olist_sellers_dataset;

        SET @end_time = GETDATE();

        PRINT '---> Loading Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
    END TRY
    BEGIN CATCH
        PRINT '===================================================================';
        PRINT 'Error Occured During The Loading Of Silver Layer';
        PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '==================================================================';
    END CATCH
END;


--  =================================================================================
--  EXEC silver.load_silver
--  =================================================================================
