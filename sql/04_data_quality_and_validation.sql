-- Data quality and load validation queries.
USE freshcart_analytics;

-- Row counts across staging and analytical tables.
SELECT 'stg_inventory' AS table_name, COUNT(*) AS total_rows FROM stg_inventory
UNION ALL SELECT 'stg_demand', COUNT(*) FROM stg_demand
UNION ALL SELECT 'stg_sales', COUNT(*) FROM stg_sales
UNION ALL SELECT 'fact_inventory', COUNT(*) FROM fact_inventory
UNION ALL SELECT 'fact_sales', COUNT(*) FROM fact_sales
UNION ALL SELECT 'fact_demand', COUNT(*) FROM fact_demand;

-- Inventory anomalies.
SELECT
    COUNT(*) AS total_inventory_records,
    SUM(quantity_on_hand < 0) AS negative_stock_records,
    SUM(quantity_on_hand = 0) AS zero_stock_records,
    SUM(unit_cost_price < 0) AS negative_unit_cost_records,
    SUM(unit_selling_price = 0) AS zero_selling_price_records
FROM fact_inventory;

-- Sales returns and net sales.
SELECT
    COUNT(*) AS total_sales_records,
    SUM(is_return = 1) AS return_records,
    SUM(net_sales) AS total_net_sales,
    SUM(net_profit_contribution) AS total_profit_contribution
FROM fact_sales;

-- Demand forecast anomalies.
SELECT
    COUNT(*) AS total_demand_records,
    SUM(flag_negative_forecast = 1) AS flagged_negative_forecasts,
    SUM(demand_forecast_clean < 0) AS remaining_negative_clean_forecasts,
    ROUND(AVG(demand_forecast_clean), 2) AS average_clean_forecast
FROM fact_demand;
