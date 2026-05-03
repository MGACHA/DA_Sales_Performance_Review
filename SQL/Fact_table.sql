-- Step 5.1: Drop the fact table if it already exists.
IF OBJECT_ID('warehouse.FACT_Sales', 'U') IS NOT NULL
    DROP TABLE warehouse.FACT_Sales;

-- Step 5.2: Create the fact table structure.
CREATE TABLE warehouse.FACT_Sales (
    Date_Key INT NOT NULL,
    Sales_ID INT NOT NULL,
    Sales_Rep_ID INT NOT NULL,
    Customer_ID INT NOT NULL,
    Promotion_ID INT NOT NULL,
    Quantity INT NOT NULL,
    Revenue_GBP DECIMAL(18, 2) NOT NULL,
    Unit_Price_GBP DECIMAL(18, 4) NOT NULL,
    Has_Promotion_Flag BIT NOT NULL,
    CONSTRAINT PK_FACT_Sales PRIMARY KEY CLUSTERED (Sales_ID)
);

-- Step 5.3: Load the fact table from staging.Sales_Data.
INSERT INTO warehouse.FACT_Sales (
    Date_Key,
    Sales_ID,
    Sales_Rep_ID,
    Customer_ID,
    Promotion_ID,
    Quantity,
    Revenue_GBP,
    Unit_Price_GBP,
    Has_Promotion_Flag
)
SELECT
    CAST(CONVERT(char(8), s.[Date], 112) AS INT) AS Date_Key,
    s.Sales_ID,
    s.Sales_Rep_ID,
    s.Customer_ID,
    COALESCE(CAST(s.Promotion_ID AS INT), 0) AS Promotion_ID,
    s.Quantity,
    s.Value AS Revenue_GBP,
    CAST(s.Value * 1.0 / NULLIF(s.Quantity, 0) AS DECIMAL(18, 4)) AS Unit_Price_GBP,
    CASE WHEN s.Promotion_ID IS NOT NULL THEN 1 ELSE 0 END AS Has_Promotion_Flag
FROM staging.Sales_Data s
WHERE s.Sales_ID IS NOT NULL
  AND s.Quantity > 0
  AND s.Value > 0;

-- Step 5.4: Validate and enforce keys on dimension tables before adding FKs.

-- Step 5.4.1: DIM_Sales_Rep must have non-null, unique Sales_Rep_ID values.
IF EXISTS (SELECT 1 FROM warehouse.DIM_Sales_Rep WHERE Sales_Rep_ID IS NULL)
    THROW 50021, 'Step 5.4.1 failed: DIM_Sales_Rep has NULL Sales_Rep_ID values.', 1;

IF EXISTS (
    SELECT Sales_Rep_ID
    FROM warehouse.DIM_Sales_Rep
    GROUP BY Sales_Rep_ID
    HAVING COUNT(*) > 1
)
    THROW 50022, 'Step 5.4.1 failed: DIM_Sales_Rep has duplicate Sales_Rep_ID values.', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE [type] = 'PK'
      AND [name] = 'PK_DIM_Sales_Rep'
      AND [parent_object_id] = OBJECT_ID('warehouse.DIM_Sales_Rep')
)
    THROW 50023, 'Step 5.4.1 failed: PK_DIM_Sales_Rep is missing. Re-run Step 4.2 first.', 1;

-- Step 5.4.2: DIM_Customer must have non-null Customer_ID and a PK.
ALTER TABLE warehouse.DIM_Customer
ALTER COLUMN Customer_ID INT NOT NULL;

IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE [type] = 'PK'
      AND [name] = 'PK_DIM_Customer'
      AND [parent_object_id] = OBJECT_ID('warehouse.DIM_Customer')
)
BEGIN
    ALTER TABLE warehouse.DIM_Customer
    ADD CONSTRAINT PK_DIM_Customer PRIMARY KEY CLUSTERED (Customer_ID);
END;

-- Step 5.4.3: DIM_Promotion must have non-null Promotion_ID and a PK.
ALTER TABLE warehouse.DIM_Promotion
ALTER COLUMN Promotion_ID INT NOT NULL;

IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE [type] = 'PK'
      AND [name] = 'PK_DIM_Promotion'
      AND [parent_object_id] = OBJECT_ID('warehouse.DIM_Promotion')
)
BEGIN
    ALTER TABLE warehouse.DIM_Promotion
    ADD CONSTRAINT PK_DIM_Promotion PRIMARY KEY CLUSTERED (Promotion_ID);
END;

-- Step 5.4.4: DIM_Date must have non-null Date_Key and a PK.
ALTER TABLE warehouse.DIM_Date
ALTER COLUMN Date_Key INT NOT NULL;

IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE [type] = 'PK'
      AND [name] = 'PK_DIM_Date'
      AND [parent_object_id] = OBJECT_ID('warehouse.DIM_Date')
)
BEGIN
    ALTER TABLE warehouse.DIM_Date
    ADD CONSTRAINT PK_DIM_Date PRIMARY KEY CLUSTERED (Date_Key);
END;

-- Step 5.5: Add the foreign keys one by one.

-- Step 5.5.1: Link FACT_Sales to DIM_Date.
ALTER TABLE warehouse.FACT_Sales
ADD CONSTRAINT FK_Sales_Date FOREIGN KEY (Date_Key) REFERENCES warehouse.DIM_Date(Date_Key);

-- Step 5.5.2: Link FACT_Sales to DIM_Sales_Rep.
ALTER TABLE warehouse.FACT_Sales
ADD CONSTRAINT FK_Sales_Rep FOREIGN KEY (Sales_Rep_ID) REFERENCES warehouse.DIM_Sales_Rep(Sales_Rep_ID);

-- Step 5.5.3: Link FACT_Sales to DIM_Customer.
ALTER TABLE warehouse.FACT_Sales
ADD CONSTRAINT FK_Customer FOREIGN KEY (Customer_ID) REFERENCES warehouse.DIM_Customer(Customer_ID);

-- Step 5.5.4: Link FACT_Sales to DIM_Promotion.
ALTER TABLE warehouse.FACT_Sales
ADD CONSTRAINT FK_Promotion FOREIGN KEY (Promotion_ID) REFERENCES warehouse.DIM_Promotion(Promotion_ID);
