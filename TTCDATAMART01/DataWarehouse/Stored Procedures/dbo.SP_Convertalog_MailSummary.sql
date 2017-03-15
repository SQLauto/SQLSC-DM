SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[SP_Convertalog_MailSummary] @full_ind bit=0
as
Begin

declare @date datetime
--@date to Monthly for control need to only go back a month(previous monday)
set @date = dateadd(week, datediff(week, 0, DATEADD(month,-1,getdate()) ), 0)

--Fullrefersh
if @full_ind=1
set @date='1900-01-01'


select distinct YEAR(a.StartDate) YearOfMailing, 
	MONTH(a.StartDate) MonthOfMailing,
	cast(a.StartDate as date) DayOfMailing,
	a.AdCode, c.AdcodeName, c.CatalogCode, c.CatalogName,
	c.MD_Year, c.MD_Country, c.MD_Audience,
	c.ChannelID MD_ChannelID, c.MD_Channel as MD_ChannelName,
	c.MD_PromotionTypeID, c.MD_PromotionType,
	c.MD_CampaignID, c.MD_CampaignName,
	c.MD_PriceType,
	a.CustomerID, c.StopDate,convert(int,0) Orders, convert(money,0.0) as Sales, convert(int,0) as parts,CONVERT(int,0) as units
into #temp	
from (select * from DataWarehouse.Archive.MailingHistory_Convertalog
	where FlagHoldOut = 0 and StartDate>=@date) a 
	left join DataWarehouse.Mapping.vwAdcodesAll c on a.adcode = c.adcode


update a
set a.orders = b.orders,
	a.sales = b.sales,
	a.units = b.units,
	a.parts = b.parts
from #temp a join	
	(select a.customerID, a.AdCode, SUM(b.NetOrderamount) sales, COUNT(b.orderid) Orders , SUM(b.TotalCourseParts) parts, SUM(b.TotalCourseQuantity) units
	from #temp a
	join DataWarehouse.Marketing.DMPurchaseOrders b on a.CustomerID = b.CustomerID
										and a.AdCode = b.AdCode
	group by a.CustomerID, a.AdCode)b on a.CustomerID = b.CustomerID
									and a.AdCode = b.AdCode
																			



--Fullrefersh
if @full_ind=1										
	begin


	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Marketing].[MailTracker_Convertalog]') AND type in (N'U'))
	drop table DataWarehouse.[Marketing].[MailTracker_Convertalog]

	select YearOfMailing, MonthOfMailing, DayOfMailing, AdCode, AdcodeName,
		CatalogCode, CatalogName, 
		MD_Year, MD_Country, MD_Audience,
		MD_ChannelID, MD_ChannelName,
		MD_PromotionTypeID, MD_PromotionType,
		MD_CampaignID, MD_CampaignName,
		MD_PriceType,	
		COUNT(customerID) Circ,
		SUM(Orders) Orders, SUM(sales) Sales,SUM(parts) parts, SUM(units) units,
		GETDATE() as ReportDate,
		case when getdate()> StopDate + 14 then 1 /*Expire record so that going forward we may not update this record*/
			 else 0 end as Offer_expired_flg

	into Datawarehouse.Marketing.MailTracker_Convertalog
	from #temp
	group by YearOfMailing, MonthOfMailing, DayOfMailing, AdCode, AdcodeName,
		CatalogCode, CatalogName,
		MD_Year, MD_Country, MD_Audience,
		MD_ChannelID, MD_ChannelName,
		MD_PromotionTypeID, MD_PromotionType,
		MD_CampaignID, MD_CampaignName,
		MD_PriceType,StopDate
	order by 1,2,3	


	end

else

	begin

		select YearOfMailing, MonthOfMailing, DayOfMailing, AdCode, AdcodeName,
			CatalogCode, CatalogName, 
			MD_Year, MD_Country, MD_Audience,
			MD_ChannelID, MD_ChannelName,
			MD_PromotionTypeID, MD_PromotionType,
			MD_CampaignID, MD_CampaignName,
			MD_PriceType,	
			COUNT(customerID) Circ,
			SUM(Orders) Orders, SUM(sales) Sales,SUM(parts) parts, SUM(units) units,
			GETDATE() as ReportDate,
			case when getdate()> StopDate + 14 then 1 /*Expire record so that going forward we may not update this record*/
				 else 0 end as Offer_expired_flg

		into #temp2
		from #temp
		group by YearOfMailing, MonthOfMailing, DayOfMailing, AdCode, AdcodeName,
			CatalogCode, CatalogName,
			MD_Year, MD_Country, MD_Audience,
			MD_ChannelID, MD_ChannelName,
			MD_PromotionTypeID, MD_PromotionType,
			MD_CampaignID, MD_CampaignName,
			MD_PriceType,StopDate
		order by 1,2,3	

/*  Update data for old Adcodes*/ 

		update a
		set a.Circ = b.Circ,
			a.Orders = b.Orders,
			a.sales = b.sales,
			a.units = b.units,
			a.parts = b.parts,
			a.reportdate = getdate(),
			a.Offer_expired_flg = b.Offer_expired_flg
		from Datawarehouse.Marketing.MailTracker_Convertalog a 
		inner join #temp2 b
		on a.AdCode=b.AdCode and a.CatalogCode=b.CatalogCode 
		where a.Offer_expired_flg = 0  /* Once adcodes are Expired then those records will not get updated again*/



/*  add data for New Adcodes*/ 

		insert into Datawarehouse.Marketing.MailTracker_Convertalog 
		select b.*
		from Datawarehouse.Marketing.MailTracker_Convertalog a 
		right join #temp2 b
		on a.AdCode=b.AdCode 
		where a.AdCode is null


drop table #temp2
	end


drop table #temp



End



GO
