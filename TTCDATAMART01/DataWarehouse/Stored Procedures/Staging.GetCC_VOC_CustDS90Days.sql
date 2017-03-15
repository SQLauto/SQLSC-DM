SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[GetCC_VOC_CustDS90Days]
AS
--- Proc Name:    GetCC_VOC_CustDS90Days
--- Purpose:      To provide customer care with the 90 day downstream sales and Orders 
---					from the day of CC_ContactDate for VOC customers who were contacted.
--- Input Parameters: None
--- But, input table is: staging.CC_VOC_ContactedCustList
--- Which is loaded from file: G:\Marketing\CustomerCareReports\VOC_Report\WeeklyVOCContactedCustomers.xlsx
--- Uses SSIS package to load this.
              
--- Updates:
--- Name                      Date        Comments
--- Preethi Ramanujam		2/28/2013     New
    DECLARE 
    	@ReportDate datetime
BEGIN
	set nocount on

    set @ReportDate = GETDATE()

    -- Make sure input table has data.
    declare @ErrorMsg varchar(50)
	IF NOT EXISTS (select 1 from staging.CC_VOC_ContactedCustList)
		BEGIN
			PRINT 'There is no data in table: staging.CC_VOC_ContactedCustList'
			set @ErrorMsg = 'There is no data in table: staging.CC_VOC_ContactedCustList'
		    RAISERROR(@ErrorMsg,15,1)
            RETURN
		END

	-- Delete if the row has null value in the customerID
	delete from staging.CC_VOC_ContactedCustList 
	where customerid is null
		
	-- From the most recent VOC history, get all the customers who did not complete 90 days
	insert into staging.CC_VOC_ContactedCustList
	select a.CustomerID, a.CustomerName, a.DatePrepared, a.CC_ContactDate
	from Marketing.CC_VOC_ContactedCustList a left join
		staging.CC_VOC_ContactedCustList b on a.CustomerID = b.CustomerID
										and a.DatePrepared = b.DatePrepared
	where DateLoaded = (select MAX(DateLoaded) MaxDateLoaded 
						from Marketing.CC_VOC_ContactedCustList)
	and FlagComplete90Days = 0
	and b.CustomerID is null

   if object_id('Staging.CC_VOC_ContactedCustListTEMP1') is not null 
			drop table Staging.CC_VOC_ContactedCustListTEMP1


	select a.CustomerID, 
		a.CC_ContactDate,
		a.DatePrepared,
		count(b.orderid) DS90DaysOrders,
		sum(b.NetOrderAmount) DS90DaysSales
	into Staging.CC_VOC_ContactedCustListTEMP1	
	from staging.CC_VOC_ContactedCustList a left join
		DataWarehouse.Marketing.DMPurchaseOrders b on a.customerid = b.CustomerID
											and b.DateOrdered between a.CC_ContactDate and dateadd(day,90,a.CC_ContactDate)
	group by a.CustomerID, 
		a.CC_ContactDate,
		a.DatePrepared
		

   if object_id('Staging.CC_VOC_ContactedCustListTEMP') is not null 
			drop table Staging.CC_VOC_ContactedCustListTEMP	
											
	select a.*, 
		b.DS90DaysOrders, 
		ISNULL(b.DS90DaysSales,0) DS90DaysSales,
		case when b.DS90Daysorders > 0 then 1 else 0 end as FlagDS90DaysOrdered,
		DATEDIFF(day,a.CC_ContactDate,GETDATE()) as DaysSinceContact,
		case when DATEDIFF(day,a.CC_ContactDate,GETDATE()) > 90 then 1
			else 0
		end as FlagComplete90Days,
		GETDATE() as DateLoaded
	into staging.CC_VOC_ContactedCustListTEMP	
	from  staging.CC_VOC_ContactedCustList a left join
			Staging.CC_VOC_ContactedCustListTEMP1	b on a.customerid = b.customerid
													and a.dateprepared = b.dateprepared
													and a.CC_ContactDate = b.CC_ContactDate

	select * from staging.CC_VOC_ContactedCustListTEMP	

    -- Update the main table
	insert into Marketing.CC_VOC_ContactedCustList
	select * 
	from staging.CC_VOC_ContactedCustListTEMP	

	truncate table staging.CC_VOC_ContactedCustList

    -- Drop all the temp tables
    if object_id('Staging.CC_VOC_ContactedCustListTEMP1') is not null drop table Staging.CC_VOC_ContactedCustListTEMP1
    if object_id('Staging.CC_VOC_ContactedCustListTEMP') is not null drop table Staging.CC_VOC_ContactedCustListTEMP
END
GO
