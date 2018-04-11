SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [Staging].[SP_MC_TGC_WebVisits]

AS

TRUNCATE TABLE [staging].[MC_TGC_WebVisits]

Insert Into [staging].[MC_TGC_WebVisits] (CustomerID,[MonthStartDate],AllVisits,ProdViews,PageViews)



select CustomerID,
		cast(dateadd(month,datediff(month,0,cast(visitdate as date)),0) as date) [MonthStartDate],
		sum(a.AllVisits) as AllVisits,
		sum(a.Prodviews) as ProdViews,
		sum(a.pageviews) as PageViews 
	from Datawarehouse.Archive.Omni_AllWebUserId a inner join  
	(select distinct customerid, web_user_id 
	from DataWarehouse.mapping.Customerid_Userid_MarketingCloudID)b on a.UserId=b.web_user_id
	where dateadd(month,datediff(month,0,visitdate),0)= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)   --format(dateadd(month,datediff(month,0,GETDATE()),0),' dd-MM-yyyy') = DateAdd(M,-1,GetDate())--  dateadd(month,datediff(month,0,GETDATE()),0)=dateadd(month,datediff(month,0,GETDATE()),0)-2
	group by customerid,cast(dateadd(month,datediff(month,0,cast(visitdate as date)),0) as date)

	

	insert into [Marketing].[MC_TGC_WebVisits] (CustomerID,[MonthStartDate],AllVisits,ProdViews,PageViews) 
	select * from  [staging].[MC_TGC_WebVisits]

GO
