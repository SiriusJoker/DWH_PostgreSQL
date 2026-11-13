--This queries check if tables have duplicates by source triplet

SELECT
	city_src_id,
	source_entity,
	source_system,
	COUNT(*) AS cnt
FROM bl_3nf.ce_cities
GROUP BY
	city_src_id,
	source_entity,
	source_system
HAVING COUNT(*) > 1;

SELECT
	customer_src_id,
	source_entity,
	source_system,
	COUNT(*) AS cnt
FROM bl_3nf.ce_customers 
GROUP BY
	customer_src_id,
	source_entity,
	source_system
HAVING COUNT(*) > 1;

SELECT
	product_src_id,
	source_entity,
	source_system,
	COUNT(*) AS cnt
FROM bl_3nf.ce_products_scd 
GROUP BY
	product_src_id,
	source_entity,
	source_system
HAVING COUNT(*) > 1;

SELECT
	sale_src_id,
	source_entity,
	source_system,
	COUNT(*) AS cnt
FROM bl_3nf.ce_sales
GROUP BY
	sale_src_id,
	source_entity,
	source_system
HAVING COUNT(*) > 1;

SELECT
	delivery_src_id,
	source_entity,
	source_system,
	COUNT(*) AS cnt
FROM bl_3nf.ce_deliveries
GROUP BY
	delivery_src_id,
	source_entity,
	source_system
HAVING COUNT(*) > 1;

SELECT
	product_src_id,
	source_entity,
	source_system,
	COUNT(*) AS cnt
FROM bl_dm.dim_products_scd dps 
GROUP BY
	product_src_id,
	source_entity,
	source_system
HAVING COUNT(*) > 1;

SELECT
	sale_src_id,
	source_entity,
	source_system,
	COUNT(*) AS cnt
FROM bl_dm.fact_sales_dd fsd 
GROUP BY
	sale_src_id,
	source_entity,
	source_system
HAVING COUNT(*) > 1;

SELECT
	delivery_src_id,
	source_entity,
	source_system,
	COUNT(*) AS cnt
FROM bl_dm.fact_deliveries_dd fsd 
GROUP BY
	delivery_src_id,
	source_entity,
	source_system
HAVING COUNT(*) > 1;