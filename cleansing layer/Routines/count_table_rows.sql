-- This function gets schema_name and table name as parameters and returns count of rows in this table.
-- It is used while loading with upsert and merge where there is no possibility to get separate diagnostic for updated and inserted rows
CREATE OR REPLACE FUNCTION bl_cl.count_table_rows(
	p_schema_name varchar,
	p_table_name varchar
)
RETURNS bigint
LANGUAGE plpgsql
AS $$
DECLARE
	row_count bigint;
	sql_query text;
BEGIN

	sql_query := format(
		'SELECT COUNT(*) FROM %I.%I',
		p_schema_name,
		p_table_name
	);

	EXECUTE sql_query INTO row_count;

	return row_count;

END;
$$;