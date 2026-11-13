-- procedure for loading dimension table suppliers uses update + insert:

CREATE OR REPLACE PROCEDURE bl_cl.load_dim_suppliers()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
BEGIN

	-- Gather data from source	--
	CREATE TEMP TABLE tmp_dim_suppliers
	ON COMMIT DROP AS
	SELECT bl_3nf.ce_suppliers.supplier_name AS src_name,
	bl_3nf.ce_suppliers.supplier_rating AS src_rating,
	bl_3nf.ce_suppliers.contract_start_dt AS src_start,
	'bl_3nf' AS src_system,
	'ce_suppliers' AS src_entity,
	bl_3nf.ce_suppliers.supplier_id::varchar(1000) AS src_id
	FROM bl_3nf.ce_suppliers
	WHERE bl_3nf.ce_suppliers.supplier_id <> -1;

    -- UPDATE	--

	UPDATE bl_dm.dim_suppliers
	SET supplier_name =	tmp_dim_suppliers.src_name,
		supplier_rating = tmp_dim_suppliers.src_rating ,
		contract_start_dt =	tmp_dim_suppliers.src_start ,
		ta_update_dt = current_timestamp ::TIMESTAMPTZ
	FROM tmp_dim_suppliers
	WHERE tmp_dim_suppliers.src_system = bl_dm.dim_suppliers.source_system AND 
		tmp_dim_suppliers.src_entity = bl_dm.dim_suppliers.source_entity AND 
		tmp_dim_suppliers.src_id = bl_dm.dim_suppliers.supplier_src_id AND 
		(
			tmp_dim_suppliers.src_name  <> bl_dm.dim_suppliers.supplier_name OR 
			tmp_dim_suppliers.src_rating <> bl_dm.dim_suppliers.supplier_rating OR 
			tmp_dim_suppliers.src_start <> bl_dm.dim_suppliers.contract_start_dt
		);

	GET DIAGNOSTICS log_updated = ROW_COUNT;

	-- INSERT 

	INSERT INTO bl_dm.dim_suppliers 
	(
		supplier_name,
		supplier_rating,
		contract_start_dt,
		source_system,
		source_entity ,
		supplier_src_id,
		ta_insert_dt ,
		ta_update_dt 
	)
	SELECT src_name,
		src_rating,
		src_start,
		src_system,
		src_entity,
		src_id,
		current_timestamp ::TIMESTAMPTZ,
		current_timestamp ::TIMESTAMPTZ
	FROM tmp_dim_suppliers
	WHERE NOT EXISTS (
		SELECT 1
		FROM bl_dm.dim_suppliers 
		WHERE tmp_dim_suppliers.src_system = bl_dm.dim_suppliers.source_system  AND 
		tmp_dim_suppliers.src_entity = bl_dm.dim_suppliers.source_entity AND 
		tmp_dim_suppliers.src_id = bl_dm.dim_suppliers.supplier_src_id
	);        

	GET DIAGNOSTICS log_inserted = ROW_COUNT;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_dim_suppliers',
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
		'load_dim_suppliers',
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