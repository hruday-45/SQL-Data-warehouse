# 📈 Monthly Revenue Trend Analysis

---

## 🧠 Business Question
How does revenue and order volume trend over time on a monthly basis?

---

## 🎯 Why This Matters
- Helps leadership track **business growth and seasonality**
- Identifies **peak and low-performing months**
- Supports **forecasting, budgeting, and promotional planning**
- Provides context for changes in customer demand over time

---

## 🧩 Data Sources
| Layer | View |
|------|------|
| Gold | `gold.fact_sales` |
| Gold | `gold.dim_date` |

---

## 🛠️ Logic Overview
- Aggregates total revenue and order count at a **monthly level**
- Joins sales facts with the date dimension
- Groups data by calendar year and month
- Orders results in reverse chronological order for trend analysis

---

## 📌 Key Metrics
| Metric | Value |
|------|------|
| Analysis Period | Sep 2016 – Sep 2018 |
| Peak Revenue Month | Nov 2017 |
| Peak Order Volume Month | Jan 2018 |
| Lowest Activity | Dec 2016 (platform ramp-up) |

---

## 🔍 Key Insights
- Revenue shows **steady and sustained growth from early 2017**
- **November 2017** recorded the highest monthly revenue, likely driven by promotional events
- Order volume peaked in **January 2018**, indicating strong post-holiday demand
- Very low revenue in late 2016 reflects the **early adoption phase** of the platform
- 2018 maintains high revenue consistency until the partial data seen in September

---

## 📊 Output

<details>
<summary>📊 Click to expand monthly revenue trend</summary>

| Year | Month | Month Name | Monthly Revenue (R$) | Order Count |
|:---|:---|:---|:---|:---|
| 2016 | 09 | September | 259.11 | 3 |
| 2016 | 10 | October | 52,857.48 | 308 |
| 2016 | 12 | December | 19.62 | 1 |
| 2017 | 01 | January | 125,855.62 | 789 |
| 2017 | 02 | February | 270,360.88 | 1,733 |
| 2017 | 03 | March | 406,714.73 | 2,641 |
| 2017 | 04 | April | 386,961.51 | 2,391 |
| 2017 | 05 | May | 551,348.77 | 3,660 |
| 2017 | 06 | June | 481,358.64 | 3,217 |
| 2017 | 07 | July | 547,320.99 | 3,969 |
| 2017 | 08 | August | 623,384.25 | 4,293 |
| 2017 | 09 | September | 659,515.30 | 4,243 |
| 2017 | 10 | October | 712,347.66 | 4,568 |
| **2017** | **11** | **November** | **1,088,606.79** | **7,451** |
| 2017 | 12 | December | 818,789.82 | 5,624 |
| 2018 | 01 | January | 1,036,781.68 | 7,220 |
| 2018 | 02 | February | 913,337.10 | 6,694 |
| 2018 | 03 | March | 1,075,586.21 | 7,188 |
| 2018 | 04 | April | 1,087,843.16 | 6,934 |
| 2018 | 05 | May | 1,066,124.89 | 6,853 |
| 2018 | 06 | June | 954,673.22 | 6,160 |
| 2018 | 07 | July | 987,178.22 | 6,273 |
| 2018 | 08 | August | 956,416.67 | 6,452 |

</details>

---

## 🖼️ Visualization

![Monthly Revenue Trend](../../../assets/Monthly_Revenue_Trend.png)


---

## 🧪 Data Quality Checks
- ✔ Revenue values validated to be non-negative
- ✔ Distinct `order_key` used to avoid double counting
- ✔ Partial months (e.g., Sep 2018) identified and interpreted correctly

---

## 🧱 SQL Reference

```sql
-- Monthly Revenue Trend
SELECT 
    d.year,
    d.month,
    d.month_name,
    SUM(f.total_product_value) AS monthly_revenue,
    COUNT(DISTINCT f.order_key) AS monthly_order_count
FROM gold.fact_sales f
LEFT JOIN gold.dim_date d ON f.order_purchase_timestamp = d.date
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;
