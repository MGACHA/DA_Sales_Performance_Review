use DA_Sales
-- 4.1 DIM_Region (Consolidate UK, GB, England)
SELECT
    Region_ID,
    CASE
        WHEN Region IN ('UK', 'GB', 'England') THEN 'United Kingdom'
        ELSE Region
    END AS Region_Name,
    CASE
        WHEN Region IN ('UK', 'GB', 'England') THEN 'GBP'
        ELSE Currency_Used
    END AS Currency_Used,
    CASE
        WHEN Region IN ('UK', 'GB', 'England') THEN 1.0
        ELSE ISNULL(Exchange_Rate_to_GBP, 1.0)
    END AS Exchange_Rate_to_GBP
INTO warehouse.DIM_Region
FROM staging.Region;

-- 4.2 DIM_Sales_Rep

SELECT
    Sales_Rep_ID,
    Sales_Rep_Name,
    Manager_Name,
    Years_Of_Service,
    CASE WHEN Is_On_Probation = 'Y' THEN 1 ELSE 0 END AS Is_On_Probation_Flag,
    Is_On_Probation AS Is_On_Probation_Code
INTO warehouse.DIM_Sales_Rep
FROM staging.Sales_Rep;

-- 4.3 DIM_Customer

SELECT
    Customer_ID,
    Name AS Customer_Name,
    Type AS Customer_Type,
    Region_ID
INTO warehouse.DIM_Customer
FROM staging.Customer;

-- 4.4 DIM_Promotion

IF OBJECT_ID('warehouse.DIM_Promotion', 'U') IS NOT NULL
    DROP TABLE warehouse.DIM_Promotion;

CREATE TABLE warehouse.DIM_Promotion (
    Promotion_ID INT NOT NULL,
    Reduction DECIMAL(5, 2) NOT NULL,
    Discount_Percentage INT NOT NULL,
    Promotion_Status NVARCHAR(30) NOT NULL,
    CONSTRAINT PK_DIM_Promotion PRIMARY KEY CLUSTERED (Promotion_ID)
);

INSERT INTO warehouse.DIM_Promotion (Promotion_ID, Reduction, Discount_Percentage, Promotion_Status)
SELECT
    Promotion_ID,
    Reduction,
    CAST(Reduction * 100 AS INT) AS Discount_Percentage,
    'Active' AS Promotion_Status
FROM staging.Promotion;

IF NOT EXISTS (SELECT 1 FROM warehouse.DIM_Promotion WHERE Promotion_ID = 0)
BEGIN
    INSERT INTO warehouse.DIM_Promotion (Promotion_ID, Reduction, Discount_Percentage, Promotion_Status)
    VALUES (0, 0.0, 0, 'No Promotion');
END;

-- 4.5 DIM_Date (Simple date dimension for 2026)

-- Step 1: Drop if exists
IF OBJECT_ID('warehouse.DIM_Date', 'U') IS NOT NULL
    DROP TABLE warehouse.DIM_Date;

-- Step 2: Create table with NOT NULL defined explicitly
CREATE TABLE warehouse.DIM_Date (
    Date_Key     INT          NOT NULL,
    Date_Value   DATE         NOT NULL,
    [Year]       SMALLINT     NOT NULL,
    [Month]      TINYINT      NOT NULL,
    [Day]        TINYINT      NOT NULL,
    Month_Start  DATE         NOT NULL,
    Month_End    DATE         NOT NULL,
    Month_Name   VARCHAR(10)  NOT NULL,
    Day_Name     VARCHAR(10)  NOT NULL,
    Week_Number  TINYINT      NOT NULL,
    [Quarter]    TINYINT      NOT NULL
);

-- Step 3: Insert data
WITH Date_Sequence AS (
    SELECT DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1, CAST('2026-01-01' AS DATE)) AS Date_Value
    FROM (SELECT TOP 366 1 AS n FROM sys.objects a CROSS JOIN sys.objects b) x
)
INSERT INTO warehouse.DIM_Date (
    Date_Key, Date_Value, [Year], [Month], [Day],
    Month_Start, Month_End, Month_Name, Day_Name, Week_Number, [Quarter]
)
SELECT
    CAST(CONVERT(CHAR(8), Date_Value, 112) AS INT),
    Date_Value,
    YEAR(Date_Value),
    MONTH(Date_Value),
    DAY(Date_Value),
    DATEFROMPARTS(YEAR(Date_Value), MONTH(Date_Value), 1),
    EOMONTH(Date_Value),
    DATENAME(MONTH, Date_Value),
    DATENAME(WEEKDAY, Date_Value),
    DATEPART(ISO_WEEK, Date_Value),
    DATEPART(QUARTER, Date_Value)
FROM Date_Sequence
WHERE Date_Value >= '2026-01-01' AND Date_Value < '2027-01-01';

-- Step 4: Add PK — now works because Date_Key is NOT NULL
ALTER TABLE warehouse.DIM_Date
ADD CONSTRAINT PK_DIM_Date PRIMARY KEY CLUSTERED (Date_Key);
