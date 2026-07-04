-- CREATE AND SELECT THE DATABASE
-- Create the project database.
CREATE DATABASE olist_db;

-- Select the database for all subsequent operations.
USE olist_db;

-- VERIFY IMPORTED TABLES
-- Display all tables available in the database.
SHOW TABLES;

-- INSPECT TABLE STRUCTURES
-- Display the structure of each important table.
DESCRIBE products;
DESCRIBE customers;
DESCRIBE orders;
DESCRIBE order_items;

-- CHECK TOTAL RECORDS

-- Count the total number of customers.
SELECT COUNT(*) AS customers_count
FROM customers;

-- Count the total number of orders.
SELECT COUNT(*) AS orders_count
FROM orders;

-- Count the total number of order items.
SELECT COUNT(*) AS order_items_count
FROM order_items;

-- VERIFY CUSTOMER-ORDER RELATIONSHIP
-- Count matching records between
-- customers and orders tables.

SELECT COUNT(*) AS matching_records
FROM orders o
INNER JOIN customers c
ON o.customer_id = c.customer_id;

-- ============================================================
-- VERIFY ORDER-ITEM RELATIONSHIP
-- Count matching records between
-- orders and order_items tables.
SELECT COUNT(*) AS matching_records
FROM order_items oi
INNER JOIN orders o
ON oi.order_id = o.order_id;

-- ============================================================
-- CHECK FOR ORPHAN ORDERS
-- Identify orders without matching customers.
SELECT COUNT(*) AS orphan_orders
FROM orders o
LEFT JOIN customers c
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- ============================================================
-- CHECK FOR ORPHAN ORDER ITEMS
-- Identify order items without matching orders.
SELECT COUNT(*) AS orphan_order_items
FROM order_items oi
LEFT JOIN orders o
ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- ============================================================
-- CHECK MISSING DELIVERY DATES
-- Count orders where the delivery date
-- is missing.
SELECT COUNT(*) AS missing_delivery_dates
FROM orders
WHERE order_delivered_customer_date IS NULL;

-- ============================================================
-- ANALYZE MISSING DELIVERY DATES
-- Display order status for orders
-- with missing delivery dates.
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
WHERE order_delivered_customer_date IS NULL
GROUP BY order_status;

-- ============================================================
-- DISPLAY SAMPLE ORDERS WITH MISSING DELIVERY DATES
SELECT
    order_id,
    order_status,
    order_purchase_timestamp,
    order_delivered_customer_date
FROM orders
WHERE order_delivered_customer_date IS NULL
LIMIT 20;

-- ============================================================
-- CREATE CLEANED ORDERS VIEW
-- Create a view that classifies orders
-- based on delivery status.
CREATE OR REPLACE VIEW orders_cleaned AS
SELECT
    *,
    CASE
        WHEN order_delivered_customer_date IS NULL
            THEN 'Not Delivered'
        ELSE 'Delivered'
    END AS delivery_status
FROM orders;

-- ============================================================
-- DISPLAY SAMPLE RECORDS FROM THE CLEANED ORDERS VIEW
-- Display the first 10 records from the cleaned orders view
-- to verify that the delivery_status column was created correctly.
SELECT *
FROM orders_cleaned
LIMIT 10;

-- ============================================================
-- COUNT ORDERS BY DELIVERY STATUS
-- Count the total number of delivered and
-- not delivered orders.
SELECT
    delivery_status,
    COUNT(*) AS total_orders
FROM orders_cleaned
GROUP BY delivery_status;

-- ============================================================
-- PREVIEW ORDER DATE COLUMNS
-- Display purchase and delivery timestamps
-- for a sample of orders.
SELECT
    order_purchase_timestamp,
    order_delivered_customer_date
FROM orders
LIMIT 10;

-- ============================================================
-- INSPECT ORDERS TABLE STRUCTURE
-- Display the structure of the orders table.
DESCRIBE orders;

-- ============================================================
-- CONVERT PURCHASE TIMESTAMP TO DATETIME
-- Convert the purchase timestamp column
-- to the DATETIME data type.
ALTER TABLE orders
MODIFY order_purchase_timestamp DATETIME;

-- ============================================================
-- CONVERT DELIVERY TIMESTAMP TO DATETIME
-- Convert the delivery timestamp column
-- to the DATETIME data type.
ALTER TABLE orders
MODIFY order_delivered_customer_date DATETIME;

-- ============================================================
-- CHECK FOR MISSING DELIVERY DATES
-- Count the number of orders with missing delivery dates.
SELECT COUNT(*) AS missing_delivery_dates
FROM orders
WHERE order_delivered_customer_date IS NULL;

SELECT *
FROM orders
WHERE order_delivered_customer_date IS NULL;

-- ============================================================
-- CREATE CLEANED ORDERS DATE VIEW
-- Create a view containing useful date features
-- for time-based analysis.
CREATE OR REPLACE VIEW orders_dates_clean AS
SELECT
    order_id,
    customer_id,
    DATE(order_purchase_timestamp) AS purchase_date,
    MONTH(order_purchase_timestamp) AS purchase_month,
    YEAR(order_purchase_timestamp) AS purchase_year,
    order_purchase_timestamp,
    order_delivered_customer_date
FROM orders;

-- ============================================================
-- DISPLAY SAMPLE RECORDS FROM THE CLEANED ORDERS DATE VIEW
-- Display the first 10 records from the cleaned
-- orders date view to verify the extracted
-- purchase date, month, and year.
SELECT *
FROM orders_dates_clean
LIMIT 10;

-- ============================================================
-- PREVIEW PAYMENT VALUES
-- Display sample payment values before
-- performing data cleaning.
SELECT payment_value
FROM order_payments
LIMIT 10;

-- ============================================================
-- INSPECT PAYMENT TABLE STRUCTURE
-- Display the schema of the payment table.
DESCRIBE order_payments;

-- ============================================================
-- STANDARDIZE PAYMENT VALUES
-- Round payment values to two decimal places
-- for consistent financial reporting.
SELECT
    ROUND(payment_value, 2) AS standardized_payment
FROM order_payments
LIMIT 10;

-- ============================================================
-- CREATE CLEAN PAYMENT VIEW
-- Create a reusable view containing
-- cleaned payment information.
CREATE OR REPLACE VIEW payments_clean AS
SELECT
    order_id,
    payment_type,
    ROUND(payment_value, 2) AS payment_value_brl
FROM order_payments;

-- ============================================================
-- DISPLAY SAMPLE RECORDS FROM THE CLEAN PAYMENT VIEW
-- Display the first 10 records from
-- the cleaned payment view.
SELECT *
FROM payments_clean
LIMIT 10;

-- ============================================================
-- CHECK FOR MISSING PAYMENT VALUES
-- Count the number of missing payment values.
SELECT COUNT(*) AS missing_payment_values
FROM order_payments
WHERE payment_value IS NULL;

-- ============================================================
-- FIND THE REFERENCE DATE FOR RECENCY CALCULATION
-- Retrieve the most recent purchase date in the dataset.
-- This date is used as the reference point for calculating
-- customer Recency.
SELECT
    MAX(order_purchase_timestamp) AS max_order_date
FROM orders;

-- ============================================================
-- FIND THE LAST PURCHASE DATE FOR EACH CUSTOMER
-- Retrieve the latest purchase date
-- for every customer.
SELECT
    c.customer_unique_id,
    MAX(o.order_purchase_timestamp) AS last_order_date
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
LIMIT 10;

-- ============================================================
-- CALCULATE CUSTOMER RECENCY
-- Calculate the number of days since each
-- customer's last purchase using the latest
-- order date as the reference.
SELECT
    c.customer_unique_id,
    MAX(o.order_purchase_timestamp) AS last_order_date,
    DATEDIFF(
        (SELECT MAX(order_purchase_timestamp) FROM orders),
        MAX(o.order_purchase_timestamp)
    ) AS Recency
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
LIMIT 20;

-- ============================================================
-- CREATE CUSTOMER RECENCY VIEW
-- Create a reusable SQL view containing
-- the Recency value for every customer.
CREATE OR REPLACE VIEW customer_recency AS
SELECT
    c.customer_unique_id,
    DATEDIFF(
        (SELECT MAX(order_purchase_timestamp) FROM orders),
        MAX(o.order_purchase_timestamp)
    ) AS Recency
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id;

-- ============================================================
-- DISPLAY CUSTOMER RECENCY DATA
-- Display the first 10 records from the
-- customer_recency view for verification.
SELECT *
FROM customer_recency
LIMIT 10;

-- ============================================================
-- CALCULATE CUSTOMER PURCHASE FREQUENCY
-- Count the total number of unique orders placed
-- by each customer.
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS Frequency
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY Frequency DESC;

-- ============================================================
-- GENERATE FREQUENCY SUMMARY STATISTICS
-- Calculate the minimum, maximum,
-- and average purchase frequency.
SELECT
    MIN(Frequency) AS Minimum_Frequency,
    MAX(Frequency) AS Maximum_Frequency,
    AVG(Frequency) AS Average_Frequency
FROM
(
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS Frequency
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) AS frequency_summary;

-- ============================================================
-- CALCULATE CUSTOMER MONETARY VALUE
-- Calculate the total amount spent
-- by each customer.
SELECT
    c.customer_unique_id,
    ROUND(SUM(op.payment_value), 2) AS Monetary
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_payments op
    ON o.order_id = op.order_id
GROUP BY c.customer_unique_id
ORDER BY Monetary DESC;

-- ============================================================
-- GENERATE MONETARY SUMMARY STATISTICS
-- Calculate the minimum, maximum,
-- and average customer spending.
SELECT
    MIN(Monetary) AS Minimum_Monetary,
    MAX(Monetary) AS Maximum_Monetary,
    AVG(Monetary) AS Average_Monetary
FROM
(
    SELECT
        c.customer_unique_id,
        SUM(op.payment_value) AS Monetary
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_payments op
        ON o.order_id = op.order_id
    GROUP BY c.customer_unique_id
) AS monetary_summary;

-- ============================================================
-- IDENTIFY CUSTOMER COHORT MONTH USING WINDOW FUNCTION
-- Determine the first purchase month (cohort month)
-- for each customer using a window function.
SELECT
    c.customer_unique_id,
    o.order_id,

    DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    ) AS order_month,
    MIN(
        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        )
    ) OVER (
        PARTITION BY c.customer_unique_id
    ) AS cohort_month
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id;
    
-- ============================================================
-- CREATE COHORT ANALYSIS VIEW
-- Create a reusable view containing each customer's
-- cohort month, order month, and month number
-- for retention analysis.
CREATE OR REPLACE VIEW cohort_data AS
SELECT
    c.customer_unique_id,

    MIN(
        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        )
    ) OVER (
        PARTITION BY c.customer_unique_id
    ) AS cohort_month,

    DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    ) AS order_month,

    TIMESTAMPDIFF(
        MONTH,

        STR_TO_DATE(
            CONCAT(
                MIN(
                    DATE_FORMAT(
                        o.order_purchase_timestamp,
                        '%Y-%m'
                    )
                ) OVER (
                    PARTITION BY c.customer_unique_id
                ),
                '-01'
            ),
            '%Y-%m-%d'
        ),

        STR_TO_DATE(
            CONCAT(
                DATE_FORMAT(
                    o.order_purchase_timestamp,
                    '%Y-%m'
                ),
                '-01'
            ),
            '%Y-%m-%d'
        )

    ) AS month_number

FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id;

-- ============================================================
-- DISPLAY SAMPLE COHORT DATA
-- Display the first 20 records from the cohort_data
-- view to verify the cohort analysis structure.
SELECT *
FROM cohort_data
LIMIT 20;

-- ============================================================
-- CALCULATE MONTHLY CUSTOMER RETENTION
-- Count the number of retained customers
-- for each cohort month and month number.
SELECT
    cohort_month,
    month_number,
    COUNT(DISTINCT customer_unique_id) AS retained_customers
FROM cohort_data
GROUP BY
    cohort_month,
    month_number
ORDER BY
    cohort_month,
    month_number;

-- ============================================================
-- VALIDATE MONTHLY ORDER VOLUME
-- Count the total number of orders
-- placed each month.
SELECT
    DATE_FORMAT(
        order_purchase_timestamp,
        '%Y-%m'
    ) AS order_month,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY order_month
ORDER BY order_month;

-- ============================================================
-- DISPLAY SAMPLE COHORT DATA
-- Display sample records
-- from the cohort_data view.
SELECT *
FROM cohort_data
LIMIT 10;

-- ============================================================
-- CALCULATE COHORT RETENTION PERCENTAGE
-- Calculate the percentage of customers
-- retained for each cohort over time.
WITH cohort_counts AS (
    SELECT
        cohort_month,
        month_number,
        COUNT(DISTINCT customer_unique_id) AS retained_customers
    FROM cohort_data
    GROUP BY
        cohort_month,
        month_number
),
cohort_size AS (
    SELECT
        cohort_month,
        retained_customers AS cohort_customers
    FROM cohort_counts
    WHERE month_number = 0
)
SELECT
    cc.cohort_month,
    cc.month_number,
    cc.retained_customers,
    ROUND(
        cc.retained_customers * 100.0
        / cs.cohort_customers,
        2
    ) AS retention_percentage
FROM cohort_counts cc
JOIN cohort_size cs
ON cc.cohort_month = cs.cohort_month
ORDER BY
    cc.cohort_month,
    cc.month_number;
    
-- ============================================================
-- DISPLAY COHORT VIEW STRUCTURE
-- Display the schema of
-- the cohort_data view.
DESCRIBE cohort_data;
    
-- ============================================================
-- CALCULATE MONTHLY RETENTION PERCENTAGES
-- Calculate customer retention percentage
-- for each cohort month using cohort size
-- as the baseline.
WITH cohort_counts AS (
    SELECT
        cohort_month,
        month_number,
        COUNT(DISTINCT customer_unique_id) AS retained_customers
    FROM cohort_data
    GROUP BY
        cohort_month,
        month_number
),
cohort_size AS (
    SELECT
        cohort_month,
        retained_customers AS cohort_customers
    FROM cohort_counts
    WHERE month_number = 0
)
SELECT
    cc.cohort_month,
    cc.month_number,
    cc.retained_customers,
    ROUND(
        (cc.retained_customers * 100.0) /
        cs.cohort_customers,
        2
    ) AS retention_percentage
FROM cohort_counts cc
JOIN cohort_size cs
ON cc.cohort_month = cs.cohort_month
ORDER BY
    cc.cohort_month,
    cc.month_number;    

-- ============================================================
-- CREATE MONTHLY RETENTION COHORT VIEW
-- Create a reusable SQL view containing
-- monthly customer retention percentages.
CREATE OR REPLACE VIEW monthly_retention_cohorts AS
WITH cohort_counts AS (
    SELECT
        cohort_month,
        month_number,
        COUNT(DISTINCT customer_unique_id) AS retained_customers
    FROM cohort_data
    GROUP BY
        cohort_month,
        month_number

),
cohort_size AS (
    SELECT
        cohort_month,
        retained_customers AS cohort_customers
    FROM cohort_counts
    WHERE month_number = 0
)
SELECT
    cc.cohort_month,
    cc.month_number,
    cc.retained_customers,
    ROUND(
        (cc.retained_customers * 100.0) /
        cs.cohort_customers,
        2
    ) AS retention_percentage
FROM cohort_counts cc
JOIN cohort_size cs
ON cc.cohort_month = cs.cohort_month;

SELECT *
FROM monthly_retention_cohorts
LIMIT 20;

-- ============================================================
-- STORE MONTHLY RETENTION DATA IN GOLD LAYER TABLE
-- Store the finalized monthly retention results
-- in a Gold Layer table for reporting and analytics.

-- Remove the existing table if it already exists.
DROP TABLE IF EXISTS gold_layer;

-- Create the Gold Layer table from the
-- monthly retention cohort view.

CREATE TABLE gold_layer AS
SELECT *
FROM monthly_retention_cohorts;

-- ============================================================
-- VERIFY THE GOLD LAYER TABLE
-- Display sample records from the Gold Layer table.
SELECT *
FROM gold_layer_monthly_retention_cohorts
LIMIT 10;

-- ============================================================
-- EXTRACT PRODUCT CATEGORY INFORMATION
-- Join order items, products, and translation
-- tables to retrieve English product category names.
SELECT
    oi.order_id,
    oi.product_id,
    p.product_category_name,
    pct.product_category_name_english
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pct
ON p.product_category_name =
   pct.product_category_name
LIMIT 20;

-- ============================================================
-- INSPECT PRODUCT CATEGORY TRANSLATION TABLE
DESCRIBE product_category_name_translation;

-- ============================================================
-- CREATE MONTHLY RETENTION COHORTS VIEW
-- Create a reusable SQL view containing
-- monthly customer retention percentages.
CREATE OR REPLACE VIEW monthly_retention_cohorts AS
WITH cohort_counts AS (
    SELECT
        cohort_month,
        month_number,
        COUNT(DISTINCT customer_unique_id) AS retained_customers
    FROM cohort_data
    GROUP BY
        cohort_month,
        month_number
),
cohort_size AS (
    SELECT
        cohort_month,
        retained_customers AS cohort_customers
    FROM cohort_counts
    WHERE month_number = 0
)
SELECT
    cc.cohort_month,
    cc.month_number,
    cc.retained_customers,
    ROUND(
        (cc.retained_customers * 100.0) /
        cs.cohort_customers,
        2
    ) AS retention_percentage
FROM cohort_counts cc
JOIN cohort_size cs
ON cc.cohort_month = cs.cohort_month;

-- ============================================================
-- STORE RETENTION RESULTS IN GOLD LAYER TABLE
-- Remove the existing table if it already exists.
DROP TABLE IF EXISTS gold_layer_monthly_retention_cohorts;
-- Store the finalized monthly retention results
-- in a physical SQL table.
CREATE TABLE gold_layer_monthly_retention_cohorts AS
SELECT *
FROM monthly_retention_cohorts;

-- ============================================================
-- VERIFY GOLD LAYER TABLE
-- Display sample records from the Gold Layer table.
SELECT *
FROM gold_layer_monthly_retention_cohorts
LIMIT 10;

SELECT
    oi.order_id,
    oi.product_id,
    p.product_category_name,
    pct.product_category_name_english
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pct
    ON p.product_category_name = pct.product_category_name
LIMIT 20;

-- ============================================================
-- INSPECT PRODUCT CATEGORY TRANSLATION TABLE
-- Display the structure of the product category
-- translation table.
DESCRIBE product_category_name_translation;

-- ============================================================
-- PREVIEW PRODUCT CATEGORY INFORMATION
-- Join order items, products, and translation tables
-- to display product category names in English.
SELECT
    oi.order_id,
    oi.product_id,
    p.product_category_name,
    pct.product_category_name_english
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pct
    ON p.product_category_name = pct.product_category_name
LIMIT 20;

DESCRIBE product_category_name_translation;

-- ============================================================
-- CALCULATE TOTAL REVENUE BY PRODUCT CATEGORY
-- Calculate the total revenue generated
-- by each product category.
SELECT
    pct.product_category_name_english,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pct
    ON p.product_category_name = pct.product_category_name
GROUP BY pct.product_category_name_english
ORDER BY total_revenue DESC;

-- ============================================================
-- DISPLAY TOP 10 PRODUCT CATEGORIES BY REVENUE
-- Display the ten highest revenue-generating
-- product categories.
SELECT
    pct.product_category_name_english,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pct
    ON p.product_category_name = pct.product_category_name
GROUP BY pct.product_category_name_english
ORDER BY total_revenue DESC
LIMIT 10;

-- ============================================================
-- CALCULATE OVERALL SALES REVENUE
-- Calculate the total revenue generated
-- across all orders.
SELECT
    ROUND(SUM(price), 2) AS overall_revenue
FROM order_items;

-- ============================================================
-- IDENTIFY HIGH-VALUE PRODUCT CATEGORIES
-- Calculate revenue per unique customer
-- for each product category.
SELECT
    pct.product_category_name_english,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
    ROUND(
        SUM(oi.price) /
        COUNT(DISTINCT c.customer_unique_id),
        2
    ) AS revenue_per_customer
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pct
    ON p.product_category_name = pct.product_category_name
JOIN orders o
    ON oi.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY
    pct.product_category_name_english
ORDER BY
    revenue_per_customer DESC;
SELECT
    pct.product_category_name_english,
    ROUND(
        SUM(oi.price) /
        COUNT(DISTINCT c.customer_unique_id),
        2
    ) AS revenue_per_customer
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pct
    ON p.product_category_name = pct.product_category_name
JOIN orders o
    ON oi.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY pct.product_category_name_english
ORDER BY revenue_per_customer DESC
LIMIT 10;

-- ============================================================
-- CREATE RFM VIEW
-- Create a view containing Recency, Frequency,
-- and Monetary (RFM) metrics for every customer.
CREATE OR REPLACE VIEW rfm_view AS
SELECT
    c.customer_unique_id,
    DATEDIFF(
        (SELECT MAX(order_purchase_timestamp)
         FROM orders),
        MAX(o.order_purchase_timestamp)
    ) AS Recency,
    COUNT(DISTINCT o.order_id) AS Frequency,
    ROUND(SUM(op.payment_value), 2) AS Monetary
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_payments op
    ON o.order_id = op.order_id
GROUP BY
    c.customer_unique_id;
    
-- ============================================================
-- VERIFY RFM VIEW
-- Display sample records from the RFM view.
SELECT *
FROM rfm_view
LIMIT 10;    
CREATE OR REPLACE VIEW customer_segments AS
SELECT
    customer_unique_id,
    Monetary,
    CASE
        WHEN Monetary >= 1000 THEN 'High Value'
        WHEN Monetary >= 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM rfm_view;

-- ============================================================
-- CREATE CUSTOMER SEGMENTS
-- Categorize customers into High, Medium,
-- and Low Value segments based on Monetary value.
CREATE OR REPLACE VIEW customer_segments AS
SELECT
    customer_unique_id,
    Monetary,
    CASE
        WHEN Monetary >= 1000 THEN 'High Value'
        WHEN Monetary >= 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM rfm_view;

-- ============================================================
-- VERIFY CUSTOMER SEGMENTS
-- Display sample customer segments.
SELECT *
FROM customer_segments
LIMIT 10;

-- ============================================================
-- IDENTIFY HIGH-VALUE PRODUCT CATEGORIES
-- Calculate revenue and revenue per unique customer
-- for each product category.
SELECT
    pct.product_category_name_english,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
    ROUND(
        SUM(oi.price) /
        COUNT(DISTINCT c.customer_unique_id),
        2
    ) AS revenue_per_customer
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pct
    ON p.product_category_name = pct.product_category_name
JOIN orders o
    ON oi.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY
    pct.product_category_name_english
ORDER BY
    revenue_per_customer DESC;

-- ============================================================
-- TOP 10 HIGH-VALUE PRODUCT CATEGORIES
-- Display the top ten product categories
-- based on revenue per customer.
SELECT
    pct.product_category_name_english,
    ROUND(
        SUM(oi.price) /
        COUNT(DISTINCT c.customer_unique_id),
        2
    ) AS revenue_per_customer
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pct
    ON p.product_category_name = pct.product_category_name
JOIN orders o
    ON oi.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY
    pct.product_category_name_english
ORDER BY
    revenue_per_customer DESC
LIMIT 10;

-- ============================================================
-- CREATE RFM VIEW
-- Create a reusable view containing
-- Recency, Frequency, and Monetary values
-- for every customer.
CREATE OR REPLACE VIEW rfm_view AS
SELECT
    c.customer_unique_id,
    DATEDIFF(
        (SELECT MAX(order_purchase_timestamp)
         FROM orders),
        MAX(o.order_purchase_timestamp)
    ) AS Recency,
    COUNT(DISTINCT o.order_id) AS Frequency,
    ROUND(SUM(op.payment_value), 2) AS Monetary
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_payments op
    ON o.order_id = op.order_id
GROUP BY
    c.customer_unique_id;

-- ============================================================
-- VERIFY RFM VIEW
-- Display sample customer RFM values.
SELECT *
FROM rfm_view
LIMIT 10;

-- ============================================================
-- CREATE CUSTOMER SEGMENTS
-- Categorize customers into
-- High Value, Medium Value,
-- and Low Value segments.
CREATE OR REPLACE VIEW customer_segments AS
SELECT
    customer_unique_id,
    Monetary,
    CASE
        WHEN Monetary >= 1000 THEN 'High Value'
        WHEN Monetary >= 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM rfm_view;

-- ============================================================
-- VERIFY CUSTOMER SEGMENTS
SELECT *
FROM customer_segments
LIMIT 10;

-- ============================================================
-- CREATE AVERAGE ORDER VALUE (AOV) VIEW
-- Calculate the Average Order Value
-- for each customer segment.
CREATE OR REPLACE VIEW segment_aov AS
SELECT
    cs.customer_segment,
    ROUND(
        SUM(op.payment_value) /
        COUNT(DISTINCT o.order_id),
        2
    ) AS AOV
FROM customer_segments cs
JOIN customers c
    ON cs.customer_unique_id = c.customer_unique_id
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_payments op
    ON o.order_id = op.order_id
GROUP BY
    cs.customer_segment;

-- ============================================================
-- VERIFY AVERAGE ORDER VALUE VIEW
SELECT *
FROM segment_aov;

-- ============================================================
-- CALCULATE REPEAT PURCHASE RATIO
-- Calculate the percentage of customers
-- who placed more than one order.
SELECT
    ROUND(
        (
            COUNT(CASE WHEN order_count > 1 THEN 1 END)
            * 100.0 /
            COUNT(*)
        ),
        2
    ) AS Repeat_Purchase_Ratio
FROM
(
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) t;

-- ============================================================
-- CREATE CUSTOMER ANALYTICS VIEW
-- Create a consolidated customer analytics view
-- containing Recency, Frequency, and Monetary values.
-- This dataset will be exported for Python analytics.

CREATE OR REPLACE VIEW customer_analytics AS
SELECT
    c.customer_unique_id,
    DATEDIFF(
        (
            SELECT MAX(order_purchase_timestamp)
            FROM orders
        ),
        MAX(o.order_purchase_timestamp)
    ) AS Recency,
    COUNT(DISTINCT o.order_id) AS Frequency,
    ROUND(SUM(op.payment_value), 2) AS Monetary
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_payments op
    ON o.order_id = op.order_id
GROUP BY
    c.customer_unique_id;

-- ============================================================
-- VERIFY CUSTOMER ANALYTICS VIEW
SELECT *
FROM customer_analytics
LIMIT 20;

-- ============================================================
-- COUNT TOTAL CUSTOMERS
SELECT
    COUNT(*) AS Total_Customers
FROM customer_analytics;

SELECT *
FROM customer_analytics;


