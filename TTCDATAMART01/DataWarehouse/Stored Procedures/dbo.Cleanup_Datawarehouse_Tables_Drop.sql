SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[Cleanup_Datawarehouse_Tables_Drop]

AS

-- To clean up lstmgr tables in order to save space
-- Preethi Ramanujam 

DECLARE @lstmgrTableName VARCHAR(100), @Qry VARCHAR(8000), @NewTable varchar(1000)

DECLARE MyCursor insensitive CURSOR
FOR
SELECT SCHEMA_NAME(b.schema_id) + '.' + a.Name--,crdate 
FROM sysobjects a join
	 sys.tables b on a.id = b.object_id
--where a.name like 'welcomeEmail%AdcodeGridBKP%'
--WHERE a.Name like 'Email_2018%'
where a.name like 'Final%mtchbck%'
--WHERE a.Name like 'ordallctn_%OrdersWithPay%WkOf%'
--WHERE a.Name like '%DeL'
and a.crdate <= dateadd(month,-6,getdate())
and a.xtype = 'U'
and a.name not like '%numHit%'
and a.name not like '%FnlSmry%'
and a.name not like '%model%'
and a.name not like '%tgcplus%'
--and SCHEMA_NAME(b.schema_id) = 'staging'
order by 1 
--order by 2 desc
--and name not like '%COLO'

--- BEGIN Cursor for each table
OPEN MyCursor
FETCH NEXT FROM MyCursor INTO @lstmgrTableName

WHILE @@FETCH_STATUS = 0
BEGIN

PRINT 'Running update for table ' + @lstmgrTableName

	SET @Qry = 'SELECT TOP 10 * FROM  datawarehouse.' + @lstmgrTableName 
	PRINT @Qry
	EXEC (@Qry)


-- Truncate the table

SET @Qry = 'Truncate Table datawarehouse.' + @lstmgrTableName
PRINT @Qry
EXEC (@Qry)


-- Drop the table

SET @Qry = 'Drop Table datawarehouse.' + @lstmgrTableName
PRINT @Qry
EXEC (@Qry)

	FETCH NEXT FROM MyCursor INTO @lstmgrTableName
END
CLOSE MyCursor
DEALLOCATE MyCursor
--- END Cursor for each table









GO
