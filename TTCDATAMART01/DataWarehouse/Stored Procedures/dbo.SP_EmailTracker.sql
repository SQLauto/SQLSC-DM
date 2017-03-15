SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
   
    
CREATE Proc [dbo].[SP_EmailTracker]     
as    
Begin    
    
Declare @Adcode int    
    
truncate table DataWarehouse.Staging.TempEmailTrackerNew     
    
    
/*Delta Refresh*/    
Begin    
    
/********Get Adcodes Which are currently Not Expired*********/    
--#Adcode    
    
select Ad.Adcode,ComboID, His.StartDate EmailSentDate, COUNT(His.customerid) Counts, Cast(0 as bit) as processed    
into #Adcode    
from DataWarehouse.Mapping.vwAdcodesAll Ad (nolock)    
left join DataWarehouse.Archive.EmailhistoryCurrentYear His    
on his.Adcode = Ad.AdCode    
where AD.MD_PromotionType like 'House Email%'    
and GETDATE() between AD.StartDate and AD.StopDate+3    
and ad.StartDate >= DATEADD(month,-2,getdate())    
and his.FlagHoldOut = 0    
group by Ad.Adcode, His.StartDate,ComboID    
having COUNT(his.customerid) > 0    
union     
select Ad.Adcode,'CCN2M' as ComboID, His.StartDate EmailSentDate, null as  Counts, Cast(0 as bit) as processed     
from DataWarehouse.Mapping.vwAdcodesAll Ad (nolock)    
left join DataWarehouse.Archive.EmailhistoryCurrentYear His    
on his.Adcode = Ad.AdCode    
where AD.MD_PromotionType like 'House Email%'    
and GETDATE() between AD.StartDate and AD.StopDate+3    
and ad.StartDate >= DATEADD(month,-2,getdate())    
and his.FlagHoldOut = 0    
group by Ad.Adcode, His.StartDate    
having COUNT(his.customerid) > 0    
    
--#EmailedAdcodes (Adcode/Comboid)    
select a.AdCode,AD.AdcodeName,AD.CatalogCode,AD.CatalogName,A.ComboID,a.counts as CountOfEmailsSent,a.EmailSentDate as EmailSentDate,    
  year(a.EmailSentDate) YearOfEmailSent,Month(a.EmailSentDate) MonthOfEmailSent,MD_Year,MD_Audience,MD_Channel,AD.MD_PromotionType ,    
  AD.MD_CampaignName,MD_PriceType,MD_Country,AD.StartDate,AD.StopDate,Lkup.SeqNum,Lkup.CustomerSegment,Lkup.MultiOrSingle,    
  Lkup.NewSeg,Lkup.Name,Lkup.A12mf,Lkup.CustomerSegmentFnl,Lkup.CustomerSegment2, case when dateadd(d,3,AD.StopDate) > CAST(GETDATE() as date) then 0 else 1 end as FlagCompleted ,a.processed    
Into #EmailedAdcodes              
from #Adcode a    
Inner join DataWarehouse.Mapping.vwAdcodesAll Ad (nolock)    
on A.Adcode = Ad.AdCode    
left join (select distinct Lkup.comboid, Lkup.SeqNum,Lkup.CustomerSegment,Lkup.MultiOrSingle,    
    Lkup.NewSeg,Lkup.Name,Lkup.A12mf,Lkup.CustomerSegmentFnl,Lkup.CustomerSegment2     
       from DataWarehouse.Mapping.RFMComboLookup  Lkup (nolock)    
   ) Lkup on Lkup.Comboid = CASE WHEN A.ComboID = 'Inq' THEN '25-10000 Mo Inq'       
                                             ELSE ISNULL(A.ComboID,'Unknown')      
                                        END        
where EmailSentDate is not null    
    
  
    
    
 while exists(select top 1 Adcode from #EmailedAdcodes where processed = 0)    
  Begin     
      
   select top 1 @adcode = Adcode from #EmailedAdcodes where processed = 0    
       
   --select @adcode Adcode    
    
     select CustomerID,Adcode,StartDate,FlagHoldOut,ComboID,PreferredCategory    
     into #EH     
     from DataWarehouse.Archive.EmailhistoryCurrentYear EH    
     where AdCode = @adcode    
    
     select CustomerID,OrderID,OrderSource,AdCode,NetOrderAmount,TotalCourseSales,TotalCourseParts,TotalCourseQuantity as TotalCourseUnits    
     into #DM     
     from DataWarehouse.Marketing.DMPurchaseOrders DM    
     where AdCode = @adcode    
    
     insert into DataWarehouse.Staging.TempEmailTrackerNew     
     select  isnull(EH.adcode,@adcode)adcode,isnull(EH.comboid,'CCN2M') comboid,    
       case when FlagHoldOut = 1 then 0     
         when EH.CustomerID is null and DM.CustomerID is not null then 2    
         else 1 end as FlagEmailed,    
          DM.CustomerID as DMCustomerID,OrderID,OrderSource,NetOrderAmount,TotalCourseSales,TotalCourseParts,TotalCourseUnits,    
          EH.CustomerID EMailHistCustomerID,EH.FlagHoldOut,EH.PreferredCategory    
     from #EH EH    
     Full Outer join #DM DM    
     on EH.Adcode = DM.Adcode and DM.Customerid = Eh.CustomerID    
    
        
    drop table #EH     
    drop table #DM     
        
   Update #EmailedAdcodes     
   set processed = 1    
   where AdCode = @adcode    
        
        
        
  End    
    
    
/**************************************************      #EmailTracker      ***********************************************************/    
    
   select     
     A.AdCode,A.AdcodeName,A.CatalogCode,A.CatalogName,A.ComboID,Count(distinct EMailHistCustomerID) as TotalEmailed,A.EmailSentDate as EHistStartDate,    
     A.YearOfEmailSent,A.MonthOfEmailSent,A.MD_Year,A.MD_Audience,A.MD_Channel,A.MD_PromotionType ,A.MD_CampaignName,A.MD_PriceType,    
     A.MD_Country,A.StartDate as CCTblStartDate,A.StopDate,A.SeqNum,A.CustomerSegment,A.MultiOrSingle,A.NewSeg,A.Name,A.A12mf,    
     A.CustomerSegmentFnl,A.CustomerSegment2,t.FlagEmailed,count(t.DMCustomerID)CustCount, count(T.OrderID) TotalOrders,    
     t.OrderSource,sum(t.NetOrderAmount) TotalSales ,sum(t.TotalCourseSales) TotalCourseSales,sum(t.TotalCourseParts) TotalCourseParts,    
     sum(t.TotalCourseUnits) TotalCourseUnits,getdate() as EmailUpdateDate , getdate() as TableUpdateDate,MIN(FlagCompleted) as FlagCompleted    
    
   into #EmailTracker    
   from #EmailedAdcodes A    
   left join DataWarehouse.Staging.TempEmailTrackerNew t    
   on A.AdCode = t.adcode and A.ComboID = t.ComboID    
   group by A.AdCode,A.AdcodeName,A.CatalogCode,A.CatalogName,A.ComboID,A.CountOfEmailsSent,A.EmailSentDate,A.YearOfEmailSent,    
     A.MonthOfEmailSent,A.MD_Year,A.MD_Audience,A.MD_Channel,A.MD_PromotionType ,A.MD_CampaignName,A.MD_PriceType,A.MD_Country,    
     A.StartDate,A.StopDate,A.SeqNum,A.CustomerSegment,A.MultiOrSingle,A.NewSeg,A.Name,A.A12mf,A.CustomerSegmentFnl,    
     A.CustomerSegment2, t.FlagEmailed,t.OrderSource    
    
   
   
 /*Updating CCN2M values to default*/    
  Update #EmailTracker  
  set CustomerSegment = 'CCN2M'  
 ,CustomerSegmentFnl ='CCN2M'  
 ,CustomerSegment2 = 'CCN2M'  
 ,SeqNum =101  
 where comboid = 'CCN2M'  
    
     
  delete from DataWarehouse.marketing.EmailTrackerNew    
  where adcode in (select distinct adcode from #EmailTracker)    
    
  insert into  DataWarehouse.marketing.EmailTrackerNew     
  select * from #EmailTracker    
    
  update DataWarehouse.marketing.EmailTrackerNew      
  set TableUpdateDate = getdate()       
    
drop table #Adcode    
drop table #EmailedAdcodes    
drop table #EmailTracker    
    
/* End Delta Refresh*/    
End    
    
    
END    
    
    
    
    
    
    
    
  
  
  
GO
