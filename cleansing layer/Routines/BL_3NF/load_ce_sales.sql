-- This script contains procedures of initial and incremental load of prefact table ce_sales in bl_3nf 
CREATE OR REPLACE PROCEDURE bl_cl.load_ce_sales()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    rows_affected bigint := 0;
	log_updated bigint := 0;
    log_inserted bigint := 0;
BEGIN

	-- Gather data from offline source	--
	CREATE TEMP TABLE tmp_sales
	ON COMMIT DROP AS
	SELECT 
		COALESCE (bl_3nf.ce_products_scd.product_id,-1) AS src_prod_id,
		COALESCE (bl_3nf.ce_products_scd.start_dt,'1900-01-01 00:00 '::timestamptz) AS src_prod_dt,
		COALESCE (bl_3nf.ce_customers.customer_id,-1) AS src_cust_id,
		COALESCE (bl_3nf.ce_promotions.promotion_id,-1) AS src_promo_id,
		COALESCE (sa_grocery_instore_sales.src_source2_offline.quantity::INT,-1) AS src_q,
		COALESCE (sa_grocery_instore_sales.src_source2_offline.sales_dt::TIMESTAMPTZ,'1900-01-01 00:00 '::timestamptz) AS src_e_dt,
		COALESCE (sa_grocery_instore_sales.src_source2_offline.cost_tot::NUMERIC(13,6),-1) AS src_cost_tot,
		COALESCE (sa_grocery_instore_sales.src_source2_offline.price_tot::NUMERIC(13,6),-1) AS src_price_tot,
		COALESCE (sa_grocery_instore_sales.src_source2_offline.profit::NUMERIC(13,6),-1) AS src_profit,
		COALESCE (sa_grocery_instore_sales.src_source2_offline.margin_pct::NUMERIC(6,4),-1) AS src_margin,
		'n.a.' AS src_p_type,
		COALESCE (bl_3nf.ce_employees.employee_id,-1) AS src_emp_id, 
		COALESCE (TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.checkout_type)),'n.a.') AS src_checkout,
		COALESCE (TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.transaction_number)),'n.a.') AS src_tn,
		-1 AS src_d_id,
		'sa_grocery_instore_sales' AS src_system,
		'src_source2_offline' AS src_entity,
		TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.sales_id)) AS src_id
	FROM sa_grocery_instore_sales.src_source2_offline  
	LEFT JOIN bl_3nf.ce_products_scd ON bl_3nf.ce_products_scd.source_system ='sa_grocery_instore_sales' AND 
			bl_3nf.ce_products_scd.source_entity ='src_source2_offline' AND 
			bl_3nf.ce_products_scd.product_src_id=TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.product_id)) 
		AND bl_3nf.ce_products_scd.is_active='y'
	LEFT JOIN bl_3nf.ce_customers ON bl_3nf.ce_customers.source_system='sa_grocery_instore_sales' AND
			bl_3nf.ce_customers.source_entity ='src_source2_offline' AND 
			bl_3nf.ce_customers.customer_src_id=TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.customer_id))
	LEFT JOIN bl_3nf.ce_promotions ON bl_3nf.ce_promotions.source_system='sa_grocery_instore_sales' AND
			bl_3nf.ce_promotions.source_entity ='src_source2_offline' AND 
			bl_3nf.ce_promotions.promotion_src_id=TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.promotion_id))
	LEFT JOIN bl_3nf.ce_employees ON bl_3nf.ce_employees.source_system='sa_grocery_instore_sales' AND
			bl_3nf.ce_employees.source_entity ='src_source2_offline' AND 
			bl_3nf.ce_employees.employee_src_id=TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.sales_person_id))
	WHERE sa_grocery_instore_sales.src_source2_offline.sales_id IS NOT NULL AND 
		sa_grocery_instore_sales.src_source2_offline.sales_dt IS NOT NULL and 
		sa_grocery_instore_sales.src_source2_offline.processed_flag='n'
	UNION ALL
	SELECT 
		COALESCE (bl_3nf.ce_products_scd.product_id,-1)  AS src_prod_id,
		COALESCE (bl_3nf.ce_products_scd.start_dt,'1900-01-01 00:00 '::timestamptz) AS src_prod_dt,
		COALESCE (bl_3nf.ce_customers.customer_id,-1) AS src_cust_id,
		COALESCE(bl_3nf.ce_promotions.promotion_id,-1) AS src_promo_id,
		COALESCE(sa_grocery_online_sales.src_source1_online.quantity::INT,-1) AS src_q, 
		COALESCE(sa_grocery_online_sales.src_source1_online.sales_dt::TIMESTAMPTZ,'1900-01-01 00:00 '::timestamptz) AS src_e_dt,
		COALESCE(sa_grocery_online_sales.src_source1_online.cost_tot::NUMERIC(13,6),-1) AS src_cost_tot,
		COALESCE(sa_grocery_online_sales.src_source1_online.price_tot::NUMERIC(13,6),-1) AS src_price_tot,
		COALESCE (sa_grocery_online_sales.src_source1_online.profit::NUMERIC(13,6),-1) AS src_profit,
		COALESCE (sa_grocery_online_sales.src_source1_online.margin_pct::NUMERIC(6,4),-1) AS src_margin,
		COALESCE (TRIM(LOWER(sa_grocery_online_sales.src_source1_online.payment_type)),'n.a.') AS src_p_type,
		-1 AS src_emp_id,
		'n.a.' AS src_checkout,
		COALESCE (TRIM(LOWER(sa_grocery_online_sales.src_source1_online.transaction_number)),'n.a.') AS src_tn,
		COALESCE(bl_3nf.ce_deliveries.delivery_id,-1) AS src_d_id,
		'sa_grocery_online_sales' AS src_system ,
		'src_source1_online' AS src_entity ,
		TRIM(LOWER(sa_grocery_online_sales.src_source1_online.sales_id )) AS src_id
	FROM sa_grocery_online_sales.src_source1_online 
	LEFT JOIN bl_3nf.ce_products_scd ON bl_3nf.ce_products_scd.source_system ='sa_grocery_online_sales' AND 
		bl_3nf.ce_products_scd.source_entity ='src_source1_online' AND 
		bl_3nf.ce_products_scd.product_src_id =TRIM(LOWER(sa_grocery_online_sales.src_source1_online.product_id))
		AND bl_3nf.ce_products_scd.is_active='y'
	LEFT JOIN bl_3nf.ce_customers ON bl_3nf.ce_customers.source_system ='sa_grocery_online_sales' AND 
		bl_3nf.ce_customers.source_entity ='src_source1_online' AND 
		bl_3nf.ce_customers.customer_src_id = TRIM(LOWER(sa_grocery_online_sales.src_source1_online.customer_id))
	LEFT JOIN bl_3nf.ce_promotions ON bl_3nf.ce_promotions.source_system ='sa_grocery_online_sales' AND 
		bl_3nf.ce_promotions.source_entity='src_source1_online' AND 
		bl_3nf.ce_promotions.promotion_src_id =TRIM(LOWER(sa_grocery_online_sales.src_source1_online.promotion_id ))
	LEFT JOIN bl_3nf.ce_deliveries ON bl_3nf.ce_deliveries.source_system ='sa_grocery_online_sales' AND 
		bl_3nf.ce_deliveries.source_entity ='src_source1_online' AND 
		bl_3nf.ce_deliveries.delivery_src_id =TRIM(LOWER(sa_grocery_online_sales.src_source1_online.delivery_address)) ||'|'||
		(COALESCE(sa_grocery_online_sales.src_source1_online.shipping_cost::numeric(11,6),-1))::text ||'|'||
		COALESCE(sa_grocery_online_sales.src_source1_online.delivery_date::timestamptz, '1900-01-01 00:00 '::timestamptz)::text
	WHERE sa_grocery_online_sales.src_source1_online.sales_id IS NOT NULL AND 
		sa_grocery_online_sales.src_source1_online.sales_dt IS NOT NULL  and 
			sa_grocery_online_sales.src_source1_online.processed_flag = 'n'
	;
						
	-- INSERT 

	INSERT INTO bl_3nf.ce_sales
	SELECT 
		NEXTVAL('bl_3nf.sqc_sales'), 	--sale_id bigint PRIMARY KEY,	
		src_prod_id ,	--product_id bigint NOT NULL,
		src_prod_dt,	--product_start_dt timestamptz NOT NULL,
		src_cust_id ,	--customer_id bigint NOT NULL,
		src_promo_id ,	--promotion_id bigint NOT NULL,
		src_q ,			--quantity int NOT NULL,
		src_e_dt ,		--event_dt timestamptz NOT NULL,
		src_cost_tot ,	--cost_tot numeric(13,6) NOT NULL,
		src_price_tot ,	--price_tot numeric(13,6) NOT NULL,
		src_profit ,	--profit numeric(13,6),
		src_margin ,	--margin_pct numeric(6,4),
		src_p_type ,	--payment_type varchar(10) NOT NULL,
		src_emp_id ,	--sales_person_id bigint NOT NULL,
		src_checkout ,	--checkout_type varchar(20) NOT NULL,
		src_tn,			--transaction_number varchar(20) NOT NULL,
		src_d_id ,		--delivery_id bigint NOT NULL,
		src_system,		--source_system varchar(1000) NOT NULL,
		src_entity,		--source_entity varchar(1000) NOT NULL,
		src_id,			--sale_src_id varchar(1000) NOT NULL,
		current_timestamp ::TIMESTAMPTZ,	--ta_insert_dt timestamptz NOT NULL,
		current_timestamp ::TIMESTAMPTZ		--ta_update_dt timestamptz NOT NULL,
	FROM tmp_sales
	WHERE 
		NOT EXISTS (
		SELECT 1
		FROM bl_3nf.ce_sales
		WHERE bl_3nf.ce_sales.source_system=src_system AND 
			bl_3nf.ce_sales.source_entity=src_entity AND
			bl_3nf.ce_sales.sale_src_id=src_id
		);

	GET DIAGNOSTICS rows_affected = ROW_COUNT;
	log_inserted:=log_inserted+rows_affected;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_ce_sales',
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
		'load_ce_sales',
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