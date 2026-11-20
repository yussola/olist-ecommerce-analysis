###-----Total Revenue by Month-----###
SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM olist_orders AS o
JOIN olist_order_item AS oi
    ON o.order_id = oi.order_id
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY month;

###---------- Top 10 Product Categories -------------###
SELECT
    COALESCE(
        t.product_category_name_english,
        p.product_category_name
    ) AS product_category,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM olist_order_item AS oi
JOIN olist_products AS p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation AS t
    ON p.product_category_name = t.`ï»¿product_category_name`
GROUP BY
    COALESCE(
        t.product_category_name_english,
        p.product_category_name
    )
ORDER BY total_revenue DESC
LIMIT 10;

###-------------- percentage of orders that were delivered ----------------###
SELECT
    COUNT(*) AS delivered_orders_with_dates,
    SUM(
        CASE
            WHEN order_delivered_customer_date >
                 order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS late_orders,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN order_delivered_customer_date >
                     order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS late_delivery_percentage
FROM olist_orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;
	
###------------------- Average Review Score ---------------------###
SELECT
    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On-time'
    END AS delivery_status,
    COUNT(*) AS total_reviews,
    ROUND(AVG(r.review_score), 2) AS average_review_score
FROM olist_orders AS o
JOIN olist_order_reviews_dataset AS r
    ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
  AND r.review_score IS NOT NULL
GROUP BY
    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On-time'
    END;

###-------------------- repeat purchase rate ------------------###
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM olist_orders AS o
    JOIN olist_customers AS c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)
        AS repeat_customers,
    ROUND(
        100.0 * SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS repeat_purchase_rate
FROM customer_orders;

###--------------- sellers with the highest late delivery rates ---------------###
WITH seller_order_status AS (
    SELECT DISTINCT
        oi.seller_id,
        o.order_id,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date
    FROM olist_order_item AS oi
    JOIN olist_orders AS o
        ON oi.order_id = o.order_id
),

seller_rates AS (
    SELECT
        seller_id,
        COUNT(*) AS total_orders,

        SUM(
            CASE
                WHEN order_delivered_customer_date IS NOT NULL
                 AND order_estimated_delivery_date IS NOT NULL
                THEN 1
                ELSE 0
            END
        ) AS orders_with_delivery_dates,

        SUM(
            CASE
                WHEN order_delivered_customer_date IS NOT NULL
                 AND order_estimated_delivery_date IS NOT NULL
                 AND order_delivered_customer_date >
                     order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ) AS late_orders,

        ROUND(
            100.0 * SUM(
                CASE
                    WHEN order_delivered_customer_date IS NOT NULL
                     AND order_estimated_delivery_date IS NOT NULL
                     AND order_delivered_customer_date >
                         order_estimated_delivery_date
                    THEN 1
                    ELSE 0
                END
            )
            / NULLIF(
                SUM(
                    CASE
                        WHEN order_delivered_customer_date IS NOT NULL
                         AND order_estimated_delivery_date IS NOT NULL
                        THEN 1
                        ELSE 0
                    END
                ),
                0
            ),
            2
        ) AS late_delivery_rate

    FROM seller_order_status
    GROUP BY seller_id
    HAVING COUNT(*) >= 30
       AND SUM(
            CASE
                WHEN order_delivered_customer_date IS NOT NULL
                 AND order_estimated_delivery_date IS NOT NULL
                THEN 1
                ELSE 0
            END
       ) > 0
),

ranked_sellers AS (
    SELECT
        seller_id,
        total_orders,
        orders_with_delivery_dates,
        late_orders,
        late_delivery_rate,
        RANK() OVER (
            ORDER BY late_delivery_rate DESC
        ) AS seller_rank
    FROM seller_rates
)

SELECT
    seller_rank,
    seller_id,
    total_orders,
    orders_with_delivery_dates,
    late_orders,
    late_delivery_rate
FROM ranked_sellers
ORDER BY seller_rank, seller_id;