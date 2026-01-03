# ⏰ Sellers Frequently Missing Estimated Delivery Dates

---

## 🧠 Business Question
Which **sellers most frequently miss estimated delivery dates** for orders that were ultimately delivered?

This analysis highlights sellers whose delivery performance may negatively impact customer trust and platform reliability.

---

## 🎯 Why This Matters
- Late deliveries lead to:
  - Poor customer experience
  - Lower review scores
  - Increased churn
- Identifying repeat offenders enables:
  - Seller performance monitoring
  - SLA enforcement
  - Logistics optimization

---

## 🧩 Data Sources
| Layer | View |
|------|------|
| Gold | `gold.fact_sales` |
| Gold | `gold.dim_sellers` |

---

## 🛠️ Business Logic
- Consider **only delivered orders**
- Identify late deliveries using `is_late_delivery_flag`
- Aggregate at **seller level**
- Metrics calculated:
  - Total delivered orders
  - Number of late orders
  - Late delivery rate (%)
- Exclude sellers with **zero late deliveries**
- Rank sellers by **highest late delivery rate**

---

## 📌 Sample Output

| Seller ID | Total Orders | Late Orders | Late Delivery Rate (%) |
|----------|-------------:|------------:|-----------------------:|
| 04843805947f0fc584fc1969b6e50fe7 | 1 | 1 | 100.00 |
| 05ca864204d09595ae591b93ea9cf93d | 1 | 1 | 100.00 |
| 1352e06ae67b410cdae0b2a22361167b | 2 | 2 | 100.00 |
| 13d95f0f6f73943d4ceffad0fc2cd32c | 1 | 1 | 100.00 |
| 154bdf805377afea75a3bd158e9eab10 | 1 | 1 | 100.00 |

📁 **Full output:** `reports/Delivery_&_Logistics_Performance/full_output/05_sellers_missing_estimated_delivery_dates.csv`

---

## 🔍 Key Insights
- Most sellers were under the late delivery rate of 20%.
- Most sellers with late delivery rate of 100% have sold very less amount of orders.

---

## 📊 Business Interpretation
- Sellers with repeated late deliveries—even at low volume—should be:
  - Closely monitored
  - Flagged for SLA violations
- High-risk sellers can:
  - Harm marketplace credibility
  - Increase customer complaints

---

## 🧱 SQL Reference

```sql


WITH SellerDeliveryStats AS (
    SELECT
        fs.seller_key,
        COUNT(DISTINCT fs.order_key) AS total_orders,
        -- the sum of late orders using the pre-defined late delivery flag
        SUM(CASE WHEN fs.is_late_delivery_flag = 1 THEN 1
            ELSE 0 END) AS late_orders
    FROM gold.fact_sales fs
    WHERE fs.is_delivered_flag = 1   
    GROUP BY fs.seller_key
)
SELECT
    ds.seller_id,
    sds.total_orders,
    sds.late_orders,
    -- the late rate percentage (Late Orders / Total Orders)
    CAST(100.0 * sds.late_orders / sds.total_orders AS DECIMAL(5,2)) AS late_delivery_rate_percent
FROM SellerDeliveryStats sds
LEFT JOIN gold.dim_sellers ds
    ON sds.seller_key = ds.seller_key 
    WHERE sds.late_orders > 0   -- removing sellers who doesn't had any late orders
ORDER BY late_delivery_rate_percent DESC;
