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
		PRINT '---> Truncating Table: bronze.csv_olist_customers_dataset';
		TRUNCATE TABLE bronze.csv_olist_customers_dataset;

		PRINT '---> Inserting Data Info: bronze.csv_olist_customers_dataset';
		BULK INSERT bronze.csv_olist_customers_dataset
		FROM 'C:\SQL project\Client Data Sheet\olist_customers_dataset.csv'
		WITH (
			FIRSTROW		    = 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		  = '"',
  		ROWTERMINATOR   = '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '---> Truncating Table: bronze.csv_olist_geolocation_dataset';
		TRUNCATE TABLE bronze.csv_olist_geolocation_dataset;

		PRINT '---> Inserting Data Info: bronze.csv_olist_geolocation_dataset';
		BULK INSERT bronze.csv_olist_geolocation_dataset
		FROM 'C:\SQL project\Client Data Sheet\olist_geolocation_dataset.csv'
		WITH (
			FIRSTROW		    = 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		  = '"',
			ROWTERMINATOR	  = '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '---> Truncating Table: bronze.csv_olist_order_items_dataset';
		TRUNCATE TABLE bronze.csv_olist_order_items_dataset;

		PRINT '---> Inserting Data Info: bronze.csv_olist_order_items_dataset';
		BULK INSERT bronze.csv_olist_order_items_dataset
		FROM 'C:\SQL project\Client Data Sheet\olist_order_items_dataset.csv'
		WITH (
			FIRSTROW		    = 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		  = '"',
			ROWTERMINATOR	  = '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '---> Truncating Table: bronze.csv_olist_order_payments_dataset';
		TRUNCATE TABLE bronze.csv_olist_order_payments_dataset;

		PRINT '---> Inserting Data Info: bronze.csv_olist_order_payments_dataset';
		BULK INSERT bronze.csv_olist_order_payments_dataset
		FROM 'C:\SQL project\Client Data Sheet\olist_order_payments_dataset.csv'
		WITH (
			FIRSTROW		    = 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		  = '"',
			ROWTERMINATOR	  = '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '---> Truncating Table: bronze.csv_olist_order_reviews_dataset';
		TRUNCATE TABLE bronze.csv_olist_order_reviews_dataset;

		PRINT '---> Inserting Data Info: bronze.csv_olist_order_reviews_dataset';
		BULK INSERT bronze.csv_olist_order_reviews_dataset
		FROM 'C:\SQL project\Client Data Sheet\olist_order_reviews_dataset.csv'
		WITH (
			FIRSTROW		    = 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		  = '"',
			ROWTERMINATOR	  = '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '---> Truncating Table: bronze.csv_olist_orders_dataset';
		TRUNCATE TABLE bronze.csv_olist_orders_dataset;

		PRINT '---> Inserting Data Info: bronze.csv_olist_orders_dataset';
		BULK INSERT bronze.csv_olist_orders_dataset
		FROM 'C:\SQL project\Client Data Sheet\olist_orders_dataset.csv'
		WITH (
			FIRSTROW		    = 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		  = '"',
			ROWTERMINATOR	  = '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '---> Truncating Table: bronze.csv_olist_products_dataset';
		TRUNCATE TABLE bronze.csv_olist_products_dataset;

		PRINT '---> Inserting Data Info: bronze.csv_olist_products_dataset';
		BULK INSERT bronze.csv_olist_products_dataset
		FROM 'C:\SQL project\Client Data Sheet\olist_products_dataset.csv'
		WITH (
			FIRSTROW		    = 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		  = '"',
			ROWTERMINATOR	  = '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '---> Truncating Table: bronze.csv_olist_sellers_dataset';
		TRUNCATE TABLE bronze.csv_olist_sellers_dataset;

		PRINT '---> Inserting Data Info: bronze.csv_olist_sellers_dataset';
		BULK INSERT bronze.csv_olist_sellers_dataset
		FROM 'C:\SQL project\Client Data Sheet\olist_sellers_dataset.csv'
		WITH (
			FIRSTROW		    = 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		  = '"',
			ROWTERMINATOR	  = '0x0a',
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
			FIRSTROW		    = 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		  = '"',
			ROWTERMINATOR	  = '0x0a',
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
