SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROC [Staging].[Proc_Upsell_CourseAffinity_new]
AS

/*PRINT 'BEGIN Proc_Upsell_CourseAffinity_new'*/

/* Preethi Ramanujam - 1/27/2009 - To generate Course affinity table for upsell engine*/
/* Preethi Ramanujam - 3/17/2009 - Added Bundles to the list.*/

/*PRINT 'Step1: Create temp table rfm..Upsell_CourseAffinity_Temp'*/

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Upsell_CourseAffinity_Temp')
	DROP TABLE Staging.Upsell_CourseAffinity_Temp

SELECT FP.*, SP.OrderID AS SP_OrderID, SP.DateOrdered SP_DateOrdered, SP.PriorPurchaseOrderID, SP.CourseID AS SP_CourseID,
	SP.Parts AS SP_Parts, SP.PostReleaseCourseSat AS SP_CSATScore,
	SP.CourseName AS SP_CourseName, SP.SubjectCategory SP_SubjectCategory, 
	SP.SubjectCategory2 as SP_SubjectCategory2, SP.SubjectCategoryID AS SP_SubjectCategoryID,
	SP.ReleaseDate as SP_ReleaseDate,
	DATEDIFF(Day, SP.ReleaseDate, convert(datetime,convert(varchar,getdate(),101))) SP_DaysSinceRelease,
	SP.TotalSales AS SP_TotalSales,
	dateadd(day, -540, dateadd(day, -2, convert(datetime,convert(varchar,getdate(),101)))) AS FP_StartDate,
	dateadd(day, -90,dateadd(day, -2, convert(datetime,convert(varchar,getdate(),101)))) AS FP_EndDate,
	convert(datetime,convert(varchar,getdate(),101)) AS ReportDate	
INTO Staging.Upsell_CourseAffinity_Temp
FROM 	(select O.CustomerID, O.OrderID, O.DateOrdered, OI.CourseID, OI.Parts, DMC.PostReleaseCourseSat as CSATScore, 
		DMC.AbbrvCourseName as CourseName, DMC.SubjectCategory, DMC.SubjectCategory2, DMC.SubjectCategoryID,
		DMC.ReleaseDate, OI.TotalSales
	from Marketing.DMPurchaseOrders O JOIN
		Marketing.DMPurchaseOrderItems OI ON O.CustomerID = OI.CustomerID and O.OrderID = OI.OrderID LEFT OUTER JOIN
		Mapping.DMCourse DMC ON OI.CourseID = DMC.CourseID
	where O.SequenceNum = 1 and O.NetOrderamount between 10 and 1500
	and O.DateOrdered BETWEEN dateadd(day, -540, dateadd(day, -2, convert(datetime,convert(varchar,getdate(),101)))) 
			and dateadd(day, -90,dateadd(day, -2, convert(datetime,convert(varchar,getdate(),101)))))FP JOIN
	(select O.CustomerID, O.OrderID, O.DateOrdered, O.PriorPurchaseOrderID, 
		OI.CourseID, OI.Parts, DMC.PostReleaseCourseSat, 
		DMC.AbbrvCourseName as CourseName, DMC.SubjectCategory, DMC.SubjectCategory2, DMC.SubjectCategoryID,
		DMC.ReleaseDate, OI.TotalSales
	from Marketing.DMPurchaseOrders O JOIN
		Marketing.DMPurchaseOrderItems OI ON O.CustomerID = OI.CustomerID and O.OrderID = OI.OrderID LEFT OUTER JOIN
		Mapping.DMCourse DMC ON OI.CourseID = DMC.CourseID
	where O.SequenceNum = 2 and O.NetOrderamount between 10 and 1500
	and O.DateOrdered >= dateadd(day, -540, dateadd(day, -2, convert(datetime,convert(varchar,getdate(),101))))
	and DaysSinceLastPurchase < 91)SP ON FP.CustomerID = SP.CustomerID 
					AND FP.OrderID = SP.PriorPurchaseOrderID


CREATE Clustered Index IX_Upsell_CourseAffinity_Temp_FC on Staging.Upsell_CourseAffinity_Temp (CourseID, CourseName)
CREATE Index IX_Upsell_CourseAffinity_Temp_SC on Staging.Upsell_CourseAffinity_Temp (SP_CourseID)
CREATE Index IX_Upsell_CourseAffinity_Temp_SRD on Staging.Upsell_CourseAffinity_Temp (SP_ReleaseDate)
CREATE Index IX_Upsell_CourseAffinity_Temp_SDO on Staging.Upsell_CourseAffinity_Temp (SP_DateOrdered)

/* Remove discontinued Courses from the affinity list*/

/*PRINT 'Step2: Remove discontinued Courses from the affinity list'*/

SELECT Distinct UCA.CourseID, UCA.CourseName
FROM Staging.Upsell_CourseAffinity_Temp UCA LEFT OUTER JOIN
	(SELECT DISTINCT CourseID 
	FROM Staging.Invitem 
	WHERE forsaleonweb=1 
	AND forsaletoconsumer=1 
	AND InvStatusID in ('Active','Disc')
	AND itemcategoryid in ('course','bundle'))Crs ON UCA.CourseID = Crs.CourseID
WHERE Crs.CourseID is NULL 
ORDER BY 1

DELETE UCA
FROM Staging.Upsell_CourseAffinity_Temp UCA LEFT OUTER JOIN
	(SELECT DISTINCT CourseID 
	FROM Staging.Invitem 
	WHERE forsaleonweb=1 
	AND forsaletoconsumer=1
	AND InvStatusID in ('Active','Disc')
	AND itemcategoryid in ('course','bundle'))Crs ON UCA.CourseID = Crs.CourseID
WHERE Crs.CourseID is NULL 


SELECT DISTINCT UCA.SP_CourseID, UCA.SP_CourseName
FROM Staging.Upsell_CourseAffinity_Temp UCA LEFT OUTER JOIN
	(SELECT DISTINCT CourseID 
	FROM Staging.Invitem 
	WHERE forsaleonweb=1 
	AND forsaletoconsumer=1 
	AND InvStatusID in ('Active','Disc')
	AND itemcategoryid in ('course','bundle'))Crs ON UCA.SP_CourseID = Crs.CourseID
WHERE Crs.CourseID is NULL 
ORDER BY 1

DELETE UCA
FROM Staging.Upsell_CourseAffinity_Temp UCA LEFT OUTER JOIN
	(SELECT DISTINCT CourseID 
	FROM Staging.Invitem 
	WHERE forsaleonweb=1 
	AND forsaletoconsumer=1 
	AND InvStatusID in ('Active','Disc')	
	AND itemcategoryid in ('course','bundle'))Crs ON UCA.SP_CourseID = Crs.CourseID
WHERE Crs.CourseID is NULL 

/* Remove if Second Purchase Course is same as first Course*/

/*PRINT 'Step3: Remove if Second Purchase Course is same as first Course'*/

DELETE
FROM Staging.Upsell_CourseAffinity_Temp
WHERE CourseID = SP_CourseID

/* Create Course affinity factors for courses released after the cap date.*/

/*PRINT 'Step4: Create Course affinity factors for courses released after the cap date.'*/

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Upsell_CourseAffinity_Factor')
	DROP TABLE Staging.Upsell_CourseAffinity_Factor

SELECT Distinct SP_CourseID, SP_ReleaseDate, convert(float,0) AS TotalSP_SinceRelease, 
	convert(float,0) AS TotalSP_All, convert(float,0) AS SP_CourseAffFactor
INTO Staging.Upsell_CourseAffinity_Factor
FROM Staging.Upsell_CourseAffinity_Temp
WHERE SP_ReleaseDate >= dateadd(day, -540, dateadd(day, -2, convert(datetime,convert(varchar,getdate(),101))))
ORDER BY SP_ReleaseDate DESC

CREATE INDEX IX_Upsell_CourseAffinity_Factor ON Staging.Upsell_CourseAffinity_Factor (SP_CourseID)
CREATE INDEX IX_Upsell_CourseAffinity_Factor2 ON Staging.Upsell_CourseAffinity_Factor (SP_ReleaseDate)

UPDATE A
SET A.TotalSP_All = B.TotalSP_All
FROM Staging.Upsell_CourseAffinity_Factor A,
	(SELECT Count(Distinct Customerid) TotalSP_All
	FROM Staging.Upsell_CourseAffinity_Temp)B

/*select * from Staging.Upsell_CourseAffinity_Factor*/

DECLARE @SP_ReleaseDate DateTime

DECLARE MyCur_SPRelDate CURSOR
FOR
SELECT distinct SP_ReleaseDate
FROM Staging.Upsell_CourseAffinity_Temp
WHERE SP_ReleaseDate >= dateadd(day, -540, dateadd(day, -2, convert(datetime,convert(varchar,getdate(),101))))

/*- BEGIN Cursor for SP_Release Date*/
OPEN MyCur_SPRelDate
FETCH NEXT FROM MyCur_SPRelDate INTO @SP_ReleaseDate

DECLARE @TotalSP_SinceRelease FLOAT

WHILE @@FETCH_STATUS = 0
BEGIN
/*- Assign SP_Counts from release date*/
	SELECT @TotalSP_SinceRelease = Count(Distinct Customerid)
	FROM Staging.Upsell_CourseAffinity_Temp
	WHERE SP_DateOrdered >= @SP_ReleaseDate

	SELECT @SP_ReleaseDate, @TotalSP_SinceRelease

	IF @TotalSP_SinceRelease <= 0 
		SET  @TotalSP_SinceRelease = 1

	SELECT @SP_ReleaseDate, @TotalSP_SinceRelease

	UPDATE Staging.Upsell_CourseAffinity_Factor
	SET TotalSP_SinceRelease = @TotalSP_SinceRelease,
		SP_CourseAffFactor = TotalSP_All/@TotalSP_SinceRelease
	WHERE SP_ReleaseDate = @SP_ReleaseDate

	
	FETCH NEXT FROM MyCur_SPRelDate INTO @SP_ReleaseDate
END
CLOSE MyCur_SPRelDate
DEALLOCATE MyCur_SPRelDate


UPDATE Staging.Upsell_CourseAffinity_Factor
set SP_CourseAffFactor = 15
where SP_CourseAffFactor > 15

/* Generate Upsell_CourseAffinity table*/

/* PRINT 'Step5: Generate Upsell_CourseAffinity table'*/

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Upsell_CourseAffinity_new')
	DROP TABLE Staging.Upsell_CourseAffinity_new

SELECT A.CourseID, A.Parts, A.CSATScore, A.CourseName, 
	A.SubjectCategory, A.SubjectCategory2, A.SubjectCategoryID,
	A.ReleaseDate, Convert(float, 0) FP_Rank, 
	A.FP_StartDate, A.FP_EndDate, A.ReportDate,
	convert(tinyint, 0) FlagAnonymous,
	A.SP_CourseID, A.SP_Parts, A.SP_CSATScore, A.SP_CourseName, 
	A.SP_SubjectCategory, A.SP_SubjectCategory2, A.SP_SubjectCategoryID, 
	A.SP_ReleaseDate, A.SP_DaysSinceRelease, 
	CASE WHEN A.SP_DaysSinceRelease < 400 THEN 1 ELSE 0 END AS FlagRecentRelease,
	B.TotalSP_SinceRelease, B.TotalSP_All, 
	Convert(int,ISNULL(B.SP_CourseAffFactor,1)) SP_CourseAffFactor,
	COUNT(DISTINCT A.CustomerID) CustCount, 0 as AdjustedCustCount,

	convert(float,0) AS Rank,
	convert(float,0) AS RankAdjusted
INTO Staging.Upsell_CourseAffinity_new
FROM Staging.Upsell_CourseAffinity_Temp A LEFT OUTER JOIN
	Staging.Upsell_CourseAffinity_Factor B ON A.SP_courseID = B.SP_CourseID
GROUP BY A.CourseID, A.Parts, A.CSATScore, A.CourseName, 
	A.SubjectCategory, A.SubjectCategory2, A.SubjectCategoryID,
	A.ReleaseDate, A.FP_StartDate, A.FP_EndDate, A.ReportDate,
	A.SP_CourseID, A.SP_Parts, A.SP_CSATScore, A.SP_CourseName, 
	A.SP_SubjectCategory, A.SP_SubjectCategory2, A.SP_SubjectCategoryID, 
	A.SP_ReleaseDate, A.SP_DaysSinceRelease, B.TotalSP_SinceRelease, B.TotalSP_All, 
	Convert(int,ISNULL(B.SP_CourseAffFactor,1))

CREATE Clustered Index IX_Upsell_CourseAffinity_new_FC on Staging.Upsell_CourseAffinity_new (CourseID, CourseName)
CREATE Index IX_Upsell_CourseAffinity_new_SC on Staging.Upsell_CourseAffinity_new (SP_CourseID)
CREATE Index IX_Upsell_CourseAffinity_new_SRD on Staging.Upsell_CourseAffinity_new (SP_ReleaseDate)

/* Update adjusted counts based on course affinity factor*/

/* PRINT 'Step6: Update adjusted counts based on course affinity factor'*/

UPDATE Staging.Upsell_CourseAffinity_new
SET AdjustedCustCount = CustCount * ISNULL(SP_CourseAffFactor,1)


/* Update SP Ranks without adjustments and with adjustments*/

/* PRINT 'Step7: Update SP Ranks without adjustments and with adjustments'*/

DECLARE @CourseID INT, @SP_CourseID INT, @Custcount INT, @SP_Parts INT, @SP_CSATScore Float

/*- Declare First Cursor for ranking*/
DECLARE MyCursor CURSOR
FOR
SELECT DISTINCT CourseID 
FROM Staging.Upsell_CourseAffinity_new
ORDER BY CourseID

/*- Begin First Cursor for ranking	*/
OPEN MyCursor
FETCH NEXT FROM MyCursor INTO @CourseID

PRINT 'Ranking for CourseID ' + convert(varchar,@CourseID)
	
WHILE @@FETCH_STATUS = 0
	BEGIN
		/*- Declare Second Cursor for updating ranks without adjustments*/
		DECLARE MyCursor2 CURSOR
		FOR
		SELECT SP_CourseID, CustCount, SP_Parts, SP_CSATScore
		FROM Staging.Upsell_CourseAffinity_new
		WHERE CourseID = @CourseID
		ORDER BY CustCount DESC, SP_Parts Desc, SP_CSATScore Desc
		
		/*- BEGIN Second Cursor for updating ranks without adjustments*/
		OPEN MyCursor2
		FETCH NEXT FROM MyCursor2 INTO @SP_CourseID, @Custcount, @SP_Parts, @SP_CSATScore

		DECLARE @Rank FLOAT
		SET @Rank = CONVERT(FLOAT,1) 

		WHILE @@FETCH_STATUS = 0
		BEGIN
		/*- Assign rank based on cust count*/
			UPDATE Staging.Upsell_CourseAffinity_new
			SET Rank = @Rank
			WHERE CourseID = @CourseID
			AND SP_CourseID = @SP_CourseID 
			AND CustCount = @CustCount

			SET @Rank = @Rank + CONVERT(FLOAT,1)
			
			FETCH NEXT FROM MyCursor2 INTO @SP_CourseID, @Custcount, @SP_Parts, @SP_CSATScore
		END
		CLOSE MyCursor2
		DEALLOCATE MyCursor2
		/*- END Second Cursor for updating ranks without adjustments*/

/*- Declare third Cursor for updating ranks with adjustments*/
		DECLARE MyCursor3 CURSOR
		FOR
		SELECT SP_CourseID, AdjustedCustCount, SP_Parts, SP_CSATScore
		FROM Staging.Upsell_CourseAffinity_new
		WHERE CourseID = @CourseID
		ORDER BY AdjustedCustCount DESC, SP_Parts Desc, SP_CSATScore Desc
		
		/*- BEGIN third Cursor for updating ranks with adjustments*/
		OPEN MyCursor3
		FETCH NEXT FROM MyCursor3 INTO @SP_CourseID, @Custcount, @SP_Parts, @SP_CSATScore

		SET @Rank = CONVERT(FLOAT,1) 

		WHILE @@FETCH_STATUS = 0
		BEGIN
		/*- Assign rank based on adjusted cust counts*/
			UPDATE Staging.Upsell_CourseAffinity_new
			SET RankAdjusted = @Rank
			WHERE CourseID = @CourseID
			AND SP_CourseID = @SP_CourseID 
			AND AdjustedCustCount = @CustCount

			SET @Rank = @Rank + CONVERT(FLOAT,1)
			
			FETCH NEXT FROM MyCursor3 INTO @SP_CourseID, @Custcount, @SP_Parts, @SP_CSATScore
		END
		CLOSE MyCursor3
		DEALLOCATE MyCursor3
		/*- END third Cursor for updating ranks with adjustments*/

		FETCH NEXT FROM MyCursor INTO @CourseID
	END
CLOSE MyCursor
DEALLOCATE MyCursor

/* Add Ranking for course1 Based on base ranking for Course 2*/

/* PRINT 'Step8: Add Ranking for course1 Based on base ranking for Course 2'*/

DECLARE @FPCourseID INT, @FPCustCount INT, @FP_Parts INT, @FP_CSATScore FLOAT, @FPRank FLOAT

DECLARE MyCur_FPRank CURSOR
FOR
SELECT CourseID, AdjustedCustCount, Parts, CSATScore
FROM Staging.Upsell_CourseAffinity_new
WHERE RankAdjusted = 1.0
ORDER BY AdjustedCustCount DESC, Parts DESC, CSATSCore DESC

/*- BEGIN Cursor*/
OPEN MyCur_FPRank
FETCH NEXT FROM MyCur_FPRank INTO @FPCourseID, @FPCustcount, @FP_Parts, @FP_CSATScore

SET @FPRank = CONVERT(FLOAT,1) 

WHILE @@FETCH_STATUS = 0
BEGIN
/*- Assign ranks for First course*/
	UPDATE Staging.Upsell_CourseAffinity_new
	SET FP_Rank = @FPRank
	WHERE CourseID = @FPCourseID
	AND RankAdjusted = 1.0
	AND AdjustedCustCount = @FPCustcount
	AND Parts = @FP_Parts
	AND CSATScore = @FP_CSATScore

	SET @FPRank = @FPRank + CONVERT(FLOAT,1)
	
	FETCH NEXT FROM MyCur_FPRank INTO @FPCourseID, @FPCustcount, @FP_Parts, @FP_CSATScore
END
CLOSE MyCur_FPRank
DEALLOCATE MyCur_FPRank

UPDATE A
SET A.FP_Rank = B.FP_Rank
FROM Staging.Upsell_CourseAffinity_new A JOIN
	(SELECT Distinct CourseID, FP_Rank
	FROM Staging.Upsell_CourseAffinity_new
	WHERE FP_Rank > 0)B on A.CourseID = B.CourseID

/* If Adjusted Cust count is less than 19 for RankAdjusted 1, then pull course list*/
/* from Anonymous*/

/* PRINT 'Step9: If Adjusted Cust count is less than 19 for RankAdjusted 1, then pull course list from Anonymous'*/

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Upsell_CourseAffinity_TempAnonymous')
	DROP TABLE Staging.Upsell_CourseAffinity_TempAnonymous


SELECT A.*, 1 AS FlagAnonymous,
	B.CourseID AS SP_CourseID,
	C.CourseParts AS SP_Parts, C.PostReleaseCourseSat as SP_CSATScore,
	C.AbbrvCourseName as SP_CourseName, C.SubjectCategory as SP_SubjectCategory,
	C.SubjectCategory2 as SP_SubjectCategory2, C.SubjectCategoryID as SP_SubjectCategoryID,
	C.ReleaseDate AS SP_ReleaseDate, 
	DATEDIFF(Day, C.ReleaseDate, convert(datetime,convert(varchar,getdate(),101))) SP_DaysSinceRelease,
	CASE WHEN DATEDIFF(Day, C.ReleaseDate, convert(datetime,convert(varchar,getdate(),101))) < 400
		then 1 else 0 end as FlagRecentRelease,
	null as TotalSP_SinceRelease, null as TotalSP_All,  null SP_CourseAffFactor, 
	0 CustCount, 0 AdjustedCustCount, null Rank, B.DisplayOrder as RankAdjusted
INTO Staging.Upsell_CourseAffinity_TempAnonymous
FROM 	(SELECT DISTINCT CourseID, Parts, CSATScore, CourseName, SubjectCategory, SubjectCategory2, 
		SubjectCategoryID, ReleaseDate, FP_Rank, FP_StartDate, FP_EndDate, ReportDate
	FROM Staging.Upsell_CourseAffinity_new
	WHERE AdjustedCustCount < 19 AND RankAdjusted = 1)A JOIN
	Staging.CCUpSellAnonymous B ON A.SubjectCategoryID = B.SubjectID JOIN
	Mapping.DMCourse C ON B.CourseID = C.CourseID 

CREATE Clustered Index IX_Upsell_CourseAffinity_TempAnonymous_FC on Staging.Upsell_CourseAffinity_TempAnonymous (CourseID)
CREATE Index IX_Upsell_CourseAffinity_TempAnonymous_SC on Staging.Upsell_CourseAffinity_TempAnonymous (SP_CourseID)
CREATE Index IX_Upsell_CourseAffinity_TempAnonymous_SRD on Staging.Upsell_CourseAffinity_TempAnonymous (SP_ReleaseDate)

INSERT INTO Staging.Upsell_CourseAffinity_TempAnonymous
SELECT A.*, 1 AS FlagAnonymous,
	B.CourseID AS SP_CourseID,
	C.CourseParts AS SP_Parts, C.PostReleaseCourseSat as SP_CSATScore,
	C.AbbrvCourseName as SP_CourseName, C.SubjectCategory as SP_SubjectCategory,
	C.SubjectCategory2 as SP_SubjectCategory2, C.SubjectCategoryID as SP_SubjectCategoryID,
	C.ReleaseDate AS SP_ReleaseDate, 
	DATEDIFF(Day, C.ReleaseDate, convert(datetime,convert(varchar,getdate(),101))) SP_DaysSinceRelease,
	CASE WHEN DATEDIFF(Day, C.ReleaseDate, convert(datetime,convert(varchar,getdate(),101))) < 400
		then 1 else 0 end as FlagRecentRelease,
	null as TotalSP_SinceRelease, null as TotalSP_All,  null SP_CourseAffFactor, 
	0 CustCount, 0 AdjustedCustCount, null Rank, B.DisplayOrder as RankAdjusted
FROM 	(SELECT A.CourseID, A.CourseParts as Parts, A.PostReleaseCourseSat as CSATScore, 
		A.AbbrvCourseName as CourseName, A.SubjectCategory, A.SubjectCategory2, 
		A.SubjectCategoryID, A.ReleaseDate, @FPRank as FP_Rank,   
		dateadd(day, -540, dateadd(day, -2, convert(datetime,convert(varchar,getdate(),101)))) AS FP_StartDate,
		dateadd(day, -90,dateadd(day, -2, convert(datetime,convert(varchar,getdate(),101)))) AS FP_EndDate,
		convert(datetime,convert(varchar,getdate(),101)) AS ReportDate
	FROM Mapping.DMCourse A LEFT OUTER JOIN
		(SELECT Distinct CourseID
		FrOM Staging.Upsell_CourseAffinity_new)B ON A.CourseID = B.CourseID
	WHERE B.CourseID IS NULL
	AND A.BundleFlag = 0
	AND A.ReleaseDate BETWEEN dateadd(day, -90,dateadd(day, -2, convert(datetime,convert(varchar,getdate(),101))))
				AND getdate())A JOIN
	Staging.CCUpSellAnonymous B ON A.SubjectCategoryID = B.SubjectID JOIN
	Mapping.DMCourse C ON B.CourseID = C.CourseID 



UPDATE A
SET A.RankAdjusted = A.RankAdjusted + B.Rank,
	A.FlagAnonymous = 1
FROM Staging.Upsell_CourseAffinity_new A JOIN
	(SELECT Distinct CourseID, MAX(RankAdjusted) Rank
	FROM Staging.Upsell_CourseAffinity_TempAnonymous
	GROUP BY CourseID)B ON A.CourseID = B.CourseID
	
UPDATE A
SET A.RankAdjusted = B.RankAdjusted
FROM Staging.Upsell_CourseAffinity_new A JOIN
	Staging.Upsell_CourseAffinity_TempAnonymous B ON A.CourseID = B.CourseID
						AND A.SP_courseID = B.SP_CourseID

INSERT INTO Staging.Upsell_CourseAffinity_new
SELECT A.*
FROM Staging.Upsell_CourseAffinity_TempAnonymous A LEFT OUTER JOIN
	Staging.Upsell_CourseAffinity_new B ON A.Courseid  = B.CourseID
						AND A.SP_courseID = B.SP_CourseID
WHERE B.SP_CourseID IS NULL

/* Add Bundles to the table.*/

/* PRINT 'Step10: Add Bundles to the table.'*/

INSERT INTO Staging.Upsell_CourseAffinity_new
select Distinct a.CourseID, a.CourseParts, a.PostReleaseCourseSat as CSATScore, 
	convert(varchar(50),a.CourseName) CourseName, a.SubjectCategory, 
	a.SubjectCategory2, a.SubjectCategoryID,
	a.ReleaseDate, 0 as FP_Rank, 
	dateadd(day, -540, dateadd(day, -2, convert(datetime,convert(varchar,getdate(),101)))) AS FP_StartDate,
	dateadd(day, -90,dateadd(day, -2, convert(datetime,convert(varchar,getdate(),101)))) AS FP_EndDate,
	convert(datetime,convert(varchar,getdate(),101)) AS ReportDate,
	1 as FlagAnonymous, B.CourseID AS SP_CourseID, c.CourseParts as SP_Parts, 
	c.PostReleaseCourseSat as CSATScore, 
	c.AbbrvCourseName as SP_CourseName, c.SubjectCategory as SP_SubjectCategory, 
	c.SubjectCategory2 as SP_SubjectCategory2, c.SubjectCategoryID as SP_SubjectCategoryID,
	c.ReleaseDate as SP_ReleaseDate, 
	DATEDIFF(Day, c.ReleaseDate, convert(datetime,convert(varchar,getdate(),101))) SP_DaysSinceRelease,
	CASE WHEN DATEDIFF(Day, c.ReleaseDate, convert(datetime,convert(varchar,getdate(),101))) < 400
		then 1 else 0 end as FlagRecentRelease,
	0 as TotalSP_SinceRelease, 0 as TotalSP_All,  0 SP_CourseAffFactor, 
	0 CustCount, 0 AdjustedCustCount, 0 Rank, B.DisplayOrder as RankAdjusted
from Mapping.dmcourse a JOIN
	Staging.CCUpSellAnonymous b on a.subjectcategoryid = b.subjectid JOIN
	Mapping.dmcourse c on b.CourseID = C.Courseid
where a.bundleflag = 1
order by a.Courseid, B.DisplayOrder

/*
-- Load the table for TS
Truncate table Marketing.Upsell_CourseLevelReccos

insert into Marketing.Upsell_CourseLevelReccos
select CourseID, 
	SP_CourseID as UpsellCourseID, 
	RankAdjusted as DisplayOrder
from Staging.Upsell_CourseAffinity_new


-- For Prospect Web
Truncate table Marketing.Upsell_CourseLevelReccos_ProspectWeb

insert into Marketing.Upsell_CourseLevelReccos_ProspectWeb
select CourseID, 
	SP_CourseID as UpsellCourseID, 
	RankAdjusted as DisplayOrder,
	'US' as CountryCode
from Staging.Upsell_CourseAffinity_new
--where sp_Courseid in (OSW courses)
*/

/*PRINT 'END Proc_Upsell_CourseAffinity_new'*/
/* END Proc_Upsell_CourseAffinity_new*/
GO
