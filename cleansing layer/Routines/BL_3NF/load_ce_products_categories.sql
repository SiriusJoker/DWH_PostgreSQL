--procedure begins by creating a temporary table that gathers the required data from the source systems and transforms 
--it into the format required for loading into the target tables. 
--For SCD Type 1 tables, the procedure first checks whether
--the temporary table contains records with the same source identifier triplet (source_system, source_entity, source_id) but
--different attribute values. If such records are found, the existing rows are updated. Afterward, any new records that do
--not already exist in the target table are inserted. 

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_products_categories()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
BEGIN

	-- Gather data from source	--
	CREATE TEMP TABLE tmp_products_subcategories
	ON COMMIT DROP AS
	SELECT 
		COALESCE (TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.category_name)),'n.a.') AS c_name,
		'sa_grocery_instore_sales' AS src_system,
		'src_source2_offline' AS src_entity,
		TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.category_id)) AS src_id,
		ROW_NUMBER() OVER (PARTITION BY TRIM(LOWER(category_id))
		ORDER BY sa_grocery_instore_sales.src_source2_offline.sales_dt::TIMESTAMPTZ DESC ) AS rn
	FROM sa_grocery_instore_sales.src_source2_offline 
	WHERE sa_grocery_instore_sales.src_source2_offline.category_id IS NOT NULL AND 
		sa_grocery_instore_sales.src_source2_offline.sales_dt IS NOT NULL
	UNION ALL
	SELECT 
		COALESCE (TRIM(LOWER(sa_grocery_online_sales.src_source1_online.category_name)),'n.a.') AS c_name,
		'sa_grocery_online_sales' AS src_system,
		'src_source1_online' AS src_entity,
		TRIM(LOWER(sa_grocery_online_sales.src_source1_online.category_id)) AS src_id,
		ROW_NUMBER() OVER (PARTITION BY TRIM(LOWER(category_id))
		ORDER BY sa_grocery_online_sales.src_source1_online.sales_dt::TIMESTAMPTZ DESC ) AS rn
	FROM sa_grocery_online_sales.src_source1_online 
	WHERE sa_grocery_online_sales.src_source1_online.category_id IS NOT NULL AND
		sa_grocery_online_sales.src_source1_online.sales_dt IS NOT NULL;

    -- UPDATE	--

	UPDATE bl_3nf.ce_product_categories
	SET 
		product_category_name=c_name,
		ta_update_dt=current_timestamp ::TIMESTAMPTZ
	FROM tmp_products_subcategories
	WHERE tmp_products_subcategories.rn=1 AND 
			tmp_products_subcategories.src_system=bl_3nf.ce_product_categories.source_system AND 
			tmp_products_subcategories.src_entity=bl_3nf.ce_product_categories.source_entity AND 
			tmp_products_subcategories.src_id=bl_3nf.ce_product_categories.product_category_src_id AND 
			bl_3nf.ce_product_categories.product_category_name <> tmp_products_subcategories.c_name ;

	GET DIAGNOSTICS log_updated = ROW_COUNT;

	-- INSERT 
	INSERT INTO bl_3nf.ce_product_categories (
		product_category_id,
		product_category_name,
		source_system,
		source_entity,
		product_category_src_id,
		ta_insert_dt,
		ta_update_dt
	)
	SELECT nextval('bl_3nf.sqc_product_categories'),
		c_name,
		src_system,
		src_entity,
		src_id,
		current_timestamp ::TIMESTAMPTZ,
		current_timestamp ::TIMESTAMPTZ
	FROM tmp_products_subcategories
	WHERE rn=1 AND 
		NOT EXISTS (
		SELECT 1 
		FROM bl_3nf.ce_product_categories
		WHERE bl_3nf.ce_product_categories.source_system =tmp_products_subcategories.src_system AND 
			bl_3nf.ce_product_categories.source_entity =tmp_products_subcategories.src_entity AND 
			bl_3nf.ce_product_categories.product_category_src_id =tmp_products_subcategories.src_id
	);

	GET DIAGNOSTICS log_inserted = ROW_COUNT;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_ce_products_categories',
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
		'load_ce_products_categories',
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