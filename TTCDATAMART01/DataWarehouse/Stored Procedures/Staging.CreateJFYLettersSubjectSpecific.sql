SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[CreateJFYLettersSubjectSpecific]
    @AdCodeActive int = 0,
	@StartDate date = null,
    @StopDate date = null
AS
BEGIN
    set nocount on
    
    select distinct 
    	ccs.Customerid, 
        ccs.NewSeg, 
        ccs.Name, 
        ccs.a12mf, 
        ccs.ComboID, 
        ccs.Concatenated, 
        ccs.CustomerSegment, 
        ccs.FMPullDate, 
        ccs.Frequency, 
        ccs.EmailAddress, 
        ccs.FlagEmail, 
        ccs.FlagValidEmail, 
        @StartDate as StartDate,
        ccs.FlagEmailPref, 
        ccs.FlagValidRegionUS, 
        ccs.FlagInternational, 
        ccs.FlagMail, 
        ccs.CustomerSince, 
        ccs.PublicLibrary, 
        ccs.CG_Gender, 
        ccs.PreferredCategory2, 
        ccs.LTDPurchasesBin, 
        ccs.CRComboID, 
        ccs.NumHits, 
        ccs.AH, 
        ccs.EC, 
        ccs.FA, 
        ccs.HS, 
        ccs.LIT, 
        ccs.MH, 
        ccs.PH, 
        ccs.RL, 
        ccs.SC, 
        ccs.PreferredCategory,
        0 as FlagReceivedJFYBefore, 
        0 as JFYAdcode, 
        convert(varchar(50),'') as JFYAdcodeName, 
        0 as FlagJFYHoldout, 0 as JFYHoldoutAdcode,
        convert(varchar(50),'') as JFYHoldoutAdcodeName, 
        csm.Audio, 
        csm.Video, 
        csm.CD, 
        CSM.DVD, 
        CSM.DownLoads, 
        CSM.HSFormat,
        convert(varchar(50),'Others') CustGroup,
        0 FlagCDOnly, 
        0 FlagDVDOnly, 
        0 FlagMultiformat, 
        0 FlagMFCDPref, 
        0 FlagMFDVDPref,
        Convert(varchar(10),'') FormatPref, 
        convert(varchar(50),'') Version,
        @AdCodeActive as Adcode, 
        convert(varchar(50),'') as AdcodeName, 
        0 as CatalogCode,
        convert(varchar(50),'') as CatalogName,
        0 as FlagWebLTM18, 
        0 as FlagPhone, 
        0 as FlagHSOnly,
        convert(varchar(20),'') as FormatType,
        convert(varchar(3),'') as FlagRcvdJFY1_2010,
  		isnull(au.URLExtension, 'www.thegreatcourses.com/XXX') as URLExtension,
        isnull(au.OfferType, 'xxx') as OfferType,
        convert(varchar, @StopDate, 107) as ExpirationDate,
		convert(varchar, @StartDate, 107) as MailDate,
        cr.DSLPurchase,
        cr.Recency,
        cr.IntlAOS, 
        cr.IntlOrderSource,
        cr.IntlFormat,
        cr.IntlPromotionTypeID,
        ccs.CustomerSegmentNew,
        cd.TenureDays,
        cd.LTDPurchases,
        cd.R3FormatMediaPref,
        cd.TTB
    INTO Staging.TempMailPull
    from Marketing.campaigncustomersignature ccs (nolock)
    left outer join Marketing.customersubjectmatrix csm (nolock) on ccs.customerid = csm.customerid
    left join Mapping.AdCodeURL au (nolock) on au.AdCode = @AdCodeActive  
	left join Staging.vwCustomerRecency cr (nolock) on cr.CustomerID = ccs.CustomerID    
    left join Marketing.CustomerDynamicCourseRank cd on cd.CustomerID = ccs.CustomerID
    where ccs.CustomerSegment in ('Active','Swamp') and
           ccs.publiclibrary = 0
    and ccs.FlagValidRegionUS = 1
    and ccs.FlagMail = 1
    and ccs.buyertype > 3

    insert INTO Staging.TempMailPull
    select distinct 
    	ccs.Customerid, 
        ccs.NewSeg, 
        ccs.Name, 
        ccs.a12mf, 
        ccs.ComboID, 
        ccs.Concatenated, 
        ccs.CustomerSegment, 
        ccs.FMPullDate, 
        ccs.Frequency, 
        ccs.EmailAddress, 
        ccs.FlagEmail, 
        ccs.FlagValidEmail, 
        @StartDate as StartDate,
        ccs.FlagEmailPref, 
        ccs.FlagValidRegionUS, 
        ccs.FlagInternational, 
        ccs.FlagMail, 
        ccs.CustomerSince, 
        ccs.PublicLibrary, 
        ccs.CG_Gender, 
        ccs.PreferredCategory2, 
        ccs.LTDPurchasesBin, 
        ccs.CRComboID, 
        ccs.NumHits, 
        ccs.AH, 
        ccs.EC, 
        ccs.FA, 
        ccs.HS, 
        ccs.LIT, 
        ccs.MH, 
        ccs.PH, 
        ccs.RL, 
        ccs.SC, 
        ccs.PreferredCategory,
        0 as FlagReceivedJFYBefore, 0 as JFYAdcode, 
        convert(varchar(50),'') as JFYAdcodeName, 
        0 as FlagJFYHoldout, 0 as JFYHoldoutAdcode,
        convert(varchar(50),'') as JFYHoldoutAdcodeName, 
        0,
        0,
        0,
        0,
        0,
        0,
        convert(varchar(50),'Others') CustGroup,
        0 FlagCDOnly, 
        0 FlagDVDOnly, 
        0 FlagMultiformat, 
        0 FlagMFCDPref, 
        0 FlagMFDVDPref,
        Convert(varchar(10),'') FormatPref, convert(varchar(50),'') Version,
        @AdCodeActive as Adcode, 
        convert(varchar(50),'') as AdcodeName, 
        0 as CatalogCode,
        convert(varchar(50),'') as CatalogName,
        0 as FlagWebLTM18, 0 as FlagPhone, 
        0 as FlagHSOnly,
        convert(varchar(20),'') as FormatType,
        convert(varchar(3),'') as FlagRcvdJFY1_2010,
  		isnull(au.URLExtension, 'www.thegreatcourses.com/XXX') as URLExtension,
        isnull(au.OfferType, 'xxx') as OfferType,
        convert(varchar, @StopDate, 107) as ExpirationDate,
		convert(varchar, @StartDate, 107) as MailDate,
        cr.DSLPurchase,
        cr.Recency,
        cr.IntlAOS, 
        cr.IntlOrderSource,
        cr.IntlFormat,
        cr.IntlPromotionTypeID,
        ccs.CustomerSegmentNew,
        cd.TenureDays,
        cd.LTDPurchases,
        cd.R3FormatMediaPref,
        cd.TTB
    from marketing.campaigncustomersignature ccs (nolock)
    left join Mapping.AdCodeURL au (nolock) on au.AdCode = @AdCodeActive      
   	left join Staging.vwCustomerRecency cr (nolock) on cr.CustomerID = ccs.CustomerID    
    left join Marketing.CustomerDynamicCourseRank cd on cd.CustomerID = ccs.CustomerID
    where 
    	ccs.customersegment is null
        and ccs.comboid in ('NoRFM')
        and ccs.publiclibrary = 0
        and ccs.FlagValidRegionUS = 1
        and ccs.FlagMail = 1
        and ccs.buyertype > 3
    
    -- if they ever purchased on the web in the last 18 months, then they are web customers.
    UPDATE A
    SET A.FlagWebLTM18 = 1
    from Staging.TempMailPull a JOIN
          (select distinct customerid
          from marketing.dmpurchaseorders 
          where dateordered >= dateadd(month, - 18,getdate())
          and ordersource = 'W')b on a.customerid = b.customerid

    UPDATE Staging.TempMailPull
    set FlagPhone = 1 
    where FlagWebLTM18 = 0

    update Staging.TempMailPull
    set CustGroup = case when FlagEmail = 0 and FlagWebLTM18 = 1 then 'NonEmailable_Web'
                when FlagEmail = 0 and FlagWebLTM18 = 0 then 'NonEmailable_Phone'
                when FlagEmail = 1 and FlagWebLTM18 = 1 then 'Emailable_Web'
                when FlagEmail = 1 and FlagWebLTM18 = 0 then 'Emailable_Phone'
                else CustGroup
                end

    update Staging.TempMailPull 
    set Preferredcategory2 = 'SCI'
    where Preferredcategory2 like 'SC '
    
    -- update active adcodes

    update Staging.TempMailPull 
    set adcode = 47233
    where customersegment = 'Active'
    and custgroup in ('Emailable_Phone','NonEmailable_Phone','NonEmailable_Web')
    and FlagRcvdJFY1_2010 in (0,2,4)

    -- This is a Complement your collection letter. So, adcode by subject
    update Staging.TempMailPull 
    set adcode = case when preferredcategory2 = 'AH ' then 47233
                            when preferredcategory2 = 'LIT' then 47240
                            when preferredcategory2 = 'MH ' then 47234
                            when preferredcategory2 = 'MSC' then 47237
                            when preferredcategory2 = 'MTH' then 47238
                            when preferredcategory2 = 'PH ' then 47235
                            when preferredcategory2 = 'RL ' then 47236
                            when preferredcategory2 = 'EC ' then 47241
                            when preferredcategory2 = 'FW ' then 47241
                            when preferredcategory2 = 'HS ' then 47241
                            when preferredcategory2 is null then 47241
                            when preferredcategory2 = 'PR ' then 47241
                            when preferredcategory2 = 'SCI' then 47241
                            when preferredcategory2 = 'X  ' then 47241
                            when preferredcategory2 = 'VA ' then 47239
                            end
    where adcode = 47233

    -- If they received letter in June, then only top segments get it
    -- to keep the counts close to forecast

    update Staging.TempMailPull 
    set adcode = case when preferredcategory2 = 'AH ' then 47233
                            when preferredcategory2 = 'LIT' then 47240
                            when preferredcategory2 = 'MH ' then 47234
                            when preferredcategory2 = 'MSC' then 47237
                            when preferredcategory2 = 'MTH' then 47238
                            when preferredcategory2 = 'PH ' then 47235
                            when preferredcategory2 = 'RL ' then 47236
                            when preferredcategory2 = 'EC ' then 47241
                            when preferredcategory2 = 'FW ' then 47241
                            when preferredcategory2 = 'HS ' then 47241
                            when preferredcategory2 is null then 47241
                            when preferredcategory2 = 'PR ' then 47241
                            when preferredcategory2 = 'SCI' then 47241
                            when preferredcategory2 = 'X  ' then 47241
                            when preferredcategory2 = 'VA ' then 47239
                            end
    where adcode = 0
    and customersegment = 'Active'
    and custgroup in ('NonEmailable_Phone','NonEmailable_Web')
    and FlagRcvdJFY1_2010 in (6)
    and newseg between 2 and 5

END
GO
