SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[SP_Load_TGCplus_Merge_Dupes] @TableName Varchar(100)= null, @VarDate Varchar(8)=null
as
Begin 

--Declare @SQL as nvarchar(4000)


--set @SQL ='
--Insert into Datawarehouse.mapping.TGCplus_Merge_Dupes

--select Fnl.*,Rank() Over(Partition by keptpin,TGCPlusCustomerid order by kept_drop desc,acctno) as Rank,cast('''+ @VarDate + ''' as date) as Merge_Date
--from 
--(
--	select Distinct  D.*,K.acctno-1000000000 as TGCPlusCustomerid 
--		from DataWarehouse..' + @TableName +' D
--		join (
--			select acctno,Keptpin
--			from  DataWarehouse..' + @TableName +'
--			where acctno >1000000000
--			) K
--		on k.keptpin = D.keptpin
--	where D.acctno  <1000000000
--) Fnl'

-- Print @SQL

-- Exec (@SQL)

/* After loading it into DataWarehouse.Archive.Merge_Dupes*/

Insert into Datawarehouse.mapping.TGCplus_Merge_Dupes

select Fnl.prename,Fnl.fname,Fnl.mi	,Fnl.lname,Fnl.sufname,Fnl.add1,Fnl.add2,Fnl.add3,Fnl.city,Fnl.state,Fnl.zip,Fnl.acctno	,Fnl.kept_drop,Fnl.keptpin,fnl.TGCPlusCustomerid
,Rank() Over(Partition by Fnl.keptpin,Fnl.TGCPlusCustomerid order by Fnl.kept_drop desc,Fnl.acctno) as Rank,cast(Fnl.Merge_Date as date) as Merge_Date
from 
(
	select Distinct  D.*,K.acctno-1000000000 as TGCPlusCustomerid 
		from DataWarehouse.Archive.Merge_Dupes D
		join (
			select acctno,Keptpin
			from  DataWarehouse.Archive.Merge_Dupes
			where acctno >1000000000 and acctno <2000000000
			) K
		on k.keptpin = D.keptpin
	where D.acctno  <1000000000 
	--and DATEADD(month, DATEDIFF(month, 0, getdate()), 0) = Merge_Date 
) Fnl
left join Datawarehouse.mapping.TGCplus_Merge_Dupes M
on M.acctno = Fnl.acctno and Fnl.keptpin =M.keptpin and fnl.TGCPlusCustomerid = M.TGCPlusCustomerid 
where M.acctno is null

 End


GO
