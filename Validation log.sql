SELECT
    COUNT(DISTINCT order_id) AS Total_Orders
FROM vw_fact_order_items;

SELECT
    ROUND(SUM(price), 2) AS Total_Revenue
FROM vw_fact_order_items;

SELECT
    ROUND(
        SUM(price) / COUNT(DISTINCT order_id),
        2
    ) AS Average_Order_Value
FROM vw_fact_order_items;

SELECT
    ROUND(AVG(review_score), 2) AS Average_Review_Score
FROM olist_order_reviews_dataset;