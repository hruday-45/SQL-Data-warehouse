# 📦 Average Order Value (AOV) by Customer State

---

## 🧠 Business Question
Which customer states generate the **highest average order value (AOV)**, and how does customer spending vary geographically?

---

## 🎯 Why This Matters
- Identifies **high-value regions** for targeted marketing
- Supports **regional pricing and promotion strategies**
- Helps optimize **logistics, inventory, and seller expansion**
- Enables smarter **customer segmentation by geography**

---

## 🧩 Data Sources
| Layer | View |
|------|------|
| Gold | `gold.fact_sales` |
| Gold | `gold.dim_customers` |

---

## 🛠️ Business Logic
For each customer state:
- Count distinct orders
- Sum total product revenue
- Calculate **Average Order Value (AOV)** as:
- Results are ordered by **highest AOV first**.

---

## 📌 Key Metrics (Top States by AOV)

| State | Total Orders | Total Revenue | Average Order Value |
|------|--------------|---------------|---------------------|
| PB | 532 | 132,132.78 | **248.37** |
| AC | 81 | 18,467.42 | **227.99** |
| RO | 247 | 55,810.19 | **225.95** |
| AL | 411 | 92,257.08 | **224.47** |
| PA | 970 | 206,946.70 | **213.35** |

📁 **Full output:** `reports/Business_Reports/full_output/08_AOV_by_customer_state.csv`

---

## 🔍 Key Insights
- **Paraíba (PB)** leads with the highest AOV despite moderate order volume
- States with **lower order counts** (PR, AP) still show strong purchasing power
- High AOV does not always correlate with high order volume
- Indicates opportunity to:
  - Increase customer acquisition in high-AOV regions
  - Customize promotions for lower-volume, high-value states

---

## 📊 Business Use Cases
- Regional marketing and campaign targeting
- Customer lifetime value (LTV) segmentation by geography
- Strategic warehouse and logistics planning
- Revenue forecasting by region

---

## 🧱 SQL Reference

```sql
SELECT 
    c.customer_state,
    COUNT(DISTINCT f.order_key) AS total_orders,
    SUM(f.total_product_value) AS total_revenue,
    SUM(f.total_product_value) / COUNT(DISTINCT f.order_key) AS average_order_value
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c 
    ON f.customer_key = c.customer_key
GROUP BY c.customer_state
ORDER BY average_order_value DESC;

