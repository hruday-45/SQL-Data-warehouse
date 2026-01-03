# 🚚 Do Installment-Heavy Orders Experience More Delivery Delays?

---

## 🧠 Business Question
Are orders with **higher installment counts** more likely to experience **late delivery**?

---

## 🎯 Why This Matters
- Installments may indicate:
  - Higher-value orders
  - More complex fulfillment
- Late deliveries impact:
  - Customer satisfaction
  - Reviews and repeat purchases
- Understanding this relationship helps:
  - Identify operational risks tied to payment behavior
  - Improve SLA planning for high-value orders

---

## 🧩 Data Sources
| Layer | View |
|------|------|
| Gold | `gold.fact_payments` |
| Gold | `gold.fact_sales` |
| Gold (Temp Table) | `gold.order_delivery_status` |
| Gold (Temp Table) | `gold.order_payment_behavior` |

---

## 🛠️ Analytical Approach

### 1️⃣ Payment Behavior Aggregation
- For each order, identify the **maximum number of installments used**
- Stored in a temporary bridge table for performance optimization

### 2️⃣ Delivery Status Identification
- Flag whether each **delivered order** experienced a late delivery
- Ensures only completed deliveries are evaluated

### 3️⃣ Correlation Analysis
- Join payment behavior with delivery outcomes
- Group orders into **installment intensity buckets**
- Calculate late delivery rates per group

---

## 📊 Key Metrics

| Installment Group | Total Orders | Late Orders | Late Delivery Rate (%) |
|------------------|-------------:|------------:|-----------------------:|
| Heavy Installments (7+) | 11,763 | 1,025 | 8.71 |
| Medium Installments (4–6) | 15,739 | 1,296 | 8.23 |
| Light Installments (2–3) | 22,159 | 1,792 | 8.09 |
| Single Payment | 46,802 | 3,712 | 7.93 |

---

## 🔍 Key Insights
- Late delivery rates **increase slightly** as installment count increases
- Heavy installment orders show:
  - The **highest delay rate** (8.71%)
  - Only a marginal increase over single-payment orders
- Differences across groups are **statistically small**

---

## 📈 Business Interpretation
- Installment intensity is **not a major driver** of delivery delays
- Slight upward trend may reflect:
  - Larger basket sizes
  - More complex logistics for high-value orders
- Operational performance remains relatively consistent across payment behaviors

---

## ⚠️ Limitations & Considerations
- Analysis includes **only delivered orders**
- Installments act as a **proxy** for order value, not a direct cause
- External factors not included:
  - Seller fulfillment speed
  - Product category
  - Geographic distance

---

## 🧱 SQL Reference

```sql

-- Dropping bridge table1 if exists before
DROP TABLE IF EXISTS gold.order_payment_behavior;

-- Analyzing Payment Behavior
-- Identifying the maximum number of installments used for each unique order.
SELECT
    order_key,
    MAX(payment_installments) AS max_installments
INTO gold.order_payment_behavior
FROM gold.fact_payments
GROUP BY order_key;

-- Indexing the order_key allows for a much faster join in the final step.
CREATE UNIQUE CLUSTERED INDEX IX_opb_order
ON gold.order_payment_behavior (order_key);

-- Dropping bridge table2 if exists before 
DROP TABLE IF EXISTS gold.order_delivery_status;

-- Analyzing Delivery Status.
-- Identifying if an order was flagged as a late delivery.
SELECT
    order_key,
    MAX(is_late_delivery_flag) AS is_late_delivery
INTO gold.order_delivery_status
FROM gold.fact_sales
WHERE is_delivered_flag = 1
GROUP BY order_key;

-- Clustered index ensures the delivery data is physically sorted for performance.
CREATE UNIQUE CLUSTERED INDEX IX_ods_order
ON gold.order_delivery_status (order_key);

-- The Correlation Analysis.
/* Join the payment behavior with the delivery status and group them into 
logical 'installment buckets' to see if late rates increase with more installments.*/

SELECT
    CASE
        WHEN opb.max_installments = 1 THEN 'Single Payment'
        WHEN opb.max_installments BETWEEN 2 AND 3 THEN 'Light Installments (2–3)'
        WHEN opb.max_installments BETWEEN 4 AND 6 THEN 'Medium Installments (4–6)'
        ELSE 'Heavy Installments (7+)'
    END AS installment_group,
    COUNT(*) AS total_orders,
    SUM(ods.is_late_delivery) AS late_orders,
    -- the late delivery percentage for each group.
    CAST(100.0 * SUM(ods.is_late_delivery) / COUNT(*) AS DECIMAL(5,2)) AS late_delivery_rate_percent
FROM gold.order_delivery_status ods
JOIN gold.order_payment_behavior opb
    ON ods.order_key = opb.order_key
GROUP BY
    CASE
        WHEN opb.max_installments = 1 THEN 'Single Payment'
        WHEN opb.max_installments BETWEEN 2 AND 3 THEN 'Light Installments (2–3)'
        WHEN opb.max_installments BETWEEN 4 AND 6 THEN 'Medium Installments (4–6)'
        ELSE 'Heavy Installments (7+)'
    END
ORDER BY late_delivery_rate_percent DESC;

-- Cleanup:Drop the temporary tables to keep the 'gold' schema clean and free up storage.
DROP TABLE gold.order_delivery_status;
DROP TABLE gold.order_payment_behavior;
