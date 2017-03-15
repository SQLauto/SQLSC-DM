SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  PROC [Staging].[CampaignEmail_GetRanking]
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
FROM datawarehouse.staging.MktCatalogCodes
WHERE CatalogCode = @EmailCatalogCode

SELECT '@Count = ', @Count

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

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn02RankTemp')
	DROP TABLE Datawarehouse.Staging.Ecampn02RankTemp

SELECT Sum(FNL.SumSales) AS SumSales,
	FNL.CourseID,
	FNL.PreferredCategory,
	CONVERT(FLOAT,0) AS Rank
INTO Datawarehouse.Staging.Ecampn02RankTemp
FROM	(SELECT sum(OI.SalesPrice) AS SumSales,
			II.Courseid AS CourseID,
			'GEN' AS PreferredCategory
	FROM  Datawarehouse.Marketing.DMPurchaseOrders O JOIN
		Datawarehouse.Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
		Datawarehouse.Staging.Invitem II ON OI.StockItemID = II.StockItemID LEFT OUTER JOIN
		Datawarehouse.Staging.MktPricingMatrix MPM ON MPM.UserStockItemID = II.StockItemID	
	WHERE O.DATEORDERED BETWEEN DATEADD(Month,@PriorMonths,GETDATE()) AND GETDATE()
	AND O.SequenceNum > 1
	AND MPM.CatalogCode = (@EmailCatalogCode)
	GROUP BY  II.Courseid
	UNION
	SELECT sum(OI.SalesPrice) AS SumSales,
		II.Courseid AS CourseID,
		ISNULL(CSM.PreferredCategory2,'GEN') AS PreferredCategory
	FROM --RFM..CustomerSubjectMatrix CSM JOIN
		MarketingDM.dbo.campaigncustomersignature CSM JOIN
               Datawarehouse.Marketing.DMPurchaseOrders O  ON CSM.CUSTOMERID = O.CUSTOMERID JOIN
               Datawarehouse.Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
		Datawarehouse.Staging.Invitem II ON OI.StockItemID = II.StockItemID LEFT OUTER JOIN
		Datawarehouse.Staging.MktPricingMatrix MPM ON MPM.UserStockItemID = II.StockItemID
	WHERE O.DATEORDERED BETWEEN DATEADD(Month,@PriorMonths,GETDATE()) AND GETDATE()
	AND O.SequenceNum > 1
	AND MPM.CatalogCode = (@EmailCatalogCode)
	AND CSM.PreferredCategory2 is not null
	GROUP BY CSM.PREFERREDCATEGORY2, II.Courseid)FNL
GROUP BY FNL.CourseID,FNL.PreferredCategory
ORDER BY FNL.PreferredCategory,Sum(FNL.SumSales) DESC

-- SELECT Sum(FNL.SumSales) AS SumSales,
-- 	FNL.CourseID,
-- 	FNL.PreferredCategory,
-- 	CONVERT(FLOAT,0) AS Rank
-- INTO Datawarehouse.Staging.Ecampn02RankTemp
-- FROM	(SELECT sum(OI.SalesPrice) AS SumSales,
-- 			II.Courseid AS CourseID,
-- 			'GEN' AS PreferredCategory
-- 	FROM  Datawarehouse.Marketing.DMPurchaseOrders O JOIN
-- 		Datawarehouse.Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
-- 		Datawarehouse.Staging.Invitem II ON OI.StockItemID = II.UserStockItemID LEFT OUTER JOIN
-- 		Datawarehouse.Staging.MktPricingMatrix MPM ON MPM.UserStockItemID = II.UserStockItemID	
-- 	WHERE O.DATEORDERED BETWEEN DATEADD(Month,-3,GETDATE()) AND GETDATE()
-- 	AND MPM.CatalogCode = (@EmailCatalogCode)
-- 	GROUP BY  II.Courseid
-- 	UNION
-- 	SELECT sum(OI.SalesPrice) AS SumSales,
-- 		II.Courseid AS CourseID,

-- 		ISNULL(CSM.PreferredCategory,'GEN') AS PreferredCategory
-- 	FROM --RFM..CustomerSubjectMatrix CSM JOIN
-- 		MarketingDM.dbo.campaigncustomersignature CSM JOIN
--                Datawarehouse.Marketing.DMPurchaseOrders O  ON CSM.CUSTOMERID = O.CUSTOMERID JOIN
--                Datawarehouse.Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
-- 		Datawarehouse.Staging.Invitem II ON OI.StockItemID = II.UserStockItemID LEFT OUTER JOIN
-- 		Datawarehouse.Staging.MktPricingMatrix MPM ON MPM.UserStockItemID = II.UserStockItemID
-- 	WHERE O.DATEORDERED BETWEEN DATEADD(Month,-3,GETDATE()) AND GETDATE()
-- 	AND MPM.CatalogCode = (@EmailCatalogCode)
-- 	AND CSM.PreferredCategory IS NOT NULL
-- 	GROUP BY CSM.PREFERREDCATEGORY, II.Courseid)FNL
-- GROUP BY FNL.CourseID,FNL.PreferredCategory
-- ORDER BY FNL.PreferredCategory,Sum(FNL.SumSales) DESC

--- Assign ranking based on Sales


DECLARE @CourseID INT
DECLARE @SumSales MONEY
DECLARE @PrefCat VARCHAR(5)
--- Declare First Cursor for PreferredCategory 
DECLARE MyCursor CURSOR
FOR
SELECT  DISTINCT PreferredCategory 
FROM Datawarehouse.Staging.Ecampn02RankTemp
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
		FROM Datawarehouse.Staging.Ecampn02RankTemp
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
			UPDATE Datawarehouse.Staging.Ecampn02RankTemp
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
		FROM Datawarehouse.Staging.MktPricingMatrix MPM JOIN
			Datawarehouse.Staging.Invitem II ON MPM.UserStockItemID = II.StockItemID
		WHERE MPM.CatalogCode = @EmailCatalogCode

		--FROM Datawarehouse.Staging.Ecampn01CourseList

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
			FROM Datawarehouse.Staging.Ecampn02RankTemp
			WHERE PreferredCategory = 'GEN'
			AND CourseID NOT IN (SELECT CourseID 
					       FROM Datawarehouse.Staging.Ecampn02RankTemp
					       WHERE PreferredCategory = @PrefCat)
			ORDER BY SumSales DESC
			--- Begin Third Cursor for courses within the General Category
			OPEN MyCursor3
			FETCH NEXT FROM MyCursor3 INTO @CourseID3,@SumSales3

			WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @SumSales3,@CourseID3,@PrefCat,@Rank
				INSERT INTO Datawarehouse.Staging.Ecampn02RankTemp
				SELECT @SumSales3,@CourseID3,@PrefCat,@Rank
	
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

-- Remove Discontinued Courses

DELETE WP
-- Select wp.*
FROM Datawarehouse.Staging.Ecampn02Ranktemp WP LEFT OUTER JOIN
	(SELECT DISTINCT CourseID 
	FROM Datawarehouse.Staging.Invitem 
	WHERE forsaleonweb=1 
	AND forsaletoconsumer=1 
	AND itemcategoryid in ('course','bundle'))Crs ON WP.CourseID = Crs.CourseID
WHERE Crs.Courseid is null

-- Force ranks for some courses to top
-- 
-- UPDATE Datawarehouse.Staging.Ecampn02Ranktemp
-- SET Rank = case when rank between 15 and 19 then Rank/1.56
-- 		when rank between 20 and 50 then rank/2.56
-- 		when rank between 50 and 75 then rank/3.56
-- 		when rank between 76 and 100 then rank/4.568
-- 		when rank between 100 and 200 then rank/5.89
-- 		when rank > 200 then rank/6.89
-- 		else rank
-- 	end 
-- WHERE CourseID IN (1830,1426,7158,4242,3480,6450,5620,2270,8598,3430,2180, 1447, 1527, 8818, 5665)
-- -- and rank > 10
-- 
--UPDATE Datawarehouse.Staging.Ecampn02Ranktemp
--SET Rank = case when rank > 10 then rank/1.546
--		when rank > 20 then rank/2.123
--		when rank > 30 then rank/4.789
--		else rank
--	end 
---- SET Rank = rank/2.12
--WHERE CourseID IN (8510,4670,1557)
--
--
--UPDATE Datawarehouse.Staging.Ecampn02Ranktemp
--SET Rank = case when rank > 10 then rank/1.234
--		when rank > 20 then rank/3.16
--		else rank
--	end 
---- SET Rank = rank/2.12
--WHERE CourseID IN (1816,158)

/*
UPDATE Datawarehouse.Staging.Ecampn02Ranktemp
SET Rank = rank/8.12
WHERE CourseID IN (1816,158)*/
--- Report1: Ranking check report

SELECT a.Sumsales,a.CourseID,b.CourseName,a.PreferredCategory, a.Rank   
FROM Datawarehouse.Staging.Ecampn02Ranktemp a,
	SuperStarDW.dbo.MktCourse b
WHERE a.CourseID = b.CourseID
ORDER BY a.PreferredCategory, a.Rank

-- Get CourseList
SELECT Distinct A.CourseID, B.Coursename, B.PublishDate
from Datawarehouse.Staging.Ecampn02Ranktemp a,
	SuperStarDW.dbo.MktCourse b
WHERE a.CourseID = b.CourseID
Order By B.PublishDate Desc
GO
