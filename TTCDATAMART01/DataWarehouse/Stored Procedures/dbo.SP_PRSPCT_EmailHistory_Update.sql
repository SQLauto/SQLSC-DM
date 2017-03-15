SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[SP_PRSPCT_EmailHistory_Update] @Date nvarchar(8) = null
as
Begin

declare  @Table varchar(100),@SQL Nvarchar(2000)


If @Date is null
select @Date = cast (convert(varchar(8), getdate()-1, 112)  as nvarchar(8))
select @Date


select distinct TABLE_NAME, 0 as processed 
Into #PRSPCT
from lstmgr.INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME like '%PRSPCT%'
and TABLE_NAME like '%'+@Date+'%'
and TABLE_NAME NOT like '%del'

   
 select * from #PRSPCT
 
 While exists( select top 1 * from #PRSPCT where processed = 0) 
 Begin
 
 select top 1 @Table = Table_name from #PRSPCT where processed = 0

 
 set @SQL = 'insert into DataWarehouse.Archive.EmailhistoryPRSPCT
			select Emailaddress ,Adcode,cast( '''+ @Date+ '''  as date) as StartDate, 0 as FlagHoldOut,''Gen'' as PreferredCategory 
			from Lstmgr.dbo.' + @Table + ' 
			where emailaddress not like ''%@teachco.com''
			and Colo_Del_Ind = 0'
 Print @SQL
 
 Exec (@SQL)
 
 update #PRSPCT
 set processed = 1
 where Table_name = @Table

 select * from #PRSPCT
 
 End
 
End

 


GO
