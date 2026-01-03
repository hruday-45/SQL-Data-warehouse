# 📊Olist Brazil Business Overview

This repository contains an analysis of Olist Brazil's e-commerce dataset. Below is a high-level business summary based on sales, customers, and products.

---

## 📌Key Business Metrics

| Metric | Value |
|--------|-------|
| **Total Unique Customers** | 96,097 |
| **Total Customer Profiles** | 99,442 |
| **Total Products in Catalog** | 32,952 |
| **Total Orders** | 98,666 |
| **Average Price per Item Sold** | 124.42 BRL |
| **Total Quantity of Items Sold** | 102,425 |
| **Total Sales Revenue** | 14,803,808.78 BRL |

---

## 📝Summary

- **Customer Base:** Olist has ~96k unique customers, with slightly more profiles in their database including inactive users.  
- **Product Catalog:** Over 32k distinct products are available for purchase across multiple categories.  
- **Sales Performance:** Nearly 99k orders were completed, generating total revenue of ~14.8 million BRL, with an average item price of ~124 BRL.  
- **Volume:** A total of 102k items were sold, indicating that many orders contain multiple items.  

---

## 🔍Insights for Stakeholders

- The average price of items suggests a mix of low- and high-ticket products.  
- With nearly all customer profiles active, Olist has a strong foundation for marketing campaigns to increase repeat purchases.  
- Product catalog size indicates broad coverage, providing opportunities for upselling and cross-selling.

---

## 🧱 SQL Reference

```sql

-- 1. Total Unique Customers who placed an order
SELECT 'Total Customers Unique' AS metric_name, COUNT(DISTINCT customer_unique_id) AS metric_value
FROM gold.dim_customers

UNION ALL

-- 2. Total Customer Profiles (including those who haven't ordered yet)
SELECT 'Total Customer Profiles', COUNT(customer_key)
FROM gold.dim_customers

UNION ALL

-- 3. Total Distinct Products in Catalog
SELECT 'Total Products', COUNT(DISTINCT product_key)
FROM gold.dim_products

UNION ALL

-- 4. Total Orders (excluding canceled/unavailable if desired)
SELECT 'Total Orders', COUNT(DISTINCT order_key)
FROM gold.fact_sales
WHERE order_key <> -1 -- Filtering out system noise

UNION ALL

-- 5. Average Price per Item Sold
SELECT 'Average Price', AVG(product_price)
FROM gold.fact_sales

UNION ALL

-- 6. Total Quantity of Items Sold 
SELECT 'Total Quantity Sold', COUNT(*)
FROM gold.fact_sales

UNION ALL

-- 7. Total Gross Sales (Revenue)
SELECT 'Total Sales Revenue', SUM(total_product_value)
FROM gold.fact_sales;
