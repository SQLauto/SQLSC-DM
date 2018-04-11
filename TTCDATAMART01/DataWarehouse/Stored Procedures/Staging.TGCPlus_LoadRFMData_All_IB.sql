SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE procedure [Staging].[TGCPlus_LoadRFMData_All_IB]  
 @LoadType varchar(50) = 'Load'  
 ,@AsOfDate datetime = null  
  
as  
 --declare   
 --    @a12mF_EndDate datetime,  
 --    @a12mF_StartDate datetime,   
 --    @DSStartDate datetime,   
 --    @DSEndDate datetime,   
 -- @DSDays int,   
 --    @MaxDays int  
begin  
  
 if @LoadType = 'Update'  
 begin  
  
 if @AsOfDate is null   
  select @AsOfDate = max(AsofDate)  
  from marketing.TGCPlus_CustomerSignature_Snapshot  
  where day(asofdate) = 1
 else  
  select @AsOfDate = DATEADD(month, DATEDIFF(month, 0, @AsOfDate), 0)  
  
  select @AsOfDate  
  
 PRINT 'Loading RFM for ' + convert(varchar, @Asofdate, 101)  
  
 Select  a.AsofDate  
   ,a.CustomerID  
   ,a.IntlSubDate  
   ,a.LTDPaidAmt   
   ,max(b.tstamp) DateLastPlayed  
   ,sum(b.StreamedMins) StreamedMinutes  
   ,DATEDIFF(day, max(b.TSTAMP),a.AsoFDate) DaysSinceLastStream  
   ,DATEDIFF(day, a.IntlSubDate, a.AsofDate) Tenure  
   ,(sum(b.StreamedMins)/DATEDIFF(day, a.IntlSubDate, a.AsofDate)) MinutesPerDay  
   ,convert(int, null) Recency_Decile  
   ,convert(int, null) Frequency_Decile  
   ,convert(int, null) Monetary_Decile  
   ,convert(int, null) RF_Score  
   ,convert(int, null) Monetary_Score  
   ,convert(varchar(50),null) RFMGroup  
   ,cast(0 as bit) as CurrentFlag
   ,getdate() as DMLastupdated
 into #TGCPlus_RFMBaseUpdate_IB  
 from marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a  
  left join Marketing.tgcplus_Consumption_smry b on a.uuid = b.UUID  
            and b.TSTAMP < a.AsofDate  
 where a.CustStatusFlag = 1   
 and a.PaidFlag = 1-- and b.CustStatusFlag = 1  
 --and a.CustomerID in (2130333) --,2998034,3617941,2528907)  
 and a.AsofDate = @AsOfDate  
 group by a.AsofDate  
 ,a.CustomerID  
 ,a.IntlSubDate  
 ,a.LTDPaidAmt  
  
 update #TGCPlus_RFMBaseUpdate_IB 
 set Recency_Decile = 1,  
  Frequency_Decile = 1  
 where DaysSinceLastStream is null  
  
   
 update a  
 set a.Recency_Decile = b.Recency_Decile,  
  a.Frequency_Decile = b.Frequency_Decile  
 from #TGCPlus_RFMBaseUpdate_IB a  
 join (Select AsofDate  
   ,CustomerID  
   ,DaysSinceLastStream  
   --,ntile(10) over (partition by Asofdate order by DaysSinceLastStream desc)+1 as Recency_Decile  
   ,case when DaysSinceLastStream >= 0 and DaysSinceLastStream <= 1 then 11  
    when DaysSinceLastStream >= 2 and DaysSinceLastStream < 3 then 10  
    when DaysSinceLastStream >= 3 and DaysSinceLastStream < 7 then 9  
    when DaysSinceLastStream >= 7 and DaysSinceLastStream < 13 then 8  
    when DaysSinceLastStream >= 13 and DaysSinceLastStream < 23 then 7  
    when DaysSinceLastStream >= 23 and DaysSinceLastStream < 36 then 6  
    when DaysSinceLastStream >= 36 and DaysSinceLastStream < 55 then 5  
    when DaysSinceLastStream >= 55 and DaysSinceLastStream < 87 then 4  
    when DaysSinceLastStream >= 87 and DaysSinceLastStream < 149 then 3  
    when DaysSinceLastStream >= 149 then 2  
    else 0  
   end as Recency_Decile  
   ,MinutesPerDay  
   --,ntile(10) over (partition by Asofdate order by MinutesPerDay)+1 as Frequency_Decile  
   ,case when MinutesPerDay >= 0 and MinutesPerDay < 0.304347 then 2  
    when MinutesPerDay >= 0.304347 and MinutesPerDay < 0.89 then 3  
    when MinutesPerDay >= 0.89 and MinutesPerDay < 1.78481 then 4  
    when MinutesPerDay >= 1.78481 and MinutesPerDay < 3.100917 then 5  
    when MinutesPerDay >= 3.100917 and MinutesPerDay < 4.99074 then 6  
    when MinutesPerDay >= 4.99074 and MinutesPerDay < 7.769531 then 7  
    when MinutesPerDay >= 7.769531 and MinutesPerDay < 12.09375 then 8  
    when MinutesPerDay >= 12.09375 and MinutesPerDay < 19.55926 then 9  
    when MinutesPerDay >= 19.55926 and MinutesPerDay < 36.01261 then 10  
    when MinutesPerDay >= 36.01261 then 11  
    else 0  
   end as Frequency_Decile  
  from #TGCPlus_RFMBaseUpdate_IB
  where DaysSinceLastStream >= 0)b on a.AsofDate = b.AsofDate  
         and a.CustomerID = b.CustomerID  
  
 update a  
 set a.Monetary_Decile = b.Monetary_Decile  
 from #TGCPlus_RFMBaseUpdate_IB a  
 join (Select AsofDate  
   ,CustomerID  
   ,LTDPaidAmt  
   --,ntile(10) over (partition by Asofdate order by LTDPaidAmt) as Monetary_Decile  
   ,case when LTDPaidAmt < 19.99 then 1  
    when LTDPaidAmt >= 19.99 and LTDPaidAmt < 39.98 then 2  
    when LTDPaidAmt >= 39.98 and LTDPaidAmt < 79.96 then 3  
    when LTDPaidAmt >= 79.96 and LTDPaidAmt < 99.95 then 4  
    when LTDPaidAmt >= 99.95 and LTDPaidAmt < 159.92 then 5  
    when LTDPaidAmt >= 159.92 and LTDPaidAmt < 179.99 then 6  
    when LTDPaidAmt >= 179.99 and LTDPaidAmt < 180 then 7  
    when LTDPaidAmt >= 180 and LTDPaidAmt < 199.9 then 8  
    when LTDPaidAmt >= 199.9 and LTDPaidAmt < 359.98 then 9  
    when LTDPaidAmt >= 359.98 then 10  
    else 0  
   end Monetary_Decile  
  from #TGCPlus_RFMBaseUpdate_IB)b on a.AsofDate = b.AsofDate  
         and a.CustomerID = b.CustomerID  
  
 -- Update Monetary and RF scores  
  
 update a  
 set RF_Score = (100 * Recency_Decile)+(100 * Frequency_Decile),  
  Monetary_Score = (Monetary_Decile * 100)  
 from #TGCPlus_RFMBaseUpdate_IB a  
  
 --declare @AvgRF int, @AvgMonetary  
  
 --select   
 --from #TGCPlus_RFMBaseUpdate  
  
 update a  
 set a.RFMGroup = case  when (100 * [Recency_Decile])+(100 * [Frequency_Decile]) >= 1197 and (Monetary_Decile * 100) >= 567 then 'High RF, High Monetary'  
         when (100 * [Recency_Decile])+(100 * [Frequency_Decile]) >= 1197 and (Monetary_Decile * 100) < 567 then 'High RF, Low Monetary'   
         when (100 * [Recency_Decile])+(100 * [Frequency_Decile]) < 1197 and (Monetary_Decile * 100) >= 567 then 'Low RF, High Monetary'  
         when (100 * [Recency_Decile])+(100 * [Frequency_Decile]) < 1197 and (Monetary_Decile * 100) < 567 then 'Low RF, Low Monetary'  
     else 'Other' end  
 from #TGCPlus_RFMBaseUpdate_IB a  
  
  
 Print 'Deleting data that already exists'  
 delete a  
 from Marketing.TGCPlus_RFM_IB a   
 join #TGCPlus_RFMBaseUpdate_IB b on a.AsofDate = b.AsofDate  
  
 Print 'Loading data into final table'  
 insert into Marketing.TGCPlus_RFM_IB  
 select *  
 from #TGCPlus_RFMBaseUpdate_IB  
  
 end  
  
 else   
 begin  
  
  Select  a.AsofDate  
   ,a.CustomerID  
   ,a.IntlSubDate  
   ,a.LTDPaidAmt   
   ,max(b.tstamp) DateLastPlayed  
   ,sum(b.StreamedMins) StreamedMinutes  
   ,DATEDIFF(day, max(b.TSTAMP),a.AsoFDate) DaysSinceLastStream  
   ,DATEDIFF(day, a.IntlSubDate, a.AsofDate) Tenure  
   ,(sum(b.StreamedMins)/DATEDIFF(day, a.IntlSubDate, a.AsofDate)) MinutesPerDay  
   ,convert(int, null) Recency_Decile  
   ,convert(int, null) Frequency_Decile  
   ,convert(int, null) Monetary_Decile  
   ,convert(int, null) RF_Score  
   ,convert(int, null) Monetary_Score  
   ,convert(varchar(50),null) RFMGroup   
   ,cast(0 as bit) as CurrentFlag
   ,getdate() as DMLastupdated
 into #TGCPlus_RFMBase_IB  
 from marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a  
  left join Marketing.tgcplus_Consumption_smry b on a.uuid = b.UUID  
            and b.TSTAMP < a.AsofDate  
 where a.CustStatusFlag = 1   
 and a.PaidFlag = 1-- and b.CustStatusFlag = 1  
 --and a.CustomerID in (2130333) --,2998034,3617941,2528907)  
 --and a.AsofDate >= '1/1/2017'  
 and day(a.AsofDate)  = 1
 group by a.AsofDate  
 ,a.CustomerID  
 ,a.IntlSubDate  
 ,a.LTDPaidAmt  
  
 update #TGCPlus_RFMBase_IB  
 set Recency_Decile = 1,  
  Frequency_Decile = 1  
 where DaysSinceLastStream is null  
  
   
 update a  
 set a.Recency_Decile = b.Recency_Decile,  
  a.Frequency_Decile = b.Frequency_Decile  
 from #TGCPlus_RFMBase_IB a  
 join (Select AsofDate  
   ,CustomerID  
   ,DaysSinceLastStream  
   --,ntile(10) over (partition by Asofdate order by DaysSinceLastStream desc)+1 as Recency_Decile  
   ,case when DaysSinceLastStream >= 0 and DaysSinceLastStream <= 1 then 11  
    when DaysSinceLastStream >= 2 and DaysSinceLastStream < 3 then 10  
    when DaysSinceLastStream >= 3 and DaysSinceLastStream < 7 then 9  
    when DaysSinceLastStream >= 7 and DaysSinceLastStream < 13 then 8  
    when DaysSinceLastStream >= 13 and DaysSinceLastStream < 23 then 7  
    when DaysSinceLastStream >= 23 and DaysSinceLastStream < 36 then 6  
    when DaysSinceLastStream >= 36 and DaysSinceLastStream < 55 then 5  
    when DaysSinceLastStream >= 55 and DaysSinceLastStream < 87 then 4  
    when DaysSinceLastStream >= 87 and DaysSinceLastStream < 149 then 3  
    when DaysSinceLastStream >= 149 then 2  
    else 0  
   end as Recency_Decile  
   ,StreamedMinutes  
   --,ntile(10) over (partition by Asofdate order by MinutesPerDay)+1 as Frequency_Decile  
   ,case when MinutesPerDay >= 0 and MinutesPerDay < 0.304347 then 2  
    when MinutesPerDay >= 0.304347 and MinutesPerDay < 0.89 then 3  
    when MinutesPerDay >= 0.89 and MinutesPerDay < 1.78481 then 4  
    when MinutesPerDay >= 1.78481 and MinutesPerDay < 3.100917 then 5  
    when MinutesPerDay >= 3.100917 and MinutesPerDay < 4.99074 then 6  
    when MinutesPerDay >= 4.99074 and MinutesPerDay < 7.769531 then 7  
    when MinutesPerDay >= 7.769531 and MinutesPerDay < 12.09375 then 8  
    when MinutesPerDay >= 12.09375 and MinutesPerDay < 19.55926 then 9  
    when MinutesPerDay >= 19.55926 and MinutesPerDay < 36.01261 then 10  
    when MinutesPerDay >= 36.01261 then 11  
    else 0  
   end as Frequency_Decile  
  from #TGCPlus_RFMBase_IB   
  where DaysSinceLastStream >= 0)b on a.AsofDate = b.AsofDate  
         and a.CustomerID = b.CustomerID  
  
   
 update a  
 set a.Monetary_Decile = b.Monetary_Decile  
 from #TGCPlus_RFMBase_IB a  
 join (Select AsofDate  
   ,CustomerID  
   ,LTDPaidAmt  
   --,ntile(10) over (partition by Asofdate order by LTDPaidAmt) as Monetary_Decile  
   ,case when LTDPaidAmt < 19.99 then 1  
    when LTDPaidAmt >= 19.99 and LTDPaidAmt < 39.98 then 2  
    when LTDPaidAmt >= 39.98 and LTDPaidAmt < 79.96 then 3  
    when LTDPaidAmt >= 79.96 and LTDPaidAmt < 99.95 then 4  
    when LTDPaidAmt >= 99.95 and LTDPaidAmt < 159.92 then 5  
    when LTDPaidAmt >= 159.92 and LTDPaidAmt < 179.99 then 6  
    when LTDPaidAmt >= 179.99 and LTDPaidAmt < 180 then 7  
    when LTDPaidAmt >= 180 and LTDPaidAmt < 199.9 then 8  
    when LTDPaidAmt >= 199.9 and LTDPaidAmt < 359.98 then 9  
    when LTDPaidAmt >= 359.98 then 10  
    else 0  
   end Monetary_Decile  
  from #TGCPlus_RFMBase_IB )b on a.AsofDate = b.AsofDate  
         and a.CustomerID = b.CustomerID  
  
  
 -- Update Monetary and RF scores  
  
 update a  
 set RF_Score = (100 * Recency_Decile)+(100 * Frequency_Decile),  
  Monetary_Score = (Monetary_Decile * 100)  
 from #TGCPlus_RFMBase_IB a  
  
 update a  
 set a.RFMGroup = case  when (100 * [Recency_Decile])+(100 * [Frequency_Decile]) >= 1197 and (Monetary_Decile * 100) >= 567 then 'High RF, High Monetary'  
         when (100 * [Recency_Decile])+(100 * [Frequency_Decile]) >= 1197 and (Monetary_Decile * 100) < 567 then 'High RF, Low Monetary'   
         when (100 * [Recency_Decile])+(100 * [Frequency_Decile]) < 1197 and (Monetary_Decile * 100) >= 567 then 'Low RF, High Monetary'  
         when (100 * [Recency_Decile])+(100 * [Frequency_Decile]) < 1197 and (Monetary_Decile * 100) < 567 then 'Low RF, Low Monetary'  
     else 'Other' end  
 from #TGCPlus_RFMBase_IB a  
  
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TGCPlus_Acqsn_Summary_TEMPReg')  
        DROP TABLE Marketing.TGCPlus_RFM_IB 
   
 select *  
 into Marketing.TGCPlus_RFM_IB
 from #TGCPlus_RFMBase_IB  
  
   
 end  
      
	update Marketing.TGCPlus_RFM_IB
	set CurrentFlag = 0 ;


	--With CTE_CurrentFlag 
	--		AS (
	--			select customerid, Asofdate, ROW_NUMBER()Over(partition by customerid order by Asofdate desc) Rank
	--			from Marketing.TGCPlus_RFM  
	--			)
	-- update a 
	-- set a.CurrentFlag = CTE.RANK
	-- from Marketing.TGCPlus_RFM  a
	-- join CTE_CurrentFlag cte
	-- on a.customerid = cte.customerid
	-- and a.AsofDate = cte.asofdate
	-- where Cte.Rank = 1;

	Update Marketing.TGCPlus_RFM_IB 
	set CurrentFlag = 1
	where Asofdate = (
	select Max(asofdate) from Marketing.TGCPlus_RFM_IB
	where Datepart(d,asofdate) = 1)


end  


GO
