/*
===============================================================================
DDL Script: Create Gold Tables
===============================================================================
Script Purpose:
    This script creates tables for the Gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables (Star Schema)
*/

--  =================================================================
--  Create Dimension Table: gold.dim_customers
--  =================================================================

--------------------------------------------------------------------
-- Droping Fact tables First to avoid FK constraints issues
--------------------------------------------------------------------
DROP TABLE IF EXISTS gold.fact_sales;
DROP TABLE IF EXISTS gold.fact_payments;
DROP TABLE IF EXISTS gold.fact_reviews;

--------------------------------------------------------------------
-- Droping Dim tables
--------------------------------------------------------------------
DROP TABLE IF EXISTS gold.dim_customers;
DROP TABLE IF EXISTS gold.dim_sellers;
DROP TABLE IF EXISTS gold.dim_products;
DROP TABLE IF EXISTS gold.dim_orders;
DROP TABLE IF EXISTS gold.dim_date;
DROP TABLE IF EXISTS gold.dim_location;

--------------------------------------------------------------------------------
----------------------------- Creating Dimension Tables ------------------------
--------------------------------------------------------------------------------
CREATE TABLE gold.dim_customers
(
	customer_key INT NOT NULL,
	customer_id NVARCHAR(50) NOT NULL,
	customer_unique_id NVARCHAR(50) NOT NULL,
	customer_city NVARCHAR(50) NOT NULL,
	customer_state NVARCHAR(50) NOT NULL,
	customer_zip_code_prefix NVARCHAR(10),
	latitude DECIMAL(9,6),
	longitude DECIMAL(9,6),
	first_order_date DATE,
	last_order_date DATE,
	total_orders INT,
	is_repeat_customer BIT NOT NULL DEFAULT 0,
	customer_tenure_days INT,
	dwh_create_date DATETIME2(0) DEFAULT GETDATE()
		CONSTRAINT PK_dim_customers PRIMARY KEY CLUSTERED (customer_key),
	CONSTRAINT UQ_dim_customers_customer_id UNIQUE (customer_id)
);


CREATE TABLE gold.dim_sellers
(
	seller_key INT NOT NULL,
	seller_id NVARCHAR(50) NOT NULL,
	seller_city NVARCHAR(50) NOT NULL,
	seller_state NVARCHAR(50) NOT NULL,
	seller_zip_code_prefix NVARCHAR(10),
	latitude DECIMAL(9,6),
	longitude DECIMAL(9,6),
	dwh_create_date DATETIME2(0) DEFAULT GETDATE()
		CONSTRAINT PK_dim_sellers PRIMARY KEY CLUSTERED (seller_key),
	CONSTRAINT UQ_dim_sellers_seller_id UNIQUE (seller_id)
);


CREATE TABLE gold.dim_products
(
	product_key INT NOT NULL,
	product_id NVARCHAR(50) NOT NULL,
	product_category_name NVARCHAR(50) NOT NULL,
	product_category_name_english NVARCHAR(50) NOT NULL,
	product_weight_g INT,
	product_length_cm INT,
	product_height_cm INT,
	product_width_cm INT,
	product_volume_cm3 DECIMAL(10,2),
	dwh_create_date DATETIME2(0) DEFAULT GETDATE()
		CONSTRAINT PK_dim_products PRIMARY KEY CLUSTERED (product_key),
	CONSTRAINT UQ_dim_products_product_id UNIQUE (product_id)
);

CREATE TABLE gold.dim_orders
(
	order_key INT NOT NULL,
	order_id NVARCHAR(50) NOT NULL,
	customer_id NVARCHAR(50) NOT NULL,
	order_status NVARCHAR(30) NOT NULL,
	order_purchase_timestamp DATETIME2(0),
	order_approved_at DATETIME2(0),
	order_delivered_carrier_date DATETIME2(0),
	order_delivered_customer_date DATETIME2(0),
	order_estimated_delivery_date DATETIME2(0),
	delivery_performance_status NVARCHAR(20),
	dwh_create_date DATETIME2(0) DEFAULT GETDATE()
		CONSTRAINT PK_dim_orders PRIMARY KEY CLUSTERED (order_key),
	CONSTRAINT UQ_dim_orders_order_id UNIQUE (order_id)
);


CREATE TABLE gold.dim_date
(
	date_key INT NOT NULL,
	date DATE NOT NULL,
	day INT NOT NULL,
	week INT NOT NULL,
	month INT NOT NULL,
	month_name NVARCHAR(20) NOT NULL,
	quarter INT NOT NULL,
	year INT NOT NULL,
	is_weekend BIT NOT NULL DEFAULT 0,
	is_holiday_brazil_flag BIT NOT NULL DEFAULT 0,
	dwh_create_date DATETIME2(0) DEFAULT GETDATE()
		CONSTRAINT PK_dim_date PRIMARY KEY CLUSTERED (date_key),
	CONSTRAINT UQ_dim_date_date UNIQUE (date)
);


CREATE TABLE gold.dim_location
(
	location_key INT NOT NULL,
	geolocation_zip_code_prefix NVARCHAR(10) NOT NULL,
	city NVARCHAR(40) NOT NULL,
	state_code NVARCHAR(2) NOT NULL,
	state_name NVARCHAR(50) NOT NULL,
	region_name NVARCHAR(20) NOT NULL,
	latitude DECIMAL(9,6),
	longitude DECIMAL(9,6),
	dwh_create_date DATETIME2(0) DEFAULT GETDATE()
		CONSTRAINT PK_dim_location PRIMARY KEY CLUSTERED (location_key),
	CONSTRAINT UQ_dim_location_zip_code_prefix UNIQUE (geolocation_zip_code_prefix)
);

--------------------------------------------------------------------------------
----------------------------- Creating Fact Tables -----------------------------
--------------------------------------------------------------------------------
CREATE TABLE gold.fact_sales
(
	sales_key INT IDENTITY(1,1) NOT NULL,
	order_key INT NOT NULL,
	customer_key INT NOT NULL,
	seller_key INT NOT NULL,
	product_key INT NOT NULL,
	product_price DECIMAL(10,2),
	freight_value DECIMAL(10,2),
	total_product_value DECIMAL(10,2),
	order_status NVARCHAR(20),
	order_purchase_timestamp DATE,
	order_approved_at DATE,
	order_delivered_carrier_date DATE,
	order_delivered_customer_date DATE,
	total_delivery_days INT,
	seller_processing_days INT,
	carrier_transit_days INT,
	delivery_delay_days INT,
	is_shipped_flag BIT NOT NULL DEFAULT 0,
	is_delivered_flag BIT NOT NULL DEFAULT 0,
	is_late_delivery_flag BIT NOT NULL DEFAULT 0,
	dwh_create_date DATETIME2(0) DEFAULT GETDATE()
		CONSTRAINT PK_fact_sales PRIMARY KEY CLUSTERED (sales_key),
	CONSTRAINT FK_fact_sales_orders FOREIGN KEY (order_key)
        REFERENCES gold.dim_orders(order_key),
	CONSTRAINT FK_fact_sales_customers FOREIGN KEY (customer_key)
		REFERENCES gold.dim_customers(customer_key),
	CONSTRAINT FK_fact_sales_sellers FOREIGN KEY (seller_key)
		REFERENCES gold.dim_sellers(seller_key),
	CONSTRAINT FK_fact_sales_products FOREIGN KEY (product_key)
		REFERENCES gold.dim_products(product_key)
);

CREATE TABLE gold.fact_payments
(
	payment_key INT IDENTITY(1,1) NOT NULL,
	order_key INT NOT NULL,
	customer_key INT NOT NULL,
	order_approved_at DATE,
	payment_value DECIMAL(10,2),
	payment_installments INT,
	payment_type NVARCHAR(20),
	dwh_create_date DATETIME2(0) DEFAULT GETDATE()
		CONSTRAINT PK_fact_payments PRIMARY KEY CLUSTERED (payment_key),
	CONSTRAINT FK_fact_payments_orders FOREIGN KEY (order_key)
		REFERENCES gold.dim_orders(order_key),
	CONSTRAINT FK_fact_payments_customers FOREIGN KEY (customer_key)
		REFERENCES gold.dim_customers(customer_key)
);


CREATE TABLE gold.fact_reviews
(
	review_key INT IDENTITY(1,1) NOT NULL,
	order_key INT NOT NULL,
	customer_key INT NOT NULL,
	review_date DATE,
	avg_review_score DECIMAL(10,2),
	latest_review_date DATETIME2(0),
	latest_answer_timestamp DATETIME2(0),
	review_response_lag_days INT,
	dwh_create_date DATETIME2(0) DEFAULT GETDATE()
		CONSTRAINT PK_fact_reviews PRIMARY KEY CLUSTERED (review_key),
	CONSTRAINT FK_fact_reviews_orders FOREIGN KEY (order_key)
		REFERENCES gold.dim_orders(order_key),
	CONSTRAINT FK_fact_reviews_customers FOREIGN KEY (customer_key)
		REFERENCES gold.dim_customers(customer_key)
);