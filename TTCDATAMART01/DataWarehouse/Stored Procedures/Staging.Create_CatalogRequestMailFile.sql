SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [Staging].[Create_CatalogRequestMailFile] 
	@StartDate datetime = null
AS 

/* Preethi Ramanujam 	1/27/2014
	To Create mail file for weekly catalog request mailing
*/

	declare @StartDateChar varchar(15), 
			@CRCatalog varchar(15),
			@ErrorMsg varchar(200),
			@DataPullDate datetime
	
    set @StartDate = isnull(@StartDate, convert(datetime,convert(varchar,getdate(),101)))

	PRINT '@StartDate = ' + convert(varchar,@StartDate)
	
	set @StartDateChar = CONVERT(varchar,@startdate,112)

	PRINT '@@StartDateChar = ' + @StartDateChar
	
	select @CRCatalog = CRCatalog,
		@DataPullDate = DataPullDate
	from datawarehouse.Mapping.CatalogRequestSchedule
	where DataPullDate = datawarehouse.Staging.GetMonday(cast(@Startdate as date))

	IF @CRCatalog = 'NO MAILING'
	BEGIN	
		-- Check if we can get the DL control version of catalogcode ****
		SET @ErrorMsg = 'There is no Catalog request mail this week'
		RAISERROR(@ErrorMsg,15,1)
		RETURN
	END
	
		
		
	select distinct JSCUSTACCT, b.Prefix, b.FirstName, b.MiddleName, b.LastName, b.Suffix,
		b.Address1, b.Address2 + ' ' + b.Address3 as Address2,
		b.City, b.State, b.PostalCode,
		b.CustomerSegment, b.Frequency, b.FlagMail, b.CountryCode, b.FlagValidRegionUS
	into #temp
	 from DAXImports..JSCATALOGREQUEST a join
		DataWarehouse.Marketing.CampaignCustomerSignature b on a.JSCUSTACCT = b.CustomerID
	where CREATEDDATETIME >= DATEADD(week, -3, @Startdate)
	and b.FlagMail = 1
	and CountryCode = 'US'
	and CustomerSegment like '%inq%'


	-- Drop if we have already sent them a catalog
	select * 
	into #temp2
	from DataWarehouse.[Archive].[MailhistoryCurrentYear]  /*Archive.MailingHistory2013   20150428 Vik*/
	where StartDate  >= DATEADD(week, -3, @Startdate)

	delete a
	from #temp a join
		#temp2 b on a.JSCUSTACCT = b.CustomerID
	

	-- Drop if they have received Catalog Request in the last 4 weeks.
		
	delete a
	from #temp a join
		(select *
		from datawarehouse.Archive.MailingHistory_CatRqst
		where datapulldate >= DATEADD(week, -5, @Startdate))b on a.JSCUSTACCT = b.customerid	
				
	-- Create final dataset
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Mail_US_CatalogRequest')	
	drop table staging.Mail_US_CatalogRequest
			
	select a.JSCUSTACCT as CustomerID,
		a.Prefix,
		a.FirstName,
		a.MiddleName,
		a.LastName,
		a.Suffix,
		a.Address1,
		a.Address2,
		a.City,
		a.State,
		a.PostalCode,
		b.OfferAdcode,
		b.CatalogAdcode,
		b.CpnExpirationDate,
		b.CouponCode,
		b.ShipDate
	into staging.Mail_US_CatalogRequest
		 from #temp a,
			(select *
			from datawarehouse.Mapping.CatalogRequestSchedule 
			where DataPullDate = datawarehouse.Staging.GetMonday(cast(@Startdate as date))) b 

	-- Load Catalog Request Mail History
	
	insert into datawarehouse.Archive.MailingHistory_CatRqst
	select *, @DataPullDate
	from staging.Mail_US_CatalogRequest	
			
	-- Load data into FINAL Table on rfm database
	declare @FnlTable varchar(200),
		@Qry varchar(8000)
	
	Set @FnlTable = 'rfm..Mail_US_CatalogRequest_' + CONVERT(varchar,@DataPullDate,112) + '_CorpPress'
	
	set @Qry = 'Select *
				into ' + @FnlTable + 
			   ' from staging.Mail_US_CatalogRequest'
			   
	print (@Qry)
	exec (@Qry)
	
	drop table #temp
	drop table #temp2
				   
	
	
GO
