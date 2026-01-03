# 👥 One-Time vs Repeat Customers Analysis

---

## 🧠 Business Question
How many customers made **only one purchase** versus **multiple purchases**, and what does this reveal about customer retention?

---

## 🎯 Why This Matters
- Measures the **health of customer retention**
- Identifies reliance on **one-time buyers vs loyal customers**
- Helps prioritize:
  - Retention campaigns
  - Loyalty programs
  - Post-purchase engagement strategies

---

## 🧩 Data Sources
| Layer | View |
|------|------|
| Gold | `gold.fact_sales` |
| Gold | `gold.dim_customers` |

---

## 🛠️ Business Logic
- Aggregate orders at the **customer_unique_id** level
- Count distinct orders per customer
- Segment customers into:
  - **One-Time Customers** → exactly 1 order
  - **Repeat Customers** → more than 1 order

---

## 📌 Key Results

| Customer Segment | Total Customers |
|------------------|----------------:|
| One-Time Customer | **92,507** |
| Repeat Customer | **2,913** |

---

## 🔍 Key Insights
- **~97% of customers** made only a single purchase
- Repeat customers represent a **very small fraction** of the customer base
- Indicates:
  - Strong acquisition
  - Weak retention
- Significant revenue upside exists by converting even a small portion of one-time buyers into repeat customers

---

## 📊 Business Implications
- High churn after first purchase
- Opportunity to improve:
  - First-order experience
  - Delivery reliability
  - Post-order communication
- Retention improvements could have **outsized impact on revenue**

---

## 🧱 SQL Reference

```sql
WITH CustomerOrders AS (
    SELECT 
        c.customer_unique_id, -- actual unique customers
        COUNT(DISTINCT f.order_key) AS total_orders
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c 
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_unique_id
)
SELECT 
    CASE 
        WHEN total_orders = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS customer_segment,
    COUNT(*) AS total_customers
FROM CustomerOrders
GROUP BY 
    CASE 
        WHEN total_orders = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END
ORDER BY total_customers DESC;
