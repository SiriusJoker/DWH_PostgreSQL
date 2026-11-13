-- This script contains procedure of initial and incremental load of prefact table ce_deliveries in bl_3nf

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_deliveries()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
BEGIN
	-- Gather data from source	--
	CREATE TEMP TABLE tmp_deliveries
	ON COMMIT DROP AS
	WITH src_online AS (
		SELECT 
		'sa_grocery_online_sales' AS src_system,
		'src_source1_online' AS src_entity
	), all_cols AS (
		SELECT 
			bl_3nf.ce_addresses.address_id AS a_id,
			sa_grocery_online_sales.src_source1_online.shipping_cost::numeric(11,6)  AS d_cost,
			sa_grocery_online_sales.src_source1_online.delivery_date::timestamptz AS d_dt,
			src_online.src_system ,
			src_online.src_entity ,
			TRIM(LOWER(sa_grocery_online_sales.src_source1_online.delivery_address)) ||'|'||
			(sa_grocery_online_sales.src_source1_online.shipping_cost::numeric(11,6))::varchar(1000) ||'|'||
			(sa_grocery_online_sales.src_source1_online.delivery_date::timestamptz)::varchar(1000) AS src_id,
			ROW_NUMBER () OVER (PARTITION BY TRIM(LOWER(sa_grocery_online_sales.src_source1_online.delivery_address)),
				sa_grocery_online_sales.src_source1_online.shipping_cost::numeric(11,6),
				sa_grocery_online_sales.src_source1_online.delivery_date::timestamptz
				ORDER BY sa_grocery_online_sales.src_source1_online.sales_dt::TIMESTAMPTZ DESC
			) AS rn
		FROM sa_grocery_online_sales.src_source1_online 
		CROSS JOIN src_online
		LEFT JOIN bl_3nf.ce_addresses ON bl_3nf.ce_addresses.source_system =src_online.src_system AND 
			bl_3nf.ce_addresses.source_entity =src_online.src_entity AND 
			bl_3nf.ce_addresses.address_src_id =TRIM(LOWER(sa_grocery_online_sales.src_source1_online.delivery_address))	
		WHERE sa_grocery_online_sales.src_source1_online.delivery_address IS NOT NULL AND 
			sa_grocery_online_sales.src_source1_online.shipping_cost IS NOT NULL AND 
			sa_grocery_online_sales.src_source1_online.delivery_date IS NOT NULL AND
			sa_grocery_online_sales.src_source1_online.sales_dt IS NOT NULL AND
			sa_grocery_online_sales.src_source1_online.processed_flag = 'n'

-- Delivery is a small pre-fact table representing the delivery business process.
-- It is important to preserve all of its attributes (delivery address, delivery cost,
-- delivery date, and sales date). Without any of these attributes, a delivery record
-- is incomplete and loses its business meaning. Therefore, NOT NULL conditions are
-- used to prevent records with missing attribute values.
	)	
	SELECT 
		a_id,
		d_cost,
		d_dt,
		src_system ,
		src_entity ,
		src_id
	FROM all_cols
	LEFT JOIN bl_3nf.ce_deliveries ON bl_3nf.ce_deliveries.source_system=src_system AND 
		bl_3nf.ce_deliveries.source_entity=src_entity AND 
		bl_3nf.ce_deliveries.delivery_src_id = src_id
	WHERE rn=1 AND 
		bl_3nf.ce_deliveries.delivery_id IS NULL;

	-- INSERT 
	INSERT INTO  bl_3nf.ce_deliveries 
	SELECT 	
		NEXTVAL('bl_3nf.sqc_deliveries'),
		a_id,
		d_cost,
		d_dt,
		src_system,
		src_entity,
		src_id,
		current_timestamp ::TIMESTAMPTZ,
		current_timestamp ::TIMESTAMPTZ
	FROM tmp_deliveries;

	GET DIAGNOSTICS log_inserted = ROW_COUNT;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_ce_deliveries',
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
		'load_ce_deliveries',
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