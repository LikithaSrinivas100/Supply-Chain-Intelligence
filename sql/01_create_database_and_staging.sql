-- Mission 01: Supply Chain Intelligence & Inventory Optimization
-- Database and staging-table setup.
-- Run this script first. Load the cleaned CSV data into the staging tables
-- using the Python/Jupyter workflow in 03_mysql_database_setup.ipynb.

CREATE SCHEMA IF NOT EXISTS freshcart_analytics;
USE freshcart_analytics;

CREATE TABLE IF NOT EXISTS stg_inventory (
    Product_No VARCHAR(50), Store VARCHAR(50), Supplier VARCHAR(100),
    Start_Date DATE, End_Date DATE, Stock_Status VARCHAR(50),
    Qty_on_hand INT, Stocks_Selling_Amount DECIMAL(14,2),
    Cost_of_Stocks DECIMAL(14,2), Stock_Unit_Selling_Price DECIMAL(12,2),
    Stock_Unit_Cost_Price DECIMAL(12,2), Product_Description TEXT,
    Product_Division VARCHAR(150), Product_Category VARCHAR(150),
    Product_Subcategory VARCHAR(150), Product_Segment VARCHAR(200),
    Store_Type VARCHAR(100), Sales_Channel VARCHAR(100),
    flag_negative_stock BOOLEAN, flag_negative_unit_cost BOOLEAN,
    flag_zero_selling_price BOOLEAN, flag_zero_qty_residual_cost BOOLEAN,
    calculated_selling_value DECIMAL(14,2), calculated_cost_value DECIMAL(14,2)
);

CREATE TABLE IF NOT EXISTS stg_demand (
    Date DATE, Store_ID VARCHAR(20), Product_ID VARCHAR(20),
    Category VARCHAR(100), Region VARCHAR(50), Inventory_Level INT,
    Units_Sold INT, Units_Ordered INT, Demand_Forecast DECIMAL(12,2),
    Price DECIMAL(12,2), Discount DECIMAL(8,2),
    Weather_Condition VARCHAR(50), Holiday_Promotion BOOLEAN,
    Competitor_Pricing DECIMAL(12,2), Seasonality VARCHAR(50),
    flag_negative_forecast BOOLEAN, Demand_Forecast_Clean DECIMAL(12,2),
    Inventory_Coverage DECIMAL(12,2)
);

CREATE TABLE IF NOT EXISTS stg_sales (
    Transaction_Date DATE, Sales_Type VARCHAR(50), Is_Return BOOLEAN,
    Reason_of_Return VARCHAR(200), Supplier VARCHAR(100),
    Product_No VARCHAR(50), Product_Description TEXT,
    Product_Division VARCHAR(150), Product_Category VARCHAR(150),
    Product_Subcategory VARCHAR(150), Product_Segment VARCHAR(200),
    Store VARCHAR(50), Sales_Channel VARCHAR(100),
    Qty_Sold DECIMAL(12,2), Sales_Amount DECIMAL(14,2),
    Cogs DECIMAL(14,2), Number_of_Transactions INT,
    flag_negative_quantity BOOLEAN, flag_negative_sales BOOLEAN,
    flag_negative_cogs BOOLEAN, Net_Profit_Contribution DECIMAL(14,2),
    Net_Quantity DECIMAL(12,2), Net_Sales DECIMAL(14,2),
    Net_COGS DECIMAL(14,2)
);
