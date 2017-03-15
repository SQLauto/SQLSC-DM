SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [Staging].[GenerateMatchBackFileTGCPlus]
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

    SET @FnlTblName = @MatchType + @CatalogName + '_' + 'TGCPMtchBck_' + CONVERT(VARCHAR,GETDATE(),112)

    PRINT '@catalogcode = ' + CONVERT(VARCHAR,@catalogcode) 
    PRINT '@CatalogName = ' + @CatalogName 
    PRINT '@FnlTblName = ' + @FnlTblName


   
    if object_id('Staging.TempMatchBackFileTGCPlus') is not null 
    drop table Staging.TempMatchBackFileTGCPlus

   select
		u.uuid as CustomerID,
		convert(varchar(10),'') as Prefix,
        b.userFirstName as FirstName, 
        convert(varchar(20),'') as MiddleName, 
        b.userLastName as LastName, 
        convert(varchar(10),'') as Suffix,
        b.FullName, 
        b.line1 as Address1, 
        b.line2 as Address2, 
        b.line3 as Address3,
        b.city as City,
        b.region as State,
        b.postalCode as PostalCode,
        convert(varchar(2),'US') as CountryCode
	into Staging.TempMatchBackFileTGCPlus
	from Archive.TGCPlus_User u 
	join Archive.TGCPlus_BillingAddress b on u.uuid = b.userId
	where cast(u.entitled_dt as date) between cast(@MBStartDate as date) and cast(@EndDate as date)
	and u.email not like '%+%'
	and u.email not like '%plustest%' 
	and u.email not like '%teachco%'
	and b.country in ('US','United States Virgin Islands','United States')
	and b.line1 not like '%westfields blvd%'


    -- Remove any carriage returns in the address field

    UPDATE Staging.TempMatchBackFileTGCPlus 
           SET address1 = replace(replace(ISNULL(address1,''),char(13),''),char(10),''),
            address2 = replace(replace(ISNULL(address2,''),char(13),''),char(10),''),
            Address3 = replace(replace(ISNULL(Address3,''),char(13),''),char(10),'')
            
	if @CountryCode <> 'US'            
    delete Staging.TempMatchBackFileTGCPlus
    where CountryCode <> @CountryCode
    
     
    if object_id('Staging.' + @FnlTblName) is not null 
    begin
		set @Qry = 'drop table Staging.' + @FnlTblName
		exec sp_executesql @Qry 
    end
    
    exec sp_rename 'Staging.TempMatchBackFileTGCPlus', @FnlTblName
    
    --exec staging.ExportTableToPipeText rfm, dbo, @FnlTblName, '\\File1\Marketing\Plan2K15\Outside Mailings\Prospect Catalogs\US'

     
end
GO
