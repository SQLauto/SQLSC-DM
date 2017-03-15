SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [Staging].[Cleanup_Datawarehouse_Tables_Drop]

AS

-- To clean up Datawarehouse tables in order to save space
-- Preethi Ramanujam 

DECLARE @DatawarehouseTableName VARCHAR(100), @Qry VARCHAR(8000), @NewTable varchar(1000)

DECLARE MyCursor insensitive CURSOR
FOR
SELECT Name FROM sysobjects
WHERE Name like 'Email_201701%'
and crdate <= dateadd(month,-2,getdate())
order by 1
--and name not like '%COLO'

--- BEGIN Cursor for each table
OPEN MyCursor
FETCH NEXT FROM MyCursor INTO @DatawarehouseTableName

WHILE @@FETCH_STATUS = 0
BEGIN

PRINT 'Running update for table ' + @DatawarehouseTableName

	SET @Qry = 'SELECT TOP 10 * FROM  Datawarehouse.staging.' + @DatawarehouseTableName 
	PRINT @Qry
--	EXEC (@Qry)


-- Truncate the table

SET @Qry = 'Truncate Table Datawarehouse.staging.' + @DatawarehouseTableName
PRINT @Qry
EXEC (@Qry)


-- Drop the table

SET @Qry = 'Drop Table Datawarehouse.staging.' + @DatawarehouseTableName
PRINT @Qry
EXEC (@Qry)

	FETCH NEXT FROM MyCursor INTO @DatawarehouseTableName
END
CLOSE MyCursor
DEALLOCATE MyCursor
--- END Cursor for each table









GO
