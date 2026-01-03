# 🚪 Customer Churn After First Order

---

## 🧠 Business Question
What **percentage of customers churn after their first order**, meaning they never return to make a second purchase?

---

## 🎯 Why This Matters
- Measures **early-stage churn**, one of the most critical growth metrics
- Highlights whether customers:
  - Are satisfied with their first experience
  - Find enough value to return
- Helps prioritize improvements in:
  - Onboarding
  - Delivery experience
  - Product quality
  - Post-purchase engagement

---

## 🧩 Data Sources
| Layer | View |
|------|------|
| Gold | `gold.fact_sales` |
| Gold | `gold.dim_customers` |

---

## 🛠️ Business Logic
- Aggregate orders at the **customer_unique_id** level
- Identify customers with **exactly one order**
- Calculate:
  - Total unique customers
  - Churned customers (1 order only)
  - Churn rate percentage

---

## 📌 Key Metrics

| Metric | Value |
|------|------:|
| Total Unique Customers | 95,420 |
| Customers Churned After 1st Order | 89,631 |
| **Churn Rate** | **93.93%** |

---

## 🔍 Key Insights
- Nearly **94% of customers churn after their first purchase**
- Confirms:
  - Extremely weak early retention
  - Revenue heavily depends on new customer acquisition
- Aligns with earlier findings:
  - Low repeat purchase rate
  - Long gap between first and second purchase

---

## 📊 Business Implications
- Improving first-order experience could have **massive ROI**
- Even a **5–10% reduction in churn** would significantly boost:
  - Repeat revenue
  - Customer lifetime value (LTV)
- Focus areas:
  - Delivery reliability
  - Accurate product descriptions
  - Faster support resolution

---

## 🧱 SQL Reference

```sql

WITH CustomerStats AS (
    SELECT 
        c.customer_unique_id,
        COUNT(f.order_key) AS total_orders
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
    GROUP BY c.customer_unique_id
)
SELECT 
    COUNT(*) AS total_unique_customers,
    -- customers with only 1 order
    SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END) AS churned_customers,
    -- percentage calculation
    CAST(100.0 * SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2)) AS churn_rate_percent
FROM CustomerStats;
