-- procedure for loading dimension table promotions uses update + insert:
CREATE OR REPLACE PROCEDURE bl_cl.load_dim_promotions()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
BEGIN

	-- Gather data from source	--
	CREATE TEMP TABLE tmp_dim_promotions
	ON COMMIT DROP AS
	SELECT 
	bl_3nf.ce_promotions.promotion_name AS src_name,
	bl_3nf.ce_promotions.channel AS src_channel,
	bl_3nf.ce_promotions.promotion_start_dt AS src_start_dt,
	bl_3nf.ce_promotions.promotion_end_dt AS src_end_dt,
	bl_3nf.ce_promotions.discount AS src_discount,
	bl_3nf.ce_promotions.campaign_id AS src_c_id,
	bl_3nf.ce_campaigns.campaign_name AS src_c_name,
	'bl_3nf' AS src_system,
	'ce_promotions' AS src_entity,
	bl_3nf.ce_promotions.promotion_id::varchar(1000) AS src_id
	FROM bl_3nf.ce_promotions
	INNER JOIN bl_3nf.ce_campaigns ON bl_3nf.ce_promotions.campaign_id = bl_3nf.ce_campaigns.campaign_id
	WHERE bl_3nf.ce_promotions.promotion_id <> -1;

    -- UPDATE	--

	UPDATE bl_dm.dim_promotions 
	SET promotion_name = src_name,
	channel = src_channel,
	promotion_start_dt = src_start_dt,
	promotion_end_dt = src_end_dt,
	discount = src_discount,
	campaign_id = src_c_id,
	campaign_name = src_c_name,
	ta_update_dt = current_timestamp::timestamptz
	FROM tmp_dim_promotions
	WHERE source_system=src_system AND 
	source_entity = src_entity AND
	promotion_src_id =src_id AND 
	(
	promotion_name <> src_name OR
	channel <> src_channel OR
	promotion_start_dt <> src_start_dt OR
	promotion_end_dt <> src_end_dt OR
	discount <> src_discount OR
	campaign_id <> src_c_id OR
	campaign_name <> src_c_name
	);

	GET DIAGNOSTICS log_updated = ROW_COUNT;

	-- INSERT 
	INSERT INTO bl_dm.dim_promotions
	(
		promotion_name,
		channel ,
		promotion_start_dt ,
		promotion_end_dt ,
		discount ,
		campaign_id ,
		campaign_name,
		source_system ,
		source_entity ,
		promotion_src_id ,
		ta_insert_dt ,
		ta_update_dt 
	)
	SELECT src_name,
	src_channel,
	src_start_dt,
	src_end_dt,
	src_discount,
	src_c_id,
	src_c_name,
	src_system,
	src_entity,
	src_id,
	current_timestamp::timestamptz,
	current_timestamp::timestamptz
	FROM tmp_dim_promotions
	WHERE NOT EXISTS (
	SELECT 1 FROM bl_dm.dim_promotions
	WHERE 
	source_system=src_system AND 
	source_entity = src_entity AND
	promotion_src_id =src_id) ;

	GET DIAGNOSTICS log_inserted = ROW_COUNT;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_dim_promotions',
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
		'load_dim_promotions',
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