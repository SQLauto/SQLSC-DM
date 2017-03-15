SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  PROC [Staging].[CampaignEmail_GetRanking_FSBundleByAvrg]
	@EmailCatalogCode INT,
	@PriorMonths INT = -3,
	@DebugCode INT = 1
AS

DECLARE @ErrorMsg VARCHAR(8000)

--- Check to make sure CatalogCodes are provided by the user.
IF @DeBugCode = 1 PRINT 'Checking to make sure CatalogCodes are provided by the user'


IF @EmailCatalogCode IS NULL
BEGIN	
	-- Check if we can get the DL control version of catalogcode ****
	SET @ErrorMsg = 'Please provide CatalogCode for the Email Piece'
	RAISERROR(@ErrorMsg,15,1)
	RETURN
END

--- Check to make sure CatalogCode Provided is correct.
IF @DeBugCode = 1 PRINT 'Checking to make sure CatalogCode Provided is correct'

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

IF @PriorMonths > 0
   BEGIN
	SET @PriorMonths = @PriorMonths - @PriorMonths - @PriorMonths
	PRINT 'Rank based on prior ' + Convert(varchar, @PriorMonths) + ' sales.'
   END

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn02RanktempSBP')
	DROP TABLE Staging.Ecampn02RanktempSBP

SELECT Sum(FNL.SumSales) AS SumSales,
	FNL.CourseID,
	FNL.PreferredCategory,
	CONVERT(FLOAT,0) AS Rank,
	Convert(tinyint,0) AS BundleFlag,
	Convert(int,0) as CourseParts,
	Sum(FNL.SumSales) AS SumSalesBkp
INTO Staging.Ecampn02RanktempSBP
FROM	(SELECT sum(OI.SalesPrice) AS SumSales,
			II.Courseid AS CourseID,
			'GEN' AS PreferredCategory
	FROM  Marketing.DMPurchaseOrders O JOIN
		Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
		Staging.InvItem II ON OI.StockItemID = II.StockItemID LEFT OUTER JOIN
		Staging.MktPricingMatrix MPM ON MPM.UserStockItemID = II.StockItemID	
	WHERE O.DATEORDERED BETWEEN DATEADD(Month,@PriorMonths,GETDATE()) AND GETDATE()
	AND O.SequenceNum > 1
	AND MPM.CatalogCode = (@EmailCatalogCode)
	GROUP BY  II.Courseid
	UNION
	SELECT sum(OI.SalesPrice) AS SumSales,
		II.Courseid AS CourseID,
		ISNULL(CSM.PreferredCategory2,'GEN') AS PreferredCategory
	FROM --RFM..CustomerSubjectMatrix CSM JOIN
		Marketing.CampaignCustomerSignature CSM JOIN
               Marketing.DMPurchaseOrders O  ON CSM.CUSTOMERID = O.CUSTOMERID JOIN
               Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
		Staging.InvItem II ON OI.StockItemID = II.StockItemID LEFT OUTER JOIN
		Staging.MktPricingMatrix MPM ON MPM.UserStockItemID = II.StockItemID
	WHERE O.DATEORDERED BETWEEN DATEADD(Month,@PriorMonths,GETDATE()) AND GETDATE()
	AND O.SequenceNum > 1
	AND MPM.CatalogCode = (@EmailCatalogCode)
	AND CSM.PreferredCategory2 is not null
	GROUP BY CSM.PREFERREDCATEGORY2, II.Courseid)FNL
GROUP BY FNL.CourseID,FNL.PreferredCategory
ORDER BY FNL.PreferredCategory,Sum(FNL.SumSales) DESC

-- Add Bundle sales

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn02A_BundleCourseTEMP')
	DROP TABLE Staging.Ecampn02A_BundleCourseTEMP

SELECT BC.BundleID, MC1.CourseName AS BundleName,
	BC.CourseID, MC2.CourseName, MC2.CourseParts, MC2.PublishDate,
	convert(money,0) Sales
INTO Staging.Ecampn02A_BundleCourseTEMP
from Mapping.bundlecomponents BC JOIN
	(SELECT DISTINCT BC.BundleID
	FROM Staging.MktPricingMatrix MPM JOIN
		Staging.InvItem II ON MPM.UserStockItemID = II.StockItemID JOIN
		Mapping.bundlecomponents BC ON II.CourseID = BC.BundleID
	WHERE MPM.CatalogCode = (@EmailCatalogCode))B on BC.BundleID = B.BundleID JOIN
	Staging.Mktcourse MC1 ON BC.BundleID = MC1.CourseID JOIN
	Staging.Mktcourse MC2 ON BC.CourseID = MC2.CourseID
where bc.bundleflag > 0

CREATE INDEX IX_Ecampn02A_BundleCourseTEMP1 on Staging.Ecampn02A_BundleCourseTEMP (BundleID)
CREATE INDEX IX_Ecampn02A_BundleCourseTEMP2 on Staging.Ecampn02A_BundleCourseTEMP (CourseID)



-- Add Sales for individual courses from the bundles by preferred category

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn02B_BundleCourseByPrefTEMP')
	DROP TABLE Staging.Ecampn02B_BundleCourseByPrefTEMP

SELECT Sum(FNL.SumSales) AS SumSales,
	FNL.CourseID,
	FNL.PreferredCategory,
	CONVERT(FLOAT,0) AS Rank,
	Convert(tinyint,0) AS BundleFlag,
	Convert(int,0) as CourseParts,
	Sum(FNL.SumSales) AS SumSalesBkp
INTO Staging.Ecampn02B_BundleCourseByPrefTEMP
FROM	(SELECT sum(OI.SalesPrice) AS SumSales,
			BC.CourseID,
			'GEN' AS PreferredCategory
	FROM  Marketing.DMPurchaseOrders O JOIN
		Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
		(SELECT DISTINCT CourseID
		FROM Staging.Ecampn02A_BundleCourseTEMP)BC on OI.CourseID = BC.CourseID
	AND O.DATEORDERED BETWEEN DATEADD(Month,@PriorMonths,GETDATE()) AND GETDATE()
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
		FROM Staging.Ecampn02A_BundleCourseTEMP)BC on OI.CourseID = BC.CourseID
	WHERE O.DATEORDERED BETWEEN DATEADD(Month,@PriorMonths,GETDATE()) AND GETDATE()
	AND O.SequenceNum > 1
	AND CSM.PreferredCategory2 IS NOT NULL
	GROUP BY BC.CourseID, CSM.PreferredCategory2)FNL
GROUP BY FNL.CourseID,FNL.PreferredCategory

CREATE INDEX IX_Ecampn02B_BundleCourseByPrefTEMP on Staging.Ecampn02B_BundleCourseByPrefTEMP (CourseID)

-- Combine Bundles and Course by pref tables to get the Bundles by PrefCat
INSERT INTO Staging.Ecampn02RanktempSBP
SELECT AVG(B.SumSales) SumSales,
	A.BundleID AS CourseID, 
	B.PreferredCategory,
	CONVERT(FLOAT,0) AS Rank,
	Convert(tinyint,1) AS BundleFlag,
	Convert(int,0) as CourseParts,
	Sum(b.SumSales) AS SumSalesBkp
FROM  Staging.Ecampn02A_BundleCourseTEMP A JOIN
	Staging.Ecampn02B_BundleCourseByPrefTEMP B ON A.CourseID = B.CourseID
GROUP BY A.BundleID, B.PreferredCategory


--- Assign ranking based on Sales


DECLARE @CourseID INT
DECLARE @SumSales MONEY
DECLARE @PrefCat VARCHAR(5)
--- Declare First Cursor for PreferredCategory 
DECLARE MyCursor CURSOR
FOR
SELECT  DISTINCT PreferredCategory 
FROM Staging.Ecampn02RanktempSBP
ORDER BY PreferredCategory DESC

--- Begin First Cursor for PreferredCategory 			
OPEN MyCursor
FETCH NEXT FROM MyCursor INTO @PrefCat

SELECT @PrefCat
	
WHILE @@FETCH_STATUS = 0
	BEGIN
		--- Declare Second Cursor for courses within the PreferredCategory
		DECLARE MyCursor2 CURSOR
		FOR
		SELECT CourseID, SumSales 
		FROM Staging.Ecampn02RanktempSBP
		WHERE PreferredCategory = @PrefCat
		ORDER BY SumSales DESC
		
		--- BEGIN Second Cursor for courses within the PreferredCategory
		OPEN MyCursor2
		FETCH NEXT FROM MyCursor2 INTO @CourseID,@SumSales

		DECLARE @Rank FLOAT
		SET @Rank = CONVERT(FLOAT,1) 

		WHILE @@FETCH_STATUS = 0
		BEGIN
		--- Assign rank based on sales for the course id within the PreferredCategory
			UPDATE Staging.Ecampn02RanktempSBP
			SET Rank = @Rank
			WHERE PreferredCategory = @PrefCat
			AND CourseID = @CourseID 
			AND SumSales = @SumSales

			SET @Rank = @Rank + CONVERT(FLOAT,1)
			
			FETCH NEXT FROM MyCursor2 INTO @CourseID,@SumSales
		END
		CLOSE MyCursor2
		DEALLOCATE MyCursor2
		--- END Second Cursor for courses within the PreferredCategory


		--- Get the total number of courses for the given Catalog code.
		DECLARE @CourseCount INT

		SELECT @CourseCount = COUNT(DISTINCT II.CourseID)
		FROM Staging.MktPricingMatrix MPM JOIN
			Staging.InvItem II ON MPM.UserStockItemID = II.StockItemID
		WHERE MPM.CatalogCode = @EmailCatalogCode

		--FROM Staging.Ecampn01CourseList

		--- If there is no data available for courses under a particular
		--- preferred category, append courses FROM 'GEN' category.

		IF @CourseCount >= @Rank  --- If there are more courses that do not have ranks assigned yet..
		BEGIN

			IF @DeBugCode = 1 PRINT 'Inside IF statement - ' + CONVERT(VARCHAR,@Rank) + CONVERT(VARCHAR,@Coursecount)

			DECLARE @CourseID3 INT
			DECLARE @SumSales3 MONEY
			--- DECLARE Third Cursor for courses within the General Category
			DECLARE MyCursor3 CURSOR
			FOR
			SELECT DISTINCT CourseID,SumSales
			FROM Staging.Ecampn02RanktempSBP
			WHERE PreferredCategory = 'GEN'
			AND CourseID NOT IN (SELECT CourseID 
					       FROM Staging.Ecampn02RanktempSBP
					       WHERE PreferredCategory = @PrefCat)
			ORDER BY SumSales DESC
			--- Begin Third Cursor for courses within the General Category
			OPEN MyCursor3
			FETCH NEXT FROM MyCursor3 INTO @CourseID3,@SumSales3

			WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @SumSales3,@CourseID3,@PrefCat,@Rank,0,0,@SumSales3
				INSERT INTO Staging.Ecampn02RanktempSBP
				SELECT @SumSales3,@CourseID3,@PrefCat,@Rank,0,0,@SumSales3
	
				SET @Rank = @Rank + CONVERT(FLOAT,1)
				
				FETCH NEXT FROM MyCursor3 INTO @CourseID3,@SumSales3
			END
			CLOSE MyCursor3
			DEALLOCATE MyCursor3
			--- End Third Cursor for courses within the General Category
		END


		FETCH NEXT FROM MyCursor INTO @PrefCat
	END
CLOSE MyCursor
DEALLOCATE MyCursor

-- update Staging.Ecampn02RanktempSBP
-- set rank = case when rank <= 5 then rank + 5.12
-- 		else rank + 3.45
-- 		end
-- where bundleflag = 1

 --update Staging.Ecampn02RanktempSBP
 --set rank = rank / 2.05
 --where bundleflag = 0
--and preferredcategory not in ('AH', 'RL')



--UPDATE Staging.Ecampn02RanktempSBP
--SET Rank = rank/2.98
--WHERE CourseID IN (1001,1841,1950,6640,7240,8280)


-- UPDATE Staging.Ecampn02RanktempSBP
-- SET Rank = case when rank between 7.0 and 19.0 then Rank/1.56
-- 		when rank between 20.0 and 50.0 then rank/2.56
-- 		when rank between 50.0 and 75.0 then rank/3.56
-- 		when rank between 76.0 and 100.0 then rank/4.568
-- 		when rank>100.0 then rank/5.89
-- 		else rank
-- 	end 
-- --WHERE CourseID IN (1830,1426,7158,4242,3480,6450,5620,2270,8598)
-- where courseid in (1830,1831,1426,1427,7158,7159,4242,4243,3480,3481,6450,6451,5620,
-- 			5621,8598,8599,2270,2271)
-- 
-- UPDATE Staging.Ecampn02RanktempSBP
-- set rank = rank/3.51
-- -- SET Rank = case when rank > 10.0 then rank/4.51
-- -- 		else rank
-- -- 	end 
-- WHERE CourseID IN (177,197,217,250,349,447,480,550,710,751,752,753,754,780,869,1120,1219,1220,1260,1295,1426,1474,1487,1533,1573,1620,2100,2310,2317,2353,2368,2429,2539,2567,3150,3180,3340,3410,4235,4242,4600,4647,4820,5620,5665,6130,6240,6252,6299,6537,6577,7130,7150,7318,7510,757,758,8128,8267,8270,8467,8520,8540,8561,8570,8598,8894)
-- -- where courseid in (2180,3430,1447)

--- Report1: Ranking check report

SELECT a.Sumsales,a.CourseID,b.CourseName,a.PreferredCategory, a.Rank   
FROM Staging.Ecampn02RanktempSBP a,
	Staging.MktCourse b
WHERE a.CourseID = b.CourseID
ORDER BY a.PreferredCategory, a.Rank
GO
