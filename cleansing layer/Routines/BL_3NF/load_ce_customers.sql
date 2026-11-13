--Each procedure begins by creating a temporary table that gathers the required data from the source systems and transforms 
--it into the format required for loading into the target tables. 
--For SCD Type 1 tables, the procedure first checks whether
--the temporary table contains records with the same source identifier triplet (source_system, source_entity, source_id) but
--different attribute values. If such records are found, the existing rows are updated. Afterward, any new records that do
--not already exist in the target table are inserted. 

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_customers()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
BEGIN

	-- Gather data from source	--
	CREATE TEMP TABLE tmp_customers
	ON COMMIT DROP AS
	WITH raw_customer_names AS (
		SELECT 
			TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.customer_id  )) AS src_id,
			string_to_array(sa_grocery_instore_sales.src_source2_offline.customer_full_name,' ') AS name_arr
		FROM sa_grocery_instore_sales.src_source2_offline
		WHERE sa_grocery_instore_sales.src_source2_offline.customer_full_name IS NOT NULL 
	),formalized_customer_names AS (
		SELECT src_id,
			name_arr[1] AS src_f_name,
			CASE 
				WHEN array_length (name_arr,1)<=2 THEN 'n.a.'
				ELSE name_arr[2] 
			END src_m_initial,
			CASE 
				WHEN array_length (name_arr,1)=3 THEN name_arr[3]
				WHEN array_length (name_arr,1)=2 THEN name_arr[2]
				ELSE 'n.a.' 
			END src_l_name
		FROM raw_customer_names
	),src_offline AS (
		SELECT 
			'sa_grocery_instore_sales' AS src_system,
			'src_source2_offline' AS src_entity
	),
	src_online AS (
		SELECT 
			'sa_grocery_online_sales' AS src_system,
			'src_source1_online' AS src_entity
	)
		SELECT 
			COALESCE (TRIM(LOWER(formalized_customer_names.src_f_name)),'n.a.') AS src_first_name,
			COALESCE (TRIM(LOWER(formalized_customer_names.src_m_initial)),'n.a.') AS src_middle_initial,
			COALESCE (TRIM(LOWER(formalized_customer_names.src_l_name)),'n.a.') AS src_last_name,
			'n.a.' AS src_email,
			'1900-01-01 00:00'::DATE AS src_r_dt,
			'1900-01-01 00:00'::DATE AS src_fs_dt,
			COALESCE (TRIM(sa_grocery_instore_sales.src_source2_offline.customer_phonenumber),'n.a.') AS src_ph_number,
			COALESCE (sa_grocery_instore_sales.src_source2_offline.customer_birth_dt::DATE, '1900-01-01'::DATE)AS src_b_dt,
			COALESCE (bl_3nf.ce_addresses.address_id,-1) AS src_add, 
			src_offline.src_system,
			src_offline.src_entity,
			TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.customer_id  )) AS src_id,
			ROW_NUMBER()OVER(PARTITION BY TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.customer_id  ))
				ORDER BY sa_grocery_instore_sales.src_source2_offline.sales_dt::TIMESTAMPTZ DESC 
			) AS rn 
		FROM sa_grocery_instore_sales.src_source2_offline 
		LEFT JOIN formalized_customer_names ON 
			TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.customer_id))=formalized_customer_names.src_id
		CROSS JOIN src_offline
		LEFT JOIN bl_3nf.ce_addresses ON bl_3nf.ce_addresses.source_system=src_offline.src_system AND 
			bl_3nf.ce_addresses.source_entity=src_offline.src_entity AND 
			bl_3nf.ce_addresses.address_src_id=TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.customer_address))
		WHERE sa_grocery_instore_sales.src_source2_offline.customer_id IS NOT NULL AND
			sa_grocery_instore_sales.src_source2_offline.sales_dt IS NOT NULL
		UNION ALL
		SELECT 
			COALESCE (TRIM(LOWER(sa_grocery_online_sales.src_source1_online.customer_first_name )),'n.a.') AS src_first_name,
			COALESCE (TRIM(LOWER(sa_grocery_online_sales.src_source1_online.customer_middle_initial )),'n.a.')  AS src_middle_initial,
			COALESCE (TRIM(LOWER(sa_grocery_online_sales.src_source1_online.customer_last_name )),'n.a.') AS src_last_name,
			COALESCE (TRIM(LOWER(sa_grocery_online_sales.src_source1_online.email )),'n.a.') AS src_email,
			COALESCE (sa_grocery_online_sales.src_source1_online.registration_dt ::DATE,'1900-01-01'::DATE) AS  src_r_dt,
			COALESCE (sa_grocery_online_sales.src_source1_online.first_sale_dt ::DATE,'1900-01-01'::DATE)AS src_fs_dt,
			'n.a.' AS src_ph_number,
			'1900-01-01'::DATE AS src_b_dt,
			-1 AS src_add,
			src_online.src_system ,
			src_online.src_entity,
			TRIM(LOWER(sa_grocery_online_sales.src_source1_online.customer_id ))AS src_id,
			ROW_NUMBER()OVER(PARTITION BY TRIM(LOWER(sa_grocery_online_sales.src_source1_online.customer_id ))
				ORDER BY sa_grocery_online_sales.src_source1_online.sales_dt::TIMESTAMPTZ DESC
			) AS rn 
		FROM sa_grocery_online_sales.src_source1_online   
		CROSS JOIN src_online
		WHERE sa_grocery_online_sales.src_source1_online.customer_id IS NOT NULL AND 
			sa_grocery_online_sales.src_source1_online.sales_dt IS NOT NULL;

    -- UPDATE	--
	UPDATE 	bl_3nf.ce_customers
	SET customer_first_name = tmp_customers.src_first_name,
		customer_middle_initital =tmp_customers.src_middle_initial,
		customer_last_name =tmp_customers. src_last_name,	
		email =tmp_customers.src_email,	
		registration_dt =tmp_customers.src_r_dt,	
		first_sale_dt =tmp_customers.src_fs_dt,	
		customer_phone_number =tmp_customers.src_ph_number,
		customer_birth_dt =tmp_customers.src_b_dt,
		customer_address_id=tmp_customers.src_add,
		ta_update_dt=current_timestamp ::TIMESTAMPTZ
	FROM tmp_customers
	WHERE tmp_customers.rn=1 AND 
			tmp_customers.src_system=bl_3nf.ce_customers.source_system AND 
			tmp_customers.src_entity=bl_3nf.ce_customers.source_entity AND 
			tmp_customers.src_id=bl_3nf.ce_customers.customer_src_id AND 
			(
				customer_first_name <> tmp_customers.src_first_name or 
				customer_middle_initital <>tmp_customers.src_middle_initial or 
				customer_last_name <>tmp_customers. src_last_name or 	
				email <>tmp_customers.src_email or 	
				registration_dt <>tmp_customers.src_r_dt or 	
				first_sale_dt <>tmp_customers.src_fs_dt or 	
				customer_phone_number <>tmp_customers.src_ph_number or 
				customer_birth_dt <>tmp_customers.src_b_dt or 
				customer_address_id<>tmp_customers.src_add		
			);

	GET DIAGNOSTICS log_updated = ROW_COUNT;

	-- INSERT 
	INSERT INTO bl_3nf.ce_customers
	SELECT 
		NEXTVAL('bl_3nf.sqc_customers'),
		src_first_name,
		src_middle_initial,
		src_last_name,
		src_email,
		src_r_dt,
		src_fs_dt,
		src_ph_number,
		src_b_dt,
		src_add,
		src_system,
		src_entity,
		src_id,
		current_timestamp ::TIMESTAMPTZ,
		current_timestamp ::TIMESTAMPTZ
	FROM tmp_customers
	WHERE rn=1 AND
		NOT EXISTS (
			SELECT 1 
			FROM bl_3nf.ce_customers
			WHERE bl_3nf.ce_customers.source_system=src_system AND 
				bl_3nf.ce_customers.source_entity=src_entity AND 
				bl_3nf.ce_customers.customer_src_id=src_id
	);

	GET DIAGNOSTICS log_inserted = ROW_COUNT;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_ce_customers',
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
		'load_ce_customers',
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