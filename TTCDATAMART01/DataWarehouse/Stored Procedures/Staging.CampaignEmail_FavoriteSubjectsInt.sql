SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Staging].[CampaignEmail_FavoriteSubjectsInt]
	@EmailName varchar(20) = 'FvrtSbjct',
	@CountryCode char(2) = 'US',  
	@EmailCatalogCode INT,
	@EmailCatalogCodeSwamp INT = 8804,
	@EmailCatalogCodeInt INT = 8805,
	@EmailCatalogCodeInquirer INT = 8806,
	@EmailCatalogCodeCanada INT = 13631,
	@NumCourses int = 25,
	@FlagIntnl VARCHAR(3) = 'YES',
	@Test VARCHAR(5) = 'YES',
	@DeBugCode INT = 1
AS

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
    	@AdcodeCanada INT,
        @SQLStatement nvarchar(300),
        @BundleCount int,
        @TablePrefix VARCHAR(100)
begin
	--set nocount on
    
	exec Staging.CampaignEmail_DropTempTables
    
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

    IF @CountryCode = 'US' and @EmailCatalogCodeCanada <> 13631
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

	if @CountryCode = 'US'
	    SELECT @ECampaignIDActive = 'FSAct' 
	else
		SELECT @ECampaignIDActive = 'EMAIL_UK_FavSubj'     	        
	set @ECampaignIDActive =  @ECampaignIDActive + CONVERT(VARCHAR,@DropDate,112)
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

    SELECT @TablePrefix = 'Email' + CONVERT(VARCHAR,@DropDate,112) + '_Offers_' + @CountryCode + '_' + @EmailName
    FROM Staging.MktCatalogCodes
    WHERE CatalogCode = @EmailCatalogCode

    IF @DeBugCode = 1 
    BEGIN
        PRINT 'Final table name templete = ' + @TablePrefix
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
    	
		if @CountryCode = 'US'
        begin
            SELECT @AdcodeCanada =  Adcode
            FROM Staging.MktAdcodes
            WHERE CatalogCode IN (@EmailCatalogCodeCanada)
            AND UPPER(Name) LIKE '%canada%' /*CONTROL'*/
        	
            IF @AdcodeCanada IS NULL
               BEGIN
                PRINT '****WARNING**** AdcodeCanada was not found. So, using dummy Canada Adcode'
                SET @AdcodeNoSubjPref = 44279 
               END
		end           
    	   
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
    declare @StartDate datetime

    SELECT @StopDate = StopDate,
		@StartDate = StartDate
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


    SELECT 
    	sum(FNL.SumSales) AS SumSales,
        FNL.CourseID,
        cast(0 as money) as CourseParts,
        FNL.PreferredCategory,
		convert(float,0.0) as Rank,
        cast(1 as bit) as FlagPurchased,
        cast(0 as bit) as FlagBundle,
    	sum(FNL.SumSales) as SumSalesBkp
    INTO Staging.TempECampaignCourseRank
    FROM	(SELECT sum(OI.SalesPrice) AS SumSales,
                II.Courseid AS CourseID,
                'GEN' AS PreferredCategory
        FROM  Marketing.DMPurchaseOrders O JOIN
            Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
            Staging.InvItem II ON OI.StockItemID = II.StockItemID 
            JOIN Staging.MktPricingMatrix MPM ON MPM.UserStockItemID = II.StockItemID	
        WHERE O.DATEORDERED BETWEEN DATEADD(Month,-6,GETDATE()) AND GETDATE()
        AND O.SequenceNum > 1
        -- and o.BillingCountryCode = @CountryCode
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
      --  and o.BillingCountryCode = @CountryCode
        AND MPM.CatalogCode = @EmailCatalogCode
--        AND CSM.PreferredCategory2 is not null
        GROUP BY CSM.PREFERREDCATEGORY2, II.Courseid)FNL
    GROUP BY FNL.CourseID,FNL.PreferredCategory
    -- ORDER BY FNL.PreferredCategory,Sum(FNL.SumSales) DESC
    
    SELECT 
	    BC.BundleID, 
        MC1.CourseName AS BundleName,
        BC.CourseID, 
        MC2.CourseName, 
        MC2.CourseParts, 
        MC2.ReleaseDate,
        cast(0 as money) as Sales
    INTO Staging.TempECampaignBundleCourse
    from Mapping.BundleComponents BC (nolock) 
    JOIN
    (
        SELECT DISTINCT BC.BundleID
        FROM Staging.MktPricingMatrix MPM (nolock)
        JOIN Staging.InvItem II (nolock) ON MPM.UserStockItemID = II.StockItemID 
        JOIN Mapping.BundleComponents BC (nolock) ON II.CourseID = BC.BundleID
        WHERE MPM.CatalogCode = @EmailCatalogCode
    ) B on BC.BundleID = B.BundleID 
    JOIN Mapping.DMcourse MC1 (nolock) ON BC.BundleID = MC1.CourseID 
    JOIN Mapping.DMcourse MC2 (nolock) ON BC.CourseID = MC2.CourseID
    where bc.bundleflag > 0
    
    SELECT @BundleCount = COUNT(BundleID) 
    FROM Staging.TempECampaignBundleCourse (nolock)
    
    if @BundleCount > 0
    begin
        SELECT Sum(FNL.SumSales) AS SumSales,
            FNL.CourseID,
            FNL.PreferredCategory
        INTO Staging.TempECampaignBundleCourseByCategory
        FROM	(SELECT sum(OI.SalesPrice) AS SumSales,
                    BC.CourseID,
                    'GEN' AS PreferredCategory
            FROM  Marketing.DMPurchaseOrders O JOIN
                Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
                (SELECT DISTINCT CourseID
                FROM Staging.TempECampaignBundleCourse) BC on OI.CourseID = BC.CourseID
            AND O.DATEORDERED BETWEEN DATEADD(Month,-6,GETDATE()) AND GETDATE()
            AND O.SequenceNum > 1
            -- and o.BillingCountryCode = @CountryCode
            GROUP BY BC.CourseID
            UNION
            SELECT sum(OI.SalesPrice) AS SumSales,
                BC.CourseID,
                ISNULL(CSM.PreferredCategory2,'GEN') AS PreferredCategory
            FROM Marketing.CampaignCustomerSignature CSM JOIN
                Marketing.DMPurchaseOrders O ON CSM.CUSTOMERID = O.CUSTOMERID JOIN
                Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
                (SELECT DISTINCT CourseID
                FROM Staging.TempECampaignBundleCourse) BC on OI.CourseID = BC.CourseID
            WHERE O.DATEORDERED BETWEEN DATEADD(Month,-6,GETDATE()) AND GETDATE()
            AND O.SequenceNum > 1
            -- and o.BillingCountryCode = @CountryCode
--            AND CSM.PreferredCategory2 IS NOT NULL
            GROUP BY BC.CourseID, CSM.PreferredCategory2) FNL
        GROUP BY FNL.CourseID,FNL.PreferredCategory
        
        INSERT INTO Staging.TempECampaignCourseRank
        (
        	SumSales,
            CourseID,
            PreferredCategory,
            Rank,
            FlagBundle,
            CourseParts,
            SumSalesBkp,
            FlagPurchased
       	)
        SELECT 
        	AVG(B.SumSales) SumSales,
            A.BundleID AS CourseID, 
            B.PreferredCategory,
            convert(float,0) AS Rank,
            1 AS FlagBundle,
            0 as CourseParts,
            Sum(B.SumSales) AS SumSalesBkp,
            1
        FROM Staging.TempECampaignBundleCourse A (nolock)
        JOIN Staging.TempECampaignBundleCourseByCategory B (nolock) ON A.CourseID = B.CourseID
        GROUP BY A.BundleID, B.PreferredCategory
    end
    
	/*- Assign ranking based on Sales*/
    IF @DeBugCode = 1 PRINT 'Assign Ranking Based on sales'
    exec Staging.CampaignEmail_ExecuteSharedLogic @LogicName = 'RankBySales'


--float courses to the top

--UPDATE Staging.TempECampaignCourseRank
--SET Rank = rank/8.2
--where courseid in (337,217,2752,237,897,4880,8820,415,443,6121,790,1284,1557)

    /*- Report1: Ranking check report*/


    SELECT a.Sumsales,a.CourseID,b.CourseName,a.PreferredCategory, a.Rank   
    FROM Staging.TempECampaignCourseRank a,
        Mapping.DMCourse b
    WHERE a.CourseID = b.CourseID
    ORDER BY a.PreferredCategory, a.Rank
    
    -- Transfer data to another rank table and drop some courses to speed up the process
    select * into Staging.TempECampaignCourseRank2
    from Staging.TempECampaignCourseRank

    /* delete courses ranked higher than 100 to save time*/
    delete from Staging.TempECampaignCourseRank
    where rank > 75


    /*- STEP 3: Get the list of Emailable customers from the CustomerSignature Table*/
    IF @DeBugCode = 1 PRINT 'Begin STEP 3: Get the list of Emailable customers that should receive Favorite Subject Email.'

--    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn03Customer01')
--        DROP TABLE Staging.Ecampn03Customer01

    SELECT ccs.CustomerID,
        ccs.FirstName,
        ccs.LastName,
        ccs.EmailAddress,
        ccs.ComboID,
        111 as MailedAdcode,
         @AdcodeActive AS AdCode,
        ccs.State AS Region, ccs.CountryCode,
        @SubjectLineActive  AS SubjectLine,
        CASE WHEN ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'SC' then 'SCI'
            when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'FA' then 'VA'
            when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory NOT IN ('SC', 'FA') then ccs.preferredcategory
            else ccs.PreferredCategory2 
        END as PreferredCategory,
    /* 	ccs.PreferredCategory2 as PreferredCategory,*/
        @ECampaignIDActive  AS ECampaignID,
        ccs.CustomerSegmentNew
    INTO Staging.TempECampaignEmailableCustomers
    FROM Marketing.CampaignCustomerSignature ccs
    WHERE ccs.FlagEmail = 1 AND ccs.BuyerType > 1 AND EmailAddress LIKE '%@%'
    AND ccs.PublicLibrary = 0
    AND ccs.CountryCode = @CountryCode
   /* AND (
            ccs.CountryCode = case @CountryCode when 'US' then 'US' else @CountryCode end or 
            ccs.CountryCode = case @CountryCode when 'US' then 'CA' else @CountryCode end
        )
      and ccs.customersegment = 'Swamp'*/

	if @CountryCode = 'US'
    begin
        -- Add Inquirers
        IF @DeBugCode = 1 PRINT 'Add Inquirers'

        IF @FlagIntnl = 'YES' 
           BEGIN
            INSERT INTO Staging.TempECampaignEmailableCustomers
            (Customerid, FirstName, LastName, EmailAddress, ComboID, Adcode, Region, CountryCode, SubjectLine, 
            PreferredCategory, ECampaignID, CustomerSegmentNew, MailedAdcode)
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
                ccs.CustomerSegmentNew,
                111 as MailedAdcode
            FROM Marketing.CampaignCustomerSignature CCS LEFT OUTER JOIN
                Staging.TempECampaignEmailableCustomers EC01 ON CCS.CustomerID = EC01.CustomerID
            WHERE EC01.CustomerID IS NULL AND ccs.Buyertype = 1 
            AND ccs.FlagEmail = 1 AND ccs.PublicLibrary = 0
            AND ccs.CountryCode not in ('GB','AU')

        /* Delete if there are still from GB*/
        DELETE FROM Staging.TempECampaignEmailableCustomers
        WHERE CountryCode = 'GB'

        DELETE A
        from Staging.TempECampaignEmailableCustomers a join
            (select * from Marketing.campaigncustomersignature
            where countrycode = 'GB')b on a.emailaddress = b.emailaddress

        DELETE A
        from Staging.TempECampaignEmailableCustomers a join
            (select * from Marketing.campaigncustomersignature
            where countrycode = 'AU')b on a.emailaddress = b.emailaddress

        DELETE A
        from Staging.TempECampaignEmailableCustomers a join
            (select * from Marketing.campaigncustomersignature
            where countrycode = 'AU')b on a.CustomerID = b.CustomerID
        	
        /*- Update AdCode for International customers*/

        IF @DeBugCode = 1 PRINT 'Update AdCode for International customers'

        UPDATE EC01
        SET Adcode = @AdcodeIntnl
        FROM Staging.TempECampaignEmailableCustomers EC01 
        WHERE EC01.CountryCode NOT LIKE '%US%'
        AND EC01.CountryCode IS NOT NULL
        AND EC01.CountryCode <> ''

        IF @DeBugCode = 1 PRINT 'Update AdCode for Canada customers' /* Added on 6/9/2010*/

        UPDATE EC01
        SET Adcode = @AdcodeCanada
        FROM Staging.TempECampaignEmailableCustomers EC01 
        WHERE EC01.CountryCode LIKE '%CA%'

           END
	end

    /*- Delete Customers with duplicate EmailAddress*/
    IF @DeBugCode = 1 PRINT 'Delete Customers with duplicate EmailAddress'
	exec Staging.CampaignEmail_ExecuteSharedLogic 'DeleteDupEmails'

    /* Drop Unsubscribes and other IDs that should not receive the emails.*/
    exec Staging.CampaignEmail_RemoveUnsubs 'TempECampaignEmailableCustomers'

   
    
    /*- STEP 4: Assign Courses and Ranks to each customer based on their preferred category*/
    IF @DeBugCode = 1 PRINT 'Begin Step 4: Assign Courses and Ranks to each customer based on their preferred category'

	exec Staging.CampaignEmail_ExecuteSharedLogic 'LoadCustomerCourseRank'    


    /*- STEP 5: Remove the courses FROM the customer list if they have already purchased them. -- SK: moved to shared logic proc*/
    
    if @BundleCount > 0
    begin
		IF @DeBugCode = 1 PRINT 'STEP  5a: Remove Bundles from the customer list if they have already purchased courses from the bundle.'    
        
        delete ccr
        from Staging.TempECampaignCustomerCourseRank ccr 
		JOIN Marketing.completecoursepurchase ccp (nolock) on ccr.CustomerID = ccp.CustomerID        
        join Staging.TempECampaignBundleCourse bc (nolock) on bc.BundleID = ccr.CourseID and bc.CourseID = ccp.CourseID
    end

    IF @DeBugCode = 1 PRINT 'STEP 6: Rerank the course list to put them in order'  
	exec Staging.CampaignEmail_ExecuteSharedLogic 'ReRankCourses',0,null,null,@NumCourses   

	exec Staging.CampaignEmail_ExecuteSharedLogic 'AddPreTestData', @AdcodeActive
  
	exec Staging.CampaignEmail_ExecuteSharedLogic 'LoadEmailTemplate', @AdcodeActive, @StartDate
    


    /*- STEP 8: Generate Reports*/
    SET ROWCOUNT 0

    IF @DeBugCode = 1 PRINT 'STEP 8: Generate Reports'

    /*- Report1: Ranking check report*/

    SELECT a.Sumsales,a.CourseID,b.CourseName,a.PreferredCategory, a.Rank   
    FROM Staging.TempECampaignCourseRank2 a,
        Mapping.DMCourse b
    WHERE a.CourseID = b.CourseID
    ORDER BY a.PreferredCategory, a.Rank

 

    SELECT DISTINCT CourseID
    FROM Staging.TempECampaignCourseRank2


    /*- Create Final table*/
    IF @DeBugCode = 1 PRINT 'Create Final Tables'
    
    exec Staging.CampaignEmail_ExecuteSharedLogic 'CreateFinalTables', @TablePrefix = @TablePrefix
    
	exec Staging.CampaignEmail_DropTempTables
        
	if @DeBugCode = 1 print 'End ' + object_name(@@procid)    
end
GO
