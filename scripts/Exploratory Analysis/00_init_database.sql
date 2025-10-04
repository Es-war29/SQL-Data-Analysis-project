/*
  Create a database with the name datawarehouse
  Create  schemas gold
  Create 3 tables dim_customers,dim_products,fact_sales
  Load data into the tables 
*/
-- creating database
CREATE DATABASE DW_House;
USE DATABASE DW_House;

-- creating schema
create schema gold;

-- creating tables and loading the data
create or replace DIM_CUSTOMERS(
	CUSTOMER_KEY INT,
	CUSTOMER_ID INT,
	CUSTOMER_NUMBER varchar(50),
	FIRST_NAME varchar(50),
	LAST_NAME varchar(50),
	MARITAL_STATUS varchar(50),
	BIRTHDATE DATE,
	GENDER varchar(50),
	COUNTRY varchar(50),
	CREATE_DATE DATE
);
create or replace view FACT_SALES(
	ORDER_NUMBER varchar(50),
	PRODUCT_KEY INT,
	CUSTOMER_KEY INT,
	ORDER_DATE DATE,
	SHIPPING_DATE DATE,
	DUE_DATE DATE,
	PRICE INT,
	QUANTITY INT,
	SALES_AMOUNT INT
);

create or replace view DW_HOUSE.GOLD.DIM_PRODUCTS(
	PRODUCT_KEY INT,
	PRODUCT_ID INT,
	PRODUCT_NUMBER varchar(50),
	PRODUCT_NAM varchar(50),
	CATEGORY_ID varchar(50),
	CATEGORY varchar(50),
	SUBCATEGORY varchar(50),
	MAINTENANCE varchar(50),
	COST INT,
	PRODUCT_LINE varchar(50),
	START_LINE DATE
);

-- Load the data into tables
-- click on the table you have created and select load data
-- upload the file - downloaded from the datasets link :(https://github.com/Es-war29/SQL-Data-Analysis-project/tree/main/datasets)


