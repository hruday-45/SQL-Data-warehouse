/*
================================================================================
DDL Script: Create Silver Tables
================================================================================
Script Purpose:
  This script creates tables in the 'silver' schema, dropping existing tables if 
  they already exists in the schema.
  Run this script to re-define the DDL structure of 'bronze' tables
=================================================================================
*/

IF OBJECT_ID ('silver.customers_info' , 'U') IS NOT NULL
	DROP TABLE silver.customers_info;

CREATE TABLE silver.customers_info (
	customer_id					      NVARCHAR(MAX),
	customer_unique_id			  NVARCHAR(MAX),
	customer_zip_code_prefix	INT,
	customer_city				      NVARCHAR(MAX),
	customer_state				    NVARCHAR(MAX),
	dwh_create_date				    DATETIME2 DEFAULT GETDATE()
);


IF OBJECT_ID ('silver.geolocation_info' , 'U') IS NOT NULL
	DROP TABLE silver.geolocation_info;

CREATE TABLE silver.geolocation_info (
	geolocation_zip_code_prefix INT,
	geolocation_lat				DECIMAL(8,6),
	geolocation_lng				DECIMAL(9,6),
	geolocation_city			NVARCHAR(MAX),
	geolocation_state			NVARCHAR(MAX),
	dwh_create_date				DATETIME2 DEFAULT GETDATE()
);


IF OBJECT_ID ('silver.order_items ' , 'U') IS NOT NULL
	DROP TABLE silver.order_items ;

CREATE TABLE silver.order_items (
	order_item_key		  INT IDENTITY(1,1) PRIMARY KEY,
	order_id			      NVARCHAR(MAX),
	order_item_id		    INT,
	product_id			    NVARCHAR(MAX),
	seller_id			      NVARCHAR(MAX),
	shipping_limit_date DATETIME2,
	price				        DECIMAL(10,2),
	freight_value		    DECIMAL(10,2),
	total_value			    AS (CAST(price + freight_value AS DECIMAL(10,2))),
	dwh_create_date		  DATETIME2 DEFAULT GETDATE()
);


IF OBJECT_ID ('silver.order_payments' , 'U') IS NOT NULL
	DROP TABLE silver.order_payments;

CREATE TABLE silver.order_payments (
	payment_key           INT IDENTITY(1,1) PRIMARY KEY,
	order_id				      NVARCHAR(MAX),
	payment_sequential		INT,
	payment_type			    NVARCHAR(MAX),
	payment_installments	INT,
	payment_value			    DECIMAL(10,2),
	dwh_create_date			  DATETIME2 DEFAULT GETDATE()
);


IF OBJECT_ID ('silver.order_reviews' , 'U') IS NOT NULL
	DROP TABLE silver.order_reviews;

CREATE TABLE silver.order_reviews (
	review_key				      INT IDENTITY(1,1) PRIMARY KEY,
	review_id				        NVARCHAR(MAX),
	order_id				        NVARCHAR(MAX),
	review_score			      INT,
	review_comment_title	  NVARCHAR(MAX),
	review_comment_message	NVARCHAR(MAX),
	review_creation_date	  DATETIME2,
	review_answer_timestamp DATETIME2,
	dwh_create_date			    DATETIME2 DEFAULT GETDATE()
);


IF OBJECT_ID ('silver.orders_info' , 'U') IS NOT NULL
	DROP TABLE silver.orders_info;

CREATE TABLE silver.orders_info (
	order_id						          NVARCHAR(MAX),
	customer_id						        NVARCHAR(MAX),
	order_status					        NVARCHAR(MAX),
	order_purchase_timestamp		  DATETIME2,
	order_approved_at				      DATETIME2,
	order_delivered_carrier_date	DATETIME2,
	order_delivered_customer_date	DATETIME2,
	order_estimated_delivery_date	DATETIME2,
	dwh_create_date					      DATETIME2 DEFAULT GETDATE()
);


IF OBJECT_ID ('silver.products_info' , 'U') IS NOT NULL
	DROP TABLE silver.products_info;

CREATE TABLE silver.products_info (
	product_id					        NVARCHAR(MAX),
	product_category_name		    NVARCHAR(MAX),
	product_name_length			    INT,
	product_description_lenght	INT,
	product_photos_qty			    INT,
	product_weight_g			      INT,
	product_length_cm			      INT,
	product_height_cm			      INT,
	product_width_cm			      INT,
	dwh_create_date				      DATETIME2 DEFAULT GETDATE()
);


IF OBJECT_ID ('silver.sellers_info' , 'U') IS NOT NULL
	DROP TABLE silver.sellers_info;

CREATE TABLE silver.sellers_info (
	seller_id				        NVARCHAR(MAX),
	seller_zip_code_prefix	INT,
	seller_city				      NVARCHAR(MAX),
	seller_state			      NVARCHAR(MAX),
	dwh_create_date			    DATETIME2 DEFAULT GETDATE()
);


IF OBJECT_ID ('silver.product_category_name_translation' , 'U') IS NOT NULL
	DROP TABLE silver.product_category_name_translation;

CREATE TABLE silver.product_category_name_translation (
	product_category_name			    NVARCHAR(MAX),
	product_category_name_english	NVARCHAR(MAX),
	dwh_create_date					      DATETIME2 DEFAULT GETDATE()
);
