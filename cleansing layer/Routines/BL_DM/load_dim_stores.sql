-- created type for often used rows of city
--placed in anonymous function to make script rerunnable
DO $$
BEGIN
	IF NOT EXISTS (
		SELECT 1
		FROM pg_type
		WHERE typname = 'city_t'
		AND typnamespace = 'bl_cl'::regnamespace
	)
	THEN
		CREATE TYPE bl_cl.city_t AS (
			city_id bigint,
			city_name varchar,
			zipcode varchar
		);
	END IF;
END $$;

-- procedure for loading dimension table stores uses cursor variable and city type:
CREATE OR REPLACE PROCEDURE bl_cl.load_dim_stores()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
	rows_affected bigint := 0;
    rec RECORD;
    store_cursor REFCURSOR;

    city bl_cl.city_t;
BEGIN

OPEN store_cursor FOR
	-- Gather data from source	--
	SELECT 
	bl_3nf.ce_stores.store_code AS src_code,
	bl_3nf.ce_cities.city_id AS src_c_id,
	bl_3nf.ce_cities.city_name AS src_c_name,
	bl_3nf.ce_cities.zipcode AS src_zipcode,
	'bl_3nf' AS src_system,
	'ce_store' AS src_entity,
	bl_3nf.ce_stores.store_id::varchar(1000) AS src_id
	FROM bl_3nf.ce_stores
	INNER JOIN bl_3nf.ce_cities ON bl_3nf.ce_stores.city_id = bl_3nf.ce_cities.city_id
	where bl_3nf.ce_stores.store_id <> -1;
LOOP

FETCH store_cursor INTO rec;
EXIT WHEN NOT FOUND;

city := ROW(
	    rec.src_c_id,
	    rec.src_c_name,
	    rec.src_zipcode
	)::bl_cl.city_t;

	-- INSERT 

	INSERT INTO bl_dm.dim_stores
	(
		store_code ,
		city_id ,
		city_name,
		zipcode ,
		source_system ,
		source_entity ,
		store_src_id ,
		ta_insert_dt ,
		ta_update_dt 
	) 
	SELECT rec.src_code,
	city.city_id,
	city.city_name,
	city.zipcode,
	rec.src_system,
	rec.src_entity,
	rec.src_id,
	current_timestamp::timestamptz,
	current_timestamp::timestamptz
	WHERE NOT EXISTS (
	SELECT 1
	FROM bl_dm.dim_stores 
	WHERE bl_dm.dim_stores.source_system=rec.src_system AND 
	bl_dm.dim_stores.source_entity = rec.src_entity AND 
	bl_dm.dim_stores.store_src_id = rec.src_id
	);

	GET DIAGNOSTICS rows_affected = ROW_COUNT;

	log_inserted := log_inserted + rows_affected;

END LOOP;
CLOSE store_cursor;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_dim_stores',
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

	IF store_cursor IS NOT NULL THEN
        CLOSE store_cursor;
    END IF;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_dim_stores',
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