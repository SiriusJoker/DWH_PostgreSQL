--This script creates a procedure that loads default values in bl_dm schema

CREATE OR REPLACE PROCEDURE bl_cl.load_def_bl_dm()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
	affected_rows bigint := 0;
BEGIN

	INSERT INTO bl_dm.dim_addresses
	VALUES (
	-1,			--	address_surr_id bigint PRIMARY KEY ,
	'n.a.',		--	address varchar(1000) NOT NULL,
	-1,			--	city_id bigint NOT NULL,
	'n.a.',		-- city_name
	'n.a.',		-- zipcode
	'MANUAL',	--	source_system varchar(1000) NOT NULL,
	'MANUAL',	--	source_entity varchar(1000) NOT NULL,
	'n.a.',		--	address_src_id varchar(1000) NOT NULL,
	'1900-01-01 00:00 '::timestamptz,	--	ta_insert_dt timestamptz NOT NULL,
	'1900-01-01 00:00 '::timestamptz	--	ta_update_dt timestamptz NOT NULL
	)
	ON CONFLICT DO NOTHING;

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
	log_inserted := log_inserted + affected_rows;
	
	INSERT INTO bl_dm.dim_suppliers 
	VALUES (
		-1,
		'n.a.',
		-1,
		'1900-01-01 00:00 '::timestamptz,
		'MANUAL',
		'MANUAL',
		'n.a.',
		'1900-01-01 00:00 '::timestamptz,
		'1900-01-01 00:00 '::timestamptz
	)
	ON CONFLICT DO NOTHING;

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
	log_inserted := log_inserted + affected_rows;
	
	INSERT INTO bl_dm.dim_warehouses  
	VALUES (
		-1,
		'n.a.',
		-1,
		-1,
		'n.a.',
		-1,
		-1,
		'n.a.',
		'n.a.',
		'MANUAL',
		'MANUAL',
		'n.a.',
		'1900-01-01 00:00 '::timestamptz,
		'1900-01-01 00:00 '::timestamptz
	)
	ON CONFLICT DO NOTHING;

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
	log_inserted := log_inserted + affected_rows;
	
	INSERT INTO bl_dm.dim_customers 
	VALUES (
		-1,					--customer_surr_id
		'n.a.',				--customer_first_name
		'n.a.',				--customer_middle_initital
		'n.a.',				--customer_last_name
		'n.a.',				--email
		'1900-01-01'::date,	--registration_dt
		'1900-01-01'::date,	--first_sale_dt
		'n.a.',				--customer_phone_number
		'1900-01-01'::date,	--customer_birth_dt
		-1,					--customer_address_id
		'n.a.',				--customer_address
		-1,					--city_id
		'n.a.',				--city_name
		'n.a.',				--zipcode
		'MANUAL',			--source_system
		'MANUAL',			--source_entity
		'n.a.',				--customer_src_id
		'1900-01-01 00:00 '::timestamptz,	--ta_insert_dt
		'1900-01-01 00:00 '::timestamptz	--ta_update_dt
	)
	ON CONFLICT DO NOTHING ;

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
	log_inserted := log_inserted + affected_rows;
	
	INSERT INTO bl_dm.dim_stores
	VALUES (
		-1,
		'n.a.',
		-1,
		'n.a.',
		'n.a.',
		'MANUAL',
		'MANUAL',
		'n.a.',
		'1900-01-01 00:00 '::timestamptz,	--ta_insert_dt
		'1900-01-01 00:00 '::timestamptz	--ta_update_dt
	)
	ON CONFLICT DO NOTHING ;

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
	log_inserted := log_inserted + affected_rows;
	
	INSERT INTO bl_dm.dim_employees 
	VALUES (
		-1,			--	employee_surr_id bigint PRIMARY KEY DEFAULT nextval('bl_dm.sqc_dim_employees'),
		'n.a.',		--	employee_first_name varchar(25) NOT NULL,
		'n.a.',		--	employee_middle_initial varchar(4) NOT NULL,
		'n.a.',		--	employee_last_name varchar(25) NOT NULL,
		'1900-01-01'::date,	--	birth_dt date NOT NULL,
		'n.a.',		--	gender varchar(4) NOT NULL,
		'1900-01-01'::date,	--	hire_dt date NOT NULL,
		'n.a.',		--	employee_skill_level varchar(10) NOT NULL,
		'n.a.',		--	store_code varchar(1000) NOT NULL,
		'MANUAL',	--	source_system varchar(1000) NOT NULL,
		'MANUAL',	--	source_entity varchar(1000) NOT NULL,
		'n.a.',		--	employee_src_id varchar(1000) NOT NULL,
		'1900-01-01 00:00 '::timestamptz,	--	ta_insert_dt timestamptz NOT NULL,
		'1900-01-01 00:00 '::timestamptz	--	ta_update_dt timestamptz NOT NULL
	)
	ON CONFLICT DO NOTHING ;

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
	log_inserted := log_inserted + affected_rows;
	
	INSERT INTO bl_dm.dim_promotions 
	VALUES (
		-1,
		'n.a.',
		'n.a.',
		'1900-01-01 00:00 '::timestamptz,
		'1900-01-01 00:00 '::timestamptz,
		-1,
		-1,
		'n.a.',
		'MANUAL',
		'MANUAL',
		'n.a.',
		'1900-01-01 00:00 '::timestamptz,
		'1900-01-01 00:00 '::timestamptz
	)
	ON CONFLICT DO NOTHING ;

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
	log_inserted := log_inserted + affected_rows;
	
	INSERT INTO bl_dm.dim_products_scd 
	VALUES (
		-1,									--	product_surr_id
		'1900-01-01 00:00 '::timestamptz,	--	start_dt
		'n.a.',								--	product_name
		'n.a.',								--	product_code
		'n.a.',								--	class
		'1900-01-01 00:00 '::timestamptz,	--	modify_dt
		'n.a.',								--	resistant
		'n.a.',								--	is_allergic
		-1,									--	vitality_days
		-1,									--	product_subcategory_id
		'n.a.',								--	product_subcategory_name
		-1,									--	product_category_id
		'n.a.',								--	product_category_name
		'MANUAL',							--source_system
		'MANUAL',							--source_entity
		'n.a.',								--	product_src_id
		'1900-01-01 00:00 '::timestamptz,	--ta_insert_dt
		'1900-01-01 00:00 '::timestamptz,	--ta_update_dt
		'1999-12-31 00:00 '::timestamptz,	--end_dt
		'n'									--is_active
	)
	ON CONFLICT DO NOTHING;

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
	log_inserted := log_inserted + affected_rows;
	
	INSERT INTO bl_dm.bridge_suppliers_products
	VALUES (
	-1,									--	product_surr_id bigint NOT NULL,
	-1,									--	supplier_surr_id bigint NOT NULL,
	'MANUAL',							--	source_system varchar(1000) NOT NULL,
	'MANUAL',							--	source_entity varchar(1000) NOT NULL,
	'n.a.',								--	supplier_product_src_id varchar(1000) NOT NULL ,
	'1900-01-01 00:00 '::timestamptz,	--	ta_insert_dt timestamptz NOT NULL,
	'1900-01-01 00:00 '::timestamptz	--	ta_update_dt timestamptz NOT NULL,
	)
	ON CONFLICT DO NOTHING;

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
	log_inserted := log_inserted + affected_rows;
	
	INSERT INTO bl_dm.bridge_warehouses_products
	VALUES (
	-1,									--	product_surr_id bigint NOT NULL,
	-1,									--	warehouse_surr_id bigint NOT NULL,
	'MANUAL',							--	source_system varchar(1000) NOT NULL,
	'MANUAL',							--	source_entity varchar(1000) NOT NULL,
	'n.a.',								--	warehouse_product_src_id varchar(1000) NOT NULL ,
	'1900-01-01 00:00 '::timestamptz,	--	ta_insert_dt timestamptz NOT NULL,
	'1900-01-01 00:00 '::timestamptz	--	ta_update_dt timestamptz NOT NULL,
	)
	ON CONFLICT DO NOTHING;

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
	log_inserted := log_inserted + affected_rows;
	
	INSERT INTO bl_dm.dim_time_dd 
	VALUES (
		-1,
		'1900-01-01'::date,
		-1,
		-1,
		'n.a.',
		-1,
		-1,
		-1,
		'n.a',
		-1,
		-1,
		-1,
		-1
	)
	ON CONFLICT DO NOTHING ;

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
	log_inserted := log_inserted + affected_rows;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_def_bl_dm',
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
		'load_def_bl_dm',
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