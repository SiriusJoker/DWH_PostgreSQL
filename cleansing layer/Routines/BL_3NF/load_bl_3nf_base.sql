--This procedure calls load for all tables in bl_3nf except prefact

CREATE OR REPLACE PROCEDURE bl_cl.load_bl_3nf_base()
LANGUAGE plpgsql
AS $$
DECLARE

BEGIN

	CALL bl_cl.load_ce_campaigns();
	CALL bl_cl.load_ce_suppliers();
	CALL bl_cl.load_ce_cities();
	CALL bl_cl.load_ce_addresses();
	CALL bl_cl.load_ce_warehouses();
	CALL bl_cl.load_ce_customers();
	CALL bl_cl.load_ce_stores();
	CALL bl_cl.load_ce_employees();
	CALL bl_cl.load_ce_promotions();
	CALL bl_cl.load_ce_products_categories();
	CALL bl_cl.load_ce_product_subcategories();
	CALL bl_cl.load_ce_products_scd();
	CALL bl_cl.load_ce_suppliers_products();
	CALL bl_cl.load_ce_warehouses_products();

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION
            'Failed to load bl_3nf: %',
            SQLERRM;
END;
$$;