--Each procedure begins by creating a temporary table that gathers the required data from the source systems and transforms 
--it into the format required for loading into the target tables. 
-- SCD Type 0 tables do not require update logic, as their data remains unchanged.

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_product_subcategories()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
BEGIN

	-- Gather data from source	--
	CREATE TEMP TABLE tmp_product_subcategories
	ON COMMIT DROP AS
	WITH src_instore AS (
		SELECT 
		'sa_grocery_instore_sales' AS src_system,
		'src_source2_offline' AS src_entity
	), src_online AS (
		SELECT 
		'sa_grocery_online_sales' AS src_system,
		'src_source1_online' AS src_entity
	)
		SELECT 
			COALESCE (TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.subcategory_name)),'n.a.') AS c_name,
			COALESCE (bl_3nf.ce_product_categories.product_category_id,-1) AS c_id,
			src_instore.src_system,
			src_instore.src_entity,
			TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.subcategory_name)) AS src_id,
			ROW_NUMBER() OVER (PARTITION BY TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.subcategory_name))
			ORDER BY sa_grocery_instore_sales.src_source2_offline.sales_dt::TIMESTAMPTZ DESC ) AS rn
		FROM sa_grocery_instore_sales.src_source2_offline 
		CROSS JOIN src_instore
		LEFT JOIN bl_3nf.ce_product_categories ON 
			bl_3nf.ce_product_categories.product_category_src_id=TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.category_id)) AND 
			bl_3nf.ce_product_categories.source_system=src_instore.src_system AND 
			bl_3nf.ce_product_categories.source_entity=src_instore.src_entity 
		WHERE sa_grocery_instore_sales.src_source2_offline.subcategory_name IS NOT NULL AND
			sa_grocery_instore_sales.src_source2_offline.sales_dt IS NOT NULL
		UNION ALL 
		SELECT 
			COALESCE (TRIM(LOWER(sa_grocery_online_sales.src_source1_online.subcategory_name)),'n.a.') AS c_name,
			COALESCE (bl_3nf.ce_product_categories.product_category_id,-1) AS c_id,
			src_online.src_system,
			src_online.src_entity,
			TRIM(LOWER(sa_grocery_online_sales.src_source1_online.subcategory_name)) AS src_id,
			ROW_NUMBER() OVER (PARTITION BY TRIM(LOWER(sa_grocery_online_sales.src_source1_online.subcategory_name))
			ORDER BY sa_grocery_online_sales.src_source1_online.sales_dt::TIMESTAMPTZ DESC ) AS rn
		FROM sa_grocery_online_sales.src_source1_online 	
		CROSS JOIN src_online
		LEFT JOIN bl_3nf.ce_product_categories ON 
			bl_3nf.ce_product_categories.product_category_src_id=TRIM(LOWER(sa_grocery_online_sales.src_source1_online.category_id)) AND 
			bl_3nf.ce_product_categories.source_system=src_online.src_system AND 
			bl_3nf.ce_product_categories.source_entity=src_online.src_entity 
		WHERE sa_grocery_online_sales.src_source1_online.subcategory_name IS NOT NULL AND
			sa_grocery_online_sales.src_source1_online.sales_dt IS NOT NULL;


	-- INSERT 
	INSERT INTO bl_3nf.ce_product_subcategories (
		product_subcategory_id,
		product_subcategory_name,
		product_category_id,
		source_system,
		source_entity,
		product_subcategory_src_id,
		ta_insert_dt,
		ta_update_dt
	)
	SELECT nextval('bl_3nf.sqc_product_subcategories'),
		c_name,
		c_id,
		src_system,
		src_entity,
		src_id,
		current_timestamp ::TIMESTAMPTZ,
		current_timestamp ::TIMESTAMPTZ
	FROM tmp_product_subcategories
	WHERE rn=1 AND 
		NOT EXISTS (
		SELECT 1 
		FROM bl_3nf.ce_product_subcategories
		WHERE bl_3nf.ce_product_subcategories.source_system =TRIM(LOWER(src_system)) AND 
			bl_3nf.ce_product_subcategories.source_entity =TRIM(LOWER(src_entity)) AND 
			bl_3nf.ce_product_subcategories.product_subcategory_src_id =TRIM(LOWER(src_id))
	);

	GET DIAGNOSTICS log_inserted = ROW_COUNT;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_ce_product_subcategories',
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
		'load_ce_product_subcategories',
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