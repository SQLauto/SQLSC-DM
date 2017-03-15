SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


  
CREATE Proc [dbo].[SP_LCM_EmailSummary] @full_ind bit=0  
as  
Begin  
  
declare @date datetime  
--@date to Monthly for control need to only go back a month(previous monday)  
set @date = dateadd(week, datediff(week, 0, DATEADD(month,-2,getdate()) ), 0)  
  
--Fullrefersh  
--if @full_ind=1  
set @date='1900-01-01'  
  

select distinct YEAR(a.AcquisitionWeek) AcquisitionYear,   
 MONTH(a.AcquisitionWeek) AcquisitionMonth,  
 cast(a.AcquisitionWeek as date) AcquisitionWeek,  
 cast(a.WelcomeEmailDate as date) EmailDate,  
 a.CustGroup, a.HVLVGroup,  
 a.WelcomeEmailAdcode as Adcode, c.AdcodeName, c.CatalogCode, c.CatalogName,  
 c.MD_Year, c.MD_Country, c.MD_Audience,  
 c.ChannelID MD_ChannelID, c.MD_Channel as MD_ChannelName,  
 c.MD_PromotionTypeID, c.MD_PromotionType,  
 c.MD_CampaignID, c.MD_CampaignName,  
 c.MD_PriceType,  
 a.CustomerID,c.StopDate, convert(int,0) Orders, convert(money,0.0) as Sales, convert(int,0) as parts,CONVERT(int,0) as units  
into #temp   
from LstMgr..WelcomeSeries_Email_General a   
 left join DataWarehouse.Mapping.vwAdcodesAll c on a.WelcomeEmailAdcode = c.adcode  
where a.WelcomeEmailAdcode is not null and WelcomeEmailDate>=@date  
UNION  
select distinct YEAR(a.AcquisitionWeek) AcquisitionYear,   
 MONTH(a.AcquisitionWeek) AcquisitionMonth,  
 cast(a.AcquisitionWeek as date) AcquisitionWeek,  
 cast(a.YourAccountEmailDate as date) EmailDate,  
 a.CustGroup, a.HVLVGroup,  
 a.YourAccountEmailAdcode as Adcode, c.AdcodeName, c.CatalogCode, c.CatalogName,  
 c.MD_Year, c.MD_Country, c.MD_Audience,  
 c.ChannelID MD_ChannelID, c.MD_Channel as MD_ChannelName,  
 c.MD_PromotionTypeID, c.MD_PromotionType,  
 c.MD_CampaignID, c.MD_CampaignName,  
 c.MD_PriceType,  
 a.CustomerID,c.StopDate, convert(int,0) Orders, convert(money,0.0) as Sales, convert(int,0) as parts,CONVERT(int,0) as units  
from LstMgr..WelcomeSeries_Email_General a   
 left join DataWarehouse.Mapping.vwAdcodesAll c on a.YourAccountEmailAdcode = c.adcode  
where a.YourAccountEmailAdcode is not null and  YourAccountEmailDate>=@date  
UNION  
select distinct YEAR(a.AcquisitionWeek) AcquisitionYear,   
 MONTH(a.AcquisitionWeek) AcquisitionMonth,  
 cast(a.AcquisitionWeek as date) AcquisitionWeek,  
 cast(a.FeedBackEmailDate as date) EmailDate,  
 a.CustGroup, a.HVLVGroup,  
 a.FeedBackEmailAdcode as Adcode, c.AdcodeName, c.CatalogCode, c.CatalogName,  
 c.MD_Year, c.MD_Country, c.MD_Audience,  
 c.ChannelID MD_ChannelID, c.MD_Channel as MD_ChannelName,  
 c.MD_PromotionTypeID, c.MD_PromotionType,  
 c.MD_CampaignID, c.MD_CampaignName,  
 c.MD_PriceType,  
 a.CustomerID,c.StopDate, convert(int,0) Orders, convert(money,0.0) as Sales, convert(int,0) as parts,CONVERT(int,0) as units  
from LstMgr..WelcomeSeries_Email_General a   
 left join DataWarehouse.Mapping.vwAdcodesAll c on a.FeedBackEmailAdcode= c.adcode  
where a.FeedBackEmailAdcode is not null and FeedBackEmailDate>=@date  
UNION  
select distinct YEAR(a.AcquisitionWeek) AcquisitionYear,   
 MONTH(a.AcquisitionWeek) AcquisitionMonth,  
 cast(a.AcquisitionWeek as date) AcquisitionWeek,  
 cast(a.RecoEmailDate as date) EmailDate,  
 a.CustGroup, a.HVLVGroup,  
 a.RecoEmailAdcode as Adcode, c.AdcodeName, c.CatalogCode, c.CatalogName,  
 c.MD_Year, c.MD_Country, c.MD_Audience,  
 c.ChannelID MD_ChannelID, c.MD_Channel as MD_ChannelName,  
 c.MD_PromotionTypeID, c.MD_PromotionType,  
 c.MD_CampaignID, c.MD_CampaignName,  
 c.MD_PriceType,  
 a.CustomerID,c.StopDate, convert(int,0) Orders, convert(money,0.0) as Sales, convert(int,0) as parts,CONVERT(int,0) as units  
from LstMgr..WelcomeSeries_Email_General a   
 left join DataWarehouse.Mapping.vwAdcodesAll c on a.RecoEmailAdcode= c.adcode   
where a.RecoEmailAdcode is not null and RecoEmailDate>=@date  
UNION  
select distinct YEAR(a.AcquisitionWeek) AcquisitionYear,   
 MONTH(a.AcquisitionWeek) AcquisitionMonth,  
 cast(a.AcquisitionWeek as date) AcquisitionWeek,  
 cast(a.JFYEmailDLRDate as date) EmailDate,  
 a.CustGroup, a.HVLVGroup,  
 a.JFYEmailDLRAdcode as Adcode, c.AdcodeName, c.CatalogCode, c.CatalogName,  
 c.MD_Year, c.MD_Country, c.MD_Audience,  
 c.ChannelID MD_ChannelID, c.MD_Channel as MD_ChannelName,  
 c.MD_PromotionTypeID, c.MD_PromotionType,  
 c.MD_CampaignID, c.MD_CampaignName,  
 c.MD_PriceType,  
 a.CustomerID,c.StopDate, convert(int,0) Orders, convert(money,0.0) as Sales, convert(int,0) as parts,CONVERT(int,0) as units  
from LstMgr..WelcomeSeries_Email_General a   
 left join DataWarehouse.Mapping.vwAdcodesAll c on a.JFYEmailDLRAdcode= c.adcode   
where a.JFYEmailDLRAdcode is not null and JFYEmailDLRDate>= @date  


  
/* NEW LCM */    

--WelcomeEmails (Adcode1)
select distinct YEAR(a.AcquisitionWeek) AcquisitionYear,   
 MONTH(a.AcquisitionWeek) AcquisitionMonth,  
 cast(a.AcquisitionWeek as date) AcquisitionWeek,  
 cast(c.StartDate + 5  as date) EmailDate,  
 a.CustGroup, a.HVLVGroup,  
 a.EmailAdcode1 as Adcode, c.AdcodeName, c.CatalogCode, c.CatalogName,  
 c.MD_Year, c.MD_Country, c.MD_Audience,  
 c.ChannelID MD_ChannelID, c.MD_Channel as MD_ChannelName,  
 c.MD_PromotionTypeID, c.MD_PromotionType,  
 c.MD_CampaignID, c.MD_CampaignName,  
 c.MD_PriceType,  
 a.CustomerID,c.StopDate, convert(int,0) Orders, convert(money,0.0) as Sales, convert(int,0) as parts,CONVERT(int,0) as units  
into #NewLCM   
from lstmgr.dbo.LCM_WelcomeEmails2015 (nolock) a   
 left join DataWarehouse.Mapping.vwAdcodesAll c on a.EmailAdcode1 = c.adcode  
where a.EmailAdcode1 is not null and c.StartDate + 5>=@date  

UNION
--LTGEmail (Adcode2)
select distinct YEAR(a.AcquisitionWeek) AcquisitionYear,   
 MONTH(a.AcquisitionWeek) AcquisitionMonth,  
 cast(a.AcquisitionWeek as date) AcquisitionWeek,  
 cast(c.StartDate + 5 as date) EmailDate,  
 a.CustGroup, a.HVLVGroup,  
 a.EmailAdcode2 as Adcode, c.AdcodeName, c.CatalogCode, c.CatalogName,  
 c.MD_Year, c.MD_Country, c.MD_Audience,  
 c.ChannelID MD_ChannelID, c.MD_Channel as MD_ChannelName,  
 c.MD_PromotionTypeID, c.MD_PromotionType,  
 c.MD_CampaignID, c.MD_CampaignName,  
 c.MD_PriceType,  
 a.CustomerID,c.StopDate, convert(int,0) Orders, convert(money,0.0) as Sales, convert(int,0) as parts,CONVERT(int,0) as units  
from lstmgr.dbo.LCM_WelcomeEmails2015 (nolock) a   
 left join DataWarehouse.Mapping.vwAdcodesAll c on a.EmailAdcode2 = c.adcode  
where a.EmailAdcode2 is not null and c.StartDate + 5>=@date  

UNION
select distinct YEAR(a.AcquisitionWeek) AcquisitionYear,   
 MONTH(a.AcquisitionWeek) AcquisitionMonth,  
 cast(a.AcquisitionWeek as date) AcquisitionWeek,  
 cast(c.StartDate + 5 as date) EmailDate,  
 a.CustGroup, a.HVLVGroup,  
 a.EmailAdcode3 as Adcode, c.AdcodeName, c.CatalogCode, c.CatalogName,  
 c.MD_Year, c.MD_Country, c.MD_Audience,  
 c.ChannelID MD_ChannelID, c.MD_Channel as MD_ChannelName,  
 c.MD_PromotionTypeID, c.MD_PromotionType,  
 c.MD_CampaignID, c.MD_CampaignName,  
 c.MD_PriceType,  
 a.CustomerID,c.StopDate, convert(int,0) Orders, convert(money,0.0) as Sales, convert(int,0) as parts,CONVERT(int,0) as units  
from lstmgr.dbo.LCM_WelcomeEmails2015 (nolock) a   
 left join DataWarehouse.Mapping.vwAdcodesAll c on a.EmailAdcode3 = c.adcode  
where a.EmailAdcode3 is not null and c.StartDate + 5>=@date  

UNION
--NCJFYEmail (Adcode4)
select distinct YEAR(a.AcquisitionWeek) AcquisitionYear,   
 MONTH(a.AcquisitionWeek) AcquisitionMonth,  
 cast(a.AcquisitionWeek as date) AcquisitionWeek,  
 cast(c.StartDate + 5 as date) EmailDate,  
 a.CustGroup, a.HVLVGroup,  
 a.EmailAdcode4 as Adcode, c.AdcodeName, c.CatalogCode, c.CatalogName,  
 c.MD_Year, c.MD_Country, c.MD_Audience,  
 c.ChannelID MD_ChannelID, c.MD_Channel as MD_ChannelName,  
 c.MD_PromotionTypeID, c.MD_PromotionType,  
 c.MD_CampaignID, c.MD_CampaignName,  
 c.MD_PriceType,  
 a.CustomerID,c.StopDate, convert(int,0) Orders, convert(money,0.0) as Sales, convert(int,0) as parts,CONVERT(int,0) as units  
from lstmgr.dbo.LCM_WelcomeEmails2015 (nolock) a   
 left join DataWarehouse.Mapping.vwAdcodesAll c on a.EmailAdcode4 = c.adcode  
where a.EmailAdcode4 is not null and c.StartDate + 5 >=@date  


/*Update Counts*/  
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
                     
/*Update Counts for NEWLCM*/  
update a  
set a.orders = b.orders,  
 a.sales = b.sales,  
 a.units = b.units,  
 a.parts = b.parts    
from #NewLCM a join   
 (select a.customerID, a.AdCode, SUM(b.NetOrderamount) sales, COUNT(b.orderid) Orders, SUM(b.TotalCourseParts) parts, SUM(b.TotalCourseQuantity) units  
 from #NewLCM a  
 join DataWarehouse.Marketing.DMPurchaseOrders b on a.CustomerID = b.CustomerID  
          and a.AdCode = b.AdCode  
 group by a.CustomerID, a.AdCode)b on a.CustomerID = b.CustomerID  
         and a.AdCode = b.AdCode  

            
  
--Fullrefersh  
if @full_ind=1            
 begin  
  Print'Fullrefersh'
   IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Marketing].[LCMEmailTracker]') AND type in (N'U'))  
   drop table DataWarehouse.[Marketing].[LCMEmailTracker]  
     print ' Drop LCM '
  --LCMEmailTracker_20132014 to LCMEmailTracker  
  
  select AcquisitionYear,   
   AcquisitionMonth,  
   AcquisitionWeek,  
   EmailDate,  
   CustGroup,   
   HVLVGroup,  
   AdCode,   
   AdcodeName,  
   CatalogCode,   
   CatalogName,   
   MD_Year,   
   MD_Country,   
   MD_Audience,  
   MD_ChannelID,   
   MD_ChannelName,  
   MD_PromotionTypeID,   
   MD_PromotionType,  
   MD_CampaignID,   
   MD_CampaignName,  
   MD_PriceType,  
   COUNT(customerID) Circ,  
   SUM(Orders) Orders, SUM(sales) Sales,SUM(parts) parts, SUM(units) units,  
   cast(GETDATE()as DATE) as ReportDate,  
   case when getdate()> StopDate + 14 then 1 /*Expire record so that going forward we may not update this record*/  
   else 0 end as Offer_expired_flg  
  into Datawarehouse.Marketing.LCMEmailTracker   
  from #temp  
  group by AcquisitionYear,   
   AcquisitionMonth,  
   AcquisitionWeek,  
   EmailDate,  
   CustGroup,   
   HVLVGroup,  
   AdCode,   
   AdcodeName,  
   CatalogCode,   
   CatalogName,   
   MD_Year,   
   MD_Country,   
   MD_Audience,  
   MD_ChannelID,   
   MD_ChannelName,  
   MD_PromotionTypeID,   
   MD_PromotionType,  
   MD_CampaignID,   
   MD_CampaignName,  
   MD_PriceType,  
   StopDate  
  order by 1,2,3   
  
   print ' Recreated LCM '
--NewLCM Process  
  
   IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Marketing].[LCMEmailTrackerNew]') AND type in (N'U'))  
   drop table DataWarehouse.[Marketing].[LCMEmailTrackerNew]  
  
   print ' Drop NewLCM '
  select AcquisitionYear,   
   AcquisitionMonth,  
   AcquisitionWeek,  
   EmailDate,  
   CustGroup,   
   HVLVGroup,  
   AdCode,   
   AdcodeName,  
   CatalogCode,   
   CatalogName,   
   MD_Year,   
   MD_Country,   
   MD_Audience,  
   MD_ChannelID,   
   MD_ChannelName,  
   MD_PromotionTypeID,   
   MD_PromotionType,  
   MD_CampaignID,   
   MD_CampaignName,  
   MD_PriceType,  
   COUNT(customerID) Circ,  
   SUM(Orders) Orders, SUM(sales) Sales,SUM(parts) parts, SUM(units) units,  
   cast(GETDATE()as DATE) as ReportDate,  
   case when getdate()> StopDate + 14 then 1 /*Expire record so that going forward we may not update this record*/  
   else 0 end as Offer_expired_flg  
  into Datawarehouse.Marketing.LCMEmailTrackerNew   
  from #NewLCM  
  group by AcquisitionYear,   
   AcquisitionMonth,  
   AcquisitionWeek,  
   EmailDate,  
   CustGroup,   
   HVLVGroup,  
   AdCode,   
   AdcodeName,  
   CatalogCode,   
   CatalogName,   
   MD_Year,   
   MD_Country,   
   MD_Audience,  
   MD_ChannelID,   
   MD_ChannelName,  
   MD_PromotionTypeID,   
   MD_PromotionType,  
   MD_CampaignID,   
   MD_CampaignName,  
   MD_PriceType,  
   StopDate  
  order by 1,2,3     

 print ' Recreated NewLCM '
  
 end  
  
else  
  
Begin  
    Print'Delta refersh'
  select AcquisitionYear,   
   AcquisitionMonth,  
   AcquisitionWeek,  
   EmailDate,  
   CustGroup,   
   HVLVGroup,  
   AdCode,   
   AdcodeName,  
   CatalogCode,   
   CatalogName,   
   MD_Year,   
   MD_Country,   
   MD_Audience,  
   MD_ChannelID,   
   MD_ChannelName,  
   MD_PromotionTypeID,   
   MD_PromotionType,  
   MD_CampaignID,   
   MD_CampaignName,  
   MD_PriceType,  
   COUNT(customerID) Circ,  
   SUM(Orders) Orders, SUM(sales) Sales,SUM(parts) parts, SUM(units) units,  
   cast(GETDATE()as DATE) as ReportDate,  
   case when getdate()> StopDate + 14 then 1 /*Expire record so that going forward we may not update this record*/  
   else 0 end as Offer_expired_flg  
  into #temp2  
  from #temp  
  group by AcquisitionYear,   
   AcquisitionMonth,  
   AcquisitionWeek,  
   EmailDate,  
   CustGroup,   
   HVLVGroup,  
   AdCode,   
   AdcodeName,  
   CatalogCode,   
   CatalogName,   
   MD_Year,   
   MD_Country,   
   MD_Audience,  
   MD_ChannelID,   
   MD_ChannelName,  
   MD_PromotionTypeID,   
   MD_PromotionType,  
   MD_CampaignID,   
   MD_CampaignName,  
   MD_PriceType,  
   StopDate  
  order by 1,2,3   
   
   
   
   
  select AcquisitionYear,   
   AcquisitionMonth,  
   AcquisitionWeek,  
   EmailDate,  
   CustGroup,   
   HVLVGroup,  
   AdCode,   
   AdcodeName,  
   CatalogCode,   
   CatalogName,   
   MD_Year,   
   MD_Country,   
   MD_Audience,  
   MD_ChannelID,   
   MD_ChannelName,  
   MD_PromotionTypeID,   
   MD_PromotionType,  
   MD_CampaignID,   
   MD_CampaignName,  
   MD_PriceType,  
   COUNT(customerID) Circ,  
   SUM(Orders) Orders, SUM(sales) Sales,SUM(parts) parts, SUM(units) units,  
   cast(GETDATE()as DATE) as ReportDate,  
   case when getdate()> StopDate + 14 then 1 /*Expire record so that going forward we may not update this record*/  
   else 0 end as Offer_expired_flg  
  into #NewLCM2  
  from #NewLCM  
  group by AcquisitionYear,   
   AcquisitionMonth,  
   AcquisitionWeek,  
   EmailDate,  
   CustGroup,   
   HVLVGroup,  
   AdCode,   
   AdcodeName,  
   CatalogCode,   
   CatalogName,   
   MD_Year,   
   MD_Country,   
   MD_Audience,  
   MD_ChannelID,   
   MD_ChannelName,  
   MD_PromotionTypeID,   
   MD_PromotionType,  
   MD_CampaignID,   
   MD_CampaignName,  
   MD_PriceType,  
   StopDate  
  order by 1,2,3     
   
 
 
 /* Update Adcode changes */  
 print ' Updates to LCM '   
 Update a  
 set   
   a.Circ = b.Circ,  
   a.Orders = b.Orders,   
   a.sales = b.Sales,  
   a.units = b.units,  
   a.parts = b.parts,      
   a.ReportDate = cast(GETDATE()as DATE),  
   a.Offer_expired_flg = b.Offer_expired_flg  
 from Datawarehouse.Marketing.LCMEmailTracker a  
 inner join #temp2 b  
 on a.Adcode=b.adcode and a.HVLVGroup=b.HVLVGroup  
 where a.Offer_expired_flg=0  
   
 /* Add new Adcode data */   
 print ' Insert to LCM '
 insert into Datawarehouse.Marketing.LCMEmailTracker  
   
 select b.*  
 from Datawarehouse.Marketing.LCMEmailTracker a   
 right join #temp2 b  
 on a.AdCode=b.AdCode and a.HVLVGroup=b.HVLVGroup  
 where a.AdCode is null   
  
 drop table #temp2  
 
 print ' Updates to NewLCM '
 
  Update a  
 set   
   a.Circ = b.Circ,  
   a.Orders = b.Orders,   
   a.sales = b.Sales,  
   a.units = b.units,  
   a.parts = b.parts,      
   a.ReportDate = cast(GETDATE()as DATE),  
   a.Offer_expired_flg = b.Offer_expired_flg  
 from Datawarehouse.Marketing.LCMEmailTrackerNew a  
 inner join #NewLCM2 b  
 on a.Adcode=b.adcode and a.HVLVGroup=b.HVLVGroup  
 where a.Offer_expired_flg=0  
   
 /* Add new Adcode data */   
  print ' Insert to NewLCM '
  
 insert into Datawarehouse.Marketing.LCMEmailTrackerNew  
   
 select b.*  
 from Datawarehouse.Marketing.LCMEmailTrackerNew a   
 right join #NewLCM2 b  
 on a.AdCode=b.AdCode and a.HVLVGroup=b.HVLVGroup  
 where a.AdCode is null   
  
 drop table #NewLCM2  
 
  
End  
  
  
drop table #NewLCM  
drop table #temp  
  
END  
  


GO
