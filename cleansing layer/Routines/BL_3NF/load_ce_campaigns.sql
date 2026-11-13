--procedure begins by creating a temporary table that gathers the required data from the source systems and transforms 
--it into the format required for loading into the target tables. 
--For SCD Type 1 tables, the procedure first checks whether
--the temporary table contains records with the same source identifier triplet (source_system, source_entity, source_id) but
--different attribute values. If such records are found, the existing rows are updated. Afterward, any new records that do
--not already exist in the target table are inserted.

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_campaigns()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
	affected_rows bigint := 0;
	rec RECORD;
BEGIN

	-- Gather data from source	--
	CREATE TEMP TABLE tmp_campaigns 
	ON COMMIT DROP AS
	SELECT 
		COALESCE (TRIM(LOWER(campaign_name)),'n.a.') AS c_name,
		'sa_grocery_instore_sales' AS src_system,
		'src_source2_offline' AS src_entity,
		TRIM(LOWER(campaign_id)) AS src_id,
		ROW_NUMBER() OVER (PARTITION BY TRIM(LOWER(campaign_id))
		ORDER BY sa_grocery_instore_sales.src_source2_offline.sales_dt::TIMESTAMPTZ DESC ) AS rn
	FROM sa_grocery_instore_sales.src_source2_offline  
	WHERE campaign_id IS NOT NULL and 
		sa_grocery_instore_sales.src_source2_offline.sales_dt IS NOT NULL
	UNION ALL 
	SELECT
		COALESCE (TRIM(LOWER(campaign_name)),'n.a.') AS c_name,
		'sa_grocery_online_sales' AS src_system,
		'src_source1_online' AS src_entity,
		TRIM(LOWER(campaign_id)) AS src_id,
		ROW_NUMBER() OVER (PARTITION BY TRIM(LOWER(campaign_id))
		ORDER BY sa_grocery_online_sales.src_source1_online.sales_dt::TIMESTAMPTZ DESC ) AS rn
	FROM sa_grocery_online_sales.src_source1_online  
	WHERE campaign_id IS NOT NULL AND 
		sa_grocery_online_sales.src_source1_online.sales_dt IS NOT NULL;

    -- UPDATE	--

    FOR rec IN
        SELECT *
        FROM tmp_campaigns
        WHERE rn = 1
    LOOP

        UPDATE bl_3nf.ce_campaigns
        SET
            campaign_name = rec.c_name,
            ta_update_dt = current_timestamp
        WHERE source_system = rec.src_system
          AND source_entity = rec.src_entity
          AND campaign_src_id = rec.src_id
          AND campaign_name <> rec.c_name;

        GET DIAGNOSTICS affected_rows = ROW_COUNT;
		log_updated := log_updated + affected_rows;

    -- INSERT	--
        INSERT INTO bl_3nf.ce_campaigns
        (
            campaign_id,
            campaign_name,
            source_system,
            source_entity,
            campaign_src_id,
            ta_insert_dt,
            ta_update_dt
        )
        SELECT
            nextval('bl_3nf.sqc_campaigns'),
            rec.c_name,
            rec.src_system,
            rec.src_entity,
            rec.src_id,
            current_timestamp,
            current_timestamp
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM bl_3nf.ce_campaigns
            WHERE source_system = rec.src_system
              AND source_entity = rec.src_entity
              AND campaign_src_id = rec.src_id
        );

        GET DIAGNOSTICS affected_rows = ROW_COUNT;
		log_inserted := log_inserted + affected_rows;

    END LOOP;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_ce_campaigns',
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
		'load_ce_campaigns',
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