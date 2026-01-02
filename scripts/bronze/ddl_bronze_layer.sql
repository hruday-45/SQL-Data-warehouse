/*
===============================================================
DDL Script: Create Bronze Tables
===============================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables if they already exist.
    Run this script to re-define the DDL structure of 'bronze' tables.
================================================================
*/

IF OBJECT_ID ('bronze.olist_customers_dataset' , 'U') IS NOT NULL
	DROP TABLE bronze.olist_customers_dataset;

CREATE TABLE bronze.olist_customers_dataset (
	customer_id					NVARCHAR(50),
	customer_unique_id			NVARCHAR(50),
	customer_zip_code_prefix	INT,
	customer_city				NVARCHAR(50),
	customer_state				NVARCHAR(2)
);


IF OBJECT_ID ('bronze.olist_geolocation_dataset' , 'U') IS NOT NULL
	DROP TABLE bronze.olist_geolocation_dataset;

CREATE TABLE bronze.olist_geolocation_dataset (
	geolocation_zip_code_prefix INT,
	geolocation_lat				DECIMAL(30,20),
	geolocation_lng				DECIMAL(30,20),
	geolocation_city			NVARCHAR(50),
	geolocation_state			NVARCHAR(2)
);


IF OBJECT_ID ('bronze.olist_order_items_dataset' , 'U') IS NOT NULL
	DROP TABLE bronze.olist_order_items_dataset ;

CREATE TABLE bronze.olist_order_items_dataset (
	order_id			NVARCHAR(50),
	order_item_id		INT,
	product_id			NVARCHAR(50),
	seller_id			NVARCHAR(50),
	shipping_limit_date DATETIME2(0),
	price				DECIMAL(10,2),
	freight_value		DECIMAL(10,2)
);


IF OBJECT_ID ('bronze.olist_order_payments_dataset' , 'U') IS NOT NULL
	DROP TABLE bronze.olist_order_payments_dataset;

CREATE TABLE bronze.olist_order_payments_dataset (
	order_id				NVARCHAR(50),
	payment_sequential		INT,
	payment_type			NVARCHAR(20),
	payment_installments	INT,
	payment_value			DECIMAL(10,2)
);


IF OBJECT_ID ('bronze.olist_order_reviews_dataset' , 'U') IS NOT NULL
	DROP TABLE bronze.olist_order_reviews_dataset;

CREATE TABLE bronze.olist_order_reviews_dataset (
	review_id				NVARCHAR(50),
	order_id				NVARCHAR(50),
	review_score			INT,
	review_comment_title	NVARCHAR(MAX),
	review_comment_message	NVARCHAR(MAX),
	review_creation_date	DATETIME2(0),
	review_answer_timestamp DATETIME2(0)
);


IF OBJECT_ID ('bronze.olist_orders_dataset' , 'U') IS NOT NULL
	DROP TABLE bronze.olist_orders_dataset;

CREATE TABLE bronze.olist_orders_dataset (
	order_id						NVARCHAR(50),
	customer_id						NVARCHAR(50),
	order_status					NVARCHAR(50),
	order_purchase_timestamp		DATETIME2(0),
	order_approved_at				DATETIME2(0),
	order_delivered_carrier_date	DATETIME2(0),
	order_delivered_customer_date	DATETIME2(0),
	order_estimated_delivery_date	DATETIME2(0)
);


IF OBJECT_ID ('bronze.olist_products_dataset' , 'U') IS NOT NULL
	DROP TABLE bronze.olist_products_dataset;

CREATE TABLE bronze.olist_products_dataset (
	product_id					NVARCHAR(50),
	product_category_name		NVARCHAR(50),
	product_name_lenght			INT,
	product_description_lenght	INT,
	product_photos_qty			INT,
	product_weight_g			INT,
	product_length_cm			INT,
	product_height_cm			INT,
	product_width_cm			INT
);


IF OBJECT_ID ('bronze.olist_sellers_dataset' , 'U') IS NOT NULL
	DROP TABLE bronze.olist_sellers_dataset;

CREATE TABLE bronze.olist_sellers_dataset (
	seller_id				NVARCHAR(50),
	seller_zip_code_prefix	INT,
	seller_city				NVARCHAR(50),
	seller_state			NVARCHAR(2)
);


IF OBJECT_ID ('bronze.product_category_name_translation' , 'U') IS NOT NULL
	DROP TABLE bronze.product_category_name_translation;

CREATE TABLE bronze.product_category_name_translation (
	product_category_name			NVARCHAR(50),
	product_category_name_english	NVARCHAR(50)
);
