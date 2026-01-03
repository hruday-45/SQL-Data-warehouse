# 💰 Distribution of Order Values (Low / Medium / High)

---

## 🧠 Business Question
What is the **distribution of order values** across low, medium, high, and very high purchase amounts?

This analysis segments orders into value buckets to understand purchasing behavior and revenue concentration.

---

## 🎯 Why This Matters
- Helps identify:
  - Core revenue-driving order segments
  - High-value customer behavior
- Supports:
  - Pricing strategy
  - Promotion targeting
  - Revenue optimization

---

## 🧩 Data Source
| Layer | View |
|------|------|
| Gold | `gold.fact_sales` |

---

## 🛠️ Business Logic
- Orders are categorized based on `total_product_value`
- Value buckets:
  - **Low**: < 50
  - **Medium**: 50 – 200
  - **High**: 200 – 500
  - **Very High**: > 500
- Metrics calculated:
  - Total number of orders
  - Total revenue per bucket
  - % of total orders
  - % of total revenue

---

## 📊 Key Metrics

| Order Value Category | Total Orders | Total Revenue | Order % | Revenue % |
|---------------------|-------------:|--------------:|--------:|----------:|
| Low Value (< 50) | 20,261 | 742,187.74 | 19.78% | 5.01% |
| Medium Value (50 – 200) | 64,938 | 6,873,813.29 | 63.40% | 46.43% |
| High Value (200 – 500) | 13,662 | 3,906,698.83 | 13.34% | 26.39% |
| Very High Value (> 500) | 3,564 | 3,281,108.92 | 3.48% | 22.16% |

---

## 🔍 Key Insights
- **Medium-value orders dominate volume**, accounting for:
  - ~63% of all orders
  - ~46% of total revenue
- **Very high-value orders**:
  - Represent only **3.5% of orders**
  - Contribute **over 22% of revenue**
- Low-value orders are frequent but **revenue-light**

---

## 📈 Business Interpretation
- Revenue is **highly concentrated** in higher-value orders
- Upselling customers from:
  - Low → Medium
  - Medium → High
  can significantly increase total revenue
- High and very high value segments should receive:
  - Priority logistics
  - Loyalty incentives
  - Personalized offers

---

## 🧱 SQL Reference

```sql

WITH OrderBuckets AS (
    SELECT 
        order_key,
        total_product_value,
        CASE 
            WHEN total_product_value < 50 THEN '1. Low Value (< 50)'
            WHEN total_product_value BETWEEN 50 AND 200 THEN '2. Medium Value (50 - 200)'
            WHEN total_product_value BETWEEN 200 AND 500 THEN '3. High Value (200 - 500)'
            ELSE '4. Very High Value (> 500)'
        END AS value_category
    FROM gold.fact_sales
)
SELECT 
    value_category,
    COUNT(order_key) AS total_orders,
    SUM(total_product_value) AS total_revenue,
    -- Calculate the percentage of orders in each bucket
    CAST(100.0 * COUNT(order_key) / SUM(COUNT(order_key)) OVER() AS DECIMAL(5,2)) AS order_pct,
    -- Calculate the percentage of total revenue in each bucket
    CAST(100.0 * SUM(total_product_value) / SUM(SUM(total_product_value)) OVER() AS DECIMAL(5,2)) AS revenue_pct
FROM OrderBuckets
GROUP BY value_category
ORDER BY value_category;
