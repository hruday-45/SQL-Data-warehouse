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
	customer_id					NVARCHAR(50),
	customer_unique_id			NVARCHAR(50),
	customer_zip_code_prefix	INT,
	customer_city				NVARCHAR(50),
	customer_state				NVARCHAR(2),
	dwh_create_date				DATETIME2(0) DEFAULT GETDATE()
);


IF OBJECT_ID ('silver.geolocation_info' , 'U') IS NOT NULL
	DROP TABLE silver.geolocation_info;

CREATE TABLE silver.geolocation_info (
	geolocation_zip_code_prefix INT,
	geolocation_lat				DECIMAL(9,6),
	geolocation_lng				DECIMAL(9,6),
	geolocation_city			NVARCHAR(50),
	geolocation_state			NVARCHAR(2),
	dwh_create_date				DATETIME2(0) DEFAULT GETDATE()
);


IF OBJECT_ID ('silver.order_items ' , 'U') IS NOT NULL
	DROP TABLE silver.order_items ;

CREATE TABLE silver.order_items (
	order_id					NVARCHAR(50),
	order_item_id				INT,
	product_id					NVARCHAR(50),
	seller_id					NVARCHAR(50),
	shipping_limit_date			DATETIME2(0),
	price						DECIMAL(10,2),
	freight_value				DECIMAL(10,2),
	total_value					AS (CAST(price + freight_value AS DECIMAL(10,2))),
	dwh_create_date				DATETIME2(0) DEFAULT GETDATE()
);


IF OBJECT_ID ('silver.order_payments' , 'U') IS NOT NULL
	DROP TABLE silver.order_payments;

CREATE TABLE silver.order_payments (
	order_id				NVARCHAR(50),
	payment_sequential		INT,
	payment_type			NVARCHAR(20),
	payment_installments	INT,
	payment_value			DECIMAL(10,2),
	dwh_create_date			DATETIME2(0) DEFAULT GETDATE()
);


IF OBJECT_ID ('silver.order_reviews' , 'U') IS NOT NULL
	DROP TABLE silver.order_reviews;

CREATE TABLE silver.order_reviews (
	review_id				NVARCHAR(50),
	order_id				NVARCHAR(50),
	review_score			INT,
	review_comment_title	NVARCHAR(MAX),
	review_comment_message	NVARCHAR(MAX),
	review_creation_date	DATETIME2(0),
	review_answer_timestamp DATETIME2(0),
	dwh_create_date			DATETIME2(0) DEFAULT GETDATE()
);


IF OBJECT_ID ('silver.orders_info' , 'U') IS NOT NULL
	DROP TABLE silver.orders_info;

CREATE TABLE silver.orders_info (
	order_id						NVARCHAR(50),
	customer_id						NVARCHAR(50),
	order_status					NVARCHAR(30),
	order_purchase_timestamp		DATETIME2(0),
	order_approved_at				DATETIME2(0),
	order_delivered_carrier_date	DATETIME2(0),
	order_delivered_customer_date	DATETIME2(0),
	order_estimated_delivery_date	DATETIME2(0),
	dwh_create_date					DATETIME2(0) DEFAULT GETDATE()
);


IF OBJECT_ID ('silver.products_info' , 'U') IS NOT NULL
	DROP TABLE silver.products_info;

CREATE TABLE silver.products_info (
	product_id					NVARCHAR(50),
	product_category_name		NVARCHAR(50),
	product_name_length			INT,
	product_description_lenght	INT,
	product_photos_qty			INT,
	product_weight_g			INT,
	product_length_cm			INT,
	product_height_cm			INT,
	product_width_cm			INT,
	dwh_create_date				DATETIME2(0) DEFAULT GETDATE()
);


IF OBJECT_ID ('silver.sellers_info' , 'U') IS NOT NULL
	DROP TABLE silver.sellers_info;

CREATE TABLE silver.sellers_info (
	seller_id				NVARCHAR(50),
	seller_zip_code_prefix	INT,
	seller_city				NVARCHAR(50),
	seller_state			NVARCHAR(2),
	dwh_create_date			DATETIME2(0) DEFAULT GETDATE()
);


IF OBJECT_ID ('silver.product_category_name_translation' , 'U') IS NOT NULL
	DROP TABLE silver.product_category_name_translation;

CREATE TABLE silver.product_category_name_translation (
	product_category_name			NVARCHAR(50),
	product_category_name_english	NVARCHAR(50),
	dwh_create_date					DATETIME2(0) DEFAULT GETDATE()
);


IF OBJECT_ID ('silver.state_centers' , 'U') IS NOT NULL
	DROP TABLE silver.state_centers;

CREATE TABLE silver.state_centers (
		state_code			NVARCHAR(2) PRIMARY KEY,
		state_name			NVARCHAR(50),
		region_name			NVARCHAR(20),
		avg_lat				DECIMAL(9,6),
		avg_lng				DECIMAL(9,6),
		dwh_create_date		DATETIME2(0) DEFAULT GETDATE()
);
