-- Business analysis queries used in Mission 01.
USE freshcart_analytics;

-- Inventory KPIs.
SELECT
    COUNT(*) AS total_inventory_records,
    COUNT(DISTINCT product_key) AS unique_products,
    COUNT(DISTINCT store_key) AS unique_stores,
    COUNT(DISTINCT supplier_key) AS unique_suppliers,
    SUM(quantity_on_hand < 0) AS negative_stock_records,
    SUM(quantity_on_hand = 0) AS zero_stock_records,
    ROUND(AVG(quantity_on_hand), 2) AS avg_quantity_on_hand,
    ROUND(SUM(selling_value), 2) AS total_recorded_selling_value,
    ROUND(SUM(cost_value), 2) AS total_recorded_cost_value
FROM fact_inventory;

-- Stock status distribution.
SELECT stock_status, COUNT(*) AS total_records,
       SUM(quantity_on_hand) AS total_quantity,
       ROUND(AVG(quantity_on_hand), 2) AS avg_quantity,
       ROUND(SUM(selling_value), 2) AS recorded_selling_value,
       ROUND(SUM(cost_value), 2) AS recorded_cost_value
FROM fact_inventory
GROUP BY stock_status
ORDER BY total_records DESC;

-- Store-level stock risk.
SELECT st.store_id, COUNT(*) AS total_records,
       SUM(fi.quantity_on_hand < 0) AS negative_stock_records,
       ROUND(100.0 * SUM(fi.quantity_on_hand < 0) / COUNT(*), 2) AS negative_stock_rate,
       SUM(fi.quantity_on_hand = 0) AS zero_stock_records,
       ROUND(100.0 * SUM(fi.quantity_on_hand = 0) / COUNT(*), 2) AS zero_stock_rate
FROM fact_inventory fi
JOIN dim_store st ON fi.store_key = st.store_key
GROUP BY st.store_id
ORDER BY negative_stock_rate DESC;

-- Supplier-level stock risk (minimum 500 observations).
SELECT su.supplier_id, su.supplier_name,
       COUNT(*) AS inventory_records,
       COUNT(DISTINCT fi.product_key) AS products_supplied,
       SUM(fi.quantity_on_hand = 0) AS zero_stock_records,
       SUM(fi.quantity_on_hand < 0) AS negative_stock_records,
       ROUND(100.0 * SUM(fi.quantity_on_hand = 0) / COUNT(*), 2) AS zero_stock_rate
FROM fact_inventory fi
JOIN dim_supplier su ON fi.supplier_key = su.supplier_key
GROUP BY su.supplier_id, su.supplier_name
HAVING COUNT(*) >= 500
ORDER BY zero_stock_rate DESC;

-- ABC classification based on cumulative net sales.
WITH product_sales AS (
    SELECT p.product_key, p.product_no, p.product_description,
           SUM(s.net_sales) AS total_net_sales
    FROM fact_sales s
    JOIN dim_product p ON s.product_key = p.product_key
    GROUP BY p.product_key, p.product_no, p.product_description
),
ranked_products AS (
    SELECT *,
           SUM(total_net_sales) OVER () AS overall_sales,
           SUM(total_net_sales) OVER (
               ORDER BY total_net_sales DESC, product_key
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           ) AS cumulative_sales
    FROM product_sales
)
SELECT product_no, product_description,
       ROUND(total_net_sales, 2) AS total_net_sales,
       ROUND(100.0 * total_net_sales / NULLIF(overall_sales, 0), 2) AS sales_contribution_pct,
       ROUND(100.0 * cumulative_sales / NULLIF(overall_sales, 0), 2) AS cumulative_sales_pct,
       CASE
           WHEN cumulative_sales / NULLIF(overall_sales, 0) <= 0.80 THEN 'A'
           WHEN cumulative_sales / NULLIF(overall_sales, 0) <= 0.95 THEN 'B'
           ELSE 'C'
       END AS abc_category
FROM ranked_products
ORDER BY total_net_sales DESC;

-- Top product/store zero-stock risk for selected A-class products.
SELECT p.product_no, st.store_id, COUNT(*) AS inventory_records,
       SUM(fi.quantity_on_hand = 0) AS zero_stock_records,
       SUM(fi.quantity_on_hand < 0) AS negative_stock_records,
       ROUND(100.0 * SUM(fi.quantity_on_hand = 0) / COUNT(*), 2) AS zero_stock_rate
FROM fact_inventory fi
JOIN dim_product p ON fi.product_key = p.product_key
JOIN dim_store st ON fi.store_key = st.store_key
WHERE p.product_no IN ('PROD-166368', 'PROD-166365', 'PROD-166367')
GROUP BY p.product_no, st.store_id
ORDER BY p.product_no, zero_stock_records DESC;
