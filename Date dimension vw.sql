###--------------------- Date Dimension --------------------###
CREATE OR REPLACE VIEW vw_dim_date AS
SELECT DISTINCT
    DATE(order_purchase_timestamp) AS date_key,
    YEAR(order_purchase_timestamp) AS year,
    QUARTER(order_purchase_timestamp) AS quarter,
    MONTH(order_purchase_timestamp) AS month,
    MONTHNAME(order_purchase_timestamp) AS month_name,
    DAY(order_purchase_timestamp) AS day
FROM olist_orders
WHERE order_purchase_timestamp IS NOT NULL;


SELECT *
FROM vw_dim_date
LIMIT 10;
