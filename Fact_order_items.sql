###--------------- Star Schema(SQL view) ------------------###
USE olist;
CREATE OR REPLACE VIEW vw_fact_order_items AS
SELECT
    oi.order_id,
    oi.order_item_id,
    o.customer_id,
    oi.product_id,
    oi.seller_id,
    o.order_purchase_timestamp,
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value) AS item_total_with_freight
FROM olist_order_item AS oi
JOIN olist_orders AS o
    ON oi.order_id = o.order_id;

SELECT *
FROM vw_fact_order_items
LIMIT 10;