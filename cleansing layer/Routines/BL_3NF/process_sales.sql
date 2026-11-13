
-- procedure that contains calls of procedures for prefact tables and processes source tables. 
CREATE OR REPLACE PROCEDURE bl_cl.process_sales()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    rows_affected bigint := 0;
BEGIN

	CALL bl_cl.load_ce_deliveries();
    CALL bl_cl.load_ce_sales();
    

    UPDATE sa_grocery_instore_sales.src_source2_offline
    SET processed_flag = 'y',
        processed_dt = clock_timestamp()
    WHERE processed_flag = 'n';

	GET DIAGNOSTICS rows_affected = ROW_COUNT;

	UPDATE sa_grocery_online_sales.src_source1_online 
	SET processed_flag='y',
        processed_dt = clock_timestamp()
	WHERE processed_flag='n';

	GET DIAGNOSTICS log_updated = ROW_COUNT;
	log_updated:=log_updated+rows_affected;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'process_sales',
		log_updated ,
		log_updated,
		0,
		'SUCCESS',
		NULL,
		log_start_time,
		log_end_time
    );

EXCEPTION
WHEN OTHERS THEN

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'process_sales',
		log_updated,
		log_updated,
		0,
		'FAILED',
		SQLERRM,
		log_start_time,
		log_end_time
    );

END;
$$;
