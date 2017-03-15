SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Staging].[LoadWeeklyNewCust_2014]
	@todayDate datetime = null
-- Preethi Ramanujam   1/11/2013
-- To create a base table for welcome series email customers 
-- Assign test/control groups based on the last digit in the customerid 
-- (even gets test and odd gets Control)

-- PR - 2/6/2013
-- Added code to include FeedbackCourseID1

-- PR 1/28/2016
-- Added FlagOther To capture any additional information like BL flag etc.

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
        @WPEmailDLRDate DATETIME,
        @RecoEmailDate DATETIME,
        @JFYEmailDLRDate DATETIME,
        @JFYMailDate DATETIME

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


	SET @endDate = @startDate + 7
	set @AcquistionWeek = @startDate + 1
	Set @WPMailDate = @startDate + 12
	set @WEmailDate = @startDate + 10
	set @RecoEmailDate = @WEmailDate + 3
	set @YourAccountEDate = @WEmailDate + 14
	set @FeedBackEmailDate = @WEmailDate + 21
	set @WPEmailDLRDate	= @WEmailDate + 28 -- This has been moved up a week. So, 28 instead of 35 -- PR -- 6/3/2013 -- set @WPEmailDLRDate	= @WEmailDate + 35 
	set @JFYMailDate = @WEmailDate + 47
	set @JFYEmailDLRDate	= @WEmailDate + 63

	
	PRINT '@pullDate = ' + convert(varchar,@pullDate,101)
    PRINT '@startDate = ' + convert(varchar,@startDate,101)
	PRINT '@endDate = ' + convert(varchar,@endDate,101)
	PRINT '@AcquistionWeek = ' + convert(varchar,@AcquistionWeek,101)
    PRINT '@WPMailDate = ' + convert(varchar,@WPMailDate,101)
	PRINT '@WEmailDate = ' + convert(varchar,@WEmailDate,101)
	PRINT '@RecoEmailDate = ' + convert(varchar,@RecoEmailDate,101)
	PRINT '@YourAccountEDate = ' + convert(varchar,@YourAccountEDate,101)
    PRINT '@FeedBackEmailDate = ' + convert(varchar,@FeedBackEmailDate,101)
	PRINT '@WPEmailDLRDate = ' + convert(varchar,@WPEmailDLRDate,101)
	PRINT '@JFYEmailDLRDate = ' + convert(varchar,@JFYEmailDLRDate,101)
	PRINT '@JFYMailDate = ' + convert(varchar,@JFYMailDate,101)
		
    select 
    	@CouponCode = c.CouponCode,
        @CouponExpire = c.ExpirationPrintedDate
	from Mapping.WPCoupons c (nolock)
    where c.WeekOfMailing = dateadd(day,1,@endDate)

	execute Staging.LoadWPCustomers @pullDate, @startDate, @endDate, 'MailPull'

	truncate table Staging.NewCustomerWelcomeSeriesTEMP

	insert into Staging.NewCustomerWelcomeSeriesTEMP
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
		--case when RIGHT(a.CustomerID,1) In (1,3,5,7,9) then 'TEST'
		--	else 'CONTROL'
		--end as CustGroup, -- PR -- 1/14/2014 -- all control to begin with.
				-- PR 1/13/2015 Testing again in 2015...
				-- PR 1/28/2016 Testing begins in 2016..
		--'CONTROL' as CustGroup,		-- PR 5/21/2015	-- Test has been rolled out 
		'CONTROL' as CustGroup, --Vik Control back from 5/16/2016
		'HV' as HVLVGroup,
		GETDATE() as PullDate,
		null as FlagDigitalPhysical, 
		null as FlagAudioVideo,
		null as Courseid,
		@RecoEmailDate	as RecoEmailDate,
		@JFYEmailDLRDate as JFYEmailDLRDate,
		@JFYMailDate as JFYMailDate,
		null as ItemID,
		null as FlagOther
--	into Marketing.NewCustomerWelcomeSeries		
	from (select *
		from Staging.WPMailCustomers
		where PackageType = 'New') a join
		(select *
		from Marketing.CampaignCustomerSignature
		where CountryCode = 'US') b on a.CustomerID = b.CustomerID left join
		--and FlagMail = 1) b on a.CustomerID = b.CustomerID left join -- PR 5/21/2015 no need to retrict to only mailable. What if they are emailable..
		--rfm..WPTest_Random2013 wp on a.CustomerID = wp.CustomerID
		Marketing.NewCustomerWelcomeSeries wp on a.CustomerID = wp.CustomerID
	where wp.CustomerID is null


IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TempOrdersWPTest')
	DROP TABLE Staging.TempOrdersWPTest

select *
into Staging.TempOrdersWPTest
from DataWarehouse.Staging.vwOrders 
where DateOrdered between @startDate and @endDate
		
update a
set a.FlagReceivedSpclShipCat  = 1,
	a.HVLVGroup = 'LV',
	a.ItemID = b.ITEMID    -- PR 5/6/2014 - added ITEMID for qc
from  Staging.NewCustomerWelcomeSeriesTEMP a join
	(select distinct a.orderid, b.CustomerID, a.ITEMID  -- PR 5/6/2014 - added ITEMID for qc
	from DAXImports..DAX_OrderItemExport a join
		Staging.TempOrdersWPTest b on a.orderid = b.orderid
	where LineType = 'ItemDelivered'
	and ITEMID in ('RM0531'))b on a.CustomerID = b.CustomerID
							and a.MinOrderIDinPeriod = b.orderid


update a
set a.FlagReceivedSpclShipCat  = 1,
	a.HVLVGroup = 'MV',
	a.ItemID = b.ITEMID  -- PR 5/6/2014 - added ITEMID for qc
from  Staging.NewCustomerWelcomeSeriesTEMP a join
	(select distinct a.orderid, b.CustomerID, a.ITEMID  -- PR 5/6/2014 - added ITEMID for qc
	from DAXImports..DAX_OrderItemExport a join
		Staging.TempOrdersWPTest b on a.orderid = b.orderid
	where LineType = 'ItemDelivered'
	and ITEMID in ('RM0532'))b on a.CustomerID = b.CustomerID
							and a.MinOrderIDinPeriod = b.orderid
							

	update a
	set a.FlagDigitalPhysical = isnull(b.FlagDigitalPhysical,'Physical Only'),
		a.FlagAudioVideo = isnull(b.FlagAudioVideo,'Video Only')
	from Staging.NewCustomerWelcomeSeriesTEMP a join
		DataWarehouse.Marketing.DMPurchaseOrders b on a.MinOrderIDinPeriod = b.OrderID
			
	select distinct a.CustomerID, a.MinOrderIDinPeriod, oi.CourseID
	into #tempCourseTbl
	from Staging.NewCustomerWelcomeSeriesTEMP a left join
	(select a.OrderID, Min(a.CourseID) CourseID
		from DataWarehouse.Marketing.DMPurchaseOrderItems a join
			(select orderid, MIN(orderitemID) MinItemID
			from DataWarehouse.Marketing.DMPurchaseOrderItems 
			where StockItemID like '[PD][ACDVM]%'
			group by OrderID)b on a.OrderID = b.OrderID 
								and a.OrderItemID = b.MinItemID
		group by a.OrderID)oi on a.MinOrderIDinPeriod = oi.OrderID

-- if they purchased Digital ONLY and still not LV, then change to LV
/*
	update Staging.NewCustomerWelcomeSeriesTEMP
	set HVLVGroup = 'LV'
	where FlagDigitalPhysical in ('Digital Only','Both')
*/

-- Update Feedback CourseID
	update e
	set e.FeedBackCourseID1 = fnl.CourseID
	-- select fnl.CourseID, e.*
	from Staging.NewCustomerWelcomeSeriesTEMP e join
		#tempCourseTbl fnl on e.CustomerID = fnl.CustomerID
							and e.MinOrderIDinPeriod = fnl.MinOrderIDinPeriod		


		
-- if they are great world religion buyer, give them one course from that.				
	update 	Staging.NewCustomerWelcomeSeriesTEMP	
	set FeedBackCourseID1 = 6101
	where FeedBackCourseID1 = 6100

-- if they have purchased at least one Better Living course, flag them			
	update 	a	
	set a.FlagOther = 'BL_Buyer'
	from Staging.NewCustomerWelcomeSeriesTEMP a
		join DataWarehouse.Marketing.DMPurchaseOrderItems b on a.CustomerID = b.CustomerID
	where b.SubjectCategory2 = 'FW'	
			
		
-- PR 5/6/2014 save snapshot from the itemsexport table						
	insert into rfm..QCdaxorderitemexportTable
	select *, GETDATE() as SaveDate 
	from DAXImports..DAX_OrderItemExport
	where orderid in (select MinOrderIDinPeriod from Staging.NewCustomerWelcomeSeriesTEMP
					where itemid is not null)
	and LineType = 'itemdelivered'
	and ITEMID like '%RM%'

	insert into Marketing.NewCustomerWelcomeSeries
	select * from Staging.NewCustomerWelcomeSeriesTEMP
	
	truncate table Staging.NewCustomerWelcomeSeriesTEMP


-- add to take care by acquisition week
	update a
	set a.FlagReceivedSpclShipCat  = 1,
		A.HVLVGroup = 'LV',
		a.itemid = b.ITEMID -- PR 5/6/2014 - added ITEMID for qc
	-- select 	a.FlagReceivedSpclShipCat, A.HVLVGroup, count(a.customerid)
	from  Marketing.NewCustomerWelcomeSeries a join
		(select distinct a.orderid, b.CustomerID, a.ITEMID  -- PR 5/6/2014 - added ITEMID for qc
		from DAXImports..DAX_OrderItemExport a join
			Staging.TempOrdersWPTest b on a.orderid = b.orderid
		where LineType = 'ItemDelivered'
		and ITEMID in ('RM0531'))b on a.CustomerID = b.CustomerID
	where a.AcquisitionWeek = @AcquistionWeek
	--group by a.FlagReceivedSpclShipCat, A.HVLVGroup	
	--(657 row(s) affected)	
	
	update a
	set a.FlagReceivedSpclShipCat  = 1,
		A.HVLVGroup = 'MV',
		a.itemid = b.ITEMID -- PR 5/6/2014 - added ITEMID for qc
	-- select 	a.FlagReceivedSpclShipCat, A.HVLVGroup, count(a.customerid)
	from  Marketing.NewCustomerWelcomeSeries a join
		(select distinct a.orderid, b.CustomerID, a.ITEMID -- PR 5/6/2014 - added ITEMID for qc
		from DAXImports..DAX_OrderItemExport a join
			Staging.TempOrdersWPTest b on a.orderid = b.orderid
		where LineType = 'ItemDelivered'
		and ITEMID in ('RM0532'))b on a.CustomerID = b.CustomerID
	where a.AcquisitionWeek = @AcquistionWeek
	--group by a.FlagReceivedSpclShipCat, A.HVLVGroup	
	--(657 row(s) affected)		
	
	drop table Staging.TempOrdersWPTest
	
end

GO
