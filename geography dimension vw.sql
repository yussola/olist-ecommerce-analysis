###------------------ Geography Dimension -----------------###
CREATE OR REPLACE VIEW vw_dim_geography AS
SELECT DISTINCT
    customer_zip_code_prefix AS zip_code_prefix,
    customer_city AS city,
    customer_state AS state,
    'Customer' AS location_type
FROM olist_customers

UNION

SELECT DISTINCT
    seller_zip_code_prefix AS zip_code_prefix,
    seller_city AS city,
    seller_state AS state,
    'Seller' AS location_type
FROM olist_sellers;


SELECT *
FROM vw_dim_geography
LIMIT 10;
