# 💳 Payment Method Distribution

---

## 🧠 Business Question
What is the **distribution of payment methods** used by customers, and how much revenue does each method contribute?

This analysis helps understand:
- Customer payment preferences
- Revenue concentration by payment type
- Dependency on specific payment channels

---

## 🎯 Why This Matters
- Payment methods influence:
  - Conversion rates
  - Cash flow timing
  - Fraud and default risk
- Over-reliance on a single payment method can create:
  - Operational risk
  - Payment gateway dependency

---

## 🧩 Data Source
| Layer | View |
|------|------|
| Gold | `gold.fact_payments` |

---

## 🛠️ Business Logic
- Each payment record represents a transaction
- Metrics calculated:
  - Total transactions per payment type
  - Total payment value
  - Percentage share of:
    - Transaction volume
    - Revenue contribution

---

## 📊 Payment Method Breakdown

| Payment Type | Transactions | Total Value | % of Transactions | % of Revenue |
|-------------|-------------:|------------:|------------------:|-------------:|
| Credit Card | 76,739 | 12,531,513.36 | 73.99% | 78.46% |
| Boleto | 19,754 | 2,865,633.94 | 19.05% | 17.94% |
| Voucher | 5,689 | 356,605.26 | 5.49% | 2.23% |
| Debit Card | 1,529 | 217,989.79 | 1.47% | 1.36% |

---

## 🔍 Key Insights
- **Credit cards dominate** both transaction volume and revenue
- Boleto remains a significant secondary payment method
- Voucher and debit card usage is comparatively low
- Revenue share closely follows transaction share, indicating:
  - No major value distortion across payment types

---

## 📈 Business Interpretation
- Credit cards are the **primary revenue driver**
- Supporting boleto is essential for accessibility and inclusion
- Low debit card usage may indicate:
  - UX friction
  - Market preference over functionality
- Voucher usage suggests:
  - Promotional or campaign-driven purchases

---

## 🔎 Recommended Follow-Up Analyses
- Payment method vs:
  - Order value
  - Cancellation rate
  - Late delivery rate
- Conversion funnel analysis by payment type
- Risk exposure for high-value credit card transactions

---

## 🧱 SQL Reference

```sql

SELECT 
    payment_type,
    COUNT(order_key) AS total_transactions,
    SUM(payment_value) AS total_payment_value,

    -- the percentage share of transaction volume
    CAST(100.0 * COUNT(order_key) / SUM(COUNT(order_key)) OVER() AS DECIMAL(5,2)) AS pct_of_transactions,

    -- the percentage share of total revenue
    CAST(100.0 * SUM(payment_value) / SUM(SUM(payment_value)) OVER() AS DECIMAL(5,2)) AS pct_of_revenue
FROM gold.fact_payments
GROUP BY payment_type
ORDER BY total_transactions DESC;
