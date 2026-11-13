-- before initial load we need to create partitions for table
CREATE OR REPLACE PROCEDURE bl_cl.create_deliveries_partitions()
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

BEGIN
	CREATE TABLE IF NOT EXISTS bl_dm.fact_deliveries_default PARTITION OF bl_dm.fact_deliveries_dd DEFAULT;

	start_date:= date_trunc('month', current_date - interval '2 month');
	end_date:=date_trunc('month', current_date);
	FOR dt IN SELECT generate_series(start_date, end_date, '1 month'::interval) 
	LOOP
		mnth := to_char(dt, 'MM');
		yr := to_char(dt, 'YYYY');
		f_day := date_trunc('month', dt)::timestamptz; -- start of the month
		l_day := (date_trunc('month', dt)+'1month'::interval)::timestamptz; -- start of the next month
		EXECUTE format(
        'CREATE TABLE IF NOT EXISTS bl_dm.%I PARTITION OF bl_dm.fact_deliveries_dd
         FOR VALUES FROM (%L) TO (%L)',
        'fact_deliveries_' || yr || '_' || mnth,
        f_day,
        l_day
    	);
	END LOOP;
EXCEPTION
        WHEN OTHERS THEN
            RAISE EXCEPTION
                'Error creating fact_deliveries partitions: %',
                SQLERRM;

END;
$$;