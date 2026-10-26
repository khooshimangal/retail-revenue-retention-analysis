SHOW VARIABLES LIKE 'local_infile';
-- 1. Monthly Transaction values
SELECT
    DATE_FORMAT(invoice_date, '%Y-%m') AS month,
    ROUND(SUM(quantity * price), 2) AS net_transaction_value,
    COUNT(*) AS transaction_lines
FROM retail_analysis.retail_transactions
GROUP BY DATE_FORMAT(invoice_date, '%Y-%m')
ORDER BY month;

-- 2. Top countries by net transaction value
SELECT
    country,
    ROUND(SUM(quantity * price), 2) AS net_transaction_value,
    COUNT(*) AS transaction_lines
FROM retail_analysis.retail_transactions
GROUP BY country
ORDER BY net_transaction_value DESC
LIMIT 10;

-- 3. Top merchandise products by net transaction value
SELECT
    stock_code,
    description,
    ROUND(SUM(quantity * price), 2) AS net_transaction_value,
    SUM(quantity) AS net_quantity,
    COUNT(*) AS transaction_lines
FROM retail_analysis.retail_transactions
WHERE description IS NOT NULL
  AND TRIM(description) <> ''
  AND UPPER(description) NOT LIKE '%POSTAGE%'
  AND stock_code NOT IN ('DOT', 'POST')
GROUP BY stock_code, description
ORDER BY net_transaction_value DESC
LIMIT 10;

-- 4. Cancellation-related transaction analysis
SELECT
    COUNT(*) AS cancellation_lines,
    COUNT(DISTINCT invoice) AS cancellation_invoices,
    ROUND(SUM(quantity * price), 2) AS cancellation_line_value
FROM retail_analysis.retail_transactions
WHERE invoice LIKE 'C%';

-- 5. Top customers by qulifying purchase value
SELECT Customer_ID,
COUNT(DISTINCT invoice) AS invoive_count,
ROUND(SUM(quantity * price), 2) AS purchase_value
FROM retail_analysis.retail_transactions
WHERE customer_id IS NOT NULL
AND invoice NOT LIKE "C%"
AND quantity > 0
AND price > 0
GROUP BY customer_id
ORDER BY purchase_value desc
LIMIT 10;

-- 6. Compare customer-level average order value
WITH invoice_values AS (
    SELECT
        customer_id,
        invoice,
        SUM(quantity * price) AS order_value
    FROM retail_analysis.retail_transactions
    WHERE customer_id IS NOT NULL
      AND invoice NOT LIKE 'C%'
      AND quantity > 0
      AND price > 0
    GROUP BY customer_id, invoice
),
customer_aov AS (
    SELECT
        customer_id,
        COUNT(*) AS invoice_count,
        AVG(order_value) AS average_order_value
    FROM invoice_values
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN invoice_count = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS customers,
    ROUND(AVG(average_order_value), 2) AS mean_customer_aov
FROM customer_aov
GROUP BY customer_type;














