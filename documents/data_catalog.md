# 📊 Gold Layer Data Dictionary

## Overview
The **Gold Layer** is the business-level data representation, structured to support analytical and reporting use cases. It consists of dimension tables and fact tables for specific business metrics.

---

## 1. Dimension Tables (The Context)

### `gold.dim_customers`
**Purpose:** Stores customers details enriched with demographic and geographic data.

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| **customer_key** | `INT` | Surrogate key uniquely identifying each customer record in the customer dimension table. |
| **customer_unique_id** | `NVARCHAR(50)` | The natural unique UUID from the source system for the traceability of the customer. |
| **customer_id** | `NVARCHAR(50)` | The natural UUID from the source system for the traceability of customer. |
| **customer_city** | `NVARCHAR(50)` | The city where the customer is located. |
| **customer_state** | `NVARCHAR(50)` | The state where the customer is located in full name. |
| **state_code** | `NVARCHAR(5)` | The 2-letter state code (e.g., 'SP'). |
| **customer_zipcode** | `INT` | The postal code of the customer. |
| **latitude** | `DECIMAL(9,6)` | Geographic latitude coordinate. |
| **longitude** | `DECIMAL(8,6)` | Geographic longitude coordinate. |

### `gold.dim_date`
**Purpose:** Provide a single, consistent, and precomputed “master timeline” for the entire data warehouse.

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| **date_id** | `DATE` | Surrogate key uniquely identifying dates throughout the data warehouse timeline (yyyy-MM-dd). |
| **year** | `INT` | Calender year. |
| **quarter_number** | `INT` | Display quarter number (e.g., ‘1,2,3,4’). |
| **quarter_name** | `NVARCHAR(2)` | Display quarter name (e.g., ‘Q1’). |
| **month_number** | `INT` | Display the number of the month. |
| **month_name** | `NVARCHAR(30)` | Display the name of the month (e.g., ‘January’). |
| **year_month** | `NVARCHAR(20)` | Display the year and month (yyyy-MM). |
| **week_of_year** | `INT` | Display the week number of that year. |
| **day_number** | `INT` | Display the day number of the month. |
| **day_name** | `NVARCHAR(30)` | Display the name of the day (e.g., ‘Monday’). |
| **day_of_week_sort** | `INT` | Display the number of the day in a week. |
| **is_weekend** | `INT` | Binary flag (1 = Sat/Sun, 0 = Weekday). |

### `gold.dim_orders`
**Purpose:** Consolidates all attributes that describe the entire transaction rather than individual items.

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| **order_key** | `INT` | The unique Surrogate Key identifying each order_id as an interger. |
| **order_id** | `NVARCHAR(50)` | The natural UUID from the source system for the traceability of orders. |
| **customer_id** | `NVARCHAR(50)` | The natural UUID from the source system for the traceability of customers. |
| **avg_review_score** | `DECIMAL(10,2)` | Average of all the scores received on the particular order_id (from 0 to 5). |
| **payment_methods_count**| `INT` | Total number of distinct payment methods used for this order. |
| **total_amount_paid** | `DECIMAL(10,2)` | Sum of all payments for the order. |
| **purchase_date** | `NVARCHAR(20)` | Date of the order purchased (yyyy-MM-dd HH:mm). |
| **delivered_date** | `NVARCHAR(20)` | Order delivered date (yyyy-MM-dd HH:mm). |
| **delivery_estimated_date**| `NVARCHAR(20)` | Estimated date of the order delivery (yyyy-MM-dd HH:mm). |
| **actual_delivered_days** | `INT` | Actual number of days took for the order to get delivered. |
| **late_delivery** | `INT` | Binary flag (1 if actual delivery > estimated delivery). |
| **order_status** | `NVARCHAR(30)` | Status of the order (e.g., “SHIPPED”). |

### `gold.dim_products`
**Purpose:** Serves as the definitive source of descriptive information for every item sold.

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| **product_key** | `INT` | Surrogate key uniquely identifying each product record in the product dimension table. |
| **product_id** | `NVARCHAR(50)` | The natural UUID from the source system for the traceability of products. |
| **category_name** | `NVARCHAR(100)` | The English names of the products category. |
| **weight_kg** | `DECIMAL(10,3)` | Weight of the product in KG. |
| **name_length** | `INT` | Product name length. |
| **description_quality** | `VARCHAR(10)` | Quality based on length (If null/0 = No Details, <200 = Low, 200-1000 = Standard, >1000 = High). |
| **photos_quantity** | `INT` | Number of photos available for the product. |
| **volume_cm3** | `INT` | Product(width * length * height) in cm3. |

### `gold.dim_sellers`
**Purpose:** Definitive source of information regarding the merchants and partners operating within the ecosystem.

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| **seller_key** | `INT` | Surrogate key uniquely identifying each seller record in the product dimension table. |
| **seller_id** | `NVARCHAR(50)` | The natural UUID from the source system for the traceability of sellers. |
| **seller_city** | `NVARCHAR(100)` | The city where the seller is located. |
| **seller_state** | `NVARCHAR(100)` | The state where the seller is located. |
| **state_code** | `NVARCHAR(5)` | The 2-letter state code (e.g., 'SP'). |
| **seller_zip_code** | `INT` | The postal code of the seller. |
| **latitude** | `DECIMAL(9,6)` | Geographic latitude coordinate. |
| **longitude** | `DECIMAL(9,6)` | Geographic longitude coordinate. |

---

## 2. Fact Tables (The Metrics)

### `gold.fact_payments`
**Purpose:** Detailed financial transaction data related to orders.

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| **payment_key** | `INT` | Surrogate key uniquely identifying each payment record in the payment fact table. |
| **order_key** | `INT` | Foreign key linking payment to the time it was processed. |
| **date_id** | `DATE` | Foreign key linking dates to the time when the order is processed. |
| **payment_sequential** | `INT` | Sequence of payments if a customer used multiple methods for one order. |
| **payment_type** | `NVARCHAR(30)` | Categorizes the payment (e.g., ‘Credit_card’, ‘Voucher’). |
| **payment_installments** | `INT` | Number of monthly payments the customer chose. |
| **payment_amount** | `DECIMAL(10,2)` | Total amount processed in this specific transaction line. |
| **is_voucher_only** | `INT` | If the payment is done only with voucher it return '1' if not it will be '0'. |

### `gold.fact_reviews`
**Purpose:** Measures customer satisfaction and correlates it with operational performance like delivery speed or product quality.

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| **review_key** | `INT` | Surrogate primary key for the review entry. |
| **order_key** | `INT` | Foreign key linking the review to the relevant order. |
| **review_score** | `INT` | Rating from 1 to 5 given by the customer. |
| **review_comment_title**| `NVARCHAR(MAX)` | Short heading of the customer's feedback. |
| **review_comment_message**| `NVARCHAR(MAX)` | Full text feedback provided by the customer. |
| **date_id** | `DATE` | Foreign key linking dates to the time when the review is posted. |
| **review_answer_timestamp**| `NVARCHAR(20)` | The moment the seller responded to a customer's feedback. |

### `gold.fact_sales`
**Purpose:** Record every individual transaction at the line-item level.

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| **order_id** | `INT` | Foreign key link to gold.dim_orders. |
| **order_sequence_no** | `INT` | Identifies the position of an item within a specific order. |
| **seller_key** | `INT` | Foreign key used to link gold.dim_sellers. |
| **customer_key** | `INT` | Foreign key used to link gold.dm_customers. |
| **product_key** | `INT` | Foreign key used to link gold.dim_products. |
| **price** | `DECIMAL(10,2)` | The individual item cost at the time of purchase. |
| **freight_value** | `DECIMAL(10,2)` | The shipping cost for this specific item. |
| **total_value** | `DECIMAL(10,2)` | Sum of price and freight. |
| **date_id** | `DATE` | Foreign key used to link dates during the time of sale. |
| **shipping_limit_date** | `DATE` | The date and time by which the seller must hand over the package to the logistics carrier. |
