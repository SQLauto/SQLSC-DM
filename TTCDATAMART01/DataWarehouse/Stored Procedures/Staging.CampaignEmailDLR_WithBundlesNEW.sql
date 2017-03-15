SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  PROC [Staging].[CampaignEmailDLR_WithBundlesNEW]
	@MailCatalogCode INT,
	@MoveInt INT = 1,
/*	@EmailCatalogCode INT,
	@EmailCatalogCodeSwamp INT = 8804,
	@EmailCatalogCodeInt INT = 8805,
	@EmailCatalogCodeInquirer INT = 8806,
	@EmailCatalogcodeNonRecip INT = 8807,	*/
	@FlagIntnl VARCHAR(5) = 'YES',
	@Test VARCHAR(5) = 'YES',
	@DeBugCode INT = 1
AS

/*- Proc Name: 	Ecampaigns.dbo.CampaignEmailDLR_WithBundles*/
/*- Purpose:	To generate Email List for Email Campaign*/
/*-		deadline reminder.*/
/*- Special Tables Used: MarketingDM.dbo.CampnPageAllocation*/
/*-			MarketingDM.dbo.ValidSubjCat*/
/*-			Ecampaigns.dbo.Ecampn02RankDLR_Bundle*/
/*-			Ecampaigns.dbo.Ecampn03Customer01DLRNew*/
/*-			Ecampaigns.dbo.Ecampn03Customer02_CourseDLR_Bundle*/
/*-			Ecampaigns.dbo.Ecampn04Customer_FinalDLR*/
/*- Updates:*/
/*- Name		Date		Comments*/
/*- Preethi Ramanujam 	1/15/2009	New*/


/*- Declare variables*/

DECLARE @ErrorMsg VARCHAR(400)   /*- Error message for error handling.*/
DECLARE @MailedAdcode INT
DECLARE @Qry VARCHAR(8000)

DECLARE @MaxCourse INT
SET @MaxCourse = 25

/*- Check to make sure CatalogCodes are provided by the user.*/
IF @DeBugCode = 1 PRINT 'Checking to make sure CatalogCodes are provided by the user'

IF @MailCatalogCode IS NULL
BEGIN	
	SET @ErrorMsg = 'Please provide CatalogCode for the Mail Piece'
	RAISERROR(@ErrorMsg,15,1)
	RETURN
END

/*- Check to make sure CatalogCodes Provided are correct.*/
IF @DeBugCode = 1 PRINT 'Checking to make sure CatalogCodes Provided are correct'

DECLARE @Count INT
SELECT @Count = COUNT(*)
FROM Staging.MktCatalogCodes
WHERE CatalogCode = @MailCatalogCode

IF @Count = 0
BEGIN	
	SET @ErrorMsg = 'CatalogCode ' + CONVERT(VARCHAR,@MailCatalogCode) + ' does not exist. Please Provide a valid Catalogcode for MailPiece'
	RAISERROR(@ErrorMsg,15,1)
	RETURN
END

SELECT @Count = COUNT(*)
FROM Mapping.DLREmail_MailedAdcodes
WHERE EmailDLRID = @MailCatalogCode

IF @Count = 0
BEGIN	
	SET @ErrorMsg = 'There are no rows found for EmailDLRID ' + CONVERT(VARCHAR,@MailCatalogCode) + '. Please update table Ecampaigns..DLREmail_MailedAdcodes and try again.'
	RAISERROR(@ErrorMsg,15,1)
	RETURN
END

/*- STEP1: Derive catalog data from Mail and Email AdCodes provided*/
IF @DeBugCode = 1 PRINT 'STEP1: Derive data based on Adcodes'

SELECT *
INTO #TempEmailAdcodes
FROM Mapping.DLREmail_MailedAdcodes
WHERE EmailDLRID = @MailCatalogCode

select * from #TempEmailAdcodes

/*- Derive Dropdate for the Email*/
DECLARE @DropDate DATETIME

SELECT @DropDate = StartDate
FROM Mapping.vwAdcodesAll
WHERE Adcode = (SELECT EmailAdcode
				FROM #TempEmailAdcodes
				WHERE Segment = 'ActiveControl')

IF @DropDate is null
	SELECT @DropDate = Convert(datetime,convert(varchar,getdate(),101))

IF @DeBugCode = 1 
   BEGIN
	PRINT 'DropDate = ' + CONVERT(VARCHAR,@DropDate,101)
   END

/*- Derive Dropdate for the Mail*/
DECLARE @MailDropDate DATETIME

SELECT @MailDropDate = StartDate
FROM Staging.MktCatalogCodes
WHERE CatalogCode = @MailCatalogCode

IF @DeBugCode = 1 PRINT 'MailDropDate = ' + CONVERT(VARCHAR,@MailDropDate,101)

/*- Generate  Final table name.*/
DECLARE @FnlTable VARCHAR(100)
DECLARE @FnlTable2 VARCHAR(100)

SELECT @FnlTable = 'ecampaigns.dbo.Email' + CONVERT(VARCHAR,@DropDate,112) + '_' + 'Offers' + REPLACE(REPLACE(Name,' ',''),'-','') + '_DLR'
FROM Staging.MktCatalogCodes
WHERE CatalogCode = @MailCatalogCode

/*
SELECT @FnlTable2 = 'ecampaigns..Email' + CONVERT(VARCHAR,@DropDate,112) + '_' + 'Offers' + REPLACE(REPLACE(Name,' ',''),'-','') + '_DLR'
FROM Staging.MktCatalogCodes
WHERE CatalogCode = @MailCatalogCode
*/

IF @DeBugCode = 1 PRINT 'Final Table Name = ' + @FnlTable
IF @DeBugCode = 1 PRINT 'Final Table Name = ' + @FnlTable2

DECLARE @FnlTableActive VARCHAR(100)
DECLARE @FnlTableSNI VARCHAR(100)

SET @FnlTableActive = @FnlTable + '_Active'
SET @FnlTableSNI = @FnlTable + '_SNI'

IF @DeBugCode = 1 
BEGIN
	PRINT 'Final Table for Actives = ' +  @FnlTableActive
	PRINT 'Final Table for SNI = ' + @FnlTableSNI
END

/*- Get Adcodes for the Email*/

DECLARE @AdcodeActive INT
DECLARE @AdcodeSwamp INT
DECLARE @AdcodeIntnl INT
DECLARE @AdcodeInq INT
DECLARE @AdcodeActiveNMR INT
DECLARE @AdcodeSwampNMR INT
DECLARE @AdcodeCanada INT

SELECT @AdcodeActive = EmailAdcode
FROM #TempEmailAdcodes
WHERE EmailDLRID = @MailCatalogCode
AND Segment LIKE '%ActiveControl%'

IF @AdcodeActive IS NULL
BEGIN
	SET @AdcodeActive = 9999999
	SET @ErrorMsg = 'No Adcode was found for Active Control. Using default adcode 99999 that needs to be udpated'
	RAISERROR(@ErrorMsg,15,1)
END


SELECT @AdcodeSwamp = EmailAdcode
FROM #TempEmailAdcodes
WHERE EmailDLRID = @MailCatalogCode
AND Segment LIKE '%SwampControl%'
	
	IF @AdcodeSwamp IS NULL
	   BEGIN
		PRINT '****WARNING**** AdcodeSwamp was not found. So, taking dummy adcode 8888'
		SET @AdcodeSwamp = 8888
	   END
	
SELECT @AdcodeIntnl = EmailAdcode
FROM #TempEmailAdcodes
WHERE EmailDLRID = @MailCatalogCode
AND Segment LIKE '%International%'
	
	IF @AdcodeIntnl IS NULL
	   BEGIN
		PRINT '****WARNING**** AdcodeIntnl was not found. So, taking dummy adcode 7777'			
		SET @AdcodeIntnl = 7777
	   END
	
SELECT @AdcodeInq = EmailAdcode
FROM #TempEmailAdcodes
WHERE EmailDLRID = @MailCatalogCode
AND Segment LIKE '%Inquirer%'
	
	IF @AdcodeInq IS NULL
	   BEGIN
		PRINT '****WARNING**** AdcodeInq was not found. So, taking dummy adcode 6666'
		SET @AdcodeInq = 6666
	   END

SELECT @AdcodeCanada = EmailAdcode
FROM #TempEmailAdcodes
WHERE EmailDLRID = @MailCatalogCode
AND Segment LIKE '%Canada%'

	IF @AdcodeCanada IS NULL
	   BEGIN
		PRINT '****WARNING**** AdcodeCanada was not found. So, taking dummy adcode 5555'			
		SET @AdcodeCanada = 5555
	   END
	
SELECT @AdcodeActiveNMR = EmailAdcode
FROM #TempEmailAdcodes
WHERE EmailDLRID = @MailCatalogCode
AND Segment LIKE '%ActiveNMR%'

	
	IF @AdcodeActiveNMR IS NULL
	   BEGIN
		PRINT '****WARNING**** AdcodeActiveNMR was not found. So, taking dummy adcode 4444'
		SET @AdcodeActiveNMR = 4444
	   END

SELECT @AdcodeSwampNMR = EmailAdcode
FROM #TempEmailAdcodes
WHERE EmailDLRID = @MailCatalogCode
AND Segment LIKE '%SwampNMR%'
	
	IF @AdcodeSwampNMR IS NULL
	   BEGIN
		PRINT '****WARNING**** AdcodeSwampNMR was not found. So, taking dummy adcode 3333'
		SET @AdcodeSwampNMR = 3333
	   END

IF @DeBugCode = 1 
BEGIN
	PRINT 'AdcodeActive = ' +  CONVERT(VARCHAR,@AdcodeActive) 
	PRINT 'AdcodeSwamp = ' + CONVERT(VARCHAR,@AdcodeSwamp) 
	PRINT 'AdcodeIntnl = ' + CONVERT(VARCHAR,@AdcodeIntnl)
	PRINT 'AdcodeInq = ' + CONVERT(VARCHAR,@AdcodeInq) 
	PRINT 'AdcodeActiveNMR = ' + CONVERT(VARCHAR,@AdcodeActiveNMR)
	PRINT 'AdcodeSwampNMR = ' + CONVERT(VARCHAR,@AdcodeSwampNMR)
	PRINT 'AdcodeCanada = ' + CONVERT(VARCHAR,@AdcodeCanada)	
END

/*- Derive the campaign ID*/
DECLARE @ECampaignIDActive VARCHAR(30)
DECLARE @ECampaignIDSNI VARCHAR(30), @ECampaignIDInq VARCHAR(30)

SELECT @ECampaignIDActive = 'EMAILDLRAct' + CONVERT(VARCHAR,@DropDate,112)
SELECT @ECampaignIDSNI = 'EMAILDLRSNI' + CONVERT(VARCHAR,@DropDate,112)
SELECT @ECampaignIDInq = 'EMAILDLRInq' + CONVERT(VARCHAR,@DropDate,112)


IF @DeBugCode = 1 
BEGIN
	PRINT 'ECampaignIDActive = ' +  CONVERT(VARCHAR,@ECampaignIDActive) 
	PRINT 'ECampaignIDSNI = ' + CONVERT(VARCHAR,@ECampaignIDSNI) 
	PRINT 'ECampaignIDInq = ' +  CONVERT(VARCHAR,@ECampaignIDInq)  
END


/*- Generate MailPiece, Primary subject and other information to generate appropriate SubjectLine*/
DECLARE @MailPiece VARCHAR(50)
DECLARE @PrimarySubject VARCHAR(5)
DECLARE @PrimarySubjectName VARCHAR(50)
DECLARE @CatalogName VARCHAR(50)

SELECT @MailPiece = Description
FROM Mapping.MktCampaign
WHERE CampaignID = (SELECT CampaignID
			FROM Staging.MktCatalogCodes
			WHERE CatalogCode = @MailCatalogCode)


SELECT DISTINCT 
	@CatalogName = REPLACE(Name,' ',''),
	@PrimarySubject = CASE WHEN LEFT(Name,CHARINDEX(' ',Name)-1) = 'LT' THEN 'LIT'
			       WHEN LEFT(Name,CHARINDEX(' ',Name)-1) = 'RG' THEN 'RL'
			       ELSE LEFT(Name,CHARINDEX(' ',Name)-1)
			  END
FROM Staging.MktCatalogCodes
WHERE CatalogCode = @MailCatalogCode

SELECT @PrimarySubjectName = SubjectDescription
FROM Mapping.ValidSubjCat
WHERE SubjectCategory = @PrimarySubject

IF @DebugCode = 1
   BEGIN
	SELECT 'MailPiece = ' + @MailPiece
	SELECT 'CatalogName = ' +  @CatalogName
	SELECT 'PrimarySubject = ' +  @PrimarySubject
	SELECT 'PrimarySubjectName = ' +  @PrimarySubjectName
   END
   
/*- Generate Subject line for the email.*/

DECLARE @SubjLine VARCHAR(400) /* Default SubjectLine*/
DECLARE @StopDate DATETIME
DECLARE @IntlSubjLine VARCHAR(200) /* varies based on Mailfile.*/

SELECT @StopDate = StopDate
FROM Mapping.vwAdcodesAll
WHERE Adcode = @AdcodeActive

IF @MailPiece LIKE 'Magalog%'
   BEGIN
	IF @PrimarySubject = 'NC' SET @IntlSubjLine = 'Special Offers On New Courses End This '
	ELSE IF @CatalogName LIKE 'HouseHS%'
	   BEGIN
		IF MONTH(@MailDropDate) < 8 SET @IntlSubjLine = 'Summer Sale on High School Courses Ends This '
		ELSE SET @IntlSubjLine = 'Fall Sale on High School Courses Ends This '
	   END
	ELSE SET @IntlSubjLine = 'Annual Sale on ' + @PrimarySubjectName + ' Courses Ends This '
   END
ELSE IF @MailPiece Like 'Newsletter%'
   BEGIN
	IF MONTH(@MailDropDate) < 8 SET @IntlSubjLine = 'Summer Sale on High School Courses Ends This '
	ELSE SET @IntlSubjLine = 'Fall Sale on High School Courses Ends This '
   END
ELSE
   BEGIN
	/*SET @IntlSubjLine = 'Special Offers End '*/
 	SET @IntlSubjLine = 'Special Offers End This '
   END


SELECT @SubjLine = @IntlSubjLine + DATENAME(DW,@StopDate) + ', ' + DATENAME(mm,@StopDate) + ' ' + CONVERT(VARCHAR,DATEPART(DAY,@StopDate))
FROM Mapping.vwAdcodesAll
WHERE Adcode = @AdcodeActive

DECLARE @SubjectLineActive VARCHAR(200)
SET @SubjectLineActive = @SubjLine
DECLARE @SubjectLineSwamp VARCHAR(200)
SET @SubjectLineSwamp = @SubjLine
DECLARE @SubjectLineIntnl VARCHAR(200)
SET @SubjectLineIntnl = @SubjLine

IF @DeBugCode = 1 
   BEGIN
	PRINT 'SubjectLineActive = ' +  @SubjectLineActive
	PRINT 'SubjectLineSwamp = ' + @SubjectLineSwamp
	PRINT 'SubjectLineIntnl = ' + @SubjectLineIntnl
   END

/*- Check to make sure Page allocation table is updated.*/
DECLARE @Counts INT

SELECT @Counts = COUNT(*)
FROM Mapping.CampnPageAllocation
WHERE CatalogCode = @MailCatalogCode

IF @Counts < 1
BEGIN
	SET @ErrorMsg = 'No rows found in table Marketing.CampnPageAllocation for catalog code ' + CONVERT(VARCHAR,@MailCatalogCode) + '. Please update the table and rerun the process.'
	RAISERROR(@ErrorMsg,15,1)
	RETURN
END

/*- STEP2: Obtain Sales of courses offered in the catalog by PreferredCategory */
/*- 	   of the customer FROM customersubjectmatrix table and assign Ranks based on sales*/

/*- Generate the list of courses and saleprices by PreferredCategory*/
IF @DeBugCode = 1 PRINT 'STEP2 BEGIN'
IF @DeBugCode = 1 PRINT 'Generate Ranks Table'

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn02RankDLR_Bundle')
	DROP TABLE Staging.Ecampn02RankDLR_Bundle

SELECT Sum(FNL.SumSales) AS SumSales,
	FNL.CourseID,
	FNL.PreferredCategory,
	CONVERT(FLOAT,0) AS Rank,
	Convert(tinyint,0) AS BundleFlag	
INTO Staging.Ecampn02RankDLR_Bundle
FROM	(SELECT sum(OI.SalesPrice) AS SumSales,
		ECL.Courseid AS CourseID,
		ISNULL(CSM.PreferredCategory2,'GEN') AS PreferredCategory
	FROM /*RFM..CustomerSubjectMatrix CSM JOIN*/
	       Marketing.CampaignCustomerSignature CSM JOIN /* Preethi Ramanujam	2/28/2008	Added Campaign Signature table instead of CSM for today's pull.*/
               Marketing.DMPurchaseOrders O  ON CSM.CUSTOMERID = O.CUSTOMERID JOIN
               Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
               Staging.MKTADCODES MA  ON O.ADCODE = MA.ADCODE   JOIN
               Staging.MKTCATALOGCODES MC ON MA.CATALOGCODE = MC.CATALOGCODE JOIN
               /*Ecampaigns.dbo.Ecampn01CourseList ECL*/
		Mapping.CampnPageAllocation ECL
            ON OI.CourseID = ECL.CourseiD /*and ECL.Courseid <>250*/
	WHERE O.DATEORDERED >='12/21/2005' 
	AND MC.CATALOGCODE IN (@MailCatalogCode)
	AND ECL.CatalogCode = (@MailCatalogCode)
 	AND ECL.BundleFlag <> 1
	GROUP BY ISNULL(CSM.PreferredCategory2,'GEN'), ECL.Courseid
	UNION
	/*- Courses and sales for the promotion without preferred category*/
	SELECT sum(OI.SalesPrice) AS SumSales,
			ECL.Courseid AS CourseID,
			'GEN' AS PreferredCategory
	FROM  Marketing.DMPurchaseOrders O JOIN
		Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
		Staging.MKTADCODES MA ON O.ADCODE = MA.ADCODE   JOIN
		Staging.MKTCATALOGCODES MC ON MA.CATALOGCODE = MC.CATALOGCODE JOIN
		/*Ecampaigns.dbo.Ecampn01CourseList ECL ON OI.CourseID = ECL.CourseiD and ECL.Courseid <>250*/
		Mapping.CampnPageAllocation ECL ON OI.CourseID = ECL.CourseiD /* and ECL.Courseid <>250*/
	WHERE O.DATEORDERED >='12/21/2005' 
	AND MC.CATALOGCODE in (@MailCatalogCode)
	AND ECL.CatalogCode = (@MailCatalogCode)
 	AND ECL.BundleFlag <> 1
	GROUP BY  ECL.Courseid)FNL
GROUP BY FNL.CourseID,FNL.PreferredCategory
/*ORDER BY 3,1 DESC*/
ORDER BY FNL.PreferredCategory, Sum(FNL.SumSales) DESC

/* Add Bundle sales*/
INSERT INTO Staging.Ecampn02RankDLR_Bundle
SELECT Sum(FNL.SumSales) AS SumSales,
	FNL.CourseID,
	FNL.PreferredCategory,
	CONVERT(FLOAT,0) AS Rank,
	Convert(tinyint,1) AS BundleFlag	
FROM	(SELECT sum(OI.SalesPrice) AS SumSales,
		ECL.Courseid AS CourseID,
		ISNULL(CSM.PreferredCategory2,'GEN') AS PreferredCategory
	FROM /*RFM..CustomerSubjectMatrix CSM JOIN*/
	       Marketing.CampaignCustomerSignature CSM JOIN /* Preethi Ramanujam	2/28/2008	Added Campaign Signature table instead of CSM for today's pull.*/
               Marketing.DMPurchaseOrders O  ON CSM.CUSTOMERID = O.CUSTOMERID JOIN
               Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
               Staging.MKTADCODES MA  ON O.ADCODE = MA.ADCODE   JOIN
               Staging.MKTCATALOGCODES MC ON MA.CATALOGCODE = MC.CATALOGCODE JOIN
               /*Ecampaigns.dbo.Ecampn01CourseList ECL*/
		Mapping.CampnPageAllocation ECL
            ON OI.BundleID = ECL.CourseiD /*and ECL.Courseid <>250*/
	WHERE O.DATEORDERED >='12/21/2005' 
	AND MC.CATALOGCODE IN (@MailCatalogCode)
	AND ECL.CatalogCode = (@MailCatalogCode)
 	AND ECL.BundleFlag = 1
	GROUP BY ISNULL(CSM.PreferredCategory2,'GEN'), ECL.Courseid
	UNION
	/*- Courses and sales for the promotion without preferred category*/
	SELECT sum(OI.SalesPrice) AS SumSales,
			ECL.Courseid AS CourseID,
			'GEN' AS PreferredCategory
	FROM  Marketing.DMPurchaseOrders O JOIN
		Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
		Staging.MKTADCODES MA ON O.ADCODE = MA.ADCODE   JOIN
		Staging.MKTCATALOGCODES MC ON MA.CATALOGCODE = MC.CATALOGCODE JOIN
		/*Ecampaigns.dbo.Ecampn01CourseList ECL ON OI.CourseID = ECL.CourseiD and ECL.Courseid <>250*/
		Mapping.CampnPageAllocation ECL ON OI.BundleID = ECL.CourseiD /* and ECL.Courseid <>250*/
	WHERE O.DATEORDERED >='12/21/2005' 
	AND MC.CATALOGCODE in (@MailCatalogCode)
	AND ECL.CatalogCode = (@MailCatalogCode)
 	AND ECL.BundleFlag = 1
	GROUP BY  ECL.Courseid)FNL
GROUP BY FNL.CourseID,FNL.PreferredCategory
/*ORDER BY 3,1 DESC*/
ORDER BY FNL.PreferredCategory, Sum(FNL.SumSales) DESC



/*- Remove Courses that are not on Sale in the catalog based on price matrix table*/

IF @DeBugCode = 1 PRINT 'Remove Courses that are not on Sale in the catalog based on price matrix table'

DELETE 
/*SELECT Distinct Courseid */
FROM Staging.Ecampn02RankDLR_Bundle
WHERE CourseID NOT IN
(SELECT DISTINCT ii.CourseID
FROM Staging.MktPricingMatrix mpm,
	Staging.InvItem ii,
	Mapping.DMCourse mc
WHERE mpm.UserstockItemID = ii.StockItemID
AND ii.CourseID = mc.CourseID
AND mpm.CatalogCode = @MailCatalogCode)



/*- Assign ranking based on Sales*/
IF @DeBugCode = 1 PRINT 'Assign Ranking Based on sales'

SET NOCOUNT ON

DECLARE @CourseID INT
DECLARE @SumSales MONEY
DECLARE @PrefCat VARCHAR(5)
/*- Declare First Cursor for PreferredCategory */
DECLARE MyCursor CURSOR
FOR
SELECT  DISTINCT PreferredCategory 
FROM Staging.Ecampn02RankDLR_Bundle
ORDER BY PreferredCategory DESC

/*- Begin First Cursor for PreferredCategory 			*/
OPEN MyCursor
FETCH NEXT FROM MyCursor INTO @PrefCat

SELECT @PrefCat
	
WHILE @@FETCH_STATUS = 0
	BEGIN
		/*- Declare Second Cursor for courses within the PreferredCategory*/
		DECLARE MyCursor2 CURSOR
		FOR
		SELECT CourseID, SumSales
		FROM Staging.Ecampn02RankDLR_Bundle
		WHERE PreferredCategory = @PrefCat
		ORDER BY SumSales DESC
		
		/*- BEGIN Second Cursor for courses within the PreferredCategory*/
		OPEN MyCursor2
		FETCH NEXT FROM MyCursor2 INTO @CourseID,@SumSales

		DECLARE @Rank FLOAT
		SET @Rank = CONVERT(FLOAT,1) 

		WHILE @@FETCH_STATUS = 0
		BEGIN
		/*- Assign rank based on sales for the course id within the PreferredCategory*/
			UPDATE Staging.Ecampn02RankDLR_Bundle
			SET Rank = @Rank
			WHERE PreferredCategory = @PrefCat
			AND CourseID = @CourseID 
			AND SumSales = @SumSales

			SET @Rank = @Rank + CONVERT(FLOAT,1)
			
			FETCH NEXT FROM MyCursor2 INTO @CourseID,@SumSales
		END
		CLOSE MyCursor2
		DEALLOCATE MyCursor2
		/*- END Second Cursor for courses within the PreferredCategory*/


		/*- Get the total number of courses for the given Catalog code.*/
		DECLARE @CourseCount INT
		SELECT @CourseCount = COUNT(*)
		FROM Mapping.CampnPageAllocation
		WHERE CatalogCode = @MailCatalogCode
		/*AND BundleFlag <> 1*/
		/*FROM Ecampaigns.dbo.Ecampn01CourseList*/

		/*- If there is no data available for courses under a particular*/
		/*- preferred category, append courses FROM 'GEN' category.*/

		IF @CourseCount >= @Rank  /*- If there are more courses that do not have ranks assigned yet..*/
		BEGIN
			IF @DeBugCode = 1 PRINT 'Inside IF statement - ' + CONVERT(VARCHAR,@Rank) + CONVERT(VARCHAR,@Coursecount)

			DECLARE @CourseID3 INT, @BundleFlag3 TINYINT
			DECLARE @SumSales3 MONEY
			/*- DECLARE Third Cursor for courses within the General Category*/
			DECLARE MyCursor3 CURSOR
			FOR
			SELECT DISTINCT CourseID,SumSales, BundleFlag
			FROM Staging.Ecampn02RankDLR_Bundle
			WHERE PreferredCategory = 'GEN'
			AND CourseID NOT IN (SELECT CourseID 
					       FROM Staging.Ecampn02RankDLR_Bundle
					       WHERE PreferredCategory = @PrefCat)
			ORDER BY SumSales DESC
			/*- Begin Third Cursor for courses within the General Category*/
			OPEN MyCursor3
			FETCH NEXT FROM MyCursor3 INTO @CourseID3,@SumSales3,@BundleFlag3

			WHILE @@FETCH_STATUS = 0
			BEGIN
				INSERT INTO Staging.Ecampn02RankDLR_Bundle
				SELECT @SumSales3,@CourseID3,@PrefCat,@Rank,@BundleFlag3
	
				SET @Rank = @Rank + CONVERT(FLOAT,1)
				
				FETCH NEXT FROM MyCursor3 INTO @CourseID3,@SumSales3,@BundleFlag3
			END
			CLOSE MyCursor3
			DEALLOCATE MyCursor3
			/*- End Third Cursor for courses within the General Category*/
		END


		FETCH NEXT FROM MyCursor INTO @PrefCat
	END
CLOSE MyCursor
DEALLOCATE MyCursor
/*- END First Cursor for PreferredCategory */

SET NOCOUNT OFF

/*- If Ranks are higher than 10 for New Courses, then float them up*/
IF @DeBugCode = 1 PRINT 'If Ranks are higher than 10 for New Courses, then float them up'

UPDATE ECR
/* SET ECR.Rank = ECR.Rank/2.1 -- regular*/
SET ECR.Rank = ECR.Rank/2.1
/*SELECT DISTINCT ECR.CourseID, ECR.Rank*/
FROM Staging.Ecampn02RankDLR_Bundle ECR,
	Mapping.DMCourse MC
WHERE ECR.CourseID = MC.CourseID
AND DATEDIFF(DAY, MC.ReleaseDate,@MailDropDate) < 7 /* Publish date usually is drop date of the first catalog that the course is featured in*/
AND RANK > 10


/* If Ranks are higher than 15, then float them up*/
IF @DeBugCode = 1 PRINT 'If Ranks are higher than 15 for Bundles, then float them up'
/* */
UPDATE ECR
SET ECR.Rank = ECR.Rank/3.21
/*SELECT DISTINCT ECR.CourseID, ECR.Rank, MC.CourseName*/
FROM Staging.Ecampn02RankDLR_Bundle ECR JOIN
	Mapping.DMCourse MC ON ECR.CourseID = MC.CourseID
WHERE RANK > 15
AND mc.Bundleflag = 1

/* If there are any cross over courses ranked < 4 then push them down for magalog/Magazine DLRs.*/
PRINT 'If there are any cross over courses ranked < 4 then push them down for magalog/Magazine DLRs.'

UPDATE A
SET A.Rank = A.Rank + 3.56
FROM Staging.Ecampn02RankDLR_Bundle A JOIN
	(SELECT *
	FROM Mapping.CampnPageAllocation
	WHERE CatalogCode = @MailCatalogCode
	AND SaleType in ('COMzn', 'COMaglg'))B on A.CourseID = B.CourseID
where a.rank < 4

--force 90% off courses higher in ranking for all customers
--UPDATE Staging.Ecampn02RankDLR_Bundle
--SET Rank = rank/8.2
--WHERE CourseID IN (805,807,8122,8593,8818,897,657,615,6537,6312,6457,611,4691,1295,1546,1557,327,893,2598,2429,2539,2353,4647,4652,4617,4413,4311,447,4244,4636)

/*- Report1: Ranking check report*/
PRINT 'Check Number of Courses in Ranking Table'

SELECT a.PreferredCategory, count(a.courseid) as coursecount
FROM Staging.Ecampn02RankDLR_Bundle a,
	Mapping.DMCourse b
WHERE a.CourseID = b.CourseID
group by a.PreferredCategory
ORDER BY a.PreferredCategory


PRINT 'Ranking QC Report'

SELECT a.Sumsales,a.CourseID,b.CourseName,a.PreferredCategory, a.Rank   
FROM Staging.Ecampn02RankDLR_Bundle a,
	Mapping.DMCourse b
WHERE a.CourseID = b.CourseID
ORDER BY a.PreferredCategory, a.Rank 

/* Delete courses ranked higher than 100*/
/* DELETE */
/* FROM Ecampaigns.dbo.Ecampn02RankDLR_Bundle*/
/* WHERE Rank > 100*/

/* If there are special courses, then change their ranking as desired.*/

/* UPDATE Ecampaigns.dbo.Ecampn02RankDLR_Bundle*/
/* SET Rank = Rank/2.56*/
/* where courseID IN (8500, 8050)*/
/* and rank > 15*/

/* Float Building Great Sentences to #1 rank*/
/* update Ecampaigns.dbo.Ecampn02RankDLR_Bundle */
/* set Rank = 0.5*/
/* where courseid = 2368*/



/*- STEP 3: Get the list of Emailable customers FROM the mailing history*/
/*-	    and CustomerSignature Table*/
IF @DeBugCode = 1 PRINT 'Begin STEP 3: Get the list of Emailable customers that received the Mail Piece'

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn03Customer01DLRNew')
	DROP TABLE Staging.Ecampn03Customer01DLRNew

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn03Customer01DLRNew_NMRDrops')
	DROP TABLE Staging.Ecampn03Customer01DLRNew_NMRDrops

SELECT ccs.Customerid,
	ccs.FirstName,
	ccs.LastName,
	ccs.EmailAddress,
	RLMail.ComboID,
	RLMail.Adcode AS MailedAdcode,
 	CASE WHEN RLmail.ActiveOrSwamp = 'Active' THEN @AdcodeActive
	     ELSE @AdcodeSwamp
	END AS AdCode,
	ccs.State AS Region, ccs.CountryCode,
	CASE WHEN RLmail.ActiveOrSwamp = 'Active' THEN @SubjectLineActive
	     ELSE @SubjectLineSwamp
	END  AS SubjectLine,
	ccs.PreferredCategory2 as PreferredCategory,
	CASE WHEN RLmail.ActiveOrSwamp = 'Active' THEN @ECampaignIDActive
	     ELSE @ECampaignIDSNI
	END AS ECampaignID,
	ccs.AH, ccs.EC, ccs.FA, ccs.HS, ccs.LIT, ccs.MH, ccs.PH, ccs.RL, ccs.SC,
	ccs.FW, ccs.PR
INTO Staging.Ecampn03Customer01DLRNew
FROM Marketing.CampaignCustomerSignature ccs,
	(SELECT DISTINCT MH.CustomerID, MH.ComboID, MH.Adcode,
		CASE WHEN MH.NewSeg BETWEEN 1 and 10 OR MH.NewSeg BETWEEN 13 AND 15 THEN 'Active'
		     WHEN MH.NewSeg BETWEEN 11 and 12 OR MH.NewSeg > 15 THEN 'Swamp'
		     ELSE MH.ComboID
		END AS ActiveOrSwamp
	FROM Archive.MailingHistory MH (nolock) JOIN
		(SELECT Distinct MailedAdcode
		FROM #TempEmailAdcodes
		WHERE EmailDLRID = @MailCatalogCode 
		and MailedAdcode > 0)MAC ON MH.Adcode = MAC.MailedAdcode
	WHERE ISNULL(FlagHoldOut,0) = 0)RLMail
WHERE ccs.CustomerID = RLMail.CustomerID
AND ccs.FlagEmail = 1
AND CCS.PublicLibrary = 0
AND CCS.COUNTRYCODE not in ('GB','AU')

/*- Check if the list was pulled*/
DECLARE @CountCheck INT

SELECT @CountCheck = COUNT(*)
FROM Staging.Ecampn03Customer01DLRNew


IF @CountCheck = 0
BEGIN	
	SET @ErrorMsg = 'No data found in table Staging.Ecampn03Customer01DLRNew. Make sure Mailing History table is updated'
	RAISERROR(@ErrorMsg,15,1)
	RETURN
END


/*Add Inquirers*/
IF @DeBugCode = 1 PRINT 'Add Inquirers'

IF @FlagIntnl = 'YES' 
   BEGIN
	INSERT INTO Staging.Ecampn03Customer01DLRNew
	(Customerid, FirstName, LastName, EmailAddress, ComboID, MailedAdcode, Adcode, 
	Region, CountryCode, SubjectLine, 	PreferredCategory, ECampaignID)
	SELECT CCS.CustomerID, Staging.proper(CCS.FirstName) FirstName,
		Staging.proper(CCS.LastName) LastName, CCS.EmailAddress, 
		CASE WHEN ccs.ComboID = '25-10000 Mo Inq Plus' or ccs.ComboID = 'Inq' 
											THEN '25-10000 Mo Inq'
		     ELSE CCS.ComboID
		END AS ComboID, 
		0 as MailedAdcode,
		@AdcodeInq as Adcode, 
		ISNULL(State,'') AS Region, CCS.CountryCode,
		@SubjectLineSwamp AS SubjectLine, 
		'GEN' AS PreferredCategory,
		@ECampaignIDInq AS ECampaignID
	FROM Marketing.CampaignCustomerSignature CCS LEFT OUTER JOIN
		Staging.Ecampn03Customer01DLRNew EC01 ON CCS.CustomerID = EC01.CustomerID
	WHERE EC01.CustomerID IS NULL AND ccs.Buyertype = 1 AND ccs.FlagEmail = 1 AND ccs.PublicLibrary = 0
	AND CCS.CountryCode like '%US%'
   END


/*- Add International folks to the list.*/

IF @FlagIntnl = 'YES' 
   BEGIN
	IF @DeBugCode = 1 PRINT 'Add International customers'
	
	INSERT INTO Staging.Ecampn03Customer01DLRNew
	(Customerid, FirstName, LastName, EmailAddress, ComboID, 
	MailedAdcode, Adcode, Region, CountryCode, SubjectLine, 
	PreferredCategory, ECampaignID)
	SELECT CCS.CustomerID,
		CCS.FirstName,
		CCS.LastName,
		CCS.EmailAddress,
		CCS.ComboID,
		0 as MailedAdcode,
		@AdcodeIntnl AS Adcode,
		'' AS Region, CCS.CountryCode,
		@SubjectLineIntnl AS SubjectLine,
		ccs.PreferredCategory2 as PreferredCategory,
		CASE WHEN CCS.CustomerSegment = 'Active' then @ECampaignIDActive
			ELSE @ECampaignIDSNI 
			END AS ECampaignID
	FROM Marketing.CampaignCustomerSignature CCS LEFT OUTER JOIN
		Staging.Ecampn03Customer01DLRNew EC01 ON CCS.CustomerID = EC01.CustomerID
	WHERE CCS.CountryCode NOT LIKE '%US%'
	AND CCS.CountryCode IS NOT NULL
	AND CCS.CountryCode <> ''
/* 	AND CCS.BuyerType > 1*/
	AND CCS.EmailAddress LIKE '%@%'
	AND CCS.FlagEmail = 1
	AND CCS.PublicLibrary = 0
	AND EC01.Customerid IS NULL
	AND CCS.CountryCode not in ('GB','AU')
   END
   
   
/* Delete UK customers*/
DELETE FROM Staging.Ecampn03Customer01DLRNew 
WHERE CountryCode in ('GB','AU')

DELETE A
FROM Staging.Ecampn03Customer01DLRNew A JOIN
	(SELECT * 
	FROM Marketing.CampaignCustomerSignature
	WHERE CountryCode in ('GB','AU'))B ON A.EmailAddress = B.EmailAddress
   
/* update Canada adcode*/

UPDATE  Staging.Ecampn03Customer01DLRNew
SET Adcode = @AdcodeCanada
WHERE Countrycode = 'CA'


/* Delete if there are still from AU*/
/*DELETE FROM Ecampaigns.dbo.Ecampn03Customer01DLRNew*/
/*WHERE CountryCode = 'AU'*/


DELETE A
from Staging.Ecampn03Customer01DLRNew a join
	(select * from marketing.campaigncustomersignature
	where countrycode = 'AU'
	and CustomerSince >= '9/1/2010')b on a.emailaddress = b.emailaddress


DELETE A
from Staging.Ecampn03Customer01DLRNew a join
	(select * from marketing.campaigncustomersignature
	where countrycode = 'AU'
	and CustomerSince >= '9/1/2010')b on a.CustomerID = b.CustomerID
	

/* Add Non Mail recipients*/
IF @FlagIntnl = 'YES' 

   BEGIN
	IF @DeBugCode = 1 PRINT 'Add Non Mail recipients'
	

	INSERT INTO Staging.Ecampn03Customer01DLRNew
	(Customerid, FirstName, LastName, EmailAddress, ComboID, MailedAdcode, 
	Adcode, Region, CountryCode, SubjectLine, 
	PreferredCategory, ECampaignID, AH, EC, FA, HS, LIT, MH, PH, RL, SC, FW, PR)
	select Distinct ccs.CustomerID, ccs.FirstName, ccs.LastName, ccs.EmailAddress,
		ccs.comboID, 0 as MailedAdcode,
		CASE WHEN CCS.CustomerSegment = 'Active' then @AdcodeActiveNMR
				else @AdcodeSwampNMR
			END as Adcode, CCS.State AS Region, CCS.CountryCode,
		@SubjectLineActive As SubjectLine,
		ccs.PreferredCategory2 as PreferredCategory, 
		Case when CCS.CustomerSegment = 'Active' then @ECampaignIDActive 
			else @ECampaignIDSNI
			end as EcampaignID,
		ccs.AH, ccs.EC, ccs.FA, ccs.HS, ccs.LIT, ccs.MH, ccs.PH, ccs.RL, ccs.SC,
		ccs.FW, ccs.PR
	from marketing.campaigncustomersignature ccs left outer join
		Staging.Ecampn03Customer01DLRNew EC01 on ccs.Customerid = EC01.CustomerID
	where EC01.Customerid is null 
	and flagemail = 1 and publiclibrary = 0
	and ccs.Countrycode like '%US%'

   END


/*- Delete Customers with duplicate EmailAddress*/
IF @DeBugCode = 1 PRINT 'Delete Customers with duplicate EmailAddress'

DECLARE @RowCount INT
SET @RowCount =1

WHILE @RowCount > 0
BEGIN
DELETE FROM Staging.Ecampn03Customer01DLRNew 
WHERE CustomerID IN (
		SELECT MIN(Customerid)
		FROM Staging.Ecampn03Customer01DLRNew 
		WHERE EmailAddress IN
				(SELECT EmailAddress
				FROM Staging.Ecampn03Customer01DLRNew
				GROUP BY EmailAddress
				HAVING COUNT(Customerid) > 1)
		GROUP BY EmailAddress)
SET @RowCount = @@ROWCOUNT
SELECT @RowCount
END



/* Delete customers that we do not want for this mailing.*/
/* Delete Swampers and Inquirers*/
/* Adcode      AdcodeName                                         CatalogCode */
/* ----------- -------------------------------------------------- ----------- */
/* 27838       Dummy Swamp Control                                8804*/
/* 27839       Dummy No Subj Pref                                 8804*/
/* 27840       Dummy International control                        8805*/
/* 27841       Dummy Inquirer place holder                        8806*/
/* 27842       Dummy WebInq place holder                          8806*/
/* 27843       Dummy Non Mail Recipients                          8807*/
/* 32109       Dummy Email CatCodeFor Active Control              9340*/
/* 9999999     Dummy Active	*/

/* PRINT 'Delete unwanted segments'*/
 /*DELETE FROM Ecampaigns.dbo.Ecampn03Customer01DLRNew*/
 /*WHERE Adcode IN (27841, 27840, 27842, 27843, 7777, 5555, 4444, 3333)*/

 
/* update other adcodes based on mailed adcode*/
UPDATE A
SET A.Adcode = B.EmailAdcode
FROM Staging.Ecampn03Customer01DLRNew A JOIN
	(select * from Mapping.DLREmail_MailedAdcodes
	where EmailDLRID = @MailCatalogCode
	and MailedAdcode > 0)B ON A.MailedAdcode = B.MailedAdcode

/*
UPDATE A
SET A.Adcode = B.EmailAdcode
FROM Staging.Ecampn03Customer01DLRNew A JOIN
	(select * from Mapping.DLREmail_MailedAdcodes
	where MailedAdcode > 0
	and Segment like '%Active%')B ON A.MailedAdcode = B.MailedAdcode
WHERE A.Adcode = @AdcodeActive


UPDATE A
SET A.Adcode = B.EmailAdcode
FROM Staging.Ecampn03Customer01DLRNew A JOIN
	(select * from Mapping.DLREmail_MailedAdcodes
	where MailedAdcode > 0
	and Segment like '%swamp%')B ON A.MailedAdcode = B.MailedAdcode
WHERE A.Adcode = @AdcodeSwamp
*/

UPDATE A
SET A.SubjectLine = B.SubjectLine
FROM Staging.Ecampn03Customer01DLRNew A JOIN
	Mapping.DLREmail_MailedAdcodes B ON A.MailedAdcode = B.MailedAdcode
								and A.Adcode = B.EmailAdcode


/* If they are non mail recipients that are not qualified for magalog, drop them*/
/*
If @MailPiece LIKE '%Magalog%' and @PrimarySubject <> 'NC'
   BEGIN
		DECLARE @QrySubject VARCHAR(100)
		DECLARE @PrimSubj VARCHAR(5)

		SET @Qry = ''
		SET @QrySubject = ''
		
		PRINT 'If they are non mail recipients that are not qualified for magalog, drop them'

		DECLARE MyCursor2 CURSOR FOR
		select PrimarySubjAbbr 
		FROM Mapping.SubjectCorrelation
		where CRSubjAbbr = @PrimarySubject
		and PrimarySubjAbbr <> 'REST'
		
			OPEN MyCursor2
			FETCH NEXT FROM MyCursor2 INTO @PrimSubj
				
			WHILE @@FETCH_STATUS = 0
				BEGIN

					IF @QrySubject = ''
						SET @QrySubject = @PrimSubj
					ELSE 
						SET @QrySubject = @QrySubject + ' + ' + @PrimSubj

					FETCH NEXT FROM MyCursor2 INTO @PrimSubj
				END

		CLOSE MyCursor2
		DEALLOCATE MyCursor2
		
		select @QrySubject	
		
		SET @Qry = 'SELECT *
					INTO  Staging.Ecampn03Customer01DLRNew_NMRDrops
					FROM Staging.Ecampn03Customer01DLRNew
					WHERE Adcode in (SELECT EmailAdcode
									FROM #TempEmailAdcodes
									where segment like ''%NMR%'')
					AND ' + @QrySubject + ' = 0'
					
		PRINT (@Qry)
		
		EXEC (@Qry)
		
		SET @Qry = 'DELETE FROM Staging.Ecampn03Customer01DLRNew
					WHERE Adcode in (SELECT EmailAdcode
									FROM #TempEmailAdcodes
									where segment like ''%NMR%'')
					AND ' + @QrySubject + ' = 0'
					
		PRINT (@Qry)
		
		EXEC (@Qry)	
		
		/* Generate QC Report*/
		SET @Qry = 'SELECT Adcode, ' + @QrySubject + ', COUNT(CustomerID)
					FROM Staging.Ecampn03Customer01DLRNew
					WHERE Adcode in (SELECT EmailAdcode
									FROM #TempEmailAdcodes
									where segment like ''%NMR%'')
					GROUP BY Adcode, ' + @QrySubject +
					' ORDER BY Adcode, ' + @QrySubject
	
					
		PRINT (@Qry)
		
		EXEC (@Qry)				
		
	END
*/
	
/* Drop Unsubscribes and other IDs that should not receive the emails.*/
exec Staging.CampaignEmail_RemoveUnsubs 'Ecampn03Customer01DLRNew'

/*- STEP 4: Assign Courses and Ranks to each customer based on their preferred category*/
IF @DeBugCode = 1 PRINT 'Begin Step 4: Assign Courses and Ranks to each customer based on their preferred category'

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn03Customer02_CourseDLR_Bundle')
	DROP TABLE Staging.Ecampn03Customer02_CourseDLR_Bundle

SELECT a.Customerid,
	a.FirstName,
	a.LastName,
	a.EmailAddress,
	a.ComboID,
	a.MailedAdcode,
	er.CourseID,
	er.Rank,
	a.Adcode,
	a.Region, a.CountryCode,
	a.SubjectLine,
	a.PreferredCategory,
	a.ECampaignID
INTO Staging.Ecampn03Customer02_CourseDLR_Bundle
FROM Staging.Ecampn03Customer01DLRNew a,
	Staging.Ecampn02RankDLR_Bundle er
WHERE ISNULL(a.PreferredCategory,'GEN') = er.PreferredCategory


CREATE CLUSTERED INDEX IDX_Ecampn03Customer02_CourseDLR_Bundle_Cust
ON Staging.Ecampn03Customer02_CourseDLR_Bundle (Customerid)

/* If we have multiple versions with few sets/courses in the mail, use this to remove some segments*/
/* */
 /*delete a*/
 /*from Ecampaigns.dbo.Ecampn03Customer02_CourseDLR_Bundle a join*/
 /*	(select distinct customerID*/
 /*	from rfm..mailinghistory*/
 /*	where adcode in (43177))b on a.customerid = b.customerID*/
 /*where a.courseid in (5183,1831,1528,5621,2181)*/
 
 /* if we want to remove the opposite*/
 /*delete a*/
 /*from Ecampaigns.dbo.Ecampn03Customer02_CourseDLR_Bundle a left outer join*/
 /*	(select distinct customerID*/
 /*	from rfm..mailinghistory*/
 /*	where adcode in (43177))b on a.customerid = b.customerID*/
 /*where b.customerid is null*/
 /*and a.courseid in (1462,9127,5576,3392)*/
 

/*- STEP 5: Remove the courses FROM the customer list if they have already purchased them.*/
IF @DeBugCode = 1 PRINT 'STEP 5: Remove the courses from the customer list if they have already purchased them'

DELETE a
/*SELECT a.* */
FROM Staging.Ecampn03Customer02_CourseDLR_Bundle a,
	(SELECT DISTINCT o.customerid, courseid
	FROM marketing.dmpurchaseorderitems oi
    join marketing.dmpurchaseorders o on o.OrderID = oi.OrderID
	WHERE stockitemid LIKE '[PD][ACDMV]%'
	AND courseid IN (SELECT DISTINCT courseid FROM Staging.Ecampn02RankDLR_Bundle))b
WHERE a.customerid=b.customerid
AND a.courseid=b.courseid

IF @DeBugCode = 1 PRINT 'STEP  5a: Remove Bundles from the customer list if they have already purchased courses from the bundle.'
/* DELETE a*/
/* -- Select a.**/
/* FROM Ecampaigns.dbo.Ecampn03Customer02_CourseDLR_Bundle100 a JOIN*/
/* 	(SELECT DISTINCT OI.customerid, OI.courseid, B.BundleID*/
/* 	FROM marketingdm.dbo.dmpurchaseorderitems OI JOIN*/
/* 		Ecampaigns.dbo.Ecampn02A_BundleCourse B ON OI.courseID = B.courseID*/
/* 	WHERE stockitemid LIKE '[PD][ACDMV]%')C on a.CourseID = C.BundleID*/


DECLARE @BundleIDRB INT
DECLARE MyCursorRB CURSOR FOR
SELECT Distinct CourseID
from Staging.Ecampn02RankDLR_Bundle
where bundleflag = 1

	OPEN MyCursorRB
	FETCH NEXT FROM MyCursorRB INTO @BundleIDRB
		
	WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT 'BundleID = ' + Convert(varchar,@BundleIDRB)

			delete a
			from Staging.Ecampn03Customer02_CourseDLR_Bundle a JOIN
				(select distinct customerid
				from Marketing.completecoursepurchase
				where courseid IN (SELECT Distinct CourseID
						FROM Mapping.BundleComponents
						WHERE BundleID = @BundleIDRB))b on a.customerid = b.customerid
			where a.CourseID = @BundleIDRB

			FETCH NEXT FROM MyCursorRB INTO @BundleIDRB
		END
	CLOSE MyCursorRB
	DEALLOCATE MyCursorRB




--float 90% Off courses higher in ranking for Aug reactivation 

--update a
--set A.rank = a.RANK/8.2
 --from DataWarehouse.Staging.Ecampn03Customer02_CourseDLR_Bundle a JOIN
 --	(select * from ecampaigns.dbo.Aug2012DLR_MailFile_90PctCrsDEL
 --	)b on a.customerid = b.customerID
--where a.courseid in (1474,6299,807,3588,168,4168,4855,2031)


--float these courses higher for swamp nmr 

--update a
--set A.rank = a.RANK/8.2
 --from DataWarehouse.Staging.Ecampn03Customer02_CourseDLR_Bundle a
--where a.courseid in (1474,6299,807,3588,168,4168,4855,2031) and a.adcode=69589

/*
-- Float 90% and 9.95 off courses highier in ranking for the recipients (same course list)
update a
set A.rank = a.RANK/8.2
 from DataWarehouse.Staging.Ecampn03Customer02_CourseDLR_Bundle a JOIN
 	(select * from ecampaigns..Email20120403_AprilMailFILE_DEL
 	where adcode in (64752,64756,64754))b on a.customerid = b.customerID
where a.courseid in (3174,158,6299,3588,4878,4855,7175)

-- Float Emp Pricing courses highier in ranking for the recipients
update a
set A.rank = a.RANK/8.2
 from DataWarehouse.Staging.Ecampn03Customer02_CourseDLR_Bundle a JOIN
 	(select * from ecampaigns..Email20120403_AprilMailFILE_DEL
 	where adcode in (64753))b on a.customerid = b.customerID
where a.courseid in (657,2390,2539,3588,3310,327,8593,877,443,1592,1235,780)
*/

/* STEP 6: SELECT Max Number of Courses FROM the list.*/
IF @DeBugCode = 1 PRINT 'STEP 6: Select Max Number of Courses From the list'

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn04Customer_FinalDLR')
	DROP TABLE Staging.Ecampn04Customer_FinalDLR

/*
CREATE TABLE Staging.Ecampn04Customer_FinalDLR
(Customerid udtCustomerID NOT NULL,
FirstName VARCHAR(50) NULL,
LastName VARCHAR(50) NULL,
EmailAddress VARCHAR(60) NULL,
ComboID VARCHAR(30) NULL,
MailedAdcode INT NULL,
CourseID INT NULL,
Rank FLOAT NULL,
Adcode INT NULL,
Region VARCHAR(40) NULL,
CountryCode VARCHAR(5) NULL,
SubjectLine VARCHAR(200) NULL,
PreferredCategory VARCHAR(5) NULL,
ECampaignID VARCHAR(30) NULL)
*/


IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn03Customer02_CourseDLR_Bundle2')
	DROP TABLE Staging.Ecampn03Customer02_CourseDLR_Bundle2
	
SELECT *, RANK() OVER (PARTITION BY customerid ORDER BY RANK) AS Rank2
INTO Staging.Ecampn03Customer02_CourseDLR_Bundle2
FROM Staging.Ecampn03Customer02_CourseDLR_Bundle

CREATE INDEX ix_Ecampn03Customer02_CourseDLR_Bundle21 on Staging.Ecampn03Customer02_CourseDLR_Bundle2 (Customerid)
CREATE INDEX ix_Ecampn03Customer02_CourseDLR_Bundle22 on Staging.Ecampn03Customer02_CourseDLR_Bundle2 (rank2)

SELECT t.Customerid, t.FirstName, t.LastName, t.EmailAddress, 
	t.ComboID, MailedAdcode, CourseID, Rank2 As Rank, Adcode, Region, t.CountryCode, 
	SubjectLine, t.PreferredCategory, ECampaignID,
	ccs.CustomerSegmentNew     
INTO Staging.Ecampn04Customer_FinalDLR    
FROM Staging.Ecampn03Customer02_CourseDLR_Bundle2 t (nolock)
left join Marketing.CampaignCustomerSignature ccs (nolock) on ccs.CustomerID = t.CustomerID
WHERE rank2 <= 25
	
/*SET NOCOUNT ON*/

/*IF @CourseCount > 25*/
/*   BEGIN*/
/*	DECLARE @CustID INT*/
/*	DECLARE MyCursor CURSOR FOR*/

/*	SELECT DISTINCT customerid */
/*	FROM Ecampaigns.dbo.Ecampn03Customer02_CourseDLR_Bundle*/
	
/*		OPEN MyCursor*/
/*		FETCH NEXT FROM MyCursor INTO @CustID*/
			
/*		WHILE @@FETCH_STATUS = 0*/
/*			BEGIN*/
/*				INSERT INTO Ecampaigns.dbo.Ecampn04Customer_FinalDLR*/
/*				SELECT TOP 25 * */
/*				FROM Ecampaigns.dbo.Ecampn03Customer02_CourseDLR_Bundle*/
/*				WHERE CustomerID = @CustID*/
/*				ORDER BY CustomerID, Rank, CourseID*/
/*				FETCH NEXT FROM MyCursor INTO @CustID*/
/*			END*/
/*		CLOSE MyCursor*/
/*		DEALLOCATE MyCursor*/
/*   END*/
/*ELSE*/
/*   BEGIN*/


/*	INSERT INTO Ecampaigns.dbo.Ecampn04Customer_FinalDLR*/
/*	SELECT * */
/*	FROM Ecampaigns.dbo.Ecampn03Customer02_CourseDLR_Bundle*/
/*   END*/

/* SET NOCOUNT ON*/
/* */
/* IF @CourseCount > @MaxCourse*/
/*    BEGIN*/
/* 	INSERT INTO Ecampaigns.dbo.Ecampn04Customer_FinalDLR*/
/* 	SELECT ECC.**/
/* 	FROM Ecampaigns.dbo.Ecampn03Customer02_CourseDLR_Bundle ECC JOIN*/
/* 	            (SELECT ECC1.CUSTOMERID, ECC1.RANK, */
/* 				SUM(CASE WHEN ECC2.RANK <= ECC1.RANK THEN 1 ELSE 0 END) SEQNUM */
/* 	             FROM Ecampaigns.dbo.Ecampn03Customer02_CourseDLR_Bundle ECC1 JOIN*/
/* 		             Ecampaigns.dbo.Ecampn03Customer02_CourseDLR_Bundle ECC2*/
/* 		            ON ECC1.CUSTOMERID = ECC2.CUSTOMERID*/
/* 	             GROUP BY ECC1.CUSTOMERID, ECC1.RANK) ECCSEQ ON ECCSEQ.CUSTOMERID = ECC.CUSTOMERID */
/* 		AND ECCSEQ.RANK = ECC.RANK AND ECCSEQ.SEQNUM <= 25 --@MaxCourse*/
/* 	ORDER BY ECC.CustomerID,  ECC.Rank*/
/*    END*/
/* ELSE*/
/*    BEGIN*/
/* 	INSERT INTO Ecampaigns.dbo.Ecampn04Customer_FinalDLR*/
/* 	SELECT * */
/* 	FROM Ecampaigns.dbo.Ecampn03Customer02_CourseDLR_Bundle*/
/*    END*/


CREATE CLUSTERED INDEX IDX_Ecampn04Customer_FinalDLR_cust
ON Staging.Ecampn04Customer_FinalDLR (Customerid)

/*- STEP 7: Delete customers having less than 5 courses to offer.*/
IF @DeBugCode = 1 PRINT 'STEP 7: Delete customers having less than 5 courses to offer'

DELETE FROM Staging.Ecampn04Customer_FinalDLR
WHERE CustomerID IN 
		(SELECT CustomerID
		FROM Staging.Ecampn04Customer_FinalDLR
		GROUP BY CustomerID
		HAVING COUNT(*) < 5)

/* For magalog deadline reminders, if there are cross over courses with rank <=3 then move them down*/
/* PRINT 'STEP 7b: If ranks are <= 3 for cross over courses in magalog, then move them down'*/
/* UPDATE A*/
/* SET A.Rank = A.Rank + 2.56*/
/* FROM Ecampaigns.dbo.Ecampn04Customer_FinalDLR A JOIN*/
/* 	(SELECT **/
/* 	FROM MarketingDM.dbo.CampnPageAllocation*/
/* 	WHERE CatalogCode = @MailCatalogCode*/
/* 	AND SaleType = 'COMaglg')B on A.CourseID = B.CourseID*/








/*- STEP 8: Generate Reports*/
IF @DeBugCode = 1 PRINT 'STEP 8: Generate Reports'

/*- Report1: Ranking check report*/

SELECT a.Sumsales,a.CourseID,b.CourseName,a.PreferredCategory, a.Rank   
FROM Staging.Ecampn02RankDLR_Bundle a,
	Mapping.DMCourse b
WHERE a.CourseID = b.CourseID
ORDER BY a.PreferredCategory, a.Rank 


/*- Report2: Counts by RFM Cells*/

/* SELECT rfc.SeqNum, rfc.ComboID, Count(Distinct CustomerID) AS CountOfCustomers*/
/* FROM MarketingDM.dbo.RFMForCatalogs rfc left outer join*/
/* */
/* 	Ecampaigns.dbo.Ecampn04Customer_FinalDLR Fnl on rfc.ComboID = Fnl.ComboID*/
/* WHERE rfc.MailPiece = 'Catalogs'*/
/* GROUP BY rfc.SeqNum, rfc.ComboID*/
/* ORDER BY rfc.SeqNum*/


/*SELECT csm.newseg,csm.name,rds.a12mf,COUNT(DISTINCT mct.customerid) AS CountOfCustomers
FROM Ecampaigns.dbo.Ecampn04Customer_FinalDLR mct,
	rfm..customersubjectmatrix csm,
	rfm..rfm_data_special rds
WHERE mct.customerid=csm.customerid
	and csm.customerid=rds.customerid
GROUP BY csm.newseg,csm.name,rds.a12mf
order by 1,2,3*/

/* --- Report3: Count by AdCode and SubjectLine*/
/* */
/* SELECT fnl.AdCode, mac.Name,*/
/* 	fnl.SubjectLine, fnl.ECampaignID,*/
/* 	COUNT(fnl.Customerid) AS TotalCount,*/
/* 	COUNT(DISTINCT fnl.Customerid) AS UniqueCustCount*/
/* FROM Ecampaigns.dbo.Ecampn04Customer_FinalDLR fnl LEFT OUTER JOIN*/
/* 	Superstardw.dbo.MktAdcodes mac ON fnl.adcode = mac.adcode*/
/* GROUP BY fnl.AdCode,  mac.Name,	fnl.SubjectLine, fnl.ECampaignID*/
/* ORDER BY fnl.AdCode*/
/* */
/* --- Generate Customer and Course information for Instruction files*/
/* */
/* SELECT DISTINCT c.customerid,d.firstname,d.lastname,c.PreferredCategory,c.adcode*/
/* FROM (SELECT MAX(DISTINCT a.customerid) AS customerid,*/
/* 		b.PreferredCategory,a.Adcode*/
/* 	FROM Ecampaigns.dbo.Ecampn04Customer_FinalDLR  a,*/
/* 		Ecampaigns.dbo.Ecampn03Customer01DLRNew b*/
/* 	WHERE a.customerid=b.customerid*/
/* 	GROUP BY b.PreferredCategory,a.Adcode)c,*/
/* 	Ecampaigns.dbo.Ecampn04Customer_FinalDLR d*/
/* WHERE c.customerid=d.customerid*/
/* ORDER BY c.adcode, c.PreferredCategory, c.customerid*/

SELECT DISTINCT a.CourseID, B.CourseName
FROM Staging.Ecampn02RankDLR_Bundle a JOIN
	Mapping.DMCourse b on a.Courseid = b.courseID


/*- Add Customer data to Email History Table  */

IF @Test = 'NO'
BEGIN
	IF @DeBugCode = 1 PRINT 'Add Customer data to Email History Table'
	INSERT INTO Ecampaigns..EmailHistory
	(CustomerID,Adcode,StartDate)
	SELECT Customerid,
		Adcode,
		@DropDate AS StartDate
	FROM Staging.Ecampn03Customer01DLRNew
END

/*- Create Final table*/
IF @DeBugCode = 1 PRINT 'Create Final Table'

/*- Drop if @FnlTabl already exists*/
DECLARE @RowCounts INT
SELECT @RowCounts = COUNT(*) FROM sysobjects
WHERE Name = @FnlTable
SELECT '@RowCounts = ' + CONVERT(VARCHAR,@RowCounts)

IF @RowCounts > 0
BEGIN
	SET @Qry = 'DROP TABLE Staging.' + @FnlTable
	SELECT @Qry
	EXEC (@Qry)
END


SET @Qry = 'SELECT *
	    INTO ' + @FnlTable +
	   ' FROM Staging.Ecampn04Customer_FinalDLR'

EXEC (@Qry)


/*- Final active table*/

IF (EXISTS (SELECT * FROM ecampaigns.INFORMATION_SCHEMA.TABLES        
            WHERE TABLE_CATALOG = 'ECampaigns'
            AND TABLE_SCHEMA = 'dbo'
            AND TABLE_NAME = REPLACE(@FnlTableActive,'Ecampaigns.dbo.','')))
	BEGIN
		SET @Qry = 'DROP TABLE Staging.' + @FnlTableActive
		SELECT @Qry
		EXEC (@Qry)
	END


SET @Qry = 'SELECT *
	    INTO ' + @FnlTableActive +
	   ' FROM Staging.Ecampn04Customer_FinalDLR 
	    WHERE Adcode in (SELECT Distinct EmailAdcode
						FROM #TempEmailAdcodes
						WHERE Segment like ''%Active%'')
		and not CustomerSegmentNew in (''NearInactives'',''NewCustLowValue'')'

EXEC (@Qry)

/*- Final SNI (Swamp, No Subj Pref, International) table*/

IF (EXISTS (SELECT * FROM ecampaigns.INFORMATION_SCHEMA.TABLES        
            WHERE TABLE_CATALOG = 'ECampaigns'
            AND TABLE_SCHEMA = 'dbo'
            AND TABLE_NAME = REPLACE(@FnlTableSNI,'Ecampaigns.dbo.','')))
BEGIN
	SET @Qry = 'DROP TABLE Staging.' + @FnlTableSNI
	SELECT @Qry
	EXEC (@Qry)
END


SET @Qry = 'SELECT *
	    INTO ' + @FnlTableSNI +
	   ' FROM Staging.Ecampn04Customer_FinalDLR 
	    WHERE Adcode not in (SELECT Distinct EmailAdcode
						FROM #TempEmailAdcodes
						WHERE Segment like ''%Active%'' or Segment in (''International'',''Canada''))
        or CustomerSegmentNew in (''NearInactives'',''NewCustLowValue'')'

EXEC (@Qry)


IF @MoveInt = 1 
  BEGIN
		SET @Qry = 'insert INTO ' + @FnlTableActive +
			   ' SELECT * FROM Staging.Ecampn04Customer_FinalDLR 
				WHERE Adcode in (SELECT Distinct EmailAdcode
								FROM #TempEmailAdcodes
								WHERE Segment in (''International'',''Canada''))'

		EXEC (@Qry)
  END

/*- Create Index on @FnlTable*/
DECLARE @FnlIndex VARCHAR(50)
DECLARE @FnlIndexActive VARCHAR(50)
DECLARE @FnlIndexSNI VARCHAR(50)

SET @FnlIndex = 'IDX_' + REPLACE(@FnlTable,'ecampaigns.dbo.','')
SET @FnlIndexActive = 'IDX_' + REPLACE(@FnlTableActive,'ecampaigns.dbo.','')
SET @FnlIndexSNI = 'IDX_' + REPLACE(@FnlTableSNI,'ecampaigns.dbo.','')

SELECT 'Create Index'
SET @Qry = 'CREATE CLUSTERED INDEX ' + @FnlIndex + ' ON ' + @FnlTable + '(CustomerID)'
EXEC (@Qry)
SET @Qry = 'CREATE CLUSTERED INDEX ' + @FnlIndexActive + ' ON ' + @FnlTableActive + '(CustomerID)'
EXEC (@Qry)
SET @Qry = 'CREATE CLUSTERED INDEX ' + @FnlIndexSNI + ' ON ' + @FnlTableSNI + '(CustomerID)'
EXEC (@Qry)


IF @DeBugCode = 1 PRINT 'Staging.CampaignEmailDLR_WithBundles'
GO
