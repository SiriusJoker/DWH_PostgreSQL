
-- This procedure implements the rolling window logic:
-- when data for a new month arrives, the oldest monthly partition is detached and its data is removed;
-- a new partition for the incoming month is then created;
-- finally, the corresponding data is loaded into each partition by calling the partition load procedure.
CREATE OR REPLACE PROCEDURE bl_cl.deliveries_rolling_window()
LANGUAGE plpgsql
AS $$
declare 

mnth varchar(2);
yr varchar(4);
dt timestamptz;
f_day timestamptz;
l_day timestamptz;
start_date timestamptz;
end_date timestamptz;
partition_to_remove text;
partition_to_load text;

BEGIN 
	
	start_date:= date_trunc('month', current_date - interval '3 month');
	end_date:=date_trunc('month', current_date);
	mnth := to_char(start_date, 'MM');
	yr := to_char(start_date, 'YYYY');
	partition_to_remove:='fact_deliveries_' || yr || '_' || mnth;

	IF to_regclass('bl_dm.' || partition_to_remove) IS NOT NULL THEN
		BEGIN
			EXECUTE format(
		        'ALTER TABLE bl_dm.fact_deliveries_dd DETACH PARTITION bl_dm.%I;'	,
				partition_to_remove);
			EXECUTE format('INSERT INTO bl_dm.fact_deliveries_default
					SELECT *
					FROM bl_dm.%I;',
					partition_to_remove);
			EXECUTE format('DROP TABLE IF EXISTS bl_dm.%I',
			        partition_to_remove);
		EXCEPTION
		    WHEN OTHERS THEN
		        RAISE EXCEPTION 
		            'Failed to move partition % to default partition: %',
		            partition_to_remove,
		            SQLERRM;
		END;
	END IF;


	mnth := to_char(end_date, 'MM');
	yr := to_char(end_date, 'YYYY');
	f_day := date_trunc('month', end_date)::timestamptz; -- start of the month
	l_day := (date_trunc('month', end_date)+'1month'::interval)::timestamptz; -- start of the next month
	EXECUTE format(
    'CREATE TABLE IF NOT EXISTS bl_dm.%I PARTITION OF bl_dm.fact_deliveries_dd
     FOR VALUES FROM (%L) TO (%L)',
    'fact_deliveries_' || yr || '_' || mnth,
    f_day,
    l_day
	);

	FOR dt IN SELECT generate_series(current_date - interval '2 month', current_date, '1 month'::interval) 
	LOOP
		mnth := to_char(dt, 'MM');
		yr := to_char(dt, 'YYYY');
		f_day := date_trunc('month', dt)::timestamptz; -- start of the month
		l_day := (date_trunc('month', dt)+'1month'::interval)::timestamptz; -- start of the next month
		partition_to_load:='fact_deliveries_' || yr || '_' || mnth;
		CALL bl_cl.load_fact_deliveries_partition(partition_to_load,f_day,l_day);
	END LOOP;
EXCEPTION
        WHEN OTHERS THEN
            RAISE EXCEPTION
                'Error handling rolling window for fact_deliveries partitions: %',
                SQLERRM;

END;
$$;

-- this procedure loads data into partition
CREATE OR REPLACE PROCEDURE bl_cl.load_fact_deliveries_partition(
    p_partition_name text,
    p_start_date timestamptz,
    p_end_date timestamptz
)
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
BEGIN
	-- postgresql drop it at the end of the session, however I call this procedure 3 times in one session, therefore I need to drop it
	DROP TABLE IF EXISTS tmp_fact_deliveries;
	-- Gather data from source	--
	CREATE TEMP TABLE tmp_fact_deliveries
	ON COMMIT DROP AS
	SELECT 
		to_char(bl_3nf.ce_deliveries.delivery_dt::date,'YYYYMMDD')::bigint AS src_time_id,
		bl_3nf.ce_deliveries.delivery_cost AS src_cost,
		bl_3nf.ce_deliveries.delivery_dt AS src_dt,
		COALESCE(bl_dm.dim_addresses.address_surr_id, -1) AS src_add,
		'bl_3nf' AS src_system,
		'ce_deliveries' AS src_entity,
		bl_3nf.ce_deliveries.delivery_id::varchar(1000) AS src_id
	FROM bl_3nf.ce_deliveries
	LEFT JOIN bl_dm.dim_addresses ON bl_3nf.ce_deliveries.delivery_address_id::varchar(1000)= bl_dm.dim_addresses.address_src_id 
	WHERE bl_3nf.ce_deliveries.delivery_id <> -1 and 
		bl_3nf.ce_deliveries.delivery_dt >= p_start_date and 
		bl_3nf.ce_deliveries.delivery_dt < p_end_date;

    -- INSERT 
	EXECUTE format('INSERT INTO bl_dm.%I
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
			FROM bl_dm.%I
			WHERE source_system=src_system AND 
			source_entity=src_entity AND 
			delivery_src_id = src_id
		)'
	, p_partition_name,p_partition_name)
	;

	GET DIAGNOSTICS log_inserted = ROW_COUNT;


	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_fact_deliveries_partition',
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
		'load_fact_deliveries_partition',
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
