-- This script contains procedures of initial load of fact delivery table in bl_dm

CREATE OR REPLACE PROCEDURE bl_cl.load_fact_deliveries()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
BEGIN

	-- Gather data from source	--
	CREATE TEMP TABLE tmp_fact_deliveries
	ON COMMIT DROP AS
	SELECT 
		to_char(bl_3nf.ce_deliveries.delivery_dt::date,'YYYYMMDD')::bigint AS src_time_id,
		bl_3nf.ce_deliveries.delivery_cost AS src_cost,
		bl_3nf.ce_deliveries.delivery_dt AS src_dt,
		COALESCE(bl_dm.dim_addresses.address_surr_id,-1) AS src_add,
		'bl_3nf' AS src_system,
		'ce_deliveries' AS src_entity,
		bl_3nf.ce_deliveries.delivery_id::varchar(1000) AS src_id
	FROM bl_3nf.ce_deliveries
	LEFT JOIN bl_dm.dim_addresses ON bl_3nf.ce_deliveries.delivery_address_id::varchar(1000)= bl_dm.dim_addresses.address_src_id 
	WHERE bl_3nf.ce_deliveries.delivery_id <> -1;

	-- INSERT 

	INSERT INTO bl_dm.fact_deliveries_dd
	(
		time_surr_id,
		delivery_cost,
		delivery_dt ,
		delivery_address_surr_id ,
		source_system ,
		source_entity ,
		delivery_src_id,
		ta_insert_dt ,
		ta_update_dt
	)
	SELECT 
		src_time_id,
		src_cost,
		src_dt,
		src_add	,
		src_system,
		src_entity,
		src_id,
		current_timestamp ::TIMESTAMPTZ,
		current_timestamp ::TIMESTAMPTZ
	FROM tmp_fact_deliveries 
	WHERE NOT EXISTS (
		SELECT 1 
		FROM bl_dm.fact_deliveries_dd
		WHERE source_system=src_system AND 
		source_entity=src_entity AND 
		delivery_src_id = src_id
	);

	GET DIAGNOSTICS log_inserted = ROW_COUNT;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_fact_deliveries',
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
		'load_fact_deliveries',
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