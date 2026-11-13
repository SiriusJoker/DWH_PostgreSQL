-- Procedure to change file name of external file source

CREATE OR REPLACE PROCEDURE bl_cl.set_source2_file(
    p_filename text
)
LANGUAGE plpgsql
AS $$
BEGIN
    EXECUTE format(
        'ALTER FOREIGN TABLE sa_grocery_instore_sales.ext_source2_offline
         OPTIONS (SET filename %L)',
        'source_path' || p_filename
    );
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION
            'Failed to set filename "%" for ext_source2_offline. Error: %',
            p_filename,
            SQLERRM;
END;
$$;
