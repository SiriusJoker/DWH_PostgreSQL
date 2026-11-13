-- This script inserts data from foreign tables to source tables

CREATE OR REPLACE PROCEDURE bl_cl.insert_to_sa()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
	rows_affected bigint := 0;
BEGIN

	INSERT INTO sa_grocery_instore_sales.src_source2_offline
	SELECT DISTINCT *
	FROM sa_grocery_instore_sales.ext_source2_offline
	WHERE NOT EXISTS (
		SELECT 1
		FROM sa_grocery_instore_sales.src_source2_offline 
		WHERE src_source2_offline.SALES_ID=ext_source2_offline.SalesID
	);

	GET DIAGNOSTICS log_inserted = ROW_COUNT;

	INSERT INTO sa_grocery_online_sales.src_source1_online 
	SELECT DISTINCT *
	FROM sa_grocery_online_sales.ext_source1_online
	WHERE NOT EXISTS (
		SELECT 1
		FROM sa_grocery_online_sales.src_source1_online 
		WHERE src_source1_online.SALES_ID=ext_source1_online.SalesID
	);

	GET DIAGNOSTICS rows_affected = ROW_COUNT;

	log_inserted:=log_inserted+rows_affected;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'insert_to_sa',
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
		'insert_to_sa',
		log_updated + log_inserted,
		log_updated,
		log_inserted,
		'FAILED',
		SQLERRM,
		log_start_time,
		log_end_time
    );

    RAISE;
END;
$$;