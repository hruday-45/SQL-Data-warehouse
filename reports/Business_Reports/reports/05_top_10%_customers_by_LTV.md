# 💎 Top 10% Customers by Lifetime Value (LTV)

---

## 🧠 Business Question
Who are the top 10% of customers by total lifetime spend, and how concentrated is revenue among high-value customers?

---

## 🎯 Why This Matters
- Identifies **high-value customers** who drive a disproportionate share of revenue
- Enables **targeted retention and loyalty strategies**
- Helps prioritize **VIP treatment, personalized offers, and CRM efforts**
- Supports revenue concentration and Pareto (80/20) analysis

---

## 🧩 Data Sources
| Layer | View |
|------|------|
| Gold | `gold.fact_sales` |
| Gold | `gold.dim_customers` |

---

## 🛠️ Logic Overview
- Aggregates total lifetime spend per `customer_unique_id`
- Ranks customers by descending total spend
- Selects customers falling within the **top 10%** by spend rank
- Uses window functions for scalable percentile logic

---

## 📌 Key Metrics
| Metric | Value |
|------|------|
| Total Customers | 95,420 |
| Top Segment Size (10%) | 9,542 customers |
| Ranking Method | Revenue-based (descending) |

---

## 🔍 Key Insights
- A small group of customers contributes **significantly higher lifetime value**
- Top spenders show **5–10× higher value** than average customers
- These customers are prime candidates for:
  - Loyalty programs
  - Early access & premium benefits
  - Personalized recommendations
- Revenue concentration suggests **retention of top customers is critical**

---

## 📊 Sample Output
*(Preview of top LTV customers — truncated for readability)*

| customer_unique_id | total_spend |
|-------------------|-------------|
| da122df9eeddfedc1dc1f5349a1a690c | 7,571.63 |
| dc4802a71eae9be1dd28f5d788ceb526 | 6,929.31 |
| 459bef486812aa25204be022145caa62 | 6,922.21 |
| ff4159b92c40ebe40454e3e6a7c35ed6 | 6,726.66 |
| eebb5dda148d3893cdaf5b5ca3040ccb | 4,764.34 |
| .... | .... |

---

## 🧪 Data Quality Checks
- ✔ Used `customer_unique_id` to prevent duplicate customer counting
- ✔ Ensured all revenue values are aggregated at customer grain
- ✔ Window functions validated against total customer count

---

## 🧱 SQL Reference

```sql
WITH RankedCustomers AS (
    SELECT 
        c.customer_unique_id,
        SUM(f.total_product_value) AS total_spend,
        ROW_NUMBER() OVER (
            ORDER BY SUM(f.total_product_value) DESC
        ) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c 
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_unique_id
),
Result AS (
    SELECT *
    FROM RankedCustomers
    WHERE row_num <= (total_count * 0.10)
)
SELECT
    customer_unique_id,
    total_spend
FROM Result;
