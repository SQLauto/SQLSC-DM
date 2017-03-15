SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [Staging].[CampaignEmail_RemoveUnsubs]
	@TableName VARCHAR(100),
	@DebugCode INT = 1
AS

DECLARE @ErrorMsg VARCHAR(8000)

/*- Check to make sure CatalogCodes are provided by the user.*/
IF @DeBugCode = 1 PRINT 'Checking to make sure table name is provided by the user.'


IF @TableName IS NULL
BEGIN	
	/* Check if we can get the DL control version of catalogcode *****/
	SET @ErrorMsg = 'Please provide TableName for the removing unsubs'
	RAISERROR(@ErrorMsg,15,1)
	RETURN
END

/*- Check to make sure CatalogCode Provided is correct.*/
IF @DeBugCode = 1 PRINT 'Checking to make sure Table Name Provided is correct'

DECLARE @Count INT


SELECT @Count = COUNT(*)
FROM SysObjects
WHERE Name = @TableName

IF @Count = 0
BEGIN	
	SET @ErrorMsg = 'Table Name ' + CONVERT(VARCHAR,@TableName) + ' does not exist. Please Provide a valid Table Name'
	RAISERROR(@ErrorMsg,15,1)
	RETURN
END

DECLARE @Qry VARCHAR(8000)

SET @Qry = 'SELECT COUNT(DISTINCT customerid) 
			FROM Staging.' + @TableName
			
PRINT (@Qry)
EXEC (@Qry)
 
PRINT 'Remove based on InvalidEmails'

SET @Qry = 'DELETE a
			FROM Staging.' + @TableName + ' a JOIN
				Legacy.InvalidEmails b (nolock) on a.emailaddress = b.EmailAddress
									and a.customerid between 1 and 89999999'
			
PRINT (@Qry)
EXEC (@Qry)

SET @Qry = 'DELETE a
			FROM Staging.' + @TableName + ' a JOIN
			Legacy.InvalidEmails b (nolock) on a.customerid = b.customerid
								and a.customerid between 1 and 89999999'
		
PRINT (@Qry)
EXEC (@Qry)

SET @Qry = 'SELECT COUNT(DISTINCT customerid) 
			FROM Staging.' + @TableName

PRINT (@Qry)
EXEC (@Qry)
GO
