# ⭐ Late Delivery Impact Customer Review Scores

---

## 🧠 Business Question
Do **late deliveries** negatively affect **customer review scores**, compared to on-time deliveries?

Understanding this relationship helps evaluate whether delivery delays directly influence customer satisfaction.

---

## 🎯 Why This Matters
- Review scores influence:
  - Seller reputation
  - Platform trust
  - Repeat purchases
- Identifies whether improving delivery timelines can lead to:
  - Higher ratings
  - Better customer retention

---

## 🧩 Data Sources
| Layer | View |
|------|------|
| Gold | `gold.fact_sales` |
| Gold | `gold.fact_reviews` |

---

## 🛠️ Business Logic
- Join orders with customer reviews
- Categorize each order as:
  - **Late_Delivery** → Delivered after estimated date
  - **On_Time** → Delivered on or before estimated date
- Group results by:
  - Delivery status
  - Review score (1–5, including fractional averages)
- Count number of orders per review score bucket

---

## 📌 Key Metrics

<details>
<summary><strong>Click to view full review score distribution</strong></summary>

| Delivery Status | Orders | Avg Review Score |
|-----------------|--------:|-----------------:|
| Late_Delivery | 3,619 | 1.0 |
| Late_Delivery | 1 | 1.5 |
| Late_Delivery | 617 | 2.0 |
| Late_Delivery | 6 | 2.5 |
| Late_Delivery | 878 | 3.0 |
| Late_Delivery | 3 | 3.5 |
| Late_Delivery | 961 | 4.0 |
| Late_Delivery | 2 | 4.5 |
| Late_Delivery | 1,733 | 5.0 |
| Late_Delivery | 176 | NULL |
| On_Time | 8,163 | 1.0 |
| On_Time | 13 | 1.5 |
| On_Time | 2,726 | 2.0 |
| On_Time | 33 | 2.5 |
| On_Time | 7,600 | 3.0 |
| On_Time | 25 | 3.5 |
| On_Time | 18,513 | 4.0 |
| On_Time | 56 | 4.5 |
| On_Time | 56,677 | 5.0 |
| On_Time | 621 | NULL |

</details>

---

## 🔍 Key Insights
- **Late deliveries show a higher concentration of low review scores**
  - Large volume of **1-star and 2-star** ratings
- **On-time deliveries dominate 5-star ratings**
  - Over **56,000 on-time orders** received a perfect score
- Missing reviews (NULLs) exist in both groups but do not skew the trend

---

## 📊 Business Interpretation
- Delivery timeliness has a **strong correlation with customer satisfaction**
- Late deliveries significantly increase the likelihood of:
  - Poor reviews
  - Negative customer experience
- Improving delivery reliability can directly improve:
  - Average review scores
  - Seller performance metrics

---

## 🧱 SQL Reference

```sql
WITH DeliveryReviews AS (
    SELECT
        fs.order_key,
        fs.is_late_delivery_flag,
        fr.avg_review_score
    FROM gold.fact_sales fs
    LEFT JOIN gold.fact_reviews fr
        ON fs.order_key = fr.order_key
)
SELECT
    CASE 
        WHEN is_late_delivery_flag = 1 THEN 'Late_Delivery' 
        ELSE 'On_Time' 
    END AS delivery_status,
    COUNT(*) AS orders,
    avg_review_score
FROM DeliveryReviews
GROUP BY is_late_delivery_flag, avg_review_score;
