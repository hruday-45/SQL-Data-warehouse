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
		PRINT '---> Truncating Table: bronze.customers_info';
		TRUNCATE TABLE bronze.customers_info;

		PRINT '---> Inserting Data Info: bronze.customers_info';
		BULK INSERT bronze.customers_info
		FROM 'C:\SQL project\Client Data Sheet\customers_info.csv'
		WITH(
			FORMAT			= 'CSV',
			FIRSTROW		= 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		= '"',
			ROWTERMINATOR	= '0x0a',
			CODEPAGE		= '65001',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '---> Truncating Table: bronze.geolocation_info';
		TRUNCATE TABLE bronze.geolocation_info;

		PRINT '---> Inserting Data Info: bronze.geolocation_info';
		BULK INSERT bronze.geolocation_info
		FROM 'C:\SQL project\Client Data Sheet\geolocation_info.csv'
		WITH(
			FORMAT			= 'CSV',
			FIRSTROW		= 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		= '"',
			ROWTERMINATOR	= '0x0a',
			CODEPAGE		= '65001',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '---> Truncating Table: bronze.order_items';
		TRUNCATE TABLE bronze.order_items;

		PRINT '---> Inserting Data Info: bronze.order_items';
		BULK INSERT bronze.order_items
		FROM 'C:\SQL project\Client Data Sheet\order_items.csv'
		WITH(
			FORMAT			= 'CSV',
			FIRSTROW		= 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		= '"',
			ROWTERMINATOR	= '0x0a',
			CODEPAGE		= '65001',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '---> Truncating Table: bronze.order_payments';
		TRUNCATE TABLE bronze.order_payments;

		PRINT '---> Inserting Data Info: bronze.order_payments';
		BULK INSERT bronze.order_payments
		FROM 'C:\SQL project\Client Data Sheet\order_payments.csv'
		WITH(
			FORMAT			= 'CSV',
			FIRSTROW		= 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		= '"',
			ROWTERMINATOR	= '0x0a',
			CODEPAGE		= '65001',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '---> Truncating Table: bronze.order_reviews';
		TRUNCATE TABLE bronze.order_reviews;

		PRINT '---> Inserting Data Info: bronze.order_reviews';
		BULK INSERT bronze.order_reviews
		FROM 'C:\SQL project\Client Data Sheet\order_reviews.csv'
		WITH(
		    FORMAT			= 'CSV',
			FIRSTROW		= 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		= '"',
			ROWTERMINATOR	= '0x0d0a',
			CODEPAGE		= '65001',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '---> Truncating Table: bronze.orders_info';
		TRUNCATE TABLE bronze.orders_info;

		PRINT '---> Inserting Data Info: bronze.orders_info';
		BULK INSERT bronze.orders_info
		FROM 'C:\SQL project\Client Data Sheet\orders_info.csv'
		WITH(
			FORMAT			= 'CSV',
			FIRSTROW		= 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		= '"',
			ROWTERMINATOR	= '0x0a',
			CODEPAGE		= '65001',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '---> Truncating Table: bronze.products_info';
		TRUNCATE TABLE bronze.products_info;

		PRINT '---> Inserting Data Info: bronze.products_info';
		BULK INSERT bronze.products_info
		FROM 'C:\SQL project\Client Data Sheet\products_info.csv'
		WITH(
			FORMAT			= 'CSV',
			FIRSTROW		= 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		= '"',
			ROWTERMINATOR	= '0x0a',
			CODEPAGE		= '65001',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '---> Truncating Table: bronze.sellers_info';
		TRUNCATE TABLE bronze.sellers_info;

		PRINT '---> Inserting Data Info:bronze.sellers_info';
		BULK INSERT bronze.sellers_info
		FROM 'C:\SQL project\Client Data Sheet\sellers_info.csv'
		WITH(
			FORMAT			= 'CSV',
			FIRSTROW		= 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		= '"',
			ROWTERMINATOR	= '0x0a',
			CODEPAGE		= '65001',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---> Loading Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '---> Truncating Table: bronze.product_category_name_translation';
		TRUNCATE TABLE bronze.product_category_name_translation;

		PRINT '---> Inserting Data Info: bronze.product_category_name_translation';
		BULK INSERT bronze.product_category_name_translation
		FROM 'C:\SQL project\Client Data Sheet\product_category_name_translation.csv'
		WITH (
			FORMAT			= 'CSV',
			FIRSTROW		= 2,
			FIELDTERMINATOR = ',',
			FIELDQUOTE		= '"',
			ROWTERMINATOR	= '0x0a',
			CODEPAGE		= '65001',
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
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================================================';
	END CATCH
END;
