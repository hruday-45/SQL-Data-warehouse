# 🔁 Customer Retention Rate (6-Month & 12-Month)

---

## 🧠 Business Question
What percentage of customers return to make another purchase within **6 months** and **12 months** of their first order?

---

## 🎯 Why This Matters
- Retention is a **stronger growth lever** than acquisition
- Indicates **customer satisfaction and repeat behavior**
- Helps evaluate long-term business sustainability
- Supports cohort analysis and lifecycle marketing strategies

---

## 🧩 Data Sources
| Layer | View |
|------|------|
| Gold | `gold.dim_orders` |
| Gold | `gold.dim_customers` |
| Gold (Temp Table) | `gold.bridge_customer_orders` |

---

## 🛠️ Logic Overview
1. Created a **bridge table** linking customers to orders with a `YYYYMM` time grain
2. Identified each customer’s **first purchase month (cohort month)**
3. Flagged whether the customer returned:
   - Within **1–6 months**
   - Within **1–12 months**
4. Aggregated results to calculate **retention counts and percentages**
5. Applied indexing for **performance optimization**

---

## 📌 Key Metrics
| Metric | Value |
|------|------|
| Total Customers | 96,097 |
| Customers Retained (6 Months) | 1,086 |
| 6-Month Retention Rate | **1.13%** |
| Customers Retained (12 Months) | 1,152 |
| 12-Month Retention Rate | **1.20%** |

---

## 🔍 Key Insights
- Customer retention is **very low**, even over a 12-month window
- The small increase from 6 to 12 months suggests:
  - Most repeat purchases happen **early**, if at all
  - Long-term customer engagement is limited
- Indicates a **transactional purchase pattern**, not subscription-like behavior
- Highlights a major opportunity for:
  - Loyalty programs
  - Post-purchase engagement
  - Retention-focused marketing

---

## 📊 Output

| total_customers | customers_retained_6_months | retention_rate_6_months_percent | customers_retained_12_months | retention_rate_12_months_percent |
|----------------|-----------------------------|---------------------------------|------------------------------|----------------------------------|
| 96,097 | 1,086 | 1.13 | 1,152 | 1.20 |

---

## 🧪 Data Quality & Performance Considerations
- ✔ Used `customer_unique_id` to avoid duplicate customer inflation
- ✔ Converted timestamps to `YYYYMM` for efficient cohort math
- ✔ Clustered index applied for faster joins and aggregations
- ✔ Temporary bridge table cleaned up after execution

---

## 🧱 SQL Reference

```sql
-- Removing the bridge table if it already exists from a previous run to avoid errors.
DROP TABLE IF EXISTS gold.bridge_customer_orders;

-- Creating a temporary Bridge Table
SELECT
    dc.customer_unique_id,
    do.order_key,
    -- Converts date to an integer: May 2018 becomes 201805
    (YEAR(do.order_purchase_timestamp) * 100 
     + MONTH(do.order_purchase_timestamp)) AS order_year_month
INTO gold.bridge_customer_orders
FROM gold.dim_orders do
JOIN gold.dim_customers dc
    ON do.customer_id = dc.customer_id;

-- Optimizing with a Clustered Index
CREATE CLUSTERED INDEX CX_bridge_customer_orders
ON gold.bridge_customer_orders (customer_unique_id, order_year_month);

--  Calculate Retention using Common Table Expressions (CTEs)
WITH FirstPurchase AS (
    -- Finds the 'Cohort Month' (the very first time we ever saw this customer)
    SELECT
        customer_unique_id,
        MIN(order_year_month) AS first_year_month
    FROM gold.bridge_customer_orders
    GROUP BY customer_unique_id
),
RetentionFlags AS (
    -- Flags if a customer returned within specific windows
    SELECT
        b.customer_unique_id,

        -- 6-Month Flag: Did they return between 1 and 6 months after the first?
        MAX(CASE WHEN b.order_year_month - fp.first_year_month BETWEEN 1 AND 6
            THEN 1 ELSE 0 END) AS retained_6_months,

        -- 12-Month Flag: Did they return between 1 and 12 months after the first?
        MAX(CASE WHEN b.order_year_month - fp.first_year_month BETWEEN 1 AND 12
                THEN 1 ELSE 0 END) AS retained_12_months
    FROM gold.bridge_customer_orders b
    JOIN FirstPurchase fp
        ON b.customer_unique_id = fp.customer_unique_id
    GROUP BY b.customer_unique_id
)
-- Final Aggregation
SELECT
    COUNT(*) AS total_customers,
    SUM(retained_6_months) AS customers_retained_6_months,
    CAST(100.0 * SUM(retained_6_months) / COUNT(*) AS DECIMAL(5,2))
        AS retention_rate_6_months_percent,
    SUM(retained_12_months) AS customers_retained_12_months,
    CAST(100.0 * SUM(retained_12_months) / COUNT(*) AS DECIMAL(5,2))
        AS retention_rate_12_months_percent
FROM RetentionFlags;

-- Clean up the temporary bridge table
DROP TABLE gold.bridge_customer_orders;
