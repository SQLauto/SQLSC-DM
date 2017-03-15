SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[CreateJFYLettersSimple]
    @AdCodeActive int = 0,
	@StartDate date = null,
    @StopDate date = null
AS
BEGIN
	set nocount on
	
	PRINT 'In the CreateJFYLettersSimple Procedure'
    
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
        0 as VideoDownloads,
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
  		isnull(au.URLExtension, 'www.thegreatcourses.com/XXX') as URLExtension,
        CONVERT(tinyint,0) as FlagWebPurchBfr,
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
    from Marketing.CampaignCustomerSignature ccs (nolock)
    left join Marketing.CustomerSubjectMatrix csm (nolock) on ccs.customerid = csm.customerid
    left join Mapping.AdCodeURL au on au.AdCode = @AdCodeActive
	left join Staging.vwCustomerRecency cr (nolock) on cr.CustomerID = ccs.CustomerID    
    left join Marketing.CustomerDynamicCourseRank cd on cd.CustomerID = ccs.CustomerID
    where ccs.CustomerSegment in ('Active', 'Inactive') and
         ccs.publiclibrary = 0
    and ccs.FlagValidRegionUS = 1
    and ccs.FlagMail = 1
    and ccs.buyertype > 3

    -- used for Actives
    -- if they ever purchased on the web in the last 18 months, then they are web customers.
    UPDATE A
    SET A.FlagWebLTM18 = 1
    from Staging.TempMailPull a JOIN
        (select distinct customerid
        from marketing.dmpurchaseorders --ccqdw.dbo.orders
        where dateordered >= dateadd(month, - 18,getdate())
        and ordersource = 'W')b on a.customerid = b.customerid

    UPDATE Staging.TempMailPull
    set FlagPhone = 1 
    where FlagWebLTM18 = 0
    and customersegment = 'Active'

    update Staging.TempMailPull
    set CustGroup = case when FlagEmail = 0 and FlagWebLTM18 = 1 then 'NonEmailable_Web'
            when FlagEmail = 0 and FlagWebLTM18 = 0 then 'NonEmailable_Phone'
            when FlagEmail = 1 and FlagWebLTM18 = 1 then 'Emailable_Web'
            when FlagEmail = 1 and FlagWebLTM18 = 0 then 'Emailable_Phone'
            else CustGroup
            end
    where customersegment = 'active'
    
    UPDATE A
    SET A.FlagWebPurchBfr = 1
    from Staging.TempMailPull a JOIN
          (select distinct customerid
          from marketing.dmpurchaseorders --ccqdw.dbo.orders
          where ordersource = 'W')b on a.customerid = b.customerid

    update Staging.TempMailPull
    set CustGroup = case when FlagEmail = 0 and FlagWebPurchBfr = 1 then 'NonEmailable_Web'
                when FlagEmail = 0 and FlagWebPurchBfr = 0 then 'NonEmailable_Phone'
                when FlagEmail = 1 and FlagWebPurchBfr = 1 then 'Emailable_Web'
                when FlagEmail = 1 and FlagWebPurchBfr = 0 then 'Emailable_Phone'
                else CustGroup
                end
    where customersegment = 'Inactive'
   		
END
GO
