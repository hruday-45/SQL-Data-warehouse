/*****************************************************************************
===========================================================================
Stored Procedure: Load Gold Layer (Silver ---> Gold)
===========================================================================
Script Purpose:
  This stored procedure performs the ETL (Extract, Transform, and Load) process
  to populate the 'gold" schema tables from the 'silver' schema.

Actions Performed:
  ---> Deletes the Gold tables instead of truncating to avoid FK constraints issues.
  ---> Creates Dimension and Fact Tables which can be directly used for business reporting.

Usage Example:
  EXEC gold.load_gold;
*****************************************************************************/

CREATE OR ALTER PROCEDURE gold.load_gold
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME, @rows INT;
	BEGIN TRY
	BEGIN TRAN;
		SET @batch_start_time = GETDATE();
		PRINT '============================================================';
		PRINT 'Loading Gold Layer';
		PRINT '============================================================';

		PRINT '---> Deleting Existing Data from Gold Fact Tables';
		DELETE FROM gold.fact_sales;
		DBCC CHECKIDENT ('gold.fact_sales', RESEED, 0) WITH NO_INFOMSGS;
		DELETE FROM gold.fact_payments;
		DBCC CHECKIDENT ('gold.fact_payments', RESEED, 0) WITH NO_INFOMSGS;
		DELETE FROM gold.fact_reviews;
		DBCC CHECKIDENT ('gold.fact_reviews', RESEED, 0) WITH NO_INFOMSGS;

		PRINT '---> Deleting Existing Data from Gold Dimension Tables';
		DELETE FROM gold.dim_customers;
		DELETE FROM gold.dim_sellers;
		DELETE FROM gold.dim_products;
		DELETE FROM gold.dim_orders;
		DELETE FROM gold.dim_date;
		DELETE FROM gold.dim_location;

		PRINT '------------------------------------------------------------';

		--------------------------------------------------------------------
		-- Dim Customers
		--------------------------------------------------------------------
		SET @start_time = GETDATE();
		PRINT '---> Inserting Data Into: gold.dim_customers';

		WITH
		customer_orders
		AS
		(
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

		DimensionBase
		AS
		(
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
				CASE WHEN co.total_orders > 1 THEN 1 ELSE 0 END AS is_repeat_customer,
				DATEDIFF(DAY, co.first_order_date, co.last_order_date) AS customer_tenure_days
			FROM silver.customers_info c
				LEFT JOIN customer_orders co ON c.customer_unique_id = co.customer_unique_id
				LEFT JOIN silver.geolocation_info g ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
		)

	INSERT INTO gold.dim_customers
		(
		customer_key,
		customer_id,
		customer_unique_id,
		customer_city,
		customer_state,
		customer_zip_code_prefix,
		latitude,
		longitude,
		first_order_date,
		last_order_date,
		total_orders,
		is_repeat_customer,
		customer_tenure_days)

	-- Combining Real Customers with the Placeholder Row
			SELECT *
		FROM DimensionBase

	UNION ALL

		SELECT
			-1, 'UNKNOWN', 'UNKNOWN', 'unknown', 'NA', '0', NULL, NULL, NULL, NULL, 0, 0, 0;

		SELECT @rows = COUNT(*)
	FROM gold.dim_customers;
		PRINT '---> Rows in gold.dim_customers: ' + CAST(@rows AS NVARCHAR);

		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '------------------------------------------------------------';

	    --------------------------------------------------------------------
		-- Dim Sellers
		--------------------------------------------------------------------
		SET @start_time = GETDATE();
		PRINT '---> Inserting Data Into: gold.dim_sellers';

		WITH
		SellerBase
		AS
		(
			-- Primary business logic for actual sellers
			SELECT
				CAST(ROW_NUMBER() OVER(ORDER BY s.seller_id) AS INT) AS seller_key, -- surrogate key
				s.seller_id, -- Natural business key
				s.seller_city,
				s.seller_state,
				s.seller_zip_code_prefix,
				gi.geolocation_lat AS latitude,
				gi.geolocation_lng AS longitude
			FROM silver.sellers_info s
				LEFT JOIN silver.geolocation_info gi
				ON s.seller_zip_code_prefix = gi.geolocation_zip_code_prefix
		)

	INSERT INTO gold.dim_sellers
		(
		seller_key,
		seller_id,
		seller_city,
		seller_state,
		seller_zip_code_prefix,
		latitude,
		longitude)

			SELECT *
		FROM SellerBase
	UNION ALL
		SELECT
			-1, 'UNKNOWN', 'unknown', 'NA', '0', NULL, NULL;

		SELECT @rows = COUNT(*)
	FROM gold.dim_sellers;
		PRINT '---> Rows in gold.dim_sellers: ' + CAST(@rows AS NVARCHAR);

		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '------------------------------------------------------------';

		--------------------------------------------------------------------
		-- Dim Products
		--------------------------------------------------------------------
		SET @start_time = GETDATE();
		PRINT '---> Inserting Data Into: gold.dim_products';

		WITH
		ProductBase
		AS

		(
			SELECT
				CAST(ROW_NUMBER() OVER(ORDER BY p.product_id) AS INT) AS product_key, -- surrogate key
				p.product_id, -- Natural business key

				-- Handling names with are not present in the translation table
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

	INSERT INTO gold.dim_products
		(
		product_key,
		product_id,
		product_category_name,
		product_category_name_english,
		product_weight_g,
		product_length_cm,
		product_height_cm,
		product_width_cm,
		product_volume_cm3)

			SELECT *
		FROM ProductBase
	UNION ALL
		SELECT
			-1, 'UNKNOWN', 'unknown', 'unknown', 0, 0, 0, 0, 0;

		SELECT @rows = COUNT(*)
	FROM gold.dim_products;
		PRINT '---> Rows in gold.dim_products: ' + CAST(@rows AS NVARCHAR);

		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '------------------------------------------------------------';

		--------------------------------------------------------------------
		-- Dim Orders
		--------------------------------------------------------------------
		SET @start_time = GETDATE();
		PRINT '---> Inserting Data Into: gold.dim_orders';

		WITH
		OrdersBase
		AS

		(
			SELECT
				CAST(ROW_NUMBER() OVER(ORDER BY order_id) AS INT) AS order_key, -- surrogate key
				order_id, -- The natural business key
				customer_id, -- The natural business key
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
			FROM silver.orders_info
		)

	INSERT INTO gold.dim_orders
		(
		order_key,
		order_id,
		customer_id,
		order_status,
		order_purchase_timestamp,
		order_approved_at,
		order_delivered_carrier_date,
		order_delivered_customer_date,
		order_estimated_delivery_date,
		delivery_performance_status)
			SELECT *
		FROM OrdersBase

	UNION

		SELECT
			-1, 'UNKNOWN', 'UNKNOWN', 'unknown', NULL, NULL, NULL, NULL, NULL, 'unknown';

		SELECT @rows = COUNT(*)
	FROM gold.dim_orders;
		PRINT '---> Rows in gold.dim_orders: ' + CAST(@rows AS NVARCHAR);

		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '------------------------------------------------------------';

		--------------------------------------------------------------------
		-- Dim Date
		--------------------------------------------------------------------
		SET @start_time = GETDATE();
		PRINT '---> Inserting Data Into: gold.dim_date';

		WITH
		Numbers
		AS
		(
			SELECT TOP (1100)
				-- Selecting no of day for this business data period
				ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
			FROM sys.all_objects
		),
		DateSeries
		AS
		(
			SELECT DATEADD(DAY, n, CAST('2016-01-01' AS DATE)) AS d
			FROM Numbers
			WHERE DATEADD(DAY, n, CAST('2016-01-01' AS DATE)) <= '2018-12-31'
		)

	INSERT INTO gold.dim_date
		(
		date_key,
		date,
		day,
		week,
		month,
		month_name,
		quarter,
		year,
		is_weekend,
		is_holiday_brazil_flag)

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
        WHEN (MONTH(d) = 1 AND DAY(d) = 1)
			OR (MONTH(d) = 4 AND DAY(d) = 21)
			OR (MONTH(d) = 5 AND DAY(d) = 1)
			OR (MONTH(d) = 9 AND DAY(d) = 7)
			OR (MONTH(d) = 10 AND DAY(d) = 12)
			OR (MONTH(d) = 11 AND DAY(d) = 2)
			OR (MONTH(d) = 11 AND DAY(d) = 15)
			OR (MONTH(d) = 12 AND DAY(d) = 25)
        THEN 1 ELSE 0
    END AS is_holiday_brazil_flag
	FROM DateSeries;

		SELECT @rows = COUNT(*)
	FROM gold.dim_date;
		PRINT '---> Rows in gold.dim_date: ' + CAST(@rows AS NVARCHAR);

		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '------------------------------------------------------------';

		--------------------------------------------------------------------
		-- Dim Location
		--------------------------------------------------------------------
		SET @start_time = GETDATE();
		PRINT '---> Inserting Data Into: gold.dim_location';

		WITH
		CleanedGeolocation
		AS
		(
			SELECT
				geo.geolocation_zip_code_prefix AS location_key, -- Surrogate Key
				geo.geolocation_zip_code_prefix,
				geo.geolocation_city AS city,
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
			GROUP BY geo.geolocation_zip_code_prefix, geo.geolocation_city, geo.geolocation_state, sc.avg_lat, sc.avg_lng, sc.state_name, sc.region_name
		)

	INSERT INTO gold.dim_location
		(
		location_key,
		geolocation_zip_code_prefix,
		city,
		state_code,
		state_name,
		region_name,
		latitude,
		longitude)

	--  combining real data with a placeholder for unknown locations
			SELECT *
		FROM CleanedGeolocation
	UNION ALL
		SELECT
			-1, '0', 'unknown', 'NA', 'Unknown', 'Unknown', NULL, NULL;

		SELECT @rows = COUNT(*)
	FROM gold.dim_location;
		PRINT '---> Rows in gold.dim_location: ' + CAST(@rows AS NVARCHAR);

		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '------------------------------------------------------------';

		--------------------------------------------------------------------
		-- Fact Sales
		--------------------------------------------------------------------
		SET @start_time = GETDATE();
		PRINT '---> Inserting Data Into: gold.fact_sales';

		WITH
		SalesBase
		AS
		(
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
				SUM(oi.price) OVER(PARTITION BY oi.order_id) AS total_order_price
			FROM silver.order_items oi
				JOIN silver.orders_info o ON oi.order_id = o.order_id
		)
	INSERT INTO gold.fact_sales
		(
		order_key,
		customer_key,
		seller_key,
		product_key,
		product_price,
		freight_value,
		total_product_value,
		order_status,
		order_purchase_timestamp,
		order_approved_at,
		order_delivered_carrier_date,
		order_delivered_customer_date,
		total_delivery_days,
		seller_processing_days,
		carrier_transit_days,
		delivery_delay_days,
		is_shipped_flag,
		is_delivered_flag,
		is_late_delivery_flag)

	SELECT
		-- 1. Surrogate Keys from Dimensions
		-- We join to Gold to get the INT keys and use COALESCE for the -1 placeholder
		CAST(ISNULL(do.order_key, -1) AS INT) AS order_key,
		CAST(ISNULL(dc.customer_key, -1) AS INT) AS customer_key,
		CAST(ISNULL(ds.seller_key, -1) AS INT) AS seller_key,
		CAST(ISNULL(dp.product_key, -1) AS INT) AS product_key,

		-- 2. Original Product Price
		sb.product_price,

		-- 3. Distributed Freight (splitting the order-level freight)
		CASE 
        WHEN sb.total_order_price = 0 THEN 0 
        ELSE (sb.product_price / sb.total_order_price) * sb.freight_value
    END AS allocated_freight,

		-- 4. Total Product Value (Price + Allocated Freight)
		sb.product_price + (
        CASE 
            WHEN sb.total_order_price = 0 THEN 0 
            ELSE (sb.product_price / sb.total_order_price) * sb.freight_value
        END
    ) AS total_product_value,

		-- 5. order_status
		sb.order_status,

		-- 6. Date Keys (Formatted as YYYYMMDD)
		CAST(sb.order_purchase_timestamp AS DATE) AS order_purchase_timestamp,
		CAST(sb.order_approved_at AS DATE) AS order_approved_at,
		CAST(sb.order_delivered_carrier_date AS DATE) AS order_delivered_carrier_date,
		CAST(sb.order_delivered_customer_date AS DATE) AS order_delivered_customer_date,

		-- 7. Calculated Logistics
		DATEDIFF(DAY, sb.order_purchase_timestamp, sb.order_delivered_customer_date) AS total_delivery_days,
		DATEDIFF(DAY, sb.order_purchase_timestamp, sb.order_delivered_carrier_date) AS seller_processing_days,
		DATEDIFF(DAY, sb.order_delivered_carrier_date, sb.order_delivered_customer_date) AS carrier_transit_days,

		-- 8. Flags
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
		LEFT JOIN gold.dim_orders do ON sb.order_id = do.order_id
		LEFT JOIN gold.dim_customers dc ON sb.customer_id = dc.customer_id
		LEFT JOIN gold.dim_sellers ds ON sb.seller_id = ds.seller_id
		LEFT JOIN gold.dim_products dp ON sb.product_id = dp.product_id;

		SELECT @rows = COUNT(*)
	FROM gold.fact_sales;
		PRINT '---> Rows in gold.fact_sales: ' + CAST(@rows AS NVARCHAR);

		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '------------------------------------------------------------';

		--------------------------------------------------------------------
		-- Fact Payments
		--------------------------------------------------------------------
		SET @start_time = GETDATE();
		PRINT '---> Inserting Data Into: gold.fact_payments';

		INSERT INTO gold.fact_payments
		(
		order_key,
		customer_key,
		order_approved_at,
		payment_value,
		payment_installments,
		payment_type)

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

		SELECT @rows = COUNT(*)
	FROM gold.fact_payments;
		PRINT '---> Rows in gold.fact_payments: ' + CAST(@rows AS NVARCHAR);

		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '------------------------------------------------------------';

		--------------------------------------------------------------------
		-- Fact reviews
		--------------------------------------------------------------------
		SET @start_time = GETDATE();
		PRINT '---> Inserting Data Into: gold.fact_reviews';
		
	WITH
		AggregatedReviews
		AS
		(
			SELECT
				order_id,
				AVG(CAST(review_score AS DECIMAL(3,2))) AS avg_review_score, -- Average if they left multiple
				MAX(review_creation_date) AS latest_review_date,
				MAX(review_answer_timestamp) AS latest_answer_timestamp
			FROM silver.order_reviews
			GROUP BY order_id
		)

	INSERT INTO gold.fact_reviews
		(
		order_key,
		customer_key,
		review_date,
		avg_review_score,
		latest_review_date,
		latest_answer_timestamp,
		review_response_lag_days)

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

		SELECT @rows = COUNT(*)
	FROM gold.fact_reviews;
		PRINT '---> Rows in gold.fact_reviews: ' + CAST(@rows AS NVARCHAR);

		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '------------------------------------------------------------';

		COMMIT;
		SET @batch_end_time = GETDATE();
		PRINT '---> Gold Layer Loaded Successfully';
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds';
END TRY
BEGIN CATCH
	ROLLBACK;
	PRINT '============================================================';
	PRINT 'Error Occurred During Gold Layer Loading';
	PRINT 'Error Info; ' + ERROR_MESSAGE();
	PRINT '============================================================';
END CATCH
END;