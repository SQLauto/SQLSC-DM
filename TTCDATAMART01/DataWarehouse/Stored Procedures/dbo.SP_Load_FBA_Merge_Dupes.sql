SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[SP_Load_FBA_Merge_Dupes] @TableName Varchar(100)= null, @VarDate Varchar(8)=null
as
Begin 

/* After loading it into DataWarehouse.Archive.Merge_Dupes*/

/* load TGC Customer match*/

Insert into Datawarehouse.mapping.FBA_Merge_Dupes
select distinct Fnl.prename,Fnl.fname,Fnl.mi	,Fnl.lname,Fnl.sufname,Fnl.add1,Fnl.add2,Fnl.add3,Fnl.city,Fnl.state,Fnl.zip,Fnl.acctno ,Fnl.kept_drop,Fnl.keptpin,fnl.FBACustomerid, null
,Rank() Over(Partition by Fnl.keptpin,Fnl.FBACustomerid order by Fnl.kept_drop desc,Fnl.acctno) as Rank,cast(Fnl.Merge_Date as date) as Merge_Date
from 
(
	select Distinct  D.*,K.acctno-2000000000 as FBACustomerid 
		from DataWarehouse.Archive.Merge_Dupes D
		join (
			select acctno,Keptpin
			from  DataWarehouse.Archive.Merge_Dupes
			where acctno >2000000000  
			) K
		on k.keptpin = D.keptpin
	where D.acctno  <1000000000 
) Fnl
left join Datawarehouse.mapping.FBA_Merge_Dupes M
on M.acctno = Fnl.acctno and Fnl.keptpin =M.keptpin and fnl.FBACustomerid = M.FBACustomerid 
where M.acctno is null

/* Update TGCPlus Customer match*/
update FBA
set FBA.TGCPlusCustomerid = D.acctno-1000000000
from Datawarehouse.mapping.FBA_Merge_Dupes FBA
join DataWarehouse.Archive.Merge_Dupes D 
on FBA.keptpin = D.keptpin
and D.acctno between 1000000000 and 2000000000
where FBA.TGCPlusCustomerid is null

--select *
--from Datawarehouse.mapping.FBA_Merge_Dupes FBA
--join DataWarehouse.Archive.Merge_Dupes D 
--on FBA.keptpin = D.keptpin
--and D.acctno between 1000000000 and 2000000000

Insert into Datawarehouse.mapping.FBA_Merge_Dupes

select Distinct Fnl.prename,Fnl.fname,Fnl.mi	,Fnl.lname,Fnl.sufname,Fnl.add1,Fnl.add2,Fnl.add3,Fnl.city,Fnl.state,Fnl.zip,null	,Fnl.kept_drop,Fnl.keptpin,Fnl.FBACustomerid,Fnl.acctno
,Rank() Over(Partition by Fnl.keptpin,Fnl.FBACustomerid order by Fnl.kept_drop desc,Fnl.acctno) as Rank,cast(Fnl.Merge_Date as date) as Merge_Date
from 
(
	select Distinct  D.*,K.acctno-2000000000 as FBACustomerid 
		from DataWarehouse.Archive.Merge_Dupes D
		join (
			select acctno,Keptpin
			from  DataWarehouse.Archive.Merge_Dupes
			where acctno >2000000000  
			) K
		on k.keptpin = D.keptpin
	where D.acctno > 1000000000 and D.acctno < 2000000000
) Fnl
left join Datawarehouse.mapping.FBA_Merge_Dupes M
on Fnl.keptpin = M.keptpin 
where M.FBACustomerid is null  



/* Update TGC Customer match based on TGCPlus match*/
update FBA
set FBA.acctno = D.acctno 
--select FBA.acctno , D.acctno ,*
from Datawarehouse.mapping.FBA_Merge_Dupes FBA
join DataWarehouse.Archive.Merge_Dupes D 
on FBA.keptpin = D.keptpin
where FBA.acctno is null 
and D.acctno < 1000000000   


End


GO
