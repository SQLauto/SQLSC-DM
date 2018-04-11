SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Staging].[TGCPlus_UpsellRanking_IB]
  @FlagFullRefresh int = 0
AS
--- Proc Name:    [Staging].[TGCPlus_UpsellRanking_IB]
--- Purpose:   Linking to new summary event table --   To create TGCPlus reccos based on TGC upsells
--- Input Parameters: None
---               
--- Updates:
--- Name                      Date        Comments
--- Imane Badra  3/5/18
BEGIN
  set nocount on
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

  --select getdate()
 -- select distinct a.TGCCustomerID, a.uuid, a.CustomerID as ID,
  --  isnull(b.SegmentGroup,'SC_Calc02-03') SegmentGroup, c.CourseID, c.Rank
  --  into #first
  --from DataWarehouse.Marketing.TGCPlus_CustomerSignature a left join
  --  DataWarehouse.Marketing.Upsell_CustomerSegmentGroup b on a.TGCCustomerID = b.CustomerID left join
  --  DataWarehouse.marketing.upsell_courserank c on b.SegmentGroup = c.SegmentGroup
  --where a.TGCCustomerID is not null
  ----and a.TGhCCustomerID in (10000078,40717696,40717883)
  --order by a.TGCCustomerID, c.Rank
    

  select distinct a.TGCCustomerID, a.uuid, a.CustomerID as ID,
    isnull(b.SegmentGroup,'SC_Calc02-03') SegmentGroup
    into #temp_ib
  from DataWarehouse.Marketing.TGCPlus_CustomerSignature a left join
    DataWarehouse.Marketing.Upsell_CustomerSegmentGroup b on a.TGCCustomerID = b.CustomerID 
  where a.TGCCustomerID is not null

  select a.*, b.CourseID, b.Rank
  into #temp_ib2
  from #temp_ib a left join
    DataWarehouse.marketing.upsell_courserank b on a.SegmentGroup = b.SegmentGroup

  delete a
  from #temp_ib2 a join
    DataWarehouse.Marketing.CompleteCoursePurchase b on a.TGCCustomerID = b.CustomerID
                          and a.CourseID = b.CourseID
  where b.StockItemID not like 'PT%'

  select id, courseid, sum(streamedMins) streamedMins
  into #Watched_ib
  from DataWarehouse.Marketing.TGCplus_Consumption_Smry
  group by id, courseid
  having sum(StreamedMins) > 5

  
  --select a.tgccustomerid, count(a.courseid)
  --from Datawarehouse.Marketing.TGCPlus_CustomerUpsell a join
  --  #Watched_ib b on a.ID = b.id 
  --        and a.CourseID = b.CourseID
  --        group by a.tgccustomerid
  --        order by 2 desc 

  delete a
  from #temp_ib2 a join
    #Watched_ib b on a.ID = b.id 
          and a.CourseID = b.CourseID


  select *, ROW_NUMBER() over (partition by tgccustomerid order by Rank) as [Rank2]
  into #temp_ib3
  from #temp_ib2
  order by TGCCustomerID, rank

  drop table Datawarehouse.Marketing.TGCPlus_CustomerUpsell_ib
  
  select *, getdate() UpdateDate
  into Datawarehouse.Marketing.TGCPlus_CustomerUpsell_ib
  from #temp_ib3
  where Rank2 < 16
  order by TGCCustomerID, rank

  --select * from   Datawarehouse.Marketing.TGCPlus_CustomerUpsell


END




GO
