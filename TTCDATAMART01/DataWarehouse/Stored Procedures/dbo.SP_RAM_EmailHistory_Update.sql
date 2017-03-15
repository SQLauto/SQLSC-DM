SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_RAM_EmailHistory_Update] @Date nvarchar(8) = null
as
Begin

declare  @Table varchar(100),@SQL Nvarchar(2000)


If @Date is null
select @Date = cast (convert(varchar(8), getdate()-1, 112)  as nvarchar(8))
select @Date


select distinct TABLE_NAME, 0 as processed 
Into #ComboidPrior
from lstmgr.INFORMATION_SCHEMA.COLUMNS
where COLUMN_NAME like '%ComboidPrior%'
and TABLE_NAME like '%Email%'
and TABLE_NAME like '%'+@Date+'%'
and TABLE_NAME like '%_US_%'
and TABLE_NAME not like '%Del'
and TABLE_NAME not like '%WebLP%'
and TABLE_NAME not like '%_UK_%'
and TABLE_NAME not like '%_AU_%'
   
 select * from #ComboidPrior
 
 While exists( select top 1 * from #ComboidPrior where processed = 0) 
 Begin
 
 select top 1 @Table = Table_name from #ComboidPrior where processed = 0

 
 set @SQL = 'Insert into archive.RAM_EmailHistory 
			 select CustomerID,Adcode,  cast( '''+ @Date+ '''  as date) as StartDate, Comboid,ComboidPrior 
			 from LstMgr..' + @Table + '  
			 where Colo_Del_Ind = 0 and  ComboidPrior is not null'
 Print @SQL
 
 Exec (@SQL)
 
 update #ComboidPrior
 set processed = 1
 where Table_name = @Table
 select * from #ComboidPrior
 
 End
 
Delete from archive.RAM_EmailHistory
where Adcode in 
 (
 select adcode from archive.RAM_EmailHistory
 group by Adcode
 having COUNT(*)<100
 )
 
drop table #ComboidPrior

/* Where we dont have Combo id*/

select distinct TABLE_NAME, 0 as processed 
Into #NoComboidPrior
from lstmgr.INFORMATION_SCHEMA.COLUMNS
where  COLUMN_NAME like '%CatalogName%'
and TABLE_NAME like '%Email%'
and TABLE_NAME like '%'+@Date+'%'
and TABLE_NAME like '%_US_%'
and TABLE_NAME not like '%Del'
and TABLE_NAME not like '%WebLP%'
and TABLE_NAME not like '%_UK_%'
and TABLE_NAME not like '%_AU_%'
except
select distinct TABLE_NAME, 0 as processed 
from lstmgr.INFORMATION_SCHEMA.COLUMNS
where COLUMN_NAME like '%ComboidPrior%'


   
 select * from #NoComboidPrior
 
 While exists( select top 1 * from #NoComboidPrior where processed = 0) 
 Begin
 
 select top 1 @Table = Table_name from #NoComboidPrior where processed = 0

 
 set @SQL = 'Insert into archive.RAM_EmailHistory (CustomerID,	Adcode,	StartDate,	Comboid)
			 select CustomerID,Adcode,  cast( '''+ @Date+ '''  as date) as StartDate, Comboid
			 from LstMgr..' + @Table + '  
			 where Colo_Del_Ind = 0 and  CatalogName in (''RAM_Control'',''RAM_Test'') '
 Print @SQL
 
 Exec (@SQL)
 
 update #NoComboidPrior
 set processed = 1
 where Table_name = @Table
 
 select * from #NoComboidPrior
 
 End
 
Delete from archive.RAM_EmailHistory
where Adcode in 
 (
 select adcode from archive.RAM_EmailHistory
 group by Adcode
 having COUNT(*)<100
 )
 
drop table #NoComboidPrior


/*Update any missing ComboIdPrior using lead and lag*/

Update a
set a.ComboidPrior = coalesce(lagComboidPrior,leadComboidPrior)
from archive.RAM_EmailHistory a
join			(select * ,case when  ComboidPrior is null then lag(ComboidPrior) over(partition by CustomerID order by startdate) else ComboidPrior end as lagComboidPrior
				,case when  ComboidPrior is null then lead(ComboidPrior) over(partition by CustomerID order by startdate) else ComboidPrior end as LeadComboidPrior
					from  (select customerid,adcode,StartDate,ComboidPrior from archive.RAM_EmailHistory group by customerid,adcode,StartDate,ComboidPrior) a
					where customerid in( select customerid from archive.RAM_EmailHistory where ComboidPrior is null )
				)b
On a.CustomerID=b.CustomerID and a.Adcode=b.Adcode and a.StartDate=b.StartDate
where  a.ComboidPrior is null 


End



 

 
GO
