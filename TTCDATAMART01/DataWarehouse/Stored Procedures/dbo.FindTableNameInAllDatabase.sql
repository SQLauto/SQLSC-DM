SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[FindTableNameInAllDatabase]
 
 @TableName VARCHAR(256)
 AS
 
 DECLARE @DBName VARCHAR(256)
 DECLARE @varSQL VARCHAR(512)
 DECLARE @getDBName CURSOR
	 SET @getDBName = CURSOR FOR
	 SELECT name
	 FROM sys.databases
	 
	 CREATE TABLE #TmpTable (DBName VARCHAR(256),
	 SchemaName VARCHAR(256),
	 TableName VARCHAR(256))
	 
	 OPEN @getDBName
	 FETCH NEXT
	 FROM @getDBName INTO @DBName
	 WHILE @@FETCH_STATUS = 0
		 BEGIN
			 SET @varSQL = 'USE ' + @DBName + ';
			 INSERT INTO #TmpTable
			 SELECT '''+ @DBName + ''' AS DBName,
			 SCHEMA_NAME(schema_id) AS SchemaName,
			 name AS TableName
			 FROM sys.tables
			 WHERE name LIKE ''%' + @TableName + '%'''
			 EXEC (@varSQL)
			 FETCH NEXT
			 FROM @getDBName INTO @DBName
		 END
	 CLOSE @getDBName
	 DEALLOCATE @getDBName
	 
 SELECT *
 FROM #TmpTable
 
 DROP TABLE #TmpTable
GO
