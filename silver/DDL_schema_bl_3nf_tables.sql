BEGIN;
CREATE SCHEMA IF NOT EXISTS bl_3nf;
COMMIT;

BEGIN;
CREATE TABLE IF NOT EXISTS bl_3nf.ce_product_categories(
	product_category_id bigint PRIMARY KEY,
	product_category_name varchar(50) NOT NULL ,
	source_system varchar(1000) NOT NULL ,
	source_entity varchar(1000) NOT NULL ,
	product_category_src_id varchar(1000) NOT NULL,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL 
);

CREATE SEQUENCE IF NOT EXISTS bl_3nf.sqc_product_categories AS bigint MINVALUE 1;

CREATE TABLE IF NOT EXISTS bl_3nf.ce_product_subcategories(
	product_subcategory_id bigint PRIMARY KEY ,
	product_subcategory_name varchar(50) NOT NULL,
	product_category_id bigint NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	product_subcategory_src_id varchar(1000) NOT NULL,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL ,
	FOREIGN KEY (product_category_id) REFERENCES bl_3nf.ce_product_categories(product_category_id)
);

CREATE SEQUENCE IF NOT EXISTS bl_3nf.sqc_product_subcategories AS bigint MINVALUE 1;

CREATE TABLE IF NOT EXISTS bl_3nf.ce_suppliers(
	supplier_id bigint PRIMARY KEY,
	supplier_name varchar(50) NOT NULL,
	supplier_rating smallint NOT NULL,
	contract_start_dt timestamptz NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	supplier_src_id varchar(1000) NOT NULL,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL 
);

CREATE SEQUENCE IF NOT EXISTS bl_3nf.sqc_suppliers AS bigint MINVALUE 1;


CREATE TABLE IF NOT EXISTS bl_3nf.ce_cities(
	city_id bigint PRIMARY KEY,
	city_name varchar(50) NOT NULL,
	zipcode varchar(9) NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	city_src_id varchar(1000) NOT NULL,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL
);
CREATE SEQUENCE IF NOT EXISTS bl_3nf.sqc_cities AS bigint MINVALUE 1;

CREATE TABLE IF NOT EXISTS bl_3nf.ce_addresses(
	address_id bigint PRIMARY KEY ,
	address varchar(1000) NOT NULL,
	city_id bigint NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	address_src_id varchar(1000) NOT NULL,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL,
	FOREIGN KEY (city_id) REFERENCES bl_3nf.ce_cities (city_id)
);

CREATE SEQUENCE IF NOT EXISTS bl_3nf.sqc_addresses AS bigint MINVALUE 1;

CREATE TABLE IF NOT EXISTS bl_3nf.ce_deliveries(
	delivery_id bigint PRIMARY KEY ,
	delivery_address_id bigint NOT NULL,
	delivery_cost numeric(11,6) NOT NULL,
	delivery_dt timestamptz NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	delivery_src_id varchar(1000) NOT NULL,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL,
	FOREIGN KEY (delivery_address_id) REFERENCES bl_3nf.ce_addresses (address_id)
);
CREATE SEQUENCE IF NOT EXISTS bl_3nf.sqc_deliveries AS bigint MINVALUE 1;

CREATE TABLE IF NOT EXISTS bl_3nf.ce_warehouses(
	warehouse_id bigint PRIMARY KEY,
	warehouse_city_id bigint NOT NULL,
	warehouse_name varchar(50) NOT NULL,
	capacity numeric(7,2) NOT NULL,
	operating_cost int NOT NULL,
	manager_name varchar(50) NOT NULL,
	warehouse_load_factor numeric(7,6) NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	warehouse_src_id varchar(1000) NOT NULL,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL ,
	FOREIGN KEY (warehouse_city_id) REFERENCES bl_3nf.ce_cities(city_id)
);

CREATE SEQUENCE IF NOT EXISTS bl_3nf.sqc_warehouses AS bigint MINVALUE 1;


CREATE TABLE IF NOT EXISTS bl_3nf.ce_customers(
	customer_id bigint PRIMARY KEY,
	customer_first_name varchar(25) NOT NULL,
	customer_middle_initital varchar(4) NOT NULL,
	customer_last_name varchar(25) NOT NULL,	
	email varchar(100) NOT NULL,	
	registration_dt date NOT NULL,	
	first_sale_dt date NOT NULL,	
	customer_phone_number varchar(16) NOT NULL,
	customer_birth_dt date NOT NULL,
	customer_address_id bigint NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	customer_src_id varchar(1000) NOT NULL,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL,	
	FOREIGN KEY (customer_address_id) REFERENCES bl_3nf.ce_addresses(address_id)
);

CREATE SEQUENCE IF NOT EXISTS bl_3nf.sqc_customers AS bigint MINVALUE 1;

CREATE TABLE IF NOT EXISTS bl_3nf.ce_stores(
	store_id bigint PRIMARY KEY,
	city_id bigint NOT NULL,
	store_code varchar(1000) NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	store_src_id varchar(1000) NOT NULL,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL,
	FOREIGN KEY (city_id) REFERENCES bl_3nf.ce_cities(city_id)
);

CREATE SEQUENCE IF NOT EXISTS bl_3nf.sqc_stores AS bigint MINVALUE 1;

CREATE TABLE IF NOT EXISTS bl_3nf.ce_employees(
	employee_id bigint PRIMARY KEY,
	employee_first_name varchar(25) NOT NULL,
	employee_middle_initial varchar(4) NOT NULL,
	employee_last_name varchar(25) NOT NULL,
	birth_dt date NOT NULL,
	gender varchar(4) NOT NULL,
	hire_dt date NOT NULL,
	employee_skill_level varchar(10) NOT NULL,
	store_id bigint NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	employee_src_id varchar(1000) NOT NULL,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL,
	FOREIGN KEY (store_id) REFERENCES bl_3nf.ce_stores(store_id)
);

CREATE SEQUENCE IF NOT EXISTS bl_3nf.sqc_employees AS bigint MINVALUE 1;

CREATE TABLE IF NOT EXISTS bl_3nf.ce_campaigns(
	campaign_id bigint PRIMARY KEY,
	campaign_name varchar(50) NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	campaign_src_id varchar(1000) NOT NULL,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL 
);

CREATE SEQUENCE IF NOT EXISTS bl_3nf.sqc_campaigns AS bigint MINVALUE 1;

CREATE TABLE IF NOT EXISTS bl_3nf.ce_promotions(
	promotion_id bigint PRIMARY KEY,
	promotion_name varchar(50) NOT NULL,
	channel varchar(7) NOT NULL,
	promotion_start_dt timestamptz NOT NULL,
	promotion_end_dt timestamptz NOT NULL,
	campaign_id bigint NOT NULL,
	discount numeric(3,2) NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	promotion_src_id varchar(1000) NOT NULL,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL,
	FOREIGN KEY (campaign_id) REFERENCES bl_3nf.ce_campaigns(campaign_id)
);

CREATE SEQUENCE IF NOT EXISTS bl_3nf.sqc_promotions AS bigint MINVALUE 1;

CREATE TABLE IF NOT EXISTS bl_3nf.ce_products_scd(
	product_id bigint NOT NULL,
	start_dt timestamptz NOT NULL,
	product_name varchar(100) NOT NULL,
	product_code varchar(1000) NOT NULL,
	unit_price numeric(11,6) NOT NULL,
	class varchar(10) NOT NULL,
	modify_dt timestamptz NOT NULL,
	resistant varchar(7) NOT NULL,
	is_allergic varchar(7) NOT NULL,
	vitality_days numeric(4,1) NOT NULL,
	product_subcategory_id bigint NOT NULL,
	unit_cost numeric(11,6) NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	product_src_id varchar(1000) NOT NULL ,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL,
	end_dt timestamptz NOT NULL,
	is_active varchar(4) NOT NULL,
	FOREIGN KEY (product_subcategory_id) REFERENCES bl_3nf.ce_product_subcategories(product_subcategory_id),
	PRIMARY KEY (product_id, start_dt)	
);

CREATE SEQUENCE IF NOT EXISTS bl_3nf.sqc_products AS bigint MINVALUE 1;

CREATE TABLE IF NOT EXISTS bl_3nf.suppliers_products(
	product_id bigint NOT NULL,
	start_dt timestamptz NOT NULL,
	supplier_id bigint NOT NULL ,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	supplier_product_src_id varchar(1000) NOT NULL ,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL,
	PRIMARY KEY (product_id, start_dt, supplier_id),
	FOREIGN KEY (product_id, start_dt) REFERENCES bl_3nf.ce_products_scd (product_id, start_dt),
	FOREIGN KEY (supplier_id) REFERENCES bl_3nf.ce_suppliers (supplier_id)
);


CREATE TABLE IF NOT EXISTS bl_3nf.warehouses_products(
	product_id bigint NOT NULL,
	start_dt timestamptz NOT NULL,
	warehouse_id bigint NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	warehouse_product_src_id varchar(1000) NOT NULL ,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL,
	PRIMARY KEY (product_id, start_dt,warehouse_id),
	FOREIGN KEY (product_id, start_dt) REFERENCES bl_3nf.ce_products_scd (product_id, start_dt),
	FOREIGN KEY (warehouse_id) REFERENCES bl_3nf.ce_warehouses (warehouse_id)
);

CREATE TABLE IF NOT EXISTS bl_3nf.ce_sales(
	sale_id bigint PRIMARY KEY,	
	product_id bigint NOT NULL,
	product_start_dt timestamptz NOT NULL,
	customer_id bigint NOT NULL,
	promotion_id bigint NOT NULL,
	quantity int NOT NULL,
	event_dt timestamptz NOT NULL,
	cost_tot numeric(13,6) NOT NULL,
	price_tot numeric(13,6) NOT NULL,
	profit numeric(13,6),
	margin_pct numeric(6,4),
	payment_type varchar(10) NOT NULL,
	sales_person_id bigint NOT NULL,
	checkout_type varchar(20) NOT NULL,
	transaction_number varchar(20) NOT NULL,
	delivery_id bigint NOT NULL,
	source_system varchar(1000) NOT NULL,
	source_entity varchar(1000) NOT NULL,
	sale_src_id varchar(1000) NOT NULL,
	ta_insert_dt timestamptz NOT NULL,
	ta_update_dt timestamptz NOT NULL,
	FOREIGN KEY (customer_id) REFERENCES bl_3nf.ce_customers(customer_id),
	FOREIGN KEY (promotion_id) REFERENCES bl_3nf.ce_promotions(promotion_id),
	FOREIGN KEY (sales_person_id) REFERENCES bl_3nf.ce_employees(employee_id),	
	FOREIGN KEY (delivery_id) REFERENCES bl_3nf.ce_deliveries(delivery_id)
);

CREATE SEQUENCE IF NOT EXISTS bl_3nf.sqc_sales AS BIGINT MINVALUE 1;

COMMIT;