SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Staging].[LoadCampaignCustomerSignature]
as
	declare @RFMDropDate datetime
	
  -- PR 8/19/2014 update overlay table to point to Web Decisions demographics table.
  	
begin
	set nocount on

    set @RFMDropDate = (select top 1 DropDate from Marketing.RFM_DATA_SPECIAL)
    
    if object_id('Staging.TempCampaignCustomerSignature') is not null drop table Staging.TempCampaignCustomerSignature
    select *
    into Staging.TempCampaignCustomerSignature
    from Marketing.CampaignCustomerSignature (nolock)
    where 1 = 0
    
    insert into Staging.TempCampaignCustomerSignature
    (
    	CustomerID,
        BuyerType, 
        CustomerSince,
        [Prefix],
        FirstName, 
        MiddleName, 
        LastName,
        Suffix,
        EmailAddress,
		FlagEmail,
        Address1,
        Address2,
        Address3,
        City,
        [State],
        PostalCode,
        Zip5,
        FlagValidRegionUS,
        FlagInternational,
        CountryCode,
        CountryName,
        EndDate,
        InqDate6Mo,
        InqDate7_12Mo,
        InqDate12_24Mo,
        FlagInq,
		FirstInq,        
        InqType,
        NewSeg,
		[Name],
        a12mf, 
        ComboID, 
        Concatenated, 
        CustomerSegment, 
        FMPullDate, 
        Frequency,
        AH,
        EC,
        FA,
        FW,
        HS,
        LIT,
        MH,
        MSC,
        MTH,
        PH,
        PR,
        RL,
        SC,
        SCI,
        VA,
        PreferredCategory,
        PreferredCategory2,
        Gender,
        NumHits,
        FirstUsedAdcode,
        PublicLibrary,
        OtherInstitution,
        LastOrderDate,
        Phone,
        Phone2,
        CompanyName,
        FlagValidEmail,
        FlagEmailPref,
        R3PurchWeb,
        FlagWebLTM18,
        FlagSharePref,			-- PR 1/16/2014 to include Flag OK to Share Preference
        FlagOkToShare			-- PR 1/16/2014 to include Flag OK to Share = 1 if ok to share and ok to mail
    )
    select 
    	c.CustomerID,
        c.BuyerType, 
        CustomerSince,
        c.[Prefix],
        Staging.Proper(c.FirstName),
        Staging.Proper(c.MiddleName),
        Staging.Proper(c.LastName),
        c.Suffix,
        c.Email,
		case 
        	when c.email like '%@%' then 1
		    else 0
		end as FlagEmail,
        c.Address1,
        c.Address2,
        c.Address3,
        c.City,
        c.[State],
        c.PostalCode,
        LEFT(c.PostalCode,5) AS Zip5,
        CASE 
	        WHEN isnull(c.CountryCode, 'US') = 'US' and isnull(vr.Region, '') <> '' THEN 1
		    ELSE 0
		END AS FlagValidRegionUS,
  		CASE 
        	WHEN isnull(c.CountryCode, 'US') <> 'US' and isnull(vr.Region, '') = '' THEN 1
            else 0
		END AS FlagInternational,
        c.CountryCode,
        ct.CountryName,
		GETDATE() AS EndDate,
		DATEADD(mm, -6, CONVERT(DATETIME,FLOOR(CONVERT(FLOAT,GETDATE())))) AS InqDate6Mo,
		DATEADD(mm, -12, CONVERT(DATETIME,FLOOR(CONVERT(FLOAT,GETDATE())))) AS InqDate7_12Mo,
		DATEADD(mm, -24, CONVERT(DATETIME,FLOOR(CONVERT(FLOAT,GETDATE())))) AS InqDate12_24Mo,
		CASE 
        	WHEN c.BuyerType = 1 THEN 1
		    ELSE 0
		END AS FlagInq,
		CASE 
        	WHEN c.BuyerType = 1 THEN 1
		    ELSE 0
		END AS FirstInq,
		CASE 
        	WHEN c.BuyerType > 1 THEN 'NonInq'
		END AS InqType,
		csm.NewSeg,
        csm.[Name],
        rfm.a12mF,
   		CASE 
        	WHEN c.BuyerType > 3 THEN (ISNULL(CONVERT(VARCHAR, csm.NewSeg),'NoRFM') + ISNULL(csm.Name,'') + ISNULL(CONVERT(VARCHAR, rfm.A12mf),'')) 
			WHEN c.BuyerType = 3 THEN 'HighSchool'
		    WHEN c.BuyerType = 1 THEN 'Inq'
			ELSE 'Inq'
		END AS ComboID,
        rfm.Concatenated,
        CASE 
        	WHEN csm.Active = 1 THEN 'Active'
		    ELSE 'Inactive'
	    END as CustomerSegment,
        @RFMDropDate as FMPullDate,
        rfm.Frequency,
		isnull(csm.AH, 0) AH,
        isnull(csm.EC, 0) EC,
        isnull(csm.FA, 0) FA,
        isnull(csm.FW, 0) FW,
        isnull(csm.HS, 0) HS,
        isnull(csm.LIT, 0) LIT,
        isnull(csm.MH, 0) MH,
        isnull(csm.MSC, 0) MSC,
        isnull(csm.MTH, 0) MTH,
        isnull(csm.PH, 0) PH,
        isnull(csm.PR, 0) PR,
        isnull(csm.RL, 0) RL,
        isnull(csm.SC, 0) SC,
        isnull(csm.SCI, 0) SCI,
        isnull(csm.VA, 0) VA,
		csm.PreferredCategory,
		csm.PreferredCategory2,
		-- mpi.Gender, -- PR 8/19/14 changed to get data from WD overlay table
		'U' as Gender,
        mpi.NumHits,
        c.FirstUsedAdCode,
        case c.CustGroup
        	when 'Library' then 1
            else 0
        end as PublicLibrary,
        case c.CustGroup
        	when 'Organize' then 1
            else 0
        end as OtherInstitution,
        d.LastOrderDate,
        c.Phone,
        c.Phone2,
        c.CompanyName,
        1 FlagValidEmail,
        1 FlagEmailPref,
        0 R3PurchWeb,
        0 FlagWebLTM18,
        0 FlagSharePref,			-- PR 1/16/2014 to include Flag OK to Share Preference
        0 FlagOkToShare				-- PR 1/16/2014 to include Flag OK to Share = 1 if ok to share and ok to mail
    from Staging.Customers c (nolock) 
    left join Mapping.RFMlkValidRegion vr (nolock) on vr.Region = c.[State]
    left join Mapping.SHPlkCountry ct (nolock) on c.CountryCode = ct.CountryCode
    left join Marketing.CustomerSubjectMatrix csm (nolock) on csm.CustomerID = c.CustomerID
    left join Marketing.RFM_DATA_SPECIAL rfm (nolock) on rfm.CustomerID = c.CustomerID
    left join Mapping.DMMPInput mpi (nolock) on mpi.CustomerID = c.CustomerID
    left join Staging.vwCustomerLastOrderDate d on d.CustomerID = c.CustomerID
    where isnull(c.RootCustomerID, '') = ''
    
	/* Add remaining customers    */
    INSERT INTO Staging.TempCampaignCustomerSignature
    (
        Customerid, 
        NewSeg, 
        [Name], 
        a12mf, 
        ComboID, 
        Concatenated, 
        CustomerSegment, 
        FMPullDate, 
        Frequency, 
        [Prefix], 
        FirstName, 
        MiddleName, 
        LastName, 
        Suffix, 
        EmailAddress, 
        FlagEmail, 
        FirstUsedAdcode, 
        BuyerType, 
        CustomerSince, 
        EndDate, 
        InqDate6Mo, 
        InqDate7_12Mo, 
        InqDate12_24Mo, 
        FlagInq, 
        InqType, 
        FirstInq, 
        Gender, 
        NumHits, 
        CG_Gender, 
        PreferredCategory2, 
        LTDPurchasesBin, 
        CRComboID, 
        AH,
        EC,
        FA,
        FW,
        HS,
        LIT,
        MH,
        MSC,
        MTH,
        PH,
        PR,
        RL,
        SC,
        SCI,
        VA,
        PreferredCategory,
        PublicLibrary,
        OtherInstitution,
        LastOrderDate,
        Phone,
        Phone2,
        CompanyName,
        FlagValidEmail,
        FlagEmailPref,
        R3PurchWeb,
        FlagWebLTM18,
        FlagSharePref,			-- PR 1/16/2014 to include Flag OK to Share Preference
        FlagOkToShare			-- PR 1/16/2014 to include Flag OK to Share = 1 if ok to share and ok to mail
    )
    SELECT 
        c.CustomerID,
        csm.NewSeg, 
        csm.[Name], 
        csm.A12mf,
        CASE WHEN c.BuyerType > 3 THEN (ISNULL(CONVERT(VARCHAR,csm.NewSeg),'NoRFM') + ISNULL(csm.Name,'') + ISNULL(CONVERT(VARCHAR,csm.A12mf),'')) 
            WHEN c.BuyerType = 3 THEN 'HighSchool'
            WHEN c.BuyerType = 1 THEN 'Inq'
            ELSE 'Inq'
        END AS ComboID,
        rds.Concatenated,
        CASE WHEN csm.Active=1 THEN 'Active'
            WHEN csm.Active = 0 THEN 'Inactive'
            ELSE 'Inq'
        END CustomerSegment,
        @RFMDropDate AS FMPullDate,
        rds.Frequency,
        ISNULL(C.Prefix,'')Prefix, 
        Staging.Proper(C.FirstName), 
        Staging.Proper(ISNULL(C.MiddleName,0)) MiddleName,
        Staging.Proper(C.LastName), 
        ISNULL(C.Suffix,'') Suffix, 
        ISNULL(C.Email,'') EmailAddress, 
        CASE WHEN c.email LIKE '%@%' THEN 1		     
            ELSE 0
            END AS FlagEmail,
        C.FirstUsedAdcode,
        C.BuyerType, 
        C.CustomerSince,
        GETDATE() AS EndDate,
        DATEADD(mm, -6, CONVERT(DATETIME,FLOOR(CONVERT(FLOAT,GETDATE())))) AS InqDate6Mo,
        DATEADD(mm, -12, CONVERT(DATETIME,FLOOR(CONVERT(FLOAT,GETDATE())))) AS InqDate7_12Mo,
        DATEADD(mm, -24, CONVERT(DATETIME,FLOOR(CONVERT(FLOAT,GETDATE())))) AS InqDate12_24Mo,
        CASE WHEN c.BuyerType = 1 THEN 1
             ELSE 0
             END AS FlagInq,
        CASE WHEN c.BuyerType > 1 THEN 'NonInq'
             END AS InqType,
        CASE WHEN c.BuyerType = 1 THEN 1
             ELSE 0
             END AS FirstInq,
        mpip.Gender,
        mpip.NumHits,
        CCR.Gender AS CG_Gender,
        CCR.SecondarySubjPref AS PreferredCategory2,
        CCR.LTDPurchasesBin,
        CCR.CRComboID, 
		isnull(csm.AH, 0) AH,
        isnull(csm.EC, 0) EC,
        isnull(csm.FA, 0) FA,
        isnull(csm.FW, 0) FW,
        isnull(csm.HS, 0) HS,
        isnull(csm.LIT, 0) LIT,
        isnull(csm.MH, 0) MH,
        isnull(csm.MSC, 0) MSC,
        isnull(csm.MTH, 0) MTH,
        isnull(csm.PH, 0) PH,
        isnull(csm.PR, 0) PR,
        isnull(csm.RL, 0) RL,
        isnull(csm.SC, 0) SC,
        isnull(csm.SCI, 0) SCI,
        isnull(csm.VA, 0) VA,
        CSM.PreferredCategory,
        case c.CustGroup
        	when 'Library' then 1
            else 0
        end as PublicLibrary,
        case c.CustGroup
        	when 'Organize' then 1
            else 0
        end as OtherInstitution,
        d.LastOrderDate,
        c.Phone,
        c.Phone2,
        c.CompanyName,
        1  FlagValidEmail,
        1 FlagEmailPref,
        0 R3PurchWeb,
        0 FlagWebLTM18,
        0 FlagSharePref,		-- PR 1/16/2014 to include Flag OK to Share Preference
        0 FlagOkToShare			-- PR 1/16/2014 to include Flag OK to Share = 1 if ok to share and ok to mail
    FROM Staging.Customers C LEFT OUTER JOIN
        Staging.TempCampaignCustomerSignature CCS ON CCS.CustomerID = C.CustomerID LEFT OUTER JOIN
        Marketing.customerSubjectMatrix CSM ON C.customerID = csm.CustomerID left outer join
        Marketing.rfm_data_special RDS ON C.CustomerID = RDS.CustomerID left outer join
        Mapping.DMMPInput mpip ON mpip.CustomerID = c.CustomerID left outer join
        Marketing.CustomerDynamicCourseRank CCR ON C.CustomerID = CCR.CustomerID
        left join Staging.vwCustomerLastOrderDate d on d.CustomerID = c.CustomerID
    WHERE 
    	CCS.CustomerID IS NULL
		and isnull(c.RootCustomerID, '') = ''
    
    /*- Update rfm information for customers who are in rds, but not in csm table. -- PR Added this on 9/27/2007*/
    UPDATE TCCS
    SET TCCS.NewSeg = RI.NewSeg,
        TCCS.Name = RN.Name,
        TCCS.ComboID = CONVERT(VARCHAR,RI.NewSeg) + RN.Name + CONVERT(VARCHAR,TCCS.A12mf),
        TCCS.CustomerSegment = 	CASE 	WHEN RI.NewSeg BETWEEN 1 AND 10 THEN 'Active'
                        WHEN RI.NewSeg BETWEEN 13 AND 15 THEN 'Active'
                        ELSE 'Inactive'
                    END
    FROM Staging.TempCampaignCustomerSignature TCCS 
    JOIN Mapping.RFMInfo RI (nolock) ON TCCS.Concatenated = ri.Concatenated
    JOIN Mapping.rfmnewsegs RN (nolock) ON Ri.NewSeg = rn.NewSeg
    WHERE 
        TCCS.comboid  LIKE 'NoRFM%' 
        AND TCCS.newseg IS NULL 
        AND TCCS.a12mf IS NOT NULL
        
    /*-- Update FlagValidEmail column*/
    UPDATE tccs
    SET 
        FlagValidEmail = 0,
        tccs.FlagEmail = 0
    FROM Staging.TempCampaignCustomerSignature tccs 
    JOIN Legacy.InvalidEmails IE (nolock) ON tccs.CustomerID = IE.CustomerID

    UPDATE tccs
    SET 
        FlagValidEmail = 0,
        tccs.FlagEmail = 0
    FROM Staging.TempCampaignCustomerSignature tccs 
    JOIN Legacy.InvalidEmails IE (nolock) ON tccs.EmailAddress = IE.EmailAddress

	/*-- Update FlagEmail and FlagMail columns.        */
	/* Note EPC Email preferene updates prefrence later in SP_Load_epc_preference*/
    UPDATE ccs
    SET FlagEmail = 0,
        FlagEmailPref = 0
    FROM Staging.TempCampaignCustomerSignature ccs
    left JOIN 
    (
        select CustomerID
        from Staging.AccountPreferences ap (nolock) 
        WHERE ap.preferenceid = 'OFFEREMAIL'
    ) ap on ccs.CustomerID = ap.CustomerID
    where ap.CustomerID is null

    update ccs
    set ccs.FlagMailPref =
    case
    	when ap.CustomerID is null then 0
        else 1
    end
    from Staging.TempCampaignCustomerSignature ccs
    left join 
    (
        select CustomerID
        from Staging.AccountPreferences ap (nolock) 
        where ap.PreferenceID = 'OFFERMAIL'
    ) ap on ccs.CustomerID = ap.CustomerID

	/*  FlagSharePref,			-- PR 1/16/2014 to include Flag OK to Share Preference
        FlagOkToShare			-- PR 1/16/2014 to include Flag OK to Share = 1 if ok to share and ok to mail
        */
    update ccs
    set ccs.FlagSharePref =
    case
    	when ap.CustomerID is null then 0
        else 1
    end
    from Staging.TempCampaignCustomerSignature ccs
    left join 
    (
        select CustomerID
        from Staging.AccountPreferences ap (nolock) 
        where ap.PreferenceID = 'OKToShare'
    ) ap on ccs.CustomerID = ap.CustomerID
    
    update Staging.TempCampaignCustomerSignature
    set FlagOkToShare = 1
    where FlagSharePref = 1
    and FlagMailPref = 1
    and CountryCode in ('US','CA')
    
    update ccs
    set ccs.FlagNonBlankMailAddress = 
    case
    	when isnull(Address1, '') = '' and isnull(Address2, '') = '' then 0
        else 1
    end
    from Staging.TempCampaignCustomerSignature ccs
    
    update ccs
    set ccs.FlagMail = ccs.FlagMailPref & ccs.FlagNonBlankMailAddress
	from Staging.TempCampaignCustomerSignature ccs	    
    
	/* Update Inquirer Type    */
    UPDATE tccs
    SET tccs.InqType = ccs.InqType,
        tccs.CustomerSegment = ccs.CustomerSegment,
        tccs.ComboID = ccs.ComboID,
        tccs.CustomerSegment2 = ccs.CustomerSegment
    FROM Staging.TempCampaignCustomerSignature tccs JOIN
        (SELECT 
        Customerid,CustomerSince,
        CASE WHEN CustomerSince BETWEEN InqDate6Mo AND GETDATE() THEN '0-6 Mo Inq'
            WHEN CustomerSince BETWEEN InqDate12_24Mo AND InqDate6Mo THEN '7-24 Mo Inq'
            WHEN CustomerSince < InqDate12_24Mo THEN '25-10000 Mo Inq'
            ELSE 'Inq Other'
        END AS InqType,
        CASE WHEN CustomerSince BETWEEN InqDate6Mo AND GETDATE() THEN '0-6 Mo Inq'
            WHEN CustomerSince BETWEEN InqDate12_24Mo AND InqDate6Mo THEN '7-24 Mo Inq'
            WHEN CustomerSince < InqDate12_24Mo THEN '25-10000 Mo Inq'
            ELSE 'Inq Other'
        END AS CustomerSegment,
        CASE WHEN CustomerSince BETWEEN InqDate6Mo AND GETDATE() THEN '0-6 Mo Inq'
            WHEN CustomerSince BETWEEN InqDate12_24Mo AND InqDate6Mo THEN '7-24 Mo Inq'
            WHEN CustomerSince < InqDate12_24Mo AND NumHits > 0 THEN '25-10000 Mo Inq'
            WHEN CustomerSince BETWEEN (DATEADD(mm,-60,getdate())-1) AND InqDate12_24Mo  AND NumHits = 0 THEN '25-10000 Mo Inq'
            ELSE '25-10000 Mo Inq Plus'
            END AS ComboID
        FROM Staging.TempCampaignCustomerSignature (nolock)
        WHERE FlagInq = 1) ccs
        ON tccs.Customerid = ccs.Customerid
        
    /* Update First Inquirer Information.        */
    UPDATE tccs
    SET FirstInq = 1
    FROM staging.TempCampaignCustomerSignature tccs 
    JOIN Staging.Customers c (nolock) ON tccs.Customerid = c.Customerid
    WHERE c.FirstUsedAdcode IN (10094,22962)
    
    /*-- Get other First Inquirers based on their first Purchase*/
    UPDATE tccs
    SET FirstInq = 1
    FROM Staging.TempCampaignCustomerSignature tccs JOIN
        (SELECT o.CustomerID,o.OrderID,o.NetOrderAmount,oi.stockitemid,ii.ItemCategoryID
        FROM Staging.vwOrders o JOIN
            (SELECT MIN(OrderID) AS OrderID
            FROM Staging.vwOrders
            GROUP BY CustomerID)MinOrder ON o.orderid = MinOrder.Orderid
            JOIN Staging.vwOrderItems oi ON 
                            o.OrderID = OI.OrderID
                            AND OI.OrderID = MinOrder.OrderID
            JOIN Staging.InvItem ii ON oi.StockItemID = ii.StockItemID
        WHERE o.NetOrderAmount = 0
        AND ii.ItemCategoryID LIKE 'Catalog%')FirstOrder
    ON tccs.Customerid = FirstOrder.Customerid
    
   	/*- ADD DRTV Inquirers and their preferred categories based on their FirstUsedAdcode*/
    UPDATE tccs
    SET DRTVInq = 1,
        PreferredCategory = da.PreferredCategory
    FROM Staging.TempCampaignCustomerSignature tccs JOIN
        Mapping.DrtvAdcodes da ON tccs.firstUsedAdcode = da.adcode
        
    /* update First and Last Names to 'Lifelong' 'Learner' for institutions.*/
    UPDATE Staging.TempCampaignCustomerSignature
    SET 
        FirstName = 'LifeLong',
        LastName = 'Learner'
    WHERE 
        UPPER(FirstName) LIKE 'ACCOUNT%'
        OR UPPER(FirstName) LIKE 'ACQUISI%'
        OR UPPER(FirstName) LIKE 'KNOW'
        OR UPPER(FirstName) LIKE 'PAYABLE%'
        OR UPPER(LastName) LIKE 'ACCOUNT%'
        OR UPPER(LastName) LIKE 'ACQUISI%'
        OR UPPER(LastName) LIKE 'KNOW'
        OR UPPER(LastName) LIKE 'PAYABLE%'
        
    /* Update LTDPurhcasesBin, CG_Gender and PreferredCategory2 and CRComboID*/
    UPDATE TCCS
    SET 
        TCCS.PreferredCategory2 = CCR.SubjectPref,
        TCCS.LTDPurchasesBin = CCR.LTDPurchasesBin,
        TCCS.CRComboID = CCR.CRComboID,
        tccs.SecondarySubjPref = ccr.SecondarySubjPref
    FROM Staging.TempCampaignCustomerSignature TCCS 
    JOIN Marketing.CustomerDynamicCourseRank CCR (nolock) ON TCCS.CustomerID = CCR.CustomerID
  
  -- PR 8/19/2014 update overlay table to point to Web Decisions demographics table.
  
      update ccs
    set 
    	ccs.Gender = isnull(left(co.Gender,1), 'X'),
		ccs.CG_Gender = isnull(left(co.Gender,1), 'X')
    FROM Staging.TempCampaignCustomerSignature ccs 
    join Mapping.CustomerOverlay_WD co (nolock) on co.CustomerID = ccs.CustomerID
      
  --  update ccs
  --  set 
  --  	ccs.Gender = isnull(co.Gender, 'X'),
		--ccs.CG_Gender = isnull(co.Gender, 'X')
  --  FROM Staging.TempCampaignCustomerSignature ccs 
  --  join Mapping.CustomerOverLay co (nolock) on co.CustomerID = ccs.CustomerID
        
    /* Update R3PurchWeb flag*/
    UPDATE TCCS
    SET TCCS.R3PurchWeb = 1
    FROM Staging.TempCampaignCustomerSignature TCCS JOIN
        (SELECT Distinct O.CustomerID
        from Marketing.DMPurchaseOrders O join
            (select CustomerID, max(sequenceNum) sequenceNum
            from Marketing.DMPurchaseOrders
            group by customerid
            union
            select CustomerID, max(sequenceNum)-1 sequenceNum
            from Marketing.DMPurchaseOrders
            group by customerid
            having max(sequenceNum) > 1
            union
            select CustomerID, max(sequenceNum)-2 sequenceNum
            from Marketing.DMPurchaseOrders
            group by customerid
            having max(sequenceNum) > 2)b on O.CustomerID = b.customerID and o.sequenceNum = b.sequenceNum
        where O.OrderSource = 'W')b on TCCS.customerid = b.customerid
    
    /* Update Correct CountryCode*/
    UPDATE TCCS
    SET TCCS.CountryCode = REPLACE(B.CountryCodeCorrect,' ','')
    FROM Staging.TempCampaignCustomerSignature TCCS JOIN
        Mapping.CountryCodeCorrection B ON TCCS.CountryCode = B.CountryCode

    update Staging.TempCampaignCustomerSignature
    set CountryCode = 'XX'
    where isnull(countrycode,'') = ''
        
    /* Remove any carriage returns in the address field*/
    UPDATE Staging.TempCampaignCustomerSignature
       SET address1 = replace(replace(ISNULL(address1,''),char(13),''),char(10),''),
            address2 = replace(replace(ISNULL(address2,''),char(13),''),char(10),''),
            address3 = replace(replace(ISNULL(address3,''),char(13),''),char(10),''),            
            firstName = replace(replace(ISNULL(FirstName,''),char(13),''),char(10),''),
            LastName = replace(replace(ISNULL(LastName,''),char(13),''),char(10),''),
            city = replace(replace(ISNULL(city,''),char(13),''),char(10),''),            
            state = replace(replace(ISNULL(state,''),char(13),''),char(10),''),
            PostalCode = replace(replace(ISNULL(PostalCode,''),char(13),''),char(10),''),
            CompanyName = replace(replace(ISNULL(CompanyName,''),char(13),''),char(10),'')
            
    /* Replace commas with spaces*/
    UPDATE Staging.TempCampaignCustomerSignature
       SET address1 = replace(address1,',',' '),
            address2 = replace(address2,',',' '),
            address3 = replace(address3,',',' '),
            firstName = replace(FirstName,',',' '),
            LastName = replace(LastName,',',' '),
            City = replace(City,',',' '),
            state = replace(state,',',' '),
            PostalCode = replace(PostalCode,',',' '),
            CompanyName = replace(CompanyName,',',' ')
            
    /* Replace pipes with dashes*/
    -- PR 1/19/2013 - to avoid issues with mail files which are sent to vendors
    -- as pipe separated text files.
    UPDATE Staging.TempCampaignCustomerSignature
       SET address1 = replace(address1,'|','-'),
            address2 = replace(address2,'|','-'),
            address3 = replace(address3,'|','-'),
            firstName = replace(FirstName,'|','-'),
            LastName = replace(LastName,'|','-'),
            City = replace(City,'|',' '),
            state = replace(state,'|',' '),
            PostalCode = replace(PostalCode,'|',' ') ,
            CompanyName = replace(CompanyName,'|',' ') 
                       
    /* Preethi Ramanujam - 5/5/2011*/
    /* Update Customer Overlay data like Age, Income and Education*/
    -- update from Web Decisions Table - 8/19/2014 - PR
    UPDATE a
    SET a.DateOfBirth = b.DateOfBirth,
        a.Age = DATEDIFF(month,b.DateOfBirth,getdate())/12,
        a.HouseHoldIncomeRange = IsNull(b.IncomeDescription,'NoInfo'),
       -- a.HouseHoldIncomeBin = 	case when b.IncomeDescription in ('1: $0-$14,999','2: $15,000 - $19,999',
							--							'3: $20,000 - $29,999','4: $30,000 - $39,999',
							--							'5: $40,000 - $49,999') then 'LessThan$50K'
							--	when b.IncomeDescription in ('6: $50,000 - $74,999') then '$50K-$74K'
							--	when b.IncomeDescription in ('7: $75,000 - $99,999','8: $100,000 - $124,999') then '$75K-$124K'
							--	when b.IncomeDescription in ('9: $125,000 - $149,999','10: $150,000 - $174,999',
							--									'11: $175,000 - $199,999','12: $200,000 - $249,000',
							--									'13: $250,000+') 
							--					then '$125k+'
							--	else 'NoInfo'
							--End,
							/*Bin Changes vik 20160511*/
		a.AgeBin	= 			CASE WHEN (DATEDIFF(month,b.DateOfBirth,getdate())/12) <= 34  then '1: < 35'
										WHEN (DATEDIFF(month,b.DateOfBirth,getdate())/12) between 35 and 44 then '2: 35-44'
										WHEN (DATEDIFF(month,b.DateOfBirth,getdate())/12) between 45 and 54 then '3: 45-54'
										WHEN (DATEDIFF(month,b.DateOfBirth,getdate())/12) between 55 and 64 then '4: 55-64'
										WHEN (DATEDIFF(month,b.DateOfBirth,getdate())/12) between 65 and 74 then '5: 65-74'
										WHEN (DATEDIFF(month,b.DateOfBirth,getdate())/12) >= 75 then '6: >= 75'
										When b.Customerid is not null and b.DateOfBirth  is NULL then '7: No Overlay Available' 
										ELSE '8: Unknown'
									END , 	
		a.HouseHoldIncomeBin =		Case when b.IncomeDescription in ('1: $0-$14,999','2: $15,000 - $19,999',
                                                            '3: $20,000 - $29,999','4: $30,000 - $39,999',
                                                            '5: $40,000 - $49,999')
																then '1: < $50,000'
										when b.IncomeDescription in ('6: $50,000 - $74,999') 
																then '2: $50,000 - $74,999'
										when b.IncomeDescription in ('7: $75,000 - $99,999') 
																then '3: $75,000 - $99,999'
										when b.IncomeDescription in ('8: $100,000 - $124,999','9: $125,000 - $149,999') 
																then '4: $100,000 - $149,999'
										when b.IncomeDescription in ('10: $150,000 - $174,999','11: $175,000 - $199,999','12: $200,000 - $249,000',
																				'13: $250,000+') 
																then '5: >= $150,000'
										When b.Customerid is not null 
																then  '6: No Overlay Available'
										else '7: Unknown'
									  End ,
		a.EducationBin		=		Case  when b.Education in ('3: Some College')  then '2: Some College'
											when b.Education in ('4: College')            then '3: College'          
											when b.Education in ('5: Graduate School') then '4: Graduate Degree'
											when b.Education in ('1: Some High School or Less','2: High School') then '1: High School or Less'
											when b.Customerid is not null then '5: No Overlay Available'
											else '6: Unknown'
										  End ,
        a.Education = isnull(b.Education,'NoInfo'),
        a.EducationConfidence = 'NoInfo',
		a.NetWorth = isnull(b.NetWorth,'NoInfo'),
		a.PresenceOfChildren = isnull(b.PresenceOfChildren,'NoInfo'),
		a.MailOrderBuyer = b.MailOrderBuyer
    FROM Staging.TempCampaignCustomerSignature a left outer join
        Mapping.CustomerOverlay_WD b on a.customerid = b.customerid
        
        
    --UPDATE a
    --SET a.DateOfBirth = b.DateOfBirth,
    --    a.Age = DATEDIFF(month,b.DateOfBirth,getdate())/12,
    --    a.HouseHoldIncomeRange = IsNull(b.HouseHoldIncomeRange,'NoInfo'),
    --    a.HouseHoldIncomeBin = isnull(b.HouseHoldIncomeBin,'NoInfo'),
    --    a.Education = isnull(b.Education,'NoInfo'),
    --    a.EducationConfidence = isnull(b.EducationConfidence,'NoInfo')	
    --FROM Staging.TempCampaignCustomerSignature a left outer join
    --    Mapping.CustomerOverlay b on a.customerid = b.customerid
        
     -- PR 4/29/2016  -- changed the bins to updated bins to keep it consistent   
    --UPDATE Staging.TempCampaignCustomerSignature
    --SET AgeBin = CASE WHEN Age < 35 then '34-'
    --                WHEN Age between 35 and 44 then '35-44'
    --                WHEN Age between 45 and 54 then '45-54'
    --                WHEN Age between 55 and 64 then '55-64'
    --                WHEN Age between 65 and 79 then '65-79'
    --                WHEN Age >= 80 then '80+'
    --                ELSE ''
    --                END

	/*Bin Changes vik 20160511*/
	/*
    UPDATE Staging.TempCampaignCustomerSignature
    SET AgeBin = CASE when Age <= 34 then '1: < 35'
					when Age between 35 and 44 then '2: 35-44'
					when Age between 45 and 54 then '3: 45-54'
					when Age between 55 and 64 then '4: 55-64'
					when Age between 65 and 74 then '5: 65-74'
					when Age >= 75 then '6: >= 75'
					else '7: Unknown'
                    END
*/
	update ccs
	set ccs.OrderSourcePreference = p.OrderSource
    from Staging.TempCampaignCustomerSignature ccs
    join Staging.vwCustomerOrderSourcePreferences (nolock) p on p.CustomerID = ccs.CustomerID
	where 
    	p.RankNum = 1

	update ccs
	set ccs.MediaFormatPreference = cp.FormatMedia
    from Staging.TempCampaignCustomerSignature ccs
    join Staging.vwCustomerFormatMediaPreferences cp (nolock) on cp.CustomerID = ccs.CustomerID
	where 
    	cp.RankNum = 1
        
    -- Update FlagWebLTM18
    UPDATE TCCS
    SET TCCS.FlagWebLTM18 = 1
    FROM Staging.TempCampaignCustomerSignature TCCS JOIN
          (SELECT DISTINCT customerid
          FROM Staging.vworders (nolock)
          WHERE dateordered >= DATEADD(MONTH, - 18,GETDATE())
          AND ordersource = 'W')Web on TCCS.customerid = Web.customerid
	
    begin -- Customer Segmentation	
    
/* -- PR 3/10/2014 -- apply new model for new customer segments    
        update ccs
        set ccs.CustomerSegmentNew = 'NearInactives'
        from Staging.TempCampaignCustomerSignature ccs
        join Staging.vwCustomerRecency cr (nolock) on ccs.CustomerID = cr.CustomerID
        where 
            ccs.newseg in (6, 7, 13, 14, 15) /*or
            (ccs.newseg in (8, 9, 10) and cr.recency in (10, 11, 12))*/ -- PR - 2/19/2013. Based on 
															-- Ashit's request, moving 12 month multis
															-- back to Actives group.


        update ccs
        set ccs.CustomerSegmentNew = 'NewCustLowValue'
        from Staging.TempCampaignCustomerSignature ccs
        join Staging.vwCustomerRecency cr (nolock) on ccs.CustomerID = cr.CustomerID
        where 
            (cr.IntlOrderSource not in ('P', 'W', 'D') and ccs.ComboID = '16sL0' and cr.IntlPromotionTypeID IN (126, 127, 129, 124, 558, 2650, 2651, 2652, 2653)) 
            or (cr.IntlAOS <= 75 and cr.IntlOrderSource in ('P', 'W', 'D') and ccs.comboid in ('16sL0') and cr.IntlFormat in ('D', 'H') and cr.IntlPromotionTypeID IN (126,127,129,124,558, 2650, 2651, 2652, 2653)) 
            or (intlAOS <= 150 and IntlOrderSource in ('P','W','D') and comboid in ('16sL0') and IntlFormat in ('M', 'C') and IntlPromotionTypeID IN (126,127,129,124,558, 2650, 2651, 2652, 2653))
            or (IntlOrderSource in ('P','W','D') and comboid in ('16sL0') and isnull(IntlFormat,'V') not in ('D', 'H','C','M') and IntlPromotionTypeID IN (126,127,129,124,558, 2650, 2651, 2652, 2653))

		update ccs
        set ccs.CustomerSegmentNew = 'DeepSwamp'
        from Staging.TempCampaignCustomerSignature ccs    
        where newseg in (21,22,26,27,29,30,31,32,33,34,35,36,37,38,39)
        
        */

		-- Add New customer segments 
		update a
		set a.CustomerSegment2 = b.CustomerSegment2,
			a.CustomerSegmentFnl = b.CustomerSegmentFnl
		from Staging.TempCampaignCustomerSignature a join
			(select distinct NewSeg, Name, A12mf, CustomerSegment2, CustomerSegmentFnl from Mapping.RFMComboLookup
			where name is not null)b on a.NewSeg = b.NewSeg
										and a.Name = b.Name
										and a.a12mf = b.A12mf

		update a
		set a.CustomerSegment2 = b.CustomerSegment2,
			a.CustomerSegmentFnl = b.CustomerSegmentFnl
		from Staging.TempCampaignCustomerSignature a join
			(select distinct ComboID, CustomerSegment2, CustomerSegmentFnl from Mapping.RFMComboLookup
			where Name is null
			and ComboID <> 'HighSchool')b on b.ComboID = case when a.ComboID = '25-10000 Mo Inq Plus' then '25-10000 Mo Inq'
																															else a.ComboID end
		
		
		-- Update PM8 and PM5 -- 5/4/2014 PR to accomodate new segments
		update a
		set a.CustomerSegmentNew = case when b.HVLVGroup = 'MV' then  'NewToFile_PM5'
										when b.HVLVGroup = 'LV' then 'NewToFile_PM8'
										else a.CustomerSegmentNew
									end
		from Staging.TempCampaignCustomerSignature a join
			rfm..WPTest_Random2013 b on a.customerid = b.CustomerID
		where a.newseg in (1,2)
		and b.HVLVGroup in ('LV','MV')			

		-- Update 12 month singles to 'NearInactives -- 5/7/2014
		-- as they should be getting reactivaton mailings.
		update a
		set a.CustomerSegmentNew = 'NearInactives'
		from Staging.TempCampaignCustomerSignature a
		where a.newseg in (6,7)		
		and ComboID <> 'HighSchool'																									

		/*-- Update for PM8
      update ccs
        set ccs.CustomerSegmentNew = 'NewToFile_PM8'
        from Staging.TempCampaignCustomerSignature ccs
        join Staging.vwCustomerInitialInfo cr (nolock) on ccs.CustomerID = cr.CustomerID
        where ccs.CountryCode like '%US%'          
        and ccs.NewSeg in (1,2)
        and
            (cr.IntlPromotionTypeID IN (558) and cr.IntlAOS <= 100)
            or  (cr.IntlPromotionTypeID IN (124,125,126,127,129,2631,2642,2650,2651,2652,2653,2656,2657) and cr.IntlAOS <= 50)


		-- Update for PM5  
		update ccs
        set ccs.CustomerSegmentNew = 'NewToFile_PM5'
        from Staging.TempCampaignCustomerSignature ccs
        join Staging.vwCustomerInitialInfo cr (nolock) on ccs.CustomerID = cr.CustomerID
        where ccs.CountryCode like '%US%'  
		and ccs.CustomerSegmentNew is null
		and ccs.NewSeg in (1,2)
		and
            (cr.IntlPromotionTypeID IN (558) and cr.IntlAOS between 101.0 and 150.0)
            or (cr.IntlPromotionTypeID IN (124,125,126,127,129,2631,2642,2650,2651,2652,2653,2656,2657) and cr.IntlAOS > 50)


		-- Update for PM5  
		update ccs
        set ccs.CustomerSegmentNew = 'NewToFile_PM5'
        from Staging.TempCampaignCustomerSignature ccs
        join Staging.vwCustomerInitialInfo cr (nolock) on ccs.CustomerID = cr.CustomerID
        where ccs.CountryCode like '%US%'  
		and ccs.CustomerSegmentNew is null
		and ccs.NewSeg in (1,2)
		and cr.IntlPromotionTypeID Not IN (539, 2428) and cr.IntlAOS <= 100
        */    		
        
        update Staging.TempCampaignCustomerSignature
        set CustomerSegmentNew = isnull(CustomerSegment2,CustomerSegment)
        where isnull(CustomerSegmentNew, '') = ''
        
    end

	update Staging.TempCampaignCustomerSignature
	set Frequency = null,
		a12mf = null
	where customersegment like '%inq%'

	/*Code Moved to EPC preference Proc*/
	--if datepart(day, getdate()) = 1 
 --   begin -- If it is first of the month, then save the signature table
	--	exec Staging.AddToMonthlyArchive 'CampaignCustomerSignature'
        
        --DECLARE @AsOfDate DATETIME
    		
        --SELECT distinct @ASOfDate = convert(datetime,convert(varchar,FMPullDate,101))
        --FROM Staging.TempCampaignCustomerSignature (nolock)
        --WHERE customerSegment = 'Active'
        
 --       INSERT INTO Marketing.DMCustomerMailEmailFlags
 --       SELECT DISTINCT @AsOfDate AS AsOfDate,
 --           CustomerID, NewSeg, Name, a12mf, ComboID, Frequency, EmailAddress, 
 --           FlagEmail as FlagEmailable, FlagValidEmail, FlagEmailPref, 
 --           FlagValidRegionUS, FlagMail as FlagMailPref, PublicLibrary,
 --           FlagMail as FlagMailable, CountryCode, R3PurchWeb, 
 --           CASE WHEN ltrim(rtrim(a.countrycode)) = b.countrycodeid THEN REPLACE(CountryCode,' ','') 
 --               ELSE 'XX' 
 --           END AS CountryCodeCube,
 --           FlagSharePref,	
	--		FlagOkToShare
 --       FROM Staging.TempCampaignCustomerSignature a (nolock) 
 --       LEFT OUTER JOIN MarketingCubes.dbo.DimCountryCodes b (nolock) ON LTRIM(RTRIM(a.countrycode)) = b.countrycodeid
 --   end            

    truncate table Marketing.CampaignCustomerSignature
    insert into Marketing.CampaignCustomerSignature
    select * from Staging.TempCampaignCustomerSignature (nolock)    
    drop table Staging.TempCampaignCustomerSignature

	exec Staging.UpdateCustomerOptinTracker   
	
	-- PR 3/4/2014
	-- this is not related to Customer signature, but since this runs daily, using this proc as placeholder to run this.
	
	if object_id('DAX_Unsubscribes_Last2Months') is not null drop table DAX_Unsubscribes_Last2Months
		
	select *
	into DAX_Unsubscribes_Last2Months
	from DAXImports..DAX_Unsubscribes_Last2Months
 

 
 /*Add Data to Marketing.TGC_Monthly_RFM*/
	If Datepart(dd,getdate()) =  1
	Begin

	Insert Into DataWarehouse.Marketing.TGC_Monthly_RFM
	select CustomerID,CustomerSince,cast(FMPullDate as date) as AsOfDate,
				  NewSeg,Name,a12mf,ComboID,CustomerSegment,Frequency,CustomerSegmentNew,
				  CustomerSegmentFnl,customerSegment + case when frequency = 'F2' then '_Multi' 
														   when frequency = 'F1' then '_Single' 
														   else '' end as CustomerSegmentFrcst,
				  FirstName,LastName,Address1,Address2,Address3,City,State,postalCode,CountryCode 
              
	from DataWarehouse.Marketing.CampaignCustomerSignature 
	Where isnull(Customerid ,'')<>''
	End

end

GO
