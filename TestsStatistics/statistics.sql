-- number of records in tables in bl_3nf
SELECT 'bl_3nf.ce_addresses' AS table_name,count(*) FROM bl_3nf.ce_addresses
UNION ALL 
SELECT 'bl_3nf.ce_campaigns' AS table_name,count (*) FROM bl_3nf.ce_campaigns cc 
UNION ALL 
SELECT 'bl_3nf.ce_cities' AS table_name, count (*) FROM bl_3nf.ce_cities cc 
UNION ALL 
SELECT 'bl_3nf.ce_customers' AS table_name,count (*) FROM bl_3nf.ce_customers cc 
UNION ALL 
SELECT 'bl_3nf.ce_employees' AS table_name, count (*) FROM bl_3nf.ce_employees ce 
UNION ALL 
SELECT 'bl_3nf.ce_product_categories' AS table_name, count (*) FROM bl_3nf.ce_product_categories cpc 
UNION ALL 
SELECT 'bl_3nf.ce_product_subcategories' AS table_name,count (*) FROM bl_3nf.ce_product_subcategories cps 
UNION ALL 
SELECT 'bl_3nf.ce_products_scd' AS table_name, count (*) FROM bl_3nf.ce_products_scd cps 
UNION ALL 
SELECT 'bl_3nf.ce_promotions' AS table_name,count (*) FROM bl_3nf.ce_promotions cp 
UNION ALL 
SELECT 'bl_3nf.ce_stores' AS table_name,count (*) FROM bl_3nf.ce_stores cs 
UNION ALL 
SELECT ' bl_3nf.ce_suppliers' AS table_name,count (*) FROM bl_3nf.ce_suppliers cs 
UNION ALL 
SELECT 'bl_3nf.ce_warehouses' AS table_name,count (*) FROM bl_3nf.ce_warehouses cw 
UNION ALL 
SELECT 'bl_3nf.suppliers_products' AS table_name, count (*) FROM bl_3nf.suppliers_products sp 
UNION ALL 
SELECT 'bl_3nf.warehouses_products' AS table_name,count (*) FROM bl_3nf.warehouses_products wp 
UNION ALL
SELECT 'bl_3nf.ce_sales' AS table_name,count(*) FROM bl_3nf.ce_sales
UNION ALL
SELECT 'bl_3nf.ce_deliveries' AS table_name,count(*) FROM bl_3nf.ce_deliveries;

-- number of records in tables in bl_dm
SELECT 'bl_dm.dim_addresses' AS table_name,count(*) FROM bl_dm.dim_addresses da 
UNION ALL
SELECT 'bl_dm.dim_promotions' AS table_name, count(*) FROM bl_dm.dim_promotions
UNION ALL
SELECT 'bl_dm.dim_customers' AS table_name, count(*) FROM bl_dm.dim_customers dc 
UNION ALL
SELECT 'bl_dm.dim_employees' AS table_name, count(*) FROM bl_dm.dim_employees de 
UNION ALL
SELECT 'bl_dm.dim_products_scd' AS table_name, count(*) FROM bl_dm.dim_products_scd dps 
UNION ALL
SELECT 'bl_dm.dim_stores' AS table_name,count(*) FROM bl_dm.dim_stores ds 
UNION ALL
SELECT 'bl_dm.dim_suppliers' AS table_name, count(*) FROM bl_dm.dim_suppliers ds 
UNION ALL
SELECT 'bl_dm.dim_warehouses' AS table_name,count(*) FROM bl_dm.dim_warehouses dw 
UNION ALL
SELECT 'bl_dm.bridge_suppliers_products' AS table_name,count(*) FROM bl_dm.bridge_suppliers_products bsp 
UNION ALL
SELECT 'bl_dm.bridge_warehouses_products' AS table_name,count(*) FROM bl_dm.bridge_warehouses_products bwp 
UNION ALL
SELECT 'bl_dm.dim_time_dd' AS table_name, count(*) FROM bl_dm.dim_time_dd 
UNION ALL
SELECT 'bl_dm.fact_deliveries_dd' AS table_name,count(*) FROM bl_dm.fact_deliveries_dd fdd 
UNION ALL
SELECT 'bl_dm.fact_sales_dd' AS table_name,count(*) FROM bl_dm.fact_sales_dd fsd;

SELECT * FROM bl_cl.load_log ll ;

