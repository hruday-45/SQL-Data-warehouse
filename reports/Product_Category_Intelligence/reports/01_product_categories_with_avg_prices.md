# 🛒 Product Categories with the Average Price

---

## 🧠 Business Question
What is the **average item price** for each **product category**?

---

## 🎯 Why This Matters
- Identifies **premium product segments**
- Helps understand:
  - Revenue concentration
  - Pricing strategy by category
  - Categories suited for upselling or installment-heavy promotions
- Useful for:
  - Product portfolio optimization
  - Targeted marketing campaigns

---

## 🧩 Data Sources
| Layer | View |
|------|------|
| Gold | `gold.fact_sales` |
| Gold | `gold.dim_products` |

---

## 🛠️ Analytical Approach
- Join sales fact data with product dimension
- Group by product category
- Calculate:
  - Number of items sold
  - Average item price
- Sort categories by **highest average price**

---

## 📊 Sample Output

| Product Category | Items Sold | Avg Item Price |
|------------------|-----------:|---------------:|
| pcs | 181 | 1,141.46 |
| portateis_casa_forno_e_cafe | 76 | 624.29 |
| eletrodomesticos_2 | 234 | 483.26 |
| agro_industria_e_comercio | 183 | 351.17 |
| instrumentos_musicais | 636 | 293.11 |

📁 **Full output:** `reports/Product_Category_Intelligence/full_output/01_product_categories_with_avg_prices.csv`

---

## 🔍 Key Insights
- **PCS** products are the most premium, with an average price exceeding **1,100**
- Appliance-related categories dominate the top tiers, indicating:
  - Higher-ticket household purchases

---

## 📈 Business Interpretation
- High average price + low volume (e.g., *portateis_casa_forno_e_cafe*):
  - Likely niche or luxury purchases
- High average price + higher volume (e.g., *instrumentos_musicais*):
  - Strong candidate for financing, bundles, or cross-sell strategies
- These categories likely contribute **disproportionately to revenue**

---

## ⚠️ Limitations
- Does not account for:
  - Discounts
  - Freight costs
  - Product returns
- Category naming depends on source system consistency

---

## 🧱 SQL Reference

```sql
SELECT
    dp.product_category_name,
    COUNT(*) AS items_sold,
    CAST(AVG(fs.product_price) AS DECIMAL(10,2)) AS avg_item_price
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp
    ON fs.product_key = dp.product_key
GROUP BY dp.product_category_name
ORDER BY avg_item_price DESC;
