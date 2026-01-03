# ❌ Product Categories with the Cancellation Rates

---

## 🧠 Business Question
What is the **percentage of order cancellations** of **product categories**?

---

## 🎯 Why This Matters
- Highlights categories with:
  - Fulfillment issues
  - Customer expectation mismatches
  - Supply chain or pricing problems
- Helps business teams:
  - Reduce revenue leakage
  - Improve seller or logistics performance
  - Identify categories needing operational review

---

## 🧩 Data Sources
| Layer | View |
|------|------|
| Gold | `gold.fact_sales` |
| Gold | `gold.dim_products` |

---

## 🛠️ Analytical Approach
- Filter orders with `order_status = 'canceled'`
- Join sales data with product dimension
- Aggregate cancellations by product category
- Calculate:
  - Total cancellations per category
  - Percentage contribution to total cancellations
- Rank categories by highest cancellation share

---

## 📊 Sample Output

| Product Category | Cancellations | % of Total Cancellations |
|------------------|--------------:|--------------------------:|
| sports_leisure | 47 | 10.11 |
| housewares | 37 | 7.96 |
| health_beauty | 36 | 7.74 |
| computers_accessories | 35 | 7.53 |
| toys | 31 | 6.67 |

📁 **Full output:** `reports/Product_Category_Intelligence/full_output/02_product_categories_cancellation_rates.csv`

---

## 🔍 Key Insights
- **Sports & Leisure** contributes the highest share of cancellations (≈10%)
- Household and personal-use categories dominate the list, suggesting:
  - Stock availability issues
  - Delivery time sensitivity
- **Computers & accessories** cancellations may be linked to:
  - Pricing volatility
  - Specification mismatches
- **Toys** cancellations may be seasonal or expectation-driven

---

## 📈 Business Interpretation
- High cancellation concentration in these categories may indicate:
  - Poor demand forecasting
  - Seller fulfillment risks
  - Inaccurate product descriptions
- These categories should be prioritized for:
  - Seller performance audits
  - Inventory and logistics optimization
  - Customer communication improvements

---

## 🧱 SQL Reference

```sql

WITH baseproduct AS (
    SELECT 
        p.product_category_name_english,
        COUNT(*) AS category_cancellations
    FROM gold.fact_sales f 
    INNER JOIN gold.dim_products p ON f.product_key = p.product_key
    WHERE f.order_status = 'CANCELED' -- Ensure case sensitivity matches your data
    GROUP BY p.product_category_name_english
)
SELECT
    product_category_name_english,
    category_cancellations,
    -- Multiply by 100.0 (float) to prevent integer truncation
    100.0 * category_cancellations / SUM(category_cancellations) OVER() AS pct_of_total_cancellations
FROM baseproduct
ORDER BY 3 DESC;
