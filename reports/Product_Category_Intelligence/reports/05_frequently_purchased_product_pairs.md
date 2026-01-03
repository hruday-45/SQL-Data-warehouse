# 🛒 Frequently Purchased Product Pairs

---

## 🧠 Business Question
Which products or categories are commonly **bought together**? Understanding this enables:

- Cross-selling strategies
- Bundling promotions
- Personalized recommendations
- Inventory planning for complementary items

---

## 🎯 Why This Matters
- Identifies **natural product affinities** in customer behavior
- Supports **recommendation engines** and targeted marketing
- Reduces missed sales opportunities by suggesting complementary products at checkout

---

## 🧩 Data Sources
| Layer | View |
|------|------|
| Gold | `gold.fact_sales` |
| Gold | `gold.dim_products` |
| Gold (Temp Table) | `gold.bridge_order_products` |

---

## 🛠️ Analytical Approach
1. Create a **bridge table** with unique `order_key`–`product_key` pairs.
2. Self-join the bridge table on `order_key` to form all **product pairs in the same order**.
3. Exclude **self-pairs** and avoid **duplicate pairs** by enforcing `product_1 < product_2`.
4. Aggregate counts to calculate how often products appear together.
5. Apply a **minimum threshold** (e.g., ≥ 5 orders) to filter noise.

---

## 📊 Sample Output

| Product 1 | Product 2 | Orders Bought Together |
|------------|-----------|----------------------|
| cama_mesa_banho | moveis_decoracao | 70 |
| cama_mesa_banho | casa_conforto | 43 |
| moveis_decoracao | utilidades_domesticas | 24 |
| cama_mesa_banho | utilidades_domesticas | 20 |
| bebes | cool_stuff | 20 |

📁 **Full output:** `reports/Product_Category_Intelligence/full_output/05_frequently_purchased_product_pairs.csv`

---

## 🔍 Key Insights
- **Bedroom & furniture categories** are often paired with home décor or comfort items.
- **Utility products** appear with furniture, suggesting common household upgrade purchases.
- **Baby products** cluster with novelty items (`cool_stuff`), indicating targeted bundle opportunities.
- These pairs can be leveraged for **recommendation engines** and **marketing campaigns**.

---

## 🧱 SQL Reference

```sql

-- Droping the bridge table if it already exists from a previous run to avoid errors.
DROP TABLE IF EXISTS gold.bridge_order_products;

-- Create a 'Bridge Table' that contains unique combinations of orders and products.
SELECT DISTINCT
    order_key,
    product_key
INTO gold.bridge_order_products
FROM gold.fact_sales;

-- Create indexes so the database can quickly find which products belong to which orders.

CREATE CLUSTERED INDEX IX_bop_order
ON gold.bridge_order_products (order_key, product_key);

CREATE NONCLUSTERED INDEX IX_bop_product
ON gold.bridge_order_products (product_key, order_key);

-- joining the bridge table to ITSELF on the 'order_key'.
-- 'bop1.product_key < bop2.product_key' ensures we don't match a product with itself and prevents duplicate pairs
-- (e.g., matching A & B, but not B & A).
SELECT
    dp1.product_category_name AS product_1,
    dp2.product_category_name AS product_2,
    COUNT(DISTINCT bop1.order_key) AS orders_together -- Use DISTINCT to be safe
FROM gold.bridge_order_products bop1
JOIN gold.bridge_order_products bop2
    ON bop1.order_key = bop2.order_key
JOIN gold.dim_products dp1
    ON bop1.product_key = dp1.product_key
JOIN gold.dim_products dp2
    ON bop2.product_key = dp2.product_key
WHERE dp1.product_category_name < dp2.product_category_name -- This is the key change
GROUP BY dp1.product_category_name,
    dp2.product_category_name
HAVING COUNT(*) >= 5 -- Lowered threshold to see hidden patterns
ORDER BY orders_together DESC

-- Cleanup.
DROP TABLE gold.bridge_order_products;
