SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[CreateWeeklyRFMReportAllBKPDEL] @Date DATETIME = '1/1/1900'
AS
BEGIN
    --set nocount on
    
/* Preethi Ramanujam 	6/3/2009  To generate weekly rfm report for Forecast update*/
/* @Date is the date for which report needs to be generated.*/
/* For weekly report, it is usually Sunday.*/

/* If no date is provided, then Sunday of the week it is run is taken*/

	IF @Date = '1/1/1900'
	BEGIN
	PRINT 'No Date was provided. So, using last Sunday for the report'
		SELECT @Date = Staging.GetSunday(getdate())
		PRINT '@Date = ' + convert(varchar,@Date)
   	END
    
/* For the purpose of this report, if any other date other than Sunday is provided,*/
/* that week's Sunday is taken for further calculations.*/

	IF DATEPART(DW, @Date) > 1
   	BEGIN
	PRINT 'Date provided: ' + Convert(varchar,@Date,101) + ' is not a Sunday. Using Sunday for this week.'
		SELECT @Date = Staging.GetSunday(@Date)
		PRINT '@Date = ' + convert(varchar,@Date)
	END

/* Build RFM_Data_Special Table for that date */
/* Using rfm_buildSpecial_FC instead of regular to avoid conficts with daily processing.\*/
PRINT 'Build RFM table'
/*	EXEC Staging.LoadRFMSpecialFC @Date*/
	exec Staging.LoadRFMData @Date, 'WeeklyRFMReport'
    
    if object_id('Staging.TempWeeklyRFMReport') is not null drop table Staging.TempWeeklyRFMReport
    
    SELECT 
        C.CustomerID, 
        C.CustomerSince, 
        C.BuyerType, 
        c.Address1, 
        c.Address2, 
        c.City, 
        c.State, 
        c.PostalCode, 
        c.CountryCode,
        DATEADD(month, -6, @Date) AS Mo6InqDate,
        DATEADD(month, -24, @Date) AS Mo7to24InqDate,
        CONVERT(VARCHAR(30),'') AS InqType,
        LEFT(c.PostalCode, 5) AS Zip5, 
        C.Email,
        0 as PublicLibrary,
        0 as OtherInstitutions, 
        d.LastOrderDate,
        CASE 
            WHEN d.LastOrderDate >= C.CustomerSince then d.LastOrderDate 
            else C.CustomerSince 
        END as RecentOrderDate,
        convert(varchar(15),'') AS Concatenated,
        0 AS NewSeg,
        convert(varchar(50),'') AS Name,
        0 as A12MF,
        0 as FlagMail,
        0 AS FlagValidRegion,
        0 as FlagDRTV
	INTO Staging.TempWeeklyRFMReport
    FROM Staging.Customers C (nolock)
    left join Staging.vwCustomerLastOrderDate d (nolock) on d.CustomerID = c.CustomerID
    where C.CustomerSince <= DATEADD(day,1,@Date)

/* Update FlagMail*/
PRINT 'Update FlagMail'
    UPDATE A
    SET A.FlagMail = 
    	case 
	        WHEN isnull(mail.CustomerID, 0) <> 0 then 1
            else 0
        end
    FROM Staging.TempWeeklyRFMReport A 
    left join (
    	select ap.CustomerID 
        from Staging.AccountPreferences ap (nolock) 
        where ap.PreferenceID = 'OfferMail' ) as mail on mail.CustomerID = a.CustomerID

/* Update FlagValidRegion*/
PRINT 'Update FlagValidRegion'
UPDATE A
SET A.FlagValidRegion = 1
FROM Staging.TempWeeklyRFMReport A JOIN
	Mapping.rfmlkvalidregion VR (nolock) ON A.State = VR.Region
    
/* Map to correct CountryCode*/
PRINT 'Map to correct CountryCode'
UPDATE A
SET A.CountryCode = CC.CountryCodeCorrect
FROM Staging.TempWeeklyRFMReport A JOIN
	Mapping.CountryCodeCorrection CC (nolock) ON A.CountryCode = CC.CountryCode
    
/* Mark Institutions*/
PRINT 'Mark Institutions'
UPDATE A
SET A.PublicLibrary = 1
FROM Staging.TempWeeklyRFMReport A 
JOIN Staging.Customers c (nolock) on c.CustomerID = a.CustomerID
where c.CustGroup = 'Library'

/* Update Inquirer type*/
PRINT 'Update Inquirer type'
UPDATE Staging.TempWeeklyRFMReport
SET InqType = CASE WHEN CustomerSince > Mo6InqDate then '0-6 Mo Inq'
		WHEN CustomerSince > Mo7to24InqDate AND CustomerSince <= Mo6InqDate then '7-24 Mo Inq'
		WHEN CustomerSince <= Mo7to24InqDate then '25-1000 Mo Inq'
		ELSE 'Inq'
		END
WHERE Buyertype = 1

/* Update Highschool flag*/
PRINT 'Update Highschool flag'
UPDATE Staging.TempWeeklyRFMReport
SET InqType = 'HighSchool'
WHERE BuyerType = 3

/* Update rfm information*/
PRINT 'Update rfm information'
UPDATE A
SET A.Concatenated = B.Concatenated,
	A.A12mf = B.A12mf
FROM Staging.TempWeeklyRFMReport A JOIN
	Staging.rfm_Data_Special_FC B (nolock) ON A.CustomerID = B.CustomerID

UPDATE A
SET A.NewSeg = B.NewSeg,
	A.Name = B.Name
FROM Staging.TempWeeklyRFMReport A JOIN
	Mapping.RFMComboLookup B (nolock) ON A.A12mf = B.A12mf and A.Concatenated = B.Concatenated

/* Update NoRFMFlag*/
PRINT 'Update NoRFMFlag'
UPDATE Staging.TempWeeklyRFMReport
SET InqType = 'NoRFM'
/* select * from rfm.dbo.Weekly_RFM_Report1_Cust*/
WHERE BuyerType > 3
and newseg = 0 and isnull(Name,'') = ''
and a12mf = 0
	
	-- 5/16/12/SK: DRTV customers
    ;with cteOrders(CustomerID, AdCode, SequenceNum) as
    (
        select 
            o.CustomerID,
            o.AdCode,
            rank() over (partition by o.CustomerID order by o.DateOrdered, o.OrderID) SequenceNum
        from Staging.vwOrders o (nolock) 
    ),
    cteAdCodes(AdCode) as
    (
        select a.AdCode 
        from Mapping.vwAdcodesAll a (nolock)
        where a.ChannelID = 5
        and a.StartDate >= '1/1/2012'
    )
	update t
    set 
    	t.FlagDRTV = 1
    from Staging.TempWeeklyRFMReport t
    where t.CustomerID in 
    (
        select CustomerID
        from cteOrders o
        join cteAdCodes a on o.AdCode = a.AdCode
        where SequenceNum = 1
    )
    update t
    set t.NewSeg = 0, t.[Name] = 'DRTV', t.A12MF = 0
    from Staging.TempWeeklyRFMReport t 
    /* based on Ashit's request, all DRTV singles will be identified as DRTV instead of just 
		6 month singles. 
		-- Preethi		10/8/2012
	From: Ashit Patel 
	Sent: Wednesday, October 03, 2012 12:25 PM
	To: Bryan Lapidus; Preethi Ramanujam
	Cc: Daniel Hanks
	Subject: RE: RFMs

	DRTV customers should enter RFM count provided to finance only if they are 2x+ buyers. In other words, DRTV singles are to be excluded from all RFM.
	Thx		
	*/
   -- where t.FlagDRTV = 1 and t.NewSeg in (1, 2)  
    where t.FlagDRTV = 1 and t.NewSeg in (select distinct NewSeg 
										from DataWarehouse.Mapping.RFMComboLookup
										where MultiOrSingle = 'Single')

/* Reset Final Report*/
PRINT 'Reset Final Report'
UPDATE Staging.Weekly_RFM_Report
SET CollegeCustCount = 0,
	PublicLibraryCount = 0, 
	TotalCount = 0,
	FinalCount = 0,
	ReportFor = @Date,
	ReportGenerated = getdate(),
	CA_CollegeCustCount = 0,
	CA_PublicLibraryCount = 0, 
	CA_TotalCount = 0,
	CA_FinalCount = 0

/* Update Canada Counts*/
PRINT 'Update Canada Counts'
PRINT ''
PRINT '1. Total mailable'
DECLARE @CACount INT

SELECT @CACount = COUNT(CustomerID)
FROM Staging.TempWeeklyRFMReport
WHERE CountryCode = 'CA'
AND FlagMail = 1
AND BuyerType > 1

UPDATE Staging.Weekly_RFM_Report
SET TotalCount = @CACount
WHERE Name = 'Canada'

PRINT '2. Total Inquirers'
SELECT @CACount = COUNT(CustomerID)
FROM Staging.TempWeeklyRFMReport
WHERE CountryCode = 'CA'
AND FlagMail = 1
AND BuyerType = 1

UPDATE Staging.Weekly_RFM_Report
SET TotalCount = @CACount
WHERE Name = 'Canada_Inquirers'

PRINT '3. Total Do Not Mail'
SELECT @CACount = COUNT(CustomerID)
FROM Staging.TempWeeklyRFMReport
WHERE CountryCode = 'CA'
AND FlagMail = 0

UPDATE Staging.Weekly_RFM_Report
SET TotalCount = @CACount
WHERE Name = 'Canada_DoNotMail'

/*---------------------------------------------------------------*/
/*			CANADA		*/
/*---------------------------------------------------------------*/
/* Update final report with College customer Count for Canada*/
PRINT 'Update final report with College customer Count for Canada'
UPDATE A
SET A.CA_CollegeCustCount = B.CollegeCustCount
FROM Staging.Weekly_RFM_Report A JOIN
	(select NewSEg,Name,A12mf, count(customerid) CollegeCustCount
	from Staging.TempWeeklyRFMReport
	where CountryCode = 'CA'
	and publiclibrary = 0
	and buyertype > 3
	and FlagMail = 1
	group by NewSEg,Name,A12mf)B ON A.Newseg = b.newseg and a.name = b.name and a.a12mf = b.a12mf

/* Update final report with Public Library Count for Canada*/
PRINT 'Update final report with Public Library Count for Canada'
UPDATE A
SET A.CA_PublicLibraryCount = B.PublicLibraryCount
FROM Staging.Weekly_RFM_Report A JOIN
	(SELECT NewSEg,Name,A12mf, count(customerid) PublicLibraryCount
	FROM Staging.TempWeeklyRFMReport
	WHERE publiclibrary = 1
	AND FlagMail = 1
	AND CountryCode = 'CA'
	GROUP BY NewSEg,Name,A12mf)B ON A.Newseg = b.newseg and a.name = b.name and a.a12mf = b.a12mf

/* Update final report with HighSchool Customer Count for Canada*/
PRINT 'Update final report with HighSchool Customer Count for Canada'
UPDATE A
SET A.CA_CollegeCustCount = B.TotalCount
FROM Staging.Weekly_RFM_Report A JOIN
	(SELECT InqType, COUNT(*) TotalCount
	FROM Staging.TempWeeklyRFMReport
	WHERE BuyerType = 3
	AND CountryCode = 'CA'
	AND Publiclibrary = 0
	AND FlagMail = 1
	GROUP BY InqType)B  ON A.Name = B.InqType

/* Update Final report with Publiclibrary  Counts for Canada*/
PRINT 'Update Final report with Publiclibrary  Counts for Canada'
UPDATE A
SET A.CA_PublicLibraryCount = B.PublicLibraryCount
FROM Staging.Weekly_RFM_Report A JOIN
	(SELECT InqType, COUNT(*) PublicLibraryCount
	FROM Staging.TempWeeklyRFMReport
	WHERE BuyerType = 3
	AND CountryCode = 'CA'
	AND Publiclibrary = 1
	AND FlagMail = 1
	GROUP BY InqType)B  ON A.Name = B.InqType

/* Update final report with RFM Count for Canada*/
PRINT 'Update final report with RFM Count for Canada'
UPDATE A
SET A.CA_CollegeCustCount = B.TotalCount
FROM Staging.Weekly_RFM_Report A JOIN
	(SELECT InqType, COUNT(*) TotalCount
	FROM Staging.TempWeeklyRFMReport
	WHERE Inqtype = 'NoRFM'
	AND CountryCode = 'CA'
	AND PublicLibrary = 0
	AND FlagMail = 1
	GROUP BY InqType)B  ON A.Name = B.InqType

UPDATE A
SET A.CA_PublicLibraryCount = B.PublicLibraryCount
FROM Staging.Weekly_RFM_Report A JOIN
	(SELECT InqType, COUNT(*) PublicLibraryCount
	FROM Staging.TempWeeklyRFMReport
	WHERE Inqtype = 'NoRFM'
	AND PublicLibrary = 1
	AND FlagMail = 1
	AND CountryCode = 'CA'
	GROUP BY InqType)B  ON A.Name = B.InqType

/* Remove Canada Customers*/
PRINT 'Remove Canada Customers'
DELETE FROM Staging.TempWeeklyRFMReport
WHERE CountryCode = 'CA'

/*---------------------------------------------------------------*/
/*			UK		*/
/*---------------------------------------------------------------*/
/* Update UK Counts*/
PRINT 'Update UK Counts'
PRINT ''
PRINT '1. Total mailable'
DECLARE @UKCount INT

SELECT @UKCount = COUNT(CustomerID)
FROM Staging.TempWeeklyRFMReport
WHERE CountryCode = 'GB'
AND FlagMail = 1
AND BuyerType > 1

UPDATE Staging.Weekly_RFM_Report
SET TotalCount = @UKCount
WHERE Name = 'UK'

PRINT '2. Total Inquirers'
SELECT @UKCount = COUNT(CustomerID)
FROM Staging.TempWeeklyRFMReport
WHERE CountryCode = 'GB'
AND FlagMail = 1
AND BuyerType = 1

UPDATE Staging.Weekly_RFM_Report
SET TotalCount = @UKCount
WHERE Name = 'UK_Inquirers'

PRINT '3. Total Do Not Mail'
SELECT @UKCount = COUNT(CustomerID)
FROM Staging.TempWeeklyRFMReport
WHERE CountryCode = 'GB'
AND FlagMail = 0

UPDATE Staging.Weekly_RFM_Report
SET TotalCount = @UKCount
WHERE Name = 'UK_DoNotMail'

/* Remove UK Customers*/
PRINT 'Remove UK Customers'
DELETE FROM Staging.TempWeeklyRFMReport
WHERE CountryCode = 'GB'

/*---------------------------------------------------------------*/
/*			Australia		*/
/*---------------------------------------------------------------*/
/* Update Australia Counts*/
PRINT 'Update Australia Counts'
PRINT ''
PRINT '1. Total mailable'
DECLARE @AustraliaCount INT

SELECT @AustraliaCount = COUNT(CustomerID)
FROM Staging.TempWeeklyRFMReport
WHERE CountryCode = 'AU'
AND FlagMail = 1
AND BuyerType > 1

UPDATE Staging.Weekly_RFM_Report
SET TotalCount = @AustraliaCount
WHERE Name = 'Australia'

PRINT '2. Total Inquirers'
SELECT @AustraliaCount = COUNT(CustomerID)
FROM Staging.TempWeeklyRFMReport
WHERE CountryCode = 'AU'
AND FlagMail = 1
AND BuyerType = 1

UPDATE Staging.Weekly_RFM_Report
SET TotalCount = @AustraliaCount
WHERE Name = 'Australia_Inquirers'

PRINT '3. Total Do Not Mail'
SELECT @AustraliaCount = COUNT(CustomerID)
FROM Staging.TempWeeklyRFMReport
WHERE CountryCode = 'AU'
AND FlagMail = 0

UPDATE Staging.Weekly_RFM_Report
SET TotalCount = @AustraliaCount
WHERE Name = 'Australia_DoNotMail'

/* Remove Australia Customers*/
PRINT 'Remove Australia Customers'
DELETE FROM Staging.TempWeeklyRFMReport
WHERE CountryCode = 'AU'

/* Update US Do Not Mail Counts*/
PRINT ' Update US Do Not Mail Counts'
DECLARE @USCount INT

SELECT @USCount = Count(*)
FROM Staging.TempWeeklyRFMReport
WHERE FlagValidRegion = 1
AND FlagMail = 0

UPDATE Staging.Weekly_RFM_Report
SET TotalCount = @USCount
WHERE Name = 'US_DoNotMail'

/* Remove US Do Not Mail Folks*/
PRINT 'Remove US Do Not Mail Folks'
DELETE FROM Staging.TempWeeklyRFMReport
WHERE FlagValidRegion = 1
AND FlagMail = 0

/* Update Others*/
PRINT 'Update Others'
DECLARE @Others INT

SELECT  @Others = Count(customerid)
FROM Staging.TempWeeklyRFMReport
WHERE PostalCode LIKE '%[ABCDEFGHIJKLMNOPQRSTUVWXYZ]%'
OR FlagValidRegion = 0
OR Staging.IsDigit(Zip5) = 0
OR FlagMail = 0
OR BuyerType = 0

UPDATE Staging.Weekly_RFM_Report
SET TotalCount = @Others
WHERE Name = 'Others'

/* Remove Others*/
PRINT 'Remove Others'
DELETE FROM Staging.TempWeeklyRFMReport
WHERE PostalCode LIKE '%[ABCDEFGHIJKLMNOPQRSTUVWXYZ]%'
OR FlagValidRegion = 0
OR Staging.IsDigit(Zip5) = 0
OR FlagMail = 0
OR BuyerType = 0

/* Update final report with College customer Count*/
PRINT 'Update final report with College customer Count'
UPDATE A
SET A.CollegeCustCount = B.CollegeCustCount
FROM Staging.Weekly_RFM_Report A JOIN
	(select NewSEg,Name,A12mf, count(customerid) CollegeCustCount
	from Staging.TempWeeklyRFMReport
	where publiclibrary = 0
	and buyertype > 3
	group by NewSEg,Name,A12mf)B ON A.Newseg = b.newseg and a.name = b.name and a.a12mf = b.a12mf

/* Update final report with Public Library Count*/
PRINT 'Update final report with Public Library Count'
UPDATE A
SET A.PublicLibraryCount = B.PublicLibraryCount
FROM Staging.Weekly_RFM_Report A JOIN
	(SELECT NewSEg,Name,A12mf, count(customerid) PublicLibraryCount
	FROM Staging.TempWeeklyRFMReport t (nolock)
	WHERE publiclibrary = 1
	GROUP BY NewSEg,Name,A12mf)B ON A.Newseg = b.newseg and a.name = b.name and a.a12mf = b.a12mf

/* Update final report with Inquirer Count*/
PRINT 'Update final report with Inquirer Count'
UPDATE A
SET A.TotalCount = B.TotalCount
FROM Staging.Weekly_RFM_Report A JOIN
	(SELECT InqType, Count(*) TotalCount
	FROM Staging.TempWeeklyRFMReport
	WHERE BuyerType = 1
	AND PublicLibrary = 0
	GROUP BY Inqtype)B ON A.Name = B.InqType

UPDATE A
SET A.PublicLibraryCount = B.PublicLibraryCount
FROM Staging.Weekly_RFM_Report A JOIN
	(SELECT InqType, Count(*) PublicLibraryCount
	FROM Staging.TempWeeklyRFMReport
	WHERE BuyerType = 1
	AND PublicLibrary = 1
	GROUP BY Inqtype)B ON A.Name = B.InqType

/* Update final report with HighSchool Customer Count*/
PRINT 'Update final report with HighSchool Customer Count'
UPDATE A
SET A.TotalCount = B.TotalCount
FROM Staging.Weekly_RFM_Report A JOIN
	(SELECT InqType, COUNT(*) TotalCount
	FROM Staging.TempWeeklyRFMReport
	WHERE BuyerType = 3
	AND Publiclibrary = 0
	GROUP BY InqType)B  ON A.Name = B.InqType

/* Update Final report with Publiclibrary  Counts*/
PRINT 'Update Final report with Publiclibrary  Counts'
UPDATE A
SET A.PublicLibraryCount = B.PublicLibraryCount
FROM Staging.Weekly_RFM_Report A JOIN
	(SELECT InqType, COUNT(*) PublicLibraryCount
	FROM Staging.TempWeeklyRFMReport
	WHERE BuyerType = 3
	AND Publiclibrary = 1
	GROUP BY InqType)B  ON A.Name = B.InqType

/* Update final report with RFM Count*/
PRINT 'Update final report with RFM Count'
UPDATE A
SET A.TotalCount = B.TotalCount
FROM Staging.Weekly_RFM_Report A JOIN
	(SELECT InqType, COUNT(*) TotalCount
	FROM Staging.TempWeeklyRFMReport
	WHERE Inqtype = 'NoRFM'
	AND PublicLibrary = 0
	GROUP BY InqType)B  ON A.Name = B.InqType

UPDATE A
SET A.PublicLibraryCount = B.PublicLibraryCount
FROM Staging.Weekly_RFM_Report A JOIN
	(SELECT InqType, COUNT(*) PublicLibraryCount
	FROM Staging.TempWeeklyRFMReport
	WHERE Inqtype = 'NoRFM'
	AND PublicLibrary = 1
	GROUP BY InqType)B  ON A.Name = B.InqType

/* Update Total Count for other rfm segments*/
PRINT 'Update Total Count for other rfm segments'
UPDATE Staging.Weekly_RFM_Report
SET TotalCount = CollegeCustCount + PublicLibraryCount
WHERE NewSeg <> 0

/* Update Final Counts*/
/*PRINT 'Update Final Counts'*/
UPDATE Staging.Weekly_RFM_Report
SET FinalCount = CASE WHEN NewSeg = 0 THEN TotalCount
			ELSE CollegeCustCount
		END

/* Update Final Count for public library*/
PRINT 'Update Final Count for public library'
UPDATE A
SET A.FinalCount = B.PLCount
FROM Staging.Weekly_RFM_Report A,
	(SELECT SUM(PublicLibraryCount) PLCount
	FROM Staging.Weekly_RFM_Report)B
WHERE A.Name = 'Institution'

	-- 5/17/12/SK: update count for DRTV
    update t
    set 
    	t.FinalCount  = t.CollegeCustCount,
        t.TotalCount = t.CollegeCustCount
    from Staging.Weekly_RFM_Report t
    where t.[Name] = 'DRTV'

/* Save in a separate table*/
PRINT 'Save table in another table'
DECLARE @TodaysTable VARCHAR(50), @Qry VARCHAR(8000)

SELECT @TodaysTable = 'Weekly_RFM_Report' + Convert(varchar,getdate(),112)

IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = @TodaysTable)
   BEGIN
	SET @Qry = 'DROP TABLE Archive.' + @TodaysTable
	PRINT (@Qry)
	EXEC (@Qry)
   END


SET @Qry = 'SELECT * INTO Archive.' + @TodaysTable + ' FROM Staging.Weekly_RFM_Report ORDER BY SeqNum'
PRINT (@Qry)
EXEC (@Qry)

    if object_id('Staging.TempWeeklyRFMReport') is not null drop table Staging.TempWeeklyRFMReport
END
GO
