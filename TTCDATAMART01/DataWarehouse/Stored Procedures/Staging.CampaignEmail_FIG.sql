SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROC [Staging].[CampaignEmail_FIG]
	@EmailCatalogCode INT,
	@EmailCatalogCodeSwamp INT = 8804,
	@EmailCatalogCodeInt INT = 8805,
-- 	@EmailCatalogCodeInquirer INT = 8806,
	@FlagIntnl VARCHAR(5) = 'YES',
	@Test VARCHAR(5) = 'YES',
	@DeBugCode INT = 1
AS
--- Proc Name: 	Ecampaigns.dbo.CampaignEmail_FIG
--- Purpose:	To generate Email List for Email Campaign
---		deadline reminder.
--- Special Tables Used: MarketingDM.dbo.CampnPageAllocation
---			MarketingDM.dbo.ValidSubjCat
---			Ecampaigns.dbo.Ecampn02RankDLR
---			Ecampaigns.dbo.FIGEcampn01Customer01DLR
---			Ecampaigns.dbo.Ecampn03Customer02_CourseDLR
---			Ecampaigns.dbo.Ecampn04Customer_FinalDLR
--- Updates:
--- Name		Date		Comments
--- Preethi Ramanujam 	11/13/2008	New

--- Declare variables
	DECLARE 
    	@ErrorMsg VARCHAR(400),   --- Error message for error handling.
		@MaxCourse INT
begin
    SET @MaxCourse = 25

    --- Check to make sure CatalogCodes are provided by the user.
    IF @DeBugCode = 1 PRINT 'Checking to make sure CatalogCodes are provided by the user'

    IF @EmailCatalogCode IS NULL
    BEGIN 
          -- Check if we can get the DL control version of catalogcode ****
          SET @ErrorMsg = 'Please provide CatalogCode for the Email Piece'
          RAISERROR(@ErrorMsg,15,1)
          RETURN
    END

    --- Check to make sure CatalogCodes Provided are correct.
    IF @DeBugCode = 1 PRINT 'Checking to make sure CatalogCodes Provided are correct'

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

    IF @EmailCatalogCodeSwamp <> 8804
       BEGIN
          SELECT @Count = COUNT(*)
          FROM Staging.MktCatalogCodes
          WHERE CatalogCode = @EmailCatalogCodeSwamp
          
          IF @Count = 0
          BEGIN 
                SET @ErrorMsg = 'CatalogCode ' + CONVERT(VARCHAR,@EmailCatalogCodeSwamp) + ' does not exist. Please Provide a valid Catalogcode for Email'
                RAISERROR(@ErrorMsg,15,1)
                RETURN
          END
       END

    IF @EmailCatalogCodeInt <> 8805
       BEGIN
          SELECT @Count = COUNT(*)
          FROM Staging.MktCatalogCodes
          WHERE CatalogCode = @EmailCatalogCodeInt
          
          IF @Count = 0
          BEGIN 
                SET @ErrorMsg = 'CatalogCode ' + CONVERT(VARCHAR,@EmailCatalogCodeInt) + ' does not exist. Please Provide a valid Catalogcode for Email'
                RAISERROR(@ErrorMsg,15,1)
                RETURN
          END
       END

    -- IF @EmailCatalogCodeInquirer <> 8806
    --    BEGIN
    --    SELECT @Count = COUNT(*)
    --    FROM SuperstarDW.dbo.MktCatalogCodes
    --    WHERE CatalogCode = @EmailCatalogCodeInquirer
    --    
    --    IF @Count = 0
    --    BEGIN 
    --          SET @ErrorMsg = 'CatalogCode ' + CONVERT(VARCHAR,@EmailCatalogCodeInquirer) + ' does not exist. Please Provide a valid Catalogcode for Email'
    --          RAISERROR(@ErrorMsg,15,1)
    --          RETURN
    --    END
    --    END


    --- STEP1: Derive catalog data from Mail and Email Catalog codes provided
    IF @DeBugCode = 1 PRINT 'STEP1: Derive data based on CatalogCodes'

    --- Derive Dropdate for the Email
    DECLARE @DropDate DATETIME
    DECLARE @DropDateSNI DATETIME

    IF @EMailCatalogCodeSwamp <> 8804
      BEGIN
          SELECT @DropDate = StartDate
          FROM Staging.MktCatalogCodes
          WHERE CatalogCode = @EMailCatalogCode

          SELECT @DropDateSNI = StartDate
          FROM Staging.MktCatalogCodes
          WHERE CatalogCode = @EMailCatalogCodeSwamp
      END
    ELSE
      BEGIN
          SELECT @DropDate = StartDate,
                @DropDateSNI = StartDate
          FROM Staging.MktCatalogCodes
          WHERE CatalogCode = @EMailCatalogCode
      END

    IF @DeBugCode = 1 
       BEGIN
          PRINT 'DropDate = ' + CONVERT(VARCHAR,@DropDate,101)
          PRINT 'DropDateSNI = ' + CONVERT(VARCHAR,@DropDateSNI,101)
       END

    --- Derive the campaign ID  
    DECLARE @ECampaignIDActive VARCHAR(30)
    DECLARE @ECampaignIDSwamp VARCHAR(30)
    -- DECLARE @ECampaignIDInq VARCHAR(30)

    SELECT @ECampaignIDActive = 'FIGAct' + CONVERT(VARCHAR,@DropDate,112)
    SELECT @ECampaignIDSwamp = 'FIGSNI' + CONVERT(VARCHAR,@DropDateSNI,112)
    -- SELECT @ECampaignIDInq = 'FIGInq' + CONVERT(VARCHAR,@DropDateSNI,112)

    IF @DeBugCode = 1 
       BEGIN
          PRINT 'CampaignID for Actives= ' + @ECampaignIDActive
          PRINT 'CampaignID for Swamp = ' + @ECampaignIDSwamp
    --    PRINT 'CampaignID for Inquriers = ' + @ECampaignIDInq
       END

    --- Derive  Final table name.
    DECLARE @FnlTable VARCHAR(100)

    SELECT @FnlTable = 'Email' + CONVERT(VARCHAR,@DropDate,112) + '_' + 'Offers_FIG'
    FROM Staging.MktCatalogCodes
    WHERE CatalogCode = @EmailCatalogCode

    IF @DeBugCode = 1 
    BEGIN
          PRINT 'Final Table Name = ' + @FnlTable
    END


    --- Get Adcodes for the Email

    DECLARE @AdcodeActive INT
    DECLARE @AdcodeSwamp INT
    DECLARE @AdcodeIntnl INT
    -- DECLARE @AdcodeInq INT


    SELECT @AdcodeActive = Adcode
    FROM Staging.MktAdcodes
    WHERE CatalogCode = @EmailCatalogCode
    AND UPPER(Name) LIKE '%ACTIVE CONTROL%'

    IF @AdcodeActive IS NULL
    BEGIN
          SET @AdcodeActive = 9999999
          SET @ErrorMsg = 'No Adcode was found for CatalogCode ' + CONVERT(VARCHAR,@EmailCatalogCode) + '. Using default adcode 99999 that needs to be udpated'
          RAISERROR(@ErrorMsg,15,1)
    END


          SELECT @AdcodeSwamp = Adcode
          FROM Staging.MktAdcodes
          WHERE CatalogCode IN (@EmailCatalogCode, @EmailCatalogCodeSwamp) 
          AND UPPER(Name) LIKE '%SWAMP CONTROL%'
          
          IF @AdcodeSwamp IS NULL
             BEGIN
                PRINT '****WARNING**** AdcodeSwamp was not found. So, adding one to the AdcodeActive'
                SET @AdcodeSwamp = 8888
             END
          
          SELECT @AdcodeIntnl =  Adcode
          FROM Staging.MktAdcodes
          WHERE CatalogCode IN (@EmailCatalogCode, @EmailCatalogCodeSwamp, @EmailCatalogCodeInt)
          AND UPPER(Name) LIKE '%INTERNATIONAL%'  -- CONTROL'
          
          IF @AdcodeIntnl IS NULL
             BEGIN
                PRINT '****WARNING**** AdcodeIntnl was not found. So, adding two to the AdcodeActive'                 SET @AdcodeIntnl = 7777
             END
          
    --    SELECT @AdcodeInq =  Adcode
    --    FROM SuperstarDW.dbo.MktAdcodes
    --    WHERE CatalogCode IN (@EmailCatalogCode, @EmailCatalogCodeSwamp, @EmailCatalogCodeInt, @EmailCatalogCodeInquirer)
    --    AND UPPER(Name) LIKE '%Inquirer%'  -- CONTROL'
    --    
    --    IF @AdcodeInq IS NULL
    --       BEGIN
    --          PRINT '****WARNING**** AdcodeInq was not found. So, adding two to the AdcodeActive'                 
    --          SET @AdcodeInq = 5555
    --       END
          

    IF @DeBugCode = 1 
    BEGIN
          PRINT 'AdcodeActive = ' +  CONVERT(VARCHAR,@AdcodeActive) 
          PRINT 'AdcodeSwamp = ' + CONVERT(VARCHAR,@AdcodeSwamp) 
          PRINT 'AdcodeIntnl = ' + CONVERT(VARCHAR,@AdcodeIntnl)
    --    PRINT 'AdcodeInq = ' + CONVERT(VARCHAR,@AdcodeInq) 
    END


    --- Generate Subject line for the email.

    DECLARE @SubjLine VARCHAR(400) -- Default SubjectLine

    set @SubjLine = 'A Gift for You from The Teaching Company'

    IF @DeBugCode = 1 
       BEGIN
          PRINT 'SubjectLine = ' +  @SubjLine
       END

    --- Check to make sure FIG Master table is populated.
    DECLARE @Counts INT

    SELECT @Counts = COUNT(*)
    FROM Mapping.FIG01FIGMASTER

    IF @Counts < 1
    BEGIN
          SET @ErrorMsg = 'No rows found in table ecampaigns.dbo.FIG01FIGMASTER.'
          RAISERROR(@ErrorMsg,15,1)
          RETURN
    END
    --- STEP 3: Get the list of Emailable customers from the CustomerSignature Table
    IF @DeBugCode = 1 PRINT 'Begin STEP 3: Get the list of Emailable customers that should receive Favorite Subject Email.'
    
  	if object_id('Staging.FIGEcampn01Customer01') is not null drop table Staging.FIGEcampn01Customer01    
  	if object_id('Staging.FIGEcampn02InterimOffer') is not null drop table Staging.FIGEcampn02InterimOffer        
  	if object_id('Staging.FIGEcampn03MinRankAndFIGID') is not null drop table Staging.FIGEcampn03MinRankAndFIGID            
    
    SELECT ccs.Customerid,
          ccs.FirstName,
          ccs.LastName,
          ccs.EmailAddress,
          ccs.ComboID,
          CASE WHEN ccs.CustomerSegment = 'Active' THEN @AdcodeActive
               ELSE @AdcodeSwamp
          END AS AdCode,
          ccs.State AS Region,
          ccs.CountryCode,
          @SubjLine  AS SubjectLine,
          ccs.PreferredCategory2 as PreferredCategory,
          CASE WHEN ccs.customerSegment = 'Active' THEN @ECampaignIDActive
               ELSE @ECampaignIDSwamp
          END AS ECampaignID,
          FlagBIL=0, FlagBAC1=0, FlagBAC2=0, OfferType='NA', FlagFIGSent=0,
            FlagCandidateCourseID = 0, 
          convert(float, 10000.0001) Rank,
          ISNULL(B.DSLPurchase, 0) AS DSLPurchase
    INTO Staging.FIGEcampn01Customer01
    FROM Marketing.CampaignCustomerSignature ccs left outer join
          Marketing.CustomerDynamicCourseRank B on ccs.customerid = B.Customerid
    WHERE ccs.FlagEmail = 1 AND EmailAddress LIKE '%@%' AND ccs.buyertype > 1
    AND ccs.PublicLibrary = 0 and ccs.CountryCode not in ('GB','AU')

--    CREATE  CLUSTERED INDEX IDX_customer_FIGEcamp01Cust01
--    ON Ecampaigns.dbo.FIGEcampn01Customer01 (Customerid)

    --- Update AdCode for International customers

    IF @DeBugCode = 1 PRINT 'Update AdCode for International customers'

    UPDATE EC01
    SET Adcode = @AdcodeIntnl
    FROM Staging.FIGEcampn01Customer01 EC01 JOIN
          Marketing.CampaignCustomerSignature CCS ON CCS.CustomerID = EC01.CustomerID
    WHERE CCS.CountryCode NOT LIKE '%US%'
    AND CCS.CountryCode IS NOT NULL
    AND CCS.CountryCode <> ''

    --- Delete Customers with duplicate EmailAddress
    IF @DeBugCode = 1 PRINT 'Delete Customers with duplicate EmailAddress'

    DECLARE @RowCount INT
    SET @RowCount =1

    WHILE @RowCount > 0
    BEGIN
    DELETE FROM Staging.FIGEcampn01Customer01 
    WHERE CustomerID IN (
                SELECT MIN(Customerid)
                FROM Staging.FIGEcampn01Customer01 
                WHERE EmailAddress IN
                            (SELECT EmailAddress
                            FROM Staging.FIGEcampn01Customer01
                            GROUP BY EmailAddress
                            HAVING COUNT(Customerid) > 1)
                GROUP BY EmailAddress)
    SET @RowCount = @@ROWCOUNT
    SELECT @RowCount
    END

    -- -- Delete customers if they are in FIG_RemoveCustomers table
    -- DELETE A
    -- FROM Ecampaigns.dbo.FIGEcampn01Customer01 A JOIN
    --    Ecampaigns.dbo.FIG_RemoveCustomers B on A.CustomerID = B.CustomerID
    -- 
    -- DELETE A
    -- FROM Ecampaigns.dbo.FIGEcampn01Customer01 A JOIN
    --    Ecampaigns.dbo.FIG_RemoveCustomers B on A.EmailAddress = B.EmailAddress


    -- Update Inquirer adcode
    -- 
    -- IF @DeBugCode = 1 PRINT 'Update AdCode for Inquirers'
    -- 
    -- UPDATE Ecampaigns.dbo.FIGEcampn01Customer01
    -- SET Adcode = @AdcodeInq
    -- WHERE ComboID like '%Inq%'

/*
    -- UPDATE PREFERREDCATEGORY TO SS
    UPDATE F
    SET preferredcategory = 'SS'
    FROM Staging.FIGEcampn01Customer01 F JOIN
         SUPERSTARDW..CCUpsellCustomer C
        ON F.CustomerID = C.CustomerID AND C.SubjectPreferenceID LIKE 'BIO%'
*/

    -- Create Interim Offer table.
    PRINT 'CREATE INTERIMOFFER TABLE'

    SELECT CE.*, FM.FIGID, FM.FromCourseID, FM.DateFirstRun, FM.Course1ASC, FM.Course2ASC, 
          FM.SubjectAssociation_Original, FM.SUBJECTASSOCIATION_MODIFIED,
          FM.DSLCourseRelease, FM.CourseParts as Parts, FM.FIGSource, 
          FM.FIGTitle, FM.Notes
    INTO Staging.FIGEcampn02InterimOffer
    FROM Staging.FIGEcampn01Customer01 CE,
         (SELECT FM.*, DATEDIFF(DD, DC.PublishDate, GETDATE()) DSLCourseRelease, DC.CourseParts
          FROM Mapping.FIG01FIGMASTER FM JOIN
                Staging.MktCourse DC ON FM.FromCourseID = DC.CourseID
          UNION
          SELECT FM.*, DATEDIFF(DD, DC.PublishDate, GETDATE()) DSLCourseRelease, DC.CourseParts
          FROM Mapping.FIG01FIGMASTER FM JOIN
                Staging.MktCourse DC ON FM.Course1Asc = DC.CourseID AND FromCourseID = -1) FM 
    WHERE FM.FIGSource LIKE 'TTC%' AND FM.FlagUseORNot = 'YES'

/*
    CREATE CLUSTERED INDEX IX_FIGEcampn02InterimOffer1 ON Ecampaigns..FIGEcampn02InterimOffer (Customerid, FigID)
    CREATE INDEX IX_FIGEcampn02InterimOffer2 ON Ecampaigns..FIGEcampn02InterimOffer (FROMCOURSEID)
    CREATE INDEX IX_FIGEcampn02InterimOffer3 ON Ecampaigns..FIGEcampn02InterimOffer (COURSE1ASC)
    CREATE INDEX IX_FIGEcampn02InterimOffer4 ON Ecampaigns..FIGEcampn02InterimOffer (COURSE2ASC)
    CREATE INDEX IX_FIGEcampn02InterimOffer5 ON Ecampaigns..FIGEcampn02InterimOffer (FLAGCANDIDATECOURSEID)
*/

    -- Drop Figs from Customer list if they have already received them.
    DELETE FIO
    FROM Staging.FIGEcampn02InterimOffer FIO JOIN
          Archive.FIG00FIGHistory_FIGID FH ON FIO.CustomerID = FH.CustomerID AND FIO.FIGID = FH.FIGID


    --Update FirstBranch FLAGBIL (FLAG BOUGHT WITHIN FIGMASTER LIST), PURCHASED COURSES FROM THE FIGMASTER LIST
    PRINT 'UPDATE FIRSTBRANCH FLAGBIL (FLAG BOUGHT WITHIN FIGMASTER LIST), PURCHASED COURSES FROM THE FIGMASTER LIST'

    UPDATE FIO
    SET FLAGBIL = 1
    FROM Staging.FIGEcampn02InterimOffer FIO JOIN
                Marketing.CompleteCoursePurchase CCP ON FIO.CustomerID = CCP.CustomerID 
                                                                AND FIO.FromCourseID = CCP.CourseID
     
    UPDATE FIO
    SET FLAGBIL = 1
    FROM Staging.FIGEcampn02InterimOffer FIO JOIN
                Marketing.COMPLETECOURSEPURCHASE CCP ON FIO.CustomerID = CCP.CustomerID 
                                                                AND FIO.FromCourseID = CCP.BundleID
     
    -- UPDATE SECONDBRANCH FLAGBAC1 (FLAG BOUGHT ASSOCIATED COURSE 1)
    PRINT 'UPDATE SECONDBRANCH FLAGBAC1 (FLAG BOUGHT ASSOCIATED COURSE 1)'

    UPDATE FIO
    SET FLAGBAC1 = 1
    FROM   Staging.FIGEcampn02InterimOffer FIO JOIN
                Marketing.CompleteCoursePurchase CCP ON FIO.CustomerID = CCP.CustomerID 
                                                                AND FIO.COURSE1ASC = CCP.CourseID
     

    UPDATE FIO
    SET FLAGBAC1 = 1
    FROM   Staging.FIGEcampn02InterimOffer FIO JOIN
                Marketing.CompleteCoursePurchase CCP ON FIO.CustomerID = CCP.CustomerID 
                                                                AND  FIO.COURSE1ASC = CCP.BundleID
     

    -- UPDATE SECONDBRANCH FLAGBAC2 (FLAG BOUGHT ASSOCIATED COURSE 2)
    PRINT 'UPDATE SECONDBRANCH FLAGBAC2 (FLAG BOUGHT ASSOCIATED COURSE 2)'

    UPDATE FIO
    SET FLAGBAC2 = 1
    FROM   Staging.FIGEcampn02InterimOffer FIO JOIN
                Marketing.CompleteCoursePurchase CCP ON FIO.CustomerID = CCP.CustomerID 
                                                                AND  FIO.COURSE2ASC = CCP.CourseID
     

    UPDATE FIO
    SET FLAGBAC2 = 1
    FROM   Staging.FIGEcampn02InterimOffer FIO JOIN
                Marketing.CompleteCoursePurchase CCP ON FIO.CustomerID = CCP.CustomerID 
                                                                AND FIO.COURSE2ASC = CCP.BundleID
     

    -- UPDATE FIO WITH RANK; CONVERT DATA TYPE OF RANK TO FLOAT FROM NUMERIC 5.
    PRINT 'UPDATE FIO WITH RANK; CONVERT DATA TYPE OF RANK TO FLOAT FROM NUMERIC 5.'

    UPDATE FIO
    SET FLAGCANDIDATECOURSEID = 
              CASE WHEN FLAGBAC1 = 1 THEN FROMCOURSEID
                   WHEN FLAGBAC2 = 1 THEN FROMCOURSEID
                   WHEN FLAGBIL = 1 AND FROMCOURSEID = -1 THEN FROMCOURSEID
                   WHEN PREFERREDCATEGORY = SUBJECTASSOCIATION_MODIFIED THEN FROMCOURSEID 
                 ELSE 0
              END,
        RANK = 
            CASE WHEN FLAGBAC1 = 1 THEN (1.0000/PARTS)
                 WHEN FLAGBAC2 = 1 THEN (2.0000/PARTS)
                 WHEN FLAGBIL  = 1 THEN (3.0000/PARTS)
                 WHEN PREFERREDCATEGORY = SUBJECTASSOCIATION_MODIFIED 
                      THEN (convert(float,DSLPURCHASE) + convert(float,DSLCOURSERELEASE))*330.0000/(PARTS) 
               ELSE  10000000.0 
          END
    FROM Staging.FIGEcampn02InterimOffer FIO

    -- Drop rows if they are not candiates for the FIG
    DELETE FROM Staging.FIGEcampn02InterimOffer
    WHERE FlagCandidateCourseID = 0
     

    -- MAKE TABLE WITH MINRANK AND FIGID

    PRINT 'MAKE TABLE WITH MINRANK AND FIGID'

--    DROP TABLE Ecampaigns..FIGEcampn03MinRankAndFIGID

    SELECT FIO.CustomerID, FR.MINRANK, FIO.FIGID, FIO.FROMCOURSEID, FM.FIGSOURCE, 
          FM.FIGTITLE, FM.NOTES, FM.COURSE1ASC, FM.COURSE2ASC
    INTO Staging.FIGEcampn03MinRankAndFIGID
    FROM   Staging.FIGEcampn02InterimOffer FIO JOIN
          (SELECT CustomerID, MIN(RANK) MINRANK
          FROM Staging.FIGEcampn02InterimOffer FIO 
          WHERE FLAGBIL = 0 AND FLAGFIGSENT = 0  /*ADDED FLAGFIGSENT = 0 ON 2/28/07'*/
          GROUP BY CustomerID)FR 
         ON FIO.RANK = FR.MINRANK AND FR.CustomerID = FIO.CustomerID AND FR.MINRANK <> 10000000.0000 JOIN
                Mapping.FIG01FIGMASTER FM
         ON FIO.FIGID = FM.FIGID
    GROUP BY FIO.CustomerID, FR.MINRANK, FIO.FIGID, FIO.FROMCOURSEID, FM.FIGSOURCE, FM.FIGTITLE, FM.NOTES, FM.COURSE1ASC, FM.COURSE2ASC


    -- DELETE MORE THAN ONE MINFIG BECAUSE OF DUPLICATE MINRANK. THIS NEEDS TO BE FIXED IN FUTURE TO SELECT ONE FIGID
    PRINT 'DELETE MORE THAN ONE MINFIG BECAUSE OF DUPLICATE MINRANK. THIS NEEDS TO BE FIXED IN FUTURE TO SELECT ONE FIGID'

    DELETE F
    FROM Staging.FIGEcampn03MinRankAndFIGID F JOIN
                (SELECT CustomerID, COUNT(FIGID)CNT
                FROM Staging.FIGEcampn03MinRankAndFIGID
                GROUP BY CustomerID) DUPF
         ON F.CustomerID = DUPF.CustomerID AND DUPF.CNT >1


    -- PRINT 'UPDATE DAYS SINCE COURSE RELEASE FROM TODAY AND COURSE PARTS OF FROMCOURSEID'
    -- 
    -- UPDATE FIO
    -- SET DSLCOURSERELEASE = DATEDIFF(DD, DC.RELEASEDATE, GETDATE()),
    --     FIO.PARTS = DC.COURSEPARTS
    -- FROM   Ecampaigns..FIGEcampn02InterimOffer FIO JOIN
    --             MARKETINGDM..DMCOURSE DC ON FIO.FROMCOURSEID = DC.COURSEID
     

    -- -- UPDATE COURSE PARTS FOR WILSON QUARTERLY ARTILCES (OR TTC ARTICLES )AND HENCE NO FROMCOURSEID BUT BASED ON COURSEID OF ASSOCIATED COURSE1
    -- PRINT 'UPDATE COURSE PARTS FOR WILSON QUARTERLY ARTILCES (OR TTC ARTICLES )AND HENCE NO FROMCOURSEID BUT BASED ON COURSEID OF ASSOCIATED COURSE1'
    -- 
    -- UPDATE FIO
    -- SET    FIO.PARTS = DC.COURSEPARTS
    -- FROM   Ecampaigns..FIGEcampn02InterimOffer FIO JOIN
    --             MARKETINGDM..DMCOURSE DC ON FIO.COURSE1ASC = DC.COURSEID AND FROMCOURSEID = -1
    -- 
    -- 
    -- SELECT FM.*, DATEDIFF(DD, DC.PublishDate, GETDATE()) DSLCourseRelease, DC.CourseParts
    -- FROM Ecampaigns.dbo.FIG01FIGMASTER FM JOIN
    --    Superstardw.dbo.MktCourse DC ON FM.FromCourseID = DC.CourseID
    -- UNION
    -- SELECT FM.*, DATEDIFF(DD, DC.PublishDate, GETDATE()) DSLCourseRelease, DC.CourseParts
    -- FROM Ecampaigns.dbo.FIG01FIGMASTER FM JOIN
    --    Superstardw.dbo.MktCourse DC ON FM.Course1Asc = DC.CourseID AND FromCourseID = -1



    --- Create Final table
    IF @DeBugCode = 1 PRINT 'Create Final Table'

    DECLARE @Qry VARCHAR(8000)

    --- Drop if @FnlTabl already exists
    DECLARE @RowCounts INT
    SELECT @RowCounts = COUNT(*) FROM sysobjects
    WHERE Name = @FnlTable
    SELECT '@RowCounts = ' + CONVERT(VARCHAR,@RowCounts)

    IF @RowCounts > 0
    BEGIN
          SET @Qry = 'DROP TABLE Ecampaigns.dbo.' + @FnlTable
          SELECT @Qry
          EXEC (@Qry)
    END


    SET @Qry = 'SELECT *
              INTO ' + @FnlTable +
             ' FROM Staging.FIGEcampn03MinRankAndFIGID'

    EXEC (@Qry)



    --- Create Index on @FnlTable
    DECLARE @FnlIndex VARCHAR(50)

    SET @FnlIndex = 'IDX_' + REPLACE(@FnlTable,'rfm.dbo.','')

    SELECT 'Create Index'
    SET @Qry = 'CREATE CLUSTERED INDEX ' + @FnlIndex + ' ON ' + @FnlTable + '(CustomerID)'
    EXEC (@Qry)


    IF @DeBugCode = 1 PRINT 'END Ecampaigns.dbo.CampaignEmail_FIG'
end
GO
