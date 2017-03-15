SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Staging].[CampaignEmail_FavoriteSubjects]
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

    SELECT @TablePrefix = 'Email' + CONVERT(VARCHAR,@DropDate,112) + '_' + 'Offers_' + @EmailName
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

    /* Force ranks for some courses to top*/


--float courses to the top

--UPDATE Staging.TempECampaignCourseRank
--SET Rank = rank/4.2
--where courseid in (3390,3130,3356,3480,3372,3410,3180,893,323,2390,2752,2997,2429,2598,2567,297,8190,4617,8313,8467,8593,8570,877,4812,7237,790)

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

    /* update prefcat to secondary subject for customers in the signature table*/

    /*update a*/
    /*set a.PreferredCategory2 = b.secondarysubjpref*/
    /*from Marketingdm..campaigncustomersignature a join*/
    /*	MarketingDM..TempCustomerDynamicCourseRank b on a.customerid = b.customerid*/

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
        CASE WHEN ccs.CustomerSegmentNew in ( 'Active', 'NewToFile') THEN @AdcodeActive -- PR 5/7/2014 added NewToFile folks as they get PM4 version
             ELSE @AdcodeSwamp
        END AS AdCode,
        ccs.State AS Region, ccs.CountryCode,
        CASE WHEN ccs.CustomerSegmentNew in ( 'Active', 'NewToFile') THEN @SubjectLineActive -- PR 5/7/2014 added NewToFile folks as they get PM4 version
             ELSE @SubjectLineSwamp
        END  AS SubjectLine,
        CASE WHEN ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'SC' then 'SCI'
            when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory = 'FA' then 'VA'
            when ccs.PreferredCategory2 = 'X' and ccs.preferredcategory NOT IN ('SC', 'FA') then ccs.preferredcategory
            else ccs.PreferredCategory2 
        END as PreferredCategory,
    /* 	ccs.PreferredCategory2 as PreferredCategory,*/
        CASE WHEN ccs.customerSegment in ( 'Active', 'NewToFile') THEN @ECampaignIDActive -- PR 5/7/2014 added NewToFile folks as they get PM4 version
             ELSE @ECampaignIDSwamp
        END AS ECampaignID,
        ccs.CustomerSegmentNew
    INTO Staging.TempECampaignEmailableCustomers
    FROM Marketing.CampaignCustomerSignature ccs
    WHERE ccs.FlagEmail = 1 AND ccs.BuyerType > 1 AND EmailAddress LIKE '%@%'
    AND ccs.PublicLibrary = 0
    AND ccs.CountryCode not in ('GB','AU')
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


        /* Not tracking them separately any more. So, they do not get a separate adcode 
         Commented on 6/9/2010 */
        /*- Update Adcode for Customers without any subject preference*/
        /*IF @DeBugCode = 1 PRINT 'Update Adcode for Customers without any subject preference'*/

        /*UPDATE Staging.Ecampn03Customer01*/
        /*SET AdCode = @AdcodeNoSubjPref*/
        /*WHERE PreferredCategory IS NULL*/

    --    CREATE CLUSTERED INDEX IDX_customer_Ecamp03Cust01
    --    ON Staging.Ecampn03Customer01 (Customerid)



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
	end

    /*- Delete Customers with duplicate EmailAddress*/
    IF @DeBugCode = 1 PRINT 'Delete Customers with duplicate EmailAddress'
	exec Staging.CampaignEmail_ExecuteSharedLogic 'DeleteDupEmails'

    /* Drop Unsubscribes and other IDs that should not receive the emails.*/
    exec Staging.CampaignEmail_RemoveUnsubs 'TempECampaignEmailableCustomers'

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

--    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Ecampn03Customer02_Course')
--        DROP TABLE Staging.Ecampn03Customer02_Course

	exec Staging.CampaignEmail_ExecuteSharedLogic 'LoadCustomerCourseRank'    
--    CREATE CLUSTERED INDEX IDX_customer_Ecamp03Cust02
--    ON Staging.Ecampn03Customer02_Course (Customerid)

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
/*
	select top 1 
    	@TestAdCode = t.AdCode,
        @TestSubjectLine = t.SubjectLine,
        @TestECampaignID = t.ECampaignID
    from Staging.TempECampaignEmailableCustomers (nolock) t
*/    
	exec Staging.CampaignEmail_ExecuteSharedLogic 'LoadEmailTemplate', @AdcodeActive, @StartDate
    
    /*remove jan prospect reactivation courses from the customer group 01/14/2010 - Sri*/
    /*delete a*/
    /*from Staging.Ecampn03Customer02_Course a*/
    /*join lstmgr.dbo.Email_20100112_JanReact2010Prospect_DLR_SNI_1 b*/
    /*on a.customerid=b.customerid where*/
    /*a.courseid in (350,340,345,370,8267,5620,8320,323,243,650,8500,1600,3910,700,1475,8080,3757,4294,1106,1411,885,2250,1426,2198,4433,5181,2368,7261,611,297,1810,1580,5932,160,7100,177,4200,1700,656,653,6100,1100,2100,1487,550,153,1564,4600,1474,8050,6593,1597,1272,7187,687,6577,4360,437,4168,810,6240,805,728)*/
    /**/
    /**/

    /*delete a*/
    /*from Staging.Ecampn03Customer02_Course a*/
    /*join (select **/
    /*	from rfm.dbo.Mail_EconNL_20100517*/
    /*	where adcode = 43736)b on a.customerid = b.customerid --a.emailaddress=b.emailaddr */
    /*where a.courseid in (550,5932,5181,5665)*/


    /*- STEP 8: Generate Reports*/
    SET ROWCOUNT 0

    IF @DeBugCode = 1 PRINT 'STEP 8: Generate Reports'

    /*- Report1: Ranking check report*/

    SELECT a.Sumsales,a.CourseID,b.CourseName,a.PreferredCategory, a.Rank   
    FROM Staging.TempECampaignCourseRank2 a,
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
    FROM Staging.TempECampaignCourseRank2

    /*- Add Customer data to Email History Table -- SK: no longer needed */
--    IF @Test = 'NO'
--    BEGIN
--        IF @DeBugCode = 1 PRINT 'Add Customer data to Email History Table'
--        exec Staging.CampaignEmail_ExecuteSharedLogic 'AddToEmailHistory', @StartDate = @DropDate
--    END

    /*- Create Final table*/
    IF @DeBugCode = 1 PRINT 'Create Final Tables'
    
    exec Staging.CampaignEmail_ExecuteSharedLogic 'CreateFinalTables', @TablePrefix = @TablePrefix
    
	exec Staging.CampaignEmail_DropTempTables
        
	if @DeBugCode = 1 print 'End ' + object_name(@@procid)    
end
GO
