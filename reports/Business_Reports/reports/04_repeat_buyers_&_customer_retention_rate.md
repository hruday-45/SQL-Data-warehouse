# 🔁 Repeat Buyers & Customer Retention Rate

---

## 🧠 Business Question
What percentage of customers return to make more than one purchase, and how strong is overall customer retention?

---

## 🎯 Why This Matters
- Measures **customer loyalty** and satisfaction
- Indicates effectiveness of **customer experience and fulfillment**
- Helps evaluate **long-term revenue sustainability**
- Critical input for **CRM, retention, and marketing strategies**

---

## 🧩 Data Sources
| Layer | View |
|------|------|
| Gold | `gold.fact_sales` |
| Gold | `gold.dim_customers` |

---

## 🛠️ Logic Overview
- Counts distinct orders per customer using `customer_unique_id`
- Classifies customers into:
  - One-time buyers
  - Repeat buyers (more than one order)
- Calculates retention rate as the percentage of repeat buyers among all customers

---

## 📌 Key Metrics
| Metric | Value |
|------|------|
| Total Unique Customers | 95,420 |
| Repeat Buyers | 2,913 |
| Retention Rate | 3.05% |

---

## 🔍 Key Insights
- Only **3.05%** of customers made more than one purchase
- The marketplace is largely driven by **one-time buyers**
- Indicates a **strong acquisition engine** but weak repeat engagement
- Highlights a major opportunity for:
  - Loyalty programs
  - Post-purchase engagement
  - Improved delivery and service experience

---

## 📊 Output

| total_unique_customers | repeat_buyers | retention_rate_percentage |
|------------------------|---------------|---------------------------|
| 95,420 | 2,913 | 3.05 |

---

## 🧪 Data Quality Checks
- ✔ Used `customer_unique_id` to correctly track repeat behavior
- ✔ Ensured distinct `order_key` counting
- ✔ Verified no null customer identifiers

---

## 🧱 SQL Reference

```sql
WITH OrderCounts AS (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT f.order_key) AS order_count
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c 
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_unique_id
)
SELECT 
    COUNT(*) AS total_unique_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_buyers,
    (CAST(SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 
        AS retention_rate_percentage
FROM OrderCounts;

