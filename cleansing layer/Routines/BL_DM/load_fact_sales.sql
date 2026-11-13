-- This script contains procedures of initial load of fact sale table in bl_dm

CREATE OR REPLACE PROCEDURE bl_cl.load_fact_sales()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
BEGIN

	-- Gather data from source	--
	CREATE TEMP TABLE tmp_fact_sales
	ON COMMIT DROP AS
	SELECT 
		COALESCE(bl_dm.dim_products_scd.product_surr_id,-1) as src_prod_id,
		COALESCE(bl_dm.dim_customers.customer_surr_id,-1) as src_cust_id,
		COALESCE(bl_dm.dim_promotions.promotion_surr_id,-1) as src_promo_id,
		bl_3nf.ce_sales.quantity as src_q,
		bl_3nf.ce_sales.event_dt as src_dt,
		to_char(bl_3nf.ce_sales.event_dt::date,'YYYYMMDD')::bigint AS src_time_id,
		bl_3nf.ce_products_scd.unit_price as src_u_price,
		bl_3nf.ce_products_scd.unit_cost as src_u_cost,
		COALESCE(bl_dm.dim_promotions.discount,-1) as src_d,
		bl_3nf.ce_sales.cost_tot as src_cost_tot,
		bl_3nf.ce_sales.price_tot as src_p_tot,
		COALESCE(bl_3nf.ce_sales.price_tot/NULLIF(bl_3nf.ce_sales.cost_tot,0),-1)::numeric(7,6) AS src_ratio,
		bl_3nf.ce_sales.profit as src_profit,
		bl_3nf.ce_sales.margin_pct as src_pct,
		bl_3nf.ce_sales.payment_type as src_p_type,
		COALESCE(bl_dm.dim_employees.employee_surr_id,-1) as src_emp_id,
		COALESCE(bl_dm.dim_stores.store_surr_id,-1) as src_store_id,
		bl_3nf.ce_sales.checkout_type as src_c_type,
		bl_3nf.ce_sales.transaction_number as src_t_number,
		'bl_3nf' as src_system,
		'ce_sales' as src_entity,
		bl_3nf.ce_sales.sale_id::varchar(1000) as src_id
	FROM bl_3nf.ce_sales
	LEFT JOIN bl_dm.dim_products_scd ON 
		bl_dm.dim_products_scd.product_src_id = bl_3nf.ce_sales.product_id::varchar(1000) AND 
		bl_dm.dim_products_scd.start_dt <= bl_3nf.ce_sales.event_dt AND 
		bl_dm.dim_products_scd.end_dt >bl_3nf.ce_sales.event_dt
	LEFT JOIN bl_dm.dim_customers ON bl_dm.dim_customers.customer_src_id = bl_3nf.ce_sales.customer_id::varchar(1000) 
	LEFT JOIN bl_dm.dim_promotions ON bl_dm.dim_promotions.promotion_src_id = bl_3nf.ce_sales.promotion_id::varchar(1000) 
	LEFT JOIN bl_3nf.ce_products_scd ON bl_3nf.ce_sales.product_id=bl_3nf.ce_products_scd.product_id AND
		bl_3nf.ce_sales.product_start_dt=bl_3nf.ce_products_scd.start_dt 
	LEFT JOIN bl_dm.dim_employees ON bl_dm.dim_employees.employee_src_id = bl_3nf.ce_sales.sales_person_id::varchar(1000)
	LEFT JOIN bl_dm.dim_stores ON bl_dm.dim_stores.store_code =bl_dm.dim_employees.store_code 
	WHERE bl_3nf.ce_sales.sale_id <> -1 AND 
		bl_dm.dim_products_scd.start_dt <= bl_3nf.ce_sales.event_dt AND 
		bl_dm.dim_products_scd.end_dt >bl_3nf.ce_sales.event_dt;

	-- INSERT 

	INSERT INTO bl_dm.fact_sales_dd(
		product_surr_id,
		customer_surr_id ,
		promotion_surr_id ,
		quantity ,
		event_dt ,
		time_surr_id ,
		unit_price ,
		unit_cost ,
		discount ,
		cost_tot ,
		price_tot ,
		cost_ratio ,
		profit ,
		margin_pct ,
		payment_type ,
		sales_person_surr_id ,
		store_surr_id ,
		checkout_type ,
		transaction_number ,
		source_system ,
		source_entity ,
		sale_src_id ,
		ta_insert_dt ,
		ta_update_dt 
	)
	SELECT 
		src_prod_id,
		src_cust_id,
		src_promo_id,
		src_q,
		src_dt,
		src_time_id,
		src_u_price,
		src_u_cost,
		src_d,
		src_cost_tot,
		src_p_tot,
		src_ratio,
		src_profit,
		src_pct,
		src_p_type,
		src_emp_id,
		src_store_id,
		src_c_type,
		src_t_number,
		src_system,
		src_entity,
		src_id,
		current_timestamp ::TIMESTAMPTZ,
		current_timestamp ::TIMESTAMPTZ
	FROM tmp_fact_sales
	WHERE NOT EXISTS (
		SELECT 1
		FROM bl_dm.fact_sales_dd
		WHERE source_system =src_system AND 
			source_entity=src_entity AND 
			sale_src_id =src_id
	);

	GET DIAGNOSTICS log_inserted = ROW_COUNT;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_fact_sales',
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
		'load_fact_sales',
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