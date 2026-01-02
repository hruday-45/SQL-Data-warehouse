# 📖 Data Catalog: Olist E-Commerce Dataset

This catalog describes the raw files stored in the `/datasets` (Bronze Layer) directory.

| File Name | Description |
| :--- | :--- |
| `olist_customers_dataset.csv` | Information about customers and their locations. |
| `olist_geolocation_dataset.csv` | Brazilian zip codes with lat/long coordinates. |
| `olist_order_items_dataset.csv` | Product, price, and freight details for each order. |
| `olist_order_payments_dataset.csv` | Payment methods, installments, and transaction values. |
| `olist_order_reviews_dataset.csv` | Customer feedback and satisfaction scores. |
| `olist_orders_dataset.csv` | The central table linking all order lifecycle events. |
| `olist_products_dataset.csv` | Product categories, weights, and dimensions. |
| `olist_sellers_dataset.csv` | Seller location and ID information. |

---


# 📊 Gold Layer Data Dictionary

## Overview
The **Gold Layer** is the business-level data representation, structured to support analytical and reporting use cases. It consists of dimension tables and fact tables for specific business metrics.

## 1. Dimensions (The Context)

### 👥 `gold.dim_customers`

**Description:** This dimension table provides a single source of truth for customer attributes. It consolidates demographic data with calculated loyalty metrics to support RFM segmentation and geographic analysis.

| Column Name | Data Type | Description | Examples |
| :--- | :--- | :--- | :--- |
| **customer_key** | `int` | Unique surrogate key generated for the Gold layer. | `81684`, `10245` |
| **customer_id** | `nvarchar(50)` | The unique ID for a specific order's customer record. | `06b2a99e...`, `ad345...` |
| **customer_unique_id** | `nvarchar(50)` | The permanent ID that links a physical person across all their orders. | `861eff47...`, `7c396...` |
| **customer_city** | `nvarchar(50)` | Name of the city where the customer is located. | `sao paulo`, `rio de janeiro` |
| **customer_state** | `nvarchar(2)` | Two-letter state abbreviation for Brazil. | `SP`, `RJ`, `MG`, `PR` |
| **customer_zip_code_prefix** | `int` | First five digits of the Brazilian zip code. Note: Leading zeros are dropped due to Integer storage. | `14409`, `1001` |
| **latitude** | `decimal(9,6)` | Geographic latitude coordinate for mapping. | `-23.550520` |
| **longitude** | `decimal(9,6)` | Geographic longitude coordinate for mapping. | `-46.633308` |
| **first_order_date** | `date` | Timestamp of the first purchase made by the customer. | `2017-01-15` |
| **last_order_date** | `date` | Timestamp of the most recent purchase made. | `2018-08-22` |
| **total_orders** | `int` | Total count of distinct orders placed by the person. | `1`, `2`, `5` |
| **is_repeat_customer** | `varchar(3)` | Flag indicating if the customer has $>1$ order. | `Yes`, `No` |
| **customer_tenure_days** | `int` | Total days elapsed between first and last purchase. | `0`, `150`, `432` |

#### 💡 Implementation Notes
- **Granularity:** One row per `customer_unique_id`.
- **Joins:** Connects to `gold.fact_sales` via the `customer_key`.
- **Logic:** `is_repeat_customer` is calculated during the ETL process based on the `total_orders` count to simplify filtering in Tableau.


### 📅 `gold.dim_date`

**Description:** This dimension table provides a robust framework for time-series analysis. It enables the business to group and filter data by standard calendar attributes (Month, Year, Quarter) and specific business logic flags such as weekends and national holidays.

| Column Name | Data Type | Description | Examples |
| :--- | :--- | :--- | :--- |
| **date_key** | `int` | Primary surrogate key for the date (format: YYYYMMDD). | `20170115`, `20180822` |
| **date** | `date` | The actual calendar date. | `2017-01-15`, `2018-08-22` |
| **day** | `int` | Day of the month. | `1`, `15`, `31` |
| **week** | `int` | ISO week number of the year. | `1`, `24`, `52` |
| **month** | `int` | Numeric representation of the month. | `1`, `8`, `12` |
| **month_name** | `nvarchar(30)` | Full name of the month. | `January`, `August` |
| **quarter** | `int` | Calendar quarter (1-4). | `1`, `2`, `3`, `4` |
| **year** | `int` | Four-digit calendar year. | `2016`, `2017`, `2018` |
| **is_weekend** | `int` | Flag indicating if the date is a Saturday or Sunday (1=Yes, 0=No). | `1`, `0` |
| **is_holiday_brazil_flag** | `int` | Flag indicating if the date is a Brazilian national holiday. | `1`, `0` |

#### 💡 Implementation Notes
- **Granularity:** One row per day.
- **Joins:** Frequently joined to `gold.fact_sales` on `order_date_key`, `payment_date_key`, and `delivery_date_key`.
- **Primary Use Case:** Essential for calculating Month-over-Month (MoM) growth and identifying sales performance spikes during holiday seasons like Black Friday.


### 📍 `gold.dim_location`

**Description:** This geographic dimension table provides a normalized reference for all location-based analysis. It allows for hierarchical reporting from the zip code level up to the regional level and supports mapping through latitude and longitude coordinates.

| Column Name | Data Type | Description | Examples |
| :--- | :--- | :--- | :--- |
| **location_key** | `int` | Unique surrogate key for each specific location. | `1`, `4502` |
| **geolocation_zip_code_prefix** | `int` | First five digits of the Brazilian zip code. Note: Leading zeros are dropped due to Integer storage. | `1001`, `20000` |
| **city** | `nvarchar(max)` | Full name of the city. | `sao Paulo`, `rio de janeiro` |
| **state_code** | `nvarchar(2)` | Two-letter state abbreviation. | `SP`, `RJ`, `BA` |
| **state_name** | `nvarchar(50)` | Full name of the Brazilian state. | `São Paulo`, `Bahia` |
| **region_name** | `nvarchar(20)` | Macro-region of Brazil. | `Southeast`, `Northeast` |
| **latitude** | `decimal(9,6)` | Geographic latitude coordinate for map plotting. | `-23.550520` |
| **longitude** | `decimal(9,6)` | Geographic longitude coordinate for map plotting. | `-46.633308` |

#### 💡 Implementation Notes
- **Granularity:** One row per unique zip code prefix.
- **Joins:** Connects to `gold.dim_customers` and `gold.dim_sellers` to enrich geographic insights.
- **Tableau Use Case:** Used to build geographic heatmaps to identify high-density sales regions and calculate average shipping distances.


### 📦 `gold.dim_orders`

**Description:** This dimension table contains the header-level information for every order. It provides critical timestamps and status flags required to calculate logistics KPIs and delivery performance metrics.

| Column Name | Data Type | Description | Examples |
| :--- | :--- | :--- | :--- |
| **order_key** | `int` | Unique surrogate key for the order in the Gold layer. | `41`, `1024` |
| **order_id** | `nvarchar(50)` | The unique alphanumeric ID of the order from the source system. | `e481f51c...`, `53cdb...` |
| **customer_id** | `nvarchar(50)` | Source ID linking the order to a specific customer record. | `9ef432eb...`, `b0830...` |
| **order_status** | `nvarchar(30)` | The current state of the order lifecycle. | `DELIVERED`, `SHIPPED`, `CANCELED` |
| **order_purchase_timestamp** | `datetime2(0)` | The exact timestamp when the order was placed. | `2017-10-02 10:56:33` |
| **order_approved_at** | `datetime2(0)` | The timestamp when the payment was approved. | `2017-10-02 11:07:15` |
| **order_delivered_carrier_date** | `datetime2(0)` | The timestamp when the order was handled to the carrier. | `2017-10-04 19:55:00` |
| **order_delivered_customer_date** | `datetime2(0)` | The actual date/time the customer received the product. | `2017-10-10 21:25:13` |
| **order_estimated_delivery_date**| `datetime2(0)` | The promised delivery date provided at purchase. | `2017-10-18 00:00:00` |
| **delivery_performance_status** | `varchar(17)` | Calculated status comparing actual vs estimated delivery. | `On Time`, `Late` |

#### 💡 Implementation Notes
- **Granularity:** One row per `order_id`.
- **Primary Use Case:** Tracking the "Order Funnel" (Time to Approve $\rightarrow$ Time to Ship $\rightarrow$ Time to Deliver).
- **Performance Logic:** The `delivery_performance_status` is pre-calculated to allow for instant filtering of "Late" orders in Tableau dashboards without needing complex DATEDIFF calculations at runtime.


### 📦 `gold.dim_products`

**Description:** This dimension table contains detailed technical specifications and categorization for all products in the marketplace. It includes localized category names and physical dimensions essential for shipping cost analysis.

| Column Name | Data Type | Description | Examples |
| :--- | :--- | :--- | :--- |
| **product_key** | `int` | Unique surrogate key for the product in the Gold layer. | `1`, `5420` |
| **product_id** | `nvarchar(50)` | The unique alphanumeric ID of the product from the source system. | `1e9e8ef0...`, `3aa07...` |
| **product_category_name** | `nvarchar(50)` | Product category name in the original language (Portuguese). | `perfumaria`, `informatica_acessorios` |
| **product_category_name_english** | `nvarchar(50)` | Translated product category name for international reporting. | `perfumery`, `computers_accessories` |
| **product_weight_g** | `int` | Product weight measured in grams. | `225`, `1000`, `15000` |
| **product_length_cm** | `int` | Length of the product package in centimeters. | `16`, `30`, `50` |
| **product_height_cm** | `int` | Height of the product package in centimeters. | `10`, `15`, `25` |
| **product_width_cm** | `int` | Width of the product package in centimeters. | `14`, `20`, `30` |
| **product_volume_cm3** | `decimal(10,2)` | Calculated total volume ($L \times H \times W$) of the product. | `2240.00`, `9000.00` |

#### 💡 Implementation Notes
- **Granularity:** One row per `product_id`.
- **Category Localization:** Both Portuguese and English names are provided to support localized and global dashboards.
- **Logistics Analysis:** The physical dimensions (`weight`, `volume`) are used to audit shipping costs and carrier performance in the `gold.fact_sales` table.


### 🏪 `gold.dim_sellers`

**Description:** This dimension table contains details about the sellers operating in the Olist marketplace. It includes geographic locations and surrogate keys used to link seller performance back to the central fact tables for logistics and sales analysis.

| Column Name | Data Type | Description | Examples |
| :--- | :--- | :--- | :--- |
| **seller_key** | `int` | Unique surrogate key generated for the Gold layer. | `1054`, `982` |
| **seller_id** | `nvarchar(50)` | The unique alphanumeric ID of the seller from the source system. | `3442f895...`, `d1b65...` |
| **seller_city** | `nvarchar(50)` | Name of the city where the seller is based. | `Curitiba`, `Belo Horizonte` |
| **seller_state** | `nvarchar(2)` | Two-letter state abbreviation for the seller's location. | `PR`, `MG`, `SP` |
| **seller_zip_code_prefix** | `int` | First five digits of the Brazilian zip code. Note: Leading zeros are dropped due to Integer storage. | `80020`, `30110` |
| **latitude** | `decimal(9,6)` | Geographic latitude for seller location mapping. | `-25.428400` |
| **longitude** | `decimal(9,6)` | Geographic longitude for seller location mapping. | `-49.273300` |

#### 💡 Implementation Notes
- **Granularity:** One row per unique `seller_id`.
- **Joins:** Connects to `gold.fact_sales` via the `seller_key`.
- **Logistics Insights:** Essential for calculating "Seller-to-Customer" distances and identifying regional hubs with high seller concentrations.

---

## 2. Facts (The Metrics)

### 💳 `gold.fact_payments`

**Description:** This fact table records all payment transactions associated with orders. It is designed at a **Transaction Grain**, meaning a single order may have multiple rows if the customer used split payment methods (e.g., combining a credit card with a voucher) or multiple installments.

| Column Name | Data Type | Description | Examples |
| :--- | :--- | :--- | :--- |
| **order_key** | `int` | Surrogate key linking to `dim_orders`. | `41`, `1024` |
| **customer_key** | `int` | Surrogate key linking to `dim_customers`. | `81684`, `5501` |
| **order_approved_at** | `date` | Date the payment transaction was officially approved. | `2017-10-02`, `2018-05-14` |
| **payment_value** | `decimal(10,2)` | The monetary value of this specific payment transaction. | `44.11`, `33.18`, `127.50` |
| **payment_installments** | `int` | Number of installments chosen by the customer. | `1`, `10`, `24` |
| **payment_type** | `nvarchar(20)` | The method used for payment. | `credit card`, `boleto`, `voucher` |

#### 💡 Implementation Notes
- **Granularity:** Transaction level. An `order_key` can appear multiple times if split payments occur.
- **Reporting Use Case:** Essential for financial audits, analyzing payment method popularity, and studying the impact of installments on Average Order Value (AOV).
- **Data Integrity:** When joining with `gold.fact_sales`, use **Relationships** or **Fixed LODs** in Tableau to prevent accidental duplication of sales revenue due to the many-to-one payment relationship.


### ⭐ `gold.fact_reviews`

**Description:** This fact table stores customer feedback and satisfaction data. It tracks review scores and provides metrics for operational responsiveness by measuring the time elapsed between a review being posted and the seller's response.

| Column Name | Data Type | Description | Examples |
| :--- | :--- | :--- | :--- |
| **order_key** | `int` | Unique surrogate key linking to `dim_orders`. | `41`, `1024` |
| **customer_key** | `int` | Unique surrogate key linking to `dim_customers`. | `81684`, `5501` |
| **review_date** | `date` | The date the customer submitted the review. | `2018-01-20` |
| **avg_review_score** | `decimal(38,6)` | The satisfaction score provided (usually 1 to 5). | `5.000000`, `1.000000` |
| **latest_review_date** | `datetime2(0)` | Timestamp of the most recent review for the order. | `2018-01-20 14:02:11` |
| **latest_answer_timestamp** | `datetime2(0)` | Timestamp when the seller/system replied to the review. | `2018-01-22 10:45:00` |
| **review_response_lag_days** | `int` | Days elapsed between review and answer. | `2`, `0`, `15` |

#### 💡 Implementation Notes
- **Granularity:** One row per review event.
- **Sentiment Analysis:** Use `avg_review_score` to build Net Promoter Score (NPS) equivalents (e.g., 4-5 = Promoter, 1-2 = Detractor).
- **Service KPI:** `review_response_lag_days` is a critical operational metric; shorter lag times generally correlate with higher customer retention in future orders.


### 💰 `gold.fact_sales`

**Description:** This is the primary fact table for the Olist data warehouse. It is structured at a line-item granularity, containing transactional values, logistics performance metrics, and order lifecycle flags. It serves as the single source of truth for revenue and shipping KPIs.

| Column Name | Data Type | Description | Examples |
| :--- | :--- | :--- | :--- |
| **order_key** | `int` | Surrogate key linking to `dim_orders`. | `41`, `1024` |
| **customer_key** | `int` | Surrogate key linking to `dim_customers`. | `81684`, `5501` |
| **seller_key** | `int` | Surrogate key linking to `dim_sellers`. | `1054`, `982` |
| **product_key** | `int` | Surrogate key linking to `dim_products`. | `1415`, `2203` |
| **product_price** | `decimal(10,2)` | Selling price of a single unit. | `24.89`, `120.00` |
| **freight_value** | `decimal(10,2)` | Freight value of the item. | `17.63`, `12.50` |
| **total_product_value** | `decimal(11,2)` | Sum of product price and freight. | `42.52`, `132.50` |
| **total_order_payment** | `decimal(38,2)` | Total payment amount for the entire order. | `127.56`, `500.20` |
| **order_status** | `nvarchar(30)` | Current status of the order. | `DELIVERED`, `SHIPPED` |
| **order_purchase_timestamp**| `date` | Date the order was placed. | `2017-12-27` |
| **order_approved_at** | `date` | Date the payment was approved. | `2017-12-28` |
| **order_delivered_carrier_date**| `date` | Date item was handed to carrier. | `2018-01-05` |
| **order_delivered_customer_date**| `date` | Date item reached the customer. | `2018-01-17` |
| **total_delivery_days** | `int` | Total days from purchase to delivery. | `21`, `5`, `12` |
| **seller_processing_days** | `int` | Days taken by seller to ship the order. | `1`, `3`, `9` |
| **carrier_transit_days** | `int` | Days the package was with the carrier. | `20`, `4`, `10` |
| **delivery_delay_days** | `int` | Days past estimated delivery date. | `0`, `2`, `-5` |
| **is_shipped_flag** | `int` | 1 if shipped, 0 otherwise. | `1`, `0` |
| **is_delivered_flag** | `int` | 1 if delivered, 0 otherwise. | `1`, `0` |
| **is_late_delivery_flag** | `int` | 1 if delivered after estimate, 0 otherwise. | `0`, `1` |

#### 💡 Implementation Notes
- **Granularity:** Line-item level (one row per item within an order).
- **Logistics Logic:** `delivery_delay_days` is calculated against the `order_estimated_delivery_date` in the Silver layer to determine if an order is late.
- **Reporting Use Case:** This table is the main driver for **Executive Dashboards**, **Logistics Bottleneck Analysis**, and **Revenue Growth Trends**.
