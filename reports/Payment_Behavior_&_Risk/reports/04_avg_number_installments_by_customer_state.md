# 🗺️ Average Number of Installments by Customer State

---

## 🧠 Business Question
How does the **average number of payment installments** vary across **customer states**?

---

## 🎯 Why This Matters
- Installment usage often reflects:
  - Purchasing power
  - Price sensitivity
  - Regional economic behavior
- Understanding geographic differences helps:
  - Tailor payment offerings
  - Identify regions with higher dependence on credit-based purchases

---

## 🧩 Data Sources
| Layer | View |
|------|------|
| Gold | `gold.fact_payments` |
| Gold | `gold.dim_customers` |

---

## 🛠️ Analytical Approach
- Join payments with customer location data
- Filter to **credit card payments** (the only method supporting installments)
- Compute:
  - Average number of installments per state
  - Total transactions per state for context
- Sort states by highest average installment usage

---

## 📊 Output

<details>
<summary><strong>Click to view results: Average Installments by State</strong></summary>

| Customer State | Avg Installments | Total Transactions |
|---------------|-----------------:|-------------------:|
| PB | 4.68 | 428 |
| SE | 4.57 | 263 |
| AC | 4.52 | 61 |
| RO | 4.41 | 186 |
| AL | 4.39 | 340 |
| RN | 4.39 | 394 |
| PI | 4.28 | 389 |
| PE | 4.23 | 1,334 |
| CE | 4.19 | 1,091 |
| PA | 4.06 | 727 |
| TO | 4.03 | 197 |
| MA | 3.99 | 535 |
| BA | 3.97 | 2,661 |
| MT | 3.97 | 659 |
| AM | 3.82 | 124 |
| RS | 3.80 | 3,982 |
| GO | 3.71 | 1,520 |
| MS | 3.70 | 519 |
| ES | 3.67 | 1,571 |
| MG | 3.64 | 9,066 |
| RJ | 3.58 | 10,280 |
| SC | 3.58 | 2,711 |
| PR | 3.58 | 3,783 |
| RR | 3.42 | 33 |
| AP | 3.40 | 47 |
| DF | 3.23 | 1,699 |
| SP | 3.20 | 32,139 |

</details>

---

## 🔍 Key Insights
- Northeastern states (e.g., **PB, SE, AL, RN**) show **higher average installment usage**
- **São Paulo (SP)** has:
  - The **lowest average installments**
  - The **highest transaction volume**, indicating stronger single/short-payment behavior
- Smaller states show higher averages but with **lower transaction counts**

---

## 📈 Business Interpretation
- Higher installment averages may indicate:
  - Greater reliance on credit
  - Higher price sensitivity
- High-volume states with lower averages suggest:
  - Stronger purchasing power
  - Preference for fewer installments despite large order volumes

---

## ⚠️ Limitations
- Only credit card payments are included
- Average values may be skewed in states with low transaction counts
- Does not account for:
  - Order value
  - Income levels
  - Urban vs rural distribution

---

## 🧱 SQL Reference

```sql

SELECT 
    c.customer_state,
    -- the average number of installments
    CAST(AVG(CAST(p.payment_installments AS FLOAT)) AS DECIMAL(10,2)) AS avg_installments,
    -- Counting total transactions to provide context for the average
    COUNT(p.order_key) AS total_transactions
FROM gold.fact_payments p
JOIN gold.dim_customers c ON p.customer_key = c.customer_key
WHERE p.payment_type = 'credit card' -- primary method supporting installments in the dataset
GROUP BY c.customer_state
ORDER BY avg_installments DESC;
