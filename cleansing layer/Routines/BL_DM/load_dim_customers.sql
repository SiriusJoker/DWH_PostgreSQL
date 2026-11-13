-- procedure for loading dimension table customers uses merge and count rows:
CREATE OR REPLACE PROCEDURE bl_cl.load_dim_customers()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

	log_affected bigint := 0;
	log_inserted bigint := 0;
	log_updated bigint := 0;
	count_before bigint := 0;
	count_after bigint := 0;
BEGIN

count_before:=bl_cl.count_table_rows('bl_dm','dim_customers');

MERGE INTO bl_dm.dim_customers 
	-- Gather data from source	--
USING (
	SELECT 
	bl_3nf.ce_customers.customer_first_name AS src_first_name,
	bl_3nf.ce_customers.customer_middle_initital AS src_initial,
	bl_3nf.ce_customers.customer_last_name AS src_last_name,
	bl_3nf.ce_customers.email AS src_email,
	bl_3nf.ce_customers.registration_dt AS src_reg_dt,
	bl_3nf.ce_customers.first_sale_dt AS src_sale_dt,
	bl_3nf.ce_customers.customer_phone_number AS src_ph_number,
	bl_3nf.ce_customers.customer_birth_dt AS src_b_dt,
	bl_3nf.ce_addresses.address_id AS src_add_id,
	bl_3nf.ce_addresses.address AS src_add,
	bl_3nf.ce_cities.city_id AS src_c_id,
	bl_3nf.ce_cities.city_name AS src_c_name,
	bl_3nf.ce_cities.zipcode AS src_zipcode,
	'bl_3nf' AS src_system,
	'ce_customers' AS src_entity,
	bl_3nf.ce_customers.customer_id::varchar(1000) AS src_id
	FROM bl_3nf.ce_customers 
	INNER JOIN bl_3nf.ce_addresses ON bl_3nf.ce_addresses.address_id =bl_3nf.ce_customers.customer_address_id 
	INNER JOIN bl_3nf.ce_cities ON bl_3nf.ce_cities.city_id =bl_3nf.ce_addresses.city_id 
	where bl_3nf.ce_customers.customer_id <> -1
) AS tmp_customers

ON
(
    bl_dm.dim_customers.source_system = tmp_customers.src_system
    AND bl_dm.dim_customers.source_entity = tmp_customers.src_entity
    AND bl_dm.dim_customers.customer_src_id = tmp_customers.src_id
)
    -- UPDATE	--
WHEN MATCHED AND
(
	 bl_dm.dim_customers.customer_first_name  <> tmp_customers.src_first_name OR
	 bl_dm.dim_customers.customer_middle_initital  <> tmp_customers.src_initial OR
	 bl_dm.dim_customers.customer_last_name  <> tmp_customers.src_last_name OR
	 bl_dm.dim_customers.email  <> tmp_customers.src_email OR
	 bl_dm.dim_customers.registration_dt  <> tmp_customers.src_reg_dt OR
	 bl_dm.dim_customers.first_sale_dt  <> tmp_customers.src_sale_dt OR
	 bl_dm.dim_customers.customer_phone_number  <> tmp_customers.src_ph_number OR
	 bl_dm.dim_customers.customer_birth_dt  <> tmp_customers.src_b_dt OR
	 bl_dm.dim_customers.customer_address_id  <> tmp_customers.src_add_id OR
	 bl_dm.dim_customers.customer_address  <> tmp_customers.src_add OR
	 bl_dm.dim_customers.city_id  <> tmp_customers.src_c_id OR
	 bl_dm.dim_customers.city_name  <> tmp_customers.src_c_name OR
	 bl_dm.dim_customers.zipcode  <> tmp_customers.src_zipcode
)
THEN UPDATE
SET  customer_first_name  = tmp_customers.src_first_name,
	 customer_middle_initital  = tmp_customers.src_initial,
	 customer_last_name  = tmp_customers.src_last_name,
	 email  = tmp_customers.src_email,
	 registration_dt  = tmp_customers.src_reg_dt,
	 first_sale_dt  = tmp_customers.src_sale_dt,
	 customer_phone_number  = tmp_customers.src_ph_number,
	 customer_birth_dt  = tmp_customers.src_b_dt,
	 customer_address_id  = tmp_customers.src_add_id,
	 customer_address  = tmp_customers.src_add,
	 city_id  = tmp_customers.src_c_id,
	 city_name  = tmp_customers.src_c_name,
	 zipcode  = tmp_customers.src_zipcode,
	 ta_update_dt = current_timestamp ::TIMESTAMPTZ

	-- INSERT 
WHEN NOT MATCHED THEN

	INSERT 
	(
		customer_first_name ,
		customer_middle_initital ,
		customer_last_name ,
		email ,
		registration_dt ,
		first_sale_dt ,
		customer_phone_number ,
		customer_birth_dt ,
		customer_address_id ,
		customer_address ,
		city_id ,
		city_name,
		zipcode ,
		source_system ,
		source_entity ,
		customer_src_id,
		ta_insert_dt ,
		ta_update_dt 
	)
	VALUES( src_first_name,
	src_initial,
	src_last_name,
	src_email,
	src_reg_dt,
	src_sale_dt,
	src_ph_number,
	src_b_dt,
	src_add_id,
	src_add,
	src_c_id,
	src_c_name,
	src_zipcode,
	src_system,
	src_entity,
	src_id,
	current_timestamp ::TIMESTAMPTZ,
	current_timestamp ::TIMESTAMPTZ
	);	

	GET DIAGNOSTICS log_affected = ROW_COUNT;

	count_after:=bl_cl.count_table_rows('bl_dm','dim_customers');
	log_inserted:=count_after-count_before;
	log_updated:=log_affected-log_inserted;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_dim_customers',
		log_affected,
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
		'load_dim_customers',
		log_affected,
		log_updated,
		log_inserted,
		'FAILED',
		SQLERRM,
		log_start_time,
		log_end_time
    );

END;
$$;