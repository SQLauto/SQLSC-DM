SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [Staging].[CampaignEmail_FreeLectureNEW]
	@EmailCatalogCode INT = 9999,
	@EmailCatalogCodeSwamp INT = 8804,
	@EmailCatalogCodeInt INT = 8805,
	@EmailCatalogCodeInquirer INT = 8806,
	@EmailCatalogCodeCanada INT = 13631,
	@SubjLine VARCHAR(300) = 'Free Lecture from The Teaching Company',
	@EmailDesc VARCHAR(20) = '',
	@Test VARCHAR(5) = 'YES',
	@DeBugCode INT = 1
AS

/*- Proc Name: 	Ecampaigns.dbo.CampaignEmail_FreeLecture*/
/*- Purpose:	To generate Email List for Free Lecture Emails.*/
/*- Updates:*/
/*- Name		Date		Comments*/
/*- Preethi Ramanujam 	10/25/2007	New*/
/*- */

/*- Declare variables*/

DECLARE @ErrorMsg VARCHAR(400)   /*- Error message for error handling.*/

DECLARE @DropDate DATETIME
DECLARE @DropDateOthers DATETIME

DECLARE @AdcodeActive INT
DECLARE @AdcodeSwamp INT
DECLARE @AdcodeIntnl INT
DECLARE @AdcodeInq INT
DECLARE @AdcodeCanada INT

/*- Check to make sure CatalogCodes are provided by the user.*/
IF @DeBugCode = 1 PRINT 'Checking to make sure CatalogCode is provided by the user'

IF @EmailCatalogCode IS NULL
BEGIN	
	/* Check if we can get the DL control version of catalogcode *****/
	SET @ErrorMsg = 'CatalogCode was not provided for FreeLecture Email. Will use dummy Catalogcode'
	PRINT @ErrorMsg
END

/*- Check to make sure CatalogCode Provided is correct.*/
IF @DeBugCode = 1 PRINT 'Checking to make sure CatalogCode Provided is correct'

DECLARE @Count INT 

IF @EmailCatalogcodeSwamp <> 9999
BEGIN
	SELECT @Count = COUNT(*)
	FROM Staging.MktCatalogCodes
	WHERE CatalogCode = @EmailCatalogCodeSwamp
	
	IF @Count = 0
	BEGIN	
		SET @ErrorMsg = 'CatalogCode ' + CONVERT(VARCHAR,@EmailCatalogCodeSwamp) + ' does not exist. Please Provide a valid Catalogcode for Email'
		RAISERROR(@ErrorMsg,15,1)
		RETURN
	END
END

IF @EmailCatalogCode = 9999 
   BEGIN
	PRINT 'Dummy CatalogCode 9999 is being used'
	SET @DropDate = CONVERT(DATETIME,FLOOR(CONVERT(FLOAT,GETDATE())))

	SET @AdcodeActive = 99999
	SET @AdcodeSwamp = @AdcodeActive + 1

   END
ELSE
   BEGIN
	SELECT @Count = COUNT(*)
	FROM Staging.MktCatalogCodes
	WHERE CatalogCode = @EmailCatalogCode
	
	IF @Count = 0
	BEGIN	
		SET @ErrorMsg = 'CatalogCode ' + CONVERT(VARCHAR,@EmailCatalogCode) + ' does not exist. Please Provide a valid Catalogcode for Email'
		RAISERROR(@ErrorMsg,15,1)
		RETURN
	END
	
	/*- STEP1: Bring catalog data FROM From Email Catalog code provided*/
	IF @DeBugCode = 1 PRINT 'STEP1: Derive data based on CatalogCodes'
	
	/*--- Derive Dropdate for the Email
	
	SELECT @DropDate = StartDate
	FROM Superstardw.dbo.MktCatalogCodes
	WHERE CatalogCode = @EMailCatalogCode
	
	IF @DeBugCode = 1 PRINT 'DropDate = ' + CONVERT(VARCHAR,@DropDate,101)

	--- Derive Dropdate for Swamp folks -- PR 9/21/2007
	DECLARE @DropDateOthers DATETIME

	SELECT @DropDateOthers = @DropDate - 1

	IF @DeBugCode = 1 PRINT 'DropDateOthers = ' + CONVERT(VARCHAR,@DropDateOthers,101)*/

	/*- Derive Dropdate for the Email*/
	
	IF @EmailCatalogCodeSwamp = 8804
		BEGIN
			SELECT @DropDate = StartDate,
				@DropDateOthers = StartDate
			FROM Staging.MktCatalogCodes
			WHERE CatalogCode = @EMailCatalogCode
			
			IF @DeBugCode = 1 
			   BEGIN
				PRINT 'DropDate = ' + CONVERT(VARCHAR,@DropDate,101)
				PRINT 'DropDateSNI = ' + CONVERT(VARCHAR,@DropDateOthers,101)
			   END
		END
	ELSE
		BEGIN
			SELECT @DropDate = StartDate
			FROM Staging.MktCatalogCodes
			WHERE CatalogCode = @EMailCatalogCode
		
			SELECT @DropDateOthers = StartDate
			FROM Staging.MktCatalogCodes
			WHERE CatalogCode = @EMailCatalogCodeSwamp
			
			IF @DeBugCode = 1 
			   BEGIN
				PRINT 'DropDate = ' + CONVERT(VARCHAR,@DropDate,101)
				PRINT 'DropDateSNI = ' + CONVERT(VARCHAR,@DropDateOthers,101)
			   END
	   	END

	/*- Derive the campaign ID  -- PR 9/21/2007*/
	DECLARE @ECampaignIDActive VARCHAR(30)
	DECLARE @ECampaignIDSwamp VARCHAR(30)
	
	SELECT @ECampaignIDActive = 'FLAct' + CONVERT(VARCHAR,@DropDate,112)
	SELECT @ECampaignIDSwamp = 'FLSwmp' + CONVERT(VARCHAR,@DropDateOthers,112)
	
	/*- Get Adcodes for the Email*/
	
	SELECT @AdcodeActive = Adcode
	FROM Staging.MktAdcodes
	WHERE CatalogCode = @EmailCatalogCode
	AND UPPER(Name) LIKE '%ACTIVE%'
	
	IF @AdcodeActive IS NULL
	BEGIN
		SET @AdcodeActive = 99999
		SET @ErrorMsg = 'No Adcode was found for CatalogCode ' + CONVERT(VARCHAR,@EmailCatalogCode) + '. Using default adcode 99999 that needs to be udpated'
		PRINT @ErrorMsg
	END
	
	SELECT @AdcodeSwamp = Adcode
	FROM Staging.MktAdcodes
	WHERE CatalogCode = @EmailCatalogCodeSwamp
	AND UPPER(Name) LIKE '%SWAMP CONTROL%'
	
	IF @AdcodeSwamp IS NULL
	   BEGIN
		IF @EmailCatalogCodeSwamp <> 8804
		   BEGIN
			SELECT @AdcodeSwamp = Adcode
			FROM Staging.MktAdcodes
			WHERE CatalogCode = @EmailCatalogCodeSwamp
			AND UPPER(Name) LIKE '%SWAMP CONTROL%'
		   END
		ELSE
		   BEGIN
			PRINT '****WARNING**** AdcodeSwamp was not found. So, adding one to the AdcodeActive'
			SET @AdcodeSwamp = 8888
		   END
	   END
	
	SELECT @AdcodeIntnl =  Adcode
	FROM Staging.MktAdcodes
	WHERE CatalogCode = @EmailCatalogCodeInt
	AND UPPER(Name) LIKE '%INTERNATIONAL%'  /* CONTROL'*/
	
	IF @AdcodeIntnl IS NULL
	   BEGIN
		IF @EmailCatalogCodeInt <> 8805
		   BEGIN
			SELECT @AdcodeIntnl =  Adcode
			FROM Staging.MktAdcodes
			WHERE CatalogCode = @EmailCatalogCodeInt
			AND UPPER(Name) LIKE '%INTERNATIONAL%'  /* CONTROL'*/
		   END
		ELSE
		   BEGIN
			PRINT '****WARNING**** AdcodeIntnl was not found. So, adding two to the AdcodeActive'
			SET @AdcodeIntnl = 7777
		   END
	   END

	
	SELECT @AdcodeInq =  Adcode
	FROM Staging.MktAdcodes
	WHERE CatalogCode = @EmailCatalogCodeInquirer
	AND UPPER(Name) LIKE '%Inquirer%'  /* CONTROL'*/
	
	IF @AdcodeInq IS NULL
	   BEGIN
		IF @EmailCatalogCodeInquirer <> 8806
		   BEGIN
			SELECT @AdcodeInq =  Adcode
			FROM Staging.MktAdcodes
			WHERE CatalogCode = @EmailCatalogCodeInquirer
			AND UPPER(Name) LIKE '%Inquirer%'  /* CONTROL'*/
		   END
		ELSE
		   BEGIN
			PRINT '****WARNING**** @AdcodeInq was not found. So, adding two to the AdcodeActive'
			SET @AdcodeInq = 6666
		   END
	   END
	   
	SELECT @AdcodeCanada =  Adcode
	FROM Staging.MktAdcodes
	WHERE CatalogCode = @EmailCatalogCodeCanada
	AND UPPER(Name) LIKE '%CANADA%'  /* CONTROL'*/
	
	IF @AdcodeInq IS NULL
	   BEGIN
		IF @EmailCatalogCodeInquirer <> 13631
		   BEGIN
			SELECT @AdcodeCanada =  Adcode
			FROM Staging.MktAdcodes
			WHERE CatalogCode = @EmailCatalogCodeCanada
			AND UPPER(Name) LIKE '%CANADA%'  /* CONTROL'*/
		   END
		ELSE
		   BEGIN
			PRINT '****WARNING**** @AdcodeCanada was not found. So, adding two to the AdcodeActive'
			SET @AdcodeCanada = 5555
		   END
	   END
	   	   

	IF @DeBugCode = 1 
	BEGIN
		PRINT 'AdcodeActive = ' +  CONVERT(VARCHAR,@AdcodeActive) 
		PRINT 'AdcodeSwamp = ' + CONVERT(VARCHAR,@AdcodeSwamp) 
		PRINT 'AdcodeIntnl = ' + CONVERT(VARCHAR,@AdcodeIntnl)
		PRINT 'AdcodeInq = ' + CONVERT(VARCHAR,@AdcodeInq)
		PRINT 'AdcodeCanada = ' + CONVERT(VARCHAR,@AdcodeCanada)
	END

   END

/*- Derive  Final table name.*/
DECLARE @FnlTable VARCHAR(100)
DECLARE @FnlTableOthers1 VARCHAR(100)

/* SELECT @FnlTable = 'Email' + CONVERT(VARCHAR,YEAR(@DropDate)) + '_' + CONVERT(VARCHAR,MONTH(@DropDate)) + '_' +*/
/* 	CONVERT(VARCHAR,DAY(@DropDate)) + 'Offers_FreeLctr' + @EmailDesc*/
/* FROM Superstardw.dbo.MktCatalogCodes*/
/* WHERE CatalogCode = @EmailCatalogCode*/
/* */
/* SELECT @FnlTableOthers1 = 'Email' + CONVERT(VARCHAR,YEAR(@DropDateOthers)) + '_' + CONVERT(VARCHAR,MONTH(@DropDate)) + '_' +*/
/* 	CONVERT(VARCHAR,DAY(@DropDate)) + 'Offers_FreeLctr' + @EmailDesc*/
/* FROM Superstardw.dbo.MktCatalogCodes*/
/* WHERE CatalogCode = @EmailCatalogCode*/

SELECT @FnlTable = 'Ecampaigns.dbo.Email' + CONVERT(VARCHAR,@DropDate,112) + '_' + 'Offers_FreeLctr' + @EmailDesc
FROM Staging.MktCatalogCodes
WHERE CatalogCode = @EmailCatalogCode

SELECT @FnlTableOthers1 = 'Ecampaigns.dbo.Email' + CONVERT(VARCHAR,@DropDateOthers,112) + '_' + 'Offers_FreeLctr' + @EmailDesc
FROM Staging.MktCatalogCodes
WHERE CatalogCode = @EmailCatalogCode


DECLARE @FnlTableActive VARCHAR(100)
DECLARE @FnlTableOthers VARCHAR(100)
DECLARE @FnlTableWInq VARCHAR(100)

SELECT @FnlTableActive = @FnlTable + '_Active'
SELECT @FnlTableOthers = @FnlTableOthers1 + '_Swamp'
SELECT @FnlTableWInq = @FnlTableOthers1 + '_WInq'

IF @DeBugCode = 1 
BEGIN
	PRINT 'Final Table Name = ' + @FnlTable
	PRINT 'Final Active Table Name = ' + @FnlTableActive
	PRINT 'Final Others Table Name = ' + @FnlTableOthers
END



/*--- Generate Subject line for the email.

DECLARE @SubjLine VARCHAR(400) -- Default SubjectLine

SELECT @SubjLine = 'Free Teaching Company Benefits for You'*/


/*- STEP2: Get the list of Emailable Customers*/

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Email_FreeLecture')
	DROP TABLE Staging.Email_FreeLecture

SELECT DISTINCT Customerid, FirstName, LastName, EmailAddress, ComboID,
		1 AS CourseID, 1 AS Rank, 
		CASE WHEN CustomerSegmentNew = 'Active' THEN @AdcodeActive
		     ELSE @AdcodeSwamp
		END AS Adcode, 
		CASE WHEN CustomerSegment = 'Active' THEN @ECampaignIDActive
		     ELSE @ECampaignIDSwamp
		END AS ECampaignID,
		State AS Region, CountryCode,
		@SubjLine AS SubjectLine,
		PreferredCategory2 as PreferredCategory,
        ccs.CustomerSegmentNew
INTO Staging.Email_FreeLecture
FROM Marketing.CampaignCustomerSignature ccs (nolock)
WHERE PublicLibrary = 0 
AND FlagEmail = 1
AND CountryCode <> 'GB'

CREATE CLUSTERED INDEX IDX_EFL ON Staging.Email_FreeLecture (CustomerID)

/*- Update AdCode for Inquirers*/

IF @DeBugCode = 1 PRINT 'Update AdCode for Inquirers'

UPDATE EC01
SET Adcode = @AdcodeInq
FROM Staging.Email_FreeLecture EC01 JOIN
	Marketing.CampaignCustomerSignature CCS ON CCS.CustomerID = EC01.CustomerID
WHERE CCS.BuyerType = 1


/*- Update AdCode for International customers*/

IF @DeBugCode = 1 PRINT 'Update AdCode for International customers'

UPDATE EC01
SET Adcode = @AdcodeIntnl
FROM Staging.Email_FreeLecture EC01 JOIN
	Marketing.CampaignCustomerSignature CCS ON CCS.CustomerID = EC01.CustomerID
WHERE CCS.CountryCode NOT LIKE '%US%'
AND CCS.CountryCode IS NOT NULL
AND CCS.CountryCode <> ''

/*- Update AdCode for Canada customers*/

IF @DeBugCode = 1 PRINT 'Update AdCode for Canada customers'

UPDATE EC01
SET Adcode = @AdcodeCanada
FROM Staging.Email_FreeLecture EC01 JOIN
	Marketing.CampaignCustomerSignature CCS ON CCS.CustomerID = EC01.CustomerID
WHERE CCS.CountryCode LIKE '%CA%'

/* Delete if there are still from GB*/
DELETE FROM Staging.Email_FreeLecture
WHERE CountryCode = 'GB'

DELETE A
from Staging.Email_FreeLecture a join
	(select * from marketing.campaigncustomersignature
	where countrycode = 'GB')b on a.emailaddress = b.emailaddress
	

/* Delete if there are still from AU*/
/*DELETE FROM Ecampaigns.dbo.Email_FreeLecture*/
/*WHERE CountryCode = 'AU'*/


DELETE A
from Staging.Email_FreeLecture a join
	(select * from marketing.campaigncustomersignature
	where countrycode = 'AU'
	and CustomerSince >= '9/1/2010')b on a.emailaddress = b.emailaddress


DELETE A
from Staging.Email_FreeLecture a join
	(select * from marketing.campaigncustomersignature
	where countrycode = 'AU'
	and CustomerSince >= '9/1/2010')b on a.CustomerID = b.CustomerID
		

/*- Add Web Inq Customers*/
/*- Drop if @FnlTablActive already exists*/

/*DECLARE @RowCounts INT

SELECT @RowCounts = COUNT(*) FROM sysobjects
WHERE Name = @FnlTableWInq
SELECT '@RowCounts = ' + CONVERT(VARCHAR,@RowCounts)

IF @RowCounts > 0
BEGIN
	SET @Qry = 'DROP TABLE Ecampaigns.dbo.' + @FnlTableWInq
	SELECT @Qry
	EXEC (@Qry)
END*/

/* IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Email_FreeLecture_WInq')*/
/* 	DROP TABLE Ecampaigns.dbo.Email_FreeLecture_WInq*/
/* */
/* SELECT C.CustomerID, */
/* 	MarketingDM.dbo.proper(C.FirstName) FirstName,*/
/* 	MarketingDM.dbo.proper(C.LastName) LastName, */
/* 	C.EmailAddress, */
/* 	'WebInqs' AS ComboID,*/
/* 	1 as CourseID, 	*/
/* 	1 as Rank, */
/* 	@AdcodeInq as Adcode, */
/* 	@ECampaignIDSwamp AS ECampaignID, */
/* 	convert(varchar(2),'') as Region,*/
/* 	@SubjLine AS SubjectLine, */
/* 	'GEN' AS PreferredCategory*/
/* INTO Ecampaigns.dbo.Email_FreeLecture_WInq	*/
/* FROM Superstardw.dbo.Customers C LEFT OUTER JOIN	*/
/* 	MarketingDM.dbo.CampaignCustomerSignature CCS ON C.CustomerID = CCS.CustomerID*/
/* 	JOIN*/
/* 	/*(SELECT CustomerID*/
/* 	FROM Superstardw.dbo.AcctPreferences*/
/* 	WHERE PreferenceID = 'OfferEmail'*/
/* 	AND PreferenceValue = 1)AP ON C.CustomerID = AP.CustomerID*/*/
/* 	Superstardw.dbo.AcctPreferences AP ON C.CustomerID = AP.CustomerID*/
/* WHERE CCS.CustomerID IS NULL AND C.EmailAddress LIKE '%@%'	*/
/* AND C.EmailAddress not Like '%teachco.com' AND C.organization_key is null*/
/* AND AP.PreferenceID = 'OfferEmail'*/
/* 	AND AP.PreferenceValue = 1*/
/* ORDER BY C.CustomerID*/
/* */
/* CREATE CLUSTERED INDEX IDX_EFLWI ON Email_FreeLecture_WInq (CustomerID)*/
/* */
/* --- Delete rows where email address is in the main file*/
/* DELETE A	*/
/* FROM Ecampaigns.dbo.Email_FreeLecture_WInq A JOIN	*/
/* 	Ecampaigns.dbo.Email_FreeLecture B ON A.EmailAddress = B.EmailAddress*/
/* */
/* DELETE A	*/
/* FROM Ecampaigns.dbo.Email_FreeLecture_WInq A JOIN	*/
/* 	Ecampaigns.dbo.Email_FreeLecture B ON A.CustomerID = B.CustomerID*/
/* */
/* INSERT INTO Ecampaigns.dbo.Email_FreeLecture*/
/* SELECT **/
/* FROM Ecampaigns.dbo.Email_FreeLecture_WInq */

/*- Delete Customers with duplicate EmailAddress*/
IF @DeBugCode = 1 PRINT 'Delete Customers with duplicate EmailAddress'

DECLARE @RowCount INT
SET @RowCount =1

WHILE @RowCount > 0
BEGIN
DELETE FROM Staging.Email_FreeLecture
WHERE CustomerID IN (
		SELECT MIN(Customerid)
		FROM Staging.Email_FreeLecture
		WHERE EmailAddress IN
				(SELECT EmailAddress
				FROM Staging.Email_FreeLecture
				GROUP BY EmailAddress
				HAVING COUNT(Customerid) > 1)
		GROUP BY EmailAddress)
SET @RowCount = @@ROWCOUNT
SELECT @RowCount
END
   
/* Remove Unsubs*/
exec Staging.CampaignEmail_RemoveUnsubs 'Email_FreeLecture'

/*- STEP 8: Generate Reports*/
IF @DeBugCode = 1 PRINT 'STEP 8: Generate Reports'

/*- Report1: Counts by RFM Cells*/

SELECT RCL.SeqNum,RCL.RFMCells, RCL.ComboID, 
	COUNT(FL.CustomerID) AS CountOfCustomers
FROM (SELECT DISTINCT SeqNum, RFMCells, ComboID
	FROM Mapping.RFMComboLookup)RCL LEFT OUTER JOIN
	Staging.Email_FreeLecture FL ON FL.ComboID = RCL.ComboID
GROUP BY RCL.SeqNum, RCL.RFMCells, RCL.ComboID
ORDER BY RCL.SeqNum


/*- Report2: Count by AdCode and SubjectLine*/

SELECT FL.AdCode, MAC.Name AS AdcodeName,
	FL.SubjectLine, FL.ECampaignID,
	COUNT(FL.Customerid) AS TotalCount,
	COUNT(DISTINCT Customerid) AS UniqueCustCount
FROM Staging.Email_FreeLecture FL LEFT OUTER JOIN
	Staging.MktAdcodes MAC ON FL.Adcode = MAC.Adcode
GROUP BY FL.AdCode, MAC.Name, FL.SubjectLine, FL.ECampaignID
ORDER BY FL.Adcode

/*- Generate Customer and Course information for Instruction files*/

SELECT DISTINCT c.CustomerID,d.FirstName,d.LastName,c.Adcode
FROM (SELECT MAX(DISTINCT a.customerid) AS customerid, a.Adcode
	FROM Staging.Email_FreeLecture  a
	GROUP BY a.Adcode)c JOIN
	Staging.Email_FreeLecture d ON c.customerid=d.customerid
ORDER BY c.Adcode


/*- Add Customer data to Email History Table  */

IF @Test = 'NO'
BEGIN
	IF @DeBugCode = 1 PRINT 'Add Customer data to Email History Table'
	INSERT INTO Ecampaigns..EmailHistory
	(CustomerID,Adcode,StartDate)
	SELECT Customerid,
		Adcode,
		@DropDate AS StartDate
	FROM Staging.Email_FreeLecture
END

/*- Generate  Final table*/
IF @DeBugCode = 1 PRINT 'Create Final Tables'

DECLARE @Qry VARCHAR(1000)

/*- Drop if @FnlTablActive already exists*/

IF (EXISTS (SELECT * FROM ecampaigns.INFORMATION_SCHEMA.TABLES        
			WHERE TABLE_CATALOG = 'ECampaigns'
			AND TABLE_SCHEMA = 'dbo'
			AND TABLE_NAME = REPLACE(@FnlTableActive,'Ecampaigns.dbo.','')))
-- if object_id(@FnlTableActive) is not null 
BEGIN
	SET @Qry = 'DROP TABLE ' + @FnlTableActive
	SELECT @Qry
	EXEC (@Qry)
END

SET @Qry = 'SELECT *
	    INTO ' + @FnlTableActive +
	   ' FROM Staging.Email_FreeLecture 
	    WHERE Adcode in (' + CONVERT(VARCHAR,@AdcodeActive) + ', ' + convert(varchar, isnull(@AdcodeCanada, 0)) + ', ' + convert(varchar, isnull(@AdcodeIntnl, 0)) + ')'

EXEC (@Qry)

/*- ALTER  Index on @FnlTable*/
DECLARE @FnlIndex VARCHAR(50)

SET @FnlIndex = 'IDX_' + REPLACE(@FnlTableActive,'Ecampaigns.dbo.','')

SELECT 'ALTER  Index'
SET @Qry = 'CREATE CLUSTERED INDEX ' + @FnlIndex + ' ON ' + @FnlTableActive + '(CustomerID)'
EXEC (@Qry)


/*- Drop if @FnlTablOthers already exists*/
IF (EXISTS (SELECT * FROM ecampaigns.INFORMATION_SCHEMA.TABLES        
			WHERE TABLE_CATALOG = 'ECampaigns'
			AND TABLE_SCHEMA = 'dbo'
			AND TABLE_NAME = REPLACE(@FnlTableOthers,'Ecampaigns.dbo.','')))
BEGIN
	SET @Qry = 'DROP TABLE ' + @FnlTableOthers
	SELECT @Qry
	EXEC (@Qry)
END


SET @Qry = 'SELECT *
	    INTO ' + @FnlTableOthers +
	   ' FROM Staging.Email_FreeLecture
	    WHERE Adcode not in (' + CONVERT(VARCHAR,@AdcodeActive) + ', ' + convert(varchar, isnull(@AdcodeCanada, 0)) + ', ' + convert(varchar, isnull(@AdcodeIntnl, 0)) + ')'

EXEC (@Qry)


/*- Create Index on @FnlTable*/


SET @FnlIndex = 'IDX_' + REPLACE(@FnlTableOthers,'Ecampaigns.dbo.','')

SELECT 'Create Index'
SET @Qry = 'CREATE CLUSTERED INDEX ' + @FnlIndex + ' ON ' + @FnlTableOthers + '(CustomerID)'
EXEC (@Qry)


IF @DeBugCode = 1 PRINT 'END Staging.CampaignEmail_FreeLecture'
GO
