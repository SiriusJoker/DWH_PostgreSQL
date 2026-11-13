CREATE OR REPLACE PROCEDURE bl_cl.load_data()
LANGUAGE plpgsql
AS $$
DECLARE

BEGIN

	CALL bl_cl.insert_to_sa();
	CALL bl_cl.load_bl_3nf_base(); -- 1m24s
	CALL bl_cl.process_sales();
	CALL bl_cl.load_bl_dm_dimensions();
	CALL bl_cl.deliveries_rolling_window();
	CALL bl_cl.sales_rolling_window();

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION
            'Failed to load data: %',
            SQLERRM;
END;
$$;