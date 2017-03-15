SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[LoadWeeklyNewCust]
	@todayDate datetime = null
-- Preethi Ramanujam   1/11/2013
-- To create a base table for welcome series email customers 
-- Assign test/control groups based on the last digit in the customerid 
-- (even gets test and odd gets Control)

-- PR - 2/6/2013
-- Added code to include FeedbackCourseID1

AS
	DECLARE 
    	--@todayDate DATETIME,
		@PullDate  DATE,	
		@startDate DATETIME,
		@endDate   DATETIME,
        @sql nvarchar(1000),
        @table_name nvarchar(100),
        @CouponCode varchar(6),
        @CouponExpire date,
        @AcquistionWeek DATETIME,
        @WPMailDate DATETIME,
        @WEmailDate DATETIME,
        @YourAccountEDate DATETIME,
        @FeedBackEmailDate DATETIME,
        @WPEmailDLRDate DATETIME

begin
	--set nocount on
    
	select top 1 @PullDate = FMPullDate from Marketing.CampaignCustomerSignature (nolock)
    
    if @PullDate <> cast(getdate() as date)
    begin
		raiserror('FMPullDate from CampaignCustomerSignature differs from today''s date', 0, 0)
		return
    end
    
	SET @todayDate = coalesce(@todayDate, CONVERT(DATETIME, CONVERT(VARCHAR(10),  GETDATE(), 101)))

	SET @pullDate = @todayDate
	-- SET @startDate = @todayDate - (DATEPART(dw, @todayDate)-1)
	if DATEPART(dw,@todaydate) = 1 
		SET @startDate = @todayDate - 7
		else SET @startDate = @todayDate - (DATEPART(dw, @todayDate)-1)
		
	SET @endDate = @todayDate 
	set @AcquistionWeek = @startDate + 1
	Set @WPMailDate = @startDate + 12
	set @WEmailDate = @startDate + 10
	set @YourAccountEDate = @WEmailDate + 14
	set @FeedBackEmailDate = @WEmailDate + 21
	set @WPEmailDLRDate	= @WEmailDate + 35
	
	PRINT '@pullDate = ' + convert(varchar,@pullDate,101)
    PRINT '@startDate = ' + convert(varchar,@startDate,101)
	PRINT '@endDate = ' + convert(varchar,@endDate,101)
	PRINT '@AcquistionWeek = ' + convert(varchar,@AcquistionWeek,101)
    PRINT '@WPMailDate = ' + convert(varchar,@WPMailDate,101)
	PRINT '@WEmailDate = ' + convert(varchar,@WEmailDate,101)
	PRINT '@YourAccountEDate = ' + convert(varchar,@YourAccountEDate,101)
    PRINT '@FeedBackEmailDate = ' + convert(varchar,@FeedBackEmailDate,101)
	PRINT '@WPEmailDLRDate = ' + convert(varchar,@WPEmailDLRDate,101)
		
    select 
    	@CouponCode = c.CouponCode,
        @CouponExpire = c.ExpirationPrintedDate
	from Mapping.WPCoupons c (nolock)
    where c.WeekOfMailing = dateadd(day,1,@endDate)

	execute Staging.LoadWPCustomers @pullDate, @startDate, @endDate, 'MailPull'

	truncate table rfm..WPTest_Random2013_TEMP

	insert into rfm..WPTest_Random2013_TEMP
	select a.CustomerID,
		a.MinOrderIDinPeriod, 
		a.MinPurchDateInPeriod,
		b.EmailAddress, 
		b.CustomerSince,
		@AcquistionWeek AS AcquisitionWeek,
		@WPMailDate as WPMailDate,
		@WEmailDate AS WEmailDate,
		@YourAccountEDate as YourAccountEDate,
		@FeedBackEmailDate as FeedBackEmailDate,
		@WPEmailDLRDate as WPEmailDLRDate,
		b.ComboID, 
		b.NewSeg,
		b.Name,
		b.A12mf,
		b.PreferredCategory2,
		b.FlagEmail,
		b.FlagEmailPref,
		b.FlagValidEmail,
		b.FlagMail,
		b.Address1,
		b.Address2,
		b.Address3,
		b.City,
		b.State,
		b.CountryCode,
		0 as FlagReceivedSpclShipCat,
		case when RIGHT(a.CustomerID,1) In (0,2,4,6,8) then 'TEST'
			else 'CONTROL'
		end as CustGroup,
		'HV' as HVLVGroup,
		GETDATE() as PullDate,
		null as FlagDigitalPhysical, 
		null as FlagAudioVideo,
		null as Courseid
--	into rfm..WPTest_Random2013		
	from (select *
		from Staging.WPMailCustomers
		where PackageType = 'New') a join
		(select *
		from Marketing.CampaignCustomerSignature
		where CountryCode = 'US'
		and FlagMail = 1) b on a.CustomerID = b.CustomerID left join
		rfm..WPTest_Random2013 wp on a.CustomerID = wp.CustomerID
	where wp.CustomerID is null

update a
set a.FlagReceivedSpclShipCat  = 1,
	a.HVLVGroup = 'LV'
from  rfm..WPTest_Random2013_TEMP a join
	(select distinct a.orderid, b.CustomerID
	from DAXImports..DAX_OrderItemExport a join
		(select *
		from DataWarehouse.Staging.vwOrders 
		where DateOrdered between @startDate and @endDate)b on a.orderid = b.orderid
	where LineType = 'ItemDelivered'
	and ITEMID = 'RM0531')b on a.CustomerID = b.CustomerID
							and a.MinOrderIDinPeriod = b.orderid

	update a
	set a.FlagDigitalPhysical = isnull(b.FlagDigitalPhysical,'Physical Only'),
		a.FlagAudioVideo = isnull(b.FlagAudioVideo,'Video Only')
	from rfm..WPTest_Random2013_TEMP a join
		DataWarehouse.Marketing.DMPurchaseOrders b on a.MinOrderIDinPeriod = b.OrderID
			
	select distinct a.CustomerID, a.MinOrderIDinPeriod, oi.CourseID
	into #tempCourseTbl
	from rfm..WPTest_Random2013_TEMP a left join
	(select a.OrderID, Min(a.CourseID) CourseID
		from DataWarehouse.Marketing.DMPurchaseOrderItems a join
			(select orderid, MIN(orderitemID) MinItemID
			from DataWarehouse.Marketing.DMPurchaseOrderItems 
			where StockItemID like '[PD][ACDVM]%'
			group by OrderID)b on a.OrderID = b.OrderID 
								and a.OrderItemID = b.MinItemID
		group by a.OrderID)oi on a.MinOrderIDinPeriod = oi.OrderID


	update e
	set e.FeedBackCourseID1 = fnl.CourseID
	-- select fnl.CourseID, e.*
	from rfm..WPTest_Random2013_TEMP e join
		#tempCourseTbl fnl on e.CustomerID = fnl.CustomerID
							and e.MinOrderIDinPeriod = fnl.MinOrderIDinPeriod		
				
	update 	rfm..WPTest_Random2013_TEMP	
	set FeedBackCourseID1 = 6101
	where FeedBackCourseID1 = 6100
						
	insert into rfm..WPTest_Random2013
	select * from rfm..WPTest_Random2013_TEMP
	
	truncate table rfm..WPTest_Random2013_TEMP

end
GO
