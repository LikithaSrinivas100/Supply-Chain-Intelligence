-- Dimension tables and population queries.
USE freshcart_analytics;

CREATE TABLE IF NOT EXISTS dim_product (
    product_key INT AUTO_INCREMENT PRIMARY KEY,
    product_no VARCHAR(50) NOT NULL UNIQUE,
    product_description TEXT,
    product_division VARCHAR(150),
    product_category VARCHAR(150),
    product_subcategory VARCHAR(150),
    product_segment VARCHAR(200)
);

INSERT INTO dim_product (
    product_no, product_description, product_division,
    product_category, product_subcategory, product_segment
)
SELECT Product_No, MAX(Product_Description), MAX(Product_Division),
       MAX(Product_Category), MAX(Product_Subcategory), MAX(Product_Segment)
FROM stg_inventory
WHERE Product_No IS NOT NULL
GROUP BY Product_No;

CREATE TABLE IF NOT EXISTS dim_store (
    store_key INT AUTO_INCREMENT PRIMARY KEY,
    store_id VARCHAR(50) NOT NULL UNIQUE,
    store_type VARCHAR(100),
    sales_channel VARCHAR(100)
);

INSERT INTO dim_store (store_id, store_type, sales_channel)
SELECT Store, MAX(Store_Type), MAX(Sales_Channel)
FROM stg_inventory
WHERE Store IS NOT NULL
GROUP BY Store;

CREATE TABLE IF NOT EXISTS dim_supplier (
    supplier_key INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id VARCHAR(100) NOT NULL UNIQUE,
    supplier_name VARCHAR(150)
);

INSERT INTO dim_supplier (supplier_id, supplier_name)
SELECT DISTINCT Supplier, Supplier
FROM stg_inventory
WHERE Supplier IS NOT NULL;

CREATE TABLE IF NOT EXISTS dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    year INT, quarter INT, month INT, month_name VARCHAR(20),
    week_number INT, day_of_month INT, day_name VARCHAR(20),
    day_of_week INT, is_weekend BOOLEAN
);

INSERT INTO dim_date (
    date_key, full_date, year, quarter, month, month_name,
    week_number, day_of_month, day_name, day_of_week, is_weekend
)
SELECT
    CAST(DATE_FORMAT(d, '%Y%m%d') AS UNSIGNED), d, YEAR(d), QUARTER(d),
    MONTH(d), MONTHNAME(d), WEEK(d, 3), DAY(d), DAYNAME(d),
    DAYOFWEEK(d),
    CASE WHEN DAYOFWEEK(d) IN (1, 7) THEN TRUE ELSE FALSE END
FROM (
    SELECT DISTINCT calendar_date AS d
    FROM (
        SELECT Date AS calendar_date FROM stg_demand
        UNION
        SELECT Transaction_Date FROM stg_sales
        UNION
        SELECT Start_Date FROM stg_inventory
        UNION
        SELECT End_Date FROM stg_inventory
    ) all_dates
    WHERE calendar_date IS NOT NULL
) unique_dates;
