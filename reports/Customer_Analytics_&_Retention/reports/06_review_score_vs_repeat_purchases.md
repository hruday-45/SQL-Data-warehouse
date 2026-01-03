# ⭐ Review Score vs Repeat Purchases

---

## 🧠 Business Question
Do **higher review scores from a customer’s first order** lead to a **higher likelihood of repeat purchases**?

---

## 🎯 Why This Matters
- Helps evaluate whether **customer satisfaction (reviews)** drives retention
- Supports investments in:
  - Post-purchase experience
  - Customer support
  - Seller quality programs
- Connects **customer sentiment** directly to **revenue sustainability**

---

## 🧩 Data Sources
| Layer | View |
|------|------|
| Gold | `gold.dim_orders` |
| Gold | `gold.dim_customers` |
| Gold | `gold.fact_reviews` |
| Gold | `gold.fact_sales` |
| Gold (Temp Table) | `gold.gold.bridge_customer_orders` |

---

## 🛠️ Business Logic
1. Create a **bridge table** mapping customers to all orders
2. Identify:
   - First purchase month
   - First order key
3. Retrieve **review score of first order** (if available)
4. Classify customers as:
   - **Repeat customers** → more than one order
   - **One-time customers**
5. Aggregate repeat purchase rate by:
   - Review score
   - Including **NULL review scores**

---

## 📌 Key Metrics

<details>
<summary><strong>Click to view detailed results</strong></summary>

| First Review Score | Total Customers | Repeat Customers | Repeat Rate (%) |
|-------------------|----------------:|-----------------:|----------------:|
| NULL | 739 | 31 | 4.19 |
| 1.0 | 10,963 | 321 | 2.93 |
| 1.5 | 3 | 2 | 66.67 |
| 2.0 | 3,031 | 89 | 2.94 |
| 2.5 | 17 | 10 | 58.82 |
| 3.0 | 7,845 | 222 | 2.83 |
| 3.33 | 1 | 1 | 100.00 |
| 3.5 | 17 | 13 | 76.47 |
| 4.0 | 18,472 | 508 | 2.75 |
| 4.5 | 29 | 25 | 86.21 |
| 5.0 | 54,980 | 1,775 | 3.23 |

</details>

---

## 🔍 Key Insights
- Customers **without a review (NULL)** show a **higher repeat rate (4.19%)** than most scored groups
- **5-star reviews** still have the **highest meaningful repeat rate**
- Review scores **1–4** show **very similar repeat behavior (~2.7–3.0%)**
- Extremely high repeat rates at fractional scores are driven by **very small sample sizes**

---

## 📊 Business Interpretation
- Leaving a review is **not required for repeat behavior**
- Review score alone is a **weak predictor** of retention
- Repeat purchases are likely influenced more by:
  - Delivery experience
  - Product category
  - Price competitiveness
  - Promotions

---

## 🧱 SQL Reference

```sql

-- Removing the bridge table if it already exists from a previous run to avoid errors.
DROP TABLE IF EXISTS gold.bridge_customer_orders;

-- Creating a temporary bridge table 
SELECT
    dc.customer_unique_id,
    do.order_key,
    (YEAR(do.order_purchase_timestamp) * 100 
     + MONTH(do.order_purchase_timestamp)) AS order_year_month
INTO gold.bridge_customer_orders
FROM gold.dim_orders do
LEFT JOIN gold.dim_customers dc
    ON do.customer_id = dc.customer_id;

-- Applying an index to optimize the performance of the subsequent CTE joins
CREATE CLUSTERED INDEX CX_bridge_customer_orders
ON gold.bridge_customer_orders (customer_unique_id, order_year_month);

-- Finding the First Purchase Month
WITH FirstOrder AS (
    SELECT
        customer_unique_id,
        MIN(order_year_month) AS first_order_month
    FROM gold.bridge_customer_orders
    GROUP BY customer_unique_id
),

-- Identifying the First Order Key 
    FirstOrderKey AS (
    SELECT
        b.customer_unique_id,
        MIN(b.order_key) AS first_order_key
    FROM gold.bridge_customer_orders b
    LEFT JOIN FirstOrder f
        ON b.customer_unique_id = f.customer_unique_id
       AND b.order_year_month = f.first_order_month
    GROUP BY b.customer_unique_id
),

-- Retrieving the Review Score for that First Order 
  FirstReview AS (
    SELECT
        f.customer_unique_id,
        r.avg_review_score
    FROM FirstOrderKey f
    LEFT JOIN gold.fact_reviews r
        ON f.first_order_key = r.order_key
),

-- Categorizing customers as Repeat or Single-Purchase 
  RepeatCustomers AS (
    SELECT
        customer_unique_id,
        CASE
            WHEN COUNT(*) > 1 THEN 1 ELSE 0
        END AS is_repeat_customer
    FROM gold.bridge_customer_orders
    GROUP BY customer_unique_id
)

-- Final Aggregation 
SELECT
    fr.avg_review_score,
    COUNT(*) AS total_customers_in_score,
    SUM(rc.is_repeat_customer) AS total_repeat_customers,
    CAST(
        100.0 * SUM(rc.is_repeat_customer) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS repeat_rate_percent
FROM FirstReview fr
LEFT JOIN RepeatCustomers rc
    ON fr.customer_unique_id = rc.customer_unique_id
GROUP BY fr.avg_review_score
ORDER BY fr.avg_review_score;

-- CLEANUP: Removing the temporary bridge table
DROP TABLE gold.bridge_customer_orders;
