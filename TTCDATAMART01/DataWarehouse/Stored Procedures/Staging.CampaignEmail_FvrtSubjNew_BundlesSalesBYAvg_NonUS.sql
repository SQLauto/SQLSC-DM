SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [Staging].[CampaignEmail_FvrtSubjNew_BundlesSalesBYAvg_NonUS]
	@CountryCode char(2),
	@EmailCatalogCode INT,
	@EmailCatalogCodeSwamp INT = 8804,
	@EmailCatalogCodeInt INT = 8805,
	@EmailCatalogCodeInquirer INT = 8806,
	@MaxBundles INT = 100,
	@FlagIntnl VARCHAR(3) = 'YES',
	@Test VARCHAR(5) = 'YES',
	@DeBugCode INT = 1
AS

/*- Proc Name: 	Ecampaigns.dbo.CampaignEmail_FvrtSubjNew_BundlesSalesBYPart*/
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

SELECT @FnlTable = 'Ecampaigns.dbo.Email' + CONVERT(VARCHAR,@DropDate,112) + '_Offers_' + @CountryCode + '_FSBundle'
FROM Staging.MktCatalogCodes
WHERE CatalogCode = @EmailCatalogCode

SELECT @FnlTableSNI1 = 'Ecampaigns.dbo.Email' + CONVERT(VARCHAR,@DropDateSNI,112) + '_Offers_' + @CountryCode + '_FSBundle'
FROM Staging.MktCatalogCodes
WHERE CatalogCode = @EmailCatalogCode

--DECLARE @FnlTableActive VARCHAR(100)
--DECLARE @FnlTableSNI VARCHAR(100)

--SELECT @FnlTableActive = @FnlTable + '_Active'
--SELECT @FnlTableSNI = @FnlTableSNI1 + '_SNI'

IF @DeBugCode = 1 
BEGIN
	PRINT 'Final Table Name = ' + @FnlTable
	--PRINT 'Final Active Table Name = ' + @FnlTableActive
	--PRINT 'Final SNI Table Name = ' + @FnlTableSNI
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
	PRINT 'AdcodeIntnl = ' + CONVERT(VARCHAR,@AdcodeIntnl)
	PRINT 'AdcodeNoSubjPref = ' + CONVERT(VARCHAR,@AdcodeNoSubjPref)
	PRINT 'AdcodeInq = ' + CONVERT(VARCHAR,@AdcodeInq) 
	PRINT 'AdcodeWebInq = ' + CONVERT(VARCHAR,@AdcodeWebInq)

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

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn02Rank_BundleSBP')
	DROP TABLE Staging.Ecampn02Rank_BundleSBP

SELECT Sum(FNL.SumSales) AS SumSales,
	FNL.CourseID,
	FNL.PreferredCategory,
	CONVERT(FLOAT,0) AS Rank,
	Convert(tinyint,0) AS BundleFlag,
	Convert(int,0) as CourseParts,
	Sum(FNL.SumSales) AS SumSalesBkp
INTO Staging.Ecampn02Rank_BundleSBP
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

/* Add Bundle sales*/

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn02A_BundleCourse')
	DROP TABLE Staging.Ecampn02A_BundleCourse

SELECT BC.BundleID, MC1.CourseName AS BundleName,
	BC.CourseID, MC2.CourseName, MC2.CourseParts, MC2.ReleaseDate,
	convert(money,0) Sales
INTO Staging.Ecampn02A_BundleCourse
from Mapping.bundlecomponents BC JOIN
	(SELECT DISTINCT BC.BundleID
	FROM Staging.MktPricingMatrix MPM JOIN
		Staging.InvItem II ON MPM.UserStockItemID = II.StockItemID JOIN
		Mapping.BundleComponents BC ON II.CourseID = BC.BundleID
	WHERE MPM.CatalogCode = (@EmailCatalogCode))B on BC.BundleID = B.BundleID JOIN
	Mapping.dmcourse MC1 ON BC.BundleID = MC1.CourseID JOIN
	Mapping.DMCourse MC2 ON BC.CourseID = MC2.CourseID
where bc.bundleflag > 0

CREATE INDEX IX_Ecampn02A_BundleCourse1 on Staging.Ecampn02A_BundleCourse (BundleID)
CREATE INDEX IX_Ecampn02A_BundleCourse2 on Staging.Ecampn02A_BundleCourse (CourseID)

/* Add Sales for individual courses from the bundles by preferred category*/

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn02B_BundleCourseByPref')
	DROP TABLE Staging.Ecampn02B_BundleCourseByPref

SELECT Sum(FNL.SumSales) AS SumSales,
	FNL.CourseID,
	FNL.PreferredCategory
INTO Staging.Ecampn02B_BundleCourseByPref
FROM	(SELECT sum(OI.SalesPrice) AS SumSales,
			BC.CourseID,
			'GEN' AS PreferredCategory
	FROM  Marketing.DMPurchaseOrders O JOIN
		Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
		(SELECT DISTINCT CourseID
		FROM Staging.Ecampn02A_BundleCourse)BC on OI.CourseID = BC.CourseID
	AND O.DATEORDERED BETWEEN DATEADD(Month,-6,GETDATE()) AND GETDATE()
	AND O.SequenceNum > 1
	GROUP BY BC.CourseID
	UNION
	SELECT sum(OI.SalesPrice) AS SumSales,
		BC.CourseID,
		ISNULL(CSM.PreferredCategory2,'GEN') AS PreferredCategory
	FROM Marketing.CampaignCustomerSignature CSM JOIN
		Marketing.DMPurchaseOrders O ON CSM.CUSTOMERID = O.CUSTOMERID JOIN
		Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
		(SELECT DISTINCT CourseID
		FROM Staging.Ecampn02A_BundleCourse)BC on OI.CourseID = BC.CourseID
	WHERE O.DATEORDERED BETWEEN DATEADD(Month,-6,GETDATE()) AND GETDATE()
	AND O.SequenceNum > 1
	AND CSM.PreferredCategory2 IS NOT NULL
	GROUP BY BC.CourseID, CSM.PreferredCategory2)FNL
GROUP BY FNL.CourseID,FNL.PreferredCategory

CREATE INDEX IX_Ecampn02B_BundleCourseByPref on Staging.Ecampn02B_BundleCourseByPref (CourseID)

/* Combine Bundles and Course by pref tables to get the Bundles by PrefCat*/
INSERT INTO Staging.Ecampn02Rank_BundleSBP
SELECT AVG(B.SumSales) SumSales,
	A.BundleID AS CourseID, 
	B.PreferredCategory,
	Convert(Float,0) AS Rank,
	1 AS BundleFlag,
	Convert(int,0) as CourseParts,
	Sum(B.SumSales) AS SumSalesBkp
FROM  Staging.Ecampn02A_BundleCourse A JOIN
	Staging.Ecampn02B_BundleCourseByPref B ON A.CourseID = B.CourseID
GROUP BY A.BundleID, B.PreferredCategory


/* update Ecampaigns.dbo.Ecampn02Rank_BundleSBP*/
/* set rank = rank/3.12*/
/* where bundleflag = 0*/

/* UPDATE Ecampaigns.dbo.Ecampn02Rank_BundleSBP*/
/* SET SumSales = SumSales/CourseParts*/

/*- Assign ranking based on Sales*/
IF @DeBugCode = 1 PRINT 'Assign Ranking Based on sales'

DECLARE @CourseID INT
DECLARE @SumSales MONEY
DECLARE @PrefCat VARCHAR(5), @BundleFlag tinyInt
/*- Declare First Cursor for PreferredCategory */
DECLARE MyCursor CURSOR
FOR
SELECT  DISTINCT PreferredCategory 
FROM Staging.Ecampn02Rank_BundleSBP
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
		FROM Staging.Ecampn02Rank_BundleSBP
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
			UPDATE Staging.Ecampn02Rank_BundleSBP
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
/* 			DECLARE @BundleFlag tinyint*/
			/*- DECLARE Third Cursor for courses within the General Category*/
			DECLARE MyCursor3 CURSOR
			FOR
			SELECT DISTINCT CourseID,SumSales
			FROM Staging.Ecampn02Rank_BundleSBP
			WHERE PreferredCategory = 'GEN'
			AND CourseID NOT IN (SELECT CourseID 
					       FROM Staging.Ecampn02Rank_BundleSBP
					       WHERE PreferredCategory = @PrefCat)
			ORDER BY SumSales DESC
			/*- Begin Third Cursor for courses within the General Category*/
			OPEN MyCursor3
			FETCH NEXT FROM MyCursor3 INTO @CourseID3,@SumSales3

			WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @SumSales3,@CourseID3,@PrefCat,@Rank
				INSERT INTO Staging.Ecampn02Rank_BundleSBP
				SELECT @SumSales3,@CourseID3,@PrefCat,@Rank,@BundleFlag, 0,@SumSales3
	
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
/* UPDATE Ecampaigns.dbo.Ecampn02Rank_BundleSBP*/
/* SET Rank = case when rank between 7.0 and 19.0 then Rank/1.56*/
/* 		when rank between 20.0 and 50.0 then rank/2.56*/
/* 		when rank between 50.0 and 75.0 then rank/3.56*/
/* 		when rank between 76.0 and 100.0 then rank/4.568*/
/* 		when rank>100.0 then rank/5.89*/
/* 		else rank*/
/* 	end */
/* --WHERE CourseID IN (1830,1426,7158,4242,3480,6450,5620,2270,8598)*/
/* where courseid in (1830,1831,1426,1427,7158,7159,4242,4243,3480,3481,6450,6451,5620,*/
/* 			5621,8598,8599,2270,2271)*/
/* */
/* PRINT 'Float courses higher in ranking'*/
/* UPDATE Ecampaigns.dbo.Ecampn02Rank_BundleSBP*/
/* set rank = rank/3.51*/
/* -- SET Rank = case when rank > 10.0 then rank/4.51*/
/* -- 		else rank*/
/* -- 	end */
/* WHERE CourseID IN (177,197,217,250,349,447,480,550,710,751,752,753,754,780,869,1120,1219,1220,1260,1295,1426,1474,1487,1533,1573,1620,2100,2310,2317,2353,2368,2429,2539,2567,3150,3180,3340,3410,4235,4242,4600,4647,4820,5620,5665,6130,6240,6252,6299,6537,6577,7130,7150,7318,7510,757,758,8128,8267,8270,8467,8520,8540,8561,8570,8598,8894)*/
/* select * from Ecampaigns.dbo.Ecampn02Rank_BundleSBP*/

/* UPDATE Ecampaigns.dbo.Ecampn02Rank_BundleSBP*/
/* set rank = rank / 2.58*/
/* where bundleflag = 0*/
/**/
--UPDATE Ecampaigns.dbo.Ecampn02Rank_BundleSBP
--SET Rank = rank/2.98
--WHERE CourseID IN (1401,1712,9180,1637)

--float new courses to the top
update Staging.Ecampn02Rank_BundleSBP
set rank=RANK/8.1
where courseid in (3021,1997,2201)


PRINT 'Check Number of Courses in Ranking Table'

SELECT a.PreferredCategory, count(a.courseid) as coursecount
FROM Staging.Ecampn02Rank_BundleSBP a
group by a.PreferredCategory
ORDER BY a.PreferredCategory

PRINT 'Check Ranking'
SELECT a.Sumsales,a.CourseID,b.CourseName,a.PreferredCategory, a.Rank   
FROM Staging.Ecampn02Rank_BundleSBP a,
	Mapping.DMCourse b
WHERE a.CourseID = b.CourseID
ORDER BY a.PreferredCategory, a.Rank

--delete from Staging.Ecampn02Rank_BundleSBP
--where rank > 100
/* and bundleflag = 1*/


/* update Ecampaigns.dbo.Ecampn02Rank_BundleSBP*/
/* set rank = case when rank <= 5 then rank + 5.12*/
/* 		else rank + 3.45*/
/* 		end*/
/* where bundleflag = 1*/

/* */
/* -- If Ranks are higher than 15, then float them up*/
/* IF @DeBugCode = 1 PRINT 'If Ranks are higher than 15 for Bundles, then float them up'*/
/* */

/* AND Bundleflag = 1*/


/* insert into Ecampaigns.dbo.Ecampn02Rank_BundleSBP values(0,7158, 'MSC',0.54,1)*/
/* insert into Ecampaigns.dbo.Ecampn02Rank_BundleSBP values(0,7158, 'VA',2.54,1)*/
/* insert into Ecampaigns.dbo.Ecampn02Rank_BundleSBP values(0,7158, 'LIT',4.1,1)*/
/* insert into Ecampaigns.dbo.Ecampn02Rank_BundleSBP values(0,7158, 'GEN',23.5,1)*/
/* insert into Ecampaigns.dbo.Ecampn02Rank_BundleSBP values(0,7158, 'HS',41,1)*/
/* insert into Ecampaigns.dbo.Ecampn02Rank_BundleSBP values(0,7158, 'MH',41,1)*/
/* insert into Ecampaigns.dbo.Ecampn02Rank_BundleSBP values(0,7158, 'MTH',18.59,1)*/
/* insert into Ecampaigns.dbo.Ecampn02Rank_BundleSBP values(0,7158, 'PH',21.23,1)*/
/* insert into Ecampaigns.dbo.Ecampn02Rank_BundleSBP values(0,7158, 'RL',41,1)*/
/* insert into Ecampaigns.dbo.Ecampn02Rank_BundleSBP values(0,7158, 'SCI',22.34,1)*/
/* insert into Ecampaigns.dbo.Ecampn02Rank_BundleSBP values(0,7158, 'X',41,1)*/


/*- STEP 3: Get the list of Emailable customers from the CustomerSignature Table*/
IF @DeBugCode = 1 PRINT 'Begin STEP 3: Get the list of Emailable customers that should receive Favorite Subject Email.'

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn03Customer01')
	DROP TABLE Staging.Ecampn03Customer01

SELECT ccs.Customerid,
	ccs.FirstName,
	ccs.LastName,
	ccs.EmailAddress,
	ccs.ComboID,
 	CASE WHEN ccs.CustomerSegment = 'Active' THEN @AdcodeActive
	     ELSE @AdcodeSwamp
	END AS AdCode,
	ccs.State AS Region, ccs.Countrycode,
	CASE WHEN ccs.customerSegment = 'Active' THEN @SubjectLineActive
	     ELSE @SubjectLineSwamp
	END  AS SubjectLine,
	CASE WHEN ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'SC' then 'SCI'
		when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'FA' then 'VA'
		when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory NOT IN ('SC','FA') then ccs.preferredcategory
		else ccs.PreferredCategory2 
	END as PreferredCategory,
	CASE WHEN ccs.customerSegment = 'Active' THEN @ECampaignIDActive
	     ELSE @ECampaignIDSwamp
	END AS ECampaignID
INTO Staging.Ecampn03Customer01
FROM Marketing.CampaignCustomerSignature ccs
WHERE ccs.FlagEmail = 1 AND EmailAddress LIKE '%@%'
AND ccs.PublicLibrary = 0
AND CCS.CountryCode = @CountryCode
/* AND ccs.CustomerSegment = 'Active'*/


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

/* -- Move them to a different table*/
/* PRINT 'Move Swamp and inquirers to another table'*/
/* select **/
/* into Ecampaigns.dbo.Ecampn03Customer01SwampInq*/
/* from Ecampaigns.dbo.Ecampn03Customer01*/
/* where adcode in (34829, 34830, 34831)*/
/* */
/* -- Delete Swampers and Inquirers*/
/* PRINT 'Delete Swampers and Inquirers'*/
/* DELETE FROM Ecampaigns.dbo.Ecampn03Customer01*/
/* WHERE Adcode IN (34829, 34830, 34831)*/




/*- STEP 4: Assign Courses and Ranks to each customer based on their preferred category*/
IF @DeBugCode = 1 PRINT 'Begin Step 4: Assign Courses and Ranks to each customer based on their preferred category'

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn03Customer02_CourseBundle')
	DROP TABLE Staging.Ecampn03Customer02_CourseBundle

SELECT a.Customerid,
	a.FirstName,
	a.LastName,
	a.EmailAddress,
	a.ComboID,
	er.CourseID,
	er.Rank,
	er.BundleFlag,
	a.Adcode,
	a.Region,
	a.CountryCode,
	a.SubjectLine,
	a.PreferredCategory,
	a.EcampaignID
INTO Staging.Ecampn03Customer02_CourseBundle
FROM Staging.Ecampn03Customer01 a,
	Staging.Ecampn02Rank_BundleSBP er
WHERE ISNULL(a.PreferredCategory,'GEN') = er.PreferredCategory


CREATE CLUSTERED INDEX IDX_Ecampn03Customer02_CourseBundle
ON Staging.Ecampn03Customer02_CourseBundle (Customerid)

CREATE INDEX IDX_Ecampn03Customer02_CourseBundle2
ON Staging.Ecampn03Customer02_CourseBundle (CourseID)

/*- STEP 5: Remove the courses FROM the customer list if they have already purchased them.*/
IF @DeBugCode = 1 PRINT 'STEP 5: Remove the courses from the customer list if they have already purchased them'

DELETE a
/*SELECT a.* */
FROM Staging.Ecampn03Customer02_CourseBundle a,
	(SELECT DISTINCT o.customerid, courseid
	FROM marketing.dmpurchaseorderitems oi
    join  Marketing.DMPurchaseOrders o on o.OrderID = oi.OrderID
	WHERE stockitemid LIKE '[PD][ACDMV]%'
	AND courseid IN (SELECT DISTINCT courseid FROM Staging.Ecampn02Rank_BundleSBP))b
WHERE a.customerid=b.customerid
AND a.courseid=b.courseid

/* Remove courses from ECon groups as they received DLR two days ago*/
/* DELETE A*/
/* FROM Ecampaigns.dbo.Ecampn03Customer02_CourseBundle a JOIN*/
/* 	(SELECT Distinct CustomerID, emailaddr*/
/* 	from lstmgr.dbo.Email_20090714_EconNewsletter_DLR_activeCOLO)b on a.emailaddress = b.emailaddr*/
/* where a.courseid in (528,529,561,562,1411,1423,1434,1499,5665,5932,3300,550,5620,7150,177,5610,1810,*/
/* 1487,1426,1495,1831,1413,1428,5612,1475,5933,1424)*/


/* DELETE a*/
/* --SELECT a.* */
/* FROM Ecampaigns.dbo.Ecampn03Customer02_CourseBundle a,*/
/* 	(SELECT DISTINCT customerid, courseid*/
/* 	FROM marketingdm.dbo.dmpurchaseorderitems*/
/* 	WHERE stockitemid LIKE '[PD][ACDMV]%'*/
/* 	AND courseid IN (SELECT DISTINCT courseid FROM Ecampaigns.dbo.Ecampn02Rank_BundleSBP))b*/
/* WHERE a.customerid=b.customerid*/
/* AND a.bundleID=b.courseid*/

/* STEP 5a: Remove Bundles from the customer list if they have already purchased courses from the bundle.*/
/* IF @DeBugCode = 1 PRINT 'STEP  5a: Remove Bundles from the customer list if they have already purchased courses from the bundle.'*/
/* DELETE a*/
/* -- Select a.**/
/* FROM Ecampaigns.dbo.Ecampn03Customer02_CourseBundle a JOIN*/
/* 	(SELECT DISTINCT OI.customerid, OI.courseid, B.BundleID*/
/* 	FROM marketingdm.dbo.dmpurchaseorderitems OI JOIN*/
/* 		Ecampaigns.dbo.Ecampn02A_BundleCourse B ON OI.courseID = B.courseID*/
/* 	WHERE stockitemid LIKE '[PD][ACDMV]%')C on a.CourseID = C.BundleID*/

IF @DeBugCode = 1 PRINT 'STEP  5a: Remove Bundles from the customer list if they have already purchased courses from the bundle.'
/* DELETE a*/
/* -- Select a.**/
/* FROM Ecampaigns.dbo.Ecampn03Customer02_CourseBundle100 a JOIN*/
/* 	(SELECT DISTINCT OI.customerid, OI.courseid, B.BundleID*/
/* 	FROM marketingdm.dbo.dmpurchaseorderitems OI JOIN*/
/* 		Ecampaigns.dbo.Ecampn02A_BundleCourse B ON OI.courseID = B.courseID*/
/* 	WHERE stockitemid LIKE '[PD][ACDMV]%')C on a.CourseID = C.BundleID*/


DECLARE @CourseIDRB INT
DECLARE MyCursorRB CURSOR FOR
SELECT Distinct CourseID
from Staging.Ecampn02A_BundleCourse

	OPEN MyCursorRB
	FETCH NEXT FROM MyCursorRB INTO @CourseIDRB
		
	WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT 'CourseID = ' + Convert(varchar,@CourseIDRB)

			Select distinct BundleID
			from Mapping.bundlecomponents
			where courseid = @CourseIDRB	

			delete a
/* select a.**/
			from Staging.Ecampn03Customer02_CourseBundle a JOIN
				(select distinct customerid
				from Marketing.completecoursepurchase
				where courseid = @CourseIDRB)b on a.customerid = b.customerid JOIN
				(Select distinct BundleID
				from Mapping.bundlecomponents
				where courseid = @CourseIDRB)C on A.CourseID = c.BundleID

			FETCH NEXT FROM MyCursorRB INTO @CourseIDRB
		END
	CLOSE MyCursorRB
	DEALLOCATE MyCursorRB

/* Move them to a different table*/
/* PRINT 'Move Swamp and inquirers to another table'*/
/* select **/
/* into Ecampaigns.dbo.Ecampn03Customer02_CourseBundleSwampInq*/
/* from Ecampaigns.dbo.Ecampn03Customer02_CourseBundle*/
/* where adcode in (34829, 34830, 34831)*/
/* */
/* -- Delete Swampers and Inquirers*/
/* PRINT 'Delete Swampers and Inquirers'*/
/* DELETE FROM Ecampaigns.dbo.Ecampn03Customer02_CourseBundle*/
/* WHERE Adcode IN (34829, 34830, 34831)*/
/* */
/* */
/*
-- STEP 5b: If there are multiple bundles with same courseid, remove dupes with higher ranks.
IF @DeBugCode = 1 PRINT 'STEP  5b: If there are multiple bundles with same courseid, remove all with higher ranks.'

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn03Customer02_CourseBundleTEMP')
	DROP TABLE Ecampaigns.dbo.Ecampn03Customer02_CourseBundleTEMP


DECLARE @BCourseID INT
DECLARE MyCurBundleDDupe CURSOR FOR
SELECT CourseID
from Ecampaigns.dbo.Ecampn02A_BundleCourse
group by Courseid
having count(courseid) > 1

	OPEN MyCurBundleDDupe

	FETCH NEXT FROM MyCurBundleDDupe INTO @BCourseID
		
	WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT 'CourseID = ' + Convert(varchar,@BCourseID)

			Select distinct BundleID
			from Ecampaigns.dbo.Ecampn02A_BundleCourse
			where courseid = @BCourseID	

			select a.*, convert(varchar,customerid) + convert(varchar,convert(int,rank)) RankID
			into Ecampaigns.dbo.Ecampn03Customer02_CourseBundleTEMP
			from Ecampaigns.dbo.Ecampn03Customer02_CourseBundle a JOIN
				(Select distinct BundleID
				from Ecampaigns.dbo.Ecampn02A_BundleCourse
				where courseid = @BCourseID)C on A.CourseID = c.BundleID

			delete a
			from Ecampaigns.dbo.Ecampn03Customer02_CourseBundle a JOIN
				(Select distinct BundleID
				from Ecampaigns.dbo.Ecampn02A_BundleCourse
				where courseid = @BCourseID)C on A.CourseID = c.BundleID
			
			create clustered index ix_temp1PR1 on Ecampaigns.dbo.Ecampn03Customer02_CourseBundleTEMP (customerid)
			create index ix_temp1PR2 on Ecampaigns.dbo.Ecampn03Customer02_CourseBundleTEMP (RankID)
			create index ix_temp1PR3 on Ecampaigns.dbo.Ecampn03Customer02_CourseBundleTEMP (rank)
			
			delete a
			from Ecampaigns.dbo.Ecampn03Customer02_CourseBundleTEMP a left outer join
				(select a.*
				from Ecampaigns.dbo.Ecampn03Customer02_CourseBundleTEMP a join
				(select CustomerID, min(rank) rank
				from Ecampaigns.dbo.Ecampn03Customer02_CourseBundleTEMP
				group by customerID)b on a.customerID = b.customerid and a.rank = b.rank)b on a.RankID = b.RankID
			where b.RankID is null

			insert into Ecampaigns.dbo.Ecampn03Customer02_CourseBundle
			select Customerid,  FirstName, LastName, EmailAddress, ComboID, CourseID,
				Rank, BundleFlag, Adcode,Region, SubjectLine, PreferredCategory, ECampaignID
			 from Ecampaigns.dbo.Ecampn03Customer02_CourseBundleTEMP

 			drop table Ecampaigns.dbo.Ecampn03Customer02_CourseBundleTEMP

			FETCH NEXT FROM MyCurBundleDDupe INTO @BCourseID
		END
	CLOSE MyCurBundleDDupe
	DEALLOCATE MyCurBundleDDupe
*/
/* */
/* -- STEP 5c: If there are more than max number of bundles, remove them.*/
/* IF @DeBugCode = 1 PRINT 'STEP 5c: If there are more than max number of bundles, remove them.'*/
/* */
/* -- Run this only if number of bundles is more than Max bundles*/
/* DECLARE @CountBundles INT*/
/* */
/* SELECT @CountBundles = COUNT(DISTINCT CourseID)*/
/* FROM Ecampaigns.dbo.Ecampn02Rank_BundleSBP*/
/* WHERE bundleflag = 1*/
/* */
/* IF @CountBundles > @MaxBundles*/
/*    BEGIN*/
/* 	*/
/* 	IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn03Customer02_BundlesOnly')*/
/* 		DROP TABLE Ecampaigns.dbo.Ecampn03Customer02_BundlesOnly*/
/* 	*/
/* 	SELECT a.*, Convert(float, 0) BundleRank*/
/* 	INTO Ecampaigns.dbo.Ecampn03Customer02_BundlesOnly*/
/* 	FROM Ecampaigns.dbo.Ecampn03Customer02_CourseBundle a JOIN*/
/* 		(SELECT Customerid, Sum(BundleFlag) TotalBundles*/
/* 		FROM Ecampaigns.dbo.Ecampn03Customer02_CourseBundle*/
/* 		GROUP BY CustomerID*/
/* 		HAVING Sum(BundleFlag) > @MaxBundles)b on A.Customerid = B.customerid*/
/* 	WHERE a.BundleFlag = 1*/
/* 	*/
/* 	CREATE Clustered index ix_Ecampn03Customer02_BundlesOnly1 on Ecampaigns.dbo.Ecampn03Customer02_BundlesOnly (Customerid)*/
/* 	CREATE index ix_Ecampn03Customer02_BundlesOnly2 on Ecampaigns.dbo.Ecampn03Customer02_BundlesOnly (Rank)*/
/* 	*/
/* 	IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn03Customer02_BundlesOnlyMax')*/
/* 		DROP TABLE Ecampaigns.dbo.Ecampn03Customer02_BundlesOnlyMax*/
/* 	*/
/* 	SELECT TOP 0 **/
/* 	INTO Ecampaigns.dbo.Ecampn03Customer02_BundlesOnlyMax*/
/* 	from Ecampaigns.dbo.Ecampn03Customer02_BundlesOnly*/
/* 	*/
/* 	CREATE Clustered index ix_Ecampn03Customer02_BundlesOnlyMax1 on Ecampaigns.dbo.Ecampn03Customer02_BundlesOnlyMax (Customerid)*/
/* 	CREATE index ix_Ecampn03Customer02_BundlesOnlyMax2 on Ecampaigns.dbo.Ecampn03Customer02_BundlesOnlyMax (Rank)*/
/* 	CREATE index ix_Ecampn03Customer02_BundlesOnlyMax3 on Ecampaigns.dbo.Ecampn03Customer02_BundlesOnlyMax (CourseID)*/
/* 	*/
/* 	SET NOCOUNT ON*/
/* 	*/
/* 	DECLARE @CustIDMaxB INT*/
/* 	DECLARE MyCursorMaxB CURSOR FOR*/
/* 	SELECT DISTINCT customerid */
/* 	FROM Ecampaigns.dbo.Ecampn03Customer02_BundlesOnly*/
/* 	*/
/* 		OPEN MyCursorMaxB*/
/* 		FETCH NEXT FROM MyCursorMaxB INTO @CustIDMaxB*/
/* 			*/
/* 		WHILE @@FETCH_STATUS = 0*/
/* 			BEGIN*/
/* 				SET ROWCOUNT @MaxBundles*/
/* 				INSERT INTO Ecampaigns.dbo.Ecampn03Customer02_BundlesOnlyMax*/
/* 				SELECT **/
/* 				FROM Ecampaigns.dbo.Ecampn03Customer02_CourseBundle*/
/* 				WHERE CustomerID = @CustIDMaxB*/
/* 				AND BundleFlag = 1*/
/* 				order by customerid, rank*/
/* 				SET ROWCOUNT 0*/
/* */
/* 				FETCH NEXT FROM MyCursorMaxB INTO @CustIDMaxB*/
/* 			END*/
/* 		CLOSE MyCursorMaxB*/
/* 		DEALLOCATE MyCursorMaxB*/
/* 	*/
/* 	SET NOCOUNT OFF*/
/* */
/* */
/* -- delete if ranked higher than the max*/
/* delete a*/
/* -- select a.**/
/* from Ecampaigns.dbo.Ecampn03Customer02_BundlesOnly a join*/
/* 	Ecampaigns.dbo.Ecampn03Customer02_BundlesOnlyMax b on a.customerid = b.customerid*/
/* 							and a.courseid = b.courseid*/
/* */
/* -- delete them from customer list*/
/* delete a*/
/* -- select a.**/
/* from Ecampaigns.dbo.Ecampn03Customer02_CourseBundle a join*/
/* 	Ecampaigns.dbo.Ecampn03Customer02_BundlesOnly b on a.customerid = b.customerid*/
/* 							and a.courseid = b.courseid*/
/* */
/*    END*/
/* */
/* */
/* */
/* */
/* */
/*- STEP 6: SELECT Max Number of Courses FROM the list.*/
IF @DeBugCode = 1 PRINT 'STEP 6: Select Max Number of Courses From the list'

/*--- STEP 6: SELECT Max Number of Courses FROM the list.*/
IF @DeBugCode = 1 PRINT 'STEP 6: Select Max Number of Courses From the list'

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn04Customer_Final_Bundle')
	DROP TABLE Staging.Ecampn04Customer_Final_Bundle

CREATE TABLE Staging.Ecampn04Customer_Final_Bundle
(Customerid udtCustomerID NOT NULL,
FirstName VARCHAR(50) NULL,
LastName VARCHAR(50) NULL,
EmailAddress VARCHAR(50) NULL,
ComboID VARCHAR(30) NULL,
CourseID INT NULL,
Rank FLOAT NULL,
BundleFlag TinyInt Null,
Adcode INT NULL,
Region VARCHAR(50) NULL,
CountryCode varchar(3) NULL,
SubjectLine VARCHAR(200) NULL,
PreferredCategory VARCHAR(5) NULL,
ECampaignID VARCHAR(25) NULL)

CREATE CLUSTERED INDEX IDX_customer_Ecamp04Fnl
ON Staging.Ecampn04Customer_Final_Bundle (Customerid)


IF @DeBugCode = 1 PRINT 'STEP 6: Rerank the course list to put them in order'

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn03Customer02_CourseBundle2')
	DROP TABLE Staging.Ecampn03Customer02_CourseBundle2

select *, rank() over (partition by customerid order by rank) as Rank2
into Staging.Ecampn03Customer02_CourseBundle2
from Staging.Ecampn03Customer02_CourseBundle


CREATE INDEX ix_Ecampn03Customer02_CourseBundle21 on Staging.Ecampn03Customer02_CourseBundle2 (Customerid)
CREATE INDEX ix_Ecampn03Customer02_CourseBundle22 on Staging.Ecampn03Customer02_CourseBundle2 (rank2)


INSERT INTO Staging.Ecampn04Customer_Final_Bundle
SELECT Customerid, FirstName, LastName, EmailAddress, 
	ComboID, CourseID, Rank2 As Rank, BundleFlag, Adcode, Region, CountryCode, 
	SubjectLine, PreferredCategory, ECampaignID 
FROM Staging.Ecampn03Customer02_CourseBundle2
WHERE rank2 <= 25


/*
IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn04Customer_Final_Bundle')
	DROP TABLE Ecampaigns.dbo.Ecampn04Customer_Final_Bundle

CREATE TABLE Ecampaigns.dbo.Ecampn04Customer_Final_Bundle
(Customerid INT NOT NULL,
FirstName VARCHAR(50) NULL,
LastName VARCHAR(50) NULL,
EmailAddress VARCHAR(50) NULL,
ComboID VARCHAR(30) NULL,
CourseID INT NULL,
Rank FLOAT NULL,
BundleFlag TinyInt Null,
Adcode INT NULL,
Region VARCHAR(2) NULL,
SubjectLine VARCHAR(200) NULL,
PreferredCategory VARCHAR(5) NULL,
ECampaignID VARCHAR(25) NULL)

CREATE CLUSTERED INDEX IDX_customer_Ecamp04Fnl
ON Ecampaigns.dbo.Ecampn04Customer_Final_Bundle (Customerid)

SET NOCOUNT ON

IF @CourseCount > @MaxCourse
   BEGIN
	DECLARE @CustID INT
	DECLARE MyCursor CURSOR FOR
	SELECT DISTINCT customerid 
	FROM Ecampaigns.dbo.Ecampn03Customer02_CourseBundle
	
		OPEN MyCursor
		FETCH NEXT FROM MyCursor INTO @CustID
			
		WHILE @@FETCH_STATUS = 0
			BEGIN
				SET ROWCOUNT @MaxCourse
				INSERT INTO Ecampaigns.dbo.Ecampn04Customer_Final_Bundle
				SELECT * 
				FROM Ecampaigns.dbo.Ecampn03Customer02_CourseBundle
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
	INSERT INTO Ecampaigns.dbo.Ecampn04Customer_Final_Bundle
	SELECT * 
	FROM Ecampaigns.dbo.Ecampn03Customer02_CourseBundle
   END

SET NOCOUNT OFF
*/

/* -- */
/* -- /**/
/* -- IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn04Customer_Final_Bundle_New')*/
/* -- 	DROP TABLE Ecampaigns.dbo.Ecampn04Customer_Final_Bundle_New*/
/* -- */
/* -- SELECT ECC.*, ECCSeq.SeqNum*/
/* -- INTO Ecampaigns.dbo.Ecampn04Customer_Final_Bundle_New*/
/* -- FROM Ecampaigns.dbo.Ecampn03Customer02_CourseBundle ECC JOIN*/
/* --             (SELECT ECC1.CUSTOMERID, ECC1.RANK, */
/* -- 			SUM(CASE WHEN ECC2.RANK <= ECC1.RANK THEN 1 ELSE 0 END) SEQNUM */
/* --              FROM Ecampaigns.dbo.Ecampn03Customer02_CourseBundle ECC1 JOIN*/
/* -- 	             Ecampaigns.dbo.Ecampn03Customer02_CourseBundle ECC2*/
/* -- 	            ON ECC1.CUSTOMERID = ECC2.CUSTOMERID*/
/* --              GROUP BY ECC1.CUSTOMERID, ECC1.RANK) ECCSEQ*/
/* --      ON ECCSEQ.CUSTOMERID = ECC.CUSTOMERID */
/* -- 	AND ECCSEQ.RANK = ECC.RANK AND ECCSEQ.SEQNUM <= @MaxCourse*/
/* -- ORDER BY ECC.CustomerID,  ECC.Rank*/
/* -- */
/* -- */
/* -- CREATE CLUSTERED INDEX IDX_customer_Ecamp04FnlNew*/
/* -- ON Ecampaigns.dbo.Ecampn04Customer_Final_BundleNew (Customerid)*/
/* -- */*/
/* --- STEP 7: Delete customers having less than 5 courses to offer.*/
/* */
IF @DeBugCode = 1 PRINT 'STEP 7: Delete customers having less than 5 courses to offer'

DELETE FROM Staging.Ecampn04Customer_Final_Bundle
WHERE CustomerID IN 
		(SELECT CustomerID
		FROM Staging.Ecampn04Customer_Final_Bundle
		GROUP BY CustomerID
		HAVING COUNT(*) < 5)
/* -- */
/* -- -- DELETE FROM Ecampaigns.dbo.Ecampn04Customer_Final_Bundle_New*/
/* -- -- WHERE CustomerID IN */
/* -- -- 		(SELECT CustomerID*/
/* -- -- 		FROM Ecampaigns.dbo.Ecampn04Customer_Final_Bundle_New*/
/* -- -- 		GROUP BY CustomerID*/
/* -- -- 		HAVING COUNT(*) < 5)*/
/* -- */
/* -- */
/* -- */
/* -- --- STEP 8: Generate Reports*/
/* -- SET ROWCOUNT 0*/
/* -- IF @DeBugCode = 1 PRINT 'STEP 8: Generate Reports'*/
/* -- */
/*- Report1: Ranking check report*/

SELECT a.Sumsales,a.CourseID,b.CourseName,a.PreferredCategory, a.Rank   
FROM Staging.Ecampn02Rank_BundleSBP a,
	Mapping.DMCourse b
WHERE a.CourseID = b.CourseID
ORDER BY a.PreferredCategory, a.Rank
/* -- */
/* -- -- --- Report2: Counts by RFM Cells*/
/* -- -- */
/* -- -- -- SELECT csm.newseg,csm.name,rds.a12mf,COUNT(DISTINCT mct.customerid) AS CountOfCustomers*/
/* -- -- -- FROM Ecampaigns.dbo.Ecampn04Customer_Final_Bundle mct,*/
/* -- -- -- 	rfm..customersubjectmatrix csm,*/
/* -- -- -- 	rfm..rfm_data_special rds*/
/* -- -- -- WHERE mct.customerid=csm.customerid*/
/* -- -- -- 	and csm.customerid=rds.customerid*/
/* -- -- -- GROUP BY csm.newseg,csm.name,rds.a12mf*/
/* -- -- -- order by csm.newseg,csm.name,rds.a12mf*/
/* -- -- -- */
/* -- -- -- --- Report3: Count by AdCode and SubjectLine*/
/* -- -- -- */
/* -- -- -- SELECT fnl.AdCode, mac.Name, Fnl.EcampaignID,*/
/* -- -- -- 	fnl.SubjectLine,*/
/* -- -- -- 	COUNT(fnl.Customerid) AS TotalCount,*/
/* -- -- -- 	COUNT(DISTINCT fnl.Customerid) AS UniqueCustCount*/
/* -- -- -- FROM Ecampaigns.dbo.Ecampn04Customer_Final_Bundle fnl LEFT OUTER JOIN*/
/* -- -- -- 	Superstardw.dbo.MktAdcodes mac ON fnl.adcode = mac.adcode*/
/* -- -- -- GROUP BY fnl.AdCode, mac.Name, Fnl.EcampaignID, fnl.SubjectLine*/
/* -- -- -- ORDER BY fnl.AdCode*/
/* -- -- -- */
/* -- -- -- --- Generate Customer and Course information for Instruction files*/
/* -- -- -- SELECT DISTINCT c.customerid,d.firstname,d.lastname,c.PreferredCategory,c.adcode*/
/* -- -- -- FROM (SELECT MAX(DISTINCT customerid) AS customerid, PreferredCategory, Adcode*/
/* -- -- -- 	FROM Ecampaigns.dbo.Ecampn04Customer_Final_Bundle*/
/* -- -- -- 	GROUP BY PreferredCategory, Adcode)c,*/
/* -- -- -- 	Ecampaigns.dbo.Ecampn04Customer_Final_Bundle d*/
/* -- -- -- WHERE c.customerid=d.customerid*/
/* -- -- -- ORDER BY c.adcode, c.PreferredCategory, c.customerid*/
/* -- -- */
/* -- -- /*SELECT DISTINCT c.customerid,d.firstname,d.lastname,c.PreferredCategory,c.adcode*/
/* -- -- FROM (SELECT MAX(DISTINCT a.customerid) AS customerid,*/
/* -- -- 		b.PreferredCategory,a.Adcode*/
/* -- -- 	FROM Ecampaigns.dbo.Ecampn04Customer_Final_Bundle  a,*/
/* -- */
/* -- -- 		Ecampaigns.dbo.Ecampn03Customer01 b*/
/* -- -- 	WHERE a.customerid=b.customerid*/
/* -- -- 	GROUP BY b.PreferredCategory,a.Adcode)c,*/
/* -- -- 	Ecampaigns.dbo.Ecampn04Customer_Final_Bundle d*/
/* -- -- WHERE c.customerid=d.customerid*/
/* -- -- ORDER BY c.adcode, c.PreferredCategory, c.customerid*/*/
/* -- -- */
/* -- -- SELECT DISTINCT CourseID*/
/* -- -- FROM Ecampaigns.dbo.Ecampn02Rank_BundleSBP*/
/* -- -- */
/* -- -- --- Add Customer data to Email History Table  */
/* -- -- */
/* -- -- IF @Test = 'NO'*/
/* -- -- BEGIN*/
/* -- -- 	IF @DeBugCode = 1 PRINT 'Add Customer data to Email History Table'*/
/* -- -- 	INSERT INTO Ecampaigns.dbo.EmailHistory*/

/* -- -- 	(CustomerID,Adcode,StartDate)*/
/* -- -- 	SELECT Customerid,*/
/* -- -- 		Adcode,*/
/* -- -- 		@DropDate AS StartDate*/
/* -- -- 	FROM Ecampaigns.dbo.Ecampn03Customer01*/
/* -- -- END*/
/* -- -- */
/*- Create Final table*/
IF @DeBugCode = 1 PRINT 'Create Final Tables'

DECLARE @Qry VARCHAR(8000)



/*- Drop if @FnlTablActive already exists*/
/*
DECLARE @RowCounts INT
SELECT @RowCounts = COUNT(*) FROM sysobjects
WHERE Name = @FnlTable
SELECT '@RowCounts = ' + CONVERT(VARCHAR,@RowCounts)


IF @RowCounts > 0
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
	   ' FROM Staging.Ecampn04Customer_Final_Bundle'

EXEC (@Qry)


/*- Create Index on @FnlTable*/
DECLARE @FnlIndex VARCHAR(50)

SET @FnlIndex = 'IDX_' + REPLACE(@FnlTable,'Ecampaigns.dbo.','')

SELECT 'Create Index'
SET @Qry = 'CREATE CLUSTERED INDEX ' + @FnlIndex + ' ON ' + @FnlTable + '(CustomerID)'
EXEC (@Qry)

/*
--- Drop if @FnlTablActive already exists
DECLARE @RowCounts INT
SELECT @RowCounts = COUNT(*) FROM sysobjects
WHERE Name = @FnlTableActive
SELECT '@RowCounts = ' + CONVERT(VARCHAR,@RowCounts)

IF @RowCounts > 0

BEGIN
	SET @Qry = 'DROP TABLE Ecampaigns.dbo.' + @FnlTableActive
	SELECT @Qry
	EXEC (@Qry)
END


SET @Qry = 'SELECT *
	    INTO ' + @FnlTableActive +
	   ' FROM Ecampaigns.dbo.Ecampn04Customer_Final_Bundle
	    WHERE Adcode = ' + CONVERT(VARCHAR,@AdcodeActive)

EXEC (@Qry)


--- Create Index on @FnlTable
DECLARE @FnlIndex VARCHAR(50)

SET @FnlIndex = 'IDX_' + REPLACE(@FnlTableActive,'rfm.dbo.','')

SELECT 'Create Index'
SET @Qry = 'CREATE CLUSTERED INDEX ' + @FnlIndex + ' ON ' + @FnlTableActive + '(CustomerID)'
EXEC (@Qry)

--- Drop if @FnlTablSNI already exists

SELECT @RowCounts = COUNT(*) FROM sysobjects
WHERE Name = @FnlTableSNI
SELECT '@RowCounts = ' + CONVERT(VARCHAR,@RowCounts)

IF @RowCounts > 0
BEGIN
	SET @Qry = 'DROP TABLE Ecampaigns.dbo.' + @FnlTableSNI
	SELECT @Qry
	EXEC (@Qry)
END


SET @Qry = 'SELECT *
	    INTO ' + @FnlTableSNI +
	   ' FROM Ecampaigns.dbo.Ecampn04Customer_Final_Bundle
	    WHERE Adcode <> ' + CONVERT(VARCHAR,@AdcodeActive)

EXEC (@Qry)


--- Create Index on @FnlTable


SET @FnlIndex = 'IDX_' + REPLACE(@FnlTableSNI,'rfm.dbo.','')

SELECT 'Create Index'
SET @Qry = 'CREATE CLUSTERED INDEX ' + @FnlIndex + ' ON ' + @FnlTableSNI + '(CustomerID)'
EXEC (@Qry)
*/

IF @DeBugCode = 1 PRINT 'END Ecampaigns.dbo.CampaignEmail_FvrtSubjNew_BundlesSalesBYPart'
GO
