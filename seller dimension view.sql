###------------------- Seller Dimension -----------------###
CREATE OR REPLACE VIEW vw_dim_seller AS
SELECT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM olist_sellers;

SELECT *
FROM vw_dim_seller
LIMIT 10;
