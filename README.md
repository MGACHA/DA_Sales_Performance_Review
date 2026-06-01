# DA_Sales_Performance_Review
Data Analysis of Sales Performance Review
## What dataset contains
Main fact table:
- Sales_Data(Date, Sales_ID, Sales_Rep_ID, Customer_ID, Quantity, Value, Promotion_ID)
Dimension tables:
- Promotion(Promotion_ID, Reduction)
- Sales_Rep(Sales_Rep_ID, Sales_Rep_Name, Manager_Name, Years_Of_Service, Is_On_Probation)
- Customer(Customer_ID, Region_ID, Name, Type)
- Region(Region_ID, Region, Currency_Used, Exchange_Rate_to GBP)

## What we found from your actual data
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

## Step 1
Separate the xlsx file into a csv file using the export_excel_to_csv.py script, then load the tables into the SQL Server database. Created staging tables and warehouse tables.
Created views script create_views.sql

## Step 1 - Method 
I cleaned and validated IDs, nulls, and joins.
I joined Sales_Data with Promotion, Sales_Rep, Customer, and Region.
I built KPIs (Revenue, Orders, Units, AOV, Promo rate).
I segmented performance by rep, region, customer type, and promotions.
I translated insights into 90-day actions.
## Step 2 - Show 5 key findings
Use this order:
Revenue concentration: strongest in GB and US.
Sales rep concentration: a few reps drive most revenue.
Customer mix: Shop segment is largest revenue contributor.
Promotions: improve basket size (AOV) but reduce value per unit.
Data quality risk: inconsistent region naming impacts reporting.

