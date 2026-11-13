-- This script creates role db_manager and c-nfigures it to control load data to bl_3nf and bl_dm
-- create role in anonymous function to make script repeatable


DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_roles
        WHERE rolname = 'db_manager'
    ) THEN
        CREATE ROLE db_manager;
    END IF;
END $$;

GRANT CONNECT ON DATABASE grocery_store TO db_manager;

GRANT USAGE ON SCHEMA sa_grocery_instore_sales TO db_manager;
GRANT USAGE ON SCHEMA sa_grocery_online_sales TO db_manager;
GRANT INSERT, SELECT, UPDATE  ON TABLE sa_grocery_instore_sales.src_source2_offline TO db_manager;
GRANT INSERT, SELECT, UPDATE  ON TABLE sa_grocery_online_sales.src_source1_online TO db_manager;
GRANT SELECT ON TABLE sa_grocery_instore_sales.ext_source2_offline TO db_manager;
GRANT SELECT ON TABLE sa_grocery_online_sales.ext_source1_online TO db_manager;

GRANT USAGE ON SCHEMA bl_3nf TO db_manager;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA bl_3nf TO db_manager;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA bl_3nf TO db_manager;

GRANT USAGE ON SCHEMA bl_dm TO db_manager;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA bl_dm TO db_manager;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA bl_dm TO db_manager;
GRANT CREATE ON SCHEMA bl_dm TO db_manager;

GRANT USAGE ON SCHEMA bl_cl TO db_manager;
GRANT SELECT, INSERT, UPDATE ON bl_cl.load_log TO db_manager;

ALTER TABLE bl_dm.fact_deliveries_dd
OWNER TO db_manager;

ALTER TABLE bl_dm.fact_sales_dd
OWNER TO db_manager;





