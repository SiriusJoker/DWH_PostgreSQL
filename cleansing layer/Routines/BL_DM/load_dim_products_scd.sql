-- procedure for loading dimension table products uses update + insert:
CREATE OR REPLACE PROCEDURE bl_cl.load_dim_products_scd()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
	rows_affected bigint := 0;
BEGIN

	-- Gather data from source	--
	CREATE TEMP TABLE tmp_dim_products
	ON COMMIT DROP AS
	SELECT 
	Row_number() OVER 
	(PARTITION BY bl_3nf.ce_products_scd.product_id, bl_3nf.ce_product_categories.product_category_id, bl_3nf.ce_product_subcategories.product_subcategory_id 
	ORDER BY bl_3nf.ce_sales.event_dt) AS rn,
	bl_3nf.ce_sales.event_dt AS src_start_dt,
	bl_3nf.ce_products_scd.product_name AS src_pr_name,
	bl_3nf.ce_products_scd.product_code AS src_pr_code,
	bl_3nf.ce_products_scd."class" AS src_class,
	bl_3nf.ce_products_scd.modify_dt AS src_m_dt,
	bl_3nf.ce_products_scd.resistant AS src_resistant,
	bl_3nf.ce_products_scd.is_allergic AS src_allergic,
	bl_3nf.ce_products_scd.vitality_days AS src_v_days,
	COALESCE(bl_3nf.ce_product_subcategories.product_subcategory_id,-1) AS src_subcat_id,
	COALESCE(bl_3nf.ce_product_subcategories.product_subcategory_name,'n.a.') AS src_subcat_name,
	COALESCE(bl_3nf.ce_product_categories.product_category_id,-1) AS src_cat_id,
	COALESCE(bl_3nf.ce_product_categories.product_category_name,'n.a.') AS src_cat_name,
	'bl_3nf' AS src_system,
	'ce_products_scd' AS src_entity,
	bl_3nf.ce_products_scd.product_id::varchar(1000)AS src_id
	FROM bl_3nf.ce_products_scd 
	LEFT JOIN bl_3nf.ce_product_subcategories ON bl_3nf.ce_products_scd.product_subcategory_id = bl_3nf.ce_product_subcategories.product_subcategory_id
	LEFT JOIN bl_3nf.ce_product_categories ON bl_3nf.ce_product_categories.product_category_id =bl_3nf.ce_product_subcategories.product_category_id 
	LEFT JOIN bl_3nf.ce_sales ON bl_3nf.ce_sales.product_id =bl_3nf.ce_products_scd.product_id AND 
		bl_3nf.ce_sales.product_start_dt =bl_3nf.ce_products_scd.start_dt 
	WHERE bl_3nf.ce_products_scd.product_id <> -1 and bl_3nf.ce_products_scd.is_active='y';

    -- UPDATE	--
	WITH needs_update AS (
		SELECT tmp_dim_products.src_start_dt,
				tmp_dim_products.src_pr_name,
				tmp_dim_products.src_pr_code,
				tmp_dim_products.src_class ,
				tmp_dim_products.src_m_dt,
				tmp_dim_products.src_resistant ,
				tmp_dim_products.src_allergic ,
				tmp_dim_products.src_v_days ,
				tmp_dim_products.src_subcat_id,
				tmp_dim_products.src_subcat_name,
				tmp_dim_products.src_cat_id,
				tmp_dim_products.src_cat_name,
				tmp_dim_products.src_system,
				tmp_dim_products.src_entity,
				tmp_dim_products.src_id
		FROM tmp_dim_products
		INNER JOIN bl_dm.dim_products_scd ON bl_dm.dim_products_scd.source_system = tmp_dim_products.src_system AND 
		bl_dm.dim_products_scd.source_entity = tmp_dim_products.src_entity AND 
		bl_dm.dim_products_scd.product_src_id = tmp_dim_products.src_id AND 
		bl_dm.dim_products_scd.is_active='y'
		WHERE tmp_dim_products.rn=1 AND
		(
		product_name <> src_pr_name or
		product_code <> src_pr_code or
		"class" <> src_class or
		modify_dt <> src_m_dt or
		resistant <> src_resistant or
		is_allergic <> src_allergic or
		vitality_days <> src_v_days or
		product_subcategory_id <> src_subcat_id or
		product_subcategory_name <> src_subcat_name or
		product_category_id <> src_cat_id or
		product_category_name <> src_cat_name
		)
	), updates AS (
		UPDATE bl_dm.dim_products_scd 
		SET is_active = 'n',
			 end_dt = src_start_dt,
			 ta_update_dt=current_timestamp ::TIMESTAMPTZ
		FROM needs_update
		WHERE  needs_update.src_system=bl_dm.dim_products_scd.source_system AND 
					needs_update.src_entity=bl_dm.dim_products_scd.source_entity AND 
					needs_update.src_id=bl_dm.dim_products_scd.product_src_id AND 
					bl_dm.dim_products_scd.is_active ='y'
		)	
	INSERT INTO bl_dm.dim_products_scd
	(
		start_dt ,
		product_name ,
		product_code ,
		class ,
		modify_dt ,
		resistant ,
		is_allergic ,
		vitality_days ,
		product_subcategory_id ,
		product_subcategory_name,
		product_category_id ,
		product_category_name,
		source_system ,
		source_entity ,
		product_src_id ,
		ta_insert_dt ,
		ta_update_dt ,
		end_dt ,
		is_active 
	)
		SELECT 
		src_start_dt,
		src_pr_name,
		src_pr_code,
		src_class ,
		src_m_dt,
		src_resistant ,
		src_allergic ,
		src_v_days ,
		src_subcat_id,
		src_subcat_name,
		src_cat_id,
		src_cat_name,
		src_system,
		src_entity,
		src_id,
		current_timestamp ::TIMESTAMPTZ,
		current_timestamp ::TIMESTAMPTZ,
		'9999-12-31 00:00 '::timestamptz,
		'y'
	FROM needs_update;


	GET DIAGNOSTICS rows_affected = ROW_COUNT;
	log_updated := rows_affected;
	log_inserted := rows_affected;

	-- INSERT 
	INSERT INTO bl_dm.dim_products_scd
	(
		start_dt ,
		product_name ,
		product_code ,
		class ,
		modify_dt ,
		resistant ,
		is_allergic ,
		vitality_days ,
		product_subcategory_id ,
		product_subcategory_name,
		product_category_id ,
		product_category_name,
		source_system ,
		source_entity ,
		product_src_id ,
		ta_insert_dt ,
		ta_update_dt ,
		end_dt ,
		is_active 
	) 
	SELECT 	src_start_dt,
		src_pr_name,
		src_pr_code,
		src_class ,
		src_m_dt,
		src_resistant ,
		src_allergic ,
		src_v_days ,
		src_subcat_id,
		src_subcat_name,
		src_cat_id,
		src_cat_name,
		src_system,
		src_entity,
		src_id,
		current_timestamp ::TIMESTAMPTZ,
		current_timestamp ::TIMESTAMPTZ,
		'9999-12-31 00:00 '::timestamptz,
		'y'
	FROM tmp_dim_products
	WHERE rn=1 AND 
	NOT EXISTS (
	select 1
	from bl_dm.dim_products_scd
	where
	bl_dm.dim_products_scd.source_system=src_system AND 
	bl_dm.dim_products_scd.source_entity=src_entity AND
	bl_dm.dim_products_scd.product_src_id=src_id 
	)
	;

	GET DIAGNOSTICS rows_affected = ROW_COUNT;
	log_inserted := log_inserted+rows_affected;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_dim_products_scd',
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
		'load_dim_products_scd',
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