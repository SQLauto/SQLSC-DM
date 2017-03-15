SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE Proc [dbo].[SP_WPDLR_MailSummary] @full_ind bit=0
as
Begin

declare @date datetime
--@date to Monthly for control need to only go back a month(previous monday)
set @date = dateadd(week, datediff(week, 0, DATEADD(month,-2,getdate()) ), 0)

--Fullrefersh
if @full_ind=1
set @date='1900-01-01'


select distinct YEAR(a.EMailSent) YearOfMailing, 
	MONTH(a.EMailSent) MonthOfMailing,
	cast(a.EMailSent as date) DLREMailDate,
	a.AdCode, c.AdcodeName, c.CatalogCode, c.CatalogName,
	c.MD_Year, c.MD_Country, c.MD_Audience,
	c.ChannelID MD_ChannelID, c.MD_Channel as MD_ChannelName,
	c.MD_PromotionTypeID, c.MD_PromotionType,
	c.MD_CampaignID, c.MD_CampaignName,
	c.MD_PriceType,
	a.CustomerID,c.StopDate,a.CouponCode,a.Expiration, convert(int,0) Orders, convert(money,0.0) as Sales, convert(int,0) as parts,CONVERT(int,0) as units
into #temp	
from LstMgr..WPEMail_General a 
	left join DataWarehouse.Mapping.vwAdcodesAll c on a.adcode = c.adcode
	where a.EMailSent>=@date

update a
set a.orders = b.orders,
	a.sales = b.sales,
	a.units = b.units,
	a.parts = b.parts	
from #temp a join	
	(select a.customerID, a.AdCode, SUM(b.NetOrderamount) sales, COUNT(b.orderid) Orders, SUM(b.TotalCourseParts) parts, SUM(b.TotalCourseQuantity) units
	from #temp a
	join DataWarehouse.Marketing.DMPurchaseOrders b on a.CustomerID = b.CustomerID
										and a.AdCode = b.AdCode
	group by a.CustomerID, a.AdCode)b on a.CustomerID = b.CustomerID
									and a.AdCode = b.AdCode
																			

if @full_ind=1										
	begin

		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Marketing].[EmailTracker_WPDLR]') AND type in (N'U'))
		drop table DataWarehouse.[Marketing].[EmailTracker_WPDLR]


	select YearOfMailing, MonthOfMailing, DLREMailDate, 
		AdCode, AdcodeName,
		CatalogCode, CatalogName, 
		MD_Year, MD_Country, MD_Audience,
		MD_ChannelID, MD_ChannelName,
		MD_PromotionTypeID, MD_PromotionType,
		MD_CampaignID, MD_CampaignName,
		MD_PriceType,
		StopDate,CouponCode,Expiration,
		COUNT(customerID) Circ,
		SUM(Orders) Orders, SUM(sales) Sales,SUM(parts) parts, SUM(units) units,
		GETDATE() as ReportDate,
		case when getdate()> dateadd(d,14,Expiration) then 1 /*Expire Adcode record so that going forward we may not update this record*/
		else 0 end as Coupon_expired_flg
	into Datawarehouse.Marketing.EmailTracker_WPDLR	
	from #temp
	group by YearOfMailing, MonthOfMailing, DLREMailDate, 
		AdCode, AdcodeName,
		CatalogCode, CatalogName,
		MD_Year, MD_Country, MD_Audience,
		MD_ChannelID, MD_ChannelName,
		MD_PromotionTypeID, MD_PromotionType,
		MD_CampaignID, MD_CampaignName,
		MD_PriceType,CouponCode,Expiration,
		StopDate
	order by 1,2,3	

	End

Else 

	begin
	
	select YearOfMailing, MonthOfMailing, DLREMailDate, 
		AdCode, AdcodeName,
		CatalogCode, CatalogName, 
		MD_Year, MD_Country, MD_Audience,
		MD_ChannelID, MD_ChannelName,
		MD_PromotionTypeID, MD_PromotionType,
		MD_CampaignID, MD_CampaignName,
		MD_PriceType,CouponCode,Expiration,
		StopDate,
		COUNT(customerID) Circ,
		SUM(Orders) Orders, SUM(sales) Sales,SUM(parts) parts, SUM(units) units,
		GETDATE() as ReportDate,
		case when getdate()> dateadd(d,14,Expiration) then 1 /*Expire Adcode record so that going forward we may not update this record*/
		else 0 end as Coupon_expired_flg
	into #temp2
	from #temp
	group by YearOfMailing, MonthOfMailing, DLREMailDate, 
		AdCode, AdcodeName,
		CatalogCode, CatalogName,
		MD_Year, MD_Country, MD_Audience,
		MD_ChannelID, MD_ChannelName,
		MD_PromotionTypeID, MD_PromotionType,
		MD_CampaignID, MD_CampaignName,
		MD_PriceType,CouponCode,Expiration,
		StopDate 
	order by 1,2,3		

	/* Update Adcode changes */
		
	Update a
	set 
			a.Circ = b.Circ,
			a.Orders = b.Orders, 
			a.sales = b.Sales,
			a.units = b.units,
			a.parts = b.parts,			
			a.ReportDate = GETDATE(),
			a.Coupon_expired_flg = b.Coupon_expired_flg
	from Datawarehouse.Marketing.EmailTracker_WPDLR a
	inner join #temp2 b
	on a.Adcode=b.adcode 
	where a.Coupon_expired_flg=0
	
	/* Add new Adcode data */	

	insert into Datawarehouse.Marketing.EmailTracker_WPDLR
	
	select b.*
	from Datawarehouse.Marketing.EmailTracker_WPDLR a 
	right join #temp2 b
	on a.AdCode=b.AdCode 
	where a.AdCode is null 
	

Drop table #temp2	
	End


drop table #temp
End


GO
