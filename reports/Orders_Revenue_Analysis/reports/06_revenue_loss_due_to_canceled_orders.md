# 💸 Revenue Loss Due to Canceled Orders

---

## 🧠 Business Question
How much **revenue is lost** due to **canceled orders**, and what percentage does this represent of total potential revenue?

Understanding cancellation-driven revenue loss helps assess:
- Operational inefficiencies
- Customer friction points
- Financial leakage in the order lifecycle

---

## 🎯 Why This Matters
- Canceled orders incur:
  - Lost revenue
  - Wasted fulfillment and processing effort
- Even small cancellation rates can have:
  - Disproportionate financial impact at scale
- This KPI helps prioritize:
  - Cancellation prevention strategies
  - Checkout and fulfillment improvements

---

## 🧩 Data Sources
| Layer | View |
|------|------|
| Gold | `gold.fact_sales` |
| Gold | `gold.dim_orders` |

---

## 🛠️ Business Logic
- Only orders with `order_status = 'canceled'` are considered
- Metrics calculated:
  - Total canceled orders
  - Gross revenue associated with canceled orders
  - Revenue loss as a percentage of total potential revenue  
    (Delivered + Canceled)

---

## 📊 Key Metrics

| Metric | Value |
|------|------:|
| Total Canceled Orders | 461 |
| Gross Revenue Loss | 93,833.96 |
| % of Total Potential Revenue | **0.63%** |

---

## 🔍 Key Insights
- Canceled orders account for **less than 1%** of total potential revenue
- Financially, cancellations are **not a major revenue drain**
- However, the absolute loss (~94K) is still meaningful in operational terms

---

## 📈 Business Interpretation
- A **0.63% revenue loss** indicates:
  - Strong order completion performance
  - Low financial exposure to cancellations
- That said:
  - Preventing even a fraction of cancellations can directly improve margins
  - High-value cancellations may still warrant deeper analysis

---

## 🔎 Recommended Deep-Dives
- Revenue loss by:
  - Product category
  - Seller
  - Customer state
- Compare:
  - Cancellation rates for high-value vs low-value orders
- Investigate root causes:
  - Payment failures
  - Stock issues
  - Delivery promise gaps

---

## 🧱 SQL Reference

```sql

SELECT 
    COUNT(DISTINCT f.order_key) AS total_canceled_orders,
    SUM(f.total_product_value) AS gross_revenue_loss,
    -- Comparing it to total potential revenue (Delivered + Canceled)
    CAST(100.0 * SUM(f.total_product_value) / 
        (SELECT SUM(total_product_value) FROM gold.fact_sales) AS DECIMAL(5,2)) AS pct_of_total_potential_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_orders o ON f.order_key = o.order_key
WHERE o.order_status = 'CANCELED';
