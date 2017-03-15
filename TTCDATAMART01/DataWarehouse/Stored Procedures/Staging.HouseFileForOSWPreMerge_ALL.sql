SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Staging].[HouseFileForOSWPreMerge_ALL]
      @OSWType VARCHAR(10),
      @Wave VARCHAR(10) = 'OSW',
      @Year INT = 1900,
      @CountryCode varchar(2) = 'US',
      @DebugCode INT = 1
AS
--- Proc Name:    MarketingDM.dbo.HouseFileForOSWPreMerge
--- Purpose:      To Generate list of house file for Outside PreMerge process
---   
--- Special Tables Used: 
---
--- Input Parameters:
---         @OSWType ex: Fall, Spring, HS etc
---         @Wave        ex: OSW1/ OSW3 etc
---         @Year    Year of the OSW
---         
--- Updates:
--- Name          Date        Comments
--- Preethi Ramanujam   10/12/2007  New
--- Preethi Ramanujam   10/30/2007  Updated names from Customers table for Institutions.
--- Preethi Ramanujam   01/06/2009  To create one consolidate file instead splitting them by segments.

--- Declare variables
    DECLARE 
		@TblBase VARCHAR(50),
/*        @TblCllgAll VARCHAR(100),
        @TblHSAll VARCHAR(100),
        @TblInqAll VARCHAR(100),
        @TblDoNotMail VARCHAR(100),
        @TblNoBllngAd VARCHAR(100),
        @TblCllgOnly VARCHAR(100),
        @TblBothCllgHS VARCHAR(100),*/
        @PullDate DATETIME
begin
	set nocount on

    SET @PullDate = CONVERT(DATETIME,FLOOR(CONVERT(FLOAT,GETDATE())))

    IF @Year = 1900 
          SET @Year = YEAR(GETDATE())

    PRINT 'Year is ' + CONVERT(VARCHAR,@Year)

    SET @TblBase = 'House_' + @OSWType + @Wave + CONVERT(VARCHAR,@Year) + @CountryCode + '_AllCust'
    -- SET @TblCllgAll = @TblBase + '_AllCllgPC'
    -- SET @TblHSAll = @TblBase + '_AllHSPC'
    -- SET @TblInqAll = @TblBase + '_AllInquirers'
    -- SET @TblDoNotMail = @TblBase + '_DoNotMail'
    -- SET @TblNoBllngAd = @TblBase + '_NoBllngAdrs'
    -- SET @TblCllgOnly = @TblBase + '_CllgOnly'
    -- SET @TblBothCllgHS = @TblBase + '_BothCllgHS'

    IF @DebugCode = 1
       BEGIN
          PRINT 'Base table = ' + @TblBase
    --    PRINT 'All Collge Table = ' + @TblCllgAll
    --    PRINT 'All HighSchool table = ' + @TblHSAll
    --    PRINT 'Cllg but no HS = ' + @TblCllgOnly
    --    PRINT 'Cllg Plus HS Table = ' + @TblBothCllgHS
    --    PRINT 'All Inquirer Table = ' + @TblInqAll
    --    PRINT 'All DoNotMail Table = ' + @TblDoNotMail
    --    PRINT 'No Billing Address Table = ' + @TblNoBllngAd
       END

    DECLARE @Qry nVARCHAR(200)

    -- Get the list of all College customers

    PRINT 'Get the list of all College customers'

/*
    DECLARE @RowCounts INT
    SELECT @RowCounts = COUNT(*) FROM sysobjects
    WHERE Name = @TblBase
    SELECT '@RowCounts = ' + CONVERT(VARCHAR,@RowCounts)

    IF @RowCounts > 0
    BEGIN
          SET @Qry = 'DROP TABLE Staging.' + @TblBase
          SELECT @Qry
          EXEC (@Qry)
    END
*/

    if object_id(N'Staging.TempHouseFileForMerge', N'U') is not null drop table Staging.TempHouseFileForMerge

    SELECT Distinct 
    	CCS.CustomerID, 
        CCS.[Prefix], 
	    CASE 
        	WHEN CCS.FirstName LIKE '%LifeLong%' THEN C.FirstName
	         ELSE CCS.FirstName
    	END AS FirstName, 
        CCS.MiddleName,
	    CASE 
        	WHEN CCS.LastName LIKE '%Learner%' THEN C.LastName
         	ELSE CCS.LastName
    	END AS LastName, 
        CCS.Suffix, 
        --CCS.Company, 
        CCS.Address1,
	    CCS.Address2, 
        CCS.City, 
        CCS.[State], 
        CCS.PostalCode, 
        CCS.CountryCode,
        ccs.CountryName,
    	ISNULL(CONVERT(VARCHAR(10),CCS.PreferredCategory),'Unknown') PreferredCategory,
	    CASE 
        	-- WHEN CCS.Customersegment = 'Swamp' THEN 'Inactive' -- PR -- 5/21/2014 changed to Inactive based on new definition
        	WHEN CCS.Customersegment = 'Inactive' THEN 'Inactive'
	        WHEN CCS.CustomerSegment = 'Active' THEN 'Active'
    	    WHEN CCS.CustomerSegment LIKE '%Inq%' THEN 'Inquirer'
        	ELSE 'Unknown'
	    END AS CustomerSegment,
	    CASE 
        	WHEN CCS.BuyerType > 3 then 'College'
	        WHEN CCS.BuyerType = 3 then 'HighSchool'
        	ELSE 'Other'
    	END AS CustomerType,
    	O.DateOrdered AS DateLastPurchased
	iNTO Staging.TempHouseFileForMerge
	FROM Marketing.CampaignCustomerSignature CCS (nolock) 
    JOIN Staging.Customers C (nolock) ON CCS.CustomerID = C.CustomerID 
    LEFT OUTER JOIN 
    (
    	SELECT customerid, MAX(dateordered) AS DateOrdered, MAX(orderid) AS Maxorderid 
        FROM Staging.vworders (nolock) 
        GROUP BY customerid
	) O ON CCS.CustomerID = O.CustomerID
    where ccs.CountryCode = 
		case @CountryCode
        	when 'US' then ccs.CountryCode
            else @CountryCode
		end            
--ORDER BY CCS.PreferredCategory, CCS.CustomerSegment

/*
    IF @DebugCode = 1
       PRINT 'Executing Query : ' + @Qry

    EXEC (@Qry)

    SET @Qry = 'CREATE INDEX IX_' + @TblBase + '_Cust ON MarketingDM.dbo.' + @TblBase + ' (CustomerID)'

    IF @DebugCode = 1
       PRINT 'Executing Query : ' + @Qry

    EXEC (@Qry)

    SET @Qry = 'CREATE Clustered INDEX IX_' + @TblBase + '_PrfCt ON MarketingDM.dbo.' + @TblBase + ' (PreferredCategory)'

    IF @DebugCode = 1
       PRINT 'Executing Query : ' + @Qry

    EXEC (@Qry)
    */
    
    if object_id('Staging.' + @TblBase, N'U') is not null 
    begin
		set @Qry = 'drop table Staging.' + @TblBase    	
		exec sp_executesql @Qry
    end
    
    exec sp_rename 'Staging.TempHouseFileForMerge', @TblBase
end
GO
