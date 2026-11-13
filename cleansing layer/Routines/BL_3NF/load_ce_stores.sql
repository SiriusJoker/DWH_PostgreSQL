--Each procedure begins by creating a temporary table that gathers the required data from the source systems and transforms 
--it into the format required for loading into the target tables. 
-- SCD Type 0 tables do not require update logic, as their data remains 
--unchanged after the initial load.

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_stores()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
BEGIN

	-- Gather data from source	--
	CREATE TEMP TABLE tmp_stores
	ON COMMIT DROP AS
	WITH source_offline AS (
	SELECT 
		'sa_grocery_instore_sales' AS src_system,
		'src_source2_offline' AS src_entity
	)
		SELECT 
			COALESCE (bl_3nf.ce_cities.city_id,-1) AS src_city_id,
			source_offline.src_system ,
			source_offline.src_entity ,
			TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.store_id)) AS src_code,
			TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.store_id)) AS src_id,
			ROW_NUMBER()OVER(PARTITION BY TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.store_id))
				ORDER BY sa_grocery_instore_sales.src_source2_offline.sales_dt::TIMESTAMPTZ DESC 
			) AS rn
		FROM sa_grocery_instore_sales.src_source2_offline
		CROSS JOIN source_offline
		LEFT JOIN bl_3nf.ce_cities ON bl_3nf.ce_cities.source_system = src_system AND 
			bl_3nf.ce_cities.source_entity =src_entity AND
			bl_3nf.ce_cities.city_src_id = TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.sales_city_id))
		WHERE sa_grocery_instore_sales.src_source2_offline.store_id IS NOT NULL AND
			sa_grocery_instore_sales.src_source2_offline.sales_dt IS NOT NULL
		;

	-- INSERT 
	INSERT INTO bl_3nf.ce_stores
	SELECT 
		NEXTVAL('bl_3nf.sqc_stores'),
		src_city_id,
		src_code,
		src_system ,
		src_entity ,
		src_id,
		current_timestamp ::TIMESTAMPTZ,
		current_timestamp ::TIMESTAMPTZ
	FROM tmp_stores
	WHERE rn=1 AND 
		NOT EXISTS (
			SELECT 1
			FROM bl_3nf.ce_stores
			WHERE bl_3nf.ce_stores.source_system =src_system AND 
				bl_3nf.ce_stores.source_entity =src_entity AND 
				bl_3nf.ce_stores.store_src_id =src_id
		);

	GET DIAGNOSTICS log_inserted = ROW_COUNT;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_ce_stores',
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
		'load_ce_stores',
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