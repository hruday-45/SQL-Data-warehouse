# 📅 Order Volume by Day of the Week

---

## 🧠 Business Question
Which **days of the week** have the **highest order volume**?

Understanding this helps optimize:
- Marketing campaigns
- Infrastructure and staffing
- Seller and logistics readiness

---

## 🎯 Why This Matters
- Order volume fluctuates by weekday due to:
  - Consumer behavior
  - Work vs leisure patterns
- Identifying peak days helps:
  - Schedule promotions effectively
  - Prepare fulfillment and delivery capacity

---

## 🧩 Data Source
| Layer | View |
|------|------|
| Gold | `gold.dim_orders` |

---

## 🛠️ Business Logic
- Orders are grouped using `DATEPART(weekday, order_purchase_timestamp)`
- Weekday numbers are mapped to day names
- Placeholder or insignificant records (count = 1) are excluded
- Metrics calculated:
  - Total orders per weekday
  - Percentage share of total orders

---

## 📊 Key Metrics

| Day of Week | Total Orders | % of Total |
|------------|-------------:|-----------:|
| Monday | 16,196 | 16.29% |
| Tuesday | 15,963 | 16.05% |
| Wednesday | 15,552 | 15.64% |
| Thursday | 14,761 | 14.84% |
| Friday | 14,122 | 14.20% |
| Sunday | 11,960 | 12.03% |
| Saturday | 10,887 | 10.95% |

---

## 🔍 Key Insights
- **Monday** has the highest order volume
- Order activity steadily declines toward the weekend
- **Saturday** is the lowest-performing day
- Weekdays account for nearly **77% of all orders**

---

## 📈 Business Interpretation
- Customers are more likely to place orders during the **workweek**
- Weekend shopping activity is comparatively lower, possibly due to:
  - Reduced urgency
  - Offline shopping preferences
- Promotions launched early in the week may yield better results

---

## 🧱 SQL Reference

```sql

SELECT 
    CASE DATEPART(weekday, order_purchase_timestamp)
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
    END AS day_of_week,
    COUNT(order_id) AS total_orders,
    -- Percentage of total volume
    CAST(100.0 * COUNT(order_id) / SUM(COUNT(order_id)) OVER() AS DECIMAL(5,2)) AS pct_of_total
FROM gold.dim_orders
GROUP BY DATEPART(weekday, order_purchase_timestamp)
HAVING COUNT(order_id) <> 1
ORDER BY total_orders DESC;
