SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Staging].[CreateMailFile]
	@CatalogCode INT,
	@MaxSubjRank VARCHAR(5) = 'S100'
AS
/*- Proc Name: 	CreateMailFile*/
/*- Purpose:	This is wrapper procedure that invokes appropriate mail file */
/*-		pull procedure based on the catalog code provided.*/
/*- Input Parameters: CatalogCode, */
/*-			MaxSubjRank - defaults to S1 or S2 based on Subject category,*/
/*- Name		Date		Comments*/
/*- Preethi Ramanujam 	5/17/2007	New*/

    DECLARE 
    	@CatalogName VARCHAR(50), /*- To capture catalog information to create final mail file table*/
    	@MailPiece VARCHAR(50),	 /*- To capture the kind of mail piece. (like catalog/magalog etc)*/
		@Description VARCHAR(50), /*- */
    	@DropDate DATETIME,	 /*- To Capture dropdate for the mail*/
    	@FnlTblName VARCHAR(200),  /*- Final table name will be derived based on mailpiece, dropdate etc.*/
    	@MailIPTbl VARCHAR(200),   /*- Intermediate table*/
    	@SQLCommand nVARCHAR(300),      /*- To capture queries for dynamic queries*/
    	@ErrorMsg VARCHAR(400),   /*- Error message for error handling.*/
    	@Adcode INT,		 /*- Temp Until we have adcodes genrated earlier..*/
        @CountryCode varchar(5),
		@PrimarySubject VARCHAR(5),
        @AdcodeActive int = 99999,
        @StopDate date
begin
    set nocount on

    Print '@CatalogCode = ' + convert(varchar,@CatalogCode)
    print '@Adcode = ' + convert(varchar,@Adcode)
    print '@MaxSubjRank = ' + convert(varchar,@MaxSubjRank)

    /*- Check to make sure CatalogCode is provided by the user.*/
    IF @CatalogCode IS NULL
    BEGIN	
        SET @ErrorMsg = 'Please provide CatalogCode for the Mail Piece'
        RAISERROR(@ErrorMsg,15,1)
        RETURN
    END

    /*- Check to make sure CatalogCode Provided is correct.*/
    SELECT 
    	@MailPiece = 
            case 
                when cc.DaxMktPromotionType in (1, 6, 7, 17, 101,103, 16) then 'Catalogs'
                when cc.DaxMktPromotionType = 2 then 'Swamp'
                when cc.DaxMktPromotionType = 3 then 'Magazines'        
                when cc.DaxMktPromotionType in (4, 5, 14) then 'Magalogs'                                        
                when cc.DaxMktPromotionType = 8 and cc.DaxMktCampaign = 87 then 'JFYSimple'
                when cc.DaxMktPromotionType = 8 and cc.DaxMktCampaign = 88 then 'JFYFormatSpecific'        
                when cc.DaxMktPromotionType = 8 and cc.DaxMktCampaign = 89 then 'JFYSubjectSpecific'                
                when cc.DaxMktPromotionType = 10 then 'Newsletters'                
                when cc.DaxMktPromotionType = 22 then 'Library'
                else 'Catalogs'
            end,
		@CountryCode = c.MD_Country,
		@CatalogName = REPLACE(Name,' ',''),
        @DropDate = StartDate,
        @Description = Description,
        @PrimarySubject = 
        	CASE WHEN LEFT(Name,CHARINDEX(' ',Name)-1) = 'LT' THEN 'LIT'
            	WHEN LEFT(Name,CHARINDEX(' ',Name)-1) = 'RG' THEN 'RL'
                WHEN LEFT(Name,CHARINDEX(' ',Name)-1) = 'Econ' THEN 'EC'
                WHEN cc.DaxMktPromotionType in (6, 7) THEN LEFT(Name,3)
                ELSE LEFT(Name,CHARINDEX(' ',Name)-1)
            END        
    FROM Staging.MktCatalogCodes cc (nolock)
    join Mapping.MktDim_Country c on cc.DaxMktRegion = c.MD_CountryID
    WHERE CatalogCode = @CatalogCode
    
    PRINT '@MailPiece = ' + @MailPiece
    PRINT '@CountryCode = ' + @CountryCode
    PRINT '@CatalogName = ' + @CatalogName
    PRINT '@DropDate = ' + convert(varchar,@DropDate)
    PRINT '@Description = ' + @Description
    PRINT '@PrimarySubject = ' + @PrimarySubject
    
    SELECT @AdcodeActive = Adcode
    FROM Staging.MktAdcodes
    WHERE CatalogCode = @CatalogCode
    AND UPPER(Name) LIKE '%ACTIVE%CONTROL%'
    
    PRINT '@AdcodeActive = ' + convert(varchar,@AdcodeActive)
    
  	if object_id('Staging.TempMailPull') is not null
    drop table Staging.TempMailPull
    
    -- check countryCode and create mail files if they are non us
    -- else run normal US
    if @CountryCode = 'CA'
        SELECT *, @AdcodeActive as AdCode, @DropDate as StartDate
        INTO Staging.TempMailPull
        from marketing.CampaignCustomerSignature
        where 
        	( CountryCode = @CountryCode OR State in ('AB','BC','MB','NB','NL','NT','NS','NU','ON','PE','QC','SK','YT'))
	        and  FlagMail = 1
    	    and PublicLibrary = 0
	else if  @CountryCode in ('GB', 'AU')            
        SELECT *, @AdcodeActive as AdCode, @DropDate as StartDate
        INTO Staging.TempMailPull
        from Marketing.CampaignCustomerSignature
        where 
        	CountryCode = @CountryCode
	        and  FlagMail = 1
    	    and PublicLibrary = 0
	else begin    
        IF @MailPiece is null
        BEGIN	
            SET @ErrorMsg = 'CatalogCode ' + CONVERT(VARCHAR,@CatalogCode) + ' does not exist. Please Provide a valid Catalogcode'
            RAISERROR(@ErrorMsg,15,1)
            RETURN
        END
    
        /*- Check if the RFMPullDate is updated.*/
        DECLARE @CheckFMPullCount INT
        DECLARE @CheckFMPullDate DATETIME

        SELECT @CheckFMPullDate = FMPullDate
        FROM Marketing.CampaignCustomerSignature  

        SELECT @CheckFMPullCount = COUNT(*) 
        FROM Marketing.CampaignCustomerSignature 
        WHERE CONVERT(VARCHAR,FMPullDate,101) = CONVERT(VARCHAR,Getdate(),101)

        Print '@CheckFMPullCount = ' + CONVERT(VARCHAR,@CheckFMPullCount)
        Print '@CheckFMPullDate  = ' + CONVERT(VARCHAR,@CheckFMPullDate,101)

        IF @CheckFMPullCount = 0 
        BEGIN
            SET @ErrorMsg = '***** WARNING *****: RFMPullDate is : ' + CONVERT(VARCHAR, @CheckFMPullDate,101) + '. Please check to make sure RFM_DATA_Special/CustomerSignature tables are upto date.'
            RAISERROR(@ErrorMsg,15,1)
        END

--        SET @FnlTblName = 'Staging.Mail_' + @CatalogName + '_' + CONVERT(VARCHAR,@DropDate,112)   /* CONVERT(VARCHAR,MONTH(@DropDate)) + CONVERT(VARCHAR,DAY(@DropDAte)) + CONVERT(VARCHAR,YEAR(@DropDate))*/
	    set @FnlTblName = 'Mail_' + @CountryCode + '_' + @CatalogName + '_' + convert(varchar, @DropDate, 112)
        SET @MailIPTbl = @FnlTblName + '_MailIP'

        PRINT 'MailPiece = ' + @MailPiece + ' ,Dropdate = ' + CONVERT(VARCHAR,@dropdate,101)
        PRINT '@catalogcode = ' + CONVERT(VARCHAR,@catalogcode) + ' ,@Description = ' + @Description
        PRINT '@CatalogName = ' + @CatalogName + ' ,@PrimarySubject = ' + @PrimarySubject
        PRINT '@FnlTblName = ' + @FnlTblName + ' ,@MailIPTbl = ' + @MailIPTbl

        /*- Get Adcode Information for the specific catalog*/
        DECLARE @AdcodeSwamp INT
        DECLARE @AdcodeInq INT

        SELECT @AdcodeSwamp = Adcode
        FROM Staging.MktAdcodes
        WHERE CatalogCode = @CatalogCode
        AND UPPER(Name) LIKE '%SWAMP%CONTROL%'

        SELECT @AdcodeInq =  Adcode
        FROM Staging.MktAdcodes
        WHERE CatalogCode = @CatalogCode
        AND UPPER(Name) LIKE '%INQ%CONTROL%'

        IF @AdcodeActive = 99999
        BEGIN
            SET @ErrorMsg = 'No Adcode is listed for CatalogCode ' + CONVERT(VARCHAR,@CatalogCode) + '. Using default Adcode to create the list. Please update the adcode later.'
            PRINT (@ErrorMsg)
        END

        IF @AdcodeSwamp IS NULL	SET @AdcodeSwamp = @AdcodeActive
        IF @AdcodeInq IS NULL SET @AdcodeInq = @AdcodeActive

        SELECT @AdcodeSwamp, @AdcodeActive, @AdcodeInq
        /*- If DropDate and Adcodes are null, then let the user know. --- Need to build this in UI*/

        IF @MailPiece LIKE 'Catalog%'
        BEGIN
            SELECT 'Staging.CreateCatalogMailFile ', @CatalogCode,@CatalogName,@MailPiece,@DropDate,@PrimarySubject,@AdcodeActive,@AdcodeSwamp
            EXEC Staging.CreateCatalogMailFile @CatalogCode,@CatalogName,@MailPiece,@DropDate,@PrimarySubject,@AdcodeActive,@AdcodeSwamp
        END

        IF @MailPiece LIKE 'Swamp%'
        BEGIN
            SELECT 'Staging.CreateCatalogMailFile ', @CatalogCode,@CatalogName,@MailPiece,@DropDate,@PrimarySubject,@AdcodeActive,@AdcodeSwamp
            EXEC Staging.CreateCatalogMailFile @CatalogCode,@CatalogName,@MailPiece,@DropDate,@PrimarySubject,@AdcodeActive,@AdcodeSwamp
        END
        ELSE IF @MailPiece LIKE 'Magazine%'
        BEGIN
            SELECT 'Staging.CreateSubjMailFile', @CatalogCode,@Mailpiece,@DropDate,@PrimarySubject,@MaxSubjRank,@AdcodeActive,@AdcodeSwamp
            EXEC Staging.CreateSubjMailFile @CatalogCode,@Mailpiece,@DropDate,@PrimarySubject,@MaxSubjRank,@AdcodeActive,@AdcodeSwamp
        END
        ELSE IF @MailPiece LIKE 'Magalog%'
        BEGIN
            IF @PrimarySubject = 'NC' 
               BEGIN
                SET @MailPiece = 'Catalogs' -- Changing mail piece to catalog to use RFM information from RFMForCatalogs table.
                SELECT 'Staging.CreateCatalogMailFile ', @CatalogCode,@CatalogName,@MailPiece,@DropDate,@PrimarySubject,@AdcodeActive,@AdcodeSwamp
                EXEC Staging.CreateCatalogMailFile @CatalogCode,@CatalogName,@MailPiece,@DropDate,@PrimarySubject,@AdcodeActive,@AdcodeSwamp
               END
            ELSE IF @CatalogName LIKE '%HS%' -- If it is High School magalog, call procedure CreateHSMailFile
               BEGIN
                SELECT 'Staging.CreateHSMailFile', @DropDate,@AdcodeActive,@AdcodeSwamp
                EXEC Staging.CreateHSMailFile @DropDate,@AdcodeActive,@AdcodeSwamp
               END
            ELSE IF @CatalogName LIKE '%Xmas%' -- If it is Holiday Yulalog/Xmas reminder then call CreateCatalogMailFile
               BEGIN
                SET @MailPiece = 'Catalogs' -- Changing mail piece to catalog to use RFM information from RFMForCatalogs table.
                SELECT 'Staging.CreateCatalogMailFile ', @CatalogCode,@CatalogName,@MailPiece,@DropDate,@PrimarySubject,@AdcodeActive,@AdcodeSwamp
                EXEC Staging.CreateCatalogMailFile @CatalogCode,@CatalogName,@MailPiece,@DropDate,@PrimarySubject,@AdcodeActive,@AdcodeSwamp
               END
            ELSE
               BEGIN
                SELECT 'Staging.CreateSubjMailFile', @CatalogCode,@Mailpiece,@DropDate,@PrimarySubject,@MaxSubjRank,@AdcodeActive,@AdcodeSwamp
                EXEC Staging.CreateSubjMailFile @CatalogCode,@Mailpiece,@DropDate,@PrimarySubject,@MaxSubjRank,@AdcodeActive,@AdcodeSwamp
               END
        END
        ELSE IF @MailPiece LIKE 'Newsletter%'
        BEGIN
            IF @CatalogName LIKE 'HouseHS%'
               BEGIN
                SELECT 'Staging.CreateHSMailFile', @DropDate,@AdcodeActive,@AdcodeSwamp
                EXEC Staging.CreateHSMailFile @DropDate,@AdcodeActive,@AdcodeSwamp
               END
            ELSE IF @CatalogName LIKE '%Xmas%' -- If it is Holiday Yulalog/Xmas reminder then call CreateCatalogMailFile
               BEGIN
                SET @MailPiece = 'Catalogs' -- Changing mail piece to catalog to use RFM information from RFMForCatalogs table.
                SELECT 'Staging.CreateCatalogMailFile ', @CatalogCode,@CatalogName,@MailPiece,@DropDate,@PrimarySubject,@AdcodeActive,@AdcodeSwamp
                EXEC Staging.CreateCatalogMailFile @CatalogCode,@CatalogName,@MailPiece,@DropDate,@PrimarySubject,@AdcodeActive,@AdcodeSwamp
               END
            ELSE
               BEGIN -- Econ Newsletter
                SELECT 'Staging.CreateSubjMailFile', @CatalogCode,@Mailpiece,@DropDate,@PrimarySubject,@MaxSubjRank,@AdcodeActive,@AdcodeSwamp
                EXEC Staging.CreateSubjMailFile @CatalogCode,@Mailpiece,@DropDate,@PrimarySubject,@MaxSubjRank,@AdcodeActive,@AdcodeSwamp
               END
        END

        ELSE IF @MailPiece LIKE 'Library%'
        BEGIN
            SELECT 'Staging.CreateLibraryMailFile', @DropDate, @AdcodeActive
            EXEC Staging.CreateLibraryMailFile @DropDate, @AdcodeActive
        END
        else if @MailPiece = 'JFYSimple' exec Staging.CreateJFYLettersSimple @AdcodeActive, @DropDate, @StopDate
        else if @MailPiece = 'JFYFormatSpecific' exec Staging.CreateJFYLettersFormatSpecific @AdcodeActive, @DropDate, @StopDate
        else if @MailPiece = 'JFYSubjectSpecific' exec Staging.CreateJFYLettersSubjectSpecific @AdcodeActive, @DropDate, @StopDate
	end    
    
    if object_id('RFM.dbo.' + @FnlTblName) is not null 
    begin
		set @SQLCommand = 'drop table RFM.dbo.' + @FnlTblName
		exec sp_executesql @SQLCommand
    end
    
    set @SQLCommand = 'select * into RFM.dbo.' + @FnlTblName + ' from Staging.TempMailPull (nolock)'
	exec sp_executesql @SQLCommand

	if object_id('Staging.TempMailPull') is not null
    drop table Staging.TempMailPull

end
GO
