# 🚫 Orders Not Delivered Analysis

---

## 🧠 Business Question
How many orders were **not successfully delivered**, and what is their distribution by order status?

This helps identify operational bottlenecks and revenue leakage points.

---

## 🎯 Why This Matters
- Non-delivered orders indicate:
  - Customer dissatisfaction risk
  - Operational or logistics failures
  - Potential revenue loss
- Understanding status distribution helps prioritize:
  - Process improvements
  - Seller or courier interventions

---

## 🧩 Data Source
| Layer | View |
|------|------|
| Gold | `gold.dim_orders` |

---

## 🛠️ Business Logic
- Orders are grouped by `order_status`
- Successfully delivered orders are excluded:
  - `DELIVERED`
  - `unknown`
- For each remaining status:
  - Total orders are counted
  - Percentage contribution to all non-delivered orders is calculated

---

## 📊 Order Status Breakdown (Non-Delivered)

| Order Status | Total Orders | % of Non-Delivered |
|-------------|-------------:|------------------:|
| SHIPPED | 1,107 | 37.36% |
| CANCELED | 625 | 21.09% |
| UNAVAILABLE | 609 | 20.55% |
| INVOICED | 314 | 10.60% |
| PROCESSING | 301 | 10.16% |
| CREATED | 5 | 0.17% |
| APPROVED | 2 | 0.07% |

---

## 🔍 Key Insights
- **Shipped but not delivered** orders form the largest group (37%)
- **Canceled and unavailable** orders together account for over **40%**
- Very few orders stall at early lifecycle stages (created / approved)

---

## 📈 Business Interpretation
- A large share of orders fail **after shipping**, indicating:
  - Last-mile delivery challenges
  - Courier reliability issues
- High cancellation and unavailability rates suggest:
  - Inventory mismatches
  - Seller-side fulfillment problems

---

## 🧱 SQL Reference

```sql

SELECT 
    order_status,
    COUNT(order_id) AS total_orders,
    -- Calculate the percentage of the total order base
    CAST(100.0 * COUNT(order_id) / SUM(COUNT(order_id)) OVER() AS DECIMAL(5,2)) AS pct_of_total
FROM gold.dim_orders
WHERE order_status NOT IN ('DELIVERED', 'unknown')
GROUP BY order_status;
