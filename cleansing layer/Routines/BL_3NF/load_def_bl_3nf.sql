--This script createc procedure that load default values to bl_3nf schema

CREATE OR REPLACE PROCEDURE bl_cl.load_def_bl_3nf()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
	affected_rows bigint := 0;
BEGIN

	INSERT INTO bl_3nf.ce_product_categories (
		product_category_id,
		product_category_name,
		source_system,
		source_entity,
		product_category_src_id,
		ta_insert_dt,
		ta_update_dt
	)
	VALUES (
		-1,
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
	VALUES (-1,
		'n.a.',
		-1,
		'MANUAL',
		'MANUAL',
		'n.a.',
		'1900-01-01 00:00 '::timestamptz,
		'1900-01-01 00:00 '::timestamptz
		)
	ON CONFLICT DO NOTHING;
	
    GET DIAGNOSTICS affected_rows = ROW_COUNT;
	log_inserted := log_inserted + affected_rows;
	
	INSERT INTO bl_3nf.ce_suppliers(
		supplier_id,
		supplier_name,	
		supplier_rating,	
		contract_start_dt,	
		source_system,	
		source_entity,	
		supplier_src_id,	
		ta_insert_dt,	
		ta_update_dt
	)
	VALUES (-1,
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
	
	INSERT INTO bl_3nf.ce_cities
	VALUES (-1,
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

	INSERT INTO bl_3nf.ce_addresses
	VALUES (-1,
		'n.a.',
		-1,
		'MANUAL',
		'MANUAL',
		'n.a.',
		'1900-01-01 00:00 '::timestamptz,
		'1900-01-01 00:00 '::timestamptz
	)
	ON CONFLICT DO NOTHING;

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
	log_inserted := log_inserted + affected_rows;
	
	INSERT INTO bl_3nf.ce_deliveries
	VALUES (
		-1,
		-1,
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
	
	INSERT INTO bl_3nf.ce_warehouses(
		warehouse_id,	
		warehouse_city_id,	
		warehouse_name,	
		capacity,	
		operating_cost,	
		manager_name,	
		warehouse_load_factor,	
		source_system,	
		source_entity,	
		warehouse_src_id,	
		ta_insert_dt,	
		ta_update_dt
		)
	VALUES (-1,
		-1,
		'n.a.',
		-1,
		-1,
		'n.a.',
		-1,
		'MANUAL',
		'MANUAL',
		'n.a.',
		'1900-01-01 00:00 '::timestamptz,
		'1900-01-01 00:00 '::timestamptz
		)
	ON CONFLICT DO NOTHING;	

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
	log_inserted := log_inserted + affected_rows;
	
	INSERT INTO bl_3nf.ce_customers(
		customer_id,	
		customer_first_name,	
		customer_middle_initital,	
		customer_last_name,	
		email,	
		registration_dt,	
		first_sale_dt,	
		customer_phone_number,	
		customer_birth_dt,	
		customer_address_id,	
		source_system,	
		source_entity,	
		customer_src_id,	
		ta_insert_dt,	
		ta_update_dt
	)
	VALUES (-1,
		'n.a.',
		'n.a.',
		'n.a.',
		'n.a.',
		'1900-01-01'::date,
		'1900-01-01'::date,
		'n.a.',
		'1900-01-01'::date,
		-1,
		'MANUAL',
		'MANUAL',
		'n.a.',
		'1900-01-01 00:00 '::timestamptz,
		'1900-01-01 00:00 '::timestamptz
		)
	ON CONFLICT DO NOTHING;	

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
	log_inserted := log_inserted + affected_rows;
	
	INSERT INTO bl_3nf.ce_stores
	VALUES (-1,
		-1,
		-1,
		'MANUAL',
		'MANUAL',
		'n.a.',
		'1900-01-01 00:00 '::timestamptz,
		'1900-01-01 00:00 '::timestamptz
		)
	ON CONFLICT DO NOTHING;	

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
	log_inserted := log_inserted + affected_rows;	
		
	INSERT INTO bl_3nf.ce_employees
	VALUES (-1,		--	employee_id bigint PRIMARY KEY,
		'n.a.',		--	employee_first_name varchar(25) NOT NULL,
		'n.a.',		--	employee_middle_initial varchar(4) NOT NULL,
		'n.a.',		--	employee_last_name varchar(25) NOT NULL,
		'1900-01-01'::date,	--	birth_dt date NOT NULL,
		'n.a.',		--	gender varchar(4) NOT NULL,
		'1900-01-01'::date,	--	hire_dt date NOT NULL,
		'n.a.',		--	employee_skill_level varchar(10) NOT NULL,
		-1,			--	store_id bigint NOT NULL,
		'MANUAL',	--	source_system varchar(1000) NOT NULL,
		'MANUAL',	--	source_entity varchar(1000) NOT NULL,
		'n.a.',		--	employee_src_id varchar(1000) NOT NULL,
		'1900-01-01 00:00 '::timestamptz,	--	ta_insert_dt timestamptz NOT NULL,
		'1900-01-01 00:00 '::timestamptz	--	ta_update_dt timestamptz NOT NULL,
		)
	ON CONFLICT DO NOTHING;		
	
    GET DIAGNOSTICS affected_rows = ROW_COUNT;
	log_inserted := log_inserted + affected_rows;

	INSERT INTO bl_3nf.ce_campaigns(
		campaign_id,
		campaign_name,
		source_system,
		source_entity,
		campaign_src_id,
		ta_insert_dt,
		ta_update_dt 
	)
	VALUES (-1,
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
	
	INSERT INTO bl_3nf.ce_promotions(
		promotion_id,
		promotion_name,
		channel,
		promotion_start_dt,
		promotion_end_dt,
		campaign_id,
		discount,
		source_system,
		source_entity,
		promotion_src_id,
		ta_insert_dt,
		ta_update_dt
	)
	VALUES (-1,
		'n.a.',
		'n.a.',
		'1900-01-01 00:00 '::timestamptz,
		'1900-01-01 00:00 '::timestamptz,
		-1,
		-1,
		'MANUAL',
		'MANUAL',
		'n.a.',
		'1900-01-01 00:00 '::timestamptz,
		'1900-01-01 00:00 '::timestamptz
		)
	ON CONFLICT DO NOTHING;	

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
	log_inserted := log_inserted + affected_rows;
	
	INSERT INTO bl_3nf.ce_products_scd
	VALUES (-1,
		'1900-01-01 00:00 '::timestamptz,
		'n.a.',
		'n.a.',
		-1,
		'n.a.',
		'1900-01-01 00:00 '::timestamptz,
		'n.a.',
		'n.a.',
		-1,
		-1,
		-1,
		'MANUAL',
		'MANUAL',
		'n.a.',
		'1900-01-01 00:00 '::timestamptz,
		'1900-01-01 00:00 '::timestamptz,
		'1999-01-01 00:00 '::timestamptz,
		'n.a'
		)
	ON CONFLICT DO NOTHING;	

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
	log_inserted := log_inserted + affected_rows;
	
	INSERT INTO bl_3nf.suppliers_products
	VALUES (
		-1,
		'1900-01-01 00:00 '::timestamptz,
		-1,
		'MANUAL',
		'MANUAL',
		'n.a.',
		'1900-01-01 00:00 '::timestamptz,
		'1900-01-01 00:00 '::timestamptz
	)
	ON CONFLICT DO NOTHING;

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
	log_inserted := log_inserted + affected_rows;
	
	INSERT INTO bl_3nf.warehouses_products
	VALUES (
		-1,
		'1900-01-01 00:00 '::timestamptz,
		-1,
		'MANUAL',
		'MANUAL',
		'n.a.',
		'1900-01-01 00:00 '::timestamptz,
		'1900-01-01 00:00 '::timestamptz
	)
	ON CONFLICT DO NOTHING;

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
	log_inserted := log_inserted + affected_rows;
	
	INSERT INTO bl_3nf.ce_sales
	VALUES (-1,		--	sale_id bigint PRIMARY KEY,	
		-1,			--	product_id bigint NOT NULL,
		'1900-01-01 00:00 '::timestamptz, 	--	product_start_dt timestamptz NOT NULL,
		-1,			--	customer_id bigint NOT NULL,
		-1,			--	promotion_id bigint NOT NULL,
		-1,			--	quantity int NOT NULL,
		'1900-01-01 00:00 '::timestamptz,	--	event_dt timestamptz NOT NULL,
		-1,			--	cost_tot numeric(13,6) NOT NULL,
		-1,			--	price_tot numeric(13,6) NOT NULL,
		-1,			--	profit numeric(13,6),
		-1,			--	margin_pct numeric(6,4),
		'n.a.',		--	payment_type varchar(10) NOT NULL,
		-1,			--	sales_person_id bigint NOT NULL,
		'n.a.',		--	checkout_type varchar(20) NOT NULL,
		'n.a.',		--	transaction_number varchar(20) NOT NULL,
		-1,			--	delivery_id bigint NOT NULL,
		'MANUAL',	--	source_system varchar(1000) NOT NULL,
		'MANUAL',	--	source_entity varchar(1000) NOT NULL,
		'n.a.',		--	sale_src_id varchar(1000) NOT NULL,
		'1900-01-01 00:00 '::timestamptz,	--	ta_insert_dt timestamptz NOT NULL,
		'1900-01-01 00:00 '::timestamptz	--	ta_update_dt timestamptz NOT NULL,
		)
	ON CONFLICT DO NOTHING;	

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
	log_inserted := log_inserted + affected_rows;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_def_bl_3nf',
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
		'load_def_bl_3nf',
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