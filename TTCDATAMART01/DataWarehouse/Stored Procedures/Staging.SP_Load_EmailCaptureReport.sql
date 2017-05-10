SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [Staging].[SP_Load_EmailCaptureReport]
As
Begin


/* BondugulaV 3/31/2017  

1) Datawarehouse.archive.EmailCaptureReportByCoupons 
2) Datawarehouse.archive.EmailCaptureReportByEmailSignUp
3) Datawarehouse.archive.EmailCaptureReportByOrders
4) Datawarehouse.archive.EmailCaptureReportByOrdersAllRegSource

*/

 /* Load Coupons for future Campaings into DataWarehouse.Mapping.EmailCaptureCoupon */
  
    /* registration_source_id = 7 only*/
	select a.email Email1, a.created_date, a.registration_source_id, d.name as RegistrationSource,	b.*, c.CustomerSince											
	into #EmailCapture											
	from DataWarehouse.staging.EPC_ssis_preference a 
	left join DataWarehouse.Marketing.epc_preference b 
	on a.email = b.Email 
	left join DataWarehouse.Marketing.CampaignCustomerSignature c 
	on b.CustomerID = c.CustomerID	
	left join MagentoImports..epc_registration_source d 
	on a.registration_source_id = d.registration_source_id										
	where a.created_date >= '12/14/2016' and a.registration_source_id = 7			
	
	/* No registration_source_id filter all sources after 12/14/2016*/
	select a.email Email1, a.created_date, a.registration_source_id, d.name as RegistrationSource,	b.*, c.CustomerSince											
	into #EmailCaptureALL											
	from DataWarehouse.staging.EPC_ssis_preference a 
	left join DataWarehouse.Marketing.epc_preference b 
	on a.email = b.Email 
	left join DataWarehouse.Marketing.CampaignCustomerSignature c 
	on b.CustomerID = c.CustomerID	
	left join MagentoImports..epc_registration_source d 
	on a.registration_source_id = d.registration_source_id										
	where a.created_date >= '12/14/2016'  										
									

	/* Coupon Orders */
	select a.*, b.JSCOUPONNUMBER 											
	into #CouponOrders												
	from DataWarehouse.Marketing.DMPurchaseOrders a 
	left join DAXImports..Load_Coupons b 
	on a.Coupon = b.jscouponid 
	join DataWarehouse.Mapping.EmailCaptureCoupon c 
	on b.JSCOUPONNUMBER = c.couponNumber


	select a.*, 										
	case when DATEDIFF(day,a.created_date,a.customersince) < -1 then 'Existing' else 'New' end as CustType,									
	b.JSCOUPONNUMBER, b.CurrencyCode,									
	b.Coupon, b.CouponDesc, isnull(b.Orders,0) Orders,									
	isnull(b.Sales,0) Sales		
	Into #EmailCaptureOrders							
	from #EmailCapture a 
	left join (select customerid, Coupon, CurrencyCode,									
		JSCOUPONNUMBER, CouponDesc, 								
		count(OrderID) Orders, 								
		sum(NetOrderAmount) Sales								
	from #CouponOrders									
	group by CustomerID, Coupon, CurrencyCode, 									
		JSCOUPONNUMBER, CouponDesc) 
		b on a.CustomerID = b.CustomerID		
	
	

	Truncate table Datawarehouse.archive.EmailCaptureReportByCoupons
	
	Insert into Datawarehouse.archive.EmailCaptureReportByCoupons
	select coupon,JSCOUPONNUMBER,CouponDesc,CustType,CurrencyCode,Count(Email1)EmailCounts,Sum(Orders)Orders,Sum(Sales)Sales , getdate() as DMlastupdated
	--Into Datawarehouse.archive.EmailCaptureReportByCoupons
	from #EmailCaptureOrders
	where coupon is not null
	group by  coupon,JSCOUPONNUMBER,CouponDesc,CustType,CurrencyCode
	Order by  coupon,JSCOUPONNUMBER,CouponDesc,CustType,CurrencyCode


--- report 1			

	Truncate table Datawarehouse.archive.EmailCaptureReportByEmailSignUp
	Insert into Datawarehouse.archive.EmailCaptureReportByEmailSignUp									
	select a.*, 												
		case when DATEDIFF(day,a.created_date,a.customersince) < -1 then 'Existing' else 'New' end as CustType,											
		b.JSCOUPONNUMBER, b.CurrencyCode,										
		b.Coupon, b.CouponDesc, isnull(b.Orders,0) Orders,											
		isnull(b.Sales,0) Sales, getdate() as DMlastupdated	
		--into Datawarehouse.archive.EmailCaptureReportByEmailSignUp									
	from #EmailCapture a 
	left join (select customerid, Coupon, CurrencyCode,JSCOUPONNUMBER, CouponDesc,count(OrderID) Orders, sum(NetOrderAmount) Sales										
				from #CouponOrders											
				group by CustomerID, Coupon, CurrencyCode,JSCOUPONNUMBER, CouponDesc
			   ) b on a.CustomerID = b.CustomerID	
			 
			  
    
--- report 2

	Truncate table Datawarehouse.archive.EmailCaptureReportByOrders

	Insert into Datawarehouse.archive.EmailCaptureReportByOrders			
	select count(distinct a.CustomerID) CountCust, count(a.OrderID) Orders, 			
	sum(a.NetOrderAmount) Sales, a.OrderSource,			
	a.Coupon, JSCOUPONNUMBER, a.CouponDesc,			
	c.MD_Channel, c.MD_PromotionType, c.MD_CampaignName,			
	c.CatalogCode, c.CatalogName, c.AdCode, c.AdcodeName,			
	b.Email, b.Subscribed, b.registration_source_id,			
	case when b.Email is null then 0 else 1 end as FlagEmailSignUP,
	getdate() as DMlastupdated			
	--into Datawarehouse.archive.EmailCaptureReportByOrders			
	from #CouponOrders a left join				
	#EmailCapture b on a.CustomerID = b.CustomerID join			
	DataWarehouse.Mapping.vwAdcodesAll c on a.AdCode = c.AdCode			
	group by a.OrderSource,a.Coupon, JSCOUPONNUMBER, a.CouponDesc,			
	c.MD_Channel, c.MD_PromotionType, c.MD_CampaignName,			
	c.CatalogCode, c.CatalogName, c.AdCode, c.AdcodeName,			
	b.Email, b.Subscribed, b.registration_source_id	
 
--- report 2
/*
select count(distinct a.CustomerID) CountCust, count(a.OrderID) Orders, 
	sum(a.NetOrderAmount) Sales, a.OrderSource,			
	a.Coupon, JSCOUPONNUMBER, a.CouponDesc,			
	c.MD_Channel, c.MD_PromotionType, c.MD_CampaignName,			
	c.CatalogCode, c.CatalogName, c.AdCode, c.AdcodeName,			
	b.Email, b.Subscribed, b.registration_source_id,			
	case when b.Email is null then 0 else 1 end as FlagEmailSignUP,
	getdate() as DMlastupdated			
	into Datawarehouse.archive.EmailCaptureReportByOrdersAllRegSource			
from #CouponOrders a left join				
	#EmailCaptureALL b on a.CustomerID = b.CustomerID join			
	DataWarehouse.Mapping.vwAdcodesAll c on a.AdCode = c.AdCode			
group by a.OrderSource,				
	a.Coupon, JSCOUPONNUMBER, a.CouponDesc,			
	c.MD_Channel, c.MD_PromotionType, c.MD_CampaignName,			
	c.CatalogCode, c.CatalogName, c.AdCode, c.AdcodeName,			
	b.Email, b.Subscribed, b.registration_source_id	
*/



--- report 3				

	Truncate table Datawarehouse.archive.EmailCaptureReportByOrdersAllRegSource

	Insert into Datawarehouse.archive.EmailCaptureReportByOrdersAllRegSource	
	select a.CustomerID, a.OrderID, 
	case when a.SequenceNum <= 3 then convert(varchar(5),a.SequenceNum) else  convert(varchar(5),'4+') end as SequenceNum, 
	case when a.sequenceNum = 1 then 'New' else 'Existing' end as CustomerType,
	b.registration_source_id, b.RegistrationSource, a.DateOrdered,b.created_date, 
	a.NetOrderAmount, a.OrderSource,			
	a.Coupon, JSCOUPONNUMBER, a.CouponDesc,		
	c.MD_Channel, c.MD_PromotionType, c.MD_CampaignName,			
	c.CatalogCode, c.CatalogName, c.AdCode, c.AdcodeName,			
	b.Email, b.Subscribed,case when b.Email is null then 0 else 1 end as FlagEmailSignUP,
	getdate() as DMlastupdated			
	--into Datawarehouse.archive.EmailCaptureReportByOrdersAllRegSource
	from #CouponOrders a left join				
	#EmailCaptureALL b on a.CustomerID = b.CustomerID join			
	DataWarehouse.Mapping.vwAdcodesAll c on a.AdCode = c.AdCode			
	order by a.DateOrdered		


End
GO
