
-- This procedure implements the rolling window logic:
-- when data for a new month arrives, the oldest monthly partition is detached and its data is removed;
-- a new partition for the incoming month is then created;
-- finally, the corresponding data is loaded into each partition by calling the partition load procedure.		
CREATE OR REPLACE PROCEDURE bl_cl.sales_rolling_window(
)
LANGUAGE plpgsql
AS $$
declare 

mnth varchar(2);
yr varchar(4);
dt timestamptz;
f_day timestamptz;
l_day timestamptz;
start_date timestamptz;
end_date timestamptz;
partition_to_remove text;
partition_to_load text;

BEGIN

	start_date:= date_trunc('month', current_date - interval '3 month');
	end_date:=date_trunc('month', current_date);
	mnth := to_char(start_date, 'MM');
	yr := to_char(start_date, 'YYYY');
	partition_to_remove:='fact_sales_' || yr || '_' || mnth;

	IF to_regclass('bl_dm.' || partition_to_remove) IS NOT NULL THEN
		BEGIN
			EXECUTE format(
		        'ALTER TABLE bl_dm.fact_sales_dd DETACH PARTITION bl_dm.%I;'	,
				partition_to_remove);
			EXECUTE format('INSERT INTO bl_dm.fact_sales_default
					SELECT *
					FROM bl_dm.%I;',
					partition_to_remove);
			EXECUTE format('DROP TABLE IF EXISTS bl_dm.%I',
			        partition_to_remove);
		EXCEPTION
		    WHEN OTHERS THEN
		        RAISE EXCEPTION 
		            'Failed to move partition % to default partition: %',
		            partition_to_remove,
		            SQLERRM;
		END;
	END IF;


	mnth := to_char(end_date, 'MM');
	yr := to_char(end_date, 'YYYY');
	f_day := date_trunc('month', end_date)::timestamptz; -- start of the month
	l_day := (date_trunc('month', end_date)+'1month'::interval)::timestamptz; -- start of the next month
	EXECUTE format(
    'CREATE TABLE IF NOT EXISTS bl_dm.%I PARTITION OF bl_dm.fact_sales_dd
     FOR VALUES FROM (%L) TO (%L)',
    'fact_sales_' || yr || '_' || mnth,
    f_day,
    l_day
	);

	FOR dt IN SELECT generate_series(current_date - interval '2 month', current_date, '1 month'::interval) 
	LOOP
		mnth := to_char(dt, 'MM');
		yr := to_char(dt, 'YYYY');
		f_day := date_trunc('month', dt)::timestamptz; -- start of the month
		l_day := (date_trunc('month', dt)+'1month'::interval)::timestamptz; -- start of the next month
		partition_to_load:='fact_sales_' || yr || '_' || mnth;
		CALL bl_cl.load_fact_sales_partition(partition_to_load,f_day,l_day);
	END LOOP;
EXCEPTION
        WHEN OTHERS THEN
            RAISE EXCEPTION
                'Error handling rolling window for fact_deliveries partitions: %',
                SQLERRM;
END;
$$;

-- this procedure loads data into partition
CREATE OR REPLACE PROCEDURE bl_cl.load_fact_sales_partition(
    p_partition_name text,
    p_start_date timestamptz,
    p_end_date timestamptz
)
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
BEGIN
	-- postgresql drop it at the end of the session, however I call this procedure 3 times in one session, therefore I need to drop it
	DROP TABLE IF EXISTS tmp_fact_sales;
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
	WHERE bl_3nf.ce_sales.sale_id <> -1  and 
		bl_3nf.ce_sales.event_dt >= p_start_date and 
		bl_3nf.ce_sales.event_dt < p_end_date;

	-- UPDATE
EXECUTE format (
	'UPDATE bl_dm.%I
	SET 
		product_surr_id =src_prod_id,
		customer_surr_id = src_cust_id,
		promotion_surr_id = src_promo_id,
		quantity = src_q,
		event_dt = src_dt,
		time_surr_id = src_time_id,
		unit_price = src_u_price,
		unit_cost = src_u_cost,
		discount = src_d,
		cost_tot = src_cost_tot,
		price_tot = src_p_tot,
		cost_ratio = src_ratio,
		profit = src_profit,
		margin_pct = src_pct,
		payment_type = src_p_type,
		sales_person_surr_id = src_emp_id,
		store_surr_id = src_store_id,
		checkout_type = src_c_type,
		transaction_number = src_t_number,
		ta_update_dt = current_timestamp ::TIMESTAMPTZ
	FROM tmp_fact_sales
	WHERE source_system =tmp_fact_sales.src_system AND 
		source_entity=tmp_fact_sales.src_entity AND 
		sale_src_id =tmp_fact_sales.src_id AND 
		(
		product_surr_id <>tmp_fact_sales.src_prod_id OR
		customer_surr_id <> tmp_fact_sales.src_cust_id OR
		promotion_surr_id <> tmp_fact_sales.src_promo_id OR
		quantity <> tmp_fact_sales.src_q OR
		event_dt <> tmp_fact_sales.src_dt OR
		time_surr_id <> tmp_fact_sales.src_time_id OR
		unit_price <> tmp_fact_sales.src_u_price OR
		unit_cost <> tmp_fact_sales.src_u_cost OR
		discount <> tmp_fact_sales.src_d OR
		cost_tot <> tmp_fact_sales.src_cost_tot OR
		price_tot <> tmp_fact_sales.src_p_tot OR
		cost_ratio <> tmp_fact_sales.src_ratio OR
		profit <> tmp_fact_sales.src_profit OR
		margin_pct <> tmp_fact_sales.src_pct OR
		payment_type <> tmp_fact_sales.src_p_type OR
		sales_person_surr_id <> tmp_fact_sales.src_emp_id OR
		store_surr_id <> tmp_fact_sales.src_store_id OR
		checkout_type <> tmp_fact_sales.src_c_type OR
		transaction_number <> tmp_fact_sales.src_t_number
		)',p_partition_name);
	GET DIAGNOSTICS log_updated = ROW_COUNT;

    -- INSERT 
	EXECUTE format('INSERT INTO bl_dm.%I
	(
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
		tmp_fact_sales.src_prod_id,
		tmp_fact_sales.src_cust_id,
		tmp_fact_sales.src_promo_id,
		tmp_fact_sales.src_q,
		tmp_fact_sales.src_dt,
		tmp_fact_sales.src_time_id,
		tmp_fact_sales.src_u_price,
		tmp_fact_sales.src_u_cost,
		tmp_fact_sales.src_d,
		tmp_fact_sales.src_cost_tot,
		tmp_fact_sales.src_p_tot,
		tmp_fact_sales.src_ratio,
		tmp_fact_sales.src_profit,
		tmp_fact_sales.src_pct,
		tmp_fact_sales.src_p_type,
		tmp_fact_sales.src_emp_id,
		tmp_fact_sales.src_store_id,
		tmp_fact_sales.src_c_type,
		tmp_fact_sales.src_t_number,
		tmp_fact_sales.src_system,
		tmp_fact_sales.src_entity,
		tmp_fact_sales.src_id,
		current_timestamp ::TIMESTAMPTZ,
		current_timestamp ::TIMESTAMPTZ
	FROM tmp_fact_sales 
	WHERE NOT EXISTS (
			SELECT 1 
			FROM bl_dm.%I
			WHERE source_system=tmp_fact_sales.src_system AND 
			source_entity=tmp_fact_sales.src_entity AND 
			sale_src_id = tmp_fact_sales.src_id
		)'
	, p_partition_name,p_partition_name)
	;

	GET DIAGNOSTICS log_inserted = ROW_COUNT;


	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_fact_sales_partition',
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
		'load_fact_sales_partition',
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


