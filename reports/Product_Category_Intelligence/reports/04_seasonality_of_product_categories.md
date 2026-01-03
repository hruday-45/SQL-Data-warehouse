# 📅 Seasonality of Product Categories

---

## 🧠 Business Question
What is the **seasonal purchasing pattern** of product categories over time, and how do order volume and revenue vary by month?

---

## 🎯 Why This Matters
Understanding seasonality helps:
- Improve demand forecasting
- Optimize inventory planning
- Align marketing campaigns with peak periods
- Identify categories sensitive to holidays or promotional cycles

---

## 🧩 Data Sources
| Layer | View |
|------|------|
| Gold | `gold.dim_orders` |
| Gold | `gold.fact_sales` |
| Gold | `gold.dim_products` |

---

## 🛠️ Analytical Approach
- Filter for **delivered orders only** to reflect realized sales
- Join orders, sales, and product dimensions
- Aggregate metrics by:
  - Product category
  - Purchase month (`YYYY-MM`)
- Calculate:
  - Monthly order volume
  - Monthly revenue contribution
- Sort chronologically to reveal seasonal trends

---

## 📊 Sample Output

| Product Category | Purchase Month | Total Orders | Monthly Revenue |
|------------------|---------------|-------------:|----------------:|
| beleza_saude | 2016-09 | 1 | 47.82 |
| moveis_decoracao | 2016-10 | 49 | 6,405.60 |
| beleza_saude | 2016-10 | 36 | 3,955.24 |
| perfumaria | 2016-10 | 26 | 4,926.65 |
| brinquedos | 2016-10 | 22 | 4,249.20 |


📁 **Full output:** `reports/Product_Category_Intelligence/full_output/04_seasonality_of_product_categories.csv`

---

## 🔍 Key Insights
- **cama_mesa_banho** shows highest order volume, indicating:
  - High number of purchases in the **2017-11**
- Revenue does not always scale linearly with order count:
  - Some categories have fewer orders but higher average value

---

## 📈 Business Interpretation
- Categories exhibit **distinct seasonal behaviors**:
  - Essential goods → stable demand
  - Discretionary or gifting items → seasonal spikes
- Marketing and logistics strategies should be **category-specific**
- High-revenue months present opportunities for:
  - Cross-selling
  - Seller promotions
  - Inventory pre-stocking

---

## 🧱 SQL Reference

```sql

SELECT 
    ISNULL(p.product_category_name, 'others') AS product_category_name,
    FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS purchase_month, -- Groups by Year and Month
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(f.total_product_value) AS monthly_revenue
FROM gold.dim_orders o
LEFT JOIN gold.fact_sales f ON o.order_key = f.order_key
LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
WHERE o.order_status = 'delivered' -- Focus on successful sales
GROUP BY p.product_category_name, FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
ORDER BY  purchase_month ASC, total_orders DESC;
