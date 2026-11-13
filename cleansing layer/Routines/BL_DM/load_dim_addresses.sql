-- procedure for loading dimension table addresses uses insert and update:
CREATE OR REPLACE PROCEDURE bl_cl.load_dim_addresses()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
BEGIN

	-- Gather data from source	--
	CREATE TEMP TABLE tmp_dim_addresses 
	ON COMMIT DROP AS
		SELECT bl_3nf.ce_addresses.address AS src_address,
			bl_3nf.ce_cities.city_id AS city_id,
			bl_3nf.ce_cities.city_name AS city_name,	
			bl_3nf.ce_cities.zipcode AS zipcode,
			'bl_3nf' AS src_system,
			'ce_addresses' AS src_entity,
			bl_3nf.ce_addresses.address_id::varchar(1000) AS src_id
		FROM bl_3nf.ce_addresses  
		INNER JOIN bl_3nf.ce_cities ON bl_3nf.ce_addresses.city_id =bl_3nf.ce_cities.city_id
		WHERE bl_3nf.ce_addresses.address_id<>-1;


    -- UPDATE	--

		UPDATE bl_dm.dim_addresses
		SET
			address = tmp_dim_addresses.src_address, 
			city_id = tmp_dim_addresses.city_id,
			city_name = tmp_dim_addresses.city_name,
			zipcode = tmp_dim_addresses.zipcode,
			ta_update_dt=current_timestamp ::TIMESTAMPTZ
		FROM tmp_dim_addresses
		WHERE tmp_dim_addresses.src_system=bl_dm.dim_addresses.source_system AND 
			tmp_dim_addresses.src_entity=bl_dm.dim_addresses.source_entity AND 
			tmp_dim_addresses.src_id=bl_dm.dim_addresses.address_src_id AND 
			(
			bl_dm.dim_addresses.address <> tmp_dim_addresses.src_address OR 
			bl_dm.dim_addresses.city_id <> tmp_dim_addresses.city_id or 
			bl_dm.dim_addresses.city_name <> tmp_dim_addresses.city_name or
			bl_dm.dim_addresses.zipcode <> tmp_dim_addresses.zipcode
			);

	GET DIAGNOSTICS log_updated = ROW_COUNT;

			-- INSERT 
			INSERT INTO bl_dm.dim_addresses(
				address,
				city_id,
				city_name,
				zipcode,
				source_system ,
				source_entity ,
				address_src_id ,
				ta_insert_dt ,
				ta_update_dt 
			)
			SELECT tmp_dim_addresses.src_address,
				tmp_dim_addresses.city_id,
				tmp_dim_addresses.city_name,
				tmp_dim_addresses.zipcode,
				tmp_dim_addresses.src_system,
				tmp_dim_addresses.src_entity,
				tmp_dim_addresses.src_id, 
				current_timestamp ::TIMESTAMPTZ,
				current_timestamp ::TIMESTAMPTZ
			FROM tmp_dim_addresses
			WHERE NOT EXISTS (
				SELECT 1
				FROM bl_dm.dim_addresses
				WHERE tmp_dim_addresses.src_system=bl_dm.dim_addresses.source_system AND 
					tmp_dim_addresses.src_entity=bl_dm.dim_addresses.source_entity AND 
					tmp_dim_addresses.src_id=bl_dm.dim_addresses.address_src_id
			);

			GET DIAGNOSTICS log_inserted = ROW_COUNT;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_dim_addresses',
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
		'load_dim_addresses',
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