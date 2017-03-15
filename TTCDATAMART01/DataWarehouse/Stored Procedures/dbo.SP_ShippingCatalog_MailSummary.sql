SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE Proc [dbo].[SP_ShippingCatalog_MailSummary] @full_ind bit=1
as
Begin

declare @date datetime
--@date to Monthly for control need to only go back a month(previous monday)
set @date = dateadd(week, datediff(week, 0, DATEADD(month,-2,getdate()) ), 0)

--Fullrefersh
if @full_ind=1
set @date='1900-01-01'


select a.CustomerID,
	a.HVLVGroup,
	coalesce(a.ItemID,'RM0533') ItemID,
	c.Description as ItemName,
	Year(a.AcquisitionWeek) YearOfAcquisition,
	Month(a.AcquisitionWeek) MonthOfAcquisition,
	cast(a.AcquisitionWeek as date) AcquisitionDate,
	DM.AdCode as PurchAdCode, 
	DM.AdcodeName as PurchAdcodeName,
	DM.CatalogCode as PurchCatalogCode,
	DM.CatalogName as PurchCatalogName,	
	DM.MD_Year PurchMD_Year, 
	DM.MD_Country PurchMD_Country, 
	DM.MD_Audience PurchMD_Audience,	
	DM.MD_ChannelID PurchMD_ChannelID, 
	DM.MD_ChannelName PurchMD_ChannelName,
	DM.MD_PromotionTypeID PurchMD_PromotionTypeID, 
	DM.MD_PromotionType PurchMD_PromotionType,	
	DM.MD_CampaignID PurchMD_CampaignID, 
	DM.MD_CampaignName PurchMD_CampaignName,
	DM.StopDate PurchStopDate,	
	DM.MD_PriceType PurchMD_PriceType,
	convert(int,0) Orders, 
	convert(money,0.0) as Sales, 
	convert(money,0.0) as parts,
	CONVERT(int,0) as units
into #temp
from rfm.dbo.WPTest_Random2013 a
Left join (	select DM.AdCode, c.AdcodeName,c.CatalogCode,
			c.CatalogName,	c.MD_Year, c.MD_Country, c.MD_Audience,	c.ChannelID MD_ChannelID, c.MD_Channel as MD_ChannelName,
			c.MD_PromotionTypeID, c.MD_PromotionType,	c.MD_CampaignID, c.MD_CampaignName,c.StopDate,	c.MD_PriceType,
			DM.customerid
			from  DataWarehouse.Marketing.DMPurchaseOrders DM 
			inner join DataWarehouse.Mapping.vwAdcodesAll c on DM.adcode = c.adcode and MD_CampaignID = 1000
		) DM on dm.customerid = a.customerid
left join DAXImports..Load_InvItem c on coalesce(a.ItemID,'RM0533') = c.UserStockItemID		
where a.AcquisitionWeek >=@date



update a
set a.orders = b.orders,
	a.sales = b.sales,
	a.units = b.units,
	a.parts = b.parts	
from #temp a join	
	(select a.customerID, a.PurchAdCode, SUM(b.NetOrderamount) sales, COUNT(b.orderid) Orders, SUM(b.TotalCourseParts) parts, SUM(b.TotalCourseQuantity) units
	from #temp a
	join DataWarehouse.Marketing.DMPurchaseOrders b on a.CustomerID = b.CustomerID
										and a.PurchAdCode = b.AdCode
	group by a.CustomerID, a.PurchAdCode)b on a.CustomerID = b.CustomerID
									and a.PurchAdCode = b.PurchAdCode
									
																			

										
if @full_ind=1										
	begin

		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Marketing].[MailTracker_ShippingCatalog]') AND type in (N'U'))
		drop table DataWarehouse.[Marketing].[MailTracker_ShippingCatalog]


	select YearOfAcquisition, MonthOfAcquisition, AcquisitionDate,ItemID, ItemName,
		PurchAdCode, PurchAdcodeName,
		PurchCatalogCode, PurchCatalogName, 
		PurchMD_Year, PurchMD_Country, PurchMD_Audience,
		PurchMD_ChannelID, PurchMD_ChannelName,
		PurchMD_PromotionTypeID, PurchMD_PromotionType,
		PurchMD_CampaignID, PurchMD_CampaignName,
		PurchMD_PriceType,HVLVGroup,PurchStopDate,
		COUNT(customerID) Circ,
		SUM(Orders) Orders, SUM(sales) Sales,SUM(parts) parts, SUM(units) units,
		cast(GETDATE()as DATE) as ReportDate,
		case when getdate()> PurchStopDate + 14 then 1 /*Expire Adcode record so that going forward we may not update this record*/
		else 0 end as Offer_expired_flg
	into Datawarehouse.Marketing.MailTracker_ShippingCatalog	
	from #temp
	group by YearOfAcquisition, MonthOfAcquisition, AcquisitionDate, ItemID, ItemName,
		PurchAdCode, PurchAdcodeName,
		PurchCatalogCode, PurchCatalogName, 
		PurchMD_Year, PurchMD_Country, PurchMD_Audience,
		PurchMD_ChannelID, PurchMD_ChannelName,
		PurchMD_PromotionTypeID, PurchMD_PromotionType,
		PurchMD_CampaignID, PurchMD_CampaignName,
		PurchMD_PriceType,HVLVGroup,PurchStopDate
	order by 1,2,3	

	End

Else

	begin
	
	select YearOfAcquisition, MonthOfAcquisition, AcquisitionDate, ItemID, ItemName,
		PurchAdCode, PurchAdcodeName,
		PurchCatalogCode, PurchCatalogName, 
		PurchMD_Year, PurchMD_Country, PurchMD_Audience,
		PurchMD_ChannelID, PurchMD_ChannelName,
		PurchMD_PromotionTypeID, PurchMD_PromotionType,
		PurchMD_CampaignID, PurchMD_CampaignName,
		PurchMD_PriceType,HVLVGroup, PurchStopDate,
		COUNT(customerID) Circ,
		SUM(Orders) Orders, SUM(sales) Sales,SUM(parts) parts, SUM(units) units,
		cast(GETDATE()as DATE) as ReportDate,
		case when getdate()> PurchStopDate + 14 then 1 /*Expire Adcode record so that going forward we may not update this record*/
		else 0 end as Offer_expired_flg
	into #temp2
	from #temp
	group by YearOfAcquisition, MonthOfAcquisition, AcquisitionDate, ItemID, ItemName,
		PurchAdCode, PurchAdcodeName,
		PurchCatalogCode, PurchCatalogName, 
		PurchMD_Year, PurchMD_Country, PurchMD_Audience,
		PurchMD_ChannelID, PurchMD_ChannelName,
		PurchMD_PromotionTypeID, PurchMD_PromotionType,
		PurchMD_CampaignID, PurchMD_CampaignName,
		PurchMD_PriceType,HVLVGroup,PurchStopDate
	order by 1,2,3		

	/* Update Adcode changes */
		
	Update a
	set 
			a.Circ = b.Circ,
			a.Orders = b.Orders, 
			a.sales = b.Sales,
			a.units = b.units,
			a.parts = b.parts,			
			a.ReportDate = cast(GETDATE() as DATE), 
			a.Offer_expired_flg = b.Offer_expired_flg
	from Datawarehouse.Marketing.MailTracker_ShippingCatalog a
	inner join #temp2 b
	on a.PurchAdcode=b.Purchadcode 
	where a.Offer_expired_flg=0
	
	/* Add new Adcode data */	

	insert into Datawarehouse.Marketing.MailTracker_ShippingCatalog
	
	select b.*
	from Datawarehouse.Marketing.MailTracker_ShippingCatalog a 
	right join #temp2 b
	on a.PurchAdCode=b.PurchAdCode 
	where a.PurchAdCode is null 
	

Drop table #temp2	
	End


drop table #temp
End


GO
