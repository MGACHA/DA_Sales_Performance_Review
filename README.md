# DA_Sales_Performance_Review

## [Presentation](PowerPoint/Sales_Performance_Board_Presentation.pdf)

[Data Analysis of Sales Performance Review](Data/DA-data.xlsx)
## What dataset contains
Main fact table:
- Sales_Data(Date, Sales_ID, Sales_Rep_ID, Customer_ID, Quantity, Value, Promotion_ID)

Dimension tables:
- Promotion(Promotion_ID, Reduction)
- Sales_Rep(Sales_Rep_ID, Sales_Rep_Name, Manager_Name, Years_Of_Service, Is_On_Probation)
- Customer(Customer_ID, Region_ID, Name, Type)
- Region(Region_ID, Region, Currency_Used, Exchange_Rate_to GBP)

## What I found from your actual data
- Date range: 2026-04-24 to 2026-04-30 (7 days)
- Total orders: 213
- Total revenue: 95,816.25
- Total quantity: 1,086 units
- Average order value: 449.84
- Promotions used on 23.94% of orders

- Top performers:
- Best sales rep by revenue: Sekhar (29,970)
- Biggest region by revenue: GB (34,035), then US (27,731.25), then UK (21,750)
- Biggest customer type: Shop (50,235)
  
- Promotion insight:
- Promo orders have higher AOV (506.99) than non-promo (431.85)
- But promo revenue per unit is lower (86.19 vs 89.01)
- 5% discount promotion generated the highest revenue among promotion types
- Data quality note to mention:
- Region labels include UK, GB, and England separately (likely naming inconsistency)
- 1 sales rep (Amy, probation Y) has no transactions in this window

## Approach
I approached this task in four steps.
- First, I reviewed the raw sales data and checked the main fields, such as dates, regions, customers, promotions, and sales reps.
- Second, I cleaned and structured the data in SQL so I could create consistent reporting views.
- Third, I used those reporting views in Power BI to build focused dashboard pages for executive KPIs, sales rep performance, promotion effectiveness, and data quality.
- Finally, I used the outputs to build a short business narrative with practical recommendations, rather than only showing charts.

## Build choices and why
A key design choice was to keep most of the transformation work in SQL and keep Power BI focused on visuals and lightweight measures.
I chose this approach because it makes the business logic easier to control, easier to explain, and easier to reuse.
I also used reporting views as a semantic layer. That means each dashboard page reads from a prepared view, instead of rebuilding the logic again inside Power BI.
This keeps the model simpler and reduces the risk of inconsistent KPI definitions.


## Step 1
- Separate the xlsx file into a csv file using the [export](Python/export_excel_to_csv.py) script, 
- Load the tables into the SQL Server database
- Created staging tables for "original" data, in script [Staging](SQL/Staging_tables.sql)
- Created warehouse tables for cleaned data [DIM](SQL/DIM_tables.sql), [FACT](SQL/Fact_tables.sql)
- Created views [script](SQL/create_views.sql)

## Step 2 - Method 
- I cleaned and validated IDs, nulls, and joins.
- I joined Sales_Data with Promotion, Sales_Rep, Customer, and Region.
- I built KPIs (Revenue, Orders, Units, AOV, Promo rate).
- I segmented performance by rep, region, customer type, and promotions.

## Step 3 - Key findings
 - Revenue concentration: strongest in GB and US.
- Sales rep concentration: a few reps drive most revenue.
- Customer mix: Shop segment is the largest revenue contributor.
- Promotions: improve basket size (AOV) but reduce value per unit.
- Data quality risk: inconsistent region naming impacts reporting.


