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
	customer_id					NVARCHAR(MAX),
	customer_unique_id			NVARCHAR(MAX),
	customer_zip_code_prefix	NVARCHAR(MAX),
	customer_city				NVARCHAR(MAX),
	customer_state				NVARCHAR(MAX)
);


IF OBJECT_ID ('bronze.olist_geolocation_dataset' , 'U') IS NOT NULL
	DROP TABLE bronze.olist_geolocation_dataset;

CREATE TABLE bronze.olist_geolocation_dataset (
	geolocation_zip_code_prefix NVARCHAR(MAX),
	geolocation_lat				NVARCHAR(MAX),
	geolocation_lng				NVARCHAR(MAX),
	geolocation_city			NVARCHAR(MAX),
	geolocation_state			NVARCHAR(MAX)
);


IF OBJECT_ID ('bronze.olist_order_items_dataset' , 'U') IS NOT NULL
	DROP TABLE bronze.olist_order_items_dataset ;

CREATE TABLE bronze.olist_order_items_dataset (
	order_id			NVARCHAR(MAX),
	order_item_id		NVARCHAR(MAX),
	product_id			NVARCHAR(MAX),
	seller_id			NVARCHAR(MAX),
	shipping_limit_date NVARCHAR(MAX),
	price				NVARCHAR(MAX),
	freight_value		NVARCHAR(MAX)
);


IF OBJECT_ID ('bronze.olist_order_payments_dataset' , 'U') IS NOT NULL
	DROP TABLE bronze.olist_order_payments_dataset;

CREATE TABLE bronze.olist_order_payments_dataset (
	order_id				NVARCHAR(MAX),
	payment_sequential		NVARCHAR(MAX),
	payment_type			NVARCHAR(MAX),
	payment_installments	NVARCHAR(MAX),
	payment_value			NVARCHAR(MAX)
);


IF OBJECT_ID ('bronze.olist_order_reviews_dataset' , 'U') IS NOT NULL
	DROP TABLE bronze.olist_order_reviews_dataset;

CREATE TABLE bronze.olist_order_reviews_dataset (
	review_id				NVARCHAR(MAX),
	order_id				NVARCHAR(MAX),
	review_score			NVARCHAR(MAX),
	review_comment_title	NVARCHAR(MAX),
	review_comment_message	NVARCHAR(MAX),
	review_creation_date	NVARCHAR(MAX),
	review_answer_timestamp NVARCHAR(MAX)
);


IF OBJECT_ID ('bronze.olist_orders_dataset' , 'U') IS NOT NULL
	DROP TABLE bronze.olist_orders_dataset;

CREATE TABLE bronze.olist_orders_dataset (
	order_id						NVARCHAR(MAX),
	customer_id						NVARCHAR(MAX),
	order_status					NVARCHAR(MAX),
	order_purchase_timestamp		NVARCHAR(MAX),
	order_approved_at				NVARCHAR(MAX),
	order_delivered_carrier_date	NVARCHAR(MAX),
	order_delivered_customer_date	NVARCHAR(MAX),
	order_estimated_delivery_date	NVARCHAR(MAX)
);


IF OBJECT_ID ('bronze.olist_products_dataset' , 'U') IS NOT NULL
	DROP TABLE bronze.olist_products_dataset;

CREATE TABLE bronze.olist_products_dataset (
	product_id					NVARCHAR(MAX),
	product_category_name		NVARCHAR(MAX),
	product_name_lenght			NVARCHAR(MAX),
	product_description_lenght	NVARCHAR(MAX),
	product_photos_qty			NVARCHAR(MAX),
	product_weight_g			NVARCHAR(MAX),
	product_length_cm			NVARCHAR(MAX),
	product_height_cm			NVARCHAR(MAX),
	product_width_cm			NVARCHAR(MAX)
);


IF OBJECT_ID ('bronze.olist_sellers_dataset' , 'U') IS NOT NULL
	DROP TABLE bronze.olist_sellers_dataset;

CREATE TABLE bronze.olist_sellers_dataset (
	seller_id				NVARCHAR(MAX),
	seller_zip_code_prefix	NVARCHAR(MAX),
	seller_city				NVARCHAR(MAX),
	seller_state			NVARCHAR(MAX)
);


IF OBJECT_ID ('bronze.product_category_name_translation' , 'U') IS NOT NULL
	DROP TABLE bronze.product_category_name_translation;

CREATE TABLE bronze.product_category_name_translation (
	product_category_name			NVARCHAR(MAX),
	product_category_name_english	NVARCHAR(MAX)
););
