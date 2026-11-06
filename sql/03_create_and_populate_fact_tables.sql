-- Fact tables and population queries.
-- Assumes staging and dimension tables have already been populated.
USE freshcart_analytics;

CREATE TABLE IF NOT EXISTS fact_inventory (
    inventory_key BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_key INT NOT NULL, store_key INT NOT NULL, supplier_key INT NOT NULL,
    start_date_key INT, end_date_key INT, stock_status VARCHAR(50),
    quantity_on_hand INT, selling_value DECIMAL(14,2), cost_value DECIMAL(14,2),
    unit_selling_price DECIMAL(12,2), unit_cost_price DECIMAL(12,2),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    FOREIGN KEY (store_key) REFERENCES dim_store(store_key),
    FOREIGN KEY (supplier_key) REFERENCES dim_supplier(supplier_key),
    FOREIGN KEY (start_date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (end_date_key) REFERENCES dim_date(date_key)
);

INSERT INTO fact_inventory (
    product_key, store_key, supplier_key, start_date_key, end_date_key,
    stock_status, quantity_on_hand, selling_value, cost_value,
    unit_selling_price, unit_cost_price
)
SELECT p.product_key, st.store_key, su.supplier_key,
       CAST(DATE_FORMAT(i.Start_Date, '%Y%m%d') AS UNSIGNED),
       CAST(DATE_FORMAT(i.End_Date, '%Y%m%d') AS UNSIGNED),
       i.Stock_Status, i.Qty_on_hand, i.Stocks_Selling_Amount,
       i.Cost_of_Stocks, i.Stock_Unit_Selling_Price, i.Stock_Unit_Cost_Price
FROM stg_inventory i
INNER JOIN dim_product p ON i.Product_No = p.product_no
INNER JOIN dim_store st ON i.Store = st.store_id
INNER JOIN dim_supplier su ON i.Supplier = su.supplier_id;

CREATE TABLE IF NOT EXISTS fact_sales (
    sales_key BIGINT AUTO_INCREMENT PRIMARY KEY,
    date_key INT, product_key INT, store_key INT, supplier_key INT,
    sales_type VARCHAR(50), is_return TINYINT(1), reason_of_return VARCHAR(200),
    qty_sold DECIMAL(12,2), sales_amount DECIMAL(14,2), cogs DECIMAL(14,2),
    number_of_transactions INT, net_profit_contribution DECIMAL(14,2),
    net_quantity DECIMAL(12,2), net_sales DECIMAL(14,2), net_cogs DECIMAL(14,2),
    flag_negative_quantity TINYINT(1), flag_negative_sales TINYINT(1),
    flag_negative_cogs TINYINT(1),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    FOREIGN KEY (store_key) REFERENCES dim_store(store_key),
    FOREIGN KEY (supplier_key) REFERENCES dim_supplier(supplier_key)
);

INSERT INTO fact_sales (
    date_key, product_key, store_key, supplier_key, sales_type, is_return,
    reason_of_return, qty_sold, sales_amount, cogs, number_of_transactions,
    net_profit_contribution, net_quantity, net_sales, net_cogs,
    flag_negative_quantity, flag_negative_sales, flag_negative_cogs
)
SELECT d.date_key, p.product_key, st.store_key, su.supplier_key,
       s.Sales_Type, s.Is_Return, s.Reason_of_Return, s.Qty_Sold,
       s.Sales_Amount, s.Cogs, s.Number_of_Transactions,
       s.Net_Profit_Contribution, s.Net_Quantity, s.Net_Sales, s.Net_COGS,
       s.flag_negative_quantity, s.flag_negative_sales, s.flag_negative_cogs
FROM stg_sales s
LEFT JOIN dim_date d ON s.Transaction_Date = d.full_date
LEFT JOIN dim_product p ON s.Product_No = p.product_no
LEFT JOIN dim_store st ON s.Store = st.store_id
LEFT JOIN dim_supplier su ON s.Supplier = su.supplier_id;

CREATE TABLE IF NOT EXISTS fact_demand (
    demand_key BIGINT AUTO_INCREMENT PRIMARY KEY,
    date_key INT, store_id VARCHAR(20), product_id VARCHAR(20),
    category VARCHAR(100), region VARCHAR(50), inventory_level INT,
    units_sold INT, units_ordered INT, demand_forecast DECIMAL(12,2),
    demand_forecast_clean DECIMAL(12,2), flag_negative_forecast TINYINT(1),
    inventory_coverage DECIMAL(12,2), price DECIMAL(12,2),
    discount DECIMAL(8,2), competitor_pricing DECIMAL(12,2),
    weather_condition VARCHAR(50), holiday_promotion TINYINT(1),
    seasonality VARCHAR(50),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key)
);

INSERT INTO fact_demand (
    date_key, store_id, product_id, category, region, inventory_level,
    units_sold, units_ordered, demand_forecast, demand_forecast_clean,
    flag_negative_forecast, inventory_coverage, price, discount,
    competitor_pricing, weather_condition, holiday_promotion, seasonality
)
SELECT d.date_key, s.Store_ID, s.Product_ID, s.Category, s.Region,
       s.Inventory_Level, s.Units_Sold, s.Units_Ordered, s.Demand_Forecast,
       s.Demand_Forecast_Clean, s.flag_negative_forecast,
       s.Inventory_Coverage, s.Price, s.Discount, s.Competitor_Pricing,
       s.Weather_Condition, s.Holiday_Promotion, s.Seasonality
FROM stg_demand s
LEFT JOIN dim_date d ON s.Date = d.full_date;
