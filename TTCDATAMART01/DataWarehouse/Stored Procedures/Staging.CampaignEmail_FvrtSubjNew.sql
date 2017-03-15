SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [Staging].[CampaignEmail_FvrtSubjNew]
	@EmailCatalogCode INT,
	@EmailCatalogCodeSwamp INT = 8804,
	@EmailCatalogCodeInt INT = 8805,
	@EmailCatalogCodeInquirer INT = 8806,
	@EmailCatalogCodeCanada INT = 13631,
	@FlagIntnl VARCHAR(3) = 'YES',
	@Test VARCHAR(5) = 'YES',
	@DeBugCode INT = 1
AS
-- Ecampn02Rank
/*- Proc Name: 	Staging.CampaignEmail_FvrtSubj*/
/*- Purpose:	To generate Email List for Email Campaign*/
/*-		deadline reminder.*/
/*-		Prior to running the procedure, Price matrix should be*/
/*-		set up for the catalogcode and migrated to Datamart.*/
/*- Updates:*/
/*- Name		Date		Comments*/
/*- Preethi Ramanujam 	7/6/2007	New*/
/*- Preethi Ramanujam	9/21/2007	Added ECampaignID column for WebTrend Analysis Project*/
/*- Preethi Ramanujam	1/3/2008	Added separate Catalog code for Swampers*/

	DECLARE 
    	@ErrorMsg VARCHAR(400),   /*- Error message for error handling.*/
        @Count INT,
		@AdcodeActive INT,
    	@AdcodeSwamp INT,
    	@AdcodeIntnl INT,
    	@AdcodeNoSubjPref INT,
    	@AdcodeInq INT,
    	@AdcodeWebInq INT,
    	@AdcodeNonRecip INT,
    	@AdcodeCanada INT
begin
	set nocount on

    /*- Check to make sure CatalogCodes are provided by the user.*/
    IF @DeBugCode = 1 PRINT 'Checking to make sure CatalogCodes are provided by the user'


    IF @EmailCatalogCode IS NULL
    BEGIN	
        /* Check if we can get the DL control version of catalogcode *****/
        SET @ErrorMsg = 'Please provide CatalogCode for the Email Piece'
        RAISERROR(@ErrorMsg,15,1)
        RETURN
    END

    /*- Check to make sure CatalogCodes Provided are correct.*/
    IF @DeBugCode = 1 PRINT 'Checking to make sure CatalogCodes Provided are correct'

    SELECT @Count = COUNT(*)
    FROM Staging.MktCatalogCodes (nolock)
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
        FROM Staging.MktCatalogCodes (nolock)
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
        FROM Staging.MktCatalogCodes (nolock)
        WHERE CatalogCode = @EmailCatalogCodeInt
    	
        IF @Count = 0
        BEGIN	
            SET @ErrorMsg = 'CatalogCode ' + CONVERT(VARCHAR,@EmailCatalogCodeInt) + ' does not exist. Please Provide a valid Catalogcode for Email'
            RAISERROR(@ErrorMsg,15,1)
            RETURN
        END
       END

    IF @EmailCatalogCodeInquirer <> 8806
       BEGIN
        SELECT @Count = COUNT(*)
        FROM Staging.MktCatalogCodes
        WHERE CatalogCode = @EmailCatalogCodeInquirer
    	
        IF @Count = 0
        BEGIN	
            SET @ErrorMsg = 'CatalogCode ' + CONVERT(VARCHAR,@EmailCatalogCodeInquirer) + ' does not exist. Please Provide a valid Catalogcode for Email'
            RAISERROR(@ErrorMsg,15,1)
            RETURN
        END
       END

    IF @EmailCatalogCodeCanada <> 13631
       BEGIN
        SELECT @Count = COUNT(*)
        FROM Staging.MktCatalogCodes
        WHERE CatalogCode = @EmailCatalogCodeCanada
    	
        IF @Count = 0
        BEGIN	
            SET @ErrorMsg = 'CatalogCode ' + CONVERT(VARCHAR,@EmailCatalogCodeCanada) + ' does not exist. Please Provide a valid Catalogcode for Email'
            RAISERROR(@ErrorMsg,15,1)
            RETURN
        END
       END

    /*- STEP1: Derive catalog data from Mail and Email Catalog codes provided*/
    IF @DeBugCode = 1 PRINT 'STEP1: Derive data based on CatalogCodes'

    /*- Derive Dropdate for the Email*/
    DECLARE @DropDate DATETIME

        SELECT @DropDate = StartDate
        FROM Staging.MktCatalogCodes
        WHERE CatalogCode = @EMailCatalogCode

    IF @DeBugCode = 1 
       BEGIN
        PRINT 'DropDate = ' + CONVERT(VARCHAR,@DropDate,101)
       END

    /*- Derive the campaign ID  -- PR 9/21/2007*/
    DECLARE @ECampaignIDActive VARCHAR(30)
    DECLARE @ECampaignIDSwamp VARCHAR(30)
    DECLARE @ECampaignIDInq VARCHAR(30)
    DECLARE @ECampaignIDWebInq VARCHAR(30)

    SELECT @ECampaignIDActive = 'FSAct' + CONVERT(VARCHAR,@DropDate,112)
    SELECT @ECampaignIDSwamp = 'FSSNI' + CONVERT(VARCHAR,@DropDate,112)
    SELECT @ECampaignIDInq = 'FSInq' + CONVERT(VARCHAR,@DropDate,112)
    SELECT @ECampaignIDWebInq = 'FSWebInq' + CONVERT(VARCHAR,@DropDate,112)

    IF @DeBugCode = 1 
       BEGIN
        PRINT 'CampaignID for Actives= ' + @ECampaignIDActive
        PRINT 'CampaignID for Swamp = ' + @ECampaignIDSwamp
        PRINT 'CampaignID for Inquriers = ' + @ECampaignIDInq
        PRINT 'CampaignID for WebInq = ' + @ECampaignIDWebInq
       END

    /*- Derive  Final table name.*/
    DECLARE @FnlTable VARCHAR(100)
    DECLARE @FnlTableSNI1 VARCHAR(100)

    SELECT @FnlTable = 'Email' + CONVERT(VARCHAR,@DropDate,112) + '_' + 'Offers_FvrtSbjct'
    FROM Staging.MktCatalogCodes
    WHERE CatalogCode = @EmailCatalogCode

    SELECT @FnlTableSNI1 = 'Email' + CONVERT(VARCHAR,@DropDate,112) + '_' + 'Offers_FvrtSbjct'
    FROM Staging.MktCatalogCodes
    WHERE CatalogCode = @EmailCatalogCode

    DECLARE @FnlTableActive VARCHAR(100)
    DECLARE @FnlTableSNI VARCHAR(100)

    SELECT @FnlTableActive = 'Ecampaigns.dbo.' + @FnlTable + '_Active'
    SELECT @FnlTableSNI = 'Ecampaigns.dbo.' + @FnlTableSNI1 + '_SNI'

    IF @DeBugCode = 1 
    BEGIN
        PRINT 'Final Table Name = ' + @FnlTable
        PRINT 'Final Active Table Name = ' + @FnlTableActive
        PRINT 'Final SNI Table Name = ' + @FnlTableSNI
    END

    /*- Get Adcodes for the Email*/

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
        AND UPPER(Name) LIKE '%INTERNATIONAL%'  /* CONTROL'*/
    	
        IF @AdcodeIntnl IS NULL
           BEGIN
            PRINT '****WARNING**** AdcodeIntnl was not found. So, adding two to the AdcodeActive'			SET @AdcodeIntnl = 7777
           END
    	
        SELECT @AdcodeCanada =  Adcode
        FROM Staging.MktAdcodes
        WHERE CatalogCode IN (@EmailCatalogCodeCanada)
        AND UPPER(Name) LIKE '%canada%' /*CONTROL'*/
    	
        IF @AdcodeCanada IS NULL
           BEGIN
            PRINT '****WARNING**** AdcodeCanada was not found. So, using dummy Canada Adcode'
            SET @AdcodeCanada = 44279 
           END
    	   
        SELECT @AdcodeNoSubjPref =  Adcode
        FROM Staging.MktAdcodes
        WHERE CatalogCode IN (@EmailCatalogCode, @EmailCatalogCodeSwamp, @EmailCatalogCodeInt)
        AND UPPER(Name) LIKE '%NO SUBJ PREF%' /*CONTROL'*/
    	
        IF @AdcodeNoSubjPref IS NULL
           BEGIN
            PRINT '****WARNING**** AdcodeNoSubjPref was not found. So, adding three to the AdcodeActive'
            SET @AdcodeNoSubjPref = 6666
           END

        SELECT @AdcodeInq =  Adcode
        FROM Staging.MktAdcodes
        WHERE CatalogCode IN (@EmailCatalogCode, @EmailCatalogCodeSwamp, @EmailCatalogCodeInt, @EmailCatalogCodeInquirer)
        AND UPPER(Name) LIKE '%Inquirer%'  /* CONTROL'*/
    	
        IF @AdcodeInq IS NULL
           BEGIN
            PRINT '****WARNING**** Inquirer was not found. So, adding two to the AdcodeActive'			
            SET @AdcodeInq = 5555
           END
    	
        SELECT @AdcodeWebInq =  Adcode
        FROM Staging.MktAdcodes
        WHERE CatalogCode IN (@EmailCatalogCode, @EmailCatalogCodeSwamp, @EmailCatalogCodeInt, @EmailCatalogCodeInquirer)
        AND UPPER(Name) LIKE '%WebInq%' /*CONTROL'*/
    	
        IF @AdcodeWebInq IS NULL
           BEGIN
            PRINT '****WARNING**** AdcodeWebInq was not found. So, adding three to the AdcodeActive'
            SET @AdcodeWebInq = 4444

           END


    IF @DeBugCode = 1 
    BEGIN
        PRINT 'AdcodeActive = ' +  CONVERT(VARCHAR,@AdcodeActive) 
        PRINT 'AdcodeSwamp = ' + CONVERT(VARCHAR,@AdcodeSwamp) 
        PRINT 'AdcodeIntnl = ' + CONVERT(VARCHAR,@AdcodeIntnl)
        /*PRINT 'AdcodeNoSubjPref = ' + CONVERT(VARCHAR,@AdcodeNoSubjPref)*/
        PRINT 'AdcodeInq = ' + CONVERT(VARCHAR,@AdcodeInq) 
        /*PRINT 'AdcodeWebInq = ' + CONVERT(VARCHAR,@AdcodeWebInq)*/
        PRINT 'AdcodeCanada = ' + CONVERT(VARCHAR,@AdcodeCanada)

    END

    /*- Generate Subject line for the email.*/

    DECLARE @SubjLine VARCHAR(400) /* Default SubjectLine*/
    DECLARE @StopDate DATETIME

    SELECT @StopDate = StopDate
    FROM Staging.MktCatalogCodes
    WHERE CatalogCode = @EMailCatalogCode

    SELECT @SubjLine = 'A Special Offer on Your Favorite Subjects'

    DECLARE @SubjectLineActive VARCHAR(200)
    SET @SubjectLineActive = @SubjLine
    DECLARE @SubjectLineSwamp VARCHAR(200)
    SET @SubjectLineSwamp = @SubjLine
    DECLARE @SubjectLineIntnl VARCHAR(200)
    SET @SubjectLineIntnl = @SubjLine

    IF @DeBugCode = 1 
    BEGIN
        PRINT 'SubjectLineActive = ' +  @SubjectLineActive
        PRINT 'SubjectLineSwamp = ' + @SubjectLineSwamp
        PRINT 'SubjectLineIntnl = ' + @SubjectLineIntnl
    END

    /*- STEP2: Obtain Sales of courses offered in the catalog by PreferredCategory */
    /*- 	   of the customer FROM customersubjectmatrix table and assign Ranks based on sales*/

    /*- Generate the list of courses and saleprices by PreferredCategory*/
    IF @DeBugCode = 1 PRINT 'STEP2 BEGIN'
    IF @DeBugCode = 1 PRINT 'Generate Ranks Table'

        if object_id('Staging.Ecampn02Rank') is not null drop table Staging.Ecampn02Rank

    SELECT Sum(FNL.SumSales) AS SumSales,
        FNL.CourseID,
        FNL.PreferredCategory,
		CONVERT(FLOAT,0) AS Rank
    INTO Staging.Ecampn02Rank
    FROM	(SELECT sum(OI.SalesPrice) AS SumSales,
                II.Courseid AS CourseID,
                'GEN' AS PreferredCategory
        FROM  Marketing.DMPurchaseOrders O JOIN
            Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
            Staging.InvItem II ON OI.StockItemID = II.StockItemID 
            JOIN Staging.MktPricingMatrix MPM ON MPM.UserStockItemID = II.StockItemID	
        WHERE O.DATEORDERED BETWEEN DATEADD(Month,-6,GETDATE()) AND GETDATE()
        AND O.SequenceNum > 1
        AND MPM.CatalogCode = @EmailCatalogCode
        GROUP BY  II.Courseid
        UNION
        SELECT sum(OI.SalesPrice) AS SumSales,
            II.Courseid AS CourseID,
            ISNULL(CSM.PreferredCategory2,'GEN') AS PreferredCategory
        FROM 
            Marketing.CampaignCustomerSignature CSM JOIN
                   Marketing.DMPurchaseOrders O  ON CSM.CUSTOMERID = O.CUSTOMERID JOIN
                   Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
            Staging.InvItem II ON OI.StockItemID = II.StockItemID 
            JOIN Staging.MktPricingMatrix MPM ON MPM.UserStockItemID = II.StockItemID
        WHERE O.DATEORDERED BETWEEN DATEADD(Month,-6,GETDATE()) AND GETDATE()
        AND O.SequenceNum > 1
        AND MPM.CatalogCode = @EmailCatalogCode
--        AND CSM.PreferredCategory2 is not null
        GROUP BY CSM.PREFERREDCATEGORY2, II.Courseid)FNL
    GROUP BY FNL.CourseID,FNL.PreferredCategory
    -- ORDER BY FNL.PreferredCategory,Sum(FNL.SumSales) DESC
    
	/*- Assign ranking based on Sales*/
    IF @DeBugCode = 1 PRINT 'Assign Ranking Based on sales'

    DECLARE @CourseID INT
    DECLARE @SumSales MONEY
    DECLARE @PrefCat VARCHAR(5)
    /*- Declare First Cursor for PreferredCategory */
    DECLARE MyCursor CURSOR
    FOR
    SELECT  DISTINCT PreferredCategory 
    FROM Staging.Ecampn02Rank
    ORDER BY PreferredCategory DESC

    /*- Begin First Cursor for PreferredCategory 			*/
    OPEN MyCursor
    FETCH NEXT FROM MyCursor INTO @PrefCat

    SELECT @PrefCat
    	
    WHILE @@FETCH_STATUS = 0
        BEGIN
            /*- Declare Second Cursor for courses within the PreferredCategory*/
            DECLARE MyCursor2 CURSOR
            FOR
            SELECT CourseID, SumSales 
            FROM Staging.Ecampn02Rank
            WHERE PreferredCategory = @PrefCat
            ORDER BY SumSales DESC
    		
            /*- BEGIN Second Cursor for courses within the PreferredCategory*/
            OPEN MyCursor2
            FETCH NEXT FROM MyCursor2 INTO @CourseID,@SumSales

            DECLARE @Rank FLOAT
            SET @Rank = CONVERT(FLOAT,1) 

            WHILE @@FETCH_STATUS = 0
            BEGIN
            /*- Assign rank based on sales for the course id within the PreferredCategory*/
                UPDATE Staging.Ecampn02Rank
                SET Rank = @Rank
                WHERE PreferredCategory = @PrefCat
                AND CourseID = @CourseID 
                AND SumSales = @SumSales

                SET @Rank = @Rank + CONVERT(FLOAT,1)
    			
                FETCH NEXT FROM MyCursor2 INTO @CourseID,@SumSales
            END
            CLOSE MyCursor2
            DEALLOCATE MyCursor2
            /*- END Second Cursor for courses within the PreferredCategory*/


            /*- Get the total number of courses for the given Catalog code.*/
            DECLARE @CourseCount INT

            SELECT @CourseCount = COUNT(DISTINCT II.CourseID)
            FROM Staging.MktPricingMatrix MPM JOIN
                Staging.InvItem II ON MPM.UserStockItemID = II.StockItemID
            WHERE MPM.CatalogCode = @EmailCatalogCode

            /*FROM Staging.Ecampn01CourseList*/

            /*- If there is no data available for courses under a particular*/
            /*- preferred category, append courses FROM 'GEN' category.*/

 --NB
            IF @CourseCount >= @Rank  /*- If there are more courses that do not have ranks assigned yet..*/
            BEGIN
                IF @DeBugCode = 1 PRINT 'Inside IF statement - ' + CONVERT(VARCHAR,@Rank) + CONVERT(VARCHAR,@Coursecount)

                DECLARE @CourseID3 INT
                DECLARE @SumSales3 MONEY
                /*- DECLARE Third Cursor for courses within the General Category*/
                DECLARE MyCursor3 CURSOR
                FOR
                SELECT DISTINCT CourseID,SumSales
                FROM Staging.Ecampn02Rank
                WHERE PreferredCategory = 'GEN'
                AND CourseID NOT IN (SELECT CourseID 
                               FROM Staging.Ecampn02Rank
                               WHERE PreferredCategory = @PrefCat)
                ORDER BY SumSales DESC
                /*- Begin Third Cursor for courses within the General Category*/
                OPEN MyCursor3
                FETCH NEXT FROM MyCursor3 INTO @CourseID3,@SumSales3

                WHILE @@FETCH_STATUS = 0
                BEGIN
                    SELECT @SumSales3,@CourseID3,@PrefCat,@Rank
                    INSERT INTO Staging.Ecampn02Rank
                    SELECT @SumSales3,@CourseID3,@PrefCat,@Rank
    	
                    SET @Rank = @Rank + CONVERT(FLOAT,1)
    				
                    FETCH NEXT FROM MyCursor3 INTO @CourseID3,@SumSales3
                END
                CLOSE MyCursor3
                DEALLOCATE MyCursor3
                /*- End Third Cursor for courses within the General Category*/
            END


            FETCH NEXT FROM MyCursor INTO @PrefCat
        END
    CLOSE MyCursor
    DEALLOCATE MyCursor
    /*- END First Cursor for PreferredCategory */
    
    /* Force ranks for some courses to top*/

    /* UPDATE Staging.Ecampn02Rank*/
    /* SET Rank = case when rank between 15 and 19 then Rank/1.56*/
    /* 		when rank between 20 and 50 then rank/2.56*/
    /* 		when rank between 50 and 75 then rank/3.56*/
    /* 		when rank between 76 and 100 then rank/4.568*/
    /* 		when rank>100 then rank/5.89*/
    /* 		else rank*/
    /* 	end */
    /* WHERE CourseID IN (1830,1426,7158,4242,3480,6450,5620,2270,8598,3430,2180, 1447, 1527, 8818, 5665)*/
    /* -- and rank > 10*/
    /* */
    /* UPDATE Staging.Ecampn02Rank*/
    /* SET Rank = case when rank > 10 then rank/2.56*/
    /* 		else rank*/
    /* 	end */
    /* WHERE CourseID IN (3310,5932,2527)*/
    /* */
    /**/
    /*UPDATE Staging.Ecampn02Rank*/
    /*SET Rank = case when rank > 10 then rank/1.546*/
    /*		when rank > 20 then rank/2.123*/
    /*		when rank > 30 then rank/4.789*/
    /*		else rank*/
    /*	end */
    /*-- SET Rank = rank/2.12*/
    /*WHERE CourseID IN (8510,4670,1557)*/
    /**/
    /**/
    /*UPDATE Staging.Ecampn02Rank */
    /*SET Rank = case when rank > 10 then rank/1.234*/
    /*		when rank > 20 then rank/3.16*/
    /*		else rank*/
    /*	end */
/* Force 90% off courses to the top*/

--UPDATE Staging.Ecampn02Rank
--SET Rank = rank/9.2
--WHERE CourseID IN (174,217,297,728,3372,6121,8128,8313,3310,710,7170,480,447,1573,210)



    /*- Report1: Ranking check report*/
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn02RankBKP')
        DROP TABLE Staging.Ecampn02RankBKP
    	
    select *
    into Staging.Ecampn02RankBKP
    from Staging.Ecampn02Rank

PRINT 'Check Number of Courses in Ranking Table'

SELECT a.PreferredCategory, count(a.courseid) as coursecount
FROM Staging.Ecampn02Rank a
group by a.PreferredCategory
ORDER BY a.PreferredCategory

    SELECT a.Sumsales,a.CourseID,b.CourseName,a.PreferredCategory, a.Rank   
    FROM Staging.Ecampn02Rank a,
        Mapping.DMCourse b
    WHERE a.CourseID = b.CourseID
    ORDER BY a.PreferredCategory, a.Rank

    /* delete courses ranked higher than 100 to save time*/
    delete from Staging.Ecampn02Rank
    where rank > 80


    /* update prefcat to secondary subject for customers in the signature table*/

    /*update a*/
    /*set a.PreferredCategory2 = b.secondarysubjpref*/
    /*from Marketingdm..campaigncustomersignature a join*/
    /*	MarketingDM..TempCustomerDynamicCourseRank b on a.customerid = b.customerid*/

    /*- STEP 3: Get the list of Emailable customers from the CustomerSignature Table*/
    IF @DeBugCode = 1 PRINT 'Begin STEP 3: Get the list of Emailable customers that should receive Favorite Subject Email.'

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn03Customer01')
        DROP TABLE Staging.Ecampn03Customer01

    SELECT ccs.Customerid,
        ccs.FirstName,
        ccs.LastName,
        ccs.EmailAddress,
        ccs.ComboID,
        CASE WHEN ccs.CustomerSegmentNew = 'Active' THEN @AdcodeActive
             ELSE @AdcodeSwamp
        END AS AdCode,
        ccs.State AS Region, ccs.CountryCode,
        CASE WHEN ccs.CustomerSegmentNew = 'Active' THEN @SubjectLineActive
             ELSE @SubjectLineSwamp
        END  AS SubjectLine,
        CASE WHEN ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'SC' then 'SCI'
            when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'FA' then 'VA'
            when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory NOT IN ('SC','FA') then ccs.preferredcategory
            else ccs.PreferredCategory2 
        END as PreferredCategory,
    /* 	ccs.PreferredCategory2 as PreferredCategory,*/
        CASE WHEN ccs.customerSegment = 'Active' THEN @ECampaignIDActive
             ELSE @ECampaignIDSwamp
        END AS ECampaignID,
        ccs.CustomerSegmentNew
    INTO Staging.Ecampn03Customer01
    FROM Marketing.CampaignCustomerSignature ccs
    WHERE ccs.FlagEmail = 1 AND ccs.BuyerType > 1 AND EmailAddress LIKE '%@%'
    AND ccs.PublicLibrary = 0
    AND ccs.CountryCode not in ('GB','AU')
     /* and ccs.customersegment = 'Swamp'*/


    /* Add Inquirers*/
    IF @DeBugCode = 1 PRINT 'Add Inquirers'

    IF @FlagIntnl = 'YES' 
       BEGIN
        INSERT INTO Staging.Ecampn03Customer01
        (Customerid, FirstName, LastName, EmailAddress, ComboID, Adcode, Region, CountryCode, SubjectLine, 
        PreferredCategory, ECampaignID, CustomerSegmentNew)
        SELECT CCS.CustomerID, Staging.proper(CCS.FirstName) FirstName,
            Staging.proper(CCS.LastName) LastName, CCS.EmailAddress, 
            CASE WHEN ccs.ComboID IN ('25-10000 Mo Inq Plus', 'Inq') THEN '25-10000 Mo Inq'
                 ELSE CCS.ComboID
            END AS ComboID, 
            @AdcodeInq as Adcode, 

            ISNULL(State,'') AS Region,
            ccs.CountryCode,
            @SubjectLineSwamp AS SubjectLine, 
            'GEN' AS PreferredCategory,
            @ECampaignIDInq AS ECampaignID,
            ccs.CustomerSegmentNew
        FROM Marketing.CampaignCustomerSignature CCS LEFT OUTER JOIN
            Staging.Ecampn03Customer01 EC01 ON CCS.CustomerID = EC01.CustomerID
        WHERE EC01.CustomerID IS NULL AND ccs.Buyertype = 1 
        AND ccs.FlagEmail = 1 AND ccs.PublicLibrary = 0
        AND ccs.CountryCode not in ('GB','AU')
    	
    /* Delete if there are still from GB*/
    DELETE FROM Staging.Ecampn03Customer01
    WHERE CountryCode = 'GB'



    DELETE A
    from Staging.Ecampn03Customer01 a join
        (select * from Marketing.campaigncustomersignature
        where countrycode = 'GB')b on a.emailaddress = b.emailaddress


    /* Delete if there are still from AU*/
    /*DELETE FROM Staging.Ecampn03Customer01*/
    /*WHERE CountryCode = 'AU'*/


    DELETE A
    from Staging.Ecampn03Customer01 a join
        (select * from Marketing.campaigncustomersignature
        where countrycode = 'AU'
        and CustomerSince >= '9/1/2010')b on a.emailaddress = b.emailaddress


    DELETE A
    from Staging.Ecampn03Customer01 a join
        (select * from Marketing.campaigncustomersignature
        where countrycode = 'AU'
        and CustomerSince >= '9/1/2010')b on a.CustomerID = b.CustomerID
    	
    /*- Update AdCode for International customers*/

    IF @DeBugCode = 1 PRINT 'Update AdCode for International customers'

    UPDATE EC01
    SET Adcode = @AdcodeIntnl
    FROM Staging.Ecampn03Customer01 EC01 
    WHERE EC01.CountryCode NOT LIKE '%US%'
    AND EC01.CountryCode IS NOT NULL
    AND EC01.CountryCode <> ''

    IF @DeBugCode = 1 PRINT 'Update AdCode for Canada customers' /* Added on 6/9/2010*/

    UPDATE EC01
    SET Adcode = @AdcodeCanada
    FROM Staging.Ecampn03Customer01 EC01 
    WHERE EC01.CountryCode LIKE '%CA%'


    /* Not tracking them separately any more. So, they do not get a separate adcode 
     Commented on 6/9/2010 */
    /*- Update Adcode for Customers without any subject preference*/
    /*IF @DeBugCode = 1 PRINT 'Update Adcode for Customers without any subject preference'*/

    /*UPDATE Staging.Ecampn03Customer01*/
    /*SET AdCode = @AdcodeNoSubjPref*/
    /*WHERE PreferredCategory IS NULL*/

    CREATE CLUSTERED INDEX IDX_customer_Ecamp03Cust01
    ON Staging.Ecampn03Customer01 (Customerid)



    /* Add Web Inquirers*/
    /* 	IF @DeBugCode = 1 PRINT 'Add Web Inquirers'*/
    /* */
    /* 	IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Email_WebInq')*/
    /* 		DROP TABLE Staging.Email_WebInq*/
    /* 	*/
    /* 	SELECT C.CustomerID, Staging.proper(C.FirstName) FirstName,*/
    /* 		Staging.proper(C.LastName) LastName, C.EmailAddress, 'WebInqs' AS ComboID,*/
    /* 		@AdcodeWebInq as Adcode, */
    /* 		convert(varchar(2),'') as Region,*/
    /* 		@SubjectLineSwamp AS SubjectLine,*/
    /* 		'GEN' AS PreferredCategory, */
    /* 		@ECampaignIDWebInq AS ECampaignID*/
    /* 	INTO Staging.Email_WebInq	*/
    /* 	FROM Staging.Customers C LEFT OUTER JOIN	*/
    /* 		Staging.CampaignCustomerSignature CCS ON C.CustomerID = CCS.CustomerID*/
    /* 		JOIN*/
    /* 		(SELECT CustomerID*/
    /* 		FROM Staging.AcctPreferences*/
    /* 		WHERE PreferenceID = 'OfferEmail'*/
    /* 		AND PreferenceValue = 1)AP ON C.CustomerID = AP.CustomerID*/
    /* 	WHERE CCS.CustomerID IS NULL AND C.EmailAddress LIKE '%@%'	*/
    /* 	AND C.EmailAddress not Like '%teachco.com' AND C.organization_key is null*/
    /* 	*/
    /* 	*/
    /* 	INSERT INTO Staging.Ecampn03Customer01*/
    /* 	(Customerid, FirstName, LastName, EmailAddress, ComboID, Adcode, Region, SubjectLine, */
    /* 	PreferredCategory, ECampaignID)*/
    /* 	SELECT WI.**/
    /* 	FROM Staging.Email_WebInq WI LEFT OUTER JOIN*/
    /* 		Staging.Ecampn03Customer01 EC01 on WI.Customerid = EC01.CustomerID*/
    /* 	WHERE EC01.CustomerID IS NULL*/
        END



    /*- Delete Customers with duplicate EmailAddress*/
    IF @DeBugCode = 1 PRINT 'Delete Customers with duplicate EmailAddress'

    DECLARE @RowCount INT
    SET @RowCount =1

    WHILE @RowCount > 0
    BEGIN
    DELETE FROM Staging.Ecampn03Customer01 
    WHERE CustomerID IN (
            SELECT MIN(Customerid)
            FROM Staging.Ecampn03Customer01 
            WHERE EmailAddress IN
                    (SELECT EmailAddress
                    FROM Staging.Ecampn03Customer01
                    GROUP BY EmailAddress
                    HAVING COUNT(Customerid) > 1)
            GROUP BY EmailAddress)
    SET @RowCount = @@ROWCOUNT
    SELECT @RowCount
    END

    /* Drop Unsubscribes and other IDs that should not receive the emails.*/
    exec Staging.CampaignEmail_RemoveUnsubs 'Ecampn03Customer01'

    /* Delete Swampers and Inquirers*/
    /* Adcode      AdcodeName                                         CatalogCode */
    /* ----------- -------------------------------------------------- ----------- */
    /* 27838       Dummy Swamp Control                                8804*/
    /* 27839       Dummy No Subj Pref                                 8804*/
    /* 27840       Dummy International control                        8805*/
    /* 27841       Dummy Inquirer place holder                        8806*/
    /* 27842       Dummy WebInq place holder                          8806*/
    /* 27843       Dummy Non Mail Recipients                          8807*/
    /* 32109       Dummy Email CatCodeFor Active Control              9340*/
    /* 9999999     Dummy Active	*/

    /* PRINT 'Delete unwanted segments'*/
    /* DELETE FROM Staging.Ecampn03Customer01*/
    /* WHERE Adcode IN (9999999, 27840, 6666, 27841)*/


    /*-- For 11/17/2010 email test -- if they are not in test, drop them*/
    /*PRINT 'Drop Customers if they are not in this test'*/

    /*delete a*/
    /*from Ecampn03Customer01 a left outer join*/
    /*	(select * from Staging.Email20101118_10PrcntGRPs_Fin)b on a.customerid = b.customerid*/
    /*where b.customerid is null*/

    /*
    delete a
    from Ecampn03Customer01 a left outer join
        (select * from Staging.Email20100717_OffersRND
        where adcode in (47210, 47211))b on a.emailaddress = b.emailaddress
    where b.emailaddress is null

    select Count(customerid)
    from Staging.Email20100717_OffersRND

    select count(customerid)
    from Staging.Ecampn03Customer01
    */

    /*- STEP 4: Assign Courses and Ranks to each customer based on their preferred category*/
    IF @DeBugCode = 1 PRINT 'Begin Step 4: Assign Courses and Ranks to each customer based on their preferred category'

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn03Customer02_Course')
        DROP TABLE Staging.Ecampn03Customer02_Course

    SELECT a.Customerid,
        a.FirstName,
        a.LastName,
        a.EmailAddress,
        a.ComboID,
        er.CourseID,
        er.Rank,
        a.Adcode,
        a.Region, a.CountryCode,
        a.SubjectLine,
        a.PreferredCategory,
        a.EcampaignID,
        a.CustomerSegmentNew 
    INTO Staging.Ecampn03Customer02_Course
    FROM Staging.Ecampn03Customer01 a,
        Staging.Ecampn02Rank er
    WHERE ISNULL(a.PreferredCategory,'GEN') = er.PreferredCategory


    CREATE CLUSTERED INDEX IDX_customer_Ecamp03Cust02
    ON Staging.Ecampn03Customer02_Course (Customerid)


    /*- STEP 5: Remove the courses FROM the customer list if they have already purchased them.*/
    IF @DeBugCode = 1 PRINT 'STEP 5: Remove the courses from the customer list if they have already purchased them'

    DELETE a
    /*SELECT a.* */
    FROM Staging.Ecampn03Customer02_Course a,
        (SELECT DISTINCT o.customerid, courseid
        FROM Marketing.dmpurchaseorderitems oi
        join Marketing.DMPurchaseOrders o on o.OrderID = oi.OrderID
        WHERE stockitemid LIKE '[PD][ACDMV]%'
        AND courseid IN (SELECT DISTINCT courseid FROM Staging.Ecampn02Rank))b
    WHERE a.customerid=b.customerid
    AND a.courseid=b.courseid

   /* remove July sets tes vs control sets from the customer groups 7/24/2013 - Sri
  delete a
    from Staging.Ecampn03Customer02_Course a
    join 
    (select  * from rmf.dbo.Mail_US_JulSetsMailing_20130705 where adcode<>83943) b
    on a.customerid=b.customerid where
    a.courseid in (5914,4255,9958,1943,1962,9959,2158,2144,9960,5725,5631,9961,7821,9962,1818,1897,9963)
    
      delete a
    from Staging.Ecampn03Customer02_Course a
    join 
    (select  * from rmf.dbo.Mail_US_JulSetsMailing_20130705 where adcode=83943) b
    on a.customerid=b.customerid where
    a.courseid in (650,6265,9941,4624,9942,1655,1912,9935,7869,8412,392,9909,1853,9815,9937,1973,7264)
    */
    

  /*   delete a
    from Staging.Ecampn03Customer02_Course a
   join (select *
  from rfm.dbo.Mail_EconNL_20100517
    where adcode = 43736)b on a.customerid = b.customerid --a.emailaddress=b.emailaddr 
  where a.courseid in (2598,2317,8467,8598,710,7237,4636,4691,6206,6481,1527,1592,5610)
  and a.adcode in (83123, 83125, 83127)*/


    /*- STEP 6: SELECT Max Number of Courses FROM the list.*/
    IF @DeBugCode = 1 PRINT 'STEP 6: Select Max Number of Courses From the list'

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn04Customer_Final')
        DROP TABLE Staging.Ecampn04Customer_Final

    CREATE TABLE Staging.Ecampn04Customer_Final
    (CustomerID udtCustomerID NOT NULL,
    FirstName VARCHAR(50) NULL,
    LastName VARCHAR(50) NULL,
    EmailAddress VARCHAR(50) NULL,
    ComboID VARCHAR(30) NULL,
    CourseID INT NULL,
    Rank FLOAT NULL,
    Adcode INT NULL,
    Region VARCHAR(50) NULL,
    CountryCode VARCHAR(3) NULL, 
    SubjectLine VARCHAR(200) NULL,
    PreferredCategory VARCHAR(5) NULL,
    ECampaignID VARCHAR(25) NULL,
    CustomerSegmentNew varchar(20) null)


    CREATE CLUSTERED INDEX IDX_customer_Ecamp04Fnl
    ON Staging.Ecampn04Customer_Final (Customerid)


    IF @DeBugCode = 1 PRINT 'STEP 6: Rerank the course list to put them in order'

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn03Customer02_Course2')
        DROP TABLE Staging.Ecampn03Customer02_Course2

    select *, rank() over (partition by customerid order by rank) as Rank2
    into Staging.Ecampn03Customer02_Course2
    from Staging.Ecampn03Customer02_Course


    CREATE INDEX ix_Ecampn03Customer02_Course21 on Staging.Ecampn03Customer02_Course2 (Customerid)
    CREATE INDEX ix_Ecampn03Customer02_Course22 on Staging.Ecampn03Customer02_Course2 (rank2)


    INSERT INTO Staging.Ecampn04Customer_Final
    SELECT Customerid, FirstName, LastName, EmailAddress, 
        ComboID, CourseID, Rank2 As Rank, Adcode, Region, CountryCode, 
        SubjectLine, PreferredCategory, ECampaignID, CustomerSegmentNew  
    FROM Staging.Ecampn03Customer02_Course2
    WHERE rank2 <= 25

    /*
    SET NOCOUNT ON

    IF @CourseCount > @MaxCourse
       BEGIN
        DECLARE @CustID INT
        DECLARE MyCursor CURSOR FOR
        SELECT DISTINCT customerid 
        FROM Staging.Ecampn03Customer02_Course
    	
            OPEN MyCursor
            FETCH NEXT FROM MyCursor INTO @CustID
    			
            WHILE @@FETCH_STATUS = 0
                BEGIN
                    SET ROWCOUNT @MaxCourse
                    INSERT INTO Staging.Ecampn04Customer_Final
                    SELECT * 
                    FROM Staging.Ecampn03Customer02_Course
                    WHERE CustomerID = @CustID
                    ORDER BY CustomerID, Rank, CourseID
                    SET ROWCOUNT 0
                    FETCH NEXT FROM MyCursor INTO @CustID
                END
            CLOSE MyCursor
            DEALLOCATE MyCursor
       END
    ELSE
       BEGIN
        INSERT INTO Staging.Ecampn04Customer_Final
        SELECT * 
        FROM Staging.Ecampn03Customer02_Course
       END

    SET NOCOUNT OFF
    */

    /*
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn04Customer_Final_New')
        DROP TABLE Staging.Ecampn04Customer_Final_New

    SELECT ECC.*, ECCSeq.SeqNum
    INTO Staging.Ecampn04Customer_Final_New
    FROM Staging.Ecampn03Customer02_Course ECC JOIN
                (SELECT ECC1.CUSTOMERID, ECC1.RANK, 
                SUM(CASE WHEN ECC2.RANK <= ECC1.RANK THEN 1 ELSE 0 END) SEQNUM 
                 FROM Staging.Ecampn03Customer02_Course ECC1 JOIN
                     Staging.Ecampn03Customer02_Course ECC2
                    ON ECC1.CUSTOMERID = ECC2.CUSTOMERID
                 GROUP BY ECC1.CUSTOMERID, ECC1.RANK) ECCSEQ
         ON ECCSEQ.CUSTOMERID = ECC.CUSTOMERID 
        AND ECCSEQ.RANK = ECC.RANK AND ECCSEQ.SEQNUM <= @MaxCourse
    ORDER BY ECC.CustomerID,  ECC.Rank


    CREATE CLUSTERED INDEX IDX_customer_Ecamp04FnlNew
    ON Staging.Ecampn04Customer_FinalNew (Customerid)
    */
    /*- STEP 7: Delete customers having less than 5 courses to offer.*/

    IF @DeBugCode = 1 PRINT 'STEP 7: Delete customers having less than 5 courses to offer'

    DELETE FROM Staging.Ecampn04Customer_Final
    WHERE CustomerID IN 
            (SELECT CustomerID
            FROM Staging.Ecampn04Customer_Final
            GROUP BY CustomerID
            HAVING COUNT(*) < 5)

    /* DELETE FROM Staging.Ecampn04Customer_Final_New*/
    /* WHERE CustomerID IN */
    /* 		(SELECT CustomerID*/
    /* 		FROM Staging.Ecampn04Customer_Final_New*/
    /* 		GROUP BY CustomerID*/
    /* 		HAVING COUNT(*) < 5)*/



    /*- STEP 8: Generate Reports*/
    SET ROWCOUNT 0

    IF @DeBugCode = 1 PRINT 'STEP 8: Generate Reports'

    /*- Report1: Ranking check report*/

    SELECT a.Sumsales,a.CourseID,b.CourseName,a.PreferredCategory, a.Rank   
    FROM Staging.Ecampn02Rank a,
        Mapping.DMCourse b
    WHERE a.CourseID = b.CourseID
    ORDER BY a.PreferredCategory, a.Rank

    /*- Report2: Counts by RFM Cells*/

    /* SELECT csm.newseg,csm.name,rds.a12mf,COUNT(DISTINCT mct.customerid) AS CountOfCustomers*/
    /* FROM Staging.Ecampn04Customer_Final mct,*/
    /* 	rfm..customersubjectmatrix csm,*/
    /* 	rfm..rfm_data_special rds*/
    /* WHERE mct.customerid=csm.customerid*/
    /* 	and csm.customerid=rds.customerid*/
    /* GROUP BY csm.newseg,csm.name,rds.a12mf*/
    /* order by csm.newseg,csm.name,rds.a12mf*/
    /* */
    /* --- Report3: Count by AdCode and SubjectLine*/
    /* */
    /* SELECT fnl.AdCode, mac.Name, Fnl.EcampaignID,*/
    /* 	fnl.SubjectLine,*/
    /* 	COUNT(fnl.Customerid) AS TotalCount,*/
    /* 	COUNT(DISTINCT fnl.Customerid) AS UniqueCustCount*/
    /* FROM Staging.Ecampn04Customer_Final fnl LEFT OUTER JOIN*/
    /* 	Staging.MktAdcodes mac ON fnl.adcode = mac.adcode*/
    /* GROUP BY fnl.AdCode, mac.Name, Fnl.EcampaignID, fnl.SubjectLine*/
    /* ORDER BY fnl.AdCode*/

    /* */
    /* --- Generate Customer and Course information for Instruction files*/

    /* SELECT DISTINCT c.customerid,d.firstname,d.lastname,c.PreferredCategory,c.adcode*/
    /* FROM (SELECT MAX(DISTINCT customerid) AS customerid, PreferredCategory, Adcode*/
    /* 	FROM Staging.Ecampn04Customer_Final*/
    /* 	GROUP BY PreferredCategory, Adcode)c,*/
    /* 	Staging.Ecampn04Customer_Final d*/
    /* WHERE c.customerid=d.customerid*/
    /* ORDER BY c.adcode, c.PreferredCategory, c.customerid*/

    /*SELECT DISTINCT c.customerid,d.firstname,d.lastname,c.PreferredCategory,c.adcode
    FROM (SELECT MAX(DISTINCT a.customerid) AS customerid,
            b.PreferredCategory,a.Adcode
        FROM Staging.Ecampn04Customer_Final  a,
            Staging.Ecampn03Customer01 b
        WHERE a.customerid=b.customerid
        GROUP BY b.PreferredCategory,a.Adcode)c,
        Staging.Ecampn04Customer_Final d
    WHERE c.customerid=d.customerid
    ORDER BY c.adcode, c.PreferredCategory, c.customerid*/

    SELECT DISTINCT CourseID
    FROM Staging.Ecampn02Rank

    /*- Add Customer data to Email History Table  */

    IF @Test = 'NO'
    BEGIN
        IF @DeBugCode = 1 PRINT 'Add Customer data to Email History Table'
        INSERT INTO Ecampaigns..EmailHistory
        (CustomerID,Adcode,StartDate)
        SELECT Customerid,
            Adcode,
            @DropDate AS StartDate
        FROM Staging.Ecampn03Customer01
    END

    /*- Create Final table*/
    IF @DeBugCode = 1 PRINT 'Create Final Tables'

    DECLARE @Qry VARCHAR(8000)

    /*- Drop if @FnlTablActive already exists*/
    /*DECLARE @RowCounts INT*/
    /*SELECT @RowCounts = COUNT(*) FROM sysobjects*/
    /*WHERE Name = @FnlTableActive*/
    /*SELECT '@RowCounts = ' + CONVERT(VARCHAR,@RowCounts)*/

    IF (EXISTS (SELECT * FROM ecampaigns.INFORMATION_SCHEMA.TABLES        
                WHERE TABLE_CATALOG = 'ECampaigns'
                AND TABLE_SCHEMA = 'dbo'
                AND TABLE_NAME = REPLACE(@FnlTableActive,'Ecampaigns.dbo.','')))
    BEGIN
        SET @Qry = 'DROP TABLE ' + @FnlTableActive
        SELECT @Qry
        EXEC (@Qry)
    END


    SET @QRY = 'SELECT *
        INTO ' + @FNLTABLEACTIVE +
           ' FROM STAGING.ECAMPN04CUSTOMER_FINAL
            WHERE Adcode in (' + CONVERT(VARCHAR,@AdcodeActive) + ', ' + convert(varchar, isnull(@AdcodeCanada, 0)) + ', ' + convert(varchar, isnull(@AdcodeIntnl, 0)) + ')'
    PRINT (@QRY)
    EXEC (@QRY)


    /*- Create Index on @FnlTable*/
    DECLARE @FnlIndex VARCHAR(50)

    SET @FnlIndex = 'IDX_' + REPLACE(@FnlTableActive,'Ecampaigns.dbo.','')

    SELECT 'Create Index'
    SET @Qry = 'CREATE CLUSTERED INDEX ' + @FnlIndex + ' ON ' + @FnlTableActive + '(CustomerID)'
    EXEC (@Qry)

    /*- Drop if @FnlTablSNI already exists*/

    /*SELECT @RowCounts = COUNT(*) FROM sysobjects*/
    /*WHERE Name = @FnlTableSNI*/
    /*SELECT '@RowCounts = ' + CONVERT(VARCHAR,@RowCounts)*/

    IF (EXISTS (SELECT * FROM ecampaigns.INFORMATION_SCHEMA.TABLES        
                WHERE TABLE_CATALOG = 'ECampaigns'
                AND TABLE_SCHEMA = 'dbo'
                AND TABLE_NAME = REPLACE(@FnlTableSNI,'Ecampaigns.dbo.','')))
    BEGIN
        SET @Qry = 'DROP TABLE ' + @FnlTableSNI
        SELECT @Qry
        EXEC (@Qry)
    END


    SET @Qry = 'SELECT *
            INTO ' + @FnlTableSNI +
           ' FROM Staging.Ecampn04Customer_Final
            WHERE Adcode not in (' + CONVERT(VARCHAR,@AdcodeActive) + ', ' + convert(varchar, isnull(@AdcodeCanada, 0)) + ', ' + convert(varchar, isnull(@AdcodeIntnl, 0)) + ')'

    EXEC (@Qry)


    /*- Create Index on @FnlTable*/


    SET @FnlIndex = 'IDX_' + REPLACE(@FnlTableSNI,'Ecampaigns.dbo.','')

    SELECT 'Create Index'
    SET @Qry = 'CREATE CLUSTERED INDEX ' + @FnlIndex + ' ON ' + @FnlTableSNI + '(CustomerID)'
    EXEC (@Qry)


    IF @DeBugCode = 1 PRINT 'END Staging.CampaignEmail_FvrtSubj'
end
GO
