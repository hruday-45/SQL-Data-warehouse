# 📉 High Order Volume but Low Revenue by Customer State

---

## 🧠 Business Question
Which customer states generate **high order volumes** but **low average revenue per order**, indicating potential pricing, product-mix, or discounting issues?

---

## 🎯 Why This Matters
- Highlights regions with **strong demand but weak monetization**
- Identifies opportunities to:
  - Improve pricing strategies
  - Upsell higher-value products
  - Optimize promotional effectiveness
- Supports regional profitability analysis beyond raw order counts

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
- Calculate **State Average Order Value (AOV)**

Filters applied:
- States with **more than 2,000 orders**
- States with **AOV below 170**

Results are ordered by **highest order volume**.

---

## 📌 Key Metrics (High Volume, Low AOV States)

| State | Total Orders | Total Revenue | State AOV |
|------|-------------:|--------------:|----------:|
| SP | 41,375 | 5,534,919.01 | **133.77** |
| RJ | 12,762 | 1,985,032.34 | **155.54** |
| MG | 11,544 | 1,740,465.48 | **150.77** |
| RS | 5,432 | 825,079.13 | **151.89** |
| PR | 4,998 | 739,428.92 | **147.94** |
| SC | 3,612 | 565,692.13 | **156.61** |
| BA | 3,358 | 566,543.39 | **168.71** |
| DF | 2,125 | 334,941.87 | **157.62** |
| ES | 2,025 | 304,734.98 | **150.49** |
| GO | 2,007 | 318,632.69 | **158.76** |

---

## 🔍 Key Insights
- **São Paulo (SP)** dominates order volume but has the **lowest AOV**, pulling down overall revenue efficiency
- Large markets (RJ, MG) show similar patterns: high demand, moderate spend per order
- These regions likely rely on:
  - Low-ticket items
  - Heavy discounting
  - High promotional activity
- Small AOV improvements in these states could yield **significant revenue gains**

---

## 📊 Business Use Cases
- Regional pricing and discount optimization
- Bundling and cross-sell strategies
- Product mix rebalancing
- Revenue uplift modeling in high-traffic regions

---

## 🧱 SQL Reference
📄 `sql/business/high_volume_low_revenue_states.sql`

```sql
SELECT 
    c.customer_state,
    COUNT(DISTINCT f.order_key) AS total_orders,
    SUM(f.total_product_value) AS total_revenue,
    SUM(f.total_product_value) / COUNT(DISTINCT f.order_key) AS state_aov
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_state
-- for states with > 2000 orders but AOV < $170
HAVING COUNT(DISTINCT f.order_key) > 2000 
   AND (SUM(f.total_product_value) / COUNT(DISTINCT f.order_key)) < 170
ORDER BY total_orders DESC;
