# 🚚 Seller-wise Average Delivery Delay

---

## 🧠 Business Question
Which **sellers** have the **highest average delivery delays**, and how frequently do they ship orders late?

This analysis helps identify sellers whose fulfillment performance may negatively impact customer experience.

---

## 🎯 Why This Matters
- Late deliveries directly affect:
  - Customer satisfaction
  - Review scores
  - Marketplace trust
- Identifies sellers who may need:
  - Logistics support
  - Process audits
  - SLA enforcement

---

## 🧩 Data Sources
| Layer | View |
|------|------|
| Gold | `gold.fact_sales` |

---

## 🛠️ Business Logic
- Calculate **delivery delay (in days)** per order  
  - Positive → Late delivery  
  - Negative → Early delivery
- Aggregate metrics at **seller level**
- Metrics computed:
  - Total orders shipped
  - Average delivery delay (days)
  - Count of late-dispatched orders
- Sellers ranked by **highest average delay**

---

## 📌 Sample Output

| Seller Key | Total Orders | Avg Delivery Delay (Days) | Late Orders |
|-----------:|-------------:|--------------------------:|------------:|
| 2700 | 1 | 167.00 | 1 |
| 959 | 3 | 44.67 | 1 |
| 1746 | 1 | 35.00 | 1 |
| 1646 | 1 | 33.00 | 1 |
| 2293 | 2 | 23.50 | 2 |

📁 **Full output:** `reports/Business_Reports/full_output/03_top_product_categories_by_revenue_&_order_value.csv`

---

## 🔍 Key Insights
- Some sellers show **extreme average delays** driven by:
  - Very small order counts
  - Severe fulfillment issues
- Seller `2700` delayed delivery by **167 days** on its only order
- Indicates potential:
  - Data quality issues
  - Operational breakdowns
  - Seller non-compliance

---

## 📊 Business Interpretation
- High average delays, even with low volumes, pose:
  - Reputation risks
  - Customer churn risk
- These sellers should be:
  - Flagged for operational review
  - Monitored with stricter delivery SLAs

---

## 🧱 SQL Reference

```sql
WITH SellerDelayAnalysis AS (
    SELECT 
        seller_key,
        delivery_delay_days
    FROM gold.fact_sales
)
SELECT 
    seller_key,
    COUNT(*) AS total_orders_shipped,
    AVG(CAST(delivery_delay_days AS FLOAT)) AS avg_shipping_delay_days,
    SUM(CASE WHEN delivery_delay_days > 0 THEN 1 ELSE 0 END) AS late_dispatched_orders
FROM SellerDelayAnalysis
GROUP BY seller_key
ORDER BY avg_shipping_delay_days DESC;
