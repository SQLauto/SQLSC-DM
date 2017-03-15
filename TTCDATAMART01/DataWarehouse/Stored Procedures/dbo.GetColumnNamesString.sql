SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetColumnNamesString] (@database_name varchar(50), @table_name varchar(50), @result varchar(4000) output, @prim_key varchar(50) output) 
AS 
BEGIN 

declare @strSQL varchar(200) 
set nocount on 
create table #tmp_table (col_names varchar(50)) 
set @strSQL = 'insert into #tmp_table (col_names) select column_name from ' + @database_name + '.information_schema.columns where Table_name = ''' + @table_name + '''' 
exec(@strSQL) 
set @result = '' 
select @result = @result + CASE WHEN LEN(@result)>0 THEN ', ' ELSE '' END + '[' + col_names + ']' from #tmp_table 
set @prim_key = (select top 1 col_names from #tmp_table) 
set nocount off 
drop table #tmp_table 

END 
GO
