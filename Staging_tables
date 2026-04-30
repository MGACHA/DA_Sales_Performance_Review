------- create tables ---

CREATE TABLE staging.Sales_Data (
    Date DATE,
    Sales_ID INT,
    Sales_Rep_ID INT,
    Customer_ID INT,
    Quantity INT,
    Value DECIMAL(18, 2),
    Promotion_ID FLOAT 
);

CREATE TABLE staging.Promotion (
    Promotion_ID INT,
    Reduction DECIMAL(5, 2)
);

CREATE TABLE staging.Sales_Rep (
    Sales_Rep_ID INT,
    Sales_Rep_Name NVARCHAR(100),
    Manager_Name NVARCHAR(100),
    Years_Of_Service INT,
    Is_On_Probation CHAR(1)
);

CREATE TABLE staging.Customer (
    Customer_ID INT,
    Region_ID INT,
    Name NVARCHAR(100),
    Type NVARCHAR(50)
);


CREATE TABLE staging.Region (
    Region_ID INT,
    Region NVARCHAR(50),
    Currency_Used NVARCHAR(10),
    Exchange_Rate_to_GBP DECIMAL(10, 4)
);


------- insert data from csv ----


TRUNCATE TABLE staging.Sales_Data;
BULK INSERT staging.Sales_Data
FROM 'C:\project_5\csv_export\Sales_Data.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = '65001' --This file is encoded in UTF-8.
);

TRUNCATE TABLE staging.Promotion;
BULK INSERT staging.Promotion
FROM 'C:\project_5\csv_export\Promotion.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = '65001'
);

TRUNCATE TABLE staging.Sales_Rep;
BULK INSERT staging.Sales_Rep
FROM 'C:\project_5\csv_export\Sales_Rep.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = '65001'
);

TRUNCATE TABLE staging.Customer;
BULK INSERT staging.Customer
FROM 'C:\project_5\csv_export\Customer.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = '65001'
);

TRUNCATE TABLE staging.Region;
BULK INSERT staging.Region
FROM 'C:\project_5\csv_export\Region.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = '65001'
);

