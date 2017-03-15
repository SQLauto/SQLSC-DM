SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [Staging].[CampaignEmail_FvrtSubjNew_NonUS]
    @CountryCode char(2),    
	@EmailCatalogCode INT,
	@EmailCatalogCodeSwamp INT = 8804,
	@EmailCatalogCodeInt INT = 8805,
	@EmailCatalogCodeInquirer INT = 8806,
	@FlagIntnl VARCHAR(3) = 'YES',
	@Test VARCHAR(5) = 'YES',
	@DeBugCode INT = 1
AS

/*- Proc Name: 	Ecampaigns.dbo.CampaignEmail_FvrtSubj*/
/*- Purpose:	To generate Email List for Email Campaign*/
/*-		deadline reminder.*/
/*-		Prior to running the procedure, Price matrix should be*/
/*-		set up for the catalogcode and migrated to Datamart.*/
/*- Updates:*/
/*- Name		Date		Comments*/
/*- Preethi Ramanujam 	7/6/2007	New*/
/*- Preethi Ramanujam	9/21/2007	Added ECampaignID column for WebTrend Analysis Project*/
/*- Preethi Ramanujam	1/3/2008	Added separate Catalog code for Swampers*/

/*- Declare variables*/

DECLARE @ErrorMsg VARCHAR(400)   /*- Error message for error handling.*/

DECLARE @MaxCourse INT
SET @MaxCourse = 25

/*- Check to make sure CatalogCodes are provided by the user.*/
IF @DeBugCode = 1 PRINT 'Checking to make sure CatalogCodes are provided by the user'


IF @EmailCatalogCode IS NULL
BEGIN	
	/* Check if we can get the DL control version of catalogcode *****/
	SET @ErrorMsg = 'Please provide CatalogCode for the Email Piece'
	RAISERROR(@ErrorMsg,15,1)
	RETURN
END

/*- Check to make sure CatalogCodes Provided are correct.*/
IF @DeBugCode = 1 PRINT 'Checking to make sure CatalogCodes Provided are correct'

DECLARE @Count INT


SELECT @Count = COUNT(*)
FROM Staging.MktCatalogCodes
WHERE CatalogCode = @EmailCatalogCode

IF @Count = 0
BEGIN	
	SET @ErrorMsg = 'CatalogCode ' + CONVERT(VARCHAR,@EmailCatalogCode) + ' does not exist. Please Provide a valid Catalogcode for Email'
	RAISERROR(@ErrorMsg,15,1)
	RETURN
END

IF @EmailCatalogCodeSwamp <> 8804
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

IF @EmailCatalogCodeInt <> 8805
   BEGIN
	SELECT @Count = COUNT(*)
	FROM Staging.MktCatalogCodes
	WHERE CatalogCode = @EmailCatalogCodeInt
	
	IF @Count = 0
	BEGIN	
		SET @ErrorMsg = 'CatalogCode ' + CONVERT(VARCHAR,@EmailCatalogCodeInt) + ' does not exist. Please Provide a valid Catalogcode for Email'
		RAISERROR(@ErrorMsg,15,1)
		RETURN
	END
   END

IF @EmailCatalogCodeInquirer <> 8806
   BEGIN
	SELECT @Count = COUNT(*)
	FROM Staging.MktCatalogCodes
	WHERE CatalogCode = @EmailCatalogCodeInquirer
	
	IF @Count = 0
	BEGIN	
		SET @ErrorMsg = 'CatalogCode ' + CONVERT(VARCHAR,@EmailCatalogCodeInquirer) + ' does not exist. Please Provide a valid Catalogcode for Email'
		RAISERROR(@ErrorMsg,15,1)
		RETURN
	END
   END


/*- STEP1: Derive catalog data from Mail and Email Catalog codes provided*/
IF @DeBugCode = 1 PRINT 'STEP1: Derive data based on CatalogCodes'

/*- Derive Dropdate for the Email*/
DECLARE @DropDate DATETIME
DECLARE @DropDateSNI DATETIME

IF @EMailCatalogCodeSwamp <> 8804
  BEGIN
	SELECT @DropDate = StartDate
	FROM Staging.MktCatalogCodes
	WHERE CatalogCode = @EMailCatalogCode

	SELECT @DropDateSNI = StartDate
	FROM Staging.MktCatalogCodes
	WHERE CatalogCode = @EMailCatalogCodeSwamp
  END
ELSE
  BEGIN
	SELECT @DropDate = StartDate,
		@DropDateSNI = StartDate
	FROM Staging.MktCatalogCodes
	WHERE CatalogCode = @EMailCatalogCode
  END

IF @DeBugCode = 1 
   BEGIN
	PRINT 'DropDate = ' + CONVERT(VARCHAR,@DropDate,101)
	PRINT 'DropDateSNI = ' + CONVERT(VARCHAR,@DropDateSNI,101)
   END


/*- Derive  Final table name.*/
DECLARE @FnlTable VARCHAR(100)
DECLARE @FnlTableSNI1 VARCHAR(100)

SELECT @FnlTable = 'Ecampaigns.dbo.Email' + CONVERT(VARCHAR,@DropDate,112) + '_Offers_' + @CountryCode + '_FvrtSbjct'
/* SELECT @FnlTable = 'Email' + CONVERT(VARCHAR,@DropDate,112) + '_' + 'Offers_FSDwnlds'*/
FROM Staging.MktCatalogCodes
WHERE CatalogCode = @EmailCatalogCode

SELECT @FnlTableSNI1 = 'Ecampaigns.dbo.Email' + CONVERT(VARCHAR,@DropDateSNI,112) + '_Offers_' + @CountryCode + '_FvrtSbjct'
/* SELECT @FnlTableSNI1 = 'Email' + CONVERT(VARCHAR,@DropDateSNI,112) + '_' + 'Offers_FSDwnlds'*/
FROM Staging.MktCatalogCodes
WHERE CatalogCode = @EmailCatalogCode

DECLARE @FnlTableActive VARCHAR(100)
DECLARE @FnlTableSNI VARCHAR(100)

--SELECT @FnlTableActive = 'Ecampaigns.dbo.' + @FnlTable + '_Active'
--SELECT @FnlTableSNI = 'Ecampaigns.dbo.' + @FnlTableSNI1 + '_SNI'

IF @DeBugCode = 1 
BEGIN
	PRINT 'Final Table Name = ' + @FnlTable
	PRINT 'Final Active Table Name = ' + @FnlTableActive
	PRINT 'Final SNI Table Name = ' + @FnlTableSNI
END

/*- Get Adcodes for the Email*/

DECLARE @AdcodeActive INT
DECLARE @AdcodeSwamp INT
DECLARE @AdcodeIntnl INT
DECLARE @AdcodeNoSubjPref INT
DECLARE @AdcodeInq INT
DECLARE @AdcodeWebInq INT
DECLARE @AdcodeNonRecip INT

SELECT @AdcodeActive = Adcode
FROM Staging.MktAdcodes
WHERE CatalogCode = @EmailCatalogCode
AND UPPER(Name) LIKE '%ACTIVE CONTROL%'

IF @AdcodeActive IS NULL
BEGIN
	SET @AdcodeActive = 9999999
	SET @ErrorMsg = 'No Adcode was found for CatalogCode ' + CONVERT(VARCHAR,@EmailCatalogCode) + '. Using default adcode 99999 that needs to be udpated'
	RAISERROR(@ErrorMsg,15,1)
END


	SELECT @AdcodeSwamp = Adcode
	FROM Staging.MktAdcodes
	WHERE CatalogCode IN (@EmailCatalogCode, @EmailCatalogCodeSwamp) 
	AND UPPER(Name) LIKE '%SWAMP CONTROL%'
	
	IF @AdcodeSwamp IS NULL
	   BEGIN
		PRINT '****WARNING**** AdcodeSwamp was not found. So, adding one to the AdcodeActive'
		SET @AdcodeSwamp = 8888
	   END
	
	SELECT @AdcodeIntnl =  Adcode
	FROM Staging.MktAdcodes
	WHERE CatalogCode IN (@EmailCatalogCode, @EmailCatalogCodeSwamp, @EmailCatalogCodeInt)
	AND UPPER(Name) LIKE '%INTERNATIONAL%'  /* CONTROL'*/
	
	IF @AdcodeIntnl IS NULL
	   BEGIN
		PRINT '****WARNING**** AdcodeIntnl was not found. So, adding two to the AdcodeActive'			SET @AdcodeIntnl = 7777
	   END
	
	SELECT @AdcodeNoSubjPref =  Adcode
	FROM Staging.MktAdcodes
	WHERE CatalogCode IN (@EmailCatalogCode, @EmailCatalogCodeSwamp, @EmailCatalogCodeInt)
	AND UPPER(Name) LIKE '%NO SUBJ PREF%' /*CONTROL'*/
	
	IF @AdcodeNoSubjPref IS NULL
	   BEGIN
		PRINT '****WARNING**** AdcodeNoSubjPref was not found. So, adding three to the AdcodeActive'
		SET @AdcodeNoSubjPref = 6666
	   END

	SELECT @AdcodeInq =  Adcode
	FROM Staging.MktAdcodes
	WHERE CatalogCode IN (@EmailCatalogCode, @EmailCatalogCodeSwamp, @EmailCatalogCodeInt, @EmailCatalogCodeInquirer)
	AND UPPER(Name) LIKE '%Inquirer%'  /* CONTROL'*/
	
	IF @AdcodeInq IS NULL
	   BEGIN
		PRINT '****WARNING**** Inquirer was not found. So, adding two to the AdcodeActive'			
		SET @AdcodeInq = 5555
	   END
	
	SELECT @AdcodeWebInq =  Adcode
	FROM Staging.MktAdcodes
	WHERE CatalogCode IN (@EmailCatalogCode, @EmailCatalogCodeSwamp, @EmailCatalogCodeInt, @EmailCatalogCodeInquirer)
	AND UPPER(Name) LIKE '%WebInq%' /*CONTROL'*/
	
	IF @AdcodeWebInq IS NULL
	   BEGIN
		PRINT '****WARNING**** AdcodeWebInq was not found. So, adding three to the AdcodeActive'
		SET @AdcodeWebInq = 4444

	   END


IF @DeBugCode = 1 
BEGIN
	PRINT 'AdcodeActive = ' +  CONVERT(VARCHAR,@AdcodeActive) 
	PRINT 'AdcodeSwamp = ' + CONVERT(VARCHAR,@AdcodeSwamp)
	PRINT 'AdcodeInq = ' + CONVERT(VARCHAR,@AdcodeInq)

END

/*- Derive the campaign ID  -- PR 9/21/2007*/
DECLARE @ECampaignIDActive VARCHAR(30)
DECLARE @ECampaignIDSwamp VARCHAR(30)
DECLARE @ECampaignIDInq VARCHAR(30)
DECLARE @ECampaignIDWebInq VARCHAR(30)

SELECT @ECampaignIDActive = 'EMAIL_UK_FavSubj' + CONVERT(VARCHAR,@DropDate,112) + '_' + CONVERT(VARCHAR,@AdcodeActive)
SELECT @ECampaignIDSwamp = 'FSSNI' + CONVERT(VARCHAR,@DropDateSNI,112) + '_' + CONVERT(VARCHAR,@AdcodeSwamp)
SELECT @ECampaignIDInq = 'FSInq' + CONVERT(VARCHAR,@DropDateSNI,112) + '_' + CONVERT(VARCHAR,@AdcodeInq)

IF @DeBugCode = 1 
   BEGIN
	PRINT 'CampaignID for Actives= ' + @ECampaignIDActive
	PRINT 'CampaignID for Swamp = ' + @ECampaignIDSwamp
	PRINT 'CampaignID for Inquriers = ' + @ECampaignIDInq
   END

/*- Generate Subject line for the email.*/

DECLARE @SubjLine VARCHAR(400) /* Default SubjectLine*/
DECLARE @StopDate DATETIME

SELECT @StopDate = StopDate
FROM Staging.MktCatalogCodes
WHERE CatalogCode = @EMailCatalogCode

/*SELECT @SubjLine = 'Special Offers End This ' + DATENAME(DW,@StopDate) + ', ' + DATENAME(mm,@StopDate) + ' ' + CONVERT(VARCHAR,DATEPART(DAY,@StopDate))
FROM Superstardw.dbo.MktCatalogCodes
WHERE CatalogCode = @EMailCatalogCode*/

SELECT @SubjLine = 'A Special Offer on Your Favorite Subjects'

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

/*- STEP2: Obtain Sales of courses offered in the catalog by PreferredCategory */
/*- 	   of the customer FROM customersubjectmatrix table and assign Ranks based on sales*/

/*- Generate the list of courses and saleprices by PreferredCategory*/
IF @DeBugCode = 1 PRINT 'STEP2 BEGIN'
IF @DeBugCode = 1 PRINT 'Generate Ranks Table'

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn02Rank')
	DROP TABLE Staging.Ecampn02Rank

SELECT Sum(FNL.SumSales) AS SumSales,
	FNL.CourseID,
	FNL.PreferredCategory,
	CONVERT(FLOAT,0) AS Rank
INTO Staging.Ecampn02Rank
FROM	(SELECT sum(OI.SalesPrice) AS SumSales,
			II.Courseid AS CourseID,
			'GEN' AS PreferredCategory
	FROM  Marketing.DMPurchaseOrders O JOIN
		Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
		Staging.InvItem II ON OI.StockItemID = II.StockItemID LEFT OUTER JOIN
		Staging.MktPricingMatrix MPM ON MPM.UserStockItemID = II.StockItemID	
	WHERE O.DATEORDERED BETWEEN DATEADD(Month,-6,GETDATE()) AND GETDATE()
	AND O.SequenceNum > 1
	AND MPM.CatalogCode = (@EmailCatalogCode)
	GROUP BY  II.Courseid
	UNION
	SELECT sum(OI.SalesPrice) AS SumSales,
		II.Courseid AS CourseID,
		ISNULL(CSM.PreferredCategory2,'GEN') AS PreferredCategory
	FROM /*RFM..CustomerSubjectMatrix CSM JOIN*/
		Marketing.CampaignCustomerSignature CSM JOIN
               Marketing.DMPurchaseOrders O  ON CSM.CUSTOMERID = O.CUSTOMERID JOIN
               Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
		Staging.InvItem II ON OI.StockItemID = II.StockItemID LEFT OUTER JOIN
		Staging.MktPricingMatrix MPM ON MPM.UserStockItemID = II.StockItemID
	WHERE O.DATEORDERED BETWEEN DATEADD(Month,-6,GETDATE()) AND GETDATE()
	AND O.SequenceNum > 1
	AND MPM.CatalogCode = (@EmailCatalogCode)
	AND CSM.PreferredCategory2 is not null
	GROUP BY CSM.PREFERREDCATEGORY2, II.Courseid)FNL
GROUP BY FNL.CourseID,FNL.PreferredCategory
ORDER BY FNL.PreferredCategory,Sum(FNL.SumSales) DESC

/*- Assign ranking based on Sales*/
IF @DeBugCode = 1 PRINT 'Assign Ranking Based on sales'

DECLARE @CourseID INT
DECLARE @SumSales MONEY
DECLARE @PrefCat VARCHAR(5)
/*- Declare First Cursor for PreferredCategory */
DECLARE MyCursor CURSOR
FOR
SELECT  DISTINCT PreferredCategory 
FROM Staging.Ecampn02Rank
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
		FROM Staging.Ecampn02Rank
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
			UPDATE Staging.Ecampn02Rank
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

		SELECT @CourseCount = COUNT(DISTINCT II.CourseID)
		FROM Staging.MktPricingMatrix MPM JOIN
			Staging.InvItem II ON MPM.UserStockItemID = II.StockItemID
		WHERE MPM.CatalogCode = @EmailCatalogCode

		/*FROM Ecampaigns.dbo.Ecampn01CourseList*/

		/*- If there is no data available for courses under a particular*/
		/*- preferred category, append courses FROM 'GEN' category.*/

		IF @CourseCount >= @Rank  /*- If there are more courses that do not have ranks assigned yet..*/
		BEGIN
			IF @DeBugCode = 1 PRINT 'Inside IF statement - ' + CONVERT(VARCHAR,@Rank) + CONVERT(VARCHAR,@Coursecount)

			DECLARE @CourseID3 INT
			DECLARE @SumSales3 MONEY
			/*- DECLARE Third Cursor for courses within the General Category*/
			DECLARE MyCursor3 CURSOR
			FOR
			SELECT DISTINCT CourseID,SumSales
			FROM Staging.Ecampn02Rank
			WHERE PreferredCategory = 'GEN'
			AND CourseID NOT IN (SELECT CourseID 
					       FROM Staging.Ecampn02Rank
					       WHERE PreferredCategory = @PrefCat)
			ORDER BY SumSales DESC
			/*- Begin Third Cursor for courses within the General Category*/
			OPEN MyCursor3
			FETCH NEXT FROM MyCursor3 INTO @CourseID3,@SumSales3

			WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @SumSales3,@CourseID3,@PrefCat,@Rank
				INSERT INTO Staging.Ecampn02Rank
				SELECT @SumSales3,@CourseID3,@PrefCat,@Rank
	
				SET @Rank = @Rank + CONVERT(FLOAT,1)
				
				FETCH NEXT FROM MyCursor3 INTO @CourseID3,@SumSales3
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

/* Force ranks for some courses to top*/

/* UPDATE Ecampaigns.dbo.Ecampn02Rank*/
/* SET Rank = case when rank between 15 and 19 then Rank/1.56*/
/* 		when rank between 20 and 50 then rank/2.56*/
/* 		when rank between 50 and 75 then rank/3.56*/
/* 		when rank between 76 and 100 then rank/4.568*/
/* 		when rank>100 then rank/5.89*/
/* 		else rank*/
/* 	end */
/* WHERE CourseID IN (1830,1426,7158,4242,3480,6450,5620,2270,8598,3430,2180, 1447, 1527, 8818, 5665)*/
/* -- and rank > 10*/
/* */
/* UPDATE Ecampaigns.dbo.Ecampn02Rank*/
/* SET Rank = case when rank > 10 then rank/2.56*/
/* 		else rank*/
/* 	end */
/* WHERE CourseID IN (3310,5932,2527)*/
/* */
/**/
/*UPDATE Ecampaigns.dbo.Ecampn02Rank*/
/*SET Rank = case when rank > 10 then rank/1.546*/
/*		when rank > 20 then rank/2.123*/
/*		when rank > 30 then rank/4.789*/
/*		else rank*/
/*	end */
/*-- SET Rank = rank/2.12*/
/*WHERE CourseID IN (8510,4670,1557)*/
 
 
--UPDATE Staging.Ecampn02Rank
--SET Rank = rank/3.5
--WHERE CourseID IN (3231,5657,5610)

/*- Report1: Ranking check report*/

SELECT a.Sumsales,a.CourseID,b.CourseName,a.PreferredCategory, a.Rank   
FROM Staging.Ecampn02Rank a,
	Mapping.DMCourse b
WHERE a.CourseID = b.CourseID
ORDER BY a.PreferredCategory, a.Rank

/* delete courses ranked higher than 100 to save time*/
delete from Staging.Ecampn02Rank
where rank > 80


/* update prefcat to secondary subject for customers in the signature table*/

/*update a*/
/*set a.PreferredCategory2 = b.secondarysubjpref*/
/*from Marketingdm..campaigncustomersignature a join*/
/*	MarketingDM..TempCustomerDynamicCourseRank b on a.customerid = b.customerid*/

/*- STEP 3: Get the list of Emailable customers from the CustomerSignature Table*/
IF @DeBugCode = 1 PRINT 'Begin STEP 3: Get the list of Emailable customers that should receive Favorite Subject Email.'

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn03Customer01')
	DROP TABLE Staging.Ecampn03Customer01

SELECT ccs.Customerid,
	ccs.FirstName,
	ccs.LastName,
	ccs.EmailAddress,
	ccs.ComboID,
 	@AdcodeActive AS AdCode,
	ccs.State AS Region, ccs.CountryCode,
	@SubjectLineActive AS SubjectLine,
	CASE WHEN ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'SC' then 'SCI'
		when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'FA' then 'VA'
		when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory NOT IN ('SC','FA') then ccs.preferredcategory
		else ccs.PreferredCategory2 
	END as PreferredCategory,
/* 	ccs.PreferredCategory2 as PreferredCategory,*/
	@ECampaignIDActive AS ECampaignID
INTO Staging.Ecampn03Customer01
FROM Marketing.CampaignCustomerSignature ccs
WHERE ccs.FlagEmail = 1 AND EmailAddress LIKE '%@%'
AND ccs.PublicLibrary = 0
AND CCS.COUNTRYCODE = @CountryCode

CREATE CLUSTERED INDEX IDX_customer_Ecamp03Cust01
ON Staging.Ecampn03Customer01 (Customerid)

/*- Delete Customers with duplicate EmailAddress*/
IF @DeBugCode = 1 PRINT 'Delete Customers with duplicate EmailAddress'

DECLARE @RowCount INT
SET @RowCount =1

WHILE @RowCount > 0
BEGIN
DELETE FROM Staging.Ecampn03Customer01 
WHERE CustomerID IN (
		SELECT MIN(Customerid)
		FROM Staging.Ecampn03Customer01 
		WHERE EmailAddress IN
				(SELECT EmailAddress
				FROM Staging.Ecampn03Customer01
				GROUP BY EmailAddress
				HAVING COUNT(Customerid) > 1)
		GROUP BY EmailAddress)
SET @RowCount = @@ROWCOUNT
SELECT @RowCount
END

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
/* DELETE FROM Ecampaigns.dbo.Ecampn03Customer01*/
/* WHERE Adcode IN (9999999, 27840, 6666, 27841)*/

/*- STEP 4: Assign Courses and Ranks to each customer based on their preferred category*/
IF @DeBugCode = 1 PRINT 'Begin Step 4: Assign Courses and Ranks to each customer based on their preferred category'

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn03Customer02_Course')
	DROP TABLE Staging.Ecampn03Customer02_Course

SELECT a.Customerid,
	a.FirstName,
	a.LastName,
	a.EmailAddress,
	a.ComboID,
	er.CourseID,
	er.Rank,
	a.Adcode,
	a.Region,
	a.CountryCode,
	a.SubjectLine,
	a.PreferredCategory,
	a.EcampaignID
INTO Staging.Ecampn03Customer02_Course
FROM Staging.Ecampn03Customer01 a,
	Staging.Ecampn02Rank er
WHERE ISNULL(a.PreferredCategory,'GEN') = er.PreferredCategory


CREATE CLUSTERED INDEX IDX_customer_Ecamp03Cust02
ON Staging.Ecampn03Customer02_Course (Customerid)

/*- STEP 5: Remove the courses FROM the customer list if they have already purchased them.*/
IF @DeBugCode = 1 PRINT 'STEP 5: Remove the courses from the customer list if they have already purchased them'

DELETE a
/*SELECT a.* */
FROM Staging.Ecampn03Customer02_Course a,
	(SELECT DISTINCT o.customerid, courseid
	FROM marketing.dmpurchaseorderitems oi
    join Marketing.DMPurchaseOrders o on o.OrderID = oi.OrderID
	WHERE stockitemid LIKE '[PD][ACDMV]%'
	AND courseid IN (SELECT DISTINCT courseid FROM Staging.Ecampn02Rank))b
WHERE a.customerid=b.customerid
AND a.courseid=b.courseid

/*remove jan prospect reactivation courses from the customer group 01/14/2010 - Sri*/
/*delete a*/
/*from Ecampaigns.dbo.Ecampn03Customer02_Course a*/
/*join lstmgr.dbo.Email_20100112_JanReact2010Prospect_DLR_SNI_1 b*/
/*on a.customerid=b.customerid where*/
/*a.courseid in (350,340,345,370,8267,5620,8320,323,243,650,8500,1600,3910,700,1475,8080,3757,4294,1106,1411,885,2250,1426,2198,4433,5181,2368,7261,611,297,1810,1580,5932,160,7100,177,4200,1700,656,653,6100,1100,2100,1487,550,153,1564,4600,1474,8050,6593,1597,1272,7187,687,6577,4360,437,4168,810,6240,805,728)*/


/*- STEP 6: SELECT Max Number of Courses FROM the list.*/
IF @DeBugCode = 1 PRINT 'STEP 6: Select Max Number of Courses From the list'

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn04Customer_Final')
	DROP TABLE Staging.Ecampn04Customer_Final

CREATE TABLE Staging.Ecampn04Customer_Final
(Customerid udtCustomerID NOT NULL,
FirstName VARCHAR(50) NULL,
LastName VARCHAR(50) NULL,
EmailAddress VARCHAR(60) NULL,
ComboID VARCHAR(30) NULL,
CourseID INT NULL,
Rank FLOAT NULL,
Adcode INT NULL,
Region VARCHAR(40) NULL,
ContryCode Varchar(5) null,
SubjectLine VARCHAR(200) NULL,
PreferredCategory VARCHAR(5) NULL,
ECampaignID VARCHAR(30) NULL)


CREATE CLUSTERED INDEX IDX_customer_Ecamp04Fnl
ON Staging.Ecampn04Customer_Final (Customerid)


IF @DeBugCode = 1 PRINT 'STEP 6: Rerank the course list to put them in order'

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn03Customer02_Course2')
	DROP TABLE Staging.Ecampn03Customer02_Course2

select *, rank() over (partition by customerid order by rank) as Rank2
into Staging.Ecampn03Customer02_Course2
from Staging.Ecampn03Customer02_Course


CREATE INDEX ix_Ecampn03Customer02_Course21 on Staging.Ecampn03Customer02_Course2 (Customerid)
CREATE INDEX ix_Ecampn03Customer02_Course22 on Staging.Ecampn03Customer02_Course2 (rank2)


INSERT INTO Staging.Ecampn04Customer_Final
SELECT Customerid, FirstName, LastName, EmailAddress, 
	ComboID, CourseID, Rank2 As Rank, Adcode, Region, CountryCode, 
	SubjectLine, PreferredCategory, ECampaignID 
FROM Staging.Ecampn03Customer02_Course2
WHERE rank2 <= 25

/*
SET NOCOUNT ON

IF @CourseCount > @MaxCourse
   BEGIN
	DECLARE @CustID INT
	DECLARE MyCursor CURSOR FOR
	SELECT DISTINCT customerid 
	FROM Ecampaigns.dbo.Ecampn03Customer02_Course
	
		OPEN MyCursor
		FETCH NEXT FROM MyCursor INTO @CustID
			
		WHILE @@FETCH_STATUS = 0
			BEGIN
				SET ROWCOUNT @MaxCourse
				INSERT INTO Ecampaigns.dbo.Ecampn04Customer_Final
				SELECT * 
				FROM Ecampaigns.dbo.Ecampn03Customer02_Course
				WHERE CustomerID = @CustID
				ORDER BY CustomerID, Rank, CourseID
				SET ROWCOUNT 0
				FETCH NEXT FROM MyCursor INTO @CustID
			END
		CLOSE MyCursor
		DEALLOCATE MyCursor
   END
ELSE
   BEGIN
	INSERT INTO Ecampaigns.dbo.Ecampn04Customer_Final
	SELECT * 
	FROM Ecampaigns.dbo.Ecampn03Customer02_Course
   END

SET NOCOUNT OFF
*/

/*- STEP 7: Delete customers having less than 5 courses to offer.*/

IF @DeBugCode = 1 PRINT 'STEP 7: Delete customers having less than 5 courses to offer'

DELETE FROM Staging.Ecampn04Customer_Final
WHERE CustomerID IN 
		(SELECT CustomerID
		FROM Staging.Ecampn04Customer_Final
		GROUP BY CustomerID
		HAVING COUNT(*) < 5)

/*- STEP 8: Generate Reports*/
SET ROWCOUNT 0

IF @DeBugCode = 1 PRINT 'STEP 8: Generate Reports'

/*- Report1: Ranking check report*/

SELECT a.Sumsales,a.CourseID,b.CourseName,a.PreferredCategory, a.Rank   
FROM Staging.Ecampn02Rank a,
	Mapping.DMCourse b
WHERE a.CourseID = b.CourseID
ORDER BY a.PreferredCategory, a.Rank

/*- Report2: Counts by RFM Cells*/

SELECT DISTINCT CourseID
FROM Staging.Ecampn02Rank

/*- Add Customer data to Email History Table  */

IF @Test = 'NO'
BEGIN
	IF @DeBugCode = 1 PRINT 'Add Customer data to Email History Table'
	INSERT INTO Ecampaigns..EmailHistory
	(CustomerID,Adcode,StartDate)
	SELECT Customerid,
		Adcode,
		@DropDate AS StartDate
	FROM Staging.Ecampn03Customer01
END

/*- Create Final table*/
IF @DeBugCode = 1 PRINT 'Create Final Tables'

DECLARE @Qry VARCHAR(8000)

/*- Drop if @FnlTable already exists*/
/*
DECLARE @RowCounts INT
SELECT @RowCounts = COUNT(*) FROM sysobjects
WHERE Name = @FnlTable
SELECT '@RowCounts = ' + CONVERT(VARCHAR,@RowCounts)
*/


IF (EXISTS (SELECT * FROM ecampaigns.INFORMATION_SCHEMA.TABLES        
			WHERE TABLE_CATALOG = 'ECampaigns'
			AND TABLE_SCHEMA = 'dbo'
			AND TABLE_NAME = REPLACE(@FnlTable,'Ecampaigns.dbo.','')))
BEGIN
	SET @Qry = 'DROP TABLE ' + @FnlTable
	SELECT @Qry
	EXEC (@Qry)
END


SET @Qry = 'SELECT *
	    INTO ' + @FnlTable +
	   ' FROM Staging.Ecampn04Customer_Final'

EXEC (@Qry)


/*- Create Index on @FnlTable*/
DECLARE @FnlIndex VARCHAR(50)

SET @FnlIndex = 'IDX_' + REPLACE(@FnlTable,'Ecampaigns.dbo.','')

SELECT 'Create Index'
SET @Qry = 'CREATE CLUSTERED INDEX ' + @FnlIndex + ' ON ' + @FnlTable + '(CustomerID)'
EXEC (@Qry)

IF @DeBugCode = 1 PRINT 'END Ecampaigns.dbo.CampaignEmail_FvrtSubj'
GO
