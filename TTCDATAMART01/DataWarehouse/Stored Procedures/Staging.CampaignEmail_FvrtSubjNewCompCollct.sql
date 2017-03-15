SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROC [Staging].[CampaignEmail_FvrtSubjNewCompCollct]
	@EmailCatalogCode INT,
	@EmailCatalogCodeSwamp INT = 8804,
	@EmailCatalogCodeInt INT = 8805,
	@EmailCatalogCodeInquirer INT = 8806,
	@EmailCatalogCodeCanada INT = 13631,	
	@FlagIntnl VARCHAR(3) = 'YES',
	@Test VARCHAR(5) = 'YES',
	@DeBugCode INT = 1
AS

/*- Proc Name: 	Ecampaigns.dbo.CampaignEmail_FvrtSubjNewCompCollct*/
/*- Purpose:	To generate Email List for Email Campaign*/
/*-		for complete your collection email*/
/*-		Prior to running the procedure, Price matrix should be*/
/*-		set up for the catalogcode and migrated to Datamart.*/
/*      PM should be all courses with the exception of the courses*/
/*		you are protecting.*/
/* 		Also, update table with basic course list that were selected*/
/*		for the email.*/
/* truncate table Staging.Ecampn02_CoursesOnSale*/
/* */
/* INSERT INTO Staging.Ecampn02_CoursesOnSale*/
/* select Courseid, CourseName, SubjectCategory, SubjectCategory2*/
/* from Marketingdm..DMCourse*/
/* where courseID IN (8500,7510,4294,1830,1597,1527,1426,1423,1411,1235,160,153,140,132,131,111,105,104,102,101,8894,8593,8570,8514,8380,8270,8190,8090,7237,7180,6672,6633,6627,6457,6423,6312,6260,6234,6172,4477,4460,4433,4311,4244,4235,4123,4100,3970,3588,3356,2567,2400,2353,2317,2310,1823,1750,1546,1533,1515,1500,1499,1434,1333,1240,877,828,730,687,647,643,616,470,443,415,370,304,297,295,292,210,168,158,8520,4880,4680,4617,4242,1495,660,447,8530,7318,7175,7150,7130,1120,780,754,753,752,751,710,437,250)*/
/* order by 1*/
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
   
IF @EmailCatalogCodeCanada <> 13631
   BEGIN
	SELECT @Count = COUNT(*)
	FROM Staging.MktCatalogCodes
	WHERE CatalogCode = @EmailCatalogCodeCanada
	
	IF @Count = 0
	BEGIN	
		SET @ErrorMsg = 'CatalogCode ' + CONVERT(VARCHAR,@EmailCatalogCodeCanada) + ' does not exist. Please Provide a valid Catalogcode for Email'
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
		@DropDateSNI = StartDate - 1
	FROM Staging.MktCatalogCodes
	WHERE CatalogCode = @EMailCatalogCode
  END

IF @DeBugCode = 1 
   BEGIN
	PRINT 'DropDate = ' + CONVERT(VARCHAR,@DropDate,101)
	PRINT 'DropDateSNI = ' + CONVERT(VARCHAR,@DropDateSNI,101)
   END

/*- Derive the campaign ID  -- PR 9/21/2007*/
DECLARE @ECampaignIDActive VARCHAR(30)
DECLARE @ECampaignIDSwamp VARCHAR(30)
DECLARE @ECampaignIDInq VARCHAR(30)
DECLARE @ECampaignIDWebInq VARCHAR(30)

SELECT @ECampaignIDActive = 'FSAct' + CONVERT(VARCHAR,@DropDate,112)
SELECT @ECampaignIDSwamp = 'FSSNI' + CONVERT(VARCHAR,@DropDateSNI,112)
SELECT @ECampaignIDInq = 'FSInq' + CONVERT(VARCHAR,@DropDateSNI,112)
SELECT @ECampaignIDWebInq = 'FSWebInq' + CONVERT(VARCHAR,@DropDateSNI,112)

IF @DeBugCode = 1 
   BEGIN
	PRINT 'CampaignID for Actives= ' + @ECampaignIDActive
	PRINT 'CampaignID for Swamp = ' + @ECampaignIDSwamp
	PRINT 'CampaignID for Inquriers = ' + @ECampaignIDInq
	PRINT 'CampaignID for WebInq = ' + @ECampaignIDWebInq
   END

/*- Derive  Final table name.*/
DECLARE @FnlTable VARCHAR(100)
DECLARE @FnlTableSNI1 VARCHAR(100)

SELECT @FnlTable = 'Ecampaigns.dbo.Email' + CONVERT(VARCHAR,@DropDate,112) + '_' + 'Offers_CYC'
FROM Staging.MktCatalogCodes
WHERE CatalogCode = @EmailCatalogCode

SELECT @FnlTableSNI1 = 'Ecampaigns.dbo.Email' + CONVERT(VARCHAR,@DropDateSNI,112) + '_' + 'Offers_CYC'
FROM Staging.MktCatalogCodes
WHERE CatalogCode = @EmailCatalogCode

DECLARE @FnlTableActive VARCHAR(100)
DECLARE @FnlTableSNI VARCHAR(100)

SELECT @FnlTableActive = @FnlTable + '_Active'
SELECT @FnlTableSNI = @FnlTableSNI1 + '_SNI'

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
DECLARE @AdcodeCanada INT

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

 /* Get Swamp Adcode*/
	SELECT @AdcodeSwamp = Adcode
	FROM Staging.MktAdcodes
	WHERE CatalogCode IN (@EmailCatalogCode, @EmailCatalogCodeSwamp) 
	AND UPPER(Name) LIKE '%SWAMP CONTROL%'
	
	IF @AdcodeSwamp IS NULL
	   BEGIN
		PRINT '****WARNING**** AdcodeSwamp was not found. So, adding one to the AdcodeActive'
		SET @AdcodeSwamp = 8888
	   END
	   
 /* Get International Adcode	*/
	SELECT @AdcodeIntnl =  Adcode
	FROM Staging.MktAdcodes
	WHERE CatalogCode IN (@EmailCatalogCode, @EmailCatalogCodeSwamp, @EmailCatalogCodeInt)
	AND UPPER(Name) LIKE '%INTERNATIONAL%'  /* CONTROL'*/
	
	IF @AdcodeIntnl IS NULL
	   BEGIN
		PRINT '****WARNING**** AdcodeIntnl was not found. So, adding two to the AdcodeActive'			SET @AdcodeIntnl = 7777
	   END
	
 /* Get Canada Adcode*/
 
 	SELECT @AdcodeCanada =  Adcode
	FROM Staging.MktAdcodes
	WHERE CatalogCode IN (@EmailCatalogCodeCanada)
	AND UPPER(Name) LIKE '%canada%' /*CONTROL'*/
	
	IF @AdcodeCanada IS NULL
	   BEGIN
		PRINT '****WARNING**** AdcodeCanada was not found. So, using dummy Canada Adcode'
		SET @AdcodeCanada = 2222
	   END
	   
 /* Get No Subj Pref Adcode*/
 
	SELECT @AdcodeNoSubjPref =  Adcode
	FROM Staging.MktAdcodes
	WHERE CatalogCode IN (@EmailCatalogCode, @EmailCatalogCodeSwamp, @EmailCatalogCodeInt)
	AND UPPER(Name) LIKE '%NO SUBJ PREF%' /*CONTROL'*/
	
	IF @AdcodeNoSubjPref IS NULL
	   BEGIN
		PRINT '****WARNING**** AdcodeNoSubjPref was not found. So, adding three to the AdcodeActive'
		SET @AdcodeNoSubjPref = 6666
	   END

 /* Get Inquirer Adcode*/
	SELECT @AdcodeInq =  Adcode
	FROM Staging.MktAdcodes
	WHERE CatalogCode IN (@EmailCatalogCode, @EmailCatalogCodeSwamp, @EmailCatalogCodeInt, @EmailCatalogCodeInquirer)
	AND UPPER(Name) LIKE '%Inquirer%'  /* CONTROL'*/
	
	IF @AdcodeInq IS NULL
	   BEGIN
		PRINT '****WARNING**** Inquirer was not found. So, adding two to the AdcodeActive'			
		SET @AdcodeInq = 5555
	   END
	
 /* Get Web Inquirer Adcode*/
 	
	/*SELECT @AdcodeWebInq =  Adcode*/
	/*FROM SuperstarDW.dbo.MktAdcodes*/
	/*WHERE CatalogCode IN (@EmailCatalogCode, @EmailCatalogCodeSwamp, @EmailCatalogCodeInt, @EmailCatalogCodeInquirer)*/
	/*AND UPPER(Name) LIKE '%WebInq%' --CONTROL'*/
	
	/*IF @AdcodeWebInq IS NULL*/
	/*   BEGIN*/
	/*	PRINT '****WARNING**** AdcodeWebInq was not found. So, adding three to the AdcodeActive'*/
	/*	SET @AdcodeWebInq = 4444*/
	/*   END*/


IF @DeBugCode = 1 
BEGIN
	PRINT 'AdcodeActive = ' +  CONVERT(VARCHAR,@AdcodeActive) 
	PRINT 'AdcodeSwamp = ' + CONVERT(VARCHAR,@AdcodeSwamp) 
	PRINT 'AdcodeIntnl = ' + CONVERT(VARCHAR,@AdcodeIntnl)
	/*PRINT 'AdcodeNoSubjPref = ' + CONVERT(VARCHAR,@AdcodeNoSubjPref)*/
	PRINT 'AdcodeInq = ' + CONVERT(VARCHAR,@AdcodeInq) 
	/*PRINT 'AdcodeWebInq = ' + CONVERT(VARCHAR,@AdcodeWebInq)*/
	PRINT 'AdcodeCanada = ' + CONVERT(VARCHAR,@AdcodeCanada)
	

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
	WHERE O.DATEORDERED BETWEEN DATEADD(Month,-3,GETDATE()) AND GETDATE()
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
	WHERE O.DATEORDERED BETWEEN DATEADD(Month,-3,GETDATE()) AND GETDATE()
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
print 'Force ranks for some courses to top'

 UPDATE Staging.Ecampn02Rank
 SET Rank = Rank/10.5123
 WHERE CourseID IN (3588,2539,303,8128,759,7237,1499,1423,4168,408,4691,297,611)
 --and rank > 10

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn02RankCC')
	DROP TABLE Staging.Ecampn02RankCC

SELECT a.*,B.SubjectCategory2, ISNULL(C.FlagOnSale,0) FlagOnSale
INTO Staging.Ecampn02RankCC
FROM Staging.Ecampn02Rank A JOIN
	Mapping.dmcourse B on A.courseid = b.courseid left outer join
	(select *, 1 as FlagOnSale
	from Staging.Ecampn02_CoursesOnSale)C on A.courseid = c.courseid
order by preferredcategory, rank

DELETE FROM Staging.Ecampn02RankCC
WHERE FlagOnSale = 0
AND Preferredcategory <> SubjectCategory2

/* Delete three new courses from Dec catalog*/
/* DELETE FROM Ecampaigns.dbo.Ecampn02RankCC*/
/* WHERE CourseID IN (1950, 8280, 1001)*/



SELECT a.Sumsales,a.CourseID,b.CourseName,a.PreferredCategory, a.Rank   
FROM Staging.Ecampn02RankCC a,
	Mapping.DMCourse b
WHERE a.CourseID = b.CourseID
ORDER BY a.PreferredCategory, a.Rank


/*- STEP 3: Get the list of Emailable customers from the CustomerSignature Table*/
IF @DeBugCode = 1 PRINT 'Begin STEP 3: Get the list of Emailable customers that should receive Favorite Subject Email.'

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn03Customer01')
	DROP TABLE Staging.Ecampn03Customer01

SELECT ccs.Customerid,
	ccs.FirstName,
	ccs.LastName,
	ccs.EmailAddress,
	ccs.ComboID,
 	CASE WHEN ccs.CustomerSegmentNew = 'Active' THEN @AdcodeActive
	     ELSE @AdcodeSwamp
	END AS AdCode,
	ccs.State AS Region, ccs.CountryCode,
	CASE WHEN ccs.CustomerSegmentNew = 'Active' THEN @SubjectLineActive
	     ELSE @SubjectLineSwamp
	END  AS SubjectLine,
	CASE WHEN ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'SC' then 'SCI'
		when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'FA' then 'VA'
		when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory NOT IN ('SC','FA') then ccs.preferredcategory
		when isnull(ccs.PreferredCategory2,'') = '' then 'SCI'
		else ccs.PreferredCategory2 
	END as PreferredCategory,
	CASE WHEN ccs.customerSegment = 'Active' THEN @ECampaignIDActive
	     ELSE @ECampaignIDSwamp
	END AS ECampaignID
INTO Staging.Ecampn03Customer01
FROM Marketing.CampaignCustomerSignature ccs
WHERE ccs.FlagEmail = 1 AND ccs.BuyerType > 1 AND EmailAddress LIKE '%@%'
AND ccs.PublicLibrary = 0 
and ccs.Countrycode not IN ('GB','AU')


/*- Update AdCode for International customers*/

IF @DeBugCode = 1 PRINT 'Update AdCode for International customers'

UPDATE EC01
SET Adcode = @AdcodeIntnl
FROM Staging.Ecampn03Customer01 EC01 JOIN
	Marketing.CampaignCustomerSignature CCS ON CCS.CustomerID = EC01.CustomerID
WHERE CCS.CountryCode NOT LIKE '%US%'
AND CCS.CountryCode IS NOT NULL
AND CCS.CountryCode <> ''


/* Update Canada Adcode*/
IF @DeBugCode = 1 PRINT 'Update AdCode for Canada customers' /* Added on 6/9/2010*/

UPDATE EC01
SET Adcode = @AdcodeCanada
FROM Staging.Ecampn03Customer01 EC01 
WHERE EC01.CountryCode LIKE '%CA%'


/* Add Inquirers*/
IF @DeBugCode = 1 PRINT 'Add Inquirers'

IF @FlagIntnl = 'YES' 
   BEGIN
	INSERT INTO Staging.Ecampn03Customer01
	(Customerid, FirstName, LastName, EmailAddress, ComboID, Adcode, Region, SubjectLine, 
	PreferredCategory, ECampaignID)
	SELECT CCS.CustomerID, Staging.proper(CCS.FirstName) FirstName,
		Staging.proper(CCS.LastName) LastName, CCS.EmailAddress, 
		CASE WHEN ccs.ComboID IN ('25-10000 Mo Inq Plus', 'Inq') THEN '25-10000 Mo Inq'
		     ELSE CCS.ComboID
		END AS ComboID, 
		@AdcodeInq as Adcode, 
		ISNULL(State,'') AS Region,
		@SubjectLineSwamp AS SubjectLine, 
		'GEN' AS PreferredCategory,
		@ECampaignIDInq AS ECampaignID
	FROM Marketing.CampaignCustomerSignature CCS LEFT OUTER JOIN
		Staging.Ecampn03Customer01 EC01 ON CCS.CustomerID = EC01.CustomerID
	WHERE EC01.CustomerID IS NULL AND ccs.Buyertype = 1 AND ccs.FlagEmail = 1 AND ccs.PublicLibrary = 0
	and ccs.CountryCode not in ('AU','GB')

/* Add Web Inquirers*/
	/*IF @DeBugCode = 1 PRINT 'Add Web Inquirers'*/

	/*IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Email_WebInq')*/
	/*	DROP TABLE Ecampaigns.dbo.Email_WebInq*/
	
	/*SELECT C.CustomerID, MarketingDM.dbo.proper(C.FirstName) FirstName,*/
	/*	MarketingDM.dbo.proper(C.LastName) LastName, C.EmailAddress, 'WebInqs' AS ComboID,*/
	/*	@AdcodeWebInq as Adcode, */
	/*	convert(varchar(2),'') as Region,*/
	/*	@SubjectLineSwamp AS SubjectLine,*/
	/*	'GEN' AS PreferredCategory, */
	/*	@ECampaignIDWebInq AS ECampaignID*/
	/*INTO ECampaigns.dbo.Email_WebInq	*/
	/*FROM Superstardw.dbo.Customers C LEFT OUTER JOIN	*/
	/*	MarketingDM.dbo.CampaignCustomerSignature CCS ON C.CustomerID = CCS.CustomerID*/
	/*	JOIN*/
	/*	(SELECT CustomerID*/
	/*	FROM Superstardw.dbo.AcctPreferences*/
	/*	WHERE PreferenceID = 'OfferEmail'*/
	/*	AND PreferenceValue = 1)AP ON C.CustomerID = AP.CustomerID*/
	/*WHERE CCS.CustomerID IS NULL AND C.EmailAddress LIKE '%@%'	*/
	/*AND C.EmailAddress not Like '%teachco.com' AND C.organization_key is null*/
	
	
	/*INSERT INTO Ecampaigns.dbo.Ecampn03Customer01*/
	/*(Customerid, FirstName, LastName, EmailAddress, ComboID, Adcode, Region, SubjectLine, */
	/*PreferredCategory, ECampaignID)*/
	/*SELECT WI.**/
	/*FROM ECampaigns.dbo.Email_WebInq WI LEFT OUTER JOIN*/
	/*	Ecampaigns.dbo.Ecampn03Customer01 EC01 on WI.Customerid = EC01.CustomerID*/
	/*WHERE EC01.CustomerID IS NULL*/
   END

/* Delete if there are still from GB*/
DELETE FROM Staging.Ecampn03Customer01
WHERE CountryCode in ('GB','AU')

DELETE A
from Staging.Ecampn03Customer01 a join
	(select * from marketing.campaigncustomersignature
	where countrycode in ('GB','AU'))b on a.emailaddress = b.emailaddress
	

CREATE  CLUSTERED INDEX IDX_customer_Ecamp03Cust01
ON Staging.Ecampn03Customer01 (Customerid)

/* Delete if there are still from AU*/
/*DELETE FROM Ecampaigns.dbo.Ecampn03Customer01*/
/*WHERE CountryCode = 'AU'*/


DELETE A
from Staging.Ecampn03Customer01 a join
	(select * from marketing.campaigncustomersignature
	where countrycode = 'AU'
	and CustomerSince >= '9/1/2010')b on a.emailaddress = b.emailaddress


DELETE A
from Staging.Ecampn03Customer01 a join
	(select * from marketing.campaigncustomersignature
	where countrycode = 'AU'
	and CustomerSince >= '9/1/2010')b on a.CustomerID = b.CustomerID
	
	
/*- Update Adcode for Customers without any subject preference*/
/*IF @DeBugCode = 1 PRINT 'Update Adcode for Customers without any subject preference'*/

/*UPDATE Ecampaigns.dbo.Ecampn03Customer01*/
/*SET AdCode = @AdcodeNoSubjPref*/
/*WHERE PreferredCategory IS NULL*/

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

/* Drop Unsubscribes and other IDs that should not receive the emails.*/
exec Staging.CampaignEmail_RemoveUnsubs 'Ecampn03Customer01'

/* Backup Rank table and delete courses ranked higher than 100*/

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn02RankCCBKP')
	DROP TABLE Staging.Ecampn02RankCCBKP

SELECT *
INTO Staging.Ecampn02RankCCBKP
FROM Staging.Ecampn02RankCC

DELETE FROM Staging.Ecampn02RankCC
WHERE Rank > 100


/* Delete Swampers and Inquirers*/
/* PRINT 'Delete Swampers and Inquirers'*/
/* DELETE FROM Ecampaigns.dbo.Ecampn03Customer01*/
/* WHERE Adcode IN (27838, 27841)*/

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
	Staging.Ecampn02RankCC er
WHERE ISNULL(a.PreferredCategory,'GEN') = er.PreferredCategory


CREATE CLUSTERED INDEX IDX_customer_Ecamp03Cust02
ON Staging.Ecampn03Customer02_Course (Customerid)

/* Remove AH courses from ranking if customer is in the table Marketingdm..Cust_AHMagProtect*/
/* This was done for 11/24 email based on Ashit's request to protect AH magalog dropping in Jan.*/
/*DELETE a*/
/*-- select a.**/
/*from Ecampaigns.dbo.Ecampn03Customer02_Course a join*/
/*	Marketingdm..Cust_AHMagProtect b on a.customerid = b.customerid join*/
/*	(select distinct courseid*/
/*	from marketingdm..dmcourse*/
/*	where subjectcategory = 'AH')c on a.courseid = c.courseid*/

/*- STEP 5: Remove the courses FROM the customer list if they have already purchased them.*/
IF @DeBugCode = 1 PRINT 'STEP 5: Remove the courses from the customer list if they have already purchased them'

DELETE a
/*SELECT a.* */
FROM Staging.Ecampn03Customer02_Course a,
	(SELECT DISTINCT o.customerid, courseid
	FROM marketing.dmpurchaseorderitems oi
    join marketing.dmpurchaseorders o on o.OrderID = oi.OrderID
	WHERE stockitemid LIKE '[PD][ACDMV]%'
	AND courseid IN (SELECT DISTINCT courseid FROM Staging.Ecampn02RankCC))b
WHERE a.customerid=b.customerid
AND a.courseid=b.courseid

/*- STEP 6: SELECT Max Number of Courses FROM the list.*/
IF @DeBugCode = 1 PRINT 'STEP 6: Select Max Number of Courses From the list'

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn04Customer_Final')
	DROP TABLE Staging.Ecampn04Customer_Final

CREATE TABLE Staging.Ecampn04Customer_Final
(Customerid udtCustomerID NOT NULL,
FirstName VARCHAR(50) NULL,
LastName VARCHAR(50) NULL,
EmailAddress VARCHAR(50) NULL,
ComboID VARCHAR(30) NULL,
CourseID INT NULL,
Rank FLOAT NULL,
Adcode INT NULL,
Region VARCHAR(50) NULL,
CountryCode VARCHAR(3) NULL, 
SubjectLine VARCHAR(200) NULL,
PreferredCategory VARCHAR(5) NULL,
ECampaignID VARCHAR(25) NULL)


CREATE CLUSTERED INDEX IDX_customer_Ecamp04Fnl
ON Staging.Ecampn04Customer_Final (Customerid)

IF @DeBugCode = 1 PRINT 'STEP 6: Rerank the course list to put them in order'

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn03Customer02_CourseNO2')
	DROP TABLE Staging.Ecampn03Customer02_CourseNO2

select *, rank() over (partition by customerid order by rank) as Rank2
into Staging.Ecampn03Customer02_CourseNO2
from Staging.Ecampn03Customer02_Course


CREATE INDEX ix_Ecampn03Customer02_CourseNO21 on Staging.Ecampn03Customer02_CourseNO2 (Customerid)
CREATE INDEX ix_Ecampn03Customer02_CourseNO22 on Staging.Ecampn03Customer02_CourseNO2 (rank2)


INSERT INTO Staging.Ecampn04Customer_Final
SELECT Customerid, FirstName, LastName, EmailAddress, 
	ComboID, CourseID, Rank2 As Rank, Adcode, Region, CountryCode, 
	SubjectLine, PreferredCategory, ECampaignID 
FROM Staging.Ecampn03Customer02_CourseNO2
WHERE rank2 <= @MaxCourse

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


/*
IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn04Customer_Final_New')
	DROP TABLE Ecampaigns.dbo.Ecampn04Customer_Final_New

SELECT ECC.*, ECCSeq.SeqNum
INTO Ecampaigns.dbo.Ecampn04Customer_Final_New
FROM Ecampaigns.dbo.Ecampn03Customer02_Course ECC JOIN
            (SELECT ECC1.CUSTOMERID, ECC1.RANK, 
			SUM(CASE WHEN ECC2.RANK <= ECC1.RANK THEN 1 ELSE 0 END) SEQNUM 
             FROM Ecampaigns.dbo.Ecampn03Customer02_Course ECC1 JOIN
	             Ecampaigns.dbo.Ecampn03Customer02_Course ECC2
	            ON ECC1.CUSTOMERID = ECC2.CUSTOMERID
             GROUP BY ECC1.CUSTOMERID, ECC1.RANK) ECCSEQ
     ON ECCSEQ.CUSTOMERID = ECC.CUSTOMERID 
	AND ECCSEQ.RANK = ECC.RANK AND ECCSEQ.SEQNUM <= @MaxCourse
ORDER BY ECC.CustomerID,  ECC.Rank


CREATE CLUSTERED INDEX IDX_customer_Ecamp04FnlNew
ON Ecampaigns.dbo.Ecampn04Customer_FinalNew (Customerid)
*/
/*- STEP 7: Delete customers having less than 5 courses to offer.*/

IF @DeBugCode = 1 PRINT 'STEP 7: Delete customers having less than 5 courses to offer'

DELETE FROM Staging.Ecampn04Customer_Final
WHERE CustomerID IN 
		(SELECT CustomerID
		FROM Staging.Ecampn04Customer_Final
		GROUP BY CustomerID
		HAVING COUNT(*) < 5)

/* DELETE FROM Ecampaigns.dbo.Ecampn04Customer_Final_New*/
/* WHERE CustomerID IN */
/* 		(SELECT CustomerID*/
/* 		FROM Ecampaigns.dbo.Ecampn04Customer_Final_New*/
/* 		GROUP BY CustomerID*/
/* 		HAVING COUNT(*) < 5)*/



/*- STEP 8: Generate Reports*/
SET ROWCOUNT 0
IF @DeBugCode = 1 PRINT 'STEP 8: Generate Reports'

/*- Report1: Ranking check report*/

SELECT a.Sumsales,a.CourseID,b.CourseName,a.PreferredCategory, a.Rank   
FROM Staging.Ecampn02RankCC a,
	Mapping.DMCourse b
WHERE a.CourseID = b.CourseID
ORDER BY a.PreferredCategory, a.Rank

/*- Report2: Counts by RFM Cells*/

/* SELECT csm.newseg,csm.name,rds.a12mf,COUNT(DISTINCT mct.customerid) AS CountOfCustomers*/
/* FROM Ecampaigns.dbo.Ecampn04Customer_Final mct,*/
/* 	rfm..customersubjectmatrix csm,*/
/* 	rfm..rfm_data_special rds*/
/* WHERE mct.customerid=csm.customerid*/
/* 	and csm.customerid=rds.customerid*/
/* GROUP BY csm.newseg,csm.name,rds.a12mf*/
/* order by csm.newseg,csm.name,rds.a12mf*/
/* */
/* --- Report3: Count by AdCode and SubjectLine*/
/* */
/* SELECT fnl.AdCode, mac.Name, Fnl.EcampaignID,*/
/* 	fnl.SubjectLine,*/
/* 	COUNT(fnl.Customerid) AS TotalCount,*/
/* 	COUNT(DISTINCT fnl.Customerid) AS UniqueCustCount*/
/* FROM Ecampaigns.dbo.Ecampn04Customer_Final fnl LEFT OUTER JOIN*/
/* 	Superstardw.dbo.MktAdcodes mac ON fnl.adcode = mac.adcode*/
/* GROUP BY fnl.AdCode, mac.Name, Fnl.EcampaignID, fnl.SubjectLine*/
/* ORDER BY fnl.AdCode*/
/* */
/* --- Generate Customer and Course information for Instruction files*/
/* SELECT DISTINCT c.customerid,d.firstname,d.lastname,c.PreferredCategory,c.adcode*/
/* FROM (SELECT MAX(DISTINCT customerid) AS customerid, PreferredCategory, Adcode*/
/* 	FROM Ecampaigns.dbo.Ecampn04Customer_Final*/
/* 	GROUP BY PreferredCategory, Adcode)c,*/
/* 	Ecampaigns.dbo.Ecampn04Customer_Final d*/
/* WHERE c.customerid=d.customerid*/
/* ORDER BY c.adcode, c.PreferredCategory, c.customerid*/

/*SELECT DISTINCT c.customerid,d.firstname,d.lastname,c.PreferredCategory,c.adcode
FROM (SELECT MAX(DISTINCT a.customerid) AS customerid,
		b.PreferredCategory,a.Adcode
	FROM Ecampaigns.dbo.Ecampn04Customer_Final  a,
		Ecampaigns.dbo.Ecampn03Customer01 b
	WHERE a.customerid=b.customerid
	GROUP BY b.PreferredCategory,a.Adcode)c,
	Ecampaigns.dbo.Ecampn04Customer_Final d
WHERE c.customerid=d.customerid
ORDER BY c.adcode, c.PreferredCategory, c.customerid*/

SELECT DISTINCT CourseID
FROM Staging.Ecampn02RankCC

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

/*- Drop if @FnlTablActive already exists*/

IF (EXISTS (SELECT * FROM ecampaigns.INFORMATION_SCHEMA.TABLES        
			WHERE TABLE_CATALOG = 'ECampaigns'
			AND TABLE_SCHEMA = 'dbo'
			AND TABLE_NAME = REPLACE(@FnlTableActive,'Ecampaigns.dbo.','')))
BEGIN
	SET @Qry = 'DROP TABLE ' + @FnlTableActive
	SELECT @Qry
	EXEC (@Qry)
END

SET @Qry = 'SELECT *
	    INTO ' + @FnlTableActive +
	   ' FROM Staging.Ecampn04Customer_Final
	    WHERE Adcode in (' + CONVERT(VARCHAR,@AdcodeActive) + ', ' + convert(varchar, isnull(@AdcodeCanada, 0)) + ', ' + convert(varchar, isnull(@AdcodeIntnl, 0)) + ')'

EXEC (@Qry)


/*- Create Index on @FnlTable*/
DECLARE @FnlIndex VARCHAR(50)

SET @FnlIndex = 'IDX_' + REPLACE(@FnlTableActive,'Ecampaigns.dbo.','')

SELECT 'Create Index'
SET @Qry = 'CREATE CLUSTERED INDEX ' + @FnlIndex + ' ON ' + @FnlTableActive + '(CustomerID)'
EXEC (@Qry)

/*- Drop if @FnlTablSNI already exists*/

IF (EXISTS (SELECT * FROM ecampaigns.INFORMATION_SCHEMA.TABLES        
			WHERE TABLE_CATALOG = 'ECampaigns'
			AND TABLE_SCHEMA = 'dbo'
			AND TABLE_NAME = REPLACE(@FnlTableSNI,'Ecampaigns.dbo.','')))
BEGIN
	SET @Qry = 'DROP TABLE ' + @FnlTableSNI
	SELECT @Qry
	EXEC (@Qry)
END


SET @Qry = 'SELECT *
	    INTO ' + @FnlTableSNI +
	   ' FROM Staging.Ecampn04Customer_Final
	    WHERE Adcode not in (' + CONVERT(VARCHAR,@AdcodeActive) + ', ' + convert(varchar, isnull(@AdcodeCanada, 0)) + ', ' + convert(varchar, isnull(@AdcodeIntnl, 0)) + ')'

EXEC (@Qry)


/*- Create Index on @FnlTable*/


SET @FnlIndex = 'IDX_' + REPLACE(@FnlTableSNI,'Ecampaigns.dbo.','')

SELECT 'Create Index'
SET @Qry = 'CREATE CLUSTERED INDEX ' + @FnlIndex + ' ON ' + @FnlTableSNI + '(CustomerID)'
EXEC (@Qry)


IF @DeBugCode = 1 PRINT 'END Ecampaigns.dbo.CampaignEmail_FvrtSubjNewCompCollct'
GO
