# 🚚 High-Revenue Sellers with Poor Delivery Performance

---

## 🧠 Business Question
Which sellers generate **significant revenue** but suffer from **poor delivery performance**, as measured by late deliveries and longer delivery times?

---

## 🎯 Why This Matters
- Late deliveries directly impact **customer satisfaction and reviews**
- High-revenue sellers with delivery issues pose **brand risk**
- Helps operations teams:
  - Identify sellers needing intervention
  - Improve SLA compliance
  - Prioritize logistics optimization

---

## 🧩 Data Sources
| Layer | View |
|------|------|
| Gold | `gold.fact_sales` |
| Gold | `gold.dim_sellers` |

---

## 🛠️ Business Logic
This report focuses only on sellers who:
- Have generated **more than 10,000** in total revenue
- Have a **late delivery rate above 15%**
- Include **only delivered orders** (`is_delivered_flag = 1`)

### Metrics Calculated
- Total orders
- Total revenue
- Average delivery time (days)
- Number of late deliveries
- Late delivery rate (%)

---

## 📌 Key Metrics (Sample Sellers)

| seller_id | city | state | total_orders | total_revenue | avg_delivery_time (days) | late_orders | late_delivery_rate (%) |
|----------|------|-------|--------------:|---------------:|--------------------------:|-------------:|------------------------:|
| f7ba60f8c3f99e7ee4042fdef03b70c4 | sao bernardo do campo | SP | 218 | 69,516.87 | 13.34 | 34 | **15.60** |
| 8160255418d5aaa7dbdc9f4c64ebda44 | ibitinga | SP | 380 | 52,138.10 | 16.55 | 72 | **18.95** |
| 06a2c3af7b3aee5d69171b0e14f0ee87 | sao luis | MA | 389 | 47,377.06 | 17.60 | 91 | **23.39** |
| 712e6ed8aa4aa1fa65dab41fed5737e4 | videira | SC | 77 | 44,411.32 | 24.60 | 17 | **22.08** |
| 88460e8ebdecbfecb5f9601833981930 | maringa | PR | 246 | 31,908.48 | 17.97 | 53 | **21.54** |

📁 **Full output:** `reports/Business_Reports/full_output/07_high_revenue_sellers_with_poor_delivery_performance.csv`

---

## 🔍 Key Insights
- Several high-performing sellers exceed **20% late delivery rates**
- Some sellers show **very high average delivery times (>20 days)**
- Indicates possible:
  - Logistics bottlenecks
  - Seller fulfillment issues
  - Regional delivery challenges
- Revenue alone does not guarantee **operational excellence**

---

## ⚠️ Business Risks Identified
- High late delivery rates can lead to:
  - Poor customer reviews
  - Reduced repeat purchases
  - Platform trust erosion
- Sellers with both **high revenue and poor delivery** should be:
  - Monitored closely
  - Prioritized for corrective actions

---

## 📊 Use Cases
- Seller performance dashboards
- SLA monitoring and enforcement
- Vendor scorecards
- Operational risk management

---

## 🧱 SQL Reference

```sql
SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT f.order_key) AS total_orders,
    SUM(f.total_product_value) AS total_revenue,
    
    -- Delivery Performance Metrics
    AVG(CAST(f.total_delivery_days AS FLOAT)) AS avg_delivery_time,
    SUM(f.is_late_delivery_flag) AS total_late_orders,
    
    -- Calculating Late Ratio
    CAST(SUM(f.is_late_delivery_flag) AS FLOAT) / COUNT(DISTINCT f.order_key) * 100 AS late_delivery_rate_percent
FROM gold.fact_sales f
LEFT JOIN gold.dim_sellers s 
ON f.seller_key = s.seller_key
WHERE f.is_delivered_flag = 1
GROUP BY s.seller_id, 
         s.seller_city, 
         s.seller_state
HAVING SUM(f.total_product_value) > 10000      -- Focus on high-revenue sellers
AND (SUM(f.is_late_delivery_flag) / CAST(COUNT(*) AS FLOAT)) > 0.15 -- Late on more than 15% of orders
ORDER BY total_revenue DESC;
