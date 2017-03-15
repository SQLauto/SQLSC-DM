SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [dbo].[SP_Omni_Load_Omni_Churn_Model_Webvisit]
as 
Begin

	insert into Datawarehouse.Archive.Omni_Churn_Model_Webvisit
	(Customerid,VisitDate,Prodview)

	select S.*
	From 
	(select Customerid,[Date] as VisitDate,sum(cast(Prodview as Int)) as Prodview 
	from Datawarehouse.staging.Omni_Churn_Model_Webvisit 
	Where Customerid is not NULL
	Group by Customerid,Date)S
	left join  Datawarehouse.Archive.Omni_Churn_Model_Webvisit A
	On A.Customerid =S.Customerid and A.VisitDate = S.VisitDate
	where A.Customerid is null and A.VisitDate is null

End
GO
