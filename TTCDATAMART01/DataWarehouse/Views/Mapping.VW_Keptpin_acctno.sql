SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create View [Mapping].[VW_Keptpin_acctno]
as
	select distinct a.Keptacctno,b.acctno ,Merge_Date
	from 
	(
	select acctno as Keptacctno,keptpin from  DataWarehouse.Archive.Merge_Dupes
	where kept_drop = 'KEPT'
	and DATEADD(month, DATEDIFF(month, 0, getdate()), 0) = Merge_Date
	)a
	join DataWarehouse.Archive.Merge_Dupes b
	on a.keptpin = b.keptpin
	where a.Keptacctno<>b.acctno
	and DATEADD(month, DATEDIFF(month, 0, getdate()), 0) = Merge_Date
	
GO
