-- to use upsert there is a need of unique constraint on source triplet:
-- placed it in anonymous function to make script rerunnable

DO $$
BEGIN
	IF NOT EXISTS (
		SELECT 1
		FROM pg_constraint
		WHERE conname = 'uq_dim_warehouses_source'
		AND conrelid = 'bl_dm.dim_warehouses'::regclass
	)
	THEN
		ALTER TABLE bl_dm.dim_warehouses
		ADD CONSTRAINT uq_dim_warehouses_source
		UNIQUE
		(
			source_system,
			source_entity,
			warehouse_src_id
		);
	END IF;
END $$;

-- created type for often used rows of city
--placed in anonymous function to make script rerunnable
DO $$
BEGIN
	IF NOT EXISTS (
		SELECT 1
		FROM pg_type
		WHERE typname = 'city_t'
		AND typnamespace = 'bl_cl'::regnamespace
	)
	THEN
		CREATE TYPE bl_cl.city_t AS (
			city_id bigint,
			city_name varchar,
			zipcode varchar
		);
	END IF;
END $$;

-- procedure for loading warehouses table uses function to count rows, city type, loop cursor and upsert:
CREATE OR REPLACE PROCEDURE bl_cl.load_dim_warehouses()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    rows_affected bigint := 0;
	log_total bigint:=0;
	log_updated bigint:=0;
	log_inserted bigint:=0;
	count_before bigint:=0;
	count_after bigint:=0;

    rec RECORD;
    city bl_cl.city_t;
BEGIN

	count_before:=bl_cl.count_table_rows('bl_dm','dim_warehouses');

	FOR rec IN
		SELECT 
		bl_3nf.ce_warehouses.warehouse_name AS src_w_name,
		bl_3nf.ce_warehouses.capacity AS src_capacity,
		bl_3nf.ce_warehouses.operating_cost AS src_cost,
		bl_3nf.ce_warehouses.manager_name AS src_m_name,
		bl_3nf.ce_warehouses.warehouse_load_factor AS src_factor,
		bl_3nf.ce_cities.city_id AS src_c_id,
		bl_3nf.ce_cities.city_name AS src_c_name,
		bl_3nf.ce_cities.zipcode AS src_zipcode,
		'bl_3nf' AS src_system,
		'ce_warehouses' AS src_entity,
		bl_3nf.ce_warehouses.warehouse_id::varchar(1000) AS src_id
		FROM bl_3nf.ce_warehouses
		INNER JOIN bl_3nf.ce_cities ON bl_3nf.ce_warehouses.warehouse_city_id = bl_3nf.ce_cities.city_id
		where bl_3nf.ce_warehouses.warehouse_id <> -1

	LOOP

	    city := ROW(
	        rec.src_c_id,
	        rec.src_c_name,
	        rec.src_zipcode
	    )::bl_cl.city_t;

		INSERT INTO bl_dm.dim_warehouses
(
	warehouse_name ,
	capacity ,
	operating_cost ,
	manager_name ,
	warehouse_load_factor ,
	city_id ,
	city_name,
	zipcode ,
	source_system ,
	source_entity ,
	warehouse_src_id ,
	ta_insert_dt ,
	ta_update_dt 
)
			VALUES( rec.src_w_name,
			rec.src_capacity,
			rec.src_cost,
			rec.src_m_name,
			rec.src_factor,
			city.city_id,
			city.city_name,
			city.zipcode,
			rec.src_system,
			rec.src_entity,
			rec.src_id,
			current_timestamp ::TIMESTAMPTZ,
			current_timestamp ::TIMESTAMPTZ)
		ON CONFLICT (
		    source_system,
		    source_entity,
		    warehouse_src_id
		)
	    DO UPDATE
	    SET
			warehouse_name = EXCLUDED.warehouse_name,
			capacity = EXCLUDED.capacity,
			operating_cost = EXCLUDED.operating_cost,
			manager_name = EXCLUDED.manager_name,
			warehouse_load_factor = EXCLUDED.warehouse_load_factor,	
			city_id = EXCLUDED.city_id,
			city_name = EXCLUDED.city_name,
			zipcode = EXCLUDED.zipcode,	
			ta_update_dt = CURRENT_TIMESTAMP
		WHERE
			bl_dm.dim_warehouses.warehouse_name <> EXCLUDED.warehouse_name OR
			bl_dm.dim_warehouses.capacity <> EXCLUDED.capacity OR 
			bl_dm.dim_warehouses.operating_cost <> EXCLUDED.operating_cost OR 
			bl_dm.dim_warehouses.manager_name <> EXCLUDED.manager_name OR 
			bl_dm.dim_warehouses.warehouse_load_factor <> EXCLUDED.warehouse_load_factor OR 
			bl_dm.dim_warehouses.city_id <> EXCLUDED.city_id OR 
			bl_dm.dim_warehouses.city_name <> EXCLUDED.city_name OR 
			bl_dm.dim_warehouses.zipcode <> EXCLUDED.zipcode;

	GET DIAGNOSTICS rows_affected = ROW_COUNT;
	log_total:=log_total + rows_affected;

	
	END LOOP;
	count_after:=bl_cl.count_table_rows('bl_dm','dim_warehouses');
	log_inserted:=count_after- count_before;
	log_updated:=log_total - log_inserted;
	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_dim_warehouses',
		log_total,
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
		'load_dim_warehouses',
		log_total,
		log_updated,
		log_inserted,		
		'FAILED',
		SQLERRM,
		log_start_time,
		log_end_time
    );

END;
$$;