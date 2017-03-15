SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [Staging].[CampaignEmail_FvrtSubjNew_BundlesSalesBYAvg]
	@EmailCatalogCode INT,
	@EmailCatalogCodeSwamp INT = 8804,
	@EmailCatalogCodeInt INT = 8805,
	@EmailCatalogCodeInquirer INT = 8806,
	@EmailCatalogCodeCanada INT = 13631,
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

SELECT @FnlTable = 'Email' + CONVERT(VARCHAR,@DropDate,112) + '_Offers_FSBundle'
FROM Staging.MktCatalogCodes
WHERE CatalogCode = @EmailCatalogCode

SELECT @FnlTableSNI1 = 'Email' + CONVERT(VARCHAR,@DropDateSNI,112) + '_Offers_FSBundle'
FROM Staging.MktCatalogCodes
WHERE CatalogCode = @EmailCatalogCode

DECLARE @FnlTableActive VARCHAR(100)
DECLARE @FnlTableSNI VARCHAR(100)

SELECT @FnlTableActive = 'Ecampaigns.dbo.' + @FnlTable + '_Active'
SELECT @FnlTableSNI = 'Ecampaigns.dbo.' + @FnlTableSNI1 + '_SNI'

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
	Convert(int, 0) as CourseParts,
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
from Mapping.BundleComponents BC JOIN
	(SELECT DISTINCT BC.BundleID
	FROM Staging.MktPricingMatrix MPM JOIN
		Staging.InvItem II ON MPM.UserStockItemID = II.StockItemID JOIN
		Mapping.BundleComponents BC ON II.CourseID = BC.BundleID
	WHERE MPM.CatalogCode = (@EmailCatalogCode))B on BC.BundleID = B.BundleID JOIN
	Mapping.DMcourse MC1 ON BC.BundleID = MC1.CourseID JOIN
	Mapping.DMcourse MC2 ON BC.CourseID = MC2.CourseID
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
/* set rank = rank/2.08*/
/* where bundleflag = 1*/
/*and preferredcategory not in ('AH', 'RL')*/

/* Update SumSales to reflect by parts information*/
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

/* Force 90% off courses to the top*/

--UPDATE Staging.Ecampn02Rank_BundleSBP
--SET Rank = rank/23.5
--WHERE CourseID IN (1520,1401,6410)


/*QC before rank update---*/
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




 /*Force ranks for some courses to top*/
 /*UPDATE Ecampaigns.dbo.Ecampn02Rank_BundleSBP*/
 /*SET Rank = case when rank between 7.0 and 19.0 then Rank/1.56*/
 /*		when rank between 20.0 and 50.0 then rank/2.56*/
 /*		when rank between 50.0 and 75.0 then rank/3.56*/
 /*		when rank between 76.0 and 100.0 then rank/4.568*/
 /*		when rank>100.0 then rank/5.89*/
 /*		else rank*/
 /*	end */
 /*--WHERE CourseID IN (1830,1426,7158,4242,3480,6450,5620,2270,8598)*/
 /*where courseid in (2031,1540,1471,6220,7868,7290)*/
 
  
 /*Force ranks for some courses to top*/
 
 /*UPDATE Ecampaigns.dbo.Ecampn02Rank_BundleSBP*/
 /*SET Rank = Rank/3.21*/
 /*--WHERE CourseID IN (1830,1426,7158,4242,3480,6450,5620,2270,8598)*/
 /*where courseid in (2032,1541,1472,6221,7869,6643,650,7291,7264,7241,7511,7106,5935,5621,5668,4362,4611,4166,2271,269,3151,8325,391,8598,8871,8516)*/
 
 
/* PRINT 'Float courses lower in ranking'*/
/* UPDATE Ecampaigns.dbo.Ecampn02Rank_BundleSBP*/
/* --set rank = rank/3.51*/
/* set rank = rank+25.1*/
/* -- SET Rank = case when rank > 10.0 then rank/4.51*/
/* -- 		else rank*/
/* -- 	end */
/* WHERE CourseID IN (237,273,301,302,337,349,363,367,480,690,888,893,1240,1284,1546,1620,2120,2353,2390,2539,3174,3300,3356,3430,3650,3940,4863,6121,6206,6299,6627,7210,8100,8190,8270,8296,8467,8490,8520,8570)*/
/*-- select * from Ecampaigns.dbo.Ecampn02Rank_BundleSBP*/

/* UPDATE Ecampaigns.dbo.Ecampn02Rank_BundleSBP*/
/* set rank = rank / 2.58*/
/* where bundleflag = 0*/
/**/

/*UPDATE Ecampaigns.dbo.Ecampn02Rank_BundleSBP*/
/*SET Rank = rank/2.1*/
/*WHERE CourseID IN (6221,6220,2032,2031,1541,1540,6643,7869,*/
/*7868,7291,7290,1472,1471)*/

/*- If Ranks are higher than 10 for New Courses, then float them up*/
IF @DeBugCode = 1 PRINT 'If Ranks are higher than 10 for New Courses, then float them up'



PRINT 'Check Ranking'
SELECT a.Sumsales,a.CourseID,b.CourseName,a.PreferredCategory, a.Rank   
FROM Staging.Ecampn02Rank_BundleSBP a,
	Mapping.DMCourse b
WHERE a.CourseID = b.CourseID
ORDER BY a.PreferredCategory, a.Rank

/*delete from Ecampaigns.dbo.Ecampn02Rank_BundleSBP*/
/*where rank > 100*/
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
		else ccs.PreferredCategory2 
	END as PreferredCategory,
	CASE WHEN ccs.customerSegment = 'Active' THEN @ECampaignIDActive
	     ELSE @ECampaignIDSwamp
	END AS ECampaignID,
    ccs.CustomerSegmentNew
INTO Staging.Ecampn03Customer01
FROM Marketing.CampaignCustomerSignature ccs
WHERE ccs.FlagEmail = 1 AND ccs.BuyerType > 1 AND EmailAddress LIKE '%@%'
AND ccs.PublicLibrary = 0
AND ccs.CountryCode not in ( 'GB','AU')
/* AND ccs.CustomerSegment = 'Active'*/

/* Add Inquirers*/
IF @DeBugCode = 1 PRINT 'Add Inquirers'

IF @FlagIntnl = 'YES' 
   BEGIN
	INSERT INTO Staging.Ecampn03Customer01
	(Customerid, FirstName, LastName, EmailAddress, ComboID, Adcode, Region, CountryCode, SubjectLine, 
	PreferredCategory, ECampaignID, CustomerSegmentNew)
	SELECT CCS.CustomerID, Staging.proper(CCS.FirstName) FirstName,
		Staging.proper(CCS.LastName) LastName, CCS.EmailAddress, 
		CASE WHEN ccs.ComboID IN ('25-10000 Mo Inq Plus', 'Inq') THEN '25-10000 Mo Inq'
		     ELSE CCS.ComboID
		END AS ComboID, 
		@AdcodeInq as Adcode, 
		ISNULL(State,'') AS Region, ccs.CountryCode,
		@SubjectLineSwamp AS SubjectLine, 
		'GEN' AS PreferredCategory,
		@ECampaignIDInq AS ECampaignID,
        ccs.CustomerSegmentNew
	FROM Marketing.CampaignCustomerSignature CCS LEFT OUTER JOIN
		Staging.Ecampn03Customer01 EC01 ON CCS.CustomerID = EC01.CustomerID
	WHERE EC01.CustomerID IS NULL AND ccs.Buyertype = 1 AND ccs.FlagEmail = 1 AND ccs.PublicLibrary = 0
			AND ccs.CountryCode not in ('GB', 'AU')
			
			
/* Delete if there are still from GB*/
DELETE FROM Staging.Ecampn03Customer01
WHERE CountryCode in ('GB', 'AU')

DELETE A
from Staging.Ecampn03Customer01 a join
	(select * from marketingdm..campaigncustomersignature
	where countrycode = 'GB')b on a.emailaddress = b.emailaddress
	
/* Delete if there are still from AU*/
/*DELETE FROM Ecampaigns.dbo.Ecampn03Customer01*/
/*WHERE CountryCode = 'AU'*/


DELETE A
from Staging.Ecampn03Customer01 a join
	(select * from marketingdm..campaigncustomersignature
	where countrycode = 'AU'
	and CustomerSince >= '9/1/2010')b on a.emailaddress = b.emailaddress


DELETE A
from Staging.Ecampn03Customer01 a join
	(select * from marketingdm..campaigncustomersignature
	where countrycode = 'AU'
	and CustomerSince >= '9/1/2010')b on a.CustomerID = b.CustomerID
		
				
/*- Update AdCode for International customers*/

IF @DeBugCode = 1 PRINT 'Update AdCode for International customers'


UPDATE EC01
SET Adcode = @AdcodeIntnl
FROM Staging.Ecampn03Customer01 EC01 
WHERE EC01.CountryCode NOT LIKE '%US%'
AND EC01.CountryCode IS NOT NULL
AND EC01.CountryCode <> ''

/*
UPDATE EC01
SET Adcode = @AdcodeIntnl
FROM Ecampaigns.dbo.Ecampn03Customer01 EC01 JOIN
	MarketingDM.dbo.CampaignCustomerSignature CCS ON CCS.CustomerID = EC01.CustomerID
WHERE CCS.CountryCode NOT LIKE '%US%'
AND CCS.CountryCode IS NOT NULL
AND CCS.CountryCode <> ''
*/

IF @DeBugCode = 1 PRINT 'Update AdCode for Canada customers' /* Added on 6/9/2010*/

UPDATE EC01
SET Adcode = @AdcodeCanada
FROM Staging.Ecampn03Customer01 EC01 
WHERE EC01.CountryCode LIKE '%CA%'

/*
--- Update Adcode for Customers without any subject preference
IF @DeBugCode = 1 PRINT 'Update Adcode for Customers without any subject preference'

UPDATE Ecampaigns.dbo.Ecampn03Customer01
SET AdCode = @AdcodeNoSubjPref
WHERE PreferredCategory IS NULL */

CREATE CLUSTERED INDEX IDX_customer_Ecamp03Cust01
ON Staging.Ecampn03Customer01 (Customerid)



/* Add Web Inquirers*/
/* 	IF @DeBugCode = 1 PRINT 'Add Web Inquirers'*/
/* */
/* 	IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Email_WebInq')*/
/* 		DROP TABLE Ecampaigns.dbo.Email_WebInq*/
/* 	*/
/* 	SELECT C.CustomerID, MarketingDM.dbo.proper(C.FirstName) FirstName,*/
/* 		MarketingDM.dbo.proper(C.LastName) LastName, C.EmailAddress, 'WebInqs' AS ComboID,*/
/* 		@AdcodeWebInq as Adcode, */
/* 		convert(varchar(2),'') as Region,*/
/* 		@SubjectLineSwamp AS SubjectLine,*/
/* 		'GEN' AS PreferredCategory, */
/* 		@ECampaignIDWebInq AS ECampaignID*/
/* 	INTO ECampaigns.dbo.Email_WebInq	*/
/* 	FROM Superstardw.dbo.Customers C LEFT OUTER JOIN	*/
/* 		MarketingDM.dbo.CampaignCustomerSignature CCS ON C.CustomerID = CCS.CustomerID*/
/* 		JOIN*/
/* 		(SELECT CustomerID*/
/* 		FROM Superstardw.dbo.AcctPreferences*/
/* 		WHERE PreferenceID = 'OfferEmail'*/
/* 		AND PreferenceValue = 1)AP ON C.CustomerID = AP.CustomerID*/
/* 	WHERE CCS.CustomerID IS NULL AND C.EmailAddress LIKE '%@%'	*/
/* 	AND C.EmailAddress not Like '%teachco.com' AND C.organization_key is null*/
/* 	*/
/* 	*/
/* 	INSERT INTO Ecampaigns.dbo.Ecampn03Customer01*/
/* 	(Customerid, FirstName, LastName, EmailAddress, ComboID, Adcode, Region, SubjectLine, */
/* 	PreferredCategory, ECampaignID)*/
/* 	SELECT WI.**/
/* 	FROM ECampaigns.dbo.Email_WebInq WI LEFT OUTER JOIN*/
/* 		Ecampaigns.dbo.Ecampn03Customer01 EC01 on WI.Customerid = EC01.CustomerID*/
/* 	WHERE EC01.CustomerID IS NULL*/
   END



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
 /*PRINT 'Delete Swampers and Inquirers'*/
 /*DELETE FROM Ecampaigns.dbo.Ecampn03Customer01*/
 /*WHERE Adcode IN (27838, 27841)*/


/* For 7/17/2010 email test -- if they are in test, drop them*/


/*delete a*/
/*from Ecampn03Customer01 a join*/
/*	(select distinct customerid, emailaddr from Lstmgr.dbo.Email_20100724_35Under35_Active */
/*		where customerid>0*/
/*union*/
/*select distinct customerid, emailaddr from Lstmgr.dbo.Email_20100724_35Under35_SNI */
/*		where customerid>0) b*/
/*	 on a.customerid = b.customerid*/
/**/
/*delete a*/
/*from Ecampn03Customer01 a join*/
/*	(select distinct customerid, emailaddr from Lstmgr.dbo.Email_20100724_35Under35_Active */
/*		where customerid>0*/
/*union*/
/*select distinct customerid, emailaddr from Lstmgr.dbo.Email_20100724_35Under35_SNI */
/*		where customerid>0) b*/
/*	 on a.emailaddress = b.emailaddr*/


select count(customerid)
from Staging.Ecampn03Customer01

/* Drop Unsubscribes and other IDs that should not receive the emails.*/
exec Staging.CampaignEmail_RemoveUnsubs 'Ecampn03Customer01'

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
	a.Region, a.CountryCode,
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
    join marketing.DMPurchaseOrders o on o.OrderID = oi.OrderID
	WHERE stockitemid LIKE '[PD][ACDMV]%'
	AND courseid IN (SELECT DISTINCT courseid FROM Staging.Ecampn02Rank_BundleSBP))b
WHERE a.customerid=b.customerid
AND a.courseid=b.courseid

-- Remove Test bundles from control group and control bundle from test group
/*remove July sets tes vs control sets from the customer groups 7/24/2013 - Sri
  delete a
    from Staging.Ecampn03Customer02_CourseBundle a
    join 
    (select  * from rfm.dbo.Mail_US_JulSetsMailing_20130705 where adcode<>83943) b
    on a.customerid=b.customerid where
    a.courseid in (5914,4255,9958,1943,1962,9959,2158,2144,9960,5725,5631,9961,7821,9962,1818,1897,9963)
    
      delete a
    from Staging.Ecampn03Customer02_CourseBundle a
    join 
    (select  * from rfm.dbo.Mail_US_JulSetsMailing_20130705 where adcode=83943) b
    on a.customerid=b.customerid where
    a.courseid in (650,6265,9941,4624,9942,1655,1912,9935,7869,8412,392,9909,1853,9815,9937,1973,7264)
    
    */


 /*DELETE A*/
 /*FROM Ecampaigns.dbo.Ecampn03Customer02_CourseBundle a JOIN*/
 /*	(SELECT Distinct CustomerID, emailaddress*/
 /*	from rfm..BigSetsRecipients)b on a.CustomerID = b.CustomerID*/
 /*where a.courseid in (1253,1593,1842,2404,3305,5667,7241,7545,8282,8511,8871,8895)*/
 
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
IF @DeBugCode = 1 PRINT 'STEP  5a: Remove Bundles from the customer list if they have already purchased courses from the bundle.'


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
/* STEP 5b: If there are multiple bundles with same courseid, remove dupes with higher ranks.*/
/*IF @DeBugCode = 1 PRINT 'STEP  5b: If there are multiple bundles with same courseid, remove all with higher ranks.'

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
	DEALLOCATE MyCurBundleDDupe*/
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

/*--- STEP 6: SELECT Max Number of Courses FROM the list.*/
IF @DeBugCode = 1 PRINT 'STEP 6: Select Max Number of Courses From the list'

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn04Customer_Final_Bundle')
	DROP TABLE Staging.Ecampn04Customer_Final_Bundle

CREATE TABLE Staging.Ecampn04Customer_Final_Bundle
(Customerid udtCustomerID NOT NULL,
FirstName VARCHAR(50) NULL,
LastName VARCHAR(50) NULL,
EmailAddress VARCHAR(60) NULL,
ComboID VARCHAR(30) NULL,
CourseID INT NULL,
Rank FLOAT NULL,
BundleFlag TinyInt Null,
Adcode INT NULL,
Region VARCHAR(40) NULL,
CountryCode varchar(3) NULL,
SubjectLine VARCHAR(200) NULL,
PreferredCategory VARCHAR(5) NULL,
ECampaignID VARCHAR(30) NULL)

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

/*SET NOCOUNT ON*/

/*IF @CourseCount > @MaxCourse*/
/*   BEGIN*/
/*	DECLARE @CustID INT*/
/*	DECLARE MyCursor CURSOR FOR*/
/*	SELECT DISTINCT customerid */
/*	FROM Ecampaigns.dbo.Ecampn03Customer02_CourseBundle*/
	
/*		OPEN MyCursor*/
/*		FETCH NEXT FROM MyCursor INTO @CustID*/
			
/*		WHILE @@FETCH_STATUS = 0*/
/*			BEGIN*/
/*				SET ROWCOUNT @MaxCourse*/
/*				INSERT INTO Ecampaigns.dbo.Ecampn04Customer_Final_Bundle*/
/*				SELECT * */
/*				FROM Ecampaigns.dbo.Ecampn03Customer02_CourseBundle*/
/*				WHERE CustomerID = @CustID*/
/*				ORDER BY CustomerID, Rank, CourseID*/
/*				SET ROWCOUNT 0*/
/*				FETCH NEXT FROM MyCursor INTO @CustID*/
/*			END*/
/*		CLOSE MyCursor*/
/*		DEALLOCATE MyCursor*/
/*   END*/
/*ELSE*/
/*   BEGIN*/
/*	INSERT INTO Ecampaigns.dbo.Ecampn04Customer_Final_Bundle*/
/*	SELECT * */
/*	FROM Ecampaigns.dbo.Ecampn03Customer02_CourseBundle*/
/*   END*/

/*SET NOCOUNT OFF*/


IF @DeBugCode = 1 PRINT 'STEP 7: Delete customers having less than 5 courses to offer'

DELETE FROM Staging.Ecampn04Customer_Final_Bundle
WHERE CustomerID IN 
		(SELECT CustomerID
		FROM Staging.Ecampn04Customer_Final_Bundle
		GROUP BY CustomerID
		HAVING COUNT(*) < 5)


  /* STEP 8: Generate Report*/
  SET ROWCOUNT 0
  IF @DeBugCode = 1 PRINT 'STEP 8: Generate Report'
  
  /*Report1: Ranking check report*/

SELECT a.Sumsales,a.CourseID,b.CourseName,a.PreferredCategory, a.Rank   
FROM Staging.Ecampn02Rank_BundleSBP a,
	Mapping.DMCourse b
WHERE a.CourseID = b.CourseID
ORDER BY a.PreferredCategory, a.Rank

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
	   ' FROM Staging.Ecampn04Customer_Final_Bundle
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
	   ' FROM Staging.Ecampn04Customer_Final_Bundle
	    WHERE Adcode not in (' + CONVERT(VARCHAR,@AdcodeActive) + ', ' + convert(varchar, isnull(@AdcodeCanada, 0)) + ', ' + convert(varchar, isnull(@AdcodeIntnl, 0)) + ')'

EXEC (@Qry)


/*- Create Index on @FnlTable*/


SET @FnlIndex = 'IDX_' + REPLACE(@FnlTableSNI,'Ecampaigns.dbo.','')

SELECT 'Create Index'
SET @Qry = 'CREATE CLUSTERED INDEX ' + @FnlIndex + ' ON ' + @FnlTableSNI + '(CustomerID)'
EXEC (@Qry)


IF @DeBugCode = 1 PRINT 'END Staging.CampaignEmail_FvrtSubjNew_BundlesSalesBYPart'
GO
