-- This script creates bl_dm layer
-- bl_dm schema
-- dim and fact tables

-- inserts default row in every dim table in separate procedure

BEGIN;
CREATE SCHEMA IF NOT EXISTS bl_dm;
COMMIT;

BEGIN;

CREATE SEQUENCE IF NOT EXISTS bl_dm.sqc_addresses AS bigint MINVALUE 1;

CREATE TABLE IF NOT EXISTS bl_dm.dim_addresses(
	address_surr_id bigint PRIMARY KEY DEFAULT nextval('bl_dm.sqc_addresses'),
	address varchar(1000) NOT NULL,
	city_id bigint NOT NULL,
	city_name varchar(50) NOT NULL,
	zipcode varchar(9) NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	address_src_id varchar(1000) NOT NULL,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL
);

CREATE SEQUENCE IF NOT EXISTS bl_dm.sqc_dim_suppliers AS BIGINT MINVALUE 1;

CREATE TABLE IF NOT EXISTS bl_dm.dim_suppliers(
	supplier_surr_id bigint PRIMARY KEY DEFAULT nextval('bl_dm.sqc_dim_suppliers'),
	supplier_name varchar(50) NOT NULL,
	supplier_rating smallint NOT NULL,
	contract_start_dt timestamptz NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	supplier_src_id varchar(1000) NOT NULL,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL 
);

CREATE SEQUENCE IF NOT EXISTS bl_dm.sqc_dim_warehouses AS BIGINT MINVALUE 1;

CREATE TABLE IF NOT EXISTS bl_dm.dim_warehouses(
	warehouse_surr_id bigint PRIMARY KEY DEFAULT nextval('bl_dm.sqc_dim_warehouses'),
	warehouse_name varchar(50) NOT NULL,
	capacity numeric(7,2) NOT NULL,
	operating_cost int NOT NULL,
	manager_name varchar(50) NOT NULL,
	warehouse_load_factor numeric(7,6) NOT NULL,
	city_id bigint NOT NULL,
	city_name varchar(50) NOT NULL,
	zipcode varchar(9) NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	warehouse_src_id varchar(1000) NOT NULL,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL 
);

CREATE SEQUENCE IF NOT EXISTS bl_dm.sqc_dim_customers as bigint MINVALUE 1;

CREATE TABLE IF NOT EXISTS bl_dm.dim_customers(
	customer_surr_id bigint PRIMARY KEY DEFAULT nextval('bl_dm.sqc_dim_customers'),
	customer_first_name varchar(25) NOT NULL,
	customer_middle_initital varchar(4) NOT NULL,
	customer_last_name varchar(25) NOT NULL,	
	email varchar(100) NOT NULL,	
	registration_dt date NOT NULL,	
	first_sale_dt date NOT NULL,	
	customer_phone_number varchar(16) NOT NULL,
	customer_birth_dt date NOT NULL,
	customer_address_id bigint NOT NULL,
	customer_address varchar(100) NOT NULL,
	city_id bigint NOT NULL,
	city_name varchar(50) NOT NULL,
	zipcode varchar(9) NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	customer_src_id varchar(1000) NOT NULL,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL
);

CREATE SEQUENCE IF NOT EXISTS bl_dm.sqc_dim_stores as bigint MINVALUE 1;

CREATE TABLE IF NOT EXISTS bl_dm.dim_stores(
	store_surr_id bigint PRIMARY KEY DEFAULT nextval('bl_dm.sqc_dim_stores'),
	store_code varchar(1000) NOT NULL,
	city_id bigint NOT NULL,
	city_name varchar(50) NOT NULL,
	zipcode varchar(9) NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	store_src_id varchar(1000) NOT NULL,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL
);

CREATE SEQUENCE IF NOT EXISTS bl_dm.sqc_dim_employees as bigint MINVALUE 1;

CREATE TABLE IF NOT EXISTS bl_dm.dim_employees(
	employee_surr_id bigint PRIMARY KEY DEFAULT nextval('bl_dm.sqc_dim_employees'),
	employee_first_name varchar(25) NOT NULL,
	employee_middle_initial varchar(4) NOT NULL,
	employee_last_name varchar(25) NOT NULL,
	birth_dt date NOT NULL,
	gender varchar(4) NOT NULL,
	hire_dt date NOT NULL,
	employee_skill_level varchar(10) NOT NULL,
	store_code varchar(1000) NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	employee_src_id varchar(1000) NOT NULL,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL
);

CREATE SEQUENCE IF NOT EXISTS bl_dm.sqc_dim_promotions as bigint MINVALUE 1;

CREATE TABLE IF NOT EXISTS bl_dm.dim_promotions(
	promotion_surr_id bigint PRIMARY KEY DEFAULT nextval('bl_dm.sqc_dim_promotions'),
	promotion_name varchar(50) NOT NULL,
	channel varchar(7) NOT NULL,
	promotion_start_dt timestamptz NOT NULL,
	promotion_end_dt timestamptz NOT NULL,
	discount numeric(3,2) NOT NULL,
	campaign_id bigint NOT NULL,
	campaign_name varchar(50) NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	promotion_src_id varchar(1000) NOT NULL,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL
);

CREATE SEQUENCE IF NOT EXISTS bl_dm.sqc_dim_products AS BIGINT MINVALUE 1;

CREATE TABLE IF NOT EXISTS bl_dm.dim_products_scd(
	product_surr_id bigint PRIMARY KEY DEFAULT nextval('bl_dm.sqc_dim_products'),
	start_dt timestamptz NOT NULL,
	product_name varchar(100) NOT NULL,
	product_code varchar(1000) NOT NULL,
	class varchar(10) NOT NULL,
	modify_dt timestamptz NOT NULL,
	resistant varchar(7) NOT NULL,
	is_allergic varchar(7) NOT NULL,
	vitality_days numeric(4,1) NOT NULL,
	product_subcategory_id bigint NOT NULL,
	product_subcategory_name varchar(50) NOT NULL,
	product_category_id bigint NOT NULL,
	product_category_name varchar(50) NOT NULL ,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	product_src_id varchar(1000) NOT NULL ,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL,
	end_dt timestamptz NOT NULL,
	is_active varchar(4) NOT NULL
);

CREATE TABLE IF NOT EXISTS bl_dm.bridge_suppliers_products(
	product_surr_id bigint NOT NULL,
	supplier_surr_id bigint NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	supplier_product_src_id varchar(1000) NOT NULL ,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL,
	PRIMARY KEY (product_surr_id, supplier_surr_id),
	FOREIGN KEY (product_surr_id) REFERENCES bl_dm.dim_products_scd (product_surr_id),
	FOREIGN KEY (supplier_surr_id) REFERENCES bl_dm.dim_suppliers (supplier_surr_id)
);

CREATE TABLE IF NOT EXISTS bl_dm.bridge_warehouses_products(
	product_surr_id bigint NOT NULL,
	warehouse_surr_id bigint NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	warehouse_product_src_id varchar(1000) NOT NULL ,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL,
	PRIMARY KEY (product_surr_id, warehouse_surr_id),
	FOREIGN KEY (product_surr_id) REFERENCES bl_dm.dim_products_scd (product_surr_id),
	FOREIGN KEY (warehouse_surr_id) REFERENCES bl_dm.dim_warehouses (warehouse_surr_id)
);

-- from previous script + schema is added
CREATE TABLE IF NOT EXISTS bl_dm.dim_time_dd(
	time_surr_id bigint PRIMARY KEY,
	full_date DATE NOT NULL,
	day_number_of_month SMALLINT NOT NULL,
	month_number SMALLINT NOT NULL,
	month_name VARCHAR(15) NOT NULL,
	year SMALLINT NOT NULL,
	week_number_of_year SMALLINT NOT NULL,
	quarter_number SMALLINT NOT NULL,
	day_of_week VARCHAR(10) NOT NULL,
	fiscal_year SMALLINT NOT NULL,
	fiscal_quarter SMALLINT NOT NULL,
	fiscal_month SMALLINT NOT NULL,
	fiscal_week SMALLINT NOT NULL
);

CREATE SEQUENCE IF NOT EXISTS bl_dm.sqc_fact_deliveries AS bigint MINVALUE 1;


CREATE TABLE IF NOT EXISTS bl_dm.fact_deliveries_dd(
	delivery_surr_id bigint DEFAULT nextval('bl_dm.sqc_fact_deliveries'),
	time_surr_id bigint NOT NULL,
	delivery_cost numeric(11,6) NOT NULL,
	delivery_dt timestamptz NOT NULL,
	delivery_address_surr_id bigint NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	delivery_src_id varchar(1000) NOT NULL,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL,
	FOREIGN KEY (time_surr_id) REFERENCES bl_dm.dim_time_dd (time_surr_id),
	FOREIGN KEY (delivery_address_surr_id) REFERENCES bl_dm.dim_addresses (address_surr_id)
)PARTITION BY RANGE (delivery_dt);

CREATE SEQUENCE IF NOT EXISTS bl_dm.sqc_fact_sales AS BIGINT MINVALUE 1;

CREATE TABLE IF NOT EXISTS bl_dm.fact_sales_dd(
	sale_surr_id bigint DEFAULT nextval('bl_dm.sqc_fact_sales'),	
	product_surr_id bigint NOT NULL,
	customer_surr_id bigint NOT NULL,
	promotion_surr_id bigint NOT NULL,
	quantity int NOT NULL,
	event_dt timestamptz NOT NULL,
	time_surr_id bigint NOT NULL,
	unit_price numeric(11,6) NOT NULL,
	unit_cost numeric(11,6) NOT NULL,
	discount numeric(3,2) NOT NULL,
	cost_tot numeric(13,6) NOT NULL,
	price_tot numeric(13,6) NOT NULL,
	cost_ratio numeric(7,6),
	profit numeric(13,6),
	margin_pct numeric(6,4),
	payment_type varchar(10) NOT NULL,
	sales_person_surr_id bigint NOT NULL,
	store_surr_id bigint NOT NULL,
	checkout_type varchar(20) NOT NULL,
	transaction_number varchar(20) NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	sale_src_id varchar(1000) NOT NULL,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL,
	FOREIGN KEY (customer_surr_id) REFERENCES bl_dm.dim_customers(customer_surr_id),
	FOREIGN KEY (promotion_surr_id) REFERENCES bl_dm.dim_promotions(promotion_surr_id),
	FOREIGN KEY (sales_person_surr_id) REFERENCES bl_dm.dim_employees(employee_surr_id),
	FOREIGN KEY (store_surr_id) REFERENCES bl_dm.dim_stores(store_surr_id),
	FOREIGN KEY (time_surr_id) REFERENCES bl_dm.dim_time_dd(time_surr_id),
	FOREIGN KEY (product_surr_id) REFERENCES bl_dm.dim_products_scd(product_surr_id)
)PARTITION BY RANGE (event_dt);

COMMIT;


