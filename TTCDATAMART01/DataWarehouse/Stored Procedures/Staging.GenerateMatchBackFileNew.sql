SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [Staging].[GenerateMatchBackFileNew]
	@CatalogCode INT,
	@CountryCode varchar(2) = 'US',
	@DebugCode INT = 0
AS
-- Proc Name: 	rfm.dbo.GenerateMatchBackFileNew
-- Purpose:	This is a procedure used to generate match back files for outside waves
--
-- Input Parameters: @CatalogCode -- Catalog code for the main outside wave that we 
--				 	want the match back file.
--		     @DebugMode - SET to 0 by default.
		
-- Tables Used:  
-- UPDATEs:
-- Name		Date		Comments
-- Preethi Ramanujam 	1/31/2008	New
--

--- STEP 1: Declare and assign variables
--DECLARE @CatalogCode INT
DECLARE @CatalogName VARCHAR(50)	-- To capture catalog information to create final mail file table
DECLARE @MatchType VARCHAR(50)	 	-- To capture if it is final or midway matchback
DECLARE @Description VARCHAR(50) 	-- To Capture the description
DECLARE @DropDate DATETIME	 	-- To Capture dropdate for the mail
DECLARE @EndDate DATETIME		-- To Capture EndDate for the mail
DECLARE @MBStartDate DATETIME		-- StartDate for the match back file. One week prior to @DropDate.
DECLARE @MBEndDate DATETIME		-- Today's date.
DECLARE @FnlTblName VARCHAR(200)  	-- Final table name will be derived based on mailpiece, Todays date.
DECLARE @Qry nVARCHAR(300)      	-- To capture queries for dynamic queries
DECLARE @ErrorMsg VARCHAR(400)   	-- Error message for error handling.

begin
	set nocount on
    --- Check to make sure CatalogCode is provided by the user.
    IF @CatalogCode IS NULL
    BEGIN	
        SET @ErrorMsg = 'Please provide CatalogCode for the Mail Piece'
        RAISERROR(@ErrorMsg,15,1)
        RETURN
    END

    --- Check to make sure CatalogCode Provided is correct.
    DECLARE @Count INT
    SELECT @Count = COUNT(*)
    FROM Staging.MktCatalogCodes
    WHERE CatalogCode = @CatalogCode

    IF @Count = 0
    BEGIN	
        SET @ErrorMsg = 'CatalogCode ' + CONVERT(VARCHAR,@CatalogCode) + ' does not exist. Please Provide a valid Catalogcode'
        RAISERROR(@ErrorMsg,15,1)
        RETURN
    END

    -- Get other parameters based on the CatalogCode.

    SELECT DISTINCT @CatalogName = replace(REPLACE(Name,' ',''), '.', ''),
        @DropDate = StartDate,
        @EndDate = StopDate,
        @MBStartDate = DATEADD(Day,-8,StartDate),
        @Description = Description
    FROM Staging.MktCatalogCodes
    WHERE CatalogCode = @CatalogCode

    -- Make sure the catalogcode is for Outside wave

    SELECT @Count = COUNT(*)
    FROM Staging.MktCatalogCodes
    WHERE CatalogCode = @CatalogCode 
    AND (REPLACE(Name,' ','') like '%OSW%' OR REPLACE(Name,' ','') like '%Outside%')

    IF @Count = 0 
    BEGIN
        SET @ErrorMsg = 'CatalogCode ' + CONVERT(VARCHAR,@CatalogCode) + ' is for ' + @CatalogName + '. Please Provide a valid Catalogcode'
        RAISERROR(@ErrorMsg,15,1)
        RETURN
    END

    -- Create table names.
    SET @MBEndDate = CONVERT(DATETIME,FLOOR(CONVERT(FLOAT,GETDATE())))

    IF @EndDate > @MBEndDate
        SET @MatchType = 'MidWay'
    ELSE 
        SET @MatchType = 'Final'

    SET @FnlTblName = @MatchType + @CatalogName + '_' + 'MatchBack_' + CONVERT(VARCHAR,GETDATE(),112)

    PRINT '@catalogcode = ' + CONVERT(VARCHAR,@catalogcode) 
    PRINT '@CatalogName = ' + @CatalogName 
    PRINT '@FnlTblName = ' + @FnlTblName


    --- Drop if @FnlTblName already exists
/*    DECLARE @RowCounts INT
    SELECT @RowCounts = COUNT(*) FROM sysobjects
    WHERE Name = REPLACE(@FnlTblName,'rfm.dbo.','')
    SELECT '@RowCounts = ' + CONVERT(VARCHAR,@RowCounts) */

    /*IF @RowCounts > 0
	if object_id(@FnlTblName, N'U') is not null     
    BEGIN
        SET @Qry = 'DROP TABLE ' + @FnlTblName
        SELECT @Qry
         EXEC (@Qry)
    END*/
    
    if object_id('Staging.TempMatchBackFile') is not null 
    drop table Staging.TempMatchBackFile

    --- Generate  @FnlTblName 
/*    SET @Qry = 'CREATE   TABLE ' + @FnlTblName +
            ' (Customerid INT NOT NULL,
            Prefix VARCHAR(50) NULL,
            FirstName VARCHAR(50) NULL,
            MiddleInitial char(10) NULL,
            LastName VARCHAR(50) NULL,
            Suffix VARCHAR(50) NULL,
            Company VARCHAR(50) NULL,
            Address1 VARCHAR(40) NULL,
            Address2 VARCHAR(40) NULL,
            City VARCHAR(40) NULL,
            State VARCHAR(40) NULL,
            PostalCode VARCHAR(40) NULL,
            CountryCode VARCHAR(10) NULL,
            IntlSales MONEY NULL)' + CHAR(13) + CHAR(10)
    	

    PRINT 'Creating CustTable ' + CHAR(13) + CHAR(10) + @Qry + CHAR(13) + CHAR(10)
     EXEC (@Qry)

    -- Create Index
    SET @Qry = 'CREATE CLUSTERED INDEX IX_' + REPLACE(@FnlTblName,'rfm.dbo.','') + 
           ' ON ' + @FnlTblName + ' (CustomerID)'

    PRINT 'Creating Index ' + CHAR(13) + CHAR(10) + @Qry + CHAR(13) + CHAR(10)
     EXEC (@Qry)

    -- Add CustomerIDs to the list
    SET @Qry = 'INSERT into  ' + @FnlTblName + ' (customerID) ' + CHAR(13) + CHAR(10) + 
           'SELECT DISTINCT customerID FROM  ccqdw.dbo.orders' + CHAR(13) + CHAR(10) +
           ' WHERE DateOrdered > ''' + CONVERT(VARCHAR,@MBStartDate,101) + '''' 
    -- Only if we want match back between certain dates
    --	' WHERE DateOrdered BETWEEN ''' + CONVERT(VARCHAR,@MBStartDate,101) + ''' and ''' + CONVERT(VARCHAR,@EndDate,101) + ''''
*/    
    select
		o.CustomerID,
		ISNULL(ccs.[Prefix],'') as [Prefix],
        ISNULL(ccs.FirstName,'') as FirstName, 
        ISNULL(ccs.MiddleName,'') as MiddleName, 
        ISNULL(ccs.LastName,'') as LastName, 
        ISNULL(ccs.Suffix,'') as Suffix, 
        ISNULL(ccs.Address1,'') as Address1, 
        convert(nvarchar(40), ISNULL(ccs.Address2,'')) as Address2, 
        ISNULL(ccs.City,'') as City, 
        ISNULL(ccs.[State],'') as [State], 
        ISNULL(ccs.PostalCode,'') as PostalCode,
        ISNULL(ccs.CountryCode,'') as CountryCode,
        ISNULL(dmcs.IntlPurchAmount, 111111111) as IntlSales
	into Staging.TempMatchBackFile
	from (select distinct o.CustomerID from Staging.vwOrders o (nolock) where o.DateOrdered > @MBStartDate) o 
    left join Marketing.CampaignCustomerSignature ccs ON o.customerid = ccs.customerid
    left join Marketing.DMCustomerStatic dmcs on o.customerid = dmcs.customerid


    	   
/*
    PRINT 'Add CustomerIDs to the table.' + CHAR(13) + CHAR(10) + @Qry + CHAR(13) + CHAR(10)
     EXEC (@Qry)

    -- Add Customer Name, Address information
    SET @Qry = 'UPDATE MB
        SET mb.Prefix = ISNULL(ccs.prefix,''''),
            mb.FirstName = ISNULL(ccs.FirstName,''''), 
            mb.MiddleInitial = ISNULL(ccs.MiddleInitial,''''), 
            mb.LastName = ISNULL(ccs.lastname,''''), 
            mb.Suffix = ISNULL(ccs.suffix,''''), 
            mb.Address1 = ISNULL(ccs.address1,''''), 
            mb.Address2 = ISNULL(ccs.Address2,''''), 
            mb.City = ISNULL(ccs.City,''''), 
            mb.State = ISNULL(ccs.State,''''), 
            mb.PostalCode = ISNULL(ccs.Postalcode,''''),
            mb.CountryCode = ISNULL(ccs.CountryCode,'''')		
        FROM ' + @FnlTblName + ' mb JOIN 
            marketingdm.dbo.campaigncustomersignature ccs ON mb.customerid = ccs.customerid'

    PRINT 'Add Customer Name, Address information.' + CHAR(13) + CHAR(10) + @Qry + CHAR(13) + CHAR(10)
     EXEC (@Qry)*/

    -- If Address is missing, add FROM Orders table
    
/*    SET @Qry = 'UPDATE MB 
        SET mb.address1 = ord.BillingAddress, 
            mb.address2 = ord.BillingAddress2, 
            mb.City = ord.BillingCity, 
            mb.state =  ord.BillingRegion, 
            mb.Postalcode = ord.BillingPostalCode,
            mb.Countrycode = ord.BillingCountryCode
        FROM ' + @FnlTblName + ' MB JOIN
            (SELECT o.customerid,o.OrderID, o.DateOrdered,NetOrderAmount,    BillingAddress, 
                BillingAddress2, BillingCity, 
                BillingCountryCode, BillingRegion, BillingPostalCode
            FROM
                ccqdw.dbo.orders o join
                (SELECT O.customerid, MAX(O.orderid) orderid, MAX(O.dateordered) dateordered
                 FROM ' + @FnlTblName + ' mb JOIN
                    ccqdw.dbo.orders o ON mb.CustomerID = O.CustomerID
                WHERE ISNULL(mb.address1,'''') = ''''
                GROUP BY O.customerid)maxo on o.customerid = maxo.customerid and o.orderid = maxo.orderid)Ord
            ON MB.CustomerID = Ord.customerid'*/
    

    UPDATE MB 
        SET mb.address1 = isnull(ord.BillingAddress, ''), 
            mb.address2 = isnull(ord.BillingAddress2, ''), 
            mb.City = isnull(ord.BillingCity, ''), 
            mb.state =  isnull(ord.BillingRegion, ''), 
            mb.Postalcode = isnull(ord.BillingPostalCode, ''),
            mb.Countrycode = isnull(ord.BillingCountryCode, '')
        FROM Staging.TempMatchBackFile MB JOIN
            (SELECT o.customerid,o.OrderID, o.DateOrdered,NetOrderAmount,    BillingAddress, 
                BillingAddress2, BillingCity, 
                BillingCountryCode, BillingRegion, BillingPostalCode
            FROM
                Staging.vworders o join
                (SELECT O.customerid, MAX(O.orderid) orderid, MAX(O.dateordered) dateordered
                 FROM Staging.TempMatchBackFile mb JOIN
                    Staging.vworders o ON mb.CustomerID = O.CustomerID
                WHERE ISNULL(mb.address1,'') = ''
                GROUP BY O.customerid)maxo on o.customerid = maxo.customerid and o.orderid = maxo.orderid)Ord
            ON MB.CustomerID = Ord.customerid

/*    PRINT 'Add Missing Address information' + CHAR(13) + CHAR(10) + @Qry + CHAR(13) + CHAR(10)
     EXEC (@Qry)

    -- Update Initial Sales information

    SET @Qry = 'UPDATE MB
        SET mb.IntlSales = ISNULL(dmcs.IntlPurchAmount,111111111)
        FROM ' + @FnlTblName + ' mb join
            marketingdm.dbo.DMCustomerStatic dmcs on mb.customerid = dmcs.customerid'

    PRINT 'Add Initial Purchase Amount' + CHAR(13) + CHAR(10) + @Qry + CHAR(13) + CHAR(10)
     EXEC (@Qry) */

    -- Add Missing Initial sales amount

    UPDATE MB
        SET mb.IntlSales = Ord.NetOrderAmount
        FROM Staging.TempMatchBackFile MB JOIN
            (SELECT o.customerid,o.OrderID, o.DateOrdered,NetOrderAmount
            FROM Staging.vworders o join
                (SELECT o.customerid, min(orderid) orderid, MAX(dateordered) dateordered
                 FROM Staging.TempMatchBackFile mb JOIN
                    Staging.vworders o ON mb.CustomerID = o.customerID
                WHERE ISNULL(mb.IntlSales,111111111) = 111111111
                GROUP BY o.customerid)mino on o.customerid = mino.customerid and o.orderid = mino.orderid)Ord
            ON MB.CustomerID = Ord.customerid
            
/*    SET @Qry = 'UPDATE MB
        SET mb.IntlSales = Ord.NetOrderAmount
        FROM ' + @FnlTblName + ' MB JOIN
            (SELECT o.customerid,o.OrderID, o.DateOrdered,NetOrderAmount
            FROM ccqdw.dbo.orders o join
                (SELECT o.customerid, min(orderid) orderid, MAX(dateordered) dateordered
                 FROM ' + @FnlTblName + ' mb JOIN
                    ccqdw.dbo.orders o ON mb.CustomerID = o.customerID
                WHERE ISNULL(mb.IntlSales,111111111) = 111111111
                GROUP BY o.customerid)mino on o.customerid = mino.customerid and o.orderid = mino.orderid)Ord
            ON MB.CustomerID = Ord.customerid'
            

    PRINT 'Add missing Initial Purchase Amount' + CHAR(13) + CHAR(10) + @Qry + CHAR(13) + CHAR(10)
     EXEC (@Qry)*/

    -- Update Missing Name information
    UPDATE mb
        SET mb.Prefix = isnull(c.prefix, ''),
            mb.firstname = isnull(c.firstname, ''),
            mb.middleName = isnull(c.middleinitial, ''),
            mb.lastname = isnull(c.lastname, ''),
            mb.suffix = isnull(c.suffix, '')
        FROM Staging.TempMatchBackFile MB JOIN
            (SELECT C.* FROM 
            Superstardw.dbo.Customers C JOIN  
            Staging.TempMatchBackFile mb on c.customerid = mb.customerid
            WHERE ISNULL(mb.FirstName,'') = '')C on mb.customerid = c.customerid
            
/*    SET @Qry = 'UPDATE mb
        SET mb.Prefix = c.prefix,
            mb.firstname = c.firstname,
            mb.middleinitial = c.middleinitial,
            mb.lastname = c.lastname,
            mb.suffix = c.suffix
    	
        FROM ' + @FnlTblName + ' MB JOIN
            (SELECT C.* FROM 
            Superstardw.dbo.Customers C JOIN ' + 
            @FnlTblName + ' mb on c.customerid = mb.customerid
            WHERE ISNULL(mb.FirstName,'''') = '''')C on mb.customerid = c.customerid'
            
     
    PRINT 'Add missing Name information ' + CHAR(13) + CHAR(10) + @Qry + CHAR(13) + CHAR(10)
     EXEC (@Qry) */

	

    -- Remove any carriage returns in the address field

    UPDATE Staging.TempMatchBackFile 
           SET address1 = replace(replace(ISNULL(address1,''),char(13),''),char(10),''),
            address2 = replace(replace(ISNULL(address2,''),char(13),''),char(10),'')
--            , company = replace(replace(ISNULL(company,''),char(13),''),char(10),'')
            
	--if @CountryCode <> 'US'   -- Even for US, drop international orders.. -- PR 4/4/2016          
    delete Staging.TempMatchBackFile
    where CountryCode <> @CountryCode
            
/*    SET @Qry = 'UPDATE ' + @FnlTblName + 
           ' SET address1 = replace(replace(ISNULL(address1,''''),char(13),''''),char(10),''''),
            address2 = replace(replace(ISNULL(address2,''''),char(13),''''),char(10),''''),
            company = replace(replace(ISNULL(company,''''),char(13),''''),char(10),'''')'
            

    PRINT 'Remove any carriage returns in the address field' + CHAR(13) + CHAR(10) + @Qry + CHAR(13) + CHAR(10)
     EXEC (@Qry)*/
     
    if object_id('Staging.' + @FnlTblName) is not null 
    begin
		set @Qry = 'drop table Staging.' + @FnlTblName
		exec sp_executesql @Qry 
    end
    
    exec sp_rename 'Staging.TempMatchBackFile', @FnlTblName
     
end
GO
