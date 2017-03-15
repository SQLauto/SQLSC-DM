SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [dbo].[SP_Load_EmailOrders] @Date date =  null, @maxdate date = null
As
BEGIN

if @Date is null
begin
select @Date = cast(dateadd(d,1,max(startdate)) as date) from Archive.EmailOrders
end

if @maxdate is null
begin
select @maxdate = Staging.GetSunday(cast(dateadd(m,-1,getdate()) as date))
end

 

select @Date Startdate, @maxdate Enddate

while @Date<=@maxdate

Begin  

       Declare @Startdate Date , @Enddate Date set @Startdate = @Date set @Enddate = DATEADD(MONTH,1,@Startdate) 
       select @Startdate,@Enddate

       /* For 1 day Load Email History Data*/
       select CustomerID,Adcode,StartDate,FlagHoldOut,ComboID,PreferredCategory,EmailAddress
       into #EmailHistory
       from DataWarehouse.Archive.EmailHistory2016
       where StartDate = @Startdate

       /*Adcodes list*/
       select distinct Adcode,StartDate 
       into #Adcode
       from #EmailHistory

       /* SM_TRACKING_LOG between the 1 months*/
       select * ,substring(userid,CHARINDEX('_',userid,0)+1,6 ) adcode,substring(userid,0,CHARINDEX('_',userid,0)) Customerid 
       into #SM_TRACKING_LOG
       from DataWarehouse.Archive.SM_TRACKING_LOG 
       where datestamp between @Startdate and @Enddate
       and userid like '%@%'
       and userid like '%_%'

       delete from  #SM_TRACKING_LOG
       where isnumeric(Customerid ) = 0  or isnumeric(adcode ) = 0 

       /* Include only opens and clicks for the current adcodes*/
       select L.*
       into #SM_TRACKING_LOG_1
       from #SM_TRACKING_LOG L
       join #Adcode a
       on a.Adcode = L.adcode

       select Email,Customerid,adcode, Min(Case when TType = 'open' then DateStamp else null end)OpenDateStamp, Min(Case when TType = 'click' then DateStamp else null end)ClickDateStamp
       , Sum(Case when TType = 'open' then 1 else 0 end)OpenCnt, Sum(Case when TType = 'click' then 1 else 0 end)ClickCnt
       Into #SM_Final
       from #SM_TRACKING_LOG_1
       group by Email,Customerid,adcode

       /* DMPurchase orders between the next 1 months*/
       select * Into #DMOrders
       from DataWarehouse.Marketing.DMPurchaseOrders 
       where DateOrdered between @Startdate and @Enddate

       select EH.*,SM.OpenCnt,SM.ClickCnt,SM.OpenDateStamp,SM.ClickDateStamp,DM.OrderID,DM.DateOrdered, DM.NetOrderAmount,DM.OrderSource,DM.FlagDigitalPhysical ,getdate()as DMLastupdated
       Into #EmailOrders 
       from #EmailHistory EH
       left join #SM_Final SM on SM.adcode = EH.Adcode and SM.Customerid = EH.CustomerID and SM.Email = EH.EmailAddress
       left join #DMOrders DM on DM.adcode = EH.Adcode and DM.Customerid = EH.CustomerID 
 
       
       /*Truncate data for same day if previously run*/       
       delete from Archive.EmailOrders
       where StartDate >= (select top 1 startdate from #EmailOrders)

              DECLARE @maxVal INT
              SELECT @maxVal = ISNULL(max(EmailOrders_id),0)+1 from [Archive].[EmailOrders] (nolock)
              select @maxVal

              DBCC CHECKIDENT('Archive.EmailOrders', RESEED, @maxVal)


       Insert into Archive.EmailOrders 
        (CustomerID,Adcode,StartDate,FlagHoldOut,ComboID,PreferredCategory,EmailAddress,OpenCnt,ClickCnt,OpenDateStamp,ClickDateStamp,OrderID,DateOrdered,NetOrderAmount,OrderSource,FlagDigitalPhysical,DMLastupdated)
       select * from #EmailOrders
  

  Drop table #SM_TRACKING_LOG
  Drop table #SM_TRACKING_LOG_1
  Drop table #SM_Final
  Drop table #Adcode
  Drop table #DMOrders
  Drop table #EmailHistory
  Drop table #EmailOrders


set @Date = dateadd(d,1,@Date)

End



END
GO
