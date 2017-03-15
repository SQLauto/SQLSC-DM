SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[CompareTables](@databaseA varchar(50), @databaseB varchar(50), @tableA varchar(50), @tableB varchar(50) = '') 
AS 


IF @tableB = '' SET @tableB = @tableA 

declare @strTmp varchar(50), @col_namesA varchar(4000), @strSQL varchar(8000), @prim_key varchar(50) 
exec GetColumnNamesString @databaseA, @tableA, @col_namesA output, @prim_key output 
-- print @col_namesA 

set @strSQL = 'SELECT min(TableName) as TableName , ' + @col_namesA + ' 
FROM ( 
SELECT ''New_' + @tableA + ''' as TableName, A.* 
FROM ' + @databaseA + '.dbo.' + @tableA + ' A 
UNION ALL 
SELECT ''Old_' + @tableB + ''' as TableName, B.* 
FROM ' + @databaseB + '.dbo.' + @tableB + ' B 
) tmp 
GROUP BY ' + @col_namesA + ' 
HAVING COUNT(*) = 1 
ORDER BY ' + @prim_key 

exec( @strSQL ) 
-- print @strSQL 

GO
