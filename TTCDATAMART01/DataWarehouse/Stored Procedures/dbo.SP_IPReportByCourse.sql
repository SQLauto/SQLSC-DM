SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_IPReportByCourse]
as

Begin


/*Update Start and end dates if not provided*/

delete Staging.IPCourseList  
where CourseID is null

		update IPCL
		set IPCL.Startdate = DMC.ReleaseDate
		from Staging.IPCourseList IPCL
		inner join DataWarehouse.Mapping.DMCourse DMC
		on DMC.CourseID = IPCL.CourseID
		where IPCL.Startdate is null or IPCL.Startdate = ''

		update IPCL
		set IPCL.Enddate = '2099-01-01'
		from Staging.IPCourseList IPCL
		where IPCL.Enddate is null or IPCL.Enddate = ''


/*TTC Customer IP Course calculation based on the courses from Staging.IPCourseList */

		select DM.*,IPCL.StartDate,IPCL.EndDate
		into #TTCCCustomerOrderitems
		from DataWarehouse.Marketing.DMPurchaseOrderItems DM
		inner join Staging.IPCourseList IPCL 
		on IPCL.Courseid = DM.CourseID and DM.DateOrdered >= IPCL.StartDate and DM.DateOrdered < IPCL.EndDate


		select t.CourseID,t.CourseName,DMC.SubjectCategory2,t.StockItemID,a.MediaTypeID,cast(DMC.ReleaseDate as date) as CourseReleaseDate,t.StartDate as ReportStartDate
		,case when t.EndDate = '2099-01-01' then cast(getdate() as date) else t.EndDate end as ReportEndDate
		,SUM(t.TotalQuantity) Units,SUM(t.TotalSales) Sales,cast(getdate() as date) as ReportRunDate, CAST('TTC_Customer' as varchar (255)) as Partner
		into #TTCCCustomer 
		from #TTCCCustomerOrderitems t
		inner join staging.InvItem (nolock)a     
		on t.StockItemID = a.StockItemID
		inner join DataWarehouse.Mapping.DMCourse DMC
		on DMC.CourseID = T.CourseID
		group by t.CourseID,t.CourseName,DMC.SubjectCategory2,DMC.ReleaseDate,t.StockItemID,a.MediaTypeID,t.StartDate ,t.EndDate  


/*TTC Partners IP Course calculation based on the courses from Staging.IPCourseList */

		select D.CourseID,D.CourseName,D.SubjectCategory2,c.StockItemID,c.MediaTypeID,cast(D.ReleaseDate as date) as CourseReleaseDate,
		IPCL.StartDate as ReportStartDate,case when IPCL.EndDate = '2099-01-01' then cast(getdate() as date) else IPCL.EndDate end as ReportEndDate 
		,SUM(oie.Quantity ) Units  ,SUM(oie.Quantity * oie.SALESPRICE) Sales,cast(getdate() as date) as ReportRunDate, ADC.MD_CampaignName as Partner
		into #Partners
		from DAXImports..DAX_OrderExport oe 
		inner join (select * from DataWarehouse.Mapping.vwAdcodesAll where MD_Audience = 'B2B')Adc 
		on  oe.SourceCode = Adc.AdCode 
		--inner join DAXImports..CustomerExport CE 
		--on oe.Customerid = CE.Customerid  
		inner join DAXImports..DAX_OrderItemExport oie 
		on oe.orderid = oie.orderid 
		inner join Staging.InvItem c 
		on oie.ITEMID = c.StockItemID 
		inner join Mapping.DMCourse d 
		on c.CourseID = d.CourseID  
		inner join Staging.IPCourseList IPCL 
		on IPCL.Courseid = d.CourseID and oe.Orderdate >= IPCL.StartDate and oe.Orderdate < IPCL.EndDate
		where oie.LineType = 'ItemSold'  
		group by  D.CourseID,D.CourseName,D.SubjectCategory2,D.ReleaseDate,c.StockItemID,c.MediaTypeID,IPCL.StartDate ,IPCL.EndDate  ,ADC.MD_CampaignName

  
  
  insert into Datawarehouse.Marketing.IPReportByCourse
  select * from #TTCCCustomer
  union 
  select * from #Partners
  
  drop table #TTCCCustomerOrderitems
  drop table #TTCCCustomer
  drop table #Partners
  
End  



GO
