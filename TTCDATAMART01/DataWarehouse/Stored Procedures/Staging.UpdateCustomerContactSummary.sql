SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [Staging].[UpdateCustomerContactSummary]
	@Date date = null
AS

/*- Proc Name: 	[Staging].[UpdateCustomerContactSummary] */
/*- Purpose:	To update contact summary table */

/*- Updates:*/
/*- Name		Date		Comments*/
/*- Preethi Ramanujam 	8/21/2013	New*/


	declare 
    	@ActualDate date,
    	@EndDate date,
    	@Month int,
    	@Year int,
    	@Qry varchar(4000),
    	@FinalTable varchar(50)

	set nocount on

    set @Date = coalesce(@Date, getdate())
    SELECT @ActualDate = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(@Date)-1),@Date),101)
    
    select @Month = MONTH(@ActualDate), @Year = YEAR(@ActualDate),
		@EndDate = DATEADD(Month,1,@ActualDate)
	
	select '@date = ' + CONVERT(varchar,@Date,101)

	select '@ActualDate = ' + CONVERT(varchar,@ActualDate,101),
		 '@EndDate = ' + CONVERT(varchar,@EndDate,101),
		 '@Month = ' + CONVERT(varchar,@Month),
		 '@Year = ' + CONVERT(varchar,@Year)
		 
	PRINT 'Now check if the temp mailing history exist'
		
	declare @countcs int
	
	select @countcs = COUNT(*)
	from staging.ContactSumryMailinghistory
	where YEAR(startdate) = @Year
				
	IF @countcs > 0
		print 'Temp table is ready'
	else 
	  begin
		Truncate table staging.ContactSumryMailinghistory
		
		insert into staging.ContactSumryMailinghistory
	 	select *
		from 	Archive.MailingHistory
		where year(StartDate) = @Year
	  end

		 
	PRINT 'Now check if the temp Email history exist'
		
 	declare @countcsE int
	
	select @countcsE = COUNT(*)
	from staging.ContactSumryEmailhistory
	where YEAR(StartDate) = @Year
				
	IF @countcsE > 0
		print 'Temp table is ready'
	else 
	  begin
		Truncate table staging.ContactSumryEmailhistory
		
		insert into staging.ContactSumryEmailhistory
	 	select *
		from 	Archive.EmailHistory
		where year(StartDate) = @Year
	  end				 
	
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TempCustomerContactSummary')
		drop table staging.TempCustomerContactSummary	

	select a.CustomerID,
		GETDATE() DateCustomerAdded,
		@Year ContactYear,
		@Month ContactMonth,
		ISNULL(tot.TotalMails,0) TotalMails,
		isnull(em.TotalEmails,0) TotalEmails,
		sum(case when c.MD_PromotionType IN ('House Mailings: Catalog') then 1 else 0 end) TotalCatalogs,
		sum(case when c.MD_PromotionType IN ('House Mailings: Catalog Reactivation') then 1 else 0 end) TotalCatalogReactivation,
		sum(case when c.MD_PromotionType IN ('House Mailings: Magalog', 'House Mailings: Magalog Reactivation', 'House Mailings: HighSchool mailing') then 1 else 0 end) TotalMagalogs,
		sum(case when c.MD_PromotionType IN ('House Mailings: Magazine') then 1 else 0 end) TotalMagazines,
		sum(case when c.MD_PromotionType IN ('House Mailings: NewsLetter') then 1 else 0 end) TotalNewsLetters,
		sum(case when c.MD_PromotionType IN ('House Mailings: Letter', 'House Mailings: Letter Reactivation') then 1 else 0 end) TotalJFYLetters,
		sum(case when c.MD_PromotionType IN ('House Mailings: Magnificent 7','House Mailings: Magnificent 7 Reactivation') then 1 else 0 end) TotalMag7s,
		sum(case when c.MD_PromotionType IN ('House Mailings: MagBack', 'House Mailings: MagBack Reactivation') then 1 else 0 end) TotalMagBacks,
		sum(case when c.MD_PromotionType IN ('House Mailings: PostCard') then 1 else 0 end) TotalHOMs,
		sum(case when c.MD_PromotionType IN ('House Mailings: Special Mailings') then 1 else 0 end) TotalSpecialMailings,
		isnull(WP.TotalWelcomePakcage,0) TotalWelcomePakcage,
		isnull(con.TotalConvertalog,0) TotalConvertalog,
		sum(case when c.ChannelID = 1 and c.MD_PromotionType NOT IN ('House Mailings: MagBack', 'House Mailings: MagBack Reactivation', 'House Mailings: PostCard','House Mailings: Magnificent 7','House Mailings: Magnificent 7 Reactivation', 'House Mailings: Letter', 'House Mailings: Letter Reactivation', 'House Mailings: NewsLetter', 'House Mailings: Magazine', 'House Mailings: Catalog', 'House Mailings: Catalog Reactivation',  'House Mailings: Special Mailings', 'House Mailings: Magalog', 'House Mailings: Magalog Reactivation', 'House Mailings: HighSchool mailing') then 1 else 0 end) TotalOtherMailings,
		0 as TotalMailsQC
	into staging.TempCustomerContactSummary	
	from (select distinct customerid, CustomerSince	
		from Marketing.CampaignCustomerSignature
		where CustomerSince < @EndDate) a 
		left join
		(select *
		from Staging.ContactSumryMailinghistory
		where startdate >= @ActualDate and startdate < @EndDate) b on a.CustomerID = b.CustomerID 
		left join
		Mapping.vwAdcodesAll c on b.adcode = c.AdCode 
		left join
		(select CustomerID, COUNT(adcode) TotalWelcomePakcage  
		from Archive.WPArchiveNew
		where AdCode not in (18156,32640)
		and WeekOfMailing >= @ActualDate and WeekOfMailing < @EndDate
		group by CustomerID)WP on a.CustomerID = WP.CustomerID 
		left join
		(select CustomerID, COUNT(adcode) TotalConvertalog  
		from Archive.MailingHistory_Convertalog
		where FlagHoldOut = 0
		and startdate >= @ActualDate and startdate < @EndDate
		group by CustomerID)con on a.customerid = con.customerid 
		left join
		(select CustomerID, COUNT(adcode) TotalEmails
		from Staging.ContactSumryEmailhistory
		where startdate >= @ActualDate and startdate < @EndDate
		group by Customerid)em on a.CustomerID = em.CustomerID 
		left join
		(select CustomerID, COUNT(adcode) TotalMails
		from Staging.ContactSumryMailinghistory
		where startdate >= @ActualDate and startdate < @EndDate
		group by CustomerID)tot on a.CustomerID = tot.CustomerID 
	group by a.CustomerID,
		isnull(tot.TotalMails,0),
		isnull(em.TotalEmails,0),
		isnull(WP.TotalWelcomePakcage,0),
		isnull(con.TotalConvertalog,0)
		

	Update staging.TempCustomerContactSummary
	set  TotalMailsQC = TotalCatalogs + TotalCatalogReactivation + TotalMagalogs + TotalMagazines + 
						TotalNewsLetters + TotalJFYLetters + TotalMag7s + TotalMagBacks + 
						TotalHOMs + TotalWelcomePakcage + TotalConvertalog + TotalOtherMailings + TotalSpecialMailings

	update staging.TempCustomerContactSummary
	set  TotalMails = TotalMails + TotalWelcomePakcage + TotalConvertalog 


	select * from staging.TempCustomerContactSummary
	where totalmails <> totalMailsQC


-- add data to the final table.

	Set @FinalTable = 'CustomerContactSummary_' + CONVERT(varchar,@Year)
	
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = @FinalTable)
	  begin
	  
	  -- check to make sure the data does not exist already
	  -- If exist, delete
		set @Qry = 'delete a
					from archive.' + @FinalTable + ' a join ' + 
					' staging.TempCustomerContactSummary b on a.Contactyear = b.contactyear
															and a.contactMonth = b.contactMonth'
				
		print 'Delete data if already in the Main table.'
		print (@Qry)
		exec (@Qry)	  
	  
	  
	  
		set @Qry = 'Insert INTO archive.' + @FinalTable +
					' Select *
					from staging.TempCustomerContactSummary'
				
		print 'Updating final table..'
		print (@Qry)
		exec (@Qry)
	  end
	 else 
	  begin
		set @Qry = 'Select *
					INTO archive.' + @FinalTable +
					' from staging.TempCustomerContactSummary'
				
		print 'Updating final table..'
		print (@Qry)
		exec (@Qry)
	  end						

GO
