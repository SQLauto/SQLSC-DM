SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Staging].[LoadMidwaySpendTrack]
	@FromDate DATETIME,
	@ToDate DATETIME = '1/1/1900',
	@DebugCode INT = 1
AS
--- Proc Name: 	rfm.dbo.MidwaySpendTracker
--- Purpose:	This is a procedure to track mid way spending of our customers for analysis
---
--- Input Parameters: FromDate - Start date for analysis 
---			ToDate - End date for analysis
---			DebugCode
--- Tables Used: RFM_DATA_SPECIAL_WklyRpt, 
--- Updates:
--- Name		Date		Comments
--- Preethi Ramanujam 	1/16/2008	New
--- Preethi Ramanujam	11/18/2016  added country code
---
    DECLARE @FromDatePY DATETIME -- StartDate for previous year
    DECLARE @FromDatePY2 DATETIME
    DECLARE @ToDatePY   DATETIME -- ToDate for previous year
    DECLARE @ToDatePY2   DATETIME -- ToDate for year 2 prior
    DECLARE @ToDateAdj  DATETIME -- Adjusted ToDate
begin
	set nocount on

    SET @ToDateAdj = @ToDate

    -- Adjust EndDate as needed

    IF @ToDate = '1/1/1900'
       begin
        PRINT 'In IF Statement'
        SET @ToDateAdj = CONVERT(DATETIME,FLOOR(CONVERT(FLOAT,GETDATE())))
       end
    ELSE IF @FromDate > @ToDate
       BEGIN
        RAISERROR('StartDate should be greater than the ToDate',15,1)
        RETURN
       END
    ELSE IF @ToDate < CONVERT(DATETIME,FLOOR(CONVERT(FLOAT,GETDATE())))
        SET @ToDateAdj = DATEADD(day, 1, @ToDate)
    ELSE IF @ToDate > CONVERT(DATETIME,FLOOR(CONVERT(FLOAT,GETDATE())))
        SET @ToDAteAdj = CONVERT(DATETIME,FLOOR(CONVERT(FLOAT,GETDATE())))

    SET @FromDatePY = DATEADD(year,-1,@FromDate)
    SET @FromDatePY2 = DATEADD(year,-2,@FromDate)
    SET @ToDatePY = DATEADD(year,-1,@ToDAteAdj)
    SET @ToDatePY2 = DATEADD(year,-2,@ToDAteAdj)

    IF @DebugCode = 1
       BEGIN
        PRINT 'FromDate = ' + Convert(varchar,@FromDate)
        PRINT 'ToDate = ' + Convert(varchar,@ToDate)
        PRINT 'ToDateAdj = ' + Convert(varchar,@ToDAteAdj)
        PRINT 'FromDatePY = ' + Convert(varchar,@FromDatePY)
        PRINT 'ToDatePY = ' + Convert(varchar,@ToDatePY)
        PRINT 'FromDatePY2 = ' + Convert(varchar,@FromDatePY2)
        PRINT 'ToDatePY2 = ' + Convert(varchar,@ToDatePY2)
       END

    PRINT 'Loading RFM data for ' + CONVERT(VARCHAR,@FromDate)
    EXECUTE Staging.LoadRFMData @FromDate, 'MidwaySpendTrack'

    TRUNCATE TABLE Marketing.MidwaySpendTrack 

    INSERT INTO Marketing.MidwaySpendTrack
    SELECT 
    	RDS.CustomerID, 
        RDS.DropDate as AsOfDate, 
        RDS.Recency, 
        RDS.Frequency, 
        RDS.MonetaryValue, 
        RDS.Concatenated, 
        RDS.a12mF,
        RI.Active, 
        RI.NewSeg, 
        RI.Name,
        @FromDate AS TrackStartDate, 
        @ToDAteAdj AS TrackEndDate,
        ISNULL(OMWS.TotalOrders,0) AS TotalOrders,
        ISNULL(OMWS.TotalSales,0) AS TotalSales,
        OMWS.TotalCourseParts,
        OMWS.TotalCourseQuantity,
        OMWS.TotalCourseSales,
        OMWS.TotalTranscriptParts,
        OMWS.TotalTranscriptQuantity,
        OMWS.TotalTranscriptSales, 
		case when c.CountryCode in ('US','CA','AU','GB') then c.CountryCode
			else 'ROW'
		end as CountryCode
    FROM Staging.RFMDataMST RDS (nolock)
    JOIN Mapping.RFMComboLookup RI (nolock) ON RDS.Concatenated = RI.Concatenated and RDS.a12mf = RI.A12mf
    LEFT OUTER JOIN
    (
    	SELECT 
            O.CustomerID, 
            SUM(o.NetOrderAmount) TotalSales, 
            Count(o.OrderID) TotalOrders,
            sum(po.TotalCourseParts) as TotalCourseParts,
            sum(po.TotalCourseQuantity) as TotalCourseQuantity,
            sum(po.TotalCourseSales) as TotalCourseSales,
            sum(po.TotalTranscriptParts) as TotalTranscriptParts,
            sum(po.TotalTranscriptQuantity) as TotalTranscriptQuantity,
            sum(po.TotalTranscriptSales) as TotalTranscriptSales
        FROM Staging.vwOrders O (nolock)
		join Marketing.DMPurchaseOrders po (nolock) on o.OrderID = po.OrderID        
        WHERE 
        	o.DateOrdered BETWEEN @FromDate AND @ToDAteAdj
	        AND o.NetOrderAmount > 0 and o.NetOrderAmount < 1500
        GROUP BY O.CustomerID
    ) OMWS ON RDS.Customerid = OMWS.CustomerID
	left outer join
	Staging.customers c on RDS.CustomerID = c.CustomerID

    PRINT 'Building RFM_DATA_SPECIAL_WklyRpt for ' + CONVERT(VARCHAR,@FromDatePY)
    EXECUTE Staging.LoadRFMData @FromDatePY, 'MidwaySpendTrack'

    INSERT INTO Marketing.MidwaySpendTrack
    SELECT RDS.CustomerID, RDS.DropDate, 
        RDS.Recency, RDS.Frequency, RDS.MonetaryValue, RDS.Concatenated, RDS.a12mF,
        RI.Active, RI.NewSeg, RI.Name, 
        @FromDatePY AS TrackStartDate, @ToDatePY AS TrackEndDate,
        ISNULL(OMWS.TotalOrders,0) AS TotalOrders,
        ISNULL(OMWS.TotalSales,0) AS TotalSales,
        OMWS.TotalCourseParts,
        OMWS.TotalCourseQuantity,
        OMWS.TotalCourseSales,
        OMWS.TotalTranscriptParts,
        OMWS.TotalTranscriptQuantity,
        OMWS.TotalTranscriptSales, 
		case when c.CountryCode in ('US','CA','AU','GB') then c.CountryCode
			else 'ROW'
		end as CountryCode
    FROM  Staging.RFMDataMST RDS JOIN 
        Mapping.RFMComboLookup RI ON  RDS.Concatenated = RI.Concatenated and 
                            RDS.a12mf = RI.A12mf
        LEFT OUTER JOIN
        (SELECT O.CustomerID, SUM(o.NetOrderAmount)TotalSales, Count(o.OrderID) TotalOrders,
            sum(po.TotalCourseParts) as TotalCourseParts,
            sum(po.TotalCourseQuantity) as TotalCourseQuantity,
            sum(po.TotalCourseSales) as TotalCourseSales,
            sum(po.TotalTranscriptParts) as TotalTranscriptParts,
            sum(po.TotalTranscriptQuantity) as TotalTranscriptQuantity,
            sum(po.TotalTranscriptSales) as TotalTranscriptSales
        FROM Staging.vwOrders O (nolock)
		join Marketing.DMPurchaseOrders po (nolock) on o.OrderID = po.OrderID                
        WHERE o.DateOrdered BETWEEN @FromDatePY AND @ToDatePY
        AND o.NetOrderAmount > 0 and o.NetOrderAmount < 1500
        GROUP BY O.CustomerID)OMWS ON RDS.Customerid = OMWS.CustomerID
	left outer join
	Staging.customers c on RDS.CustomerID = c.CustomerID

    /*
    SELECT AsOfDate, Active, Frequency, Count(CustomerID) CustCount, SUM(TotalSales) TotalSales,
        SUM(TotalOrders) TotalOrders, Sum(TotalSales)/Count(CustomerID) SalesPerCust
    FROM rfm.dbo.MidwaySpendTrack 
    GROUP BY AsOfDate, Active, Frequency
    ORDER BY 1,2,3
    */

    --PRINT 'Building RFM_DATA_SPECIAL_WklyRpt for todays data again'
    --DECLARE @Today DATETIME
    --SET @Today = CONVERT(DATETIME,FLOOR(CONVERT(FLOAT,GETDATE())))
    --EXECUTE rfm.[dbo].[rfm_buildSpecial_WklyRpt] @Today
end
GO
