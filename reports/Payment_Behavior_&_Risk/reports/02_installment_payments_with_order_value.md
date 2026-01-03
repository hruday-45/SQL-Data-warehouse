# 💳 Installment Payments vs Order Value

---

## 🧠 Business Question
Does allowing **installment payments** increase the **average order value (AOV)**?

This analysis focuses exclusively on **credit card payments**, as they are the only payment method that supports installments.

---

## 🎯 Why This Matters
- Installments can:
  - Reduce purchase friction
  - Enable higher-ticket purchases
  - Increase overall revenue
- Understanding installment behavior helps:
  - Optimize checkout options
  - Design pricing and financing strategies
  - Balance risk vs reward for long installment plans

---

## 🧩 Data Source
| Layer | View |
|------|------|
| Gold | `gold.fact_payments` |

---

## 🛠️ Business Logic
- Only **credit card** transactions are included
- Payments are grouped into **installment tiers**:
  - Single payment
  - Short-term installments
  - Medium-term installments
  - Long-term installments
- Metrics calculated:
  - Transaction count
  - Average order value (AOV)
  - Total revenue contribution

---

## 📊 Key Metrics

| Installment Tier | Transactions | Avg Order Value | Total Revenue |
|------------------|-------------:|---------------:|--------------:|
| 1. Single Payment | 25,441 | 95.79 | 2,436,925.04 |
| 2. Short (2–5 installments) | 35,187 | 147.55 | 5,191,941.75 |
| 3. Medium (6–10 installments) | 15,771 | 303.12 | 4,780,561.28 |
| 4. Long (11+ installments) | 340 | 359.07 | 122,085.29 |

---

## 🔍 Key Insights
- **Average order value increases sharply** as installment length increases
- Customers using:
  - 6–10 installments spend **3× more** than single-payment buyers
- Long installment plans have:
  - Very high AOV
  - Very low transaction volume

---

## 📈 Business Interpretation
- Installments are a **strong enabler of high-value purchases**
- Most revenue comes from **short and medium installment plans**
- Long installment plans:
  - Attract fewer customers
  - Likely represent premium or big-ticket items
- A balanced installment strategy maximizes revenue without excessive risk exposure

---

## ⚠️ Risk & Considerations
- Longer installment plans may:
  - Increase default risk
  - Delay cash flow realization
- Requires alignment with:
  - Fraud detection
  - Credit approval rules
  - Payment gateway policies

---

## 🔎 Recommended Follow-Up Analyses
- Installment tier vs:
  - Cancellation rate
  - Late delivery rate
  - Refund frequency
- Installment behavior by:
  - Product category
  - Customer segment
- Revenue concentration risk from long-term installments

---

## 🧱 SQL Reference

```sql

SELECT 
    CASE 
        WHEN payment_installments = 1 THEN '1. Single Payment'
        WHEN payment_installments BETWEEN 2 AND 5 THEN '2. Short (2-5 installments)'
        WHEN payment_installments BETWEEN 6 AND 10 THEN '3. Medium (6-10 installments)'
        ELSE '4. Long (11+ installments)'
    END AS installment_tier,
    COUNT(order_key) AS transaction_count,
    -- Average value of the payment
    CAST(AVG(payment_value) AS DECIMAL(10,2)) AS avg_order_value,
    -- Total revenue contribution
    SUM(payment_value) AS total_revenue
FROM gold.fact_payments
WHERE payment_type = 'credit card'
GROUP BY 
    CASE 
        WHEN payment_installments = 1 THEN '1. Single Payment'
        WHEN payment_installments BETWEEN 2 AND 5 THEN '2. Short (2-5 installments)'
        WHEN payment_installments BETWEEN 6 AND 10 THEN '3. Medium (6-10 installments)'
        ELSE '4. Long (11+ installments)'
    END
ORDER BY installment_tier;
