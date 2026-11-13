-- Procedure that changes the name of source file for foreign table ext_source1_online
-- called by superuser (not db_manager)

CREATE OR REPLACE PROCEDURE bl_cl.set_source1_file(
    p_filename text
)
LANGUAGE plpgsql
AS $$
BEGIN

    EXECUTE format(
        'ALTER FOREIGN TABLE sa_grocery_online_sales.ext_source1_online
         OPTIONS (SET filename %L)',
        'source_path' || p_filename
    );

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION
            'Failed to set filename "%" for ext_source1_online. Error: %',
            p_filename,
            SQLERRM;
END;
$$;