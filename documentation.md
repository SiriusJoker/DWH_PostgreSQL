# __OFFLINE AND ONLINE GROCERY SALES AND DELIVERY__

<img width="415" height="83" alt="изображение" src="https://github.com/user-attachments/assets/296ec4f6-6cba-4bfb-a6bb-7551ccc0a30e" />

## Business Description

### Business Background

Grocery shopping is an essential part of modern life. Retail stores provide a wide range of products that support different diets, lifestyles, and everyday needs. Since the COVID-19 pandemic in 2019-2020, online grocery shopping has become a normal part of consumer behavior.
What started as a necessity has turned into a convenient option used alongside traditional in-store shopping. Today, grocery businesses operate in both physical and digital channels, which makes sales analysis important for understanding customer behavior and improving business decisions. 

### Problems because of poor data management

Data quality issues directly affect customer experience, satisfaction, and retention, so ineffective data management leads to lost revenue and inefficient business processes. Employees spend their time resolving data incidents instead of helping businesses to grow.

### Benefits from implementing a Data Warehouse

- A data warehouse provides a unified and consistent view of retail operations across online and offline channels, integrating sales, product, promotion, and customer data into a single analytical framework.
- It enables centralized historical storage of data, ensuring that business performance can be tracked over time without fragmentation between systems.
- It supports scalable analysis of large retail datasets, allowing efficient aggregation of sales, revenue, and discount metrics across multiple dimensions such as category, channel, and campaign.
- It enhances decision-making by providing a structured foundation for performance monitoring, trend analysis, and comparative reporting between business segments.
- It enables efficient integration of new data sources, supporting future expansion such as additional sales channels, loyalty systems, or supplier data.

### Datasets description

#### The first dataset represents a broader retail view focused on online sales.

##### Product Information

&ensp;&ensp; ProductID: Product identifier

&ensp;&ensp; ProductName: Name of the product

&ensp;&ensp; Price: Unit price

&ensp;&ensp; CategoryID: Product category identifier

&ensp;&ensp; CategoryName: Name of the category

&ensp;&ensp; SubcategoryName: Name of the subcategory

&ensp;&ensp; Class: Product classification (e.g., Low / Medium / High)

&ensp;&ensp; ModifyDate: Last product update date

&ensp;&ensp; Resistant: Product resistance attribute

&ensp;&ensp; IsAllergic: Indicates allergen-related properties

&ensp;&ensp; VitalityDays: Shelf-life or durability measure

##### Supplier Information

&ensp;&ensp; SupplierID: Supplier identifier

&ensp;&ensp; SupplierName: Supplier name

&ensp;&ensp; SupplierRating: Supplier performance score

&ensp;&ensp; ContractStartDate: Start date of supplier agreement

##### Customer Information

&ensp;&ensp; CustomerID: Customer identifier

&ensp;&ensp; CustomerFirstName, CustomerMiddleInitial, CustomerLastName: Customer name details

&ensp;&ensp; Email: Customer email address

&ensp;&ensp; DeliveryAddress: Delivery location

&ensp;&ensp; DeliveryCityName: City of delivery

&ensp;&ensp; DeliveryZipcode: Postal code

&ensp;&ensp; RegistrationDate: Customer registration date

&ensp;&ensp; FirstSaleDate: First purchase date

##### Warehouse Information

&ensp;&ensp; WarehouseID: Warehouse identifier

&ensp;&ensp; WarehouseCityName: Location of warehouse

&ensp;&ensp; WarehouseName: Warehouse name

&ensp;&ensp; Capacity: Storage capacity

&ensp;&ensp; OperatingCost: Operational cost

&ensp;&ensp; ManagerName: Warehouse manager name

&ensp;&ensp; WarehouseLoadFactor: How busy a warehouse is relative to normal capacity.

##### Promotion Campaign Information

&ensp;&ensp; PromotionID: Applied promotion (if any)

&ensp;&ensp; PromotionName: Name of the promotion

&ensp;&ensp; Channel: Sales channel (Online / Offline / Both)

&ensp;&ensp; StartDate: Promotion start date

&ensp;&ensp; EndDate: Promotion end date

&ensp;&ensp; CampaignID: Marketing campaign identifier

&ensp;&ensp; CampaignName: Campaign description

&ensp;&ensp; Discount: Discount applied to the sale

##### Sales Information

&ensp;&ensp; SalesID: Unique identifier for each transaction

&ensp;&ensp; CustomerID: Identifier of the customer

&ensp;&ensp; ProductID: Identifier of the product sold

&ensp;&ensp; Quantity: Number of units purchased

&ensp;&ensp; TotalPrice: Total transaction value

&ensp;&ensp; SalesDate: Date of the transaction

&ensp;&ensp; TransactionNumber: Unique transaction reference

&ensp;&ensp; ShippingCost: Delivery cost associated with the order

&ensp;&ensp; DeliveryDate: Date of delivery

&ensp;&ensp; UnitCost: Cost per single unit of the product

&ensp;&ensp; Cost: Total cost for the transaction (UnitCost × Quantity)

&ensp;&ensp; Profit: Difference between TotalPrice and Cost

&ensp;&ensp; MarginPct: Profit as a percentage of TotalPrice

&ensp;&ensp; PaymentType: Payment type (Card, PayPal, Apple Pay)

#### The second dataset represents a store-level sales system enriched with employee and geographic information, primarily focused on offline operations. 

##### Sales Information

&ensp;&ensp; SalesID: Unique identifier for each transaction

&ensp;&ensp; SalesPersonID: Employee responsible for the sale

&ensp;&ensp; CustomerID: Customer identifier

&ensp;&ensp; ProductID: Product identifier

&ensp;&ensp; Quantity: Number of units sold

&ensp;&ensp; TotalPrice: Total transaction value

&ensp;&ensp; SalesDate: Date of sale

&ensp;&ensp; TransactionNumber: Transaction reference

&ensp;&ensp; Price: Unit product price

&ensp;&ensp; UnitCost: Cost per single unit of the product

&ensp;&ensp; Cost: Total cost for the transaction (UnitCost × Quantity)

&ensp;&ensp; Profit: Difference between TotalPrice and Cost

&ensp;&ensp; MarginPct: Profit as a percentage of TotalPrice

&ensp;&ensp; CheckoutType: Method used at checkout (cashier-assisted , self-checkout)

##### Promotion Campaign Information

&ensp;&ensp; PromotionID: Applied promotion identifier

&ensp;&ensp; PromotionName: Promotion name

&ensp;&ensp; Discount: Discount applied to the sale

&ensp;&ensp; Channel: Sales channel indicator

&ensp;&ensp; StartDate: Promotion start date

&ensp;&ensp; EndDate: Promotion end date

&ensp;&ensp; CampaignID: Marketing campaign identifier

&ensp;&ensp; CampaignName: Campaign name

##### Employee Information

&ensp;&ensp; EmployeeID: Employee identifier

&ensp;&ensp; EmployeeFirstName, EmployeeMiddleInitial, EmployeeLastName: Employee details

&ensp;&ensp; BirthDate: Employee date of birth

&ensp;&ensp; Gender: Employee gender

&ensp;&ensp; HireDate: Employment start date

&ensp;&ensp; EmployeeSkillLevel: Indicator of an employee’s performance (Low ,Medium , High)

##### Store Information

&ensp;&ensp; SalesCityID: Identifier of sales city

&ensp;&ensp; CityName: City of the store

&ensp;&ensp; StoreZipcode: Postal code

&ensp;&ensp; StoreID: Store identifier

##### Customer Information

&ensp;&ensp; CustomerID: Customer identifier

&ensp;&ensp; CustomerFullName: Full name of customer

&ensp;&ensp; CustomerPhoneNumber: Contact number

&ensp;&ensp; CustomerAddress: Customer address

&ensp;&ensp; CustomerCityID: Identifier of customer city

&ensp;&ensp; CustomerBirthDate: Customer date of birth

&ensp;&ensp; CustomerCityName: City of customer address

&ensp;&ensp; CustomerZipcode: Postal code of customer address

##### Product Information

&ensp;&ensp; ProductName: Name of the product

&ensp;&ensp; Price: Unit price

&ensp;&ensp; CategoryID: Category identifier

&ensp;&ensp; CategoryName: Name of the category

&ensp;&ensp; SubCategoryName: Name of the subcategory

&ensp;&ensp; Class: Product classification (e.g., Low / Medium / High)

&ensp;&ensp; ModifyDate: Last product update date

The datasets represent a unified system covering online and offline sales. They support analysis of sales performance, promotion effectiveness, product and category performance, customer behavior, employee impact, and operational efficiency across suppliers and warehouses.
Together, they form a structured foundation for a retail data warehouse and business intelligence reporting.

### Business grain. Dimensions and Facts.

#### Business Process. 

There are 2 processes described by this dataset. It is the process of receiving payment from a customer for individual products either online or in-store. And the process of delivering products to customers.

#### The Grain.

After analysing the business process, looking at the available data, and experimenting with it, it was determined that one row represents one transaction involving some quantity of exactly one product. There is no order or grocery basket. Each transaction is a single-product sale, so transaction-level attributes are not repeated across multiple product rows. 

And for the second process one row in the fact table represents one delivery to the customer.

#### Dimensions.

##### Sale process:

_CUSTOMER_ Customer dimension describes who buys the product.

_PRODUCT_ Product dimension describes what the customer is buying.

_WAREHOUSE_ Subdimension describes where product is stored.

_SUPPLIER_ Subdimension described from where product is supplied.

_STORE_ Store dimension describes where the event takes place.

_EMPLOYEE_ Employee dimension describes the person who helps the event to happen. 

_PROMOTION_ Promotion dimension describes discount that affected the event

_DATE_ Date dimension describes time related aspects of sale event.
	
##### Delivery process:

_ADDRESS_ Where delivery is made.

_DATE_ Date dimension describes time related aspects of delivery event.

#### Facts. 

_Sale process_ The process is measuring total price that was paid for product

_Delivery process_ The process is measuring delivery cost.

__Customer dim.__ 

Customer is a dimension that includes name, contact details (email, phone number, address), registration information, and first purchase date. 

|  Column name  |  Description  |  Data type  |
|---|---|---|
| Customer_surr_ID | Customer surrogate identifier | integer |
| Customer_src_ID | Customer natural key | varchar(255) |
| CustomerFirstName | Customer first name | varchar(25) |
| CustomerMiddleInitial | First letter of a customer's middle name | varchar(2) |
| CustomerLastName | Customer last name | varchar(25) |
| CustomerFullName | Customer full name | varchar(55) |
| Email | Customer email | varchar(50) |
| RegistrationDate | Date of customer registration in online store | timestamptz |
| FirstSaleDate | Date when customer made first purchase in online store | timestamptz |
| CustomerPhoneNumber | Customer phone number | varchar(16) |
| CustomerAddress | Customer address | varchar(200) |
| CustomerCityID | Customer city identifier | integer |
| CustomerBirthDate | Customer date of birth | timestamptz |
| CustomerCityName | City of customer address | varchar(50) |
| CustomerZipcode | Postal code of customer address | varchar(9) |

Customer details from online store data. Example

|  Customer_surr_ID  |  Customer_src_ID  |  CustomerFirstName  |  CustomerMiddleInitial  |  CustomerLastName  |  Email  |  RegistrationDate  |  FirstSaleDate  |
|----------|----------|--------|---|-------|----------------------------|---------------------|---|
| 58112142 | 581sfg12 | Deanna | F | Wolfe | deanna.wolfe8364@yahoo.com | 2023-08-24 03:19:39 | 2024-02-02 03:19:39 | 

Customer details from in-store data. Example  
|  Customer_surr_ID  |  Customer_src_ID  |  CustomerFullName  |  CustomerPhoneNumber |  CustomerAddress  |  CustomerCityID  |  CustomerBirthDate  |  CustomerCityName  |  CustomerZipcode  |
|--------------------|-------------------|--------------------|----------------------|-------------------|------------------|---------------------|--------------------|-------------------|
| 2384573            | 80308             | Yesenia N Ryan     | +1 617-363-1193      | 233 Rocky Nobel Boulevard | 9        | 1968-06-29 09:31:05 | Atlanta            | 66212             | 

__Product dim.__

Product dimension includes name, unit price, category, subcategory, product details, supplier details and warehouse details

|  Column name  |  Description  |  Data type  |  
|---|---|---|
| Product_surr_ID |  Product surrogate identifier | integer |
| Product_src_ID | Product natural key | varchar(255) |
| ProductName | Name of product | varchar(100) |
| CategoryID | Category identifier | integer |
| CategoryName | Name of category | varchar(50) |
| SubCategoryName | Name of the subcategory | varchar(50) |
| Class | Product classification | varchar(6) |
| ModifyDate | Last product update date | timestamptz |
| Resistant | Product resistance attribute | varchar(7) |
| IsAllergic | Indicates allergen-related properties | varchar(7) |
| VitalityDays | Shelf-life or durability measure | numeric(4,1) |

Product details from online store data. Example

|  Produc_surr_ID  |  Product_src_ID  |  ProductName  |  CategoryID  |  CategoryName  |  SubcategoryName  |  Class  |  ModifyDate  |  Resistant  |  IsAllergic  |  VitalityDays  |  WarehouseID  |
|-------------------|------------------|---------------|--------------|----------------|-------------------|---------|--------------|-------------|--------------|----------------|---------------|
|  372              | 453wer72       | Wine - Two Oceans Cabernet | 1 | Beverages      | Alcohol           | Low | 2018-01-22 14:32:24.580 | Unknown | True      | 0.0            | 8             |

Product details from in-store data. Example

|  Product_surr_ID  |  Product_src_ID  |  ProductName  |  CategoryID  |  CategoryName  |  SubcategoryName  |  Class  |  ModifyDate  |
|-------------------|------------------|---------------|--------------|----------------|-------------------|---------|--------------|
| 237468            | 271             | Banana - Leaves | 2           | Food           | Produce           | High | 2017-08-13 12:39:01.070 |

__Warehouse dim.__

|  Column name  |  Description  |  Data type  |  
|---|---|---|
| WarehouseID | Warehouse identifier | integer |
| WarehouseCityName | City where is the warehouse located | varchar(50) |
| WarehouseName | Warehouse name | varchar(50) |
| Capacity | Warehouse storage capacity in cubic meters | numeric(7,2) |
| OperatingCost | Operational cost per year | integer |
| ManagerName | Warehouse manager name | varchar(50) |
| WarehouseLoadFactor | Business factor | numeric(7,6) |

|  WarehouseID  |  WarehouseCityName  |  WarehouseName  |  Capacity  |  OperatingCost  |  ManagerName  |  WarehouseLoadFactor  |
|---------------|---------------------|-----------------|------------|-----------------|---------------|-----------------------|
| 8             | Newark              | Regional Depot B | 27401     | 28081           | Sarah Wilson  | 1.224617 |

__Supplier dim.__

|  Column name  |  Description  |  Data type  |
|---|---|---|
| SupplierID | Supplier identifier | integer |
| SupplierName | Supplier company name | varchar(50) |
| SupplierRating | Supplier performance score | smallint |
| ContractStartDate | Start date of supplier agreement | date |

| SupplierID | SupplierName | SupplierRating | ContractStartDate |
|---|---|---|---|
|  3 | Prime Foods | 3 | 2025-02-19 | 

__Store dim.__
	Store dimension includes identifier and city details where the store is located.

|  Column name  |  Description  |  Data type  |  
|---|---|---|
| Store_surr_ID | Store surrogate identifier | integer |
| Store_src_ID | Store natural identifier | varchar(255) |
| SalesCityID | City where store is placed identifier | integer |
| CityName | City where store is located | varchar(50) |
| StoreZipcode | Store postal code | varchar(9) |

Store details available only from in-store data. Example

| Store_surr_ID | StoreID | SalesCityID | CityName | Zipcode |
|---------------|---------|-------------|----------|---------|
| 12432         | 1267    | 4           | Fremont  | 20641   | 

__Employee dim.__
	Employee dimension includes identifier, name, personal details and hire date

|  Column name  |  Description  |  Data type  |  
|---|---|---|
| Employee_surr_ID | Employee surrogate identifier | integer |
| Employee_src_ID | Employee natural identifier | varchar(255) |
| EmployeeFirstName | Employee First Name | varchar(25) |
| EmployeeMiddleInitial | First letter of an employee's middle name | varchar(2) |
| EmployeeLastName | Employee last name | varchar(25) |
| BirthDate | Employee date of birth | timestamptz |
| Gender | Employee gender | char(1) |
| HireDate | Employment start date | timestamptz |
| EmployeeSkillLevel | Indicator of an employee’s performance | varchar(6)|

Employee details available only from in-store data. Example

| Employee_surr_ID | Employee_src_ID | EmployeeFirstName | EmployeeMiddleInitial | EmployeeLastName | BirthDate | Gender | HireDate | EmployeeSkillLevel |
|------------------|-----------------|-------------------|-----------------------|------------------|-----------|--------|----------|--------------------|
| 245242           | 22              | Christine         | W                     | Palmer           | 1968-01-25 | F  | 2011-04-27 04:07:56.930 | Medium | 

__Promotion dim.__
	Promotion dimension includes promotion details, dates and campaign details

|  Column name  |  Description  |  Data type  |  
|---|---|---|
| Promotion_surr_ID | Applied promotion surrogate identifier | integer |
| Promotion_src_ID | Applied promotion natural identifier | varchar(255) |
| PromotionName | Promotion name | varchar(50) |
| Discount | Discount applied to the sale | numeric(3,2) |
| Channel | Sales channel indicator | varchar(7) |
| StartDate | Promotion start date | date |
| EndDate | Promotion end date | date |
| CampaignID | Promotion campaign identifier | integer |
| CampaignName | Campaign name | varchar(50) |

Promotion data from online and in-store data is schematically the same. Example

| Promotion_surr_ID | Promotion_src_ID | PromotionName | Discount | Channel | StartDate | EndDate | CampaignID | CampaignName |
|-------------------|------------------|---------------|----------|---------|-----------|---------|------------|--------------|
| 2                 | 2weufh34         | Promo_2       | 0.3      | Online  | 2025-11-24 | 2025-12-23 | 5 | Loyalty Rewards | 

__Addresses dim.__

Includes Address and city of delivery.

|  Column name  |  Description  |  Data type  |  
|---|---|---|
| Address_surr_ID | Address surrogate identifier | integer |
| DeliveryAddress | Address of delivery | varchar(255) |
| DeliveryCityID | Delivery city identifier | integer |
| DeliveryZipcode | Delivery city postal code | varchar(9) |
| DeliveryCityName | Name of city where product will be delivered | varchar(50) |

| Address_surr_ID | DeliveryAddress | DeliveryCityID | DeliveryZipcode | DeliveryCityName |
|-----------------|-----------------|----------------|-----------------|------------------|
| 234   | 233 Rocky Nobel Boulevard | 9              | 6621            | Atlanta          | 

__Fact sale__
	Fact table includes an identifier, foreign keys to dimensions, product quantity, total price, sales and delivery date, and delivery cost (for online purchases). 

|  Column name  |  Description  |  Data type  |  
|---|---|---|
| Sales_surr_ID | Sale surrogate identifier | integer |
| Sales_src_ID | Sale natural identifier | varchar(255) |
| SalesPersonID | Sales person identifier | integer |
| CustomerID | Customer identifier | integer |
| ProductID | Product identifier | integer |
| Quantity | Quantity of product | integer |
| TotalPrice | Total price paid for product | numeric(13,6) |
| SalesDateID | Sales date identifier | integer |
| TransactionNumber | Transaction code | text |
| PromotionID | Applied promotion identifier | integer |
| StoreID | Store identifier | integer |
| Price | Product unit price | numeric(11,6) |
| UnitCost | Product unit cost | numeric(11,6) |
| Cost | Total cost for the transaction | numeric(13,6) |
| Profit | Difference between TotalPrice and Cost | numeric(13,6) |
| MarginPct | Profit as a percentage of TotalPrice | numeric(6,4) |
| Discount | Discount applied to the sale | numeric(6,4) |
| Payment type | Payment type | varchar(50) |
| Checkout type | Checkout type | varchar(50) |

Example of Fact detail from online data.

| Sales_surr_ID | Sales_src_ID | CustomerID | ProductID | Quantity | TotalPrice | SalesDateID | TransactionNumber | PromotionID | Cost | Price | UnitCost | Profit | MarginPct | Discount | PaymentType |
|---------------|--------------|------------|-----------|----------|------------|-------------|-------------------|-------------|------|-------|----------|--------|-----------|----------|-------------|
| 20181234012   | 2018012      | 53884      | 372       | 14       | 79.15824   | 2026021  | OX1D4LVVQRC5PF6BTVVJ | 10      | 79.15824 | 6.2824 | 5.65416 | -0.0   | -0.0      | 0.1      | Paypal      |

Fact detail from in-store data

| Sales_surr_ID | Sales_src_ID | SalesPersonID | CustomerID | ProductID | Quantity | TotalPrice | SalesDateID | TransactionNumber | PromotionID | StoreID | Price | CheckoutType | UnitCost | Cost | Profit | MarginPct | Discount |  
|---------------|--------------|---------------|------------|-----------|----------|------------|-------------|-------------------|-------------|---------|-------|--------------|----------|------|--------|-----------|----------|
| 502           | 5025190      | 22            | 80308      | 271       | 21       | 1387.17306 | 202404   | DXAGNFCP8DYJ0C4VYQVP | 2           | 7041  | 73.3954 | Cashier | 62.873724 | 1320.348194 | 66.824866 | 4.817342 | 0.1 | 

Fact delivery process.
	It includes identifier, cost measure and keys to date dimension, addresses dimension and customers dimension.

|  Column name  |  Description  |  Data type  |  
|---|---|---|
| Delivery_surr_ID | Delivery surrogate identifier | BIGINT |
| DeliveryAddress_ID | Delivery address identifier | integer |
| DeliveryDate_ID | Date of delivery identifier | integer |
| DeliveryDate | Date of delivery | timestamptz |
| DeliveryCost | Price of delivery | numeric(11,6) |
| Customer_ID | Identifier of customer who ordered a delivery | integer |

This fact table is related only to online sales.

| Delivery_surr_ID | DeliveryAddress_ID | DeliveryDate_ID | DeliveryDate | DeliveryCost | Customer_ID |
|------------------|--------------------|-----------------|--------------|--------------|-------------|
| 234234           | 24324              | 20260326       | 2026-03-26 04:07:56.930 | 2.921884 | 34535 |

Date dimension. Conformed dimension
	

|  Column name  |  Description  |  Data type  |  
|---|---|---|
| DateID | Surrogate date key | integer |
| FullDate | Actual date | Date |
| DayNumberOfMonth | Day of month (1–31) | Small int |
| MonthNumber | Month number (1–12) | Small int |
| MonthName | Month name | varchar(15) |
| Year | Calendar year | Small int |
| WeekNumberOfYear | Calendar week number | Small int |
| QuarterNumber | Quarter (1–4) | Small int |
| DayOfWeek | Name of day of week | varchar(10) |
| FiscalYear | Fiscal Year | Small int |
| FiscalQuarter | Fiscal Quarter | Small int |
| FiscalMonth | Fiscal Month | Small int |
| FiscalWeek | Fiscal week | Small int |

| SalesDateID | FullDate | DayNumberOfMonth | MonthNumber | MonthName | Year | WeekNumberOfYear | QuarterNumber | DayOfWeek | FiscalYear | FiscalQuarter | FiscalMonth | FiscalWeek |
|-------------|----------|------------------|-------------|-----------|------|------------------|---------------|-----------|------------|---------------|-------------|------------|
| 202601017687687 | 2026-01-01 | 1          | 1           | January   | 2026 | 1                | 1             | monday    | 2026       | 1             | 1           | 1          |








