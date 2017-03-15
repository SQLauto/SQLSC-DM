SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*- Proc Name: 	Datawarehse.staging.CreateAbacusMonthlyFile*/
/*- Purpose:	This creates monthly file for Abacus with US and CA data */
/*- Input Parameters: None */
/*- -- Final tables: 
		For Abacus/Epsilon: 
					rfm..TTC_CustomerLevelData_YYYYMMDD
					rfm..TTC_TransactionLevelData_YYYYMMDD		
		
		For Co_Op: 
					rfm..Co_Op_CustomerLevelData_YYYYMMDD
					rfm..Co_Op_TransactionLevelData_YYYYMMDD

-- loads the final file under the folder: \\File1\Groups\Marketing\Marketing Strategy and Analytics\UPsellRanking\UpsellCourseAffinity
-- with name: CourseUpsellForAudible_MMDDYYYYFNL.txt
-- in pipe separated format
*/
/*- Updates:*/
/*- Name		Date		Comments*/
/*- Preethi Ramanujam 	1/16/2014	New*/
-- PR			2/2/2015	Add initial Order channel for all co-op customer files as per new request for rentals..
-- PR			2/2/2015    needto send files to Datalogix, Ibehavior along with Wiland. So, loading to generic Co_Op names instead of Wiland
-- PR			2/4/2015    Remove initial Order channel from final table. Not required now. 
/*-*/

CREATE  PROC [Staging].[Monthly_CustTran_ForCoops] 
AS
begin


---- First pull Customer Level Data

	if object_id('Staging.Temp_Abacus_CustomerFile') is not null drop table Staging.Temp_Abacus_CustomerFile

	select CAST(getdate() as date) AsOfDate,
		a.CustomerID,
		a.Prefix,
		a.FirstName,
		a.MiddleName,
		a.LastName,
		a.Suffix,
		a.Address1,
		a.Address2,
		a.Address3,
		a.City,
		a.State,
		a.PostalCode,
		a.CountryCode,
		case when a.FlagMail = 1 then 0 else 1 end as FlagDoNotMail,
		case when a.FlagOkToShare = 1 then 0 else 1 end as FlagDoNotShare,
		a.FlagMail as FlagMailable,
		a.FlagEmail as FlagEmailable,
		a.FlagEmailPref as FlagEmailPreference,
		a.FlagValidEmail,
		a.MediaFormatPreference as FormatPreference,
		a.Preferredcategory2 as SubjectPreference,
		cast(a.CustomerSince as date) CustomerSinceDate,
		cast(b.DateOrdered as date)  InitialOrderDate,
		b.AdCode as InitialAdcode,	-- PR			2/2/2015	Add initial Order channel for all co-op customer files
		a.CustomerSegment,
		a.Frequency,
		a.ComboID as RFMComboID,
		c.DateOrdered as LastOrderDate,
		d.LTDPurchAmount as LTDSales,
		d.LTDPurchases,
		CONVERT(varchar(50),'') as InitialOrderChannel		-- PR			2/2/2015	Add initial Order channel for all co-op customer files
	into Staging.Temp_Abacus_CustomerFile
	from datawarehouse.marketing.CampaignCustomerSignature a left join
		(select * from DataWarehouse.Marketing.DMPurchaseOrders 
		where SequenceNum = 1)b on a.CustomerID = b.CustomerID left join
		[Staging].[vwCustomerLastOrders_DMPOrders] c on a.CustomerID = c.CustomerID left join
		DataWarehouse.Marketing.CustomerDynamicCourseRank d on a.CustomerID = d.CustomerID
	where CountryCode in ('US','CA')


	if object_id('Staging.Temp_Abacus_CustomerFileSMRY') is not null drop table Staging.Temp_Abacus_CustomerFileSMRY

	select AsOfDate,
		CountryCode,
		FlagDoNotMail,
		FlagDoNotShare,
		FlagMailable,
		FlagEmailable,
		FlagEmailPreference,
		FlagValidEmail,
		FormatPreference,
		SubjectPreference,
		Year(CustomerSinceDate) YearSince,
		Month(CustomerSinceDate) MonthSince,
		Year(InitialOrderDate) IntlOrderYear,
		month(InitialOrderDate) IntlOrderMonth,
		CustomerSegment,
		Frequency,
		RFMComboID,
		COUNT(CustomerID) CustCount,
		sum(LTDSales) TotalSales,
		sum(LTDPurchases) TotalOrders
	into Staging.Temp_Abacus_CustomerFileSMRY	
	from Staging.Temp_Abacus_CustomerFile
	group by AsOfDate,
		CountryCode,
		FlagDoNotMail,
		FlagDoNotShare,
		FlagMailable,
		FlagEmailable,
		FlagEmailPreference,
		FlagValidEmail,
		FormatPreference,
		SubjectPreference,
		Year(CustomerSinceDate),
		Month(CustomerSinceDate),
		Year(InitialOrderDate),
		month(InitialOrderDate),
		CustomerSegment,
		Frequency,
		RFMComboID

---- Pull Order/Transaction Level Data

	if object_id('Staging.Temp_Abacus_Trans_Working') is not null drop table Staging.Temp_Abacus_Trans_Working

	select CAST(getdate() as date) AsOfDate,
		a.CustomerID,
		a.OrderID,
		cast(a.DateOrdered as date) DateOrdered,
		a.NetOrderAmount TotalSales,
		a.FlagLegacy,
		a.StatusCode as OrderStatus,
		case when a.StatusCode = 1 then 'Backorder'
			when a.StatusCode = 12	then 'Pending'
			when a.StatusCode = 3	then 'Invoiced'
			when a.StatusCode = 4	then 'Cancelled'
			when a.StatusCode = 8	then 'OnHold'
			when a.StatusCode = 0	then 'None'
			else 'None'
		end AS OrderStatusDescription,
		a.SalesTypeID,
		CONVERT(varchar(30),Null) OrderType,
		a.OrderSource,
		b.PromotionType PromotionTypeID,
		c.PromotionType PromotionTypeDesc,
		a.PmtMethodID as OrderPaymentType,
		b.FlagDigitalPhysical,
		b.FlagAudioVideo,
		b.TotalCourseSales,
		b.TotalCourseQuantity as CourseUnits,
		b.TotalCourseParts,
		b.TotalTranscriptSales,
		b.TotalTranscriptQuantity as TranscriptUnits,
		b.TotalTranscriptParts
	into Staging.Temp_Abacus_Trans_Working
	from DataWarehouse.Staging.vwOrders a left join
		DataWarehouse.Marketing.DMPurchaseOrders b on a.OrderID = b.OrderID left join
		MarketingCubes..DimPromotionType c on b.PromotionType = c.PromotionTypeID 
	where cast(a.DateOrdered as date) >= DATEADD(year,-5,getdate())	

	-- Update Initial Order channel			-- PR			2/2/2015	Add initial Order channel for all co-op customer files
	update a
	set a.InitialOrderChannel = b.MD_Channel
	from Staging.Temp_Abacus_CustomerFile a join
		Mapping.vwAdcodesAll b on a.InitialAdcode = b.AdCode

	-- Update OrderPaymentType
	update a
	set a.OrderPaymentType = b.PaymMode
	from Staging.Temp_Abacus_Trans_Working a join
		DAXImports..DAX_OrderPaymentsExport b on a.orderid = b.Orderid

	-- Update ordertype for legacy orders, set all to 1
	update a
	set a.ordertype = 'Sales order'
	from Staging.Temp_Abacus_Trans_Working a 
	where flaglegacy = 1

	-- Update ordertype for DAX orders
	update a
	set a.ordertype = d.salestypevalue
	from Staging.Temp_Abacus_Trans_Working a join
		DAXImports.dbo.DAX_SalesType d on a.SalesTypeID = d.SalesTypeID  
	where a.flaglegacy = 0


	-- Remove Journal orders as they are invalid stuck orders as per Misty
	delete from Staging.Temp_Abacus_Trans_Working	
	where ordertype = 'Journal'


	-- delete customers that are not in the customer table
	delete a
	from Staging.Temp_Abacus_Trans_Working a left outer join
		Staging.Temp_Abacus_CustomerFile b on a.customerid = b.customerid
	where b.customerid is null
	
	-- Create transactional summary table for QC
	
	if object_id('Staging.Temp_Abacus_Trans_WorkingSMRY') is not null drop table Staging.Temp_Abacus_Trans_WorkingSMRY

	select AsOfDate,
		YEAR(dateordered) YearOrdered,
		OrderStatusDescription,
		OrderType,
		OrderSource,
		PromotionTypeID,
		PromotionTypeDesc,
		SUM(TotalSales) Sales,
		COUNT(OrderID) Orders
	into staging.Temp_Abacus_Trans_WorkingSMRY		
	from Staging.Temp_Abacus_Trans_Working
	group by AsOfDate,
		YEAR(dateordered),
		OrderStatusDescription,
		OrderType,
		OrderSource,
		PromotionTypeID,
		PromotionTypeDesc


	-- Create final files for Abacus/Epsilon
	declare @CustTable varchar(100),
		@OrderTable varchar(100),
		@Qry varchar(8000),
		@CustTable2 varchar(100),
		@OrderTable2 varchar(100)
		
	select @CustTable = 'rfm..TTC_CustomerLevelData_' + CONVERT(varchar,getdate(),112),
		   @OrderTable = 'rfm..TTC_TransactionLevelData_' + CONVERT(varchar,getdate(),112)

	select @CustTable2 = 'TTC_CustomerLevelData_' + CONVERT(varchar,getdate(),112),
		   @OrderTable2 = 'TTC_TransactionLevelData_' + CONVERT(varchar,getdate(),112)
	
	IF EXISTS(SELECT name FROM rfm.sys.tables WHERE name = @CustTable2)	
	begin
		set @Qry = 'Drop table ' + @CustTable
		print @Qry
		exec (@Qry)				
	end
	
	IF EXISTS(SELECT 1 FROM rfm.sys.tables WHERE name = @OrderTable2)	
	begin
		set @Qry = 'Drop table ' + @OrderTable
		print @Qry
		exec (@Qry)				
	end	
		   
	set @Qry = 'select AsOfDate, CustomerID, Prefix, FirstName,	MiddleName,	LastName,
					Suffix,	Address1, Address2,	Address3, City,	State, PostalCode,
					CountryCode, FlagDoNotMail, FlagDoNotShare,
					FlagMailable, FlagEmailable,
					FlagEmailPreference, FlagValidEmail,
					FormatPreference, SubjectPreference,
					CustomerSinceDate, InitialOrderDate, CustomerSegment,
					Frequency, RFMComboID,
					LastOrderDate,
					LTDSales,
					LTDPurchases,
					InitialOrderChannel
				into ' + @CustTable + 
				' from Staging.Temp_Abacus_CustomerFile'
				
	print @Qry
	exec (@Qry)		
			
	set @Qry = 'select AsOfDate, CustomerID, OrderID, DateOrdered, TotalSales, 
				OrderStatus, OrderStatusDescription, OrderType, OrderSource, 
				PromotionTypeID, PromotionTypeDesc, OrderPaymentType, FlagDigitalPhysical, 
				FlagAudioVideo, TotalCourseSales, CourseUnits, TotalCourseParts, 
				TotalTranscriptSales, TranscriptUnits, TotalTranscriptParts 
				into ' + @OrderTable + 
				' from Staging.Temp_Abacus_Trans_Working'
				
	print @Qry
	exec (@Qry)		
	
	exec staging.ExportTableToPipeText rfm, dbo, @CustTable2, '\\File1\Groups\Marketing\Epsilon\Epsilon_Data_Related\FilesToEpsilon'
	exec staging.ExportTableToPipeText rfm, dbo, @OrderTable2, '\\File1\Groups\Marketing\Epsilon\Epsilon_Data_Related\FilesToEpsilon'

    /*Create tables for Co_Op.
	  They get same data as Abacus, but without Canada data. */
	  
			
		/* add Co_Op Data tables in the same proc */
	declare	@CustTableCo_Op varchar(100),
		@OrderTableCo_Op varchar(100),
		@CustTableCo_Op2 varchar(100),
		@OrderTableCo_Op2 varchar(100)
		  
	select @CustTableCo_Op = 'rfm..TTCCoop_CustomerLevelData_' + CONVERT(varchar,getdate(),112),
		   @OrderTableCo_Op = 'rfm..TTCCoop_TransactionLevelData_' + CONVERT(varchar,getdate(),112)

	select @CustTableCo_Op2 = 'TTCCoop_CustomerLevelData_' + CONVERT(varchar,getdate(),112),
		   @OrderTableCo_Op2 = 'TTCCoop_TransactionLevelData_' + CONVERT(varchar,getdate(),112)
	
	IF EXISTS(SELECT name FROM rfm.sys.tables WHERE name = @CustTableCo_Op2)	
	begin
		set @Qry = 'Drop table ' + @CustTableCo_Op
		print @Qry
		exec (@Qry)				
	end
	
	IF EXISTS(SELECT 1 FROM rfm.sys.tables WHERE name = @OrderTableCo_Op2)	
	begin
		set @Qry = 'Drop table ' + @OrderTableCo_Op
		print @Qry
		exec (@Qry)				
	end	
		   
	set @Qry = 'select *
				into ' + @CustTableCo_Op + 
				' from Staging.Temp_Abacus_CustomerFile
				 where countrycode = ''US'''
				
	print @Qry
	exec (@Qry)		
			
	set @Qry = 'select a.AsOfDate, a.CustomerID, a.OrderID, a.DateOrdered, a.TotalSales, 
				a.OrderStatus, a.OrderStatusDescription, a.OrderType, a.OrderSource, 
				a.PromotionTypeID, a.PromotionTypeDesc, a.OrderPaymentType, a.FlagDigitalPhysical, 
				a.FlagAudioVideo, a.TotalCourseSales, a.CourseUnits, a.TotalCourseParts, 
				a.TotalTranscriptSales, a.TranscriptUnits, a.TotalTranscriptParts 
				into ' + @OrderTableCo_Op + 
				' from Staging.Temp_Abacus_Trans_Working a join ' + 
					@CustTableCo_Op + ' b on a.customerid = b.customerid'
				
	print @Qry
	exec (@Qry)		
	
	exec staging.ExportTableToPipeText rfm, dbo, @CustTableCo_Op2, '\\File1\Groups\Marketing\Co-Op Contracts'
	exec staging.ExportTableToPipeText rfm, dbo, @OrderTableCo_Op2, '\\File1\Groups\Marketing\Co-Op Contracts'


	--- 10/14/2016 Adding item level data for Wiland modeling. PR
	--------------------------------------------------------------------------
	declare	@ItemTableCo_Op varchar(100),
			@ItemTableCo_Op2 varchar(100)
		  
	select @ItemTableCo_Op = 'rfm..TTCCoop_ItemLevelData_Wiland_' + CONVERT(varchar,getdate(),112)

	select @ItemTableCo_Op2 = 'TTCCoop_ItemLevelData_Wiland_' + CONVERT(varchar,getdate(),112)

	-- Load data into temp table..
	if object_id('Staging.Temp_Wiland_Working') is not null drop table Staging.Temp_Wiland_Working

	select a.CustomerID
			,a.Frequency
			,b.DateOrdered
			,b.CourseID
			,b.SubjectCategory2 as SubjectCategory
			,c.SubTopic
			,b.TotalSales as 'Price'
			,case when MediaTypeID in ('DownloadA','CD','Audio','StreamA') then 'Audio'
				else 'Video' end as VideoAudio
			,case when MediaTypeID like '%download%' then 'Digital'
				else 'Physical' end as PhysicalDigital
	into Staging.Temp_Wiland_Working
	from DataWarehouse.Marketing.CampaignCustomerSignature as a
	join DataWarehouse.Marketing.DMPurchaseOrderItems as b
	on a.CustomerID=b.CustomerID
	join DataWarehouse.Mapping.DMCourse as c
	on b.CourseID=c.CourseID
	join superstardw.dbo.InvItem as d
	on b.StockItemID=d.UserStockItemID
	where cast(b.DateOrdered as date) >= DATEADD(year,-5,getdate())	
	and MediaTypeID not in ('Transcript','DownloadT','Printed','NA')
	and b.TotalSales > 0
	and a.CountryCode='US'
	order by a.CustomerID, b.DateOrdered
	
	IF EXISTS(SELECT name FROM rfm.sys.tables WHERE name = @ItemTableCo_Op2)	
	begin
		set @Qry = 'Drop table ' + @ItemTableCo_Op
		print @Qry
		exec (@Qry)				
	end
		   
	set @Qry = 'select *
				into ' + @ItemTableCo_Op + 
				' from Staging.Temp_Wiland_Working'
				
	print @Qry
	exec (@Qry)		
				
	
	exec staging.ExportTableToPipeText rfm, dbo, @ItemTableCo_Op2, '\\File1\Groups\Marketing\Co-Op Contracts'


	drop table Staging.Temp_Abacus_CustomerFile
	drop table Staging.Temp_Abacus_Trans_Working
	drop table Staging.Temp_Wiland_Working

end
GO
