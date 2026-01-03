# 📦 Average Number of Items per Order

---

## 🧠 Business Question
What is the **average number of items purchased per order**, and how large do orders typically get?

This metric helps assess customer buying behavior and order composition.

---

## 🎯 Why This Matters
- Indicates whether customers:
  - Mostly buy single items
  - Bundle multiple products per order
- Impacts:
  - Inventory planning
  - Packaging and logistics
  - Cross-sell and bundle strategies

---

## 🧩 Data Source
| Layer | View |
|------|------|
| Gold | `gold.fact_sales` |

---

## 🛠️ Business Logic
- Each row in `fact_sales` represents an item within an order
- Items per order are calculated by:
  - Grouping by `order_key`
  - Counting line items per order
- Metrics derived:
  - Average items per order
  - Maximum items in a single order
  - Total orders analyzed

---

## 📊 Key Metrics

| Metric | Value |
|------|------:|
| Average Items per Order | **1.04** |
| Maximum Items in a Single Order | **8** |
| Total Orders Analyzed | **98,666** |

---

## 🔍 Key Insights
- The average order contains **just over 1 item**
- Most customers place **single-item orders**
- A small subset of customers place **large, multi-item orders** (up to 8 items)

---

## 📈 Business Interpretation
- The platform behaves primarily as a **single-item purchase marketplace**
- There is **strong potential for bundling and cross-selling**
- Encouraging multi-item carts could:
  - Increase Average Order Value (AOV)
  - Reduce per-order fulfillment costs

---

## 🧱 SQL Reference

```sql

WITH OrderCounts AS (
    SELECT 
        order_key,
        COUNT(*) AS items_in_order
    FROM gold.fact_sales
    GROUP BY order_key
)
-- Calculate the overall average.
SELECT 
    AVG(CAST(items_in_order AS FLOAT)) AS avg_items_per_order,
    MAX(items_in_order) AS max_items_found_in_one_order,
    COUNT(order_key) AS total_orders_analyzed
FROM OrderCounts;
