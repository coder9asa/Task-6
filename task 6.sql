SELECT 
  STRFTIME('%Y-%m', field2) AS month,
  SUM(field7) AS total_revenue,
  COUNT(DISTINCT field1) AS order_volume
FROM "Online Sales Data"
GROUP BY month
ORDER BY month;

SELECT 
  STRFTIME('%Y', field2) AS year,
  SUM(field7) AS total_revenue,
  COUNT(DISTINCT field1) AS total_orders
FROM "Online Sales Data"
GROUP BY year
ORDER BY year;

SELECT 
  field3 AS category,
  SUM(field7) AS revenue,
  COUNT(DISTINCT field1) AS orders
FROM "Online Sales Data"
GROUP BY field3
ORDER BY revenue DESC;

SELECT 
  STRFTIME('%Y', field2) AS year,
  SUM(field7) AS jan_revenue
FROM "Online Sales Data"
WHERE STRFTIME('%m', field2) = '01'
GROUP BY year
ORDER BY year;

SELECT 
  field4 AS product,
  SUM(field7) AS revenue
FROM "Online Sales Data"
GROUP BY field4
ORDER BY revenue DESC
LIMIT 5;

SELECT 
  STRFTIME('%Y-%m', field2) AS month,
  SUM(field7) / COUNT(DISTINCT field1) AS avg_order_value
FROM "Online Sales Data"
GROUP BY month
ORDER BY month;

SELECT 
  field8 AS region,
  SUM(field7) AS total_revenue
FROM "Online Sales Data"
GROUP BY field8
ORDER BY total_revenue DESC;

SELECT 
  field9 AS payment_method,
  COUNT(*) AS total_transactions
FROM "Online Sales Data"
GROUP BY field9
ORDER BY total_transactions DESC;

SELECT 
  field4 AS product,
  SUM(field5) AS total_units_sold
FROM "Online Sales Data"
GROUP BY field4
ORDER BY total_units_sold DESC
LIMIT 1;

SELECT 
  field2 AS date,
  SUM(field7) AS revenue
FROM "Online Sales Data"
GROUP BY field2
ORDER BY revenue DESC
LIMIT 7;

SELECT 
  STRFTIME('%Y-%m', field2) AS month,
  SUM(field5) AS units_sold
FROM "Online Sales Data"
GROUP BY month
ORDER BY month;

SELECT 
  field1 AS transaction_id,
  field7 AS revenue
FROM "Online Sales Data"
ORDER BY revenue DESC
LIMIT 2;

SELECT 
  field8 AS region,
  COUNT(field1) AS order_count
FROM "Online Sales Data"
WHERE STRFTIME('%Y-%m', field2) = '2024-01'
GROUP BY region
ORDER BY order_count DESC
LIMIT 4;

SELECT 
  STRFTIME('%Y-%m', field2) AS month,
  field3 AS category,
  SUM(field7) AS revenue
FROM "Online Sales Data"
GROUP BY month, category
ORDER BY month, revenue DESC;

SELECT 
  STRFTIME('%Y-%m', field2) AS month,
  SUM(field7) AS electronics_revenue
FROM "Online Sales Data"
WHERE field3 = 'Electronics'
GROUP BY month
ORDER BY month;

WITH monthly_revenue AS (
  SELECT 
    STRFTIME('%Y-%m', field2) AS month,
    SUM(field7) AS revenue
  FROM "Online Sales Data"
  GROUP BY month
),
moving_avg AS (
  SELECT 
    m1.month,
    ROUND(AVG(m2.revenue), 2) AS moving_avg_revenue
  FROM monthly_revenue m1
  JOIN monthly_revenue m2
    ON m2.month <= m1.month
  GROUP BY m1.month
  HAVING COUNT(*) <= 3
)
SELECT * FROM moving_avg;

WITH monthly AS (
  SELECT 
    STRFTIME('%Y-%m', field2) AS month,
    SUM(field7) AS revenue
  FROM "Online Sales Data"
  GROUP BY month
),
growth AS (
  SELECT 
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue
  FROM monthly
)
SELECT 
  month,
  revenue,
  prev_month_revenue,
  ROUND(((revenue - prev_month_revenue) * 100.0) / prev_month_revenue, 2) AS growth_percent
FROM growth
WHERE prev_month_revenue IS NOT NULL;

WITH monthly AS (
  SELECT 
    STRFTIME('%Y-%m', field2) AS month,
    SUM(field7) AS revenue
  FROM "Online Sales Data"
  GROUP BY month
)
SELECT 
  month,
  revenue,
  SUM(revenue) OVER (ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM monthly;

WITH monthly AS (
  SELECT 
    STRFTIME('%Y-%m', field2) AS month,
    SUM(field7) AS revenue
  FROM "Online Sales Data"
  GROUP BY month
),
avg_rev AS (
  SELECT AVG(revenue) AS avg_revenue FROM monthly
)
SELECT 
  m.month,
  m.revenue,
  ROUND((m.revenue - a.avg_revenue) * 100.0 / a.avg_revenue, 2) AS spike_percent
FROM monthly m, avg_rev a
WHERE m.revenue > 1.5 * a.avg_revenue;

WITH monthly_product AS (
  SELECT 
    STRFTIME('%Y-%m', field2) AS month,
    field4 AS product,
    SUM(field7) AS revenue
  FROM "Online Sales Data"
  GROUP BY month, product
),
with_lag AS (
  SELECT 
    month,
    product,
    revenue,
    LAG(revenue) OVER (PARTITION BY product ORDER BY month) AS prev_revenue
  FROM monthly_product
)
SELECT 
  month,
  product,
  revenue,
  prev_revenue,
  ROUND(((revenue - prev_revenue) * 100.0) / prev_revenue, 2) AS growth_percent
FROM with_lag
WHERE prev_revenue IS NOT NULL AND growth_percent > 0
ORDER BY growth_percent DESC
LIMIT 10;



