SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROC [dbo].[GetAdcodeInfoDAX] @TableName varchar(200), @DatabaseName varchar(50), @SchemaName varchar(30)
AS

/* Preethi Ramanujam 	10/31/2008	To get adcode information from a mail/email table*/

DECLARE @DeBugCode TINYINT
DECLARE @Qry VARCHAR(8000)

SET @DeBugCode = 1

SET @Qry = 'select a.adcode, b.adcodename, b.catalogcode, count(distinct a.customerid) CustCount ' + Char(10) + char(13) +
	' from ' + @DatabaseName + '.' + @SchemaName + '.' + @TableName + ' a left outer join '  + Char(10) + char(13) +
	'   mapping.vwadcodesall b on a.adcode = b.adcode
	group by a.adcode, b.adcodename, b.catalogcode
	order by 1'

PRINT 'Executing' + Char(10) + char(13) + @Qry
EXEC (@Qry)
GO
