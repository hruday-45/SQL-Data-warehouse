/*
Notice: Before using this whole query, I request you to first execute the 
		city_name_normalization_function.sql and then proceed with this query.
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
            customer_zip_code_prefix,
            TRIM(silver.fn_CleanSilverEncoding(customer_city)) AS customer_city,
            TRIM(customer_state)
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
            geolocation_zip_code_prefix,
            CAST(AVG(geolocation_lat) AS DECIMAL(9,6)) AS geolocation_lat,
            CAST(AVG(geolocation_lng) AS DECIMAL(9,6)) AS geolocation_lng,
            MIN(TRIM(silver.fn_CleanSilverEncoding(geolocation_city))) AS geolocation_city,
            MAX(geolocation_state) AS geolocation_state
        FROM bronze.olist_geolocation_dataset
        WHERE (geolocation_lat BETWEEN -34 AND 6) 
          AND (geolocation_lng BETWEEN -74 AND -34)
        GROUP BY geolocation_zip_code_prefix;

        SET @end_time = GETDATE();

        PRINT '---> Loading Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '-------------------------------------------------------------------------------------------------';

        SET @start_time = GETDATE();

        PRINT '---> Truncating Table: silver.order_items';
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
            order_item_id,
            TRIM(product_id) AS product_id,
            TRIM(seller_id) AS seller_id,
            shipping_limit_date,
            price,
            freight_value
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
        payment_sequential,
        CASE TRIM(payment_type)
	        WHEN 'credit_card' THEN 'Credit Card'
	        WHEN 'debit_card'  THEN 'Debit Card'
	        WHEN 'boleto'	   THEN 'Boleto'
	        WHEN 'voucher'      THEN 'Voucher'
	        ELSE 'Other'
	        END AS payment_type,
        payment_installments,
        payment_value
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
	        review_score,
	        ISNULL(review_comment_title, 'N/A') AS review_comment_title,
	        ISNULL(review_comment_message, 'N/A') AS review_comment_message,
	        review_creation_date,
	        review_answer_timestamp
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
            order_purchase_timestamp,
            order_approved_at,
            order_delivered_carrier_date,
            order_delivered_customer_date,
            order_estimated_delivery_date
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

        SET @start_time = GETDATE();

        PRINT '---> Truncating Table: silver.products_info';
        TRUNCATE TABLE silver.products_info;

        PRINT '---> Inserting Data Info: silver.products_info';

        --  For this table I'm using the CTE method to enrich the data
        --  Calculating median weight per category from bronze source
        WITH MedianCalculations AS (
            SELECT 
                product_category_name,
                PERCENTILE_CONT(0.5) 
                    WITHIN GROUP (ORDER BY product_weight_g)
                    OVER (PARTITION BY product_category_name) AS median_weight
            FROM bronze.olist_products_dataset
            WHERE product_weight_g > 0
              AND product_category_name IS NOT NULL),

        -- Considering only distinct median values per category
        CategoryMedians AS (
            SELECT DISTINCT
                product_category_name,
                median_weight
            FROM MedianCalculations)

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
            TRIM(bp.product_id),
            ISNULL(TRIM(bp.product_category_name), 'outros'),
            bp.product_name_lenght,
            bp.product_description_lenght,
            bp.product_photos_qty,

            -- If weight is 0 or NULL, I'm use the median; otherwise, keep the original
            CAST(CASE WHEN bp.product_weight_g IS NULL OR bp.product_weight_g = 0
                      THEN cm.median_weight
                       ELSE bp.product_weight_g
                END AS INT) AS product_weight_g,
            bp.product_length_cm,
            bp.product_height_cm,
            bp.product_width_cm
        FROM bronze.olist_products_dataset bp
        LEFT JOIN CategoryMedians cm
            ON TRIM(bp.product_category_name) = TRIM(cm.product_category_name);

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
	        seller_zip_code_prefix,
	        TRIM(silver.fn_CleanSilverEncoding(seller_city)) AS seller_city,
	        TRIM(seller_state) AS seller_state
        FROM bronze.olist_sellers_dataset;

        SET @end_time = GETDATE();

        PRINT '---> Loading Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '-------------------------------------------------------------------------------------------------';
        SET @start_time = GETDATE();

        PRINT '---> Truncating the table: silver.state_centers';
        TRUNCATE TABLE silver.state_centers;

        PRINT '---> Inserting Data Info: silver.state_centers';
        INSERT INTO silver.state_centers(
               state_code, 
               state_name,
               region_name,
               avg_lat, 
               avg_lng)

        VALUES 
            ('AC', 'Acre', 'North', -9.0238, -70.8120),
            ('AL', 'Alagoas', 'Northeast', -9.5713, -36.7820),
            ('AM', 'Amazonas', 'North', -3.4168, -65.8561),
            ('AP', 'Amapá', 'North', 1.4154, -51.7711),
            ('BA', 'Bahia', 'Northeast', -12.5127, -41.7007),
            ('CE', 'Ceará', 'Northeast', -5.2000, -39.5000),
            ('DF', 'Distrito Federal', 'Midwest', -15.7998, -47.8645),
            ('ES', 'Espírito Santo', 'Southeast', -19.1834, -40.3089),
            ('GO', 'Goiás', 'Midwest', -15.8270, -49.8362),
            ('MA', 'Maranhão', 'Northeast', -5.4200, -45.4400),
            ('MG', 'Minas Gerais', 'Southeast', -18.5122, -44.5550),
            ('MS', 'Mato Grosso do Sul', 'Midwest', -20.7722, -54.7852),
            ('MT', 'Mato Grosso', 'Midwest', -12.6819, -56.9211),
            ('PA', 'Pará', 'North', -3.7922, -52.4818),
            ('PB', 'Paraíba', 'Northeast', -7.2400, -36.7800),
            ('PE', 'Pernambuco', 'Northeast', -8.2833, -37.9833),
            ('PI', 'Piauí', 'Northeast', -7.7183, -42.7289),
            ('PR', 'Paraná', 'South', -24.8923, -51.5597),
            ('RJ', 'Rio de Janeiro', 'Southeast', -22.4474, -42.9912),
            ('RN', 'Rio Grande do Norte', 'Northeast', -5.4026, -36.9541),
            ('RO', 'Rondônia', 'North', -10.8300, -63.3400),
            ('RR', 'Roraima', 'North', 2.1351, -61.3231),
            ('RS', 'Rio Grande do Sul', 'South', -30.0019, -53.7611),
            ('SC', 'Santa Catarina', 'South', -27.2423, -50.2189),
            ('SE', 'Sergipe', 'Northeast', -10.5741, -37.3857),
            ('SP', 'São Paulo', 'Southeast', -23.5505, -46.6333),
            ('TO', 'Tocantins', 'North', -10.1753, -48.2982);

        SET @end_time = GETDATE();

        PRINT '---> Loading Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '-------------------------------------------------------------------------------------------------';
    END TRY
    BEGIN CATCH
        PRINT '===================================================================';
        PRINT 'Error Occured During The Loading Of Silver Layer';
        PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '==================================================================';
    END CATCH
END;
