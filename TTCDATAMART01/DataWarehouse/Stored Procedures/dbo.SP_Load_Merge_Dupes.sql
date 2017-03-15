SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[SP_Load_Merge_Dupes]   @Date date = null
as
Begin 

if @Date is null
set @Date = cast(DATEADD(month, DATEDIFF(month, 0, getdate()), 0) as date )


--Do not delete just add new merges
--Delete A 
--select Count(*)
--from DataWarehouse.Archive.Merge_Dupes A
--join DataWarehouse.staging.Merge_Dupes S
--on A.keptpin = S.keptpin
--and A.acctno = S.acctno

 

Insert into DataWarehouse.Archive.Merge_Dupes
select distinct s.*,@Date from DataWarehouse.staging.Merge_Dupes S
left join DataWarehouse.Archive.Merge_Dupes A
on A.keptpin = S.keptpin
and A.acctno = S.acctno
Where A.keptpin is null

End
GO
