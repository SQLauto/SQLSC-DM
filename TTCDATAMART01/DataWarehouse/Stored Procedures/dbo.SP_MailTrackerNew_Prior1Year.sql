SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE Proc [dbo].[SP_MailTrackerNew_Prior1Year] @CatalogCode int    
as    
Begin   
  
/*Calc mailTracker based on catalog Codes includes Comboid,Decile and DemiDecile*/  
    
--drop table #adcode drop table #MailedAdcodes Drop table #DM_CatalogCode drop table #MH_CatalogCode  drop table #T  
--1--57276  
--Select adcode from DataWarehouse.Mapping.vwAdcodesAll where  CatalogCode =48263  
--select * from  DataWarehouse.Archive.MailhistoryPrior1Year  
--where adcode in (106769,112927)  
--declare  @CatalogCode int = 57480   
  
/*Load Data into Temp tables for the catalog code*/  
  
--TotalCourseQuantity  
   select CustomerID,OrderID,AdCode,NetOrderAmount,cast(null as money) as TotalCourseSales,cast(null as int) as TotalCourseParts, cast(null as int) as TotalCourseUnits,DateOrdered    
   into #VWOrders_CatalogCode     
   from DataWarehouse.Staging.vwOrders DM    
   where adcode in (Select adcode from DataWarehouse.Mapping.vwAdcodesAll where  CatalogCode = @CatalogCode )  
   AND StatusCode not in (4) /* why this filter?????*/  
  
/* Calculate TotalCourseSales,TotalCourseParts,TotalCourseUnits from Staging.vwOrderItems*/  
   Select  oi.JSSourceID as AdCode ,O.OrderID as OrderID,OI.OrderItemID as OrderItemID,O.OrderDate as DateOrdered,       
   CASE WHEN B.BundleID IS NULL THEN I.CourseID  ELSE B.CourseID END as CourseID,ISNULL(B.BundleID, 0) as BundleID,       
   case when B.BundleID is null then OI.StockItemID else SUBSTRING(oi.StockItemID, 1, 2) + CONVERT(VARCHAR(10), b.CourseID) end as StockItemID,      
   ISNULL(OI.Quantity, 0) as TotalQuantity,case  when B.BundleID is null then isnull(oi.SalesPrice, 0) else isnull(oi.SalesPrice, 0) * b.Portion end as SalesPrice,      
   case when oi.Quantity < 0 then 'True' else 'False' end as FlagReturn,oi.JSORIGINALSALESID as OriginalOrderID,case  when o.PaymentStatus = 2 then 'True' else 'False' end as FlagPaymentRejected,      
   cast(null as int) as Parts,  
   cast(null as int) as TotalParts,  
   cast(null as money) as TotalSales,  
   cast(null as varchar(10)) FormatMedia  
   Into #VWOrderItems_CatalogCode    
   from Staging.OrderItems oi (nolock)      
   JOIN Staging.InvItem I (nolock) ON OI.StockItemID = I.StockItemID      
   join Staging.Orders o (nolock) on o.OrderID = oi.OrderID      
   LEFT JOIN Mapping.BundleComponents B (nolock) ON I.CourseID = B.BundleID      
   WHERE (oI.StockItemID LIKE '[P][TM]%' or OI.StockItemID LIKE '[PL][CD]%' or OI.StockItemID LIKE '[PLD][AV]%')  and I.ItemCategoryID IN ('Course', 'Bundle')   
   and o.adcode  in (Select adcode from DataWarehouse.Mapping.vwAdcodesAll where  CatalogCode =  @CatalogCode )   
  
   UPDATE oi      
   SET oi.Parts = mc.CourseParts,      
    oi.TotalParts = mc.CourseParts * oi.TotalQuantity,  
    oi.FormatMedia =  CASE WHEN StockItemID LIKE 'DA%' THEN 'DL' WHEN StockItemID Like 'DV%' THEN 'DV' ELSE SUBSTRING(StockItemID, 2, 1) END  
   FROM #VWOrderItems_CatalogCode oi       
   join Mapping.DMCourse mc (nolock) on oi.CourseID = mc.CourseID      
          
   UPDATE #VWOrderItems_CatalogCode       
   SET SalesPrice = ABS(SalesPrice),      
    TotalQuantity = - ABS(TotalQuantity),      
    TotalParts = - ABS(TotalParts)      
   WHERE (FlagReturn = 'True' or FlagPaymentRejected = 'True')     
  
   UPDATE #VWOrderItems_CatalogCode   
   SET TotalSales = TotalQuantity * SalesPrice  
    
   UPDATE MO  
   SET MO.TotalCourseParts = T.TotalParts,  
    MO.TotalCourseUnits = T.TotalQuantity,  
    MO.TotalCourseSales = T.TotalSales  
   FROM #VWOrders_CatalogCode MO,    
   (SELECT OrderID, SUM(TotalParts) As TotalParts, SUM(TotalQuantity)As TotalQuantity,   
   SUM(TotalSales) As TotalSales  
   FROM #VWOrderItems_CatalogCode oi (nolock)   
   WHERE FormatMedia <> 'T'   
   GROUP BY OrderID) T   
   WHERE MO.OrderID = T.OrderID  
  
   --select CustomerID,OrderID,OrderSource,AdCode,NetOrderAmount,TotalCourseSales,TotalCourseParts,TotalCourseUnits,DateOrdered    
   --into #DM_CatalogCode     
   --from #VWOrders_CatalogCode    
  
   --select CustomerID,OrderID,OrderSource,AdCode,NetOrderAmount,TotalCourseSales,TotalCourseParts,TotalCourseQuantity as TotalCourseUnits,DateOrdered    
   --into #DM_CatalogCode     
   --from DataWarehouse.Marketing.DMPurchaseOrders DM    
   --where adcode in (Select adcode from DataWarehouse.Mapping.vwAdcodesAll where  CatalogCode = @CatalogCode )  
  
   select CustomerID,Adcode,StartDate,FlagHoldOut,ComboID,case when SubjRank = '' then 'NA' else SubjRank end as SubjRank,isnull(Decile,0) Decile,isnull(DemiDecile,0)DemiDecile  
   into #MH_CatalogCode     
   from DataWarehouse.Archive.MailhistoryPrior1Year MH    
   where AdCode in (Select adcode from DataWarehouse.Mapping.vwAdcodesAll where  CatalogCode = @CatalogCode )   
  
   
/********Get Adcodes Which are part of @CatalogCode and mailed*********/    
    
  select Ad.Adcode,ComboID,case when SubjRank = '' then 'NA' else SubjRank end as SubjRank,isnull(Decile,0) Decile,isnull(DemiDecile,0)DemiDecile, His.StartDate MailSentDate, COUNT(His.customerid) Counts, Cast(0 as bit) as processed    
  into #Adcode    
  from DataWarehouse.Mapping.vwAdcodesAll Ad (nolock)    
  left join  #MH_CatalogCode  His    
  on his.Adcode = Ad.AdCode    
  where AD.ChannelID = 1    
  and AD.CatalogCode = @CatalogCode    
  and his.FlagHoldOut = 0    
  group by Ad.Adcode, His.StartDate,ComboID,case when SubjRank = '' then 'NA' else SubjRank end ,isnull(Decile,0) ,isnull(DemiDecile,0)  
  having COUNT(his.customerid) > 0    
  union     
  select Ad.Adcode,'CCN2M' as ComboID,'NA' as SubjRank,isnull(Decile,0) Decile,isnull(DemiDecile,0)DemiDecile, His.StartDate MailSentDate, null as  Counts, Cast(0 as bit) as processed     
  from DataWarehouse.Mapping.vwAdcodesAll Ad (nolock)    
  left join  #MH_CatalogCode  His    
  on his.Adcode = Ad.AdCode    
  where AD.ChannelID = 1    
  and AD.CatalogCode = @CatalogCode    
  and his.FlagHoldOut = 0    
  group by Ad.Adcode, His.StartDate,ComboID ,isnull(Decile,0) ,isnull(DemiDecile,0)   
  having COUNT(his.customerid) > 0    
    
/*To insert any missing Adcodes with redirect or lost codes*/    
  insert into #Adcode    
  select a.AdCode,'CCN2M' as ComboID,'NA' as SubjRank,isnull(Decile,0) Decile,isnull(DemiDecile,0)DemiDecile,b.MailSentDate, null as  Counts, Cast(0 as bit) as processed     
  from DataWarehouse.Mapping.vwAdcodesAll a (nolock)    
  inner Join    
  (  select Catalogcode,MAX(MailSentDate) as MailSentDate     
    from #Adcode a    
    join DataWarehouse.Mapping.vwAdcodesAll Ad (nolock)    
    on a.AdCode = Ad.AdCode    
    group by Catalogcode    
  )b on a.CatalogCode = b.CatalogCode    
  left join #Adcode c    
  on a.AdCode = c.AdCode    
  where c.AdCode is null    
    
/*To insert any missing Adcodes with redirect or lost codes when there are only lost or hold out codes  in the catalog*/    
  insert into #Adcode    
  select a.AdCode,'CCN2M' as ComboID,'NA' as SubjRank,isnull(Decile,0) Decile,isnull(DemiDecile,0)DemiDecile,a.startdate, null as  Counts, Cast(0 as bit) as processed     
  from DataWarehouse.Mapping.vwAdcodesAll a (nolock)    
  left join #Adcode c    
  on a.AdCode = c.AdCode    
  where c.AdCode is null    
  and a.CatalogCode = @CatalogCode    
    
--drop table #MailedAdcodes (Adcode/Comboid)    
   select a.AdCode,AD.AdcodeName,AD.CatalogCode,AD.CatalogName,A.ComboID,A.SubjRank,A.Decile,A.DemiDecile,a.counts as CountOfMailsSent,a.MailSentDate as MailSentDate,    
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
    
  
 /* truncate staging table*/  
  truncate table DataWarehouse.Staging.TempMailTrackerAdcode   
    
Declare @Adcode int, @StartDate datetime,@StopDatePlus17days datetime   
  
 While exists(select top 1 Adcode from #MailedAdcodes where processed = 0)    
     
   Begin     
        select top 1 @adcode = Adcode, @StartDate= StartDate,@StopDatePlus17days = dateadd(d,17,StopDate) from #MailedAdcodes where processed = 0    
       
      select @adcode Adcode,@StartDate StartDate ,@StopDatePlus17days StopDatePlus17days   
  
  /* #MH by adcode */  
     select CustomerID,Adcode,StartDate,FlagHoldOut,ComboID,case when SubjRank = '' then 'NA' else SubjRank end as SubjRank,Decile, DemiDecile   
     into #MH     
     from #MH_CatalogCode MH    
     where AdCode = @adcode    
  
  /* #DM by adcode */  
     select CustomerID,OrderID,AdCode,NetOrderAmount,TotalCourseSales,TotalCourseParts,TotalCourseUnits    
     into #DM     
     from #VWOrders_CatalogCode DM    
     where AdCode = @adcode    
     and NetOrderAmount between 1 And 1500    
     and Dm.DateOrdered < @StopDatePlus17days  /*Logic to not include sales more than 17 days after adcode stop date*/  
    
 /* inserting into staging table DataWarehouse.Staging.TempMailTrackerAdcode Full outer join #MH and #DM by customer*/  
  
     insert into DataWarehouse.Staging.TempMailTrackerAdcode     
     select  isnull(MH.adcode,@adcode)adcode,isnull(MH.comboid,'CCN2M') comboid,MH.SubjRank,isnull(Decile,0) Decile,isnull(DemiDecile,0)DemiDecile,   
       case when FlagHoldOut = 1 then 0     
      when MH.CustomerID is null and DM.CustomerID is not null then 2    
      else 1 end as FlagMailed,    
       DM.CustomerID as DMCustomerID,OrderID,NetOrderAmount,TotalCourseSales,TotalCourseParts,TotalCourseUnits,    
       MH.CustomerID MailHistCustomerID,MH.FlagHoldOut  
       ,@StartDate as StartDate    
     from #MH MH    
     Full Outer join #DM DM    
     on --MH.Adcode = DM.Adcode and   
     DM.Customerid = MH.CustomerID    
    
      
    
  /* Address Match if comboid  like CCN2M% based */  
  
   Print 'MatchCode'    
       
    select  *     
    into #TempMailTrackerAdcode    
    from DataWarehouse.Staging.TempMailTrackerAdcode      
    where  comboid like  'CCN2M%'     
    
    select m.*,ccs.CustomerID     
    into #MatchCode    
    from    
    (    
    select t.DMCustomerId, LTRIM(RTRIM(LEFT(CCS.LastName,5) + ISNULL(CCS.zip5,'ZZZZZ') + LEFT(ISNULL(CCS.Address1,'AAAAA'),5) + CCS.FirstName)) AS MatchCode      
    from #TempMailTrackerAdcode t    
    left join DataWarehouse.Marketing.CampaignCustomerSignature ccs    
    on t.DMCustomerID = ccs.customerid    
    group by t.DMCustomerId, LTRIM(RTRIM(LEFT(CCS.LastName,5) + ISNULL(CCS.zip5,'ZZZZZ') + LEFT(ISNULL(CCS.Address1,'AAAAA'),5) + CCS.FirstName))     
    ) M     
    Join DataWarehouse.Marketing.CampaignCustomerSignature ccs    
    on M.DMCustomerId <> ccs.CustomerID and M.MatchCode =LTRIM(RTRIM(LEFT(CCS.LastName,5) + ISNULL(CCS.zip5,'ZZZZZ') + LEFT(ISNULL(CCS.Address1,'AAAAA'),5) + CCS.FirstName))     
    
    update T    
    Set --T.MailHistCustomerID = H.CustomerID,    
     t.Comboid = H.ComboID,    
     t.SubjRank = case when isnull(H.SubjRank,'') = '' then 'NA' else H.SubjRank end,   
     t.Decile = isnull(H.Decile,0),   
     t.DemiDecile = isnull(H.DemiDecile,0),   
     t.FlagMailed = case when t.FlagHoldOut = 1 then 0     
       when t.DMCustomerID is null and t.DMCustomerID is not null then 2    
       else 1 end      
    from     
    #MatchCode M    
    join  #MH_CatalogCode H    
    on H.CustomerID = M.CustomerID    
    join DataWarehouse.Staging.TempMailTrackerAdcode T    
    on T.DMCustomerID = m.DMCustomerID    
    
      
      print 'New cust'    
     update t    
     set  t.ComboID = 'CCN2M_NewCust'    
     from DataWarehouse.Staging.TempMailTrackerAdcode  t    
     join DataWarehouse.Marketing.CampaignCustomerSignature c    
     on t.DMcustomerid= c.CustomerID    
     where t.ComboID = 'CCN2M' and customersince > startdate      
           
      print '(Remaining) Non mailed Existing cust'        
     update t    
     SET t.ComboID = 'CCN2M_ExistingCust'      
     from DataWarehouse.Staging.TempMailTrackerAdcode  t    
     where t.ComboID = 'CCN2M'      
         
    
     update N    
     set  N.comboid = h.ComboID,    
    N.SubjRank = case when isnull(H.SubjRank,'') = '' then 'NA' else H.SubjRank end,    
    N.adcode = h.adcode,    
    N.FlagMailed = case when N.FlagHoldOut = 1 then 0     
      when N.DMCustomerID is null and N.DMCustomerID is not null then 2    
      else 1 end      
     from  #MH_CatalogCode  h    
     inner join DataWarehouse.Staging.TempMailTrackerAdcode N    
     on h.CustomerID = N.DMCustomerID    
     where CustomerID in (select DMCustomerID from DataWarehouse.Staging.TempMailTrackerAdcode N where comboid = 'CCN2M_ExistingCust')     
      
    
   drop table #MH     
   drop table #DM     
        
   drop table #TempMailTrackerAdcode    
   drop table #MatchCode    
        
        
  Update #MailedAdcodes     
  set processed = 1    
  where AdCode = @adcode    
        
 End    
  
  
  --select * from DataWarehouse.Staging.TempMailTrackerAdcode  
  
   select adcode,Comboid,SubjRank,Decile,DemiDecile,FlagMailed,  MailHistCustomerID, DMCustomerID  
  ,Count(OrderID) TotalOrders,sum(NetOrderAmount) TotalSales ,sum(TotalCourseSales) TotalCourseSales,sum(TotalCourseParts) TotalCourseParts, sum(TotalCourseUnits) TotalCourseUnits    
  ,Case when MailHistCustomerID is not null and MailHistCustomerID=DMCustomerID then 1 else 0 end as CustMatch  
  into #TempMailTracker  
  from DataWarehouse.Staging.TempMailTrackerAdcode  
  group by adcode,Comboid,SubjRank,Decile,DemiDecile,FlagMailed,  MailHistCustomerID, DMCustomerID  
    
     
/**************************************************      Load missing adcode and combo/Decile/DemiDecile      ***********************************************************/    
    
  insert into #MailedAdcodes  
  select a.AdCode,AD.AdcodeName,AD.CatalogCode,AD.CatalogName,A.ComboID,isnull(A.SubjRank,'NA') SubjRank,A.Decile,A.DemiDecile,0 as CountOfMailsSent,a.MailSentDate as MailSentDate,    
    year(a.MailSentDate) YearOfMailSent,Month(a.MailSentDate) MonthOfMailSent,MD_Year,MD_Audience,MD_Channel,AD.MD_PromotionType ,    
    AD.MD_CampaignName,MD_PriceType,MD_Country,AD.StartDate,AD.StopDate,Lkup.SeqNum,Lkup.CustomerSegment,Lkup.MultiOrSingle,    
    Lkup.NewSeg,Lkup.Name,Lkup.A12mf,Lkup.CustomerSegmentFnl,Lkup.CustomerSegment2,Lkup.RFMCells, case when dateadd(d,3,AD.StopDate) > CAST(GETDATE() as date) then 0 else 1 end as FlagCompleted ,1   
  from (select adcode,Comboid,SubjRank,Decile,DemiDecile,startdate  as MailSentDate  
   from DataWarehouse.Staging.TempMailTrackerAdcode   
   --where Comboid not like '%CCN2M%'  
   group by adcode,Comboid,SubjRank,Decile,DemiDecile,startdate)  a    
  Inner join DataWarehouse.Mapping.vwAdcodesAll Ad (nolock)    
  on A.Adcode = Ad.AdCode    
  left join (select distinct Lkup.comboid, Lkup.SeqNum,Lkup.CustomerSegment,Lkup.MultiOrSingle,    
   Lkup.NewSeg,Lkup.Name,Lkup.A12mf,Lkup.CustomerSegmentFnl,Lkup.CustomerSegment2,RFMCells     
      from DataWarehouse.Mapping.RFMComboLookup  Lkup (nolock)    
     ) Lkup on Lkup.Comboid = CASE WHEN A.ComboID = 'Inq' THEN '25-10000 Mo Inq'       
              ELSE ISNULL(A.ComboID,'Unknown')      
            END        
  left join (select adcode,comboid,Decile,DemiDecile from #MailedAdcodes group by adcode,comboid,Decile,DemiDecile) M  
  on M.AdCode = a.adcode and m.ComboID = a.comboid and m.Decile = a.Decile and m.DemiDecile=a.DemiDecile  
  where m.adcode is null  
  
/**************************************************      #MailTracker      ***********************************************************/    
  
   /*  
    select     
   A.AdCode,A.AdcodeName,A.CatalogCode,A.CatalogName,coalesce(t.ComboID,A.ComboID) as ComboID,coalesce(t.SubjRank,A.SubjRank) SubjRank,A.Decile,A.DemiDecile,  
   COUNT(distinct t.MailHistCustomerID) as TotalMailed,--  ,max(a.CountOfMailsSent) as TotalMailed   
   A.MailSentDate as EHistStartDate,    
   A.YearOfMailSent,A.MonthOfMailSent,A.MD_Year,A.MD_Audience,A.MD_Channel,A.MD_PromotionType ,A.MD_CampaignName,A.MD_PriceType,    
   A.MD_Country,A.StartDate as CCTblStartDate,A.StopDate,A.SeqNum,A.CustomerSegment,A.MultiOrSingle,A.NewSeg,A.Name,A.A12mf,    
   A.CustomerSegmentFnl,A.CustomerSegment2,A.RFMCells,t.FlagMailed,count(t.DMCustomerID)CustCount, count(T.OrderID) TotalOrders,    
   t.OrderSource,sum(t.NetOrderAmount) TotalSales ,sum(t.TotalCourseSales) TotalCourseSales,sum(t.TotalCourseParts) TotalCourseParts,    
   sum(t.TotalCourseUnits) TotalCourseUnits,getdate() as MailUpdateDate , getdate() as TableUpdateDate,MIN(FlagCompleted) as FlagCompleted    
    into #MailTracker    
    from #MailedAdcodes A    
    left join DataWarehouse.Staging.TempMailTrackerAdcode t    
    on A.AdCode = t.adcode     
    and isnull(t.SubjRank,'NA') = isnull(A.SubjRank,'NA')    
   -- and A.ComboID = case when t.ComboID = 'CCN2M_NewCust' then 'CCN2M'    
   --when t.ComboID = 'CCN2M_ExistingCust' then 'CCN2M'    
   --else t.ComboID end   
    and A.ComboID = t.ComboID    
    and A.Decile=t.Decile  
    and A.DemiDecile=T.DemiDecile  
  --where t.FlagHoldOut is not null or t.ComboID in ('CCN2M_NewCust','CCN2M_ExistingCust')  
    group by A.AdCode,A.AdcodeName,A.CatalogCode,A.CatalogName,A.ComboID,A.SubjRank,A.Decile,A.DemiDecile,A.CountOfMailsSent,A.MailSentDate,A.YearOfMailSent,    
   A.MonthOfMailSent,A.MD_Year,A.MD_Audience,A.MD_Channel,A.MD_PromotionType ,A.MD_CampaignName,A.MD_PriceType,A.MD_Country,    
   A.StartDate,A.StopDate,A.SeqNum,A.CustomerSegment,A.MultiOrSingle,A.NewSeg,A.Name,A.A12mf,A.CustomerSegmentFnl,    
   A.CustomerSegment2,A.RFMCells, t.FlagMailed,t.OrderSource,t.ComboID,t.SubjRank    
  */  
  
  
    select     
   A.AdCode,A.AdcodeName,A.CatalogCode,A.CatalogName,coalesce(t.ComboID,A.ComboID) as ComboID,coalesce(t.SubjRank,A.SubjRank) SubjRank,A.Decile,A.DemiDecile,  
   COUNT(distinct t.MailHistCustomerID) as TotalMailed,--  ,max(a.CountOfMailsSent) as TotalMailed   
   A.MailSentDate as EHistStartDate,    
   A.YearOfMailSent,A.MonthOfMailSent,A.MD_Year,A.MD_Audience,A.MD_Channel,A.MD_PromotionType ,A.MD_CampaignName,A.MD_PriceType,    
   A.MD_Country,A.StartDate as StartDate,A.StopDate,A.SeqNum,A.CustomerSegment,A.MultiOrSingle,A.NewSeg,A.Name,A.A12mf,    
   A.CustomerSegmentFnl,A.CustomerSegment2,A.RFMCells,t.FlagMailed,count(t.DMCustomerID)CustCount, Sum (T.TotalOrders) TotalOrders,    
   sum(t.TotalSales) TotalSales ,sum(t.TotalCourseSales) TotalCourseSales,sum(t.TotalCourseParts) TotalCourseParts,    
   sum(t.TotalCourseUnits) TotalCourseUnits,getdate() as MailUpdateDate , getdate() as TableUpdateDate,MIN(FlagCompleted) as FlagCompleted    
    into #MailTracker    
    from #MailedAdcodes A    
    left join #TempMailTracker t    
    on A.AdCode = t.adcode     
    and isnull(t.SubjRank,'NA') = isnull(A.SubjRank,'NA')    
   -- and A.ComboID = case when t.ComboID = 'CCN2M_NewCust' then 'CCN2M'    
   --when t.ComboID = 'CCN2M_ExistingCust' then 'CCN2M'    
   --else t.ComboID end   
    and A.ComboID = t.ComboID    
    and A.Decile=t.Decile  
    and A.DemiDecile=T.DemiDecile  
  --where t.FlagHoldOut is not null or t.ComboID in ('CCN2M_NewCust','CCN2M_ExistingCust')  
    group by A.AdCode,A.AdcodeName,A.CatalogCode,A.CatalogName,A.ComboID,A.SubjRank,A.Decile,A.DemiDecile,A.CountOfMailsSent,A.MailSentDate,A.YearOfMailSent,    
   A.MonthOfMailSent,A.MD_Year,A.MD_Audience,A.MD_Channel,A.MD_PromotionType ,A.MD_CampaignName,A.MD_PriceType,A.MD_Country,    
   A.StartDate,A.StopDate,A.SeqNum,A.CustomerSegment,A.MultiOrSingle,A.NewSeg,A.Name,A.A12mf,A.CustomerSegmentFnl,    
   A.CustomerSegment2,A.RFMCells, t.FlagMailed,t.ComboID,t.SubjRank    
    
    
    
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
    
    
  delete from DataWarehouse.Marketing.MailTrackerNew    
  where adcode in (select distinct adcode from #MailTracker)    
    
  insert into  DataWarehouse.Marketing.MailTrackerNew     
  select * from #MailTracker    
  where TotalMailed >0 or TotalSales>0 or TotalOrders>0    
  
  update DataWarehouse.Marketing.MailTrackerNew      
  set TableUpdateDate = getdate()       
    
drop table #Adcode    
drop table #MailedAdcodes    
drop table #MailTracker    
  
select   @CatalogCode as CatalogCodeCompleted  
   
  
END   
GO
