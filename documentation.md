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



