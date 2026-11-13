-- foreign (external) table for loading data from scv

BEGIN;
CREATE EXTENSION IF NOT EXISTS file_fdw;

CREATE SERVER IF NOT EXISTS pglog FOREIGN DATA WRAPPER file_fdw;

-- Run with caution: when creating an external table, the full path to the SCV file is used.
CREATE FOREIGN TABLE IF NOT EXISTS sa_grocery_instore_sales.ext_source2_offline(
	SalesID VARCHAR(1000),
	SalesPersonID VARCHAR(1000),
	CustomerID VARCHAR(1000),
	ProductID VARCHAR(1000),
	Quantity VARCHAR(1000),
	TotalPrice VARCHAR(1000),
	SalesDate VARCHAR(1000),
	TransactionNumber VARCHAR(1000),
	Price VARCHAR(1000),
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
	CheckoutType VARCHAR(1000),
	EmployeeID VARCHAR(1000),
	EmployeeFirstName VARCHAR(1000),
	EmployeeMiddleInitial VARCHAR(1000),
	EmployeeLastName VARCHAR(1000),
	BirthDate VARCHAR(1000),
	Gender VARCHAR(1000),
	SalesCityID VARCHAR(1000),
	HireDate VARCHAR(1000),
	EmployeeSkillLevel VARCHAR(1000),
	CityName VARCHAR(1000),
	StoreZipcode VARCHAR(1000),
	StoreID VARCHAR(1000),
	CustomerCityID VARCHAR(1000),
	CustomerAddress VARCHAR(1000),
	CustomerFullName VARCHAR(1000),
	CustomerBirthDate VARCHAR(1000),
	CustomerPhoneNumber VARCHAR(1000),
	CustomerCityName VARCHAR(1000),
	CustomerZipcode VARCHAR(1000),
	ProductName VARCHAR(1000),
	Class VARCHAR(1000),
	ModifyDate VARCHAR(1000),
	CategoryName VARCHAR(1000),
	SubcategoryName VARCHAR(1000),
	CategoryID VARCHAR(1000)
) SERVER pglog
OPTIONS (filename 'full_path.csv', format 'csv',HEADER 'true');

COMMIT;