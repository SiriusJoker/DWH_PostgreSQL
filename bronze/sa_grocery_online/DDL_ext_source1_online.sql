-- foreign (external) table for loading data from scv
BEGIN;
CREATE EXTENSION IF NOT EXISTS file_fdw;

CREATE SERVER IF NOT EXISTS pglog FOREIGN DATA WRAPPER file_fdw;

-- Run with caution: when creating an external table, the full path to the SCV file is used.
CREATE FOREIGN TABLE IF NOT EXISTS sa_grocery_online_sales.ext_source1_online(
	SalesID VARCHAR(1000),
	CustomerID VARCHAR(1000),
	ProductID VARCHAR(1000),
	Quantity VARCHAR(1000),
	TotalPrice VARCHAR(1000),
	SalesDate VARCHAR(1000),
	TransactionNumber VARCHAR(1000),
	PromotionID VARCHAR(1000),
	UnitCost VARCHAR(1000),
	Cost VARCHAR(1000),
	Profit VARCHAR(1000),
	MarginPct VARCHAR(1000),
	PromotionName VARCHAR(1000),
	Discount VARCHAR(1000),
	Channel VARCHAR(1000),
	StartDate VARCHAR(1000),
	EndDate VARCHAR(1000),
	CampaignID VARCHAR(1000),
	CampaignName VARCHAR(1000),
	DeliveryDate VARCHAR(1000),
	ProductName VARCHAR(1000),
	Price VARCHAR(1000),
	Class VARCHAR(1000),
	ModifyDate VARCHAR(1000),
	Resistant VARCHAR(1000),
	IsAllergic VARCHAR(1000),
	VitalityDays VARCHAR(1000),
	CategoryName VARCHAR(1000),
	SubcategoryName VARCHAR(1000),
	CategoryID VARCHAR(1000),
	SupplierID VARCHAR(1000),
	WarehouseID VARCHAR(1000),
	WarehouseLoadFactor VARCHAR(1000),
	ShippingCost VARCHAR(1000),
	PaymentType VARCHAR(1000),
	CustomerFirstName VARCHAR(1000),
	CustomerMiddleInitial VARCHAR(1000),
	CustomerLastName VARCHAR(1000),
	DeliveryAddress VARCHAR(1000),
	DeliveryCityName VARCHAR(1000),
	DeliveryZipcode VARCHAR(1000),
	Email VARCHAR(1000),
	FirstSaleDate VARCHAR(1000),
	RegistrationDate VARCHAR(1000),
	SupplierName VARCHAR(1000),
	SupplierRating VARCHAR(1000),
	ContractStartDate VARCHAR(1000),
	WarehouseCityName VARCHAR(1000),
	WarehouseName VARCHAR(1000),
	Capacity VARCHAR(1000),
	OperatingCost VARCHAR(1000),
	ManagerName VARCHAR(1000)
) SERVER pglog
OPTIONS (filename 'full_path.csv', format 'csv',HEADER 'true');

COMMIT;