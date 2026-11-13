-- procedure for loading bridge table warehouses_products uses insert scdtype0:
CREATE OR REPLACE PROCEDURE bl_cl.load_bridge_warehouses_products()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
BEGIN

	-- Gather data from source	--
	CREATE TEMP TABLE tmp_bridge_warehouses_products
	ON COMMIT DROP AS
	SELECT 
	bl_dm.dim_warehouses.warehouse_surr_id AS src_war_id,
	bl_dm.dim_products_scd.product_surr_id AS src_pr_id,
	'bl_3nf' AS src_system,
	'warehouses_products' AS src_entity,
	bl_dm.dim_products_scd.product_src_id ||'|'||bl_dm.dim_warehouses.warehouse_src_id AS src_id
	FROM bl_3nf.warehouses_products
	INNER JOIN bl_dm.dim_warehouses ON bl_dm.dim_warehouses.warehouse_src_id = bl_3nf.warehouses_products.warehouse_id::varchar(1000)
	INNER JOIN bl_dm.dim_products_scd ON 
	bl_dm.dim_products_scd.product_src_id = bl_3nf.warehouses_products.product_id::varchar(1000)
	WHERE bl_dm.dim_warehouses.warehouse_surr_id <> -1 AND 
		bl_dm.dim_products_scd.is_active='y';

	-- INSERT 

	INSERT INTO bl_dm.bridge_warehouses_products 
	(
		product_surr_id,
		warehouse_surr_id,
		source_system ,
		source_entity ,
		warehouse_product_src_id ,
		ta_insert_dt ,
		ta_update_dt 
	)
	SELECT
	src_pr_id, 
	src_war_id,
	src_system,
	src_entity,
	src_id,
	current_timestamp ::TIMESTAMPTZ,
	current_timestamp ::TIMESTAMPTZ
	FROM tmp_bridge_warehouses_products
	ON CONFLICT DO NOTHING;

	GET DIAGNOSTICS log_inserted = ROW_COUNT;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_bridge_warehouses_products',
		log_updated + log_inserted,
		log_updated,
		log_inserted,
		'SUCCESS',
		NULL,
		log_start_time,
		log_end_time
    );

EXCEPTION
WHEN OTHERS THEN

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_bridge_warehouses_products',
		log_updated + log_inserted,
		log_updated,
		log_inserted,
		'FAILED',
		SQLERRM,
		log_start_time,
		log_end_time
    );

END;
$$;