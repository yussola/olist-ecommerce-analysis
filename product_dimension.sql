###----------------- Product Dimension ----------------###
USE olist;
CREATE OR REPLACE VIEW vw_dim_product AS
SELECT
    p.product_id,
    p.product_category_name,
    t.product_category_name_english,
    p.product_name_lenght,
    p.product_description_lenght,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM olist_products AS p
LEFT JOIN product_category_translation AS t
    ON p.product_category_name = t.`ï»¿product_category_name`;

SELECT *
FROM vw_dim_product
LIMIT 10;