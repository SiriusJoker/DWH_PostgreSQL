--procedure begins by creating a temporary table that gathers the required data from the source systems and transforms 
--it into the format required for loading into the target tables. 
--For SCD Type 1 tables, the procedure first checks whether
--the temporary table contains records with the same source identifier triplet (source_system, source_entity, source_id) but
--different attribute values. If such records are found, the existing rows are updated. Afterward, any new records that do
--not already exist in the target table are inserted. 

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_suppliers()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
BEGIN

	-- Gather data from source	--
	CREATE TEMP TABLE tmp_suppliers
	ON COMMIT DROP AS
	SELECT 
		COALESCE (TRIM(LOWER(sa_grocery_online_sales.src_source1_online.supplier_name)),'n.a.') AS s_name,
		COALESCE (sa_grocery_online_sales.src_source1_online.supplier_rating::SMALLINT,-1) AS s_rating,
		COALESCE (sa_grocery_online_sales.src_source1_online.contract_start_dt::TIMESTAMPTZ,'1900-01-01 00:00'::TIMESTAMPTZ) AS c_start_dt,
		'sa_grocery_online_sales' AS src_system,
		'src_source1_online' AS src_entity,
		TRIM(LOWER(sa_grocery_online_sales.src_source1_online.supplier_id)) AS src_id,
		ROW_NUMBER() OVER (PARTITION BY TRIM(LOWER(sa_grocery_online_sales.src_source1_online.supplier_id))
		ORDER BY sa_grocery_online_sales.src_source1_online.sales_dt::TIMESTAMPTZ DESC ) AS rn
	FROM sa_grocery_online_sales.src_source1_online 
	WHERE sa_grocery_online_sales.src_source1_online.supplier_id IS NOT NULL AND 
		sa_grocery_online_sales.src_source1_online.sales_dt IS NOT NULL;

    -- UPDATE	--
	UPDATE bl_3nf.ce_suppliers
	SET supplier_name = tmp_suppliers.s_name,
		supplier_rating = tmp_suppliers.s_rating,
		contract_start_dt = tmp_suppliers.c_start_dt,
		ta_update_dt=current_timestamp ::TIMESTAMPTZ
	FROM tmp_suppliers
	WHERE tmp_suppliers.rn=1 AND 
			tmp_suppliers.src_system=bl_3nf.ce_suppliers.source_system AND 
			tmp_suppliers.src_entity=bl_3nf.ce_suppliers.source_entity AND 
			tmp_suppliers.src_id=bl_3nf.ce_suppliers.supplier_src_id AND
				(bl_3nf.ce_suppliers.supplier_name <> tmp_suppliers.s_name OR 
				bl_3nf.ce_suppliers.supplier_rating <> tmp_suppliers.s_rating OR
				bl_3nf.ce_suppliers.contract_start_dt <> tmp_suppliers.c_start_dt
				);

	GET DIAGNOSTICS log_updated = ROW_COUNT;

	-- INSERT 
	INSERT INTO bl_3nf.ce_suppliers(
		supplier_id,
		supplier_name,
		supplier_rating,
		contract_start_dt,
		source_system,
		source_entity,
		supplier_src_id,
		ta_insert_dt,
		ta_update_dt
	)
	SELECT NEXTVAL('bl_3nf.sqc_suppliers'),
		s_name,
		s_rating,
		c_start_dt,
		src_system,
		src_entity,
		src_id,
		current_timestamp ::TIMESTAMPTZ,
		current_timestamp ::TIMESTAMPTZ
	FROM tmp_suppliers
	WHERE rn=1 AND 
		NOT EXISTS (
		SELECT 1 
		FROM bl_3nf.ce_suppliers
		WHERE bl_3nf.ce_suppliers.source_system =src_system AND 
			bl_3nf.ce_suppliers.source_entity =src_entity AND 
			bl_3nf.ce_suppliers.supplier_src_id =src_id
	);

	GET DIAGNOSTICS log_inserted = ROW_COUNT;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_ce_suppliers',
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
		'load_ce_suppliers',
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