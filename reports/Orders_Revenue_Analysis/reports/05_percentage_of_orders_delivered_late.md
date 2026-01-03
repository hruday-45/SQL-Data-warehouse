# 🚚 Percentage of Orders Delivered Late

---

## 🧠 Business Question
What **percentage of delivered orders** arrived **later than the estimated delivery date**?

This metric is critical for measuring **logistics reliability** and **customer experience**.

---

## 🎯 Why This Matters
- Late deliveries directly impact:
  - Customer satisfaction
  - Review scores
  - Repeat purchase behavior
- Tracking this KPI helps:
  - Evaluate courier and seller performance
  - Identify systemic fulfillment issues

---

## 🧩 Data Source
| Layer | View |
|------|------|
| Gold | `gold.dim_orders` |

---

## 🛠️ Business Logic
- Consider only orders with:
  - `order_status = 'DELIVERED'`
  - Valid actual and estimated delivery dates
- A delivery is classified as **late** if:
- order_delivered_customer_date > order_estimated_delivery_date
- Metrics calculated:
- Total delivered orders
- Number of late deliveries
- Late delivery percentage

---

## 📊 Key Metrics

| Metric | Value |
|------|------:|
| Total Delivered Orders | 96,470 |
| Late Orders | 7,826 |
| Late Delivery Rate (%) | **8.11%** |

---

## 🔍 Key Insights
- Roughly **1 in every 12 delivered orders** arrives late
- The vast majority (**~92%**) of deliveries meet or beat expectations
- While performance is generally strong, late deliveries still represent a meaningful volume

---

## 📈 Business Interpretation
- An **8.11% late rate** indicates acceptable but improvable logistics performance
- Even small improvements (e.g., reducing late rate to 6%) could:
- Positively impact customer reviews
- Reduce churn among first-time buyers
- Late deliveries should be further analyzed by:
  - State
  - Seller
  - Courier partner
  - Order value

---

## 🧱 SQL Reference

```sql

SELECT 
    COUNT(order_id) AS total_delivered_orders,
    -- Count only orders where actual delivery > estimated delivery
    SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
             THEN 1
             ELSE 0 END) AS late_orders,
    -- Calculate the percentage
    CAST(100.0 * SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
                          THEN 1
                          ELSE 0 END) / COUNT(order_id) AS DECIMAL(5,2)) AS late_delivery_rate_percent
FROM gold.dim_orders
WHERE order_status = 'DELIVERED' 
  AND order_delivered_customer_date IS NOT NULL 
  AND order_estimated_delivery_date IS NOT NULL;
