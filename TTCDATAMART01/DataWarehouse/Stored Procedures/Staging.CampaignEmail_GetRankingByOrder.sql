SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  PROC [Staging].[CampaignEmail_GetRankingByOrder]
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
FROM SuperstarDW.dbo.MktCatalogCodes
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

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn02RankTempBYOrder')
	DROP TABLE Datawarehouse.Staging.Ecampn02RankTempBYOrder

SELECT Sum(FNL.SumSales) AS SumSales,
	Sum(FNL.TotalOrders) AS TotalOrders,
	FNL.CourseID,
	FNL.PreferredCategory,
	CONVERT(FLOAT,0) AS Rank
INTO Datawarehouse.Staging.Ecampn02RankTempBYOrder
FROM	(SELECT sum(OI.SalesPrice) AS SumSales,
			count(distinct oi.orderid) as TotalOrders,
			II.Courseid AS CourseID,
			'GEN' AS PreferredCategory
	FROM  Datawarehouse.Marketing.DMPurchaseOrders O JOIN
		Datawarehouse.Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
		Datawarehouse.Staging.InvItem II ON OI.StockItemID = II.StockItemID LEFT OUTER JOIN
		Datawarehouse.Staging.MktPricingMatrix MPM ON MPM.UserStockItemID = II.StockItemID	
	WHERE O.DATEORDERED BETWEEN DATEADD(Month,@PriorMonths,GETDATE()) AND GETDATE()
	AND O.SequenceNum > 1
	AND MPM.CatalogCode = (@EmailCatalogCode)
	GROUP BY  II.Courseid
	UNION
	SELECT sum(OI.SalesPrice) AS SumSales,
		count(distinct oi.orderid) as TotalOrders,
		II.Courseid AS CourseID,
		ISNULL(CSM.PreferredCategory2,'GEN') AS PreferredCategory
	FROM --RFM..CustomerSubjectMatrix CSM JOIN
		Datawarehouse.Marketing.campaigncustomersignature CSM JOIN
               Datawarehouse.Marketing.DMPurchaseOrders O  ON CSM.CUSTOMERID = O.CUSTOMERID JOIN
               Datawarehouse.Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
		Datawarehouse.Staging.InvItem II ON OI.StockItemID = II.StockItemID LEFT OUTER JOIN
		Datawarehouse.Staging.MktPricingMatrix MPM ON MPM.UserStockItemID = II.StockItemID
	WHERE O.DATEORDERED BETWEEN DATEADD(Month,@PriorMonths,GETDATE()) AND GETDATE()
	AND O.SequenceNum > 1
	AND MPM.CatalogCode = (@EmailCatalogCode)
	AND CSM.PreferredCategory2 is not null
	GROUP BY CSM.PREFERREDCATEGORY2, II.Courseid)FNL
GROUP BY FNL.CourseID,FNL.PreferredCategory
ORDER BY FNL.PreferredCategory,Sum(FNL.TotalOrders) DESC


--- Assign ranking based on Sales

DECLARE @CourseID INT
DECLARE @TotalOrders Float
DECLARE @PrefCat VARCHAR(5)
--- Declare First Cursor for PreferredCategory 
DECLARE MyCursor CURSOR
FOR
SELECT  DISTINCT PreferredCategory 
FROM Datawarehouse.Staging.Ecampn02RankTempBYOrder
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
		SELECT CourseID, TotalOrders 
		FROM Datawarehouse.Staging.Ecampn02RankTempBYOrder
		WHERE PreferredCategory = @PrefCat
		ORDER BY TotalOrders DESC
		
		--- BEGIN Second Cursor for courses within the PreferredCategory
		OPEN MyCursor2
		FETCH NEXT FROM MyCursor2 INTO @CourseID,@TotalOrders

		DECLARE @Rank FLOAT
		SET @Rank = CONVERT(FLOAT,1) 

		WHILE @@FETCH_STATUS = 0
		BEGIN
		--- Assign rank based on sales for the course id within the PreferredCategory
			UPDATE Datawarehouse.Staging.Ecampn02RankTempBYOrder
			SET Rank = @Rank
			WHERE PreferredCategory = @PrefCat
			AND CourseID = @CourseID 
			AND TotalOrders = @TotalOrders

			SET @Rank = @Rank + CONVERT(FLOAT,1)
			
			FETCH NEXT FROM MyCursor2 INTO @CourseID,@TotalOrders
		END
		CLOSE MyCursor2
		DEALLOCATE MyCursor2
		--- END Second Cursor for courses within the PreferredCategory


		--- Get the total number of courses for the given Catalog code.
		DECLARE @CourseCount INT

		SELECT @CourseCount = COUNT(DISTINCT II.CourseID)
		FROM Datawarehouse.Staging.MktPricingMatrix MPM JOIN
			Datawarehouse.Staging.InvItem II ON MPM.UserStockItemID = II.StockItemID
		WHERE MPM.CatalogCode = @EmailCatalogCode

		--FROM Ecampaigns.dbo.Ecampn01CourseList

		--- If there is no data available for courses under a particular
		--- preferred category, append courses FROM 'GEN' category.

		IF @CourseCount >= @Rank  --- If there are more courses that do not have ranks assigned yet..
		BEGIN
			IF @DeBugCode = 1 PRINT 'Inside IF statement - ' + CONVERT(VARCHAR,@Rank) + CONVERT(VARCHAR,@Coursecount)

			DECLARE @CourseID3 INT
			DECLARE @TotalOrders3 float
			--- DECLARE Third Cursor for courses within the General Category
			DECLARE MyCursor3 CURSOR
			FOR
			SELECT DISTINCT CourseID,TotalOrders
			FROM Datawarehouse.Staging.Ecampn02RankTempBYOrder
			WHERE PreferredCategory = 'GEN'
			AND CourseID NOT IN (SELECT CourseID 
					       FROM Datawarehouse.Staging.Ecampn02RankTempBYOrder
					       WHERE PreferredCategory = @PrefCat)
			ORDER BY TotalOrders DESC
			--- Begin Third Cursor for courses within the General Category
			OPEN MyCursor3
			FETCH NEXT FROM MyCursor3 INTO @CourseID3,@TotalOrders3

			WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT 0, @TotalOrders3,@CourseID3,@PrefCat,@Rank
				INSERT INTO Datawarehouse.Staging.Ecampn02RankTempBYOrder
				SELECT 0, @TotalOrders3,@CourseID3,@PrefCat,@Rank
	
				SET @Rank = @Rank + CONVERT(FLOAT,1)
				
				FETCH NEXT FROM MyCursor3 INTO @CourseID3,@TotalOrders3
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
FROM Datawarehouse.Staging.Ecampn02RankTempBYOrder WP LEFT OUTER JOIN
	(SELECT DISTINCT CourseID 
	FROM Datawarehouse.Staging.InvItem 
	WHERE forsaleonweb=1 
	AND forsaletoconsumer=1 
	AND itemcategoryid in ('course','bundle'))Crs ON WP.CourseID = Crs.CourseID
WHERE Crs.Courseid is null


--- Report1: Ranking check report

SELECT a.TotalOrders,a.CourseID,b.CourseName,a.PreferredCategory, a.Rank   
FROM Datawarehouse.Staging.Ecampn02RankTempBYOrder a,
	SuperStarDW.dbo.MktCourse b
WHERE a.CourseID = b.CourseID
ORDER BY a.PreferredCategory, a.Rank

-- Get CourseList
SELECT Distinct A.CourseID, B.Coursename, B.PublishDate
from Datawarehouse.Staging.Ecampn02RankTempBYOrder a,
	SuperStarDW.dbo.MktCourse b
WHERE a.CourseID = b.CourseID
Order By B.PublishDate Desc
GO
