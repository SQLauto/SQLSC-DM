SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROC  [Staging].[GetAdcodeInfo_test] 
@TableName varchar(200), @DatabaseName varchar(50)  
AS  
  
-- Preethi Ramanujam  10/31/2008 To get bundle information given a courseID  
  
DECLARE @ErrorMsg VARCHAR(400)   --- Error message for error handling.  
DECLARE @DeBugCode TINYINT  
DECLARE @Qry VARCHAR(8000)  
  
SET @DeBugCode = 1  
  
SET @Qry = 'select a.adcode, b.adcodename, b.catalogcode, count(distinct a.customerid) CustCount ' + Char(10) + char(13) +  
 ' from ' + @DatabaseName + '.' + @TableName + ' a left outer join '  + Char(10) + char(13) +  
 ' DataWarehouse.Mapping.vwAdcodesAll b on a.adcode = b.adcode  
 group by a.adcode, b.adcodename, b.catalogcode  
 order by 1'  
  
PRINT 'Executing' + Char(10) + char(13) + @Qry  
EXEC (@Qry)  
  
GO
