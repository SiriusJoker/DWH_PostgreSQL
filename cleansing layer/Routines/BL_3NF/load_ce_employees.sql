--procedure begins by creating a temporary table that gathers the required data from the source systems and transforms 
--it into the format required for loading into the target tables. 
--For SCD Type 1 tables, the procedure first checks whether
--the temporary table contains records with the same source identifier triplet (source_system, source_entity, source_id) but
--different attribute values. If such records are found, the existing rows are updated. Afterward, any new records that do
--not already exist in the target table are inserted. 

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_employees()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
BEGIN

	-- Gather data from source	--
	CREATE TEMP TABLE tmp_employees
	ON COMMIT DROP AS
	WITH source_offline AS (
	SELECT 
		'sa_grocery_instore_sales' AS src_system,
		'src_source2_offline' AS src_entity
	)
		SELECT 
			COALESCE (TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.employee_first_name)),'n.a.') AS src_f_name,
			COALESCE (TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.employee_middle_initial)),'n.a.') AS src_m_initial,
			COALESCE (TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.employee_last_name )),'n.a.') AS src_l_name,
			COALESCE (sa_grocery_instore_sales.src_source2_offline.birth_date::DATE , '1900-01-01'::DATE) AS src_b_dt,
			COALESCE (TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.gender)),'n.a.') AS src_gender,
			COALESCE (sa_grocery_instore_sales.src_source2_offline.hire_dt::DATE , '1900-01-01'::DATE) AS src_h_dt,
			COALESCE (TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.employee_skill_level)),'n.a.') AS src_skill,
			COALESCE (bl_3nf.ce_stores.store_id,-1) AS src_st_id,
			source_offline.src_system,
			source_offline.src_entity,
			TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.sales_person_id)) AS src_id,
			ROW_NUMBER()OVER(PARTITION BY TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.sales_person_id))
				ORDER BY sa_grocery_instore_sales.src_source2_offline.sales_dt::TIMESTAMPTZ DESC 
			) AS rn 
		FROM sa_grocery_instore_sales.src_source2_offline   
		CROSS JOIN source_offline
		LEFT JOIN bl_3nf.ce_stores ON bl_3nf.ce_stores.source_system=source_offline.src_system AND 
			bl_3nf.ce_stores.source_entity=source_offline.src_entity AND 
			bl_3nf.ce_stores.store_src_id=TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.store_id))
		WHERE sa_grocery_instore_sales.src_source2_offline.sales_person_id IS NOT NULL AND
			sa_grocery_instore_sales.src_source2_offline.sales_dt IS NOT NULL
		;

    -- UPDATE	--
	UPDATE bl_3nf.ce_employees
	SET 
		employee_first_name = tmp_employees.src_f_name,
		employee_middle_initial = tmp_employees.src_m_initial,
		employee_last_name = tmp_employees.src_l_name,
		birth_dt = tmp_employees.src_b_dt,
		gender = tmp_employees.src_gender,
		hire_dt = tmp_employees.src_h_dt,
		employee_skill_level = tmp_employees.src_skill,
		store_id = src_st_id,
		ta_update_dt=current_timestamp ::TIMESTAMPTZ
	FROM tmp_employees
	WHERE tmp_employees.rn=1 AND 
				bl_3nf.ce_employees.source_system =tmp_employees.src_system AND 
				bl_3nf.ce_employees.source_entity =tmp_employees.src_entity AND 
				bl_3nf.ce_employees.employee_src_id =tmp_employees.src_id AND 
				(
						bl_3nf.ce_employees.employee_first_name <> tmp_employees.src_f_name or
						bl_3nf.ce_employees.employee_middle_initial <> tmp_employees.src_m_initial or
						bl_3nf.ce_employees.employee_last_name <> tmp_employees.src_l_name or
						bl_3nf.ce_employees.birth_dt <> tmp_employees.src_b_dt or
						bl_3nf.ce_employees.gender <> tmp_employees.src_gender or
						bl_3nf.ce_employees.hire_dt <> tmp_employees.src_h_dt or
						bl_3nf.ce_employees.employee_skill_level <> tmp_employees.src_skill or 
						bl_3nf.ce_employees.store_id <> tmp_employees.src_st_id
				);

	GET DIAGNOSTICS log_updated = ROW_COUNT;

	-- INSERT 
	INSERT INTO bl_3nf.ce_employees(
		employee_id,
		employee_first_name,
		employee_middle_initial,
		employee_last_name,
		birth_dt,
		gender,
		hire_dt,
		employee_skill_level,
		store_id,
		source_system,
		source_entity,
		employee_src_id,
		ta_insert_dt,
		ta_update_dt
	)
	SELECT 
		NEXTVAL('bl_3nf.sqc_employees'),
		src_f_name,
		src_m_initial,
		src_l_name,
		src_b_dt,
		src_gender,
		src_h_dt,
		src_skill,
		src_st_id,
		src_system,
		src_entity,
		src_id,
		current_timestamp ::TIMESTAMPTZ,
		current_timestamp ::TIMESTAMPTZ
	FROM tmp_employees
	WHERE rn=1 AND 
		NOT EXISTS (
			SELECT 1
			FROM bl_3nf.ce_employees
			WHERE bl_3nf.ce_employees.source_system=src_system AND 
				bl_3nf.ce_employees.source_entity=src_entity AND 
				bl_3nf.ce_employees.employee_src_id=src_id
		);

	GET DIAGNOSTICS log_inserted = ROW_COUNT;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_ce_employees',
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
		'load_ce_employees',
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