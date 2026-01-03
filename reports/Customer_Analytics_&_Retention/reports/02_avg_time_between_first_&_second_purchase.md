# ⏱️ Average Time Between First and Second Purchase

---

## 🧠 Business Question
What is the **average number of days between a customer’s first and second purchase**, and how quickly do customers return after their initial order?

---

## 🎯 Why This Matters
- Measures **early-stage customer retention**
- Indicates whether customers find enough value to return
- Helps design:
  - Re-engagement campaigns
  - Follow-up offers
  - Timing for reminder emails or discounts

---

## 🧩 Data Sources
| Layer | View |
|------|------|
| Gold | `gold.fact_sales` |
| Gold | `gold.dim_customers` |

---

## 🛠️ Business Logic
- Sequence customer orders chronologically using `ROW_NUMBER()`
- Identify:
  - First purchase (`order_rank = 1`)
  - Second purchase (`order_rank = 2`)
- Calculate the **day difference** between the first and second order
- Compute the average across all customers with at least two purchases

---

## 📌 Key Metric

| Metric | Value |
|------|------:|
| Average Days Between 1st and 2nd Purchase | **39.18 days** |

---

## 🔍 Key Insights
- On average, customers take **~39 days** to make a second purchase
- Indicates a **long re-engagement window**
- Suggests:
  - Limited immediate repeat behavior
  - Opportunity to shorten this gap with targeted retention efforts

---

## 📊 Business Implications
- Ideal window for:
  - Reminder emails (7–30 days)
  - Loyalty incentives
  - Personalized recommendations
- Reducing this gap could:
  - Improve retention
  - Increase lifetime value (LTV)
  - Stabilize monthly revenue

---

## 🧱 SQL Reference

```sql

WITH OrderSequence AS (
    -- Sequence the orders using the integer Date Key
    SELECT 
        c.customer_unique_id,
        f.order_purchase_timestamp AS payment_date,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id 
            ORDER BY f.order_purchase_timestamp
        ) AS order_rank
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
    -- Filter out the -1 placeholder values
    WHERE f.order_purchase_timestamp IS NOT NULL
)
SELECT 
    AVG(CAST(DATEDIFF(day, first_order.payment_date, second_order.payment_date) AS FLOAT)) 
    AS avg_days_between_1st_2nd_purchase
FROM OrderSequence first_order
JOIN OrderSequence second_order 
    ON first_order.customer_unique_id = second_order.customer_unique_id
WHERE first_order.order_rank = 1   -- First Purchase
  AND second_order.order_rank = 2;  -- Second Purchase
