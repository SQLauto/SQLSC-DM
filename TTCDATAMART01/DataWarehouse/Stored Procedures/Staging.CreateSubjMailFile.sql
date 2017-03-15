SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*- Proc Name: 	rfm.dbo.CreateSubjMailFile */
/*- Purpose:	This creates mail file for subject based mailings */
/*-		like Magazines, Magalogs.*/
/*- Input Parameters: @CatalogCode,@CatalogName,@DropDate,@PrimarySubject,@MaxSubjRank,*/
/*-		      @FnlTblName,@MailIPTbl,@AdcodeActive,@AdcodeSwamp,@AdcodeInq*/
/*- Tables Used: MarketingDM.dbo.ValidMailList*/
/*- Updates:*/
/*- Name		Date		Comments*/
/*- Preethi Ramanujam 	5/25/2007	New*/
/*- Preethi Ramanujam   9/19/2007       Added step 4b to remove two segments from magalogs. */

CREATE    PROC [Staging].[CreateSubjMailFile] 
 	@CatalogCode INT,
	@MailPiece VARCHAR(50),
	@DropDate DATETIME,
	@PrimarySubject VARCHAR(5),
	@MaxSubjRank VARCHAR(5),
	@AdcodeActive INT,
	@AdcodeSwamp INT
AS
	DECLARE @ErrorMsg VARCHAR(400)   /*- Error message for error handling.*/
    DECLARE @ValSubjCount INT
begin
	set nocount on

    SELECT 'IN THE SUBJMail'
    SELECT '@DropDate = ' + CONVERT(VARCHAR,@DropDate,101)

    /*- Preliminary checks*/
    /*- Make sure PrimarySubject derived is correct.*/
    SELECT * FROM Mapping.ValidSubjCat
    WHERE SubjectCategory = @PrimarySubject

    IF @@ROWCOUNT = 0
    BEGIN
        SET @ErrorMsg = '''' + @PrimarySubject + '''' + ' is NOT a Valid Subject Category. Please check the Name field in the MktCatalog table for CatalogCode ' + @CatalogCode 
        RAISERROR(@ErrorMsg,15,1)
        RETURN
    END	

    /*- If MaxSubjectRank was not sent as a parameter, then derive based on the PrimarySubject category.*/

    IF @MaxSubjRank = 'S100'
    BEGIN

        SELECT @MaxSubjRank =  CRSubjRank 
        FROM Mapping.SubjectCorrelation
        WHERE CRSubjAbbr = @PrimarySubject
        AND SeqNum = (SELECT MAX(seqnum) 
                FROM Mapping.SubjectCorrelation
                WHERE CRSubjAbbr = @PrimarySubject 
                AND primarysubjabbr <> 'REST')
    END

    /*- Make sure MaxSubjectRank level provided is correct*/
    SELECT @ValSubjCount = COUNT(*) 
    FROM Mapping.SubjectCorrelation
    WHERE CRSubjAbbr = @PrimarySubject
    AND CRSubjRank = @MaxSubjRank

    IF @ValSubjCount = 0
    BEGIN
        SET @ErrorMsg = '''' + @MaxSubjRank + '''' + ' is NOT a valid SubjectRank for Subject Category ''' + @PrimarySubject + ''''
        RAISERROR(@ErrorMsg,15,1)
        RETURN
    END	

    SELECT 
        ccs.CustomerID,
        ccs.BuyerType,
        ccs.ComboID,
        ccs.NewSeg,
        ccs.Name,
        ccs.a12mf,
        ccs.Concatenated,
        ccs.CustomerSegment,
        ccs.Frequency,
        ccs.FMPullDate, 
        @DropDate AS StartDate, 
        ccs.AH,
        ccs.EC,
        ccs.FA,
        ccs.HS,
        ccs.LIT,
        ccs.MH,
        ccs.PH,
        ccs.RL,
        ccs.SC,
        ccs.SCI,
        ccs.MTH,
        ccs.FW,
        ccs.PR,
        ccs.MSC,
        ccs.VA,
        ccs.FlagMail as FlagMailable,
        ccs.FlagEmail as FlagEmailable,
        ccs.Prefix,
        ccs.FirstName,
        ccs.MiddleName,
        ccs.LastName,
        ccs.Suffix,
        ccs.CompanyName as Company,
        ccs.Address1 + ' '  + ccs.Address2 as Address1,
        ccs.Address3 as Address2,
        ccs.City,
        ccs.State,
        ccs.PostalCode,
        ccs.PreferredCategory2,
        CASE 
            WHEN ccs.CustomerSegment = 'Active' THEN @AdcodeActive
            ELSE @AdcodeSwamp
        END AS Adcode,
        CCS.NumHits,
        ccs.CG_Gender,
        ccs.CustomerSince,
        cast(null as varchar(2)) as SubjRank,
        cast(null as varchar(3)) as DrtvPreferredCategory,
        cr.DSLPurchase,
        cr.Recency,
        cr.IntlAOS, 
        cr.IntlOrderSource,
        cr.IntlFormat,
        cr.IntlPromotionTypeID,
        ccs.CustomerSegmentNew,
        ccs.FlagEmail,
        cd.TenureDays,
        cd.LTDPurchases,
        cd.R3FormatMediaPref,
        cd.TTB
    INTO Staging.TempMailPull        
    FROM Marketing.CampaignCustomerSignature ccs (nolock)
	left join Staging.vwCustomerRecency cr (nolock) on cr.CustomerID = ccs.CustomerID    
    left join Marketing.CustomerDynamicCourseRank cd on cd.CustomerID = ccs.CustomerID
    WHERE 
        BuyerType IN (4, 5)
        AND FlagMail = 1
        AND FlagValidRegionUS = 1
        AND PublicLibrary = 0
        
    --- STEP 2: Update Subject Rank in the @CustTable
    SELECT 'Update subject Rank'
    --- Declare Cursor Variables
    DECLARE @PrimSubj VARCHAR(5)
    DECLARE @SubjRank VARCHAR(5)
    DECLARE @SeqNum INT 
    DECLARE @Qry2 VARCHAR(8000)
    DECLARE @QryDrtvFnl VARCHAR(8000)
    DECLARE @QryDrtv VARCHAR(8000)
    DECLARE @Qry1 VARCHAR(8000)

    SET @Qry1 = 'UPDATE Staging.TempMailPull SET SubjRank = CASE '
    SET @Qry2 = ''

    SET @QryDrtvFnl = ''
    SET @QryDrtv = ''

    --- Begin Frist Cursor
    DECLARE MyCursor1 CURSOR FOR
    SELECT DISTINCT CRSubjRank, SeqNum 
    FROM Mapping.SubjectCorrelation
    WHERE CRSubjAbbr = @PrimarySubject
    ORDER BY SeqNum

        OPEN MyCursor1
        FETCH NEXT FROM MyCursor1 INTO @SubjRank,@SeqNum 
    		
        WHILE @@FETCH_STATUS = 0
            BEGIN
                --- Begin Second Cursor
                DECLARE MyCursor2 CURSOR FOR
                SELECT DISTINCT PrimarySubjAbbr
                FROM Mapping.SubjectCorrelation
                WHERE CRSubjAbbr = @PrimarySubject
                AND CRSubjRank = @SubjRank
    			
                    OPEN MyCursor2
                    FETCH NEXT FROM MyCursor2 INTO @PrimSubj
    					
                    WHILE @@FETCH_STATUS = 0
                        BEGIN
                            IF @PrimSubj NOT LIKE 'REST'
                            BEGIN
                            IF @Qry2 = ''
                                SET @Qry2 = ' WHEN ' + @Qry2 + @PrimSubj + ' = 1 '
                            ELSE 
                                    SET @Qry2 = @Qry2 + ' OR ' + @PrimSubj + ' = 1 '

                            IF @QryDrtv = ''
                                SET @QryDrtv = ' WHEN  DrtvPreferredCategory = ''' + @PrimSubj + ''' '
                            ELSE
                                SET @QryDrtv = @QryDrtv + ' OR DrtvPreferredCategory = ''' + @PrimSubj + ''' '
                            END

                            FETCH NEXT FROM MyCursor2 INTO @PrimSubj
                        END

                CLOSE MyCursor2
                DEALLOCATE MyCursor2
                --- End Second Cursor
                IF @Qry2 = ''
                    SET @Qry2 = ' ELSE ''' + @SubjRank + ''' '
                ELSE
                    SET @Qry2 = @Qry2 + ' THEN ''' + @SubjRank  + ''' '

                SET @Qry1 = @Qry1 + @Qry2

                SET @Qry2 = ''

                IF @QryDrtv = ''
                    SET @QryDrtv = ' ELSE ''' + @SubjRank + ''' '
                ELSE
                    SET @QryDrtv = @QryDrtv + ' THEN ''' + @SubjRank  + ''' '

                SET @Qry1 = @Qry1 + @Qry2
                SET @Qry2 = ''

                SET @QryDrtvFnl = @QryDrtvFnl + @QryDrtv
                SET @QryDrtv = ''

                FETCH NEXT FROM MyCursor1 INTO @SubjRank,@SeqNum
            END
    CLOSE MyCursor1
    DEALLOCATE MyCursor1
    --- End Frist Cursor

    SET @Qry1 = @Qry1 + ' END'
    SELECT @Qry1
    EXEC (@Qry1)
  
  /* -- PR No need to add DRTV inquirers any more       
    - STEP 2a: Add DRTV Inquirers
    INSERT INTO Staging.TempMailPull(
    	Customerid, 
        BuyerType, 
        ComboID, 
        CustomerSegment, 
        Frequency,
        Name,
        FMPullDate, 
        StartDate, 
        FlagMailable, 
        FlagEmailable, 
        Prefix, 
        FirstName, 
        MiddleName, 
        LastName, 
        Suffix, 
        Company, 
        Address1, 
        Address2, 
        City, 
        State, 
        PostalCode, 
        PreferredCategory,
        AdCode, 
        SubjRank,
        DrtvPreferredCategory
    )
    SELECT 
    	CCS.CustomerID,
        CCS.BuyerType, 
        ComboID, 
        'DRTV' AS CustomerSegment, 
        'INQ' AS Frequency,
	    'DRTV Inq' AS Name,
	    CCS.FMPullDate, 
        @DropDate AS StartDate,
    	CCS.FlagMail, 
        CCS.FlagEmail,
	    CCS.Prefix, 
        CCS.FirstName,
        CCS.MiddleName,
        CCS.LastName,
        CCS.Suffix, 
        CCS.CompanyName,
	    CCS.Address1, 
        CCS.Address2, 
        CCS.City, 
        CCS.State, 
        CCS.PostalCode, 
        CCS.PreferredCategory2,
	    @AdcodeActive,
        cast(null as varchar(2)) as SubjRank,
        da.PreferredCategory
    FROM Marketing.CampaignCustomerSignature CCS (nolock)
    JOIN Mapping.DrtvAdcodes DA (nolock) ON DA.Adcode = CCS.FirstUsedAdcode
    WHERE CCS.DrtvInq = 1
    AND CCS.FlagMail = 1
    AND CCS.FlagValidRegionUS = 1
    AND CCS.Buyertype = 1
    AND CCS.PublicLibrary = 0
    AND DA.PreferredCategory IS NOT NULL
    
    SET @Qry1 = 'UPDATE Staging.TempMailPull SET SubjRank = CASE ' + @QryDrtvFnl + ' END where SubjRank is null'     
    SELECT @Qry1
    EXEC (@Qry1)
  */

    /*- STEP 3: DELETE customers with SubjRank more than @MaxSubjRank*/
    SELECT 'DELETE customers with SubjRank more than @MaxSubjRank'
    DECLARE @MaxSeqNum INT

    SELECT @MaxSeqNum =  SeqNum
    FROM Mapping.SubjectCorrelation
    WHERE CRSubjAbbr = @PrimarySubject
    AND CRSubjRank = @MaxSubjRank

    SELECT '@MaxSeqNum = ' + CONVERT(VARCHAR,@MaxSeqNum)

    DELETE FROM Staging.TempMailPull
    WHERE SubjRank IN 
    (
    	SELECT DISTINCT CRSubjRank 
        FROM Mapping.SubjectCorrelation (nolock)
        WHERE 
        	CRSubjAbbr = @PrimarySubject
            AND SeqNum > @MaxSeqNum
	)
   
   /* 
	UPDATE a
    SET A.DSLPurchaseDays = B.DSLPurchaseDays, a.recency = b.recency
    from Staging.TempMailPull a 
    join Staging.vwCustomerRecency B (nolock) on a.customerid = b.customerid
*/    			  

    /*- STEP 4: Delete customers who have bought more than 65% of courses (course parts) */
    /*-         feauted in the mailing.*/
    /*- 	    Price Matrix table is used instead of page allocation.*/
    DECLARE @Parts65Percent INT

    SELECT '@Parts65Percent = ' + CONVERT(VARCHAR,@Parts65Percent) + ' and catalogcode = ' + CONVERT(VARCHAR,@CatalogCode)

    SELECT @Parts65Percent = ROUND(SUM(cp.CourseParts) * 0.65,0)
    FROM
    (SELECT DISTINCT ii.CourseID,mc.CourseParts
    FROM Staging.MktPricingMatrix mpm,
        Staging.InvItem ii,
        Mapping.DMCourse mc
    WHERE mpm.UserstockItemID = ii.StockItemID
    AND ii.CourseID = mc.CourseID
    AND mpm.CatalogCode = @CatalogCode)cp

    SELECT '@Parts65Percent = ' + CONVERT(VARCHAR,@Parts65Percent) + ' and catalogcode = ' + CONVERT(VARCHAR,@CatalogCode)

    IF @Parts65Percent > 0 
    BEGIN
        DELETE FROM Staging.TempMailPull
        WHERE CustomerID IN 
        (
        	SELECT CustomerID
            FROM Marketing.DMPurchaseOrderItems
            WHERE 
            	CourseID IN 
                (
                    SELECT DISTINCT ii.CourseID
                    FROM Staging.MktPricingMatrix mpm, Staging.InvItem ii
                    WHERE 
                        mpm.UserstockItemID = ii.StockItemID
                        AND mpm.CatalogCode = @CatalogCode
                )
                AND TotalSales > 0
                AND StockItemID LIKE '[PD][AVCDMF]%'
                GROUP BY CustomerID
                HAVING SUM(Parts) > @Parts65Percent
        )
    END
    ELSE 
    BEGIN	
        SET @ErrorMsg = 'Please Make sure Price Matrix is updated for the CatalogCode ' + CONVERT(VARCHAR,@CatalogCode)
        RAISERROR(@ErrorMsg,15,1)
        /*RETURN*/
    END
    
    /*- STEP 4B: Delete rfm cells 84s and 85+s segments from magalog lists*/
    IF @MailPiece LIKE 'Magalog%'
       BEGIN
        DELETE FROM Staging.TempMailPull
        WHERE NewSeg BETWEEN 38 AND 39
       END
       
    delete tmp
    from Staging.TempMailPull tmp
    join Mapping.RFMforSubjBasedMails rsb (nolock) on 
    	tmp.CustomerSegment = rsb.CustomerSegment 
    	AND tmp.Frequency = rsb.Frequency 
        AND tmp.SubjRank = rsb.SubjRank
    where 
        rsb.FlagMail = 0
        AND rsb.MailPiece = @Mailpiece
       
end
GO
