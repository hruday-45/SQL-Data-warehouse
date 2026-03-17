-------------------------------------------------
-- fact_sales
-------------------------------------------------
CREATE NONCLUSTERED INDEX IX_fact_sales_customer
ON gold.fact_sales (customer_key);

CREATE NONCLUSTERED INDEX IX_fact_sales_order
ON gold.fact_sales (order_key);

CREATE NONCLUSTERED INDEX IX_fact_sales_seller
ON gold.fact_sales (seller_key);

CREATE NONCLUSTERED INDEX IX_fact_sales_product
ON gold.fact_sales (product_key);

CREATE NONCLUSTERED INDEX IX_fact_sales_purchase_date
ON gold.fact_sales (order_purchase_timestamp);

-------------------------------------------------
-- fact_payments
-------------------------------------------------
CREATE NONCLUSTERED INDEX IX_fact_payments_customer
ON gold.fact_payments (customer_key);

CREATE NONCLUSTERED INDEX IX_fact_payments_order
ON gold.fact_payments (order_key);

-------------------------------------------------
-- fact_reviews
-------------------------------------------------
CREATE NONCLUSTERED INDEX IX_fact_reviews_customer
ON gold.fact_reviews (customer_key);

CREATE NONCLUSTERED INDEX IX_fact_reviews_order
ON gold.fact_reviews (order_key);