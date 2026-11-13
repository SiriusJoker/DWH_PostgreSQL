--procedure begins by creating a temporary table that gathers the required data from the source systems and transforms 
--it into the format required for loading into the target tables. 
--For SCD Type 1 tables, the procedure first checks whether
--the temporary table contains records with the same source identifier triplet (source_system, source_entity, source_id) but
--different attribute values. If such records are found, the existing rows are updated. Afterward, any new records that do
--not already exist in the target table are inserted. 

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_promotions()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
BEGIN

	-- Gather data from source	--
	CREATE TEMP TABLE tmp_promotions
	ON COMMIT DROP AS
	WITH source_offline AS (
		SELECT 
		'sa_grocery_instore_sales' AS src_system,
		'src_source2_offline' AS src_entity
	),
	source_online AS (
		SELECT 
		'sa_grocery_online_sales' AS src_system,
		'src_source1_online' AS src_entity
	)
		SELECT 
			COALESCE (TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.promotion_name)),'n.a') AS src_name,
			COALESCE (TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.channel)),'n.a.') AS src_ch,
			COALESCE (sa_grocery_instore_sales.src_source2_offline.promotion_sop ::TIMESTAMPTZ,'1900-01-01 00:00'::TIMESTAMPTZ) AS src_p_sop,
			COALESCE (sa_grocery_instore_sales.src_source2_offline.promotion_eop ::TIMESTAMPTZ,'1900-01-01 00:00'::TIMESTAMPTZ) AS src_p_eop,
			COALESCE (bl_3nf.ce_campaigns.campaign_id,-1) AS src_campaign,
			COALESCE (sa_grocery_instore_sales.src_source2_offline.discount::NUMERIC(3,2),-1) AS src_discount,
			source_offline.src_system,
			source_offline.src_entity,
			TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.promotion_id)) AS src_id,
			ROW_NUMBER() OVER(PARTITION BY TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.promotion_id))
				ORDER BY sa_grocery_instore_sales.src_source2_offline.sales_dt::TIMESTAMPTZ DESC 
			) AS rn 
		FROM sa_grocery_instore_sales.src_source2_offline  
		CROSS JOIN source_offline
		LEFT JOIN bl_3nf.ce_campaigns ON bl_3nf.ce_campaigns.source_system=src_system AND 
			bl_3nf.ce_campaigns.source_entity=src_entity AND 
			bl_3nf.ce_campaigns.campaign_src_id=TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.campaign_id))
		WHERE sa_grocery_instore_sales.src_source2_offline.promotion_id IS NOT NULL AND 
			sa_grocery_instore_sales.src_source2_offline.sales_dt IS NOT NULL
		UNION ALL 
		SELECT 
			COALESCE (TRIM(LOWER(sa_grocery_online_sales.src_source1_online.promotion_name )),'n.a.') AS src_name,
			COALESCE (TRIM(LOWER(sa_grocery_online_sales.src_source1_online.channel)),'n.a.')AS src_ch ,
			COALESCE (sa_grocery_online_sales.src_source1_online.promotion_sop::TIMESTAMPTZ,'1900-01-01 00:00'::TIMESTAMPTZ) AS src_p_sop ,
			COALESCE (sa_grocery_online_sales.src_source1_online.promotion_eop::TIMESTAMPTZ,'1900-01-01 00:00'::TIMESTAMPTZ) AS src_p_eop ,
			COALESCE (bl_3nf.ce_campaigns.campaign_id,-1) AS src_campaign,
			COALESCE (sa_grocery_online_sales.src_source1_online.discount::NUMERIC(3,2),-1) AS src_discount ,
			source_online.src_system,
			source_online.src_entity,
			TRIM(LOWER(sa_grocery_online_sales.src_source1_online.promotion_id )) AS src_id,	
			ROW_NUMBER() OVER (PARTITION BY TRIM(LOWER(sa_grocery_online_sales.src_source1_online.promotion_id ))
				ORDER BY sa_grocery_online_sales.src_source1_online.sales_dt::TIMESTAMPTZ DESC
			) AS rn 
		FROM sa_grocery_online_sales.src_source1_online  
		CROSS JOIN source_online
		LEFT JOIN bl_3nf.ce_campaigns ON bl_3nf.ce_campaigns.source_system=src_system AND 
			bl_3nf.ce_campaigns.source_entity=src_entity AND 
			bl_3nf.ce_campaigns.campaign_src_id=TRIM(LOWER(sa_grocery_online_sales.src_source1_online.campaign_id))
		WHERE sa_grocery_online_sales.src_source1_online.promotion_id IS NOT NULL AND 
			sa_grocery_online_sales.src_source1_online.sales_dt IS NOT NULL;

    -- UPDATE	--
	UPDATE bl_3nf.ce_promotions
	SET promotion_name = tmp_promotions.src_name,
		channel = tmp_promotions.src_ch,
		promotion_start_dt = tmp_promotions.src_p_sop,
		promotion_end_dt = tmp_promotions.src_p_eop,
		campaign_id = tmp_promotions.src_campaign,
		discount = tmp_promotions.src_discount,
		ta_update_dt=current_timestamp ::TIMESTAMPTZ
	FROM tmp_promotions
	WHERE rn=1 AND 
		tmp_promotions.src_system=bl_3nf.ce_promotions.source_system AND 
		tmp_promotions.src_entity=bl_3nf.ce_promotions.source_entity AND 
		tmp_promotions.src_id=bl_3nf.ce_promotions.promotion_src_id AND 
		(
			promotion_name <> tmp_promotions.src_name or
			channel <> tmp_promotions.src_ch or
			promotion_start_dt <> tmp_promotions.src_p_sop or
			promotion_end_dt <> tmp_promotions.src_p_eop or
			campaign_id <> tmp_promotions.src_campaign or
			discount <> tmp_promotions.src_discount
		);

	GET DIAGNOSTICS log_updated = ROW_COUNT;

	-- INSERT 
	INSERT INTO bl_3nf.ce_promotions(
		promotion_id,
		promotion_name,
		channel,
		promotion_start_dt,
		promotion_end_dt,
		campaign_id,
		discount,
		source_system,
		source_entity,
		promotion_src_id,
		ta_insert_dt,
		ta_update_dt
	)
	SELECT 
		NEXTVAL('bl_3nf.sqc_promotions'),
		src_name,
		src_ch ,
		src_p_sop ,
		src_p_eop ,
		src_campaign ,
		src_discount ,
		src_system,
		src_entity,
		src_id,
		current_timestamp ::TIMESTAMPTZ,
		current_timestamp ::TIMESTAMPTZ
	FROM tmp_promotions
	WHERE rn=1 AND 
		src_id<>'0' AND -- for promotions source have '0' for no applied promotion. This line excludes this records
		NOT EXISTS (
			SELECT 1
			FROM bl_3nf.ce_promotions
			WHERE bl_3nf.ce_promotions.source_system=src_system AND 
				bl_3nf.ce_promotions.source_entity=src_entity AND 
				bl_3nf.ce_promotions.promotion_src_id=src_id
		);

	GET DIAGNOSTICS log_inserted = ROW_COUNT;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_ce_promotions',
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
		'load_ce_promotions',
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