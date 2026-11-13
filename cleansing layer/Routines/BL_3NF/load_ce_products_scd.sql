--Each procedure begins by creating a temporary table that gathers the required data from the source systems and transforms 
--it into the format required for loading into the target tables. 
--For the SCD Type 2 table, when a change is detected, the current active
--record is marked as inactive, and a new record containing the updated attribute values is inserted. The new record retains
--the same business identifier while receiving a new start_dt, and the previous record is assigned an end_dt. 

CREATE OR REPLACE FUNCTION bl_cl.get_product_source_data()
RETURNS TABLE
(	
	src_start_dt timestamptz,
    src_name text,
    src_code text,
    src_u_price numeric(11,6),
    src_class text,
    src_m_dt date,
    src_resistant text,
    src_allergic text,
    src_vitality numeric(4,1),
    src_subcategory bigint,
    src_u_cost numeric(11,6),
    src_system text,
    src_entity text,
    src_id text,
    sales_dt timestamptz,
    rn bigint
)
LANGUAGE sql
AS $$
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
		COALESCE (sa_grocery_instore_sales.src_source2_offline.sales_dt::TIMESTAMPTZ,'1900-01-01 00:00 '::timestamptz) AS src_start_dt,
		COALESCE (TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.product_name)),'n.a.') AS src_name,
		TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.product_id )) AS src_code,
		COALESCE (sa_grocery_instore_sales.src_source2_offline.unit_price::NUMERIC(11,6),-1) AS src_u_price ,
		COALESCE (TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline."class")),'n.a.') AS src_class ,
		COALESCE (sa_grocery_instore_sales.src_source2_offline.modify_dt::DATE, '1900-01-01'::DATE) AS src_m_dt,
		'n.a.' AS src_resistant,
		'n.a.' AS src_allergic,
		-1 AS src_vitality,
		COALESCE(bl_3nf.ce_product_subcategories.product_subcategory_id,-1) AS src_subcategory,
		COALESCE (sa_grocery_instore_sales.src_source2_offline.unit_cost::NUMERIC(11,6),-1) AS src_u_cost,
		source_offline.src_system ,
		source_offline.src_entity ,
		TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.product_id )) AS src_id,
		sa_grocery_instore_sales.src_source2_offline.sales_dt::TIMESTAMPTZ AS sales_dt,
		ROW_NUMBER()OVER (PARTITION BY TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.product_id ))
			ORDER BY sa_grocery_instore_sales.src_source2_offline.sales_dt::TIMESTAMPTZ DESC 
		) AS rn 
	FROM sa_grocery_instore_sales.src_source2_offline  
	CROSS JOIN source_offline 
	LEFT JOIN bl_3nf.ce_product_subcategories ON bl_3nf.ce_product_subcategories.source_system =source_offline.src_system AND 
		bl_3nf.ce_product_subcategories.source_entity =source_offline.src_entity AND
		bl_3nf.ce_product_subcategories.product_subcategory_src_id = TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.subcategory_name))
	WHERE sa_grocery_instore_sales.src_source2_offline.product_id IS NOT NULL AND 
		sa_grocery_instore_sales.src_source2_offline.sales_dt IS NOT NULL 
	UNION ALL 
	SELECT
		COALESCE(sa_grocery_online_sales.src_source1_online.sales_dt::TIMESTAMPTZ,'1900-01-01 00:00 '::timestamptz) AS src_start_dt, 
		COALESCE (TRIM(LOWER(sa_grocery_online_sales.src_source1_online.product_name)),'n.a.') AS src_name,
		TRIM(LOWER(sa_grocery_online_sales.src_source1_online.product_id )) AS src_code,
		COALESCE (sa_grocery_online_sales.src_source1_online.unit_price::NUMERIC(11,6),-1) AS src_u_price ,
		COALESCE (TRIM(LOWER(sa_grocery_online_sales.src_source1_online."class")),'n.a.') AS src_class ,
		COALESCE (sa_grocery_online_sales.src_source1_online.modify_date::DATE, '1900-01-01'::DATE) AS src_m_dt,
		COALESCE (TRIM(LOWER(sa_grocery_online_sales.src_source1_online.resistant)),'n.a.') AS src_resistant ,
		COALESCE (TRIM(LOWER(sa_grocery_online_sales.src_source1_online.is_allergic)),'n.a.') AS src_allergic ,
		COALESCE (sa_grocery_online_sales.src_source1_online.vitality_days::NUMERIC(4,1),-1) AS src_vitality ,
		COALESCE(bl_3nf.ce_product_subcategories.product_subcategory_id,-1) AS src_subcategory,
		COALESCE (sa_grocery_online_sales.src_source1_online.unit_cost::NUMERIC(11,6),-1) AS src_u_cost,
		source_online.src_system,
		source_online.src_entity,
		TRIM(LOWER(sa_grocery_online_sales.src_source1_online.product_id )) AS src_id,
		sa_grocery_online_sales.src_source1_online.sales_dt::TIMESTAMPTZ AS sales_dt,
		ROW_NUMBER() OVER(PARTITION BY TRIM(LOWER(sa_grocery_online_sales.src_source1_online.product_id ))
			ORDER BY sa_grocery_online_sales.src_source1_online.sales_dt::TIMESTAMPTZ DESC
		) AS rn	
	FROM sa_grocery_online_sales.src_source1_online  
	CROSS JOIN source_online
	LEFT JOIN bl_3nf.ce_product_subcategories ON bl_3nf.ce_product_subcategories.source_system =source_online.src_system AND 
		bl_3nf.ce_product_subcategories.source_entity =source_online.src_entity AND
		bl_3nf.ce_product_subcategories.product_subcategory_src_id =TRIM(LOWER(sa_grocery_online_sales.src_source1_online.subcategory_name))
	WHERE sa_grocery_online_sales.src_source1_online.product_id IS NOT NULL AND 
		sa_grocery_online_sales.src_source1_online.sales_dt IS NOT NULL;
$$;

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_products_scd()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
BEGIN

	-- Gather data from source	--
	CREATE TEMP TABLE tmp_products
	ON COMMIT DROP AS
	SELECT *
	FROM bl_cl.get_product_source_data();

    -- UPDATE	--
	
	WITH needs_update AS (
	SELECT bl_3nf.ce_products_scd.product_id, 
		tmp_products.src_start_dt,
		tmp_products.src_name,
		tmp_products.src_code, -- won't change because it's natural key: in this case same as src_id
		tmp_products.src_u_price ,
		tmp_products.src_class ,
		tmp_products.src_m_dt,
		tmp_products.src_resistant ,
		tmp_products.src_allergic ,
		tmp_products.src_vitality ,
		tmp_products.src_subcategory,
		tmp_products.src_u_cost,
		tmp_products.src_system,
		tmp_products.src_entity,
		tmp_products.src_id
	FROM tmp_products
	INNER JOIN bl_3nf.ce_products_scd ON tmp_products.src_system=bl_3nf.ce_products_scd.source_system AND 
			tmp_products.src_entity=bl_3nf.ce_products_scd.source_entity AND 
			tmp_products.src_id=bl_3nf.ce_products_scd.product_src_id AND 
			bl_3nf.ce_products_scd.is_active ='y' AND 
			(
				tmp_products.src_name <> bl_3nf.ce_products_scd.product_name or
				tmp_products.src_u_price  <> bl_3nf.ce_products_scd.unit_price or
				tmp_products.src_class  <> bl_3nf.ce_products_scd."class" or
				tmp_products.src_m_dt <> bl_3nf.ce_products_scd.modify_dt or
				tmp_products.src_resistant <> bl_3nf.ce_products_scd.resistant  or
				tmp_products.src_allergic <> bl_3nf.ce_products_scd.is_allergic  or
				tmp_products.src_vitality <> bl_3nf.ce_products_scd.vitality_days  or
				tmp_products.src_subcategory <> bl_3nf.ce_products_scd.product_subcategory_id OR
				tmp_products.src_u_cost <> bl_3nf.ce_products_scd.unit_cost 
			)
	WHERE tmp_products.rn = 1
	), updates AS (
	UPDATE bl_3nf.ce_products_scd
	SET is_active = 'n',
	 end_dt = src_start_dt,
	 ta_update_dt= current_timestamp ::TIMESTAMPTZ
	FROM needs_update
	WHERE  needs_update.src_system=bl_3nf.ce_products_scd.source_system AND 
			needs_update.src_entity=bl_3nf.ce_products_scd.source_entity AND 
			needs_update.src_id=bl_3nf.ce_products_scd.product_src_id AND 
			bl_3nf.ce_products_scd.is_active ='y'
	)	
	INSERT INTO bl_3nf.ce_products_scd
	SELECT product_id, 
		src_start_dt,
		src_name,
		src_code, 
		src_u_price ,
		src_class ,
		src_m_dt,
		src_resistant ,
		src_allergic ,
		src_vitality ,
		src_subcategory,
		src_u_cost,
		src_system,
		src_entity,
		src_id,
		current_timestamp ::TIMESTAMPTZ,
		current_timestamp ::TIMESTAMPTZ,
		'9999-12-31 00:00 '::timestamptz,
		'y'
	FROM needs_update;

	GET DIAGNOSTICS log_updated = ROW_COUNT;

	-- INSERT 

	INSERT INTO bl_3nf.ce_products_scd
	SELECT NEXTVAL('bl_3nf.sqc_products'),
		src_start_dt,
		src_name,
		src_code,
		src_u_price ,
		src_class ,
		src_m_dt,
		src_resistant ,
		src_allergic ,
		src_vitality ,
		src_subcategory,
		src_u_cost,
		src_system,
		src_entity,
		src_id,
		current_timestamp ::TIMESTAMPTZ,
		current_timestamp ::TIMESTAMPTZ,
		'9999-12-31 00:00 '::timestamptz,
		'y'
	FROM tmp_products
		WHERE rn=1 AND
		NOT EXISTS (
		SELECT 1
		FROM bl_3nf.ce_products_scd
		WHERE bl_3nf.ce_products_scd.source_system=src_system AND 
			bl_3nf.ce_products_scd.source_entity=src_entity AND
			bl_3nf.ce_products_scd.product_src_id=src_id
		);

	GET DIAGNOSTICS log_inserted = ROW_COUNT;
	log_inserted := log_inserted+log_updated;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_ce_products_scd',
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
		'load_ce_products_scd',
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