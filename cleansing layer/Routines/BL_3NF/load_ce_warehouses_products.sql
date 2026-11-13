--procedure begins by creating a temporary table that gathers the required data from the source systems and transforms 
--it into the format required for loading into the target tables. 
-- SCD Type 0 tables do not require update logic, as their data remains unchanged

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_warehouses_products()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
BEGIN

	-- Gather data from source	--
	CREATE TEMP TABLE tmp_warehouses_products
	ON COMMIT DROP AS
	WITH source_online AS (
	SELECT 
		'sa_grocery_online_sales' AS src_system,
		'src_source1_online' AS src_entity
	)
	SELECT 
		bl_3nf.ce_products_scd.product_id,
		bl_3nf.ce_products_scd.start_dt,
		bl_3nf.ce_warehouses.warehouse_id,
		source_online.src_system,
		source_online.src_entity,
		bl_3nf.ce_products_scd.product_src_id||'|'||bl_3nf.ce_warehouses.warehouse_src_id AS src_id
	FROM sa_grocery_online_sales.src_source1_online  
	CROSS JOIN source_online
	LEFT JOIN bl_3nf.ce_products_scd ON bl_3nf.ce_products_scd.source_system =source_online.src_system AND 
		bl_3nf.ce_products_scd.source_entity =source_online.src_entity AND 
		bl_3nf.ce_products_scd.product_src_id=sa_grocery_online_sales.src_source1_online.product_id AND
		bl_3nf.ce_products_scd.is_active='y'
	LEFT JOIN bl_3nf.ce_warehouses ON bl_3nf.ce_warehouses.source_system =source_online.src_system AND 
		bl_3nf.ce_warehouses.source_entity =source_online.src_entity AND 
		bl_3nf.ce_warehouses.warehouse_src_id=sa_grocery_online_sales.src_source1_online.warehouse_id ;

	-- INSERT 
	INSERT INTO bl_3nf.warehouses_products
	SELECT 
		product_id,
		start_dt,
		warehouse_id,
		src_system,
		src_entity,
		src_id,
		current_timestamp ::TIMESTAMPTZ,
		current_timestamp ::TIMESTAMPTZ
	FROM tmp_warehouses_products
	ON CONFLICT DO NOTHING;

	GET DIAGNOSTICS log_inserted = ROW_COUNT;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_ce_warehouses_products',
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
		'load_ce_warehouses_products',
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