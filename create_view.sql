-- 6.1 Executive KPI Summary
CREATE VIEW reporting.V_Executive_KPI AS
SELECT
    COUNT(DISTINCT f.Sales_ID) AS Total_Orders, -- Count unique orders.
    SUM(f.Revenue_GBP) AS Total_Revenue, -- Sum total revenue in GBP.
    SUM(f.Quantity) AS Total_Units, -- Sum total units sold.
    CAST(SUM(f.Revenue_GBP) / NULLIF(COUNT(DISTINCT f.Sales_ID), 0) AS DECIMAL(18, 2)) AS Avg_Order_Value, -- Compute AOV safely.
    CAST(SUM(f.Revenue_GBP) / NULLIF(SUM(f.Quantity), 0) AS DECIMAL(18, 4)) AS Revenue_Per_Unit, -- Compute revenue per unit safely.
    CAST(SUM(CASE WHEN f.Has_Promotion_Flag = 1 THEN 1 ELSE 0 END) * 100.0
         / NULLIF(COUNT(DISTINCT f.Sales_ID), 0) AS DECIMAL(5, 2)) AS Promo_Usage_Percentage -- Share of promo orders.
FROM warehouse.FACT_Sales f; -- Source fact table.

-- 6.2 Daily Trend
CREATE VIEW reporting.V_Daily_Trend AS
SELECT
    d.Date_Key, -- Numeric date key (YYYYMMDD).
    d.Date_Key AS Date, -- Alias for reporting visuals.
    COUNT(DISTINCT f.Sales_ID) AS Orders, -- Daily order count.
    SUM(f.Revenue_GBP) AS Revenue, -- Daily revenue.
    SUM(f.Quantity) AS Units, -- Daily units.
    CAST(SUM(f.Revenue_GBP) / NULLIF(COUNT(DISTINCT f.Sales_ID), 0) AS DECIMAL(18, 2)) AS AOV -- Daily average order value.
FROM warehouse.FACT_Sales f -- Fact source.
JOIN warehouse.DIM_Date d ON f.Date_Key = d.Date_Key -- Join to date dimension.
GROUP BY d.Date_Key; -- Aggregate per day.

-- 6.3 Sales Rep Performance
-- 6.3 Sales Rep Performance
CREATE OR ALTER VIEW reporting.V_Rep_Performance AS
SELECT
    r.Sales_Rep_ID, -- Sales rep key.
    r.Sales_Rep_Name, -- Sales rep name.
    r.Manager_Name, -- Rep manager.
    r.Is_On_Probation_Code, -- Probation code (Y/N).
    r.Years_Of_Service, -- Rep tenure.
    r.Is_On_Probation_Flag, -- Probation flag (bit).
    COUNT(DISTINCT f.Sales_ID) AS Orders, -- Orders by rep.
    COALESCE(SUM(f.Quantity), 0) AS Units, -- Units by rep (0 for reps with no sales).
    COALESCE(SUM(f.Revenue_GBP), 0) AS Revenue, -- Revenue by rep (0 for reps with no sales).
    COALESCE(CAST(SUM(f.Revenue_GBP) / NULLIF(COUNT(DISTINCT f.Sales_ID), 0) AS DECIMAL(18, 2)), 0) AS AOV, -- AOV by rep.
    COALESCE(CAST(SUM(CASE WHEN f.Has_Promotion_Flag = 1 THEN f.Revenue_GBP ELSE 0 END) AS DECIMAL(18, 2)), 0) AS Promo_Revenue -- Promo-attributed revenue.
FROM warehouse.DIM_Sales_Rep r -- Base on rep dimension so zero-sales reps remain visible.
LEFT JOIN warehouse.FACT_Sales f ON f.Sales_Rep_ID = r.Sales_Rep_ID -- Join matching sales rows when present.
GROUP BY r.Sales_Rep_ID, r.Sales_Rep_Name, r.Manager_Name, r.Is_On_Probation_Code,
         r.Years_Of_Service, r.Is_On_Probation_Flag; -- Aggregate per rep.

-- 6.4 Region Performance (with consolidated UK)
CREATE VIEW reporting.V_Region_Performance AS
SELECT
    rg.Region_ID, -- Region key.
    rg.Region_Name, -- Region label.
    rg.Currency_Used, -- Region currency.
    COUNT(DISTINCT f.Sales_ID) AS Orders, -- Orders by region.
    SUM(f.Quantity) AS Units, -- Units by region.
    SUM(f.Revenue_GBP) AS Revenue, -- Revenue by region.
    CAST(SUM(f.Revenue_GBP) / NULLIF(COUNT(DISTINCT f.Sales_ID), 0) AS DECIMAL(18, 2)) AS AOV -- AOV by region.
FROM warehouse.FACT_Sales f -- Fact source.
JOIN warehouse.DIM_Customer c ON f.Customer_ID = c.Customer_ID -- Map sale to customer.
JOIN warehouse.DIM_Region rg ON c.Region_ID = rg.Region_ID -- Map customer to region.
GROUP BY rg.Region_ID, rg.Region_Name, rg.Currency_Used; -- Aggregate per region.


-- 6.5 Customer Type Performance
CREATE VIEW reporting.V_Customer_Type_Performance AS
SELECT
    c.Customer_Type, -- Customer segment.
    COUNT(DISTINCT f.Sales_ID) AS Orders, -- Orders by customer type.
    SUM(f.Quantity) AS Units, -- Units by customer type.
    SUM(f.Revenue_GBP) AS Revenue, -- Revenue by customer type.
    CAST(SUM(f.Revenue_GBP) / NULLIF(COUNT(DISTINCT f.Sales_ID), 0) AS DECIMAL(18, 2)) AS AOV -- AOV by customer type.
FROM warehouse.FACT_Sales f -- Fact source.
JOIN warehouse.DIM_Customer c ON f.Customer_ID = c.Customer_ID -- Join customer dimension.
GROUP BY c.Customer_Type; -- Aggregate per customer type.

-- 6.6 Promotion Effectiveness
CREATE VIEW reporting.V_Promotion_Effectiveness AS
SELECT
    p.Promotion_ID, -- Promotion key.
    p.Discount_Percentage, -- Discount percent.
    p.Promotion_Status, -- Promo status label.
    COUNT(DISTINCT f.Sales_ID) AS Orders, -- Orders per promotion.
    SUM(f.Quantity) AS Units, -- Units per promotion.
    SUM(f.Revenue_GBP) AS Revenue, -- Revenue per promotion.
    CAST(SUM(f.Revenue_GBP) / NULLIF(COUNT(DISTINCT f.Sales_ID), 0) AS DECIMAL(18, 2)) AS AOV, -- AOV per promotion.
    CAST(SUM(f.Revenue_GBP) / NULLIF(SUM(f.Quantity), 0) AS DECIMAL(18, 4)) AS Revenue_Per_Unit -- Revenue per unit per promotion.
FROM warehouse.FACT_Sales f -- Fact source.
JOIN warehouse.DIM_Promotion p ON f.Promotion_ID = p.Promotion_ID -- Join promotion dimension.
GROUP BY p.Promotion_ID, p.Discount_Percentage, p.Promotion_Status; -- Aggregate per promotion.


-- 6.7 Promo vs No Promo Comparison
CREATE VIEW reporting.V_Promo_vs_NoPromo AS
SELECT
    CASE WHEN Has_Promotion_Flag = 1 THEN 'Promo' ELSE 'No Promo' END AS Promo_Flag, -- Split by promo usage.
    COUNT(DISTINCT Sales_ID) AS Orders, -- Orders by promo flag.
    SUM(Quantity) AS Units, -- Units by promo flag.
    SUM(Revenue_GBP) AS Revenue, -- Revenue by promo flag.
    CAST(SUM(Revenue_GBP) / NULLIF(COUNT(DISTINCT Sales_ID), 0) AS DECIMAL(18, 2)) AS AOV, -- AOV by promo flag.
    CAST(SUM(Revenue_GBP) / NULLIF(SUM(Quantity), 0) AS DECIMAL(18, 4)) AS Revenue_Per_Unit -- Revenue per unit by promo flag.
FROM warehouse.FACT_Sales -- Fact source.
GROUP BY Has_Promotion_Flag; -- Aggregate promo vs no promo.

-- 6.8 Promo Impact by Customer Type
CREATE VIEW reporting.V_Promo_by_Customer_Type AS
SELECT
    c.Customer_Type, -- Customer segment.
    CASE WHEN f.Has_Promotion_Flag = 1 THEN 'Promo' ELSE 'No Promo' END AS Promo_Flag, -- Promo split within segment.
    COUNT(DISTINCT f.Sales_ID) AS Orders, -- Orders by segment and promo flag.
    SUM(f.Quantity) AS Units, -- Units by segment and promo flag.
    SUM(f.Revenue_GBP) AS Revenue, -- Revenue by segment and promo flag.
    CAST(SUM(f.Revenue_GBP) / NULLIF(COUNT(DISTINCT f.Sales_ID), 0) AS DECIMAL(18, 2)) AS AOV -- AOV by segment and promo flag.
FROM warehouse.FACT_Sales f -- Fact source.
JOIN warehouse.DIM_Customer c ON f.Customer_ID = c.Customer_ID -- Join customer segment.
GROUP BY c.Customer_Type, f.Has_Promotion_Flag; -- Aggregate by segment and promo split.

-- 6.9 Promo Impact by Region
CREATE VIEW reporting.V_Promo_by_Region AS
SELECT
    rg.Region_Name, -- Region label.
    CASE WHEN f.Has_Promotion_Flag = 1 THEN 'Promo' ELSE 'No Promo' END AS Promo_Flag, -- Promo split within region.
    COUNT(DISTINCT f.Sales_ID) AS Orders, -- Orders by region and promo flag.
    SUM(f.Quantity) AS Units, -- Units by region and promo flag.
    SUM(f.Revenue_GBP) AS Revenue, -- Revenue by region and promo flag.
    CAST(SUM(f.Revenue_GBP) / NULLIF(COUNT(DISTINCT f.Sales_ID), 0) AS DECIMAL(18, 2)) AS AOV -- AOV by region and promo flag.
FROM warehouse.FACT_Sales f -- Fact source.
JOIN warehouse.DIM_Customer c ON f.Customer_ID = c.Customer_ID -- Join customer.
JOIN warehouse.DIM_Region rg ON c.Region_ID = rg.Region_ID -- Join region.
GROUP BY rg.Region_Name, f.Has_Promotion_Flag; -- Aggregate by region and promo split.


-- 6.10 Data Quality Report View
CREATE VIEW reporting.V_Data_Quality_Report AS
SELECT
    'Total Orders Processed' AS Metric, -- Label for total processed orders metric.
    CAST(COUNT(*) AS NVARCHAR(20)) AS Value -- Value as text for union compatibility.
FROM warehouse.FACT_Sales -- Source fact table.
UNION ALL
SELECT 'Orders with Promotions', CAST(SUM(CASE WHEN Has_Promotion_Flag = 1 THEN 1 ELSE 0 END) AS NVARCHAR(20)) -- Count orders with promotions.
FROM warehouse.FACT_Sales -- Source fact table.
UNION ALL
SELECT 'Active Sales Reps', CAST(COUNT(DISTINCT Sales_Rep_ID) AS NVARCHAR(20)) -- Distinct reps with sales.
FROM warehouse.FACT_Sales -- Source fact table.
UNION ALL
SELECT 'Unique Customers', CAST(COUNT(DISTINCT Customer_ID) AS NVARCHAR(20)) -- Distinct customers with sales.
FROM warehouse.FACT_Sales -- Source fact table.
UNION ALL
SELECT 'Date Range', CONCAT(MIN(d.Date_Key), ' to ', MAX(d.Date_Key)) -- Min and max available sale dates.
FROM warehouse.FACT_Sales f -- Fact source.
JOIN warehouse.DIM_Date d ON f.Date_Key = d.Date_Key; -- Join date dimension for range.

-- 6.11 Rep Promotion Coverage (who used promotions and for whom)
CREATE OR ALTER VIEW reporting.V_Rep_Promo_Customer AS
SELECT
    r.Sales_Rep_ID, -- Sales rep key.
    r.Sales_Rep_Name, -- Sales rep name.
    r.Manager_Name, -- Manager name.
    c.Customer_ID, -- Customer key.
    c.Customer_Name, -- Customer name.
    c.Customer_Type, -- Customer segment.
    rg.Region_Name, -- Customer region.
    p.Promotion_ID, -- Promotion key.
    p.Discount_Percentage, -- Promotion discount percent.
    COUNT(DISTINCT f.Sales_ID) AS Promo_Orders, -- Promo orders handled by this rep for this customer.
    SUM(f.Quantity) AS Promo_Units, -- Promo units sold.
    SUM(f.Revenue_GBP) AS Promo_Revenue, -- Promo revenue.
    CAST(SUM(f.Revenue_GBP) / NULLIF(COUNT(DISTINCT f.Sales_ID), 0) AS DECIMAL(18, 2)) AS Promo_AOV -- Promo average order value.
FROM warehouse.FACT_Sales f -- Fact source.
JOIN warehouse.DIM_Sales_Rep r ON f.Sales_Rep_ID = r.Sales_Rep_ID -- Rep mapping.
JOIN warehouse.DIM_Customer c ON f.Customer_ID = c.Customer_ID -- Customer mapping.
JOIN warehouse.DIM_Region rg ON c.Region_ID = rg.Region_ID -- Region mapping.
JOIN warehouse.DIM_Promotion p ON f.Promotion_ID = p.Promotion_ID -- Promotion mapping.
WHERE f.Has_Promotion_Flag = 1 -- Promotion-only scope.
GROUP BY
    r.Sales_Rep_ID,
    r.Sales_Rep_Name,
    r.Manager_Name,
    c.Customer_ID,
    c.Customer_Name,
    c.Customer_Type,
    rg.Region_Name,
    p.Promotion_ID,
    p.Discount_Percentage; -- Grain: rep + customer + promotion.

-- 6.12 Rep Promotion Summary (how many promos each rep gave)
CREATE OR ALTER VIEW reporting.V_Rep_Promo_Summary AS
SELECT
    r.Sales_Rep_ID, -- Sales rep key.
    r.Sales_Rep_Name, -- Sales rep name.
    r.Manager_Name, -- Manager name.
    r.Is_On_Probation_Code, -- Probation code (Y/N).
    COUNT(DISTINCT f.Sales_ID) AS Promo_Orders, -- Number of promo orders handled by rep.
    COALESCE(SUM(f.Quantity), 0) AS Promo_Units, -- Promo units sold by rep.
    COALESCE(SUM(f.Revenue_GBP), 0) AS Promo_Revenue, -- Promo revenue generated by rep.
    COALESCE(CAST(SUM(f.Revenue_GBP) / NULLIF(COUNT(DISTINCT f.Sales_ID), 0) AS DECIMAL(18, 2)), 0) AS Promo_AOV, -- Promo AOV per rep.
    COALESCE(CAST(SUM(f.Revenue_GBP) / NULLIF(SUM(f.Quantity), 0) AS DECIMAL(18, 4)), 0) AS Promo_Revenue_Per_Unit -- Promo revenue per unit by rep.
FROM warehouse.DIM_Sales_Rep r -- Start from all reps to keep zero-promo reps visible.
LEFT JOIN warehouse.FACT_Sales f
    ON f.Sales_Rep_ID = r.Sales_Rep_ID
   AND f.Has_Promotion_Flag = 1 -- Promotion-only transactions.
GROUP BY
    r.Sales_Rep_ID,
    r.Sales_Rep_Name,
    r.Manager_Name,
    r.Is_On_Probation_Code; -- Grain: one row per rep.

-- 6.13 Rep Promotion Targeting (for who: customer type and region)
CREATE OR ALTER VIEW reporting.V_Rep_Promo_Targeting AS
SELECT
    r.Sales_Rep_ID, -- Sales rep key.
    r.Sales_Rep_Name, -- Sales rep name.
    r.Manager_Name, -- Manager name.
    c.Customer_Type, -- Customer segment receiving the promotion.
    rg.Region_Name, -- Region of promoted customer.
    COUNT(DISTINCT f.Sales_ID) AS Promo_Orders, -- Promo orders by rep x customer type x region.
    SUM(f.Quantity) AS Promo_Units, -- Promo units by rep x customer type x region.
    SUM(f.Revenue_GBP) AS Promo_Revenue, -- Promo revenue by rep x customer type x region.
    CAST(SUM(f.Revenue_GBP) / NULLIF(COUNT(DISTINCT f.Sales_ID), 0) AS DECIMAL(18, 2)) AS Promo_AOV -- Promo AOV by rep x customer type x region.
FROM warehouse.FACT_Sales f -- Fact source.
JOIN warehouse.DIM_Sales_Rep r ON f.Sales_Rep_ID = r.Sales_Rep_ID -- Rep mapping.
JOIN warehouse.DIM_Customer c ON f.Customer_ID = c.Customer_ID -- Customer mapping.
JOIN warehouse.DIM_Region rg ON c.Region_ID = rg.Region_ID -- Region mapping.
WHERE f.Has_Promotion_Flag = 1 -- Promotion-only scope.
GROUP BY
    r.Sales_Rep_ID,
    r.Sales_Rep_Name,
    r.Manager_Name,
    c.Customer_Type,
    rg.Region_Name; -- Grain: rep + customer type + region.

-- 6.14 Promo_Analysis_Combined (for who: customer type and region)
CREATE OR ALTER VIEW reporting.V_Promo_Analysis_Combined AS
WITH base AS (
    SELECT
        CASE
            WHEN f.Has_Promotion_Flag = 1 THEN 'Promo'
            ELSE 'No Promo'
        END AS Promo_Flag,
        sr.Sales_Rep_Name,
        c.Customer_Type,
        rg.Region_Name,
        CAST(COALESCE(p.Discount_Percentage, 0) AS DECIMAL(5, 2)) AS Discount_Percentage,
        CASE
            WHEN f.Has_Promotion_Flag = 0 OR f.Promotion_ID IS NULL THEN 'No Promotion'
            ELSE COALESCE(p.Promotion_Status, 'Unknown')
        END AS Promo_Status,
        f.Sales_ID,
        f.Quantity,
        f.Revenue_GBP
    FROM warehouse.FACT_Sales f
    JOIN warehouse.DIM_Sales_Rep sr
        ON f.Sales_Rep_ID = sr.Sales_Rep_ID
    JOIN warehouse.DIM_Customer c
        ON f.Customer_ID = c.Customer_ID
    JOIN warehouse.DIM_Region rg
        ON c.Region_ID = rg.Region_ID
    LEFT JOIN warehouse.DIM_Promotion p
        ON f.Promotion_ID = p.Promotion_ID
)
SELECT
    Promo_Flag,
    Sales_Rep_Name,
    Customer_Type,
    Region_Name,
    Discount_Percentage,
    Promo_Status,
    COUNT(DISTINCT Sales_ID) AS Orders,
    SUM(Quantity) AS Units,
    SUM(Revenue_GBP) AS Revenue
FROM base
GROUP BY
    Promo_Flag,
    Sales_Rep_Name,
    Customer_Type,
    Region_Name,
    Discount_Percentage,
    Promo_Status;
GO
