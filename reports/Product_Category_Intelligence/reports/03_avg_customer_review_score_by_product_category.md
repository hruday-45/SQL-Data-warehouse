# ⭐ Average Customer Review Scores by Product Category

---

## 🧠 Business Question
What are the **average customer review scores** for each product category, and which categories receive the **lowest satisfaction ratings**?

---

## 🎯 Why This Matters
- Customer reviews directly influence:
  - Conversion rates
  - Repeat purchases
  - Seller and platform reputation
- Identifying low-rated categories helps:
  - Improve product quality and descriptions
  - Reduce returns and cancellations
  - Prioritize seller or logistics interventions

---

## 🧩 Data Sources
| Layer | View |
|------|------|
| Gold | `gold.fact_reviews` |
| Gold | `gold.fact_sales` |
| Gold | `gold.dim_products` |

---

## 🛠️ Analytical Approach
- Join review data with sales and product dimensions
- Group reviews by product category
- Calculate:
  - Total number of reviews
  - Average review score (1–5)
  - Percentage of 1-star reviews
- Sort categories by **lowest average score first** to surface risk areas

---

## 📊 Sample Output

| Product Category | Total Reviews | Avg Review Score | % 1-Star Reviews |
|------------------|--------------:|-----------------:|-----------------:|
| others | 756 | 1.72 | 71.16 |
| seguros_e_servicos | 2 | 2.50 | 50.00 |
| pc_gamer | 8 | 3.13 | 37.50 |
| portateis_cozinha_e_preparadores_de_alimentos | 14 | 3.43 | 14.29 |
| moveis_escritorio | 1293 | 3.59 | 18.48 |

📁 **Full output:** `reports/Product_Category_Intelligence/full_output/03_avg_customer_review_score_by_product_category.csv`

---

## 🔍 Key Insights
- **“Others” which are not listed under category performs extremely poorly**, with:
  - Lowest average rating (1.72)
  - Over **71% 1-star reviews**
  - Likely caused by:
    - Poor categorization
    - Mixed or low-quality products
- **Almost all the product categories are scored above the average of 3 except others and seguros_e_servicos**

---

## 📈 Business Interpretation
- Categories with **low average scores + high volume** pose the greatest risk
- Poor reviews may stem from:
  - Late deliveries
  - Product quality mismatches
  - Inadequate product descriptions
- Improving these categories can:
  - Increase retention
  - Reduce cancellations
  - Improve platform trust

---

## 🧱 SQL Reference
📄 `sql/product_analysis/average_review_scores_by_category.sql`

```sql

SELECT 
    ISNULL(p.product_category_name, 'others') AS product_category_name,
    COUNT(r.order_key) AS total_reviews,
    AVG(CAST(r.avg_review_score AS FLOAT)) AS avg_score,
    -- Percentage of reviews that are 1-star
    CAST(100.0 * SUM(CASE WHEN r.avg_review_score = 1 THEN 1 ELSE 0 END) 
               / COUNT(r.order_key) AS DECIMAL(5,2)) AS pct_1_star
FROM gold.fact_reviews r
LEFT JOIN gold.fact_sales f ON r.order_key = f.order_key
LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.product_category_name
ORDER BY avg_score ASC;
