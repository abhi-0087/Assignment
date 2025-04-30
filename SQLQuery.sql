-- 1. Order and Sales Analysis:

-- 1.1 Total number of orders
SELECT COUNT(*) AS total_orders
FROM customer_orders;

-- 1.2 Total sales (sum of order_amount)
SELECT SUM(order_amount) AS total_sales
FROM customer_orders;

-- 1.3 Orders by order_status
SELECT order_status, COUNT(*) AS order_count
FROM customer_orders
GROUP BY order_status;

-- 1.4 Revenue by order_status
SELECT order_status, SUM(order_amount) AS total_revenue
FROM customer_orders
GROUP BY order_status

-- 1.5 Monthly revenue trend
SELECT 
  FORMAT(order_date, 'yyyy-MM') AS order_month,
  COUNT(*) AS total_orders,
  SUM(order_amount) AS total_revenue
FROM customer_orders
GROUP BY FORMAT(order_date, 'yyyy-MM')
ORDER BY FORMAT(order_date, 'yyyy-MM');



--2. Customer Analysis:

-- 2.1 Total unique customers
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM customer_orders;

-- 2.2 Customers with multiple orders (repeat customers)
SELECT customer_id, COUNT(*) AS total_orders
FROM customer_orders
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY total_orders DESC;

-- 2.3 Count of repeat vs one-time customers
SELECT
  CASE
    WHEN order_stats.order_count = 1 THEN 'One-time Customer'
    ELSE 'Repeat Customer'
  END AS customer_type,
  COUNT(*) AS customer_count
FROM (
  SELECT customer_id, COUNT(*) AS order_count
  FROM customer_orders
  GROUP BY customer_id
) AS order_stats
GROUP BY
  CASE
    WHEN order_stats.order_count = 1 THEN 'One-time Customer'
    ELSE 'Repeat Customer'
  END;

-- 2.4 Monthly active customers
SELECT
  FORMAT(order_date, 'yyyy-MM') AS order_month,
  COUNT(DISTINCT customer_id) AS active_customers
FROM customer_orders
GROUP BY FORMAT(order_date, 'yyyy-MM')
ORDER BY order_month;

-- 2.5 Segmentation: Number of customers by order frequency
SELECT total_orders AS order_count, COUNT(*) AS customer_count
FROM (
  SELECT customer_id, COUNT(*) AS total_orders
  FROM customer_orders
  GROUP BY customer_id
) AS order_stats
GROUP BY total_orders
ORDER BY order_count;


--3. Payment Status Analysis:

-- 3.1 Total payments by status (e.g., completed, failed)
SELECT payment_status, COUNT(*) AS total_payments
FROM payments
GROUP BY payment_status;

-- 3.2 Failure rate (% of failed payments)
SELECT 
  CAST(SUM(CASE WHEN payment_status = 'failed' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) * 100 AS failure_rate_percentage
FROM payments;

-- 3.3 Monthly payment trend (total and failed)
SELECT 
  payment_month,
  COUNT(*) AS total_payments,
  SUM(CASE WHEN payment_status = 'failed' THEN 1 ELSE 0 END) AS failed_payments
FROM (
  SELECT 
    FORMAT(payment_date, 'yyyy-MM') AS payment_month,
    payment_status
  FROM payments
) AS formatted_payments
GROUP BY payment_month
ORDER BY payment_month;


-- 3.4 Payments by method and status
SELECT 
  payment_method,
  payment_status,
  COUNT(*) AS payment_count
FROM payments
GROUP BY payment_method, payment_status
ORDER BY payment_method, payment_status;


--4. Order Details Report:

SELECT 
  o.order_id,
  o.customer_id,
  o.order_date,
  o.order_amount,
  o.order_status,
  p.payment_id,
  p.payment_date,
  p.payment_amount,
  p.payment_method,
  p.payment_status
FROM customer_orders o
LEFT JOIN payments p
  ON o.order_id = p.order_id
ORDER BY o.order_date;
