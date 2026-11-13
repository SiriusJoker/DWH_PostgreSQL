-- all records from SA layer are represented in the business layer.
-- Check is there records in source that are not present in loaded tables
-- offline source and bl_3nf sales
SELECT sa_grocery_instore_sales.src_source2_offline.sales_id 
FROM sa_grocery_instore_sales.src_source2_offline 
LEFT JOIN bl_3nf.ce_sales ON source_system='sa_grocery_instore_sales' AND 
	source_entity='src_source2_offline' AND 
	sale_src_id =sales_id 
WHERE bl_3nf.ce_sales.sale_id IS NULL ;

-- online source and bl_3nf sales
SELECT sa_grocery_online_sales.src_source1_online.sales_id
FROM sa_grocery_online_sales.src_source1_online
LEFT JOIN bl_3nf.ce_sales ON source_system='sa_grocery_online_sales' AND 
	source_entity='src_source1_online' AND 
	sale_src_id =sales_id 
WHERE bl_3nf.ce_sales.sale_id IS NULL ;
-- online source and bl_3nf deliveries
SELECT TRIM(LOWER(sa_grocery_online_sales.src_source1_online.delivery_address)) ||'|'||
			(sa_grocery_online_sales.src_source1_online.shipping_cost::numeric(11,6))::varchar(1000) ||'|'||
			(sa_grocery_online_sales.src_source1_online.delivery_date::timestamptz)::varchar(1000) AS delivery_src_id
FROM sa_grocery_online_sales.src_source1_online
LEFT JOIN bl_3nf.ce_deliveries ON source_system='sa_grocery_online_sales' AND 
	source_entity='src_source1_online' AND 
	delivery_src_id =TRIM(LOWER(sa_grocery_online_sales.src_source1_online.delivery_address)) ||'|'||
			(sa_grocery_online_sales.src_source1_online.shipping_cost::numeric(11,6))::varchar(1000) ||'|'||
			(sa_grocery_online_sales.src_source1_online.delivery_date::timestamptz)::varchar(1000) 
WHERE bl_3nf.ce_deliveries.delivery_id IS NULL ;
--bl_3nf and bl_dm sales 
SELECT *
FROM bl_3nf.ce_sales
LEFT JOIN bl_dm.fact_sales_dd ON bl_3nf.ce_sales.sale_id::varchar(1000)=bl_dm.fact_sales_dd.sale_src_id 
WHERE bl_dm.fact_sales_dd.sale_src_id IS NULL;
--bl_3nf and bl_dm deliveries
SELECT * 
FROM bl_3nf.ce_deliveries 
LEFT JOIN bl_dm.fact_deliveries_dd ON bl_3nf.ce_deliveries.delivery_id::varchar(1000)=bl_dm.fact_deliveries_dd.delivery_src_id 
WHERE bl_dm.fact_deliveries_dd.delivery_src_id IS NULL ;

-- check connection with natural key
-- offline and bl_3nf stores
SELECT bl_3nf.ce_stores.store_code,
	sa_grocery_instore_sales.src_source2_offline.store_id
FROM sa_grocery_instore_sales.src_source2_offline 
LEFT JOIN bl_3nf.ce_stores ON sa_grocery_instore_sales.src_source2_offline.store_id =bl_3nf.ce_stores.store_code ;
--check if there is store in source that is not in bl_3nf store:
SELECT *
FROM sa_grocery_instore_sales.src_source2_offline 
LEFT JOIN bl_3nf.ce_stores ON sa_grocery_instore_sales.src_source2_offline.store_id =bl_3nf.ce_stores.store_code 
WHERE bl_3nf.ce_stores.store_code IS NULL ;

-- check connection with natural key
-- offline and bl_dm stores
SELECT bl_dm.dim_stores.store_code,
	sa_grocery_instore_sales.src_source2_offline.store_id
FROM sa_grocery_instore_sales.src_source2_offline 
LEFT JOIN bl_dm.dim_stores ON sa_grocery_instore_sales.src_source2_offline.store_id =bl_dm.dim_stores.store_code ;
--check if there is store in source that is not in bl_dm store:
SELECT *
FROM sa_grocery_instore_sales.src_source2_offline 
LEFT JOIN bl_dm.dim_stores ON sa_grocery_instore_sales.src_source2_offline.store_id =bl_dm.dim_stores.store_code 
WHERE bl_dm.dim_stores.store_code IS NULL ;

--offline and bl_3nf products
SELECT bl_3nf.ce_products_scd.product_code,
	sa_grocery_instore_sales.src_source2_offline.product_id
FROM sa_grocery_instore_sales.src_source2_offline 
LEFT JOIN bl_3nf.ce_products_scd ON bl_3nf.ce_products_scd.product_code =sa_grocery_instore_sales.src_source2_offline.product_id 
	AND source_system ='sa_grocery_instore_sales'
	AND source_entity='src_source2_offline';

SELECT bl_3nf.ce_products_scd.product_code,
	sa_grocery_instore_sales.src_source2_offline.product_id
FROM sa_grocery_instore_sales.src_source2_offline 
LEFT JOIN bl_3nf.ce_products_scd ON bl_3nf.ce_products_scd.product_code =sa_grocery_instore_sales.src_source2_offline.product_id 
	AND source_system ='sa_grocery_instore_sales'
	AND source_entity='src_source2_offline'
WHERE bl_3nf.ce_products_scd.product_code IS NULL;

--online and bl_3nf products
SELECT sa_grocery_online_sales.src_source1_online.product_id ,
bl_3nf.ce_products_scd.product_code 
FROM sa_grocery_online_sales.src_source1_online
LEFT JOIN bl_3nf.ce_products_scd ON sa_grocery_online_sales.src_source1_online.product_id = bl_3nf.ce_products_scd.product_code 
	AND source_system ='sa_grocery_online_sales'
	AND source_entity='src_source1_online';

SELECT sa_grocery_online_sales.src_source1_online.product_id ,
bl_3nf.ce_products_scd.product_code 
FROM sa_grocery_online_sales.src_source1_online
LEFT JOIN bl_3nf.ce_products_scd ON sa_grocery_online_sales.src_source1_online.product_id = bl_3nf.ce_products_scd.product_code 
	AND source_system ='sa_grocery_online_sales'
	AND source_entity='src_source1_online'
WHERE bl_3nf.ce_products_scd.product_code IS NULL;

--offline and bl_dm products

SELECT bl_dm.dim_products_scd.product_code,
	sa_grocery_instore_sales.src_source2_offline.product_id
FROM sa_grocery_instore_sales.src_source2_offline 
LEFT JOIN bl_dm.dim_products_scd ON bl_dm.dim_products_scd.product_code = sa_grocery_instore_sales.src_source2_offline.product_id;

SELECT bl_dm.dim_products_scd.product_code,
	sa_grocery_instore_sales.src_source2_offline.product_id
FROM sa_grocery_instore_sales.src_source2_offline 
LEFT JOIN bl_dm.dim_products_scd ON bl_dm.dim_products_scd.product_code = sa_grocery_instore_sales.src_source2_offline.product_id
WHERE bl_dm.dim_products_scd.product_code IS NULL ;

--online and bl_dm products

SELECT sa_grocery_online_sales.src_source1_online.product_id ,
bl_dm.dim_products_scd.product_code 
FROM sa_grocery_online_sales.src_source1_online
LEFT JOIN bl_dm.dim_products_scd ON bl_dm.dim_products_scd.product_code = sa_grocery_online_sales.src_source1_online.product_id;

SELECT sa_grocery_online_sales.src_source1_online.product_id ,
bl_dm.dim_products_scd.product_code 
FROM sa_grocery_online_sales.src_source1_online
LEFT JOIN bl_dm.dim_products_scd ON bl_dm.dim_products_scd.product_code = sa_grocery_online_sales.src_source1_online.product_id
WHERE bl_dm.dim_products_scd.product_code IS NULL ;