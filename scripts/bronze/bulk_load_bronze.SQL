/*
===================================================================================
Stored Procedure: Load Bronze Layer (Source ----> Bronze)
===================================================================================
Script Purpose:
    This script loads the data from external csv files into the 'bronze' schema.
    It performs the following actions:
      - Truncates the bronze tables before loading data.
      - Uses the 'BULK INSERT' command to load data from csv files to bronze tables.

Parameters:
    None. (This stored procedure does not accept any parameters or return any values).

Usage Example:
    EXEC bronze.load_bronze;
=======================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '==========================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '==========================================================';

		SET @start_time = GETDATE();
		PRINT '---> Truncating Table: bronze.csv_customers_info';
		TRUNCATE TABLE bronze.csv_customers_info;

		PRINT '---> Inserting Data Info: bronze.csv_customers_info';
		BULK INSERT bronze.csv_customers_info
		FROM 'C:\SQL project\Client Data Sheet\customers_info.csv'
		WITH (
			FIRSTROW		= 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		= '"',
			ROWTERMINATOR	= '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '---> Truncating Table: bronze.csv_geolocation_info';
		TRUNCATE TABLE bronze.csv_geolocation_info;

		PRINT '---> Inserting Data Info: bronze.csv_geolocation_info';
		BULK INSERT bronze.csv_geolocation_info
		FROM 'C:\SQL project\Client Data Sheet\geolocation_info.csv'
		WITH (
			FIRSTROW		= 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		= '"',
			ROWTERMINATOR	= '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '---> Truncating Table: bronze.csv_order_items';
		TRUNCATE TABLE bronze.csv_order_items;

		PRINT '---> Inserting Data Info: bronze.csv_order_items';
		BULK INSERT bronze.csv_order_items
		FROM 'C:\SQL project\Client Data Sheet\order_items.csv'
		WITH (
			FIRSTROW		= 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		= '"',
			ROWTERMINATOR	= '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '---> Truncating Table: bronze.csv_order_payments';
		TRUNCATE TABLE bronze.csv_order_payments;

		PRINT '---> Inserting Data Info: bronze.csv_order_payments';
		BULK INSERT bronze.csv_order_payments
		FROM 'C:\SQL project\Client Data Sheet\order_payments.csv'
		WITH (
			FIRSTROW		= 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		= '"',
			ROWTERMINATOR	= '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '---> Truncating Table: bronze.csv_order_reviews';
		TRUNCATE TABLE bronze.csv_order_reviews;

		PRINT '---> Inserting Data Info: bronze.csv_order_reviews';
		BULK INSERT bronze.csv_order_reviews
		FROM 'C:\SQL project\Client Data Sheet\order_reviews.csv'
		WITH (
			FIRSTROW		= 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		= '"',
			ROWTERMINATOR	= '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '---> Truncating Table: bronze.csv_orders_info';
		TRUNCATE TABLE bronze.csv_orders_info;

		PRINT '---> Inserting Data Info: bronze.csv_orders_info';
		BULK INSERT bronze.csv_orders_info
		FROM 'C:\SQL project\Client Data Sheet\orders_info.csv'
		WITH (
			FIRSTROW		= 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		= '"',
			ROWTERMINATOR	= '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '---> Truncating Table: bronze.csv_products_info';
		TRUNCATE TABLE bronze.csv_products_info;

		PRINT '---> Inserting Data Info: bronze.csv_products_info';
		BULK INSERT bronze.csv_products_info
		FROM 'C:\SQL project\Client Data Sheet\products_info.csv'
		WITH (
			FIRSTROW		= 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		= '"',
			ROWTERMINATOR	= '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '---> Truncating Table: bronze.csv_sellers_info';
		TRUNCATE TABLE bronze.csv_sellers_info;

		PRINT '---> Inserting Data Info:bronze.csv_sellers_info';
		BULK INSERT bronze.csv_sellers_info
		FROM 'C:\SQL project\Client Data Sheet\sellers_info.csv'
		WITH (
			FIRSTROW		= 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		= '"',
			ROWTERMINATOR	= '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '---> Truncating Table: bronze.csv_product_category_name_translation';
		TRUNCATE TABLE bronze.csv_product_category_name_translation;

		PRINT '---> Inserting Data Info: bronze.csv_product_category_name_translation';
		BULK INSERT bronze.csv_product_category_name_translation
		FROM 'C:\SQL project\Client Data Sheet\product_category_name_translation.csv'
		WITH (
			FIRSTROW		= 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		= '"',
			ROWTERMINATOR	= '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------'

		SET @batch_end_time = GETDATE();
		PRINT '---> Loading Bronze Layer is completed';
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds';
	END TRY
	BEGIN CATCH
		PRINT '=========================================================================';
		PRINT 'Error Occured During The Loading Of Bronze Layer';
		PRINT '=========================================================================';
	END CATCH
END
