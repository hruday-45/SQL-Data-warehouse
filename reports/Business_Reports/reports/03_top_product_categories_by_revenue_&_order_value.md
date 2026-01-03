# 🛒 Top Product Categories by Revenue & Order Value

---

## 🧠 Business Question
Which product categories contribute the most to total revenue, and how do their order values compare?

---

## 🎯 Why This Matters
- Helps identify **core revenue drivers**
- Supports **category-level investment and promotion decisions**
- Enables **pricing and assortment optimization**
- Informs vendor and inventory strategy

---

## 🧩 Data Sources
| Layer | View |
|------|------|
| Gold | `gold.fact_sales` |
| Gold | `gold.dim_products` |

---

## 🛠️ Logic Overview
- Aggregates sales at the **product category level**
- Calculates total revenue and distinct order counts
- Derives Average Order Value (AOV) per category
- Sorts categories by total revenue contribution

---

## 📌 Key Metrics
| Metric | Value |
|------|------|
| Total Categories Analyzed | 74 |
| Top Revenue Category | `beleza_saude` |
| Highest AOV Category | `pcs` |

---

## 🔍 Key Insights
- **`beleza_saude`** leads in total revenue, driven by high order volume
- **`pcs`** generates the highest AOV among top categories, indicating premium purchases
- Categories with higher AOV tend to have **lower order volume**, suggesting targeted, high-value purchases

---

## 📊 Sample Output
*(Top 5 categories by revenue)*

<details>
<summary>📊 Click to expand category revenue breakdown</summary>

| Product Category | Total Orders | Total Revenue | Avg Order Value |
|------------------|-------------|---------------|-----------------|
| beleza_saude | 8,836 | 1,384,783.71 | 156.72 |
| relogios_presentes | 5,624 | 1,285,040.70 | 228.49 |
| cama_mesa_banho | 9,417 | 1,151,657.81 | 122.30 |
| esporte_lazer | 7,720 | 1,084,444.87 | 140.47 |
| informatica_acessorios | 6,689 | 936,674.78 | 140.03 |
| .... | .... | .... | .... |

</details>

📁 **Full output:** `/reports/business/top_product_categories.csv`

---

## 🧪 Data Quality Checks
- ✔ Ensured distinct `order_key` usage to prevent double counting
- ✔ Verified non-null category mappings
- ✔ Revenue values validated to be non-negative

---

## 🧱 SQL Reference

```sql
SELECT 
    p.product_category_name,
    COUNT(DISTINCT f.order_key) AS total_orders,
    SUM(f.total_product_value) AS total_revenue,
    SUM(f.total_product_value) / COUNT(DISTINCT f.order_key) AS avg_order_value
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p 
    ON f.product_key = p.product_key
GROUP BY p.product_category_name
ORDER BY total_revenue DESC;

