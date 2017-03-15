SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*- Proc Name: 	rfm.dbo.CreateCatalogMailFile */
/*- Purpose:	This creates mail file for Catalog mailings */
/*- Input Parameters: @CatalogCode,@CatalogName,@DropDate,@PrimarySubject,@MaxSubjRank,*/
/*-		      @FnlTblName,@MailIPTbl,@AdcodeActive,@AdcodeSwamp,@AdcodeInq*/
/*- Tables Used: MarketingDM.dbo.ValidMailList*/
/*- Updates:*/
/*- Name		Date		Comments*/
/*- Preethi Ramanujam 	6/20/2007	New*/
/*-*/

CREATE PROC [Staging].[CreateCatalogMailFile]
 	@CatalogCode INT,
	@CatalogName VARCHAR(50),
	@MailPiece VARCHAR(50),
	@DropDate DATETIME,
	@PrimarySubject VARCHAR(5),
	@AdcodeActive INT,
	@AdcodeSwamp INT
AS
    DECLARE @ErrorMsg VARCHAR(400)   /*- Error message for error handling.*/
    DECLARE @RFMColumnName VARCHAR(50)
begin
    PRINT 'IN THE Catalog pull proc'

    PRINT '@DropDate = ' + CONVERT(VARCHAR,@DropDate,101)

    SELECT @RFMColumnName = CASE WHEN @PrimarySubject LIKE 'Jan%' THEN 'January'
                     WHEN @PrimarySubject LIKE 'Feb%' THEN 'February'
                     WHEN @PrimarySubject LIKE 'Mar%' THEN 'March'
                     WHEN @PrimarySubject LIKE 'Apr%' THEN 'April'
                     WHEN @PrimarySubject LIKE 'May%' THEN 'May'
                     WHEN @PrimarySubject LIKE 'Jun%' THEN 'June'
                     WHEN @PrimarySubject LIKE 'Jul%' THEN 'July'
                     WHEN @PrimarySubject LIKE 'Aug%' THEN 'August'
                     WHEN @PrimarySubject LIKE 'Sep%' THEN 'September'
                     WHEN @PrimarySubject LIKE 'Oct%' THEN 'October'
                     WHEN @PrimarySubject LIKE 'Nov%' THEN 'November'
                     WHEN @PrimarySubject LIKE 'Dec%' THEN 'December'
                     WHEN @PrimarySubject LIKE 'Hol1%' THEN 'Holiday1'
                     WHEN @PrimarySubject LIKE 'Hol2%' THEN 'Holiday2'
                     WHEN @PrimarySubject LIKE 'Hol3%' THEN 'Holiday3'
                     WHEN @PrimarySubject LIKE 'Xmas%' THEN 'Yulalog'
                     WHEN @PrimarySubject LIKE 'NC' THEN 'NewCourse'
                     ELSE 'DefaultList'
                END

    IF @RFMColumnName = 'DefaultList'
    BEGIN
        SET @ErrorMsg = 'WARNING: Catalog Name ' + @CatalogName + ' is not defined in RFMForCatalogs table. Using Default List to select RFM cells.'
        PRINT @ErrorMsg
    END
    
    SELECT 
        ccs.CustomerID,
        ccs.ComboID,
        ccs.BuyerType,
        CASE WHEN ccs.comboID = '0-6 Mo Inq' THEN 40
             WHEN ccs.ComboID = '7-24 Mo Inq' THEN 41
             WHEN ccs.ComboID = '25-10000 Mo Inq' THEN 42
             WHEN ccs.ComboID = 'HighSchool' THEN 43
             WHEN ccs.ComboID = 'NoRFM' THEN 44
             ELSE ccs.NewSeg
        END AS NewSeg,
        ccs.Name,
        ccs.a12mf,
        ccs.Concatenated,
        ccs.CustomerSegment,
        ccs.Frequency,
        ccs.FMPullDate, 
        @DropDate AS StartDate,
        ccs.Prefix,
        ccs.FirstName,
        ccs.MiddleName,
        ccs.LastName,
        ccs.Suffix, 
        ccs.CompanyName,
        ccs.Address1 + ' '  + ccs.Address2 as Address1,
        ccs.Address3 as Address2,
        ccs.City,
        ccs.State,
        ccs.PostalCode,
        CASE when ccs.PublicLibrary = 1 then 8888
        	WHEN ccs.CustomerSegment = 'Active' THEN @AdcodeActive
	        ELSE @AdcodeSwamp
        END AS Adcode,
        ccs.FlagMail,
        ISNULL(REPLACE(ccs.Gender,' ',''),'X') AS Gender,
        ccs.NumHits,
        CASE 
        	WHEN ccs.NumHits = 0 THEN '00-00'
            WHEN ccs.NumHits = 1 THEN '00-01'
            WHEN ccs.NumHits BETWEEN 2 AND 3 THEN '02-03'
            WHEN ccs.NumHits > 3 THEN '04-99'
        	ELSE 'XX-XX'
        END AS NumHitsCategory,
        ISNULL(ccs.PreferredCategory,'GEN') AS PreferredCategory,
        ISNULL(ccs.PreferredCategory2,'GEN') AS PreferredCategory2,
        CASE 
        	WHEN ccs.PreferredCategory IN
            	(
                	SELECT DISTINCT SubjCat 
                    FROM Mapping.CampnPageAllocation
                    WHERE 
                    	CatalogCode = @CatalogCode
                        AND SaleType = 'CatNew'
                ) THEN 'SM'
            ELSE 'XX'
        END AS SubjMatch,
        (CASE WHEN ccs.NumHits = 0 THEN '00-00'
             WHEN ccs.NumHits = 1 THEN '00-01'
             WHEN ccs.NumHits BETWEEN 2 AND 3 THEN '02-03'
             WHEN ccs.NumHits > 3 THEN '04-99'
             ELSE 'XX-XX'
        END + '-' + ISNULL(REPLACE(ccs.Gender,' ',''),'X') + '-' + 
        CASE WHEN ccs.PreferredCategory IN (SELECT DISTINCT SubjCat 
                            FROM Mapping.CampnPageAllocation
                            WHERE CatalogCode = @CatalogCode
                            AND SaleType = 'CatNew')
            THEN 'SM'
            ELSE 'XX'
        END) AS Score,
        ccs.CG_Gender,
        ccs.CustomerSince,
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
    into Staging.TempMailPull
    FROM Marketing.CampaignCustomerSignature ccs (nolock)
    JOIN Mapping.RFMForCatalogs rfc (nolock) ON rfc.ComboID = ccs.comboid
    left join Staging.vwCustomerRecency cr on ccs.CustomerID = cr.CustomerID
    left join Marketing.CustomerDynamicCourseRank cd on cd.CustomerID = ccs.CustomerID    
    WHERE 
       	ccs.BuyerType IN (4,5,1,3)
	    AND ccs.FlagMail = 1
	    AND ccs.FlagValidRegionUS = 1
    	AND ccs.PublicLibrary = 0  -- PR, 1/10/2013 -- Need to include PublicLibrary in main catalogs
    								-- PR, 9/5/2014 -- Need to remove PublicLirbrary from all catalogs as recorded books will be marketing to them
	    AND rfc.MailPiece = @MailPiece
		and 1 = 
        	CASE 
                WHEN @RFMColumnName = 'January' THEN rfc.January
                WHEN @RFMColumnName = 'February' THEN rfc.February
                WHEN @RFMColumnName = 'March' THEN rfc.March
                WHEN @RFMColumnName = 'April' THEN rfc.April
                WHEN @RFMColumnName = 'May' THEN rfc.May
                WHEN @RFMColumnName = 'June' THEN rfc.June                
                WHEN @RFMColumnName = 'July' THEN rfc.July
                WHEN @RFMColumnName = 'August' THEN rfc.August
                WHEN @RFMColumnName = 'September' THEN rfc.September                
                WHEN @RFMColumnName = 'October' THEN rfc.October                                
                WHEN @RFMColumnName = 'November' THEN rfc.November
                WHEN @RFMColumnName = 'December' THEN rfc.December                
                WHEN @RFMColumnName = 'Holiday1' THEN rfc.Holiday1
                WHEN @RFMColumnName = 'Holiday2' THEN rfc.Holiday2
                WHEN @RFMColumnName = 'Holiday3' THEN rfc.Holiday3
				WHEN @RFMColumnName = 'Holiday3' THEN rfc.Holiday3
				WHEN @RFMColumnName = 'Yulalog' THEN rfc.Yulalog                
				WHEN @RFMColumnName = 'NewCourse' THEN rfc.NewCourse                
                ELSE DefaultList
			END
                
end
GO
