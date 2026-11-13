--procedure begins by creating a temporary table that gathers the required data from the source systems and transforms 
--it into the format required for loading into the target tables. 
-- SCD Type 0 tables do not require update logic, as their data remains unchanged after the initial load.

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_cities()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
BEGIN

	-- Gather data from source	--
	CREATE TEMP TABLE tmp_cities
	ON COMMIT DROP AS
	WITH all_cities AS (
	SELECT 
		TRIM(LOWER(sa_grocery_online_sales.src_source1_online.delivery_city_name )) AS src_city_name,
		COALESCE (TRIM(LOWER(sa_grocery_online_sales.src_source1_online.delivery_zipcode)),'n.a.') AS src_zipcode,
		'sa_grocery_online_sales' AS src_system,
		'src_source1_online' AS src_entity,
		TRIM(LOWER(sa_grocery_online_sales.src_source1_online.delivery_city_name )) AS src_id,
		sa_grocery_online_sales.src_source1_online.sales_dt::TIMESTAMPTZ AS sale_dt
	FROM sa_grocery_online_sales.src_source1_online
	WHERE sa_grocery_online_sales.src_source1_online.delivery_city_name IS NOT NULL AND
		sa_grocery_online_sales.src_source1_online.sales_dt IS NOT NULL
	UNION
	SELECT 
		TRIM(LOWER(sa_grocery_online_sales.src_source1_online.warehouse_city_name )) AS src_city_name,
		'n.a.' AS src_zipcode,
		'sa_grocery_online_sales' AS src_system,
		'src_source1_online' AS src_entity,
		TRIM(LOWER(sa_grocery_online_sales.src_source1_online.warehouse_city_name )) AS src_id,
		sa_grocery_online_sales.src_source1_online.sales_dt::TIMESTAMPTZ AS sale_dt
	FROM sa_grocery_online_sales.src_source1_online 
	WHERE sa_grocery_online_sales.src_source1_online.warehouse_city_name IS NOT NULL AND
		sa_grocery_online_sales.src_source1_online.sales_dt IS NOT NULL
	UNION 
	SELECT 
		TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.city_name)) AS src_city_name,
		COALESCE (TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.store_zipcode)),'n.a.') AS src_zipcode,
		'sa_grocery_instore_sales' AS src_system,
		'src_source2_offline' AS src_entity,
		TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.sales_city_id)) AS src_id,
		sa_grocery_instore_sales.src_source2_offline.sales_dt::TIMESTAMPTZ AS sale_dt
	FROM sa_grocery_instore_sales.src_source2_offline 
	WHERE sa_grocery_instore_sales.src_source2_offline.sales_city_id IS NOT NULL AND
		sa_grocery_instore_sales.src_source2_offline.sales_dt IS NOT NULL
	UNION
	SELECT 
		TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.customer_city_name)) AS src_city_name,
		COALESCE (TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.customer_zipcode)),'n.a.') AS src_zipcode,
		'sa_grocery_instore_sales' AS src_system,
		'src_source2_offline' AS src_entity,
		TRIM(LOWER(sa_grocery_instore_sales.src_source2_offline.customer_city_id)) AS src_id,
		sa_grocery_instore_sales.src_source2_offline.sales_dt::TIMESTAMPTZ AS sale_dt
	FROM sa_grocery_instore_sales.src_source2_offline
	WHERE sa_grocery_instore_sales.src_source2_offline.customer_city_id IS NOT NULL AND
		sa_grocery_instore_sales.src_source2_offline.sales_dt IS NOT NULL
	)
		SELECT *,
			ROW_NUMBER() OVER (
			    PARTITION BY src_system, src_entity, src_id
			    ORDER BY
			        CASE
			            WHEN src_zipcode <> 'n.a.' THEN 0
			            ELSE 1
			        END,
					sale_dt
			) AS rn
		FROM all_cities;

	-- INSERT 
	INSERT INTO bl_3nf.ce_cities
	SELECT NEXTVAL('bl_3nf.sqc_cities'),
		src_city_name,
		src_zipcode,
		src_system,
		src_entity,
		src_id,
		current_timestamp ::TIMESTAMPTZ,
		current_timestamp ::TIMESTAMPTZ
	FROM tmp_cities
	WHERE rn=1 AND 
		NOT EXISTS (
		SELECT 1 
		FROM bl_3nf.ce_cities
		WHERE bl_3nf.ce_cities.source_system =TRIM(LOWER(src_system)) AND 
			bl_3nf.ce_cities.source_entity =TRIM(LOWER(src_entity)) AND 
			bl_3nf.ce_cities.city_src_id =TRIM(LOWER(src_id))
	);

	GET DIAGNOSTICS log_inserted = ROW_COUNT;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_ce_cities',
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
		'load_ce_cities',
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