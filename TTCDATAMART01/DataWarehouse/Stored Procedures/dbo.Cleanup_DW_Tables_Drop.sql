SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROC [dbo].[Cleanup_DW_Tables_Drop]


AS

-- To clean up ecampaigns tables in order to save space
-- Preethi Ramanujam 

DECLARE @ecampaignsTableName VARCHAR(100), @Qry VARCHAR(8000), @NewTable varchar(1000)

DECLARE MyCursor insensitive CURSOR
FOR
SELECT '['+SCHEMA_NAME(schema_id)+'].['+name+']'-- as TableName, create_date
AS SchemaTable
FROM sys.tables
where name like 'OrdAllctn_BudCodeAssignWkOf%set'
-- where name like 'House%AllCust'
-- where name like 'Email_2016%'
and create_date <= dateadd(month,-15,getdate())
order by 1

--- BEGIN Cursor for each table
OPEN MyCursor
FETCH NEXT FROM MyCursor INTO @ecampaignsTableName

WHILE @@FETCH_STATUS = 0
BEGIN

PRINT 'Running update for table ' + @ecampaignsTableName

	SET @Qry = 'SELECT TOP 10 * FROM  datawarehouse.' + @ecampaignsTableName 
	PRINT @Qry
	EXEC (@Qry)


-- Truncate the table

SET @Qry = 'truncate Table datawarehouse.' + @ecampaignsTableName
PRINT @Qry
EXEC (@Qry)


-- Drop the table

SET @Qry = 'drop Table datawarehouse.' + @ecampaignsTableName
PRINT @Qry
EXEC (@Qry)

	FETCH NEXT FROM MyCursor INTO @ecampaignsTableName
END
CLOSE MyCursor
DEALLOCATE MyCursor
--- END Cursor for each table









GO
