###------------------ Order-level view -------------------###
CREATE OR REPLACE VIEW vw_fact_orders AS
SELECT
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date
FROM olist_orders AS o
JOIN olist_customers AS c
    ON o.customer_id = c.customer_id;