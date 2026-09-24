CREATE TABLE adidas_sales (
    retailer text,
    retailer_id text,
    invoice_date date,
    region text,
    state text,
    city text,
    gender_type text,
    product_category text,
    price_per_unit numeric,
    units_sold int,
    total_sales numeric,
    operating_profit numeric,
    operating_margin numeric,
    sales_method text
);


SELECT COUNT(*) FROM adidas_sales;


-- Preview a small sample of the dataset
SELECT *
FROM adidas_sales
LIMIT 5;


-- Check for missing values in every column
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE retailer IS NULL) AS missing_retailer,
    COUNT(*) FILTER (WHERE retailer_id IS NULL) AS missing_retailer_id,
    COUNT(*) FILTER (WHERE invoice_date IS NULL) AS missing_date,
    COUNT(*) FILTER (WHERE region IS NULL) AS missing_region,
    COUNT(*) FILTER (WHERE state IS NULL) AS missing_state,
    COUNT(*) FILTER (WHERE city IS NULL) AS missing_city,
    COUNT(*) FILTER (WHERE gender_type IS NULL) AS missing_gender,
    COUNT(*) FILTER (WHERE product_category IS NULL) AS missing_category,
    COUNT(*) FILTER (WHERE price_per_unit IS NULL) AS missing_price,
    COUNT(*) FILTER (WHERE units_sold IS NULL) AS missing_units,
    COUNT(*) FILTER (WHERE total_sales IS NULL) AS missing_sales,
    COUNT(*) FILTER (WHERE operating_profit IS NULL) AS missing_profit,
    COUNT(*) FILTER (WHERE operating_margin IS NULL) AS missing_margin,
    COUNT(*) FILTER (WHERE sales_method IS NULL) AS missing_method
FROM adidas_sales;


-- Check for repeated combinations of important identifying fields
-- This does NOT necessarily mean the rows are duplicates
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT (
        retailer,
        invoice_date,
        city,
        gender_type,
        product_category,
        sales_method
    )) AS unique_rows
FROM adidas_sales;


-- Check for completely identical duplicate rows
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT md5(row_to_json(adidas_sales)::text)) AS unique_rows
FROM adidas_sales;


-- Check the date range covered by the dataset
SELECT
    MIN(invoice_date) AS earliest_date,
    MAX(invoice_date) AS latest_date
FROM adidas_sales;


-- Check the ranges of the main numerical variables
SELECT
    MIN(price_per_unit) AS min_price,
    MAX(price_per_unit) AS max_price,
    MIN(units_sold) AS min_units,
    MAX(units_sold) AS max_units,
    MIN(total_sales) AS min_sales,
    MAX(total_sales) AS max_sales,
    MIN(operating_profit) AS min_profit,
    MAX(operating_profit) AS max_profit
FROM adidas_sales;


-- Check whether Total Sales normally equals Price × Units Sold
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE total_sales = price_per_unit * units_sold
    ) AS matching_rows
FROM adidas_sales;


-- Investigate the different relationships between Total Sales and Price × Units
SELECT
    total_sales / NULLIF(price_per_unit * units_sold, 0) AS sales_ratio,
    COUNT(*) AS rows
FROM adidas_sales
GROUP BY sales_ratio
ORDER BY sales_ratio;


-- Investigate where the 10× sales relationship occurs
SELECT
    retailer,
    product_category,
    sales_method,
    COUNT(*) AS rows
FROM adidas_sales
WHERE total_sales = price_per_unit * units_sold * 10
GROUP BY retailer, product_category, sales_method
ORDER BY rows DESC;


-- Check whether any rows have missing values in the sales calculation fields
SELECT *
FROM adidas_sales
WHERE price_per_unit IS NULL
   OR units_sold IS NULL
   OR total_sales IS NULL;


-- View the combinations of retailer, product, gender and sales method
-- Helps understand the structure of the dataset
SELECT DISTINCT
    retailer,
    product_category,
    gender_type,
    sales_method
FROM adidas_sales;


-- List all retailers
SELECT DISTINCT retailer
FROM adidas_sales
ORDER BY retailer;


-- List all regions
SELECT DISTINCT region
FROM adidas_sales
ORDER BY region;


-- List all states
SELECT DISTINCT state
FROM adidas_sales
ORDER BY state;


-- List all cities
SELECT DISTINCT city
FROM adidas_sales
ORDER BY city;


-- List all sales methods
SELECT DISTINCT sales_method
FROM adidas_sales
ORDER BY sales_method;


-- List all product categories
SELECT DISTINCT product_category
FROM adidas_sales
ORDER BY product_category;


-- List all gender categories
SELECT DISTINCT gender_type
FROM adidas_sales
ORDER BY gender_type;


-- Check the range of operating margins
SELECT
    MIN(operating_margin) AS min_margin,
    MAX(operating_margin) AS max_margin
FROM adidas_sales;
--  CHECK OPERATING MARGIN RANGE
SELECT
    MIN(Operating_Margin) AS min_margin,
    MAX(Operating_Margin) AS max_margin
FROM adidas_sales;


--  CHECK FOR NEGATIVE VALUES
SELECT
    COUNT(*) FILTER (WHERE Price_per_Unit < 0) AS negative_prices,
    COUNT(*) FILTER (WHERE Units_Sold < 0) AS negative_units,
    COUNT(*) FILTER (WHERE Total_Sales < 0) AS negative_sales,
    COUNT(*) FILTER (WHERE Operating_Profit < 0) AS negative_profit
FROM adidas_sales;

-- Overall commercial performance
SELECT
    SUM(total_sales) AS total_sales,
    SUM(operating_profit) AS total_profit,
    SUM(units_sold) AS total_units,
    AVG(price_per_unit) AS avg_price,
    SUM(operating_profit) / NULLIF(SUM(total_sales), 0) AS overall_margin
FROM adidas_sales;

-- Commercial performance by product category
SELECT
    product_category,
    SUM(total_sales) AS total_sales,
    SUM(operating_profit) AS total_profit,
    SUM(units_sold) AS units_sold,
    SUM(operating_profit) / NULLIF(SUM(total_sales), 0) AS profit_margin
FROM adidas_sales
GROUP BY product_category
ORDER BY total_sales DESC;

--  CHECK ZERO VALUES
SELECT
    COUNT(*) FILTER (WHERE Price_per_Unit = 0) AS zero_prices,
    COUNT(*) FILTER (WHERE Units_Sold = 0) AS zero_units,
    COUNT(*) FILTER (WHERE Total_Sales = 0) AS zero_sales,
    COUNT(*) FILTER (WHERE Operating_Profit = 0) AS zero_profit
FROM adidas_sales;


--  CHECK OPERATING MARGIN CALCULATION
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE ROUND(Operating_Profit / NULLIF(Total_Sales, 0), 2)
              = ROUND(Operating_Margin, 2)
    ) AS matching_margin_rows
FROM adidas_sales;


--  BASIC BUSINESS SUMMARY
SELECT
    COUNT(*) AS rows,
    SUM(Total_Sales) AS total_sales,
    SUM(Operating_Profit) AS total_profit,
    SUM(Units_Sold) AS total_units,
    AVG(Price_per_Unit) AS average_price
FROM adidas_sales;


--  SALES BY YEAR
SELECT
    EXTRACT(YEAR FROM Invoice_Date) AS year,
    SUM(Total_Sales) AS total_sales,
    SUM(Operating_Profit) AS total_profit
FROM adidas_sales
GROUP BY year
ORDER BY year;


--  SALES BY PRODUCT CATEGORY
SELECT
    Product_Category,
    SUM(Total_Sales) AS total_sales,
    SUM(Operating_Profit) AS total_profit,
    SUM(Units_Sold) AS units_sold
FROM adidas_sales
GROUP BY Product_Category
ORDER BY total_sales DESC;


--  SALES BY RETAILER
SELECT
    Retailer,
    SUM(Total_Sales) AS total_sales,
    SUM(Operating_Profit) AS total_profit,
    SUM(Units_Sold) AS units_sold
FROM adidas_sales
GROUP BY Retailer
ORDER BY total_sales DESC;


--  SALES BY SALES METHOD
SELECT
    Sales_Method,
    SUM(Total_Sales) AS total_sales,
    SUM(Operating_Profit) AS total_profit,
    SUM(Units_Sold) AS units_sold
FROM adidas_sales
GROUP BY Sales_Method
ORDER BY total_sales DESC;


--  SALES BY REGION
SELECT
    Region,
    SUM(Total_Sales) AS total_sales,
    SUM(Operating_Profit) AS total_profit,
    SUM(Units_Sold) AS units_sold
FROM adidas_sales
GROUP BY Region
ORDER BY total_sales DESC;


-- Commercial performance by retailer
SELECT
    retailer,
    SUM(total_sales) AS total_sales,
    SUM(operating_profit) AS total_profit,
    SUM(units_sold) AS units_sold,
    SUM(operating_profit) / NULLIF(SUM(total_sales), 0) AS profit_margin
FROM adidas_sales
GROUP BY retailer
ORDER BY total_sales DESC;

-- Compare performance across sales channels
SELECT
    sales_method,
    SUM(total_sales) AS total_sales,
    SUM(operating_profit) AS total_profit,
    SUM(units_sold) AS units_sold,
    SUM(operating_profit) / NULLIF(SUM(total_sales), 0) AS profit_margin
FROM adidas_sales
GROUP BY sales_method
ORDER BY total_sales DESC;

-- Compare commercial performance by region
SELECT
    region,
    SUM(total_sales) AS total_sales,
    SUM(operating_profit) AS total_profit,
    SUM(units_sold) AS units_sold,
    SUM(operating_profit) / NULLIF(SUM(total_sales), 0) AS profit_margin
FROM adidas_sales
GROUP BY region
ORDER BY total_sales DESC;

-- Compare commercial performance by gender
SELECT
    gender_type,
    SUM(total_sales) AS total_sales,
    SUM(operating_profit) AS total_profit,
    SUM(units_sold) AS units_sold,
    SUM(operating_profit) / NULLIF(SUM(total_sales), 0) AS profit_margin
FROM adidas_sales
GROUP BY gender_type
ORDER BY total_sales DESC;

-- Track sales and profit over time
SELECT
    DATE_TRUNC('month', invoice_date) AS month,
    SUM(total_sales) AS total_sales,
    SUM(operating_profit) AS total_profit
FROM adidas_sales
GROUP BY month
ORDER BY month;

-- Compare products within each retailer
SELECT
    retailer,
    product_category,
    SUM(total_sales) AS total_sales,
    SUM(operating_profit) AS total_profit,
    SUM(operating_profit) / NULLIF(SUM(total_sales), 0) AS profit_margin
FROM adidas_sales
GROUP BY retailer, product_category
ORDER BY total_sales DESC;

-- Find combinations with strong profitability
SELECT
    retailer,
    product_category,
    SUM(total_sales) AS total_sales,
    SUM(operating_profit) AS total_profit,
    ROUND(
        SUM(operating_profit) / NULLIF(SUM(total_sales), 0),
        3
    ) AS profit_margin
FROM adidas_sales
GROUP BY retailer, product_category
ORDER BY profit_margin DESC;

-- Find combinations with high sales but relatively lower margins
SELECT
    retailer,
    product_category,
    SUM(total_sales) AS total_sales,
    SUM(operating_profit) AS total_profit,
    ROUND(
        SUM(operating_profit) / NULLIF(SUM(total_sales), 0),
        3
    ) AS profit_margin
FROM adidas_sales
GROUP BY retailer, product_category
HAVING SUM(total_sales) > 50000000
ORDER BY profit_margin ASC;

-- Compare commercial performance by state
SELECT
    state,
    SUM(total_sales) AS total_sales,
    SUM(operating_profit) AS total_profit,
    ROUND(
        SUM(operating_profit) / NULLIF(SUM(total_sales), 0),
        3
    ) AS profit_margin
FROM adidas_sales
GROUP BY state
ORDER BY total_sales DESC;

-- Find sales and profit trends by month
SELECT
    DATE_TRUNC('month', invoice_date) AS month,
    SUM(total_sales) AS total_sales,
    SUM(operating_profit) AS total_profit,
    ROUND(
        SUM(operating_profit) / NULLIF(SUM(total_sales), 0),
        3
    ) AS profit_margin
FROM adidas_sales
GROUP BY month
ORDER BY month;

-- Compare overall performance between years
SELECT
    EXTRACT(YEAR FROM invoice_date) AS year,
    SUM(total_sales) AS total_sales,
    SUM(operating_profit) AS total_profit,
    SUM(units_sold) AS units_sold,
    ROUND(
        SUM(operating_profit) / NULLIF(SUM(total_sales), 0),
        3
    ) AS profit_margin
FROM adidas_sales
GROUP BY year
ORDER BY year;

-- Compare each product category across 2020 and 2021
SELECT
    product_category,
    EXTRACT(YEAR FROM invoice_date) AS year,
    SUM(total_sales) AS total_sales,
    SUM(operating_profit) AS total_profit,
    SUM(units_sold) AS units_sold,
    ROUND(
        SUM(operating_profit) / NULLIF(SUM(total_sales), 0),
        3
    ) AS profit_margin
FROM adidas_sales
GROUP BY product_category, EXTRACT(YEAR FROM invoice_date)
ORDER BY product_category, year;


-- Compare each retailer across 2020 and 2021
SELECT
    retailer,
    EXTRACT(YEAR FROM invoice_date) AS year,
    SUM(total_sales) AS total_sales,
    SUM(operating_profit) AS total_profit,
    SUM(units_sold) AS units_sold,
    ROUND(
        SUM(operating_profit) / NULLIF(SUM(total_sales), 0),
        3
    ) AS profit_margin
FROM adidas_sales
GROUP BY retailer, EXTRACT(YEAR FROM invoice_date)
ORDER BY retailer, year;

-- Calculate 2020 to 2021 sales growth by retailer
SELECT
    retailer,
    SUM(total_sales) FILTER (
        WHERE EXTRACT(YEAR FROM invoice_date) = 2020
    ) AS sales_2020,
    SUM(total_sales) FILTER (
        WHERE EXTRACT(YEAR FROM invoice_date) = 2021
    ) AS sales_2021,
    ROUND(
        (
            SUM(total_sales) FILTER (
                WHERE EXTRACT(YEAR FROM invoice_date) = 2021
            )
            -
            SUM(total_sales) FILTER (
                WHERE EXTRACT(YEAR FROM invoice_date) = 2020
            )
        )
        / NULLIF(
            SUM(total_sales) FILTER (
                WHERE EXTRACT(YEAR FROM invoice_date) = 2020
            ),
            0
        ) * 100,
        1
    ) AS sales_growth_pct
FROM adidas_sales
GROUP BY retailer
ORDER BY sales_growth_pct DESC;

-- Compare product category growth between 2020 and 2021
SELECT
    product_category,
    SUM(total_sales) FILTER (
        WHERE EXTRACT(YEAR FROM invoice_date) = 2020
    ) AS sales_2020,
    SUM(total_sales) FILTER (
        WHERE EXTRACT(YEAR FROM invoice_date) = 2021
    ) AS sales_2021,
    ROUND(
        (
            SUM(total_sales) FILTER (
                WHERE EXTRACT(YEAR FROM invoice_date) = 2021
            )
            -
            SUM(total_sales) FILTER (
                WHERE EXTRACT(YEAR FROM invoice_date) = 2020
            )
        )
        / NULLIF(
            SUM(total_sales) FILTER (
                WHERE EXTRACT(YEAR FROM invoice_date) = 2020
            ),
            0
        ) * 100,
        1
    ) AS sales_growth_pct
FROM adidas_sales
GROUP BY product_category
ORDER BY sales_growth_pct DESC;

-- Compare regional sales growth between 2020 and 2021
SELECT
    region,
    SUM(total_sales) FILTER (
        WHERE EXTRACT(YEAR FROM invoice_date) = 2020
    ) AS sales_2020,
    SUM(total_sales) FILTER (
        WHERE EXTRACT(YEAR FROM invoice_date) = 2021
    ) AS sales_2021,
    ROUND(
        (
            SUM(total_sales) FILTER (
                WHERE EXTRACT(YEAR FROM invoice_date) = 2021
            )
            -
            SUM(total_sales) FILTER (
                WHERE EXTRACT(YEAR FROM invoice_date) = 2020
            )
        )
        / NULLIF(
            SUM(total_sales) FILTER (
                WHERE EXTRACT(YEAR FROM invoice_date) = 2020
            ),
            0
        ) * 100,
        1
    ) AS sales_growth_pct
FROM adidas_sales
GROUP BY region
ORDER BY sales_growth_pct DESC;

-- Compare regional sales, profit and margin
SELECT
    region,
    SUM(total_sales) AS total_sales,
    SUM(operating_profit) AS total_profit,
    SUM(units_sold) AS units_sold,
    ROUND(
        SUM(operating_profit) / NULLIF(SUM(total_sales), 0) * 100,
        1
    ) AS profit_margin
FROM adidas_sales
GROUP BY region
ORDER BY total_sales DESC;

-- Compare sales method performance between 2020 and 2021
SELECT
    sales_method,
    EXTRACT(YEAR FROM invoice_date) AS year,
    SUM(total_sales) AS total_sales,
    SUM(operating_profit) AS total_profit,
    SUM(units_sold) AS units_sold,
    ROUND(
        SUM(operating_profit) / NULLIF(SUM(total_sales), 0) * 100,
        1
    ) AS profit_margin
FROM adidas_sales
GROUP BY sales_method, EXTRACT(YEAR FROM invoice_date)

-- Find high-sales areas where profitability is relatively weak
SELECT
    retailer,
    region,
    product_category,
    sales_method,
    SUM(total_sales) AS total_sales,
    SUM(operating_profit) AS total_profit,
    ROUND(
        SUM(operating_profit) / NULLIF(SUM(total_sales), 0) * 100,
        1
    ) AS profit_margin
FROM adidas_sales
GROUP BY retailer, region, product_category, sales_method
HAVING SUM(total_sales) > 20000000
ORDER BY profit_margin ASC;

-- Compare average margin across the main commercial dimensions
SELECT
    'Retailer' AS dimension,
    retailer AS category,
    ROUND(
        SUM(operating_profit) / NULLIF(SUM(total_sales), 0) * 100,
        1
    ) AS profit_margin
FROM adidas_sales
GROUP BY retailer

UNION ALL

SELECT
    'Product' AS dimension,
    product_category AS category,
    ROUND(
        SUM(operating_profit) / NULLIF(SUM(total_sales), 0) * 100,
        1
    ) AS profit_margin
FROM adidas_sales
GROUP BY product_category

UNION ALL

SELECT
    'Sales Method' AS dimension,
    sales_method AS category,
    ROUND(
        SUM(operating_profit) / NULLIF(SUM(total_sales), 0) * 100,
        1
    ) AS profit_margin
FROM adidas_sales
GROUP BY sales_method

UNION ALL

SELECT
    'Region' AS dimension,
    region AS category,
    ROUND(
        SUM(operating_profit) / NULLIF(SUM(total_sales), 0) * 100,
        1
    ) AS profit_margin
FROM adidas_sales
GROUP BY region

ORDER BY dimension, profit_margin;
ORDER BY sales_method, year;

-- Flag commercially important areas that may need investigation
SELECT
    retailer,
    region,
    product_category,
    sales_method,
    SUM(total_sales) AS total_sales,
    SUM(operating_profit) AS total_profit,
    ROUND(
        SUM(operating_profit) / NULLIF(SUM(total_sales), 0) * 100,
        1
    ) AS profit_margin
FROM adidas_sales
GROUP BY retailer, region, product_category, sales_method
HAVING SUM(total_sales) > 20000000
   AND SUM(operating_profit) / NULLIF(SUM(total_sales), 0) < 0.35
ORDER BY total_sales DESC;

-- Check state-level commercial performance
SELECT
    state,
    SUM(total_sales) AS total_sales,
    SUM(operating_profit) AS total_profit,
    ROUND(
        SUM(operating_profit) / NULLIF(SUM(total_sales), 0) * 100,
        1
    ) AS profit_margin
FROM adidas_sales
GROUP BY state
ORDER BY total_sales DESC;

-- Identify high-sales areas with weak profitability
SELECT
    state,
    retailer,
    product_category,
    sales_method,
    SUM(total_sales) AS total_sales,
    SUM(operating_profit) AS total_profit,
    ROUND(
        SUM(operating_profit) / NULLIF(SUM(total_sales), 0) * 100,
        1
    ) AS profit_margin
FROM adidas_sales
GROUP BY state, retailer, product_category, sales_method
HAVING SUM(total_sales) > 10000000
   AND SUM(operating_profit) / NULLIF(SUM(total_sales), 0) < 0.35
ORDER BY total_sales DESC;

SELECT
    SUM(total_sales) / NULLIF(SUM(units_sold), 0) AS average_selling_price
FROM adidas_sales;

-- Check whether Total Sales is effectively Revenue
SELECT
    SUM(total_sales) AS revenue,
    SUM(operating_profit) AS operating_profit,
    SUM(total_sales) - SUM(operating_profit) AS implied_costs
FROM adidas_sales;