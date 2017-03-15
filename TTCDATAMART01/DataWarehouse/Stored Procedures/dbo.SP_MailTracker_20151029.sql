SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
  
  
CREATE Proc [dbo].[SP_MailTracker_20151029]   
as  
Begin  
  
  
/*Delta Refresh*/  
  
Declare @Adcode int, @StartDate datetime  
  
truncate table DataWarehouse.Staging.TempMailTrackerNew   
  
  
/********Get Adcodes Which are currently Not Expired*********/  
--drop table #Adcode  
  
select Ad.Adcode,ComboID,case when SubjRank = '' then 'NA' else SubjRank end as SubjRank, His.StartDate MailSentDate, COUNT(His.customerid) Counts, Cast(0 as bit) as processed  
into #Adcode  
from DataWarehouse.Mapping.vwAdcodesAll Ad (nolock)  
left join DataWarehouse.Archive.MailhistoryCurrentYear His  
on his.Adcode = Ad.AdCode  
where AD.ChannelID = 1  
and GETDATE() between ad.StopDate and ad.StopDate+21  
and his.FlagHoldOut = 0  
group by Ad.Adcode, His.StartDate,ComboID,case when SubjRank = '' then 'NA' else SubjRank end  
having COUNT(his.customerid) > 0  
union   
select Ad.Adcode,'CCN2M' as ComboID,'NA' as SubjRank, His.StartDate MailSentDate, null as  Counts, Cast(0 as bit) as processed   
from DataWarehouse.Mapping.vwAdcodesAll Ad (nolock)  
left join DataWarehouse.Archive.MailhistoryCurrentYear His  
on his.Adcode = Ad.AdCode  
where AD.ChannelID = 1  
and GETDATE() between ad.StopDate and ad.StopDate+21  
and his.FlagHoldOut = 0  
group by Ad.Adcode, His.StartDate,ComboID  
having COUNT(his.customerid) > 0  
  
--drop table #MailedAdcodes (Adcode/Comboid)  
select a.AdCode,AD.AdcodeName,AD.CatalogCode,AD.CatalogName,A.ComboID,A.SubjRank,a.counts as CountOfMailsSent,a.MailSentDate as MailSentDate,  
  year(a.MailSentDate) YearOfMailSent,Month(a.MailSentDate) MonthOfMailSent,MD_Year,MD_Audience,MD_Channel,AD.MD_PromotionType ,  
  AD.MD_CampaignName,MD_PriceType,MD_Country,AD.StartDate,AD.StopDate,Lkup.SeqNum,Lkup.CustomerSegment,Lkup.MultiOrSingle,  
  Lkup.NewSeg,Lkup.Name,Lkup.A12mf,Lkup.CustomerSegmentFnl,Lkup.CustomerSegment2,Lkup.RFMCells, case when dateadd(d,3,AD.StopDate) > CAST(GETDATE() as date) then 0 else 1 end as FlagCompleted ,a.processed  
Into #MailedAdcodes            
from #Adcode a  
Inner join DataWarehouse.Mapping.vwAdcodesAll Ad (nolock)  
on A.Adcode = Ad.AdCode  
left join (select distinct Lkup.comboid, Lkup.SeqNum,Lkup.CustomerSegment,Lkup.MultiOrSingle,  
    Lkup.NewSeg,Lkup.Name,Lkup.A12mf,Lkup.CustomerSegmentFnl,Lkup.CustomerSegment2,RFMCells   
       from DataWarehouse.Mapping.RFMComboLookup  Lkup (nolock)  
   ) Lkup on Lkup.Comboid = CASE WHEN A.ComboID = 'Inq' THEN '25-10000 Mo Inq'     
                                             ELSE ISNULL(A.ComboID,'Unknown')    
                                        END      
where MailSentDate is not null  
  
--truncate staging      
 truncate table DataWarehouse.Staging.TempMailTrackerNew  
  
--declare @adcode int , @StartDate datetime  
  
 while exists(select top 1 Adcode from #MailedAdcodes where processed = 0)  
  Begin   
    
   select top 1 @adcode = Adcode, @StartDate= StartDate from #MailedAdcodes where processed = 0  
     
   --select @adcode Adcode,@StartDate StartDate  
  
     select CustomerID,Adcode,StartDate,FlagHoldOut,ComboID,case when SubjRank = '' then 'NA' else SubjRank end as SubjRank--,PreferredCategory  
     into #EH   
     from DataWarehouse.Archive.MailhistoryCurrentYear EH  
     where AdCode = @adcode  
  
     select CustomerID,OrderID,OrderSource,AdCode,NetOrderAmount,TotalCourseSales,TotalCourseParts,TotalCourseQuantity as TotalCourseUnits  
     into #DM   
     from DataWarehouse.Marketing.DMPurchaseOrders DM  
     where AdCode = @adcode  
  
     insert into DataWarehouse.Staging.TempMailTrackerNew   
     select  isnull(EH.adcode,@adcode)adcode,isnull(EH.comboid,'CCN2M') comboid,EH.SubjRank,  
       case when FlagHoldOut = 1 then 0   
         when EH.CustomerID is null and DM.CustomerID is not null then 2  
         else 1 end as FlagMailed,  
          DM.CustomerID as DMCustomerID,OrderID,OrderSource,NetOrderAmount,TotalCourseSales,TotalCourseParts,TotalCourseUnits,  
          EH.CustomerID MailHistCustomerID,EH.FlagHoldOut--,EH.PreferredCategory  
          ,@StartDate as StartDate  
          --into DataWarehouse.Staging.TempMailTrackerNew   
     from #EH EH  
     Full Outer join #DM DM  
     on EH.Adcode = DM.Adcode and DM.Customerid = Eh.CustomerID  
  
    
   print 'New cust'  
     update t  
     set  t.ComboID = 'CCN2M_NewCust'  
     from DataWarehouse.Staging.TempMailTrackerNew  t  
     left join DataWarehouse.Marketing.CampaignCustomerSignature c  
     on t.DMcustomerid= c.CustomerID  
     where t.ComboID = 'CCN2M' and customersince > startdate    
         
   print '(Remaining) Non mailed Existing cust'      
     update t  
     SET t.ComboID = 'CCN2M_ExistingCust'    
     from DataWarehouse.Staging.TempMailTrackerNew  t  
     --left join DataWarehouse.Marketing.CampaignCustomerSignature c  
     --on t.DMcustomerid= c.CustomerID  
     where t.ComboID = 'CCN2M' --and customersince <= startdate      
    
      
    drop table #EH   
    drop table #DM   
      
   Update #MailedAdcodes   
   set processed = 1  
   where AdCode = @adcode  
      
  End  
  
  
/**************************************************      #MailTracker      ***********************************************************/  
  
   select   
     A.AdCode,A.AdcodeName,A.CatalogCode,A.CatalogName,coalesce(t.ComboID,A.ComboID) as ComboID,coalesce(t.SubjRank,A.SubjRank) SubjRank,COUNT(distinct t.MailHistCustomerID) as TotalMailed,A.MailSentDate as EHistStartDate,  
     A.YearOfMailSent,A.MonthOfMailSent,A.MD_Year,A.MD_Audience,A.MD_Channel,A.MD_PromotionType ,A.MD_CampaignName,A.MD_PriceType,  
     A.MD_Country,A.StartDate as CCTblStartDate,A.StopDate,A.SeqNum,A.CustomerSegment,A.MultiOrSingle,A.NewSeg,A.Name,A.A12mf,  
     A.CustomerSegmentFnl,A.CustomerSegment2,A.RFMCells,t.FlagMailed,count(t.DMCustomerID)CustCount, count(T.OrderID) TotalOrders,  
     t.OrderSource,sum(t.NetOrderAmount) TotalSales ,sum(t.TotalCourseSales) TotalCourseSales,sum(t.TotalCourseParts) TotalCourseParts,  
     sum(t.TotalCourseUnits) TotalCourseUnits,getdate() as MailUpdateDate , getdate() as TableUpdateDate,MIN(FlagCompleted) as FlagCompleted  
  
   into #MailTracker  
   from #MailedAdcodes A  
   left join DataWarehouse.Staging.TempMailTrackerNew t  
   on A.AdCode = t.adcode   
   and isnull(t.SubjRank,'NA') = A.SubjRank   
   and A.ComboID = case when t.ComboID = 'CCN2M_NewCust' then 'CCN2M'  
        when t.ComboID = 'CCN2M_ExistingCust' then 'CCN2M'  
        else t.ComboID end  
   group by A.AdCode,A.AdcodeName,A.CatalogCode,A.CatalogName,A.ComboID,A.SubjRank,A.CountOfMailsSent,A.MailSentDate,A.YearOfMailSent,  
     A.MonthOfMailSent,A.MD_Year,A.MD_Audience,A.MD_Channel,A.MD_PromotionType ,A.MD_CampaignName,A.MD_PriceType,A.MD_Country,  
     A.StartDate,A.StopDate,A.SeqNum,A.CustomerSegment,A.MultiOrSingle,A.NewSeg,A.Name,A.A12mf,A.CustomerSegmentFnl,  
     A.CustomerSegment2,A.RFMCells, t.FlagMailed,t.OrderSource,t.ComboID,t.SubjRank  
  
  
  
/*Updating CCN2M_ExistingCust values to default*/    
 Update #MailTracker  
 set CustomerSegment = 'CCN2M_ExistingCust'  
,CustomerSegmentFnl ='CCN2M_ExistingCust'  
,CustomerSegment2 = 'CCN2M_ExistingCust'  
,SeqNum =102  
where comboid = 'CCN2M_ExistingCust'  
  
/*Updating CCN2M_NewCust values to default*/    
 Update #MailTracker  
 set CustomerSegment = 'CCN2M_NewCust'  
,CustomerSegmentFnl ='CCN2M_NewCust'  
,CustomerSegment2 = 'CCN2M_NewCust'  
,SeqNum =103  
where comboid = 'CCN2M_NewCust'  
  
  
/*Updating CCN2M values to default*/    
 Update #MailTracker  
 set   
 Comboid = 'CCN2M_NewCust'  
,CustomerSegment = 'CCN2M_NewCust'  
,CustomerSegmentFnl ='CCN2M_NewCust'  
,CustomerSegment2 = 'CCN2M_NewCust'  
,SeqNum =103  
where comboid = 'CCN2M'  
  
  
  delete from DataWarehouse.Marketing.MailTrackerNew_old  
  where adcode in (select distinct adcode from #MailTracker)  
  
  insert into  DataWarehouse.Marketing.MailTrackerNew_old   
  select * from #MailTracker  
  
  update DataWarehouse.Marketing.MailTrackerNew_old    
  set TableUpdateDate = getdate()     
  
drop table #Adcode  
drop table #MailedAdcodes  
drop table #MailTracker  
  
/* End Delta Refresh*/  
  
  
  
END  
  
  
  
  
  
GO
