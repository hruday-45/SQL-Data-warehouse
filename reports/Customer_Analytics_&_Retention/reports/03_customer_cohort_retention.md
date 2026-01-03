# 📊 Customer Cohort Retention Analysis (Monthly)

---

## 🧠 Business Question
How does **customer retention evolve over time** based on the month of first purchase (cohort), and how long do customers continue to return after acquisition?

---

## 🎯 Why This Matters
- Reveals **long-term customer behavior**
- Identifies strong vs weak acquisition periods
- Helps evaluate:
  - Marketing effectiveness
  - Product-market fit over time
  - Retention decay patterns

This is a **foundational CXO-level metric** used in growth and product analytics.

---

## 🧩 Data Sources
| Layer | View |
|------|------|
| Gold | `gold.dim_orders` |
| Gold | `gold.dim_customers` |
| Gold | `gold.fact_sales` |

---

## 🛠️ Business Logic (High-Level)
1. Build a **bridge table** linking customers to order months (`YYYYMM`)
2. Identify each customer’s **first purchase month** (cohort)
3. Calculate the **month offset** since first purchase using total-month arithmetic
4. Count active customers per cohort per month
5. Normalize counts into **retention percentages**
6. Limit analysis to the first **24 months** for clarity

---

## 📌 Sample Output

| Cohort Month | Months Since First Purchase | Active Customers | Cohort Size | Retention % |
|-------------|----------------------------|-----------------|------------|------------|
| 201609 | 0 | 4 | 4 | 100.00 |
| 201610 | 0 | 321 | 321 | 100.00 |
| 201610 | 6 | 1 | 321 | 0.31 |
| 201610 | 9 | 1 | 321 | 0.31 |
| 201610 | 11 | 1 | 321 | 0.31 |

📁 **Full output:** `reports/Customer_Analytics_&_Retention/full_output/03_customer_cohort_retention.csv`

---

## 🔍 Key Insights
- Retention **drops sharply after Month 0**, indicating high early churn
- Very few customers return after **6+ months**
- Older cohorts (2016–2017) show:
  - Small cohort sizes
  - Long but sparse reactivation tails
- Confirms:
  - Strong acquisition
  - Weak long-term engagement

---

## 📊 Business Interpretation
- Customer value is **front-loaded**
- Revenue depends heavily on:
  - First purchase
  - Immediate follow-ups
- Long-term loyalty programs are underutilized or ineffective

---

## 🧱 SQL Reference

```sql

-- Removing the bridge table if it already exists from a previous run to avoid errors.
DROP TABLE IF EXISTS gold.bridge_customer_orders;

-- Creating a Performance Bridge Table
SELECT
    dc.customer_unique_id,
    do.order_key,
    (YEAR(do.order_purchase_timestamp) * 100 
     + MONTH(do.order_purchase_timestamp)) AS order_year_month
INTO gold.bridge_customer_orders
FROM gold.dim_orders do
JOIN gold.dim_customers dc
    ON do.customer_id = dc.customer_id;

CREATE CLUSTERED INDEX CX_bridge_customer_orders
ON gold.bridge_customer_orders (customer_unique_id, order_year_month);

-- Finding the First Purchase Month (Cohort) for each customer
WITH CustomerCohort AS (
    SELECT
        customer_unique_id,
        MIN(order_year_month) AS cohort_month
    FROM gold.bridge_customer_orders
    GROUP BY customer_unique_id
)

-- Calculating Month Offset using "Total Months" Logic 
-- This converts YYYYMM to (Years * 12 + Months) to ensure the difference between 201801 and 201712 is exactly 1.
, OrdersWithCohort AS (
    SELECT
        b.customer_unique_id,
        c.cohort_month,
        b.order_year_month,
        ( (b.order_year_month / 100 * 12) + (b.order_year_month % 100) ) -
        ( (c.cohort_month / 100 * 12) + (c.cohort_month % 100) ) 
        AS month_number
    FROM gold.bridge_customer_orders b
    JOIN CustomerCohort c
        ON b.customer_unique_id = c.customer_unique_id
)

-- Counting Active Customers per month for each cohort
, CohortCounts AS (
    SELECT
        cohort_month,
        month_number,
        COUNT(DISTINCT customer_unique_id) AS active_customers
    FROM OrdersWithCohort
    GROUP BY cohort_month, month_number
)

-- Identifying the starting size of each cohort (Month 0)
, CohortSize AS (
    SELECT
        cohort_month,
        active_customers AS cohort_size
    FROM CohortCounts
    WHERE month_number = 0
)

-- Final Calculation and Percentage Formatting
SELECT
    cc.cohort_month,
    cc.month_number AS months_since_first_purchase,
    cc.active_customers,
    cs.cohort_size,
    CAST(
        100.0 * cc.active_customers / cs.cohort_size
        AS DECIMAL(5,2)
    ) AS retention_percent
FROM CohortCounts cc
JOIN CohortSize cs
    ON cc.cohort_month = cs.cohort_month
WHERE cc.month_number <= 24 -- Filter to reasonable timeframe
ORDER BY
    cc.cohort_month,
    cc.month_number;

-- CLEANUP 
DROP TABLE gold.bridge_customer_orders;
