SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_Omni_Load_Omni_AllWebCust] 
as 
Begin


delete from Datawarehouse.Staging.Omni_AllWebCust
where customerid=''

	insert into Datawarehouse.Archive.Omni_AllWebCust 

	select S.*
	From 
	(select [Date],Customerid,cast([AllVisits] as int)AllVisits,cast(ProdView as int)ProdViews,cast([PageViews] as int)PageViews,getdate() as DMLastUpdated
	from Datawarehouse.Staging.Omni_AllWebCust  S
	Where Customerid is not NULL)S
	left join Datawarehouse.Archive.Omni_AllWebCust A
	On A.Customerid = S.Customerid and A.VisitDate = S.Date
	where A.Customerid is null and A.VisitDate is null

End
GO
