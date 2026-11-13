-- procedure for loading dimension table employees uses update + insert:
CREATE OR REPLACE PROCEDURE bl_cl.load_dim_employees()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
BEGIN

	-- Gather data from source	--
	CREATE TEMP TABLE tmp_dim_employees
	ON COMMIT DROP AS
	SELECT 
	bl_3nf.ce_employees.employee_first_name AS src_f_name,
	bl_3nf.ce_employees.employee_middle_initial AS src_initial,
	bl_3nf.ce_employees.employee_last_name AS src_l_name,
	bl_3nf.ce_employees.birth_dt AS src_b_dt,
	bl_3nf.ce_employees.gender AS src_gender,
	bl_3nf.ce_employees.hire_dt AS src_h_dt,
	bl_3nf.ce_employees.employee_skill_level AS src_level,
	coalesce(bl_3nf.ce_stores.store_code,'n.a.') AS src_s_code,
	'bl_3nf' AS src_system,
	'ce_employees' AS src_entity,
	bl_3nf.ce_employees.employee_id::varchar(1000) AS src_id
	FROM bl_3nf.ce_employees
	LEFT JOIN bl_3nf.ce_stores ON bl_3nf.ce_employees.store_id =bl_3nf.ce_stores.store_id 
	WHERE bl_3nf.ce_employees.employee_id <> -1;

    -- UPDATE	--
	UPDATE bl_dm.dim_employees 
	SET employee_first_name = src_f_name,
	employee_middle_initial = src_initial,
	employee_last_name = src_l_name,
	birth_dt = src_b_dt,
	gender = src_gender,
	hire_dt = src_h_dt,
	employee_skill_level = src_level,
	store_code = src_s_code,
	ta_update_dt = current_timestamp::timestamptz
	FROM tmp_dim_employees
	WHERE source_system = src_system AND 
	source_entity = src_entity AND 
	employee_src_id = src_id AND 
	(
	employee_first_name <> src_f_name or
	employee_middle_initial <> src_initial or
	employee_last_name <> src_l_name or
	birth_dt <> src_b_dt or
	gender <> src_gender or
	hire_dt <> src_h_dt or
	employee_skill_level <> src_level or
	store_code <> src_s_code
	);


	GET DIAGNOSTICS log_updated = ROW_COUNT;

	-- INSERT 

	INSERT INTO bl_dm.dim_employees 
	(
		employee_first_name ,
		employee_middle_initial ,
		employee_last_name ,
		birth_dt ,
		gender ,
		hire_dt ,
		employee_skill_level ,
		store_code,
		source_system ,
		source_entity ,
		employee_src_id,
		ta_insert_dt ,
		ta_update_dt 
	)
	SELECT 
	src_f_name,
	src_initial,
	src_l_name,
	src_b_dt,
	src_gender,
	src_h_dt,
	src_level,
	src_s_code,
	src_system,
	src_entity,
	src_id,
	current_timestamp::timestamptz,
	current_timestamp::timestamptz
	FROM tmp_dim_employees
	WHERE NOT EXISTS (
	SELECT 1 
	FROM bl_dm.dim_employees 
	WHERE source_system = src_system AND 
	source_entity = src_entity AND 
	employee_src_id = src_id
	);

	GET DIAGNOSTICS log_inserted = ROW_COUNT;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_dim_employees',
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
		'load_dim_employees',
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