--procedure begins by creating a temporary table that gathers the required data from the source systems and transforms 
--it into the format required for loading into the target tables. 
--For SCD Type 1 tables, the procedure first checks whether
--the temporary table contains records with the same source identifier triplet (source_system, source_entity, source_id) but
--different attribute values. If such records are found, the existing rows are updated. Afterward, any new records that do
--not already exist in the target table are inserted. 
CREATE OR REPLACE PROCEDURE bl_cl.load_ce_warehouses()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
BEGIN

	-- Gather data from source	--
	CREATE TEMP TABLE tmp_warehouses
	ON COMMIT DROP AS
	WITH src_online AS (
		SELECT 
		'sa_grocery_online_sales' AS src_system,
		'src_source1_online' AS src_entity
	)
		SELECT 
			COALESCE (bl_3nf.ce_cities.city_id,-1) AS city_id ,
			COALESCE (TRIM(LOWER(sa_grocery_online_sales.src_source1_online.warehouse_name)),'n.a.') AS src_name,
			COALESCE (sa_grocery_online_sales.src_source1_online.capacity::NUMERIC(7,2),-1) AS src_capacity,
			COALESCE (sa_grocery_online_sales.src_source1_online.operating_cost::INT,-1) AS src_o_cost,
			COALESCE (TRIM(LOWER(sa_grocery_online_sales.src_source1_online.manager_name)),'n.a.') AS src_m_name,
			COALESCE (sa_grocery_online_sales.src_source1_online.warehouse_load_factor::NUMERIC(7,6),-1) AS src_l_factor,
			src_online.src_system ,
			src_online.src_entity ,
			TRIM(LOWER(sa_grocery_online_sales.src_source1_online.warehouse_id)) AS src_id,
			current_timestamp ::TIMESTAMPTZ AS insert_dt,
			current_timestamp ::TIMESTAMPTZ AS update_dt,
			ROW_NUMBER() OVER (PARTITION BY TRIM(LOWER(sa_grocery_online_sales.src_source1_online.warehouse_id))
				ORDER BY sa_grocery_online_sales.src_source1_online.sales_dt::TIMESTAMPTZ DESC
			) AS rn
		FROM sa_grocery_online_sales.src_source1_online 
		CROSS JOIN src_online 
		LEFT JOIN bl_3nf.ce_cities ON bl_3nf.ce_cities.source_system =src_online.src_system AND 
			bl_3nf.ce_cities.source_entity =src_online.src_entity AND 
			bl_3nf.ce_cities.city_src_id = TRIM(LOWER(sa_grocery_online_sales.src_source1_online.warehouse_city_name)) 
		WHERE sa_grocery_online_sales.src_source1_online.warehouse_id IS NOT NULL AND 
			sa_grocery_online_sales.src_source1_online.sales_dt IS NOT NULL;

    -- UPDATE	--
	UPDATE bl_3nf.ce_warehouses
	SET 
		warehouse_city_id=tmp_warehouses.city_id,
		warehouse_name=tmp_warehouses.src_name,
		capacity=tmp_warehouses.src_capacity,
		operating_cost=tmp_warehouses.src_o_cost,
		manager_name=tmp_warehouses.src_m_name,
		warehouse_load_factor=tmp_warehouses.src_l_factor,
		ta_update_dt=current_timestamp ::TIMESTAMPTZ
	FROM tmp_warehouses
	WHERE tmp_warehouses.rn=1 AND 
					tmp_warehouses.src_system=bl_3nf.ce_warehouses.source_system AND 
					tmp_warehouses.src_entity=bl_3nf.ce_warehouses.source_entity AND 
					tmp_warehouses.src_id=bl_3nf.ce_warehouses.warehouse_src_id AND 
					(bl_3nf.ce_warehouses.warehouse_city_id <> tmp_warehouses.city_id OR 
					bl_3nf.ce_warehouses.warehouse_name<>tmp_warehouses.src_name OR 
					bl_3nf.ce_warehouses.capacity<>tmp_warehouses.src_capacity or
					bl_3nf.ce_warehouses.operating_cost<>tmp_warehouses.src_o_cost or
					bl_3nf.ce_warehouses.manager_name<>tmp_warehouses.src_m_name or
					bl_3nf.ce_warehouses.warehouse_load_factor<>tmp_warehouses.src_l_factor
					);


	GET DIAGNOSTICS log_updated = ROW_COUNT;

	-- INSERT 
	INSERT INTO bl_3nf.ce_warehouses (
		warehouse_id,
		warehouse_city_id,
		warehouse_name,
		capacity,
		operating_cost,
		manager_name,
		warehouse_load_factor,
		source_system,
		source_entity,
		warehouse_src_id,
		ta_insert_dt,
		ta_update_dt
	)
	SELECT NEXTVAL('bl_3nf.sqc_warehouses'),
		city_id,
		src_name,
		src_capacity,
		src_o_cost,
		src_m_name,
		src_l_factor,
		src_system,
		src_entity,
		src_id,
		insert_dt,
		update_dt
	FROM tmp_warehouses
	WHERE rn=1 AND 
		NOT EXISTS (
		SELECT 1
		FROM bl_3nf.ce_warehouses
		WHERE bl_3nf.ce_warehouses.source_system=src_system AND 
			bl_3nf.ce_warehouses.source_entity=src_entity AND
			bl_3nf.ce_warehouses.warehouse_src_id=src_id
			);

	GET DIAGNOSTICS log_inserted = ROW_COUNT;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_ce_warehouses',
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
		'load_ce_warehouses',
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