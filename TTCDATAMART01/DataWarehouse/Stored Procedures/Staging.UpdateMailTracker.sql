SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[UpdateMailTracker]
    @CodeList varchar(100) = '', -- comma-separated list of Campaign Codes or Catalog Codes
    @CodeType varchar(8) = 'Campaign', -- either 'Campaign' or 'Catalog'
    @EmptyFactsTable varchar(3) = 'No' -- 'Yes'/'No'
as
	declare
		@CodeValues table(Code int)
	declare        
        @Code varchar(5),
		@Pos int        
begin
	set nocount on
    
    --- New Mail Campaign Tracker UPDATE
    -- Preethi Ramanujam	12/11/2009 Update

    -- CampaignIDs: (373, 374, 376, 377, 378, 379, 384, 386, 391,390) - 1/25/2010
    -- CampaignIDs: Just for Canada: 326, 386

    -- --2010 -- select * from superstardw.dbo.mktcampaign where campaignid in (373, 374, 376, 377, 378, 379, 384, 386, 391,390)
    -- --2011 -- select * from superstardw.dbo.mktcampaign where campaignid in (435, 436, 440, 434, 443, 444, 459, 466, 471, 472, 473,551)

    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

	-- split list of Codes into table variable
    set @CodeList = ltrim(rtrim(@CodeList)) + ','
    SET @Pos = CHARINDEX(',', @CodeList, 1)
    IF REPLACE(@CodeList, ',', '') <> ''
    BEGIN
        WHILE @Pos > 0
        BEGIN
            SET @Code = LTRIM(RTRIM(LEFT(@CodeList, @Pos - 1)))
            IF @Code <> ''
            BEGIN
                INSERT INTO @CodeValues (Code) VALUES (CAST(@Code AS int))
            END
            SET @CodeList = RIGHT(@CodeList, LEN(@CodeList) - @Pos)
            SET @Pos = CHARINDEX(',', @CodeList, 1)
        END
    END	   
    
    select * from @CodeValues 

    PRINT 'STEP 1: Create MailingHistoryBy RFM with adcode and matchcode information'

    PRINT 'Drop table MailTrackerMailingHistory'
    DROP TABLE Staging.MailTrackerMailingHistory

    PRINT 'Create table MailTrackerMailingHistory'

    SELECT 
    	MH.CustomerID, 
        ISNULL(RCL.CustomerSegment,'') CustomerSegment,
        MC.MatchCode, 
        ISNULL(RCL.Seqnum,0) SeqNum, 
        ISNULL(RCL.RFMCells,'') RFMCells, 
        ISNULL(MH.ComboID,'Unknown') as ComboID, 
        RCL.MultiOrSingle,
        MH.Adcode, 
        Adcode.AdcodeName,
        Adcode.CatalogCode,
        Adcode.CatalogName,
        Adcode.OldCampaignID, 
        Adcode.OldCampaignName, 
        ISNULL(MH.SubjRank,'NA') SubjRank,
        CASE WHEN MH.FlagHoldout = 0 THEN 1
             WHEN MH.FlagHoldout = 1 THEN 0
             ELSE MH.FlagHoldout
        END AS FlagMailed,
        Adcode.StartDate, 
        DATEADD(day,3,StopDate2Weeks) AS StopDate
    INTO Staging.MailTrackerMailingHistory
    FROM Archive.MailHistoryCurrentyear MH (nolock)
    LEFT OUTER JOIN
        (SELECT DISTINCT SeqNum, RFMCells, CustomerSegment,ComboID,MultiOrSingle
        FROM Mapping.RFMComboLookup (nolock))RCL ON ISNULL(MH.ComboID,'Unknown') = RCL.ComboID
    LEFT OUTER JOIN
        (SELECT DISTINCT CCS.CustomerID, CCS.CustomerSince,
            LTRIM(RTRIM(LEFT(CCS.LastName,5) + ISNULL(CCS.zip5,'ZZZZZ') + LEFT(ISNULL(CCS.Address1,'AAAAA'),5) + CCS.FirstName)) AS MatchCode 
        FROM Marketing.CampaignCustomerSignature CCS (nolock) JOIN
            Staging.Customers C ON C.customerID = CCS.Customerid)MC ON MH.CustomerID = MC.CustomerID
    --  	LEFT OUTER JOIN  -- PR 7/14/2008 - try with this - do we need left outer join????
    JOIN
    (
    	SELECT ACA.*, DATEADD(WK,2,ACA.StopDate) AS StopDate2Weeks
	    FROM Mapping.vwAdcodesAll ACA (nolock)
    	join @CodeValues cv on cv.Code = 
		    case @CodeType
    	    	when 'Campaign' then aca.OldCampaignID
    		    when 'Catalog' then aca.CatalogCode
		    end            
        --    WHERE ACA.CampaignID IN (435, 436, 440, 434, 443, 444, 459, 466, 471, 472, 473,551)
    ) Adcode ON MH.Adcode = Adcode.Adcode
    -- 2010 IDs -- WHERE ACA.CampaignID IN (373, 374, 376, 377, 378, 379, 384, 386, 391,390,326,386))Adcode ON MH.Adcode = Adcode.Adcode
    -- WHERE ACA.CampaignID IN (325, 324, 319, 318, 357))Adcode ON MH.Adcode = Adcode.Adcode
    -- 	WHERE ACA.CampaignID IN (202, 203, 204, 206, 207, 248, 249, 250, 251, 252))Adcode ON MH.Adcode = Adcode.Adcode
    -- 	WHERE ACA.CampaignID BETWEEN 248 and 252)Adcode ON MH.Adcode = Adcode.Adcode
    --	WHERE ACA.CampaignID BETWEEN 202 AND 207 AND ACA.CampaignID <> 205)Adcode ON MH.Adcode = Adcode.Adcode

--    create clustered index IX_MailingHistory_byRFM_Update_1 ON RFM.dbo.MailingHistory_byRFM_Update (CustomerID,catalogcode)
--    create index IX_MailingHistory_byRFM_Update_2 ON RFM.dbo.MailingHistory_byRFM_Update (CustomerID)
--    create index IX_MailingHistory_byRFM_Update_3 ON RFM.dbo.MailingHistory_byRFM_Update (catalogcode)
    -- create index IX_MailingHistory_byRFM_Update_4 ON RFM.dbo.MailingHistory_byRFM_Update (CardNumber)
    -- create index IX_MailingHistory_byRFM_Update_5 ON RFM.dbo.MailingHistory_byRFM_Update (MatchCode)

    PRINT 'STEP 2: Begin - Create Orders Table'
    SELECT Getdate()

    DROP TABLE Staging.MailTrackerOrders

    SELECT 
    	DMPO.CustomerID, 
        MC.MatchCode, 
        MC.CustomerSince, 
        DMPO.DateOrdered, 
        DMPO.Adcode, 
        DMPO.CardNum, 
        DMPO.NetOrderAmount, 
        DMPO.OrderID,
        Adcode.AdcodeName, 
        Adcode.CatalogCode, 
        Adcode.CatalogName, 
        Adcode.OldCampaignID, 
        Adcode.OldCampaignName, 
        Adcode.StartDate, 
        DATEADD(day,3,StopDate2Weeks) AS StopDate,
        DMPO.CustomerID as MatchCustomerid, 
        Convert(int,0) AS MatchLevel
    INTO Staging.MailTrackerOrders
    FROM Staging.vwOrders DMPO (nolock)
    JOIN
    (
    	SELECT ACA.*, DATEADD(WK,2,ACA.StopDate) AS StopDate2Weeks
        FROM Mapping.vwAdcodesAll ACA (nolock)
    -- 	WHERE ACA.CampaignID BETWEEN 248 and 252)Adcode ON DMPO.Adcode = Adcode.Adcode
        join @CodeValues cv on cv.Code = 
		    case @CodeType
    	    	when 'Campaign' then aca.OldCampaignID
    		    when 'Catalog' then aca.CatalogCode
		    end            
        --WHERE ACA.CampaignID IN (435, 436, 440, 434, 443, 444, 459, 466, 471, 472, 473,551)
    ) Adcode 
	ON DMPO.Adcode = Adcode.Adcode AND DMPO.DateOrdered BETWEEN Adcode.StartDate AND DATEADD(day,3,StopDate2Weeks)
    -- 2010 IDs -- WHERE ACA.CampaignID IN (373, 374, 376, 377, 378, 379, 384, 386, 391,390,326,386))Adcode ON DMPO.Adcode = Adcode.Adcode
    -- 	WHERE ACA.CampaignID IN (325, 324, 319, 318, 357))Adcode ON DMPO.Adcode = Adcode.Adcode
    -- 	WHERE ACA.CampaignID IN (202, 203, 204, 206, 207, 248, 249, 250, 251, 252))Adcode ON DMPO.Adcode = Adcode.Adcode
                                        
        LEFT OUTER JOIN
        (SELECT DISTINCT CCS.CustomerID, CCS.CustomerSince,
            LTRIM(RTRIM(LEFT(CCS.LastName,5) + ISNULL(CCS.zip5,'ZZZZZ') + LEFT(ISNULL(CCS.Address1,'AAAAA'),5) + CCS.FirstName)) AS MatchCode
        FROM Marketing.CampaignCustomerSignature CCS JOIN
            Staging.Customers C 
	ON C.customerID = CCS.Customerid)MC ON DMPO.CustomerID = MC.CustomerID
    WHERE DMPO.NetOrderAmount BETWEEN 1 and 1500
    AND DMPO.StatusCode not in (4)
	/*StatusCode IN (0, 1, 3, 12) -- Avaya original version: (10,20,40,50,0,2,3,1)  changed after QC between Order allocation 20160506 */

    PRINT 'STEP 2: End - Create Orders Table'
    SELECT Getdate()


    PRINT 'STEP 3: Begin - Update MatchLevels'
    SELECT Getdate()

    PRINT 'If CustomerIDs and Catalogcodes match, then MatchLevel = 1'
    UPDATE OBR
    SET OBR.MatchCustomerID = MHBR.CustomerID,
        OBR.MatchLevel = 1
    FROM 	Staging.MailTrackerOrders OBR JOIN
        Staging.MailTrackerMailingHistory MHBR ON OBR.CustomerID = MHBR.CustomerID
                        AND OBR.CatalogCode = MHBR.CatalogCode						

    PRINT 'If MatchCode and Catalogcodes match, then MatchLevel = 2'
    UPDATE OBR
    SET OBR.MatchCustomerID = MHBR.CustomerID,
        OBR.MatchLevel = 2
    FROM 	Staging.MailTrackerOrders OBR JOIN
        Staging.MailTrackerMailingHistory MHBR ON OBR.MatchCode = MHBR.MatchCode
       AND OBR.CatalogCode = MHBR.CatalogCode	
    where OBR.matchLevel = 0	

    PRINT 'STEP 3: End - Update MatchLevels'
    SELECT Getdate()


    PRINT 'STEP 3: Begin - Create index'
    SELECT Getdate()
    create clustered index IX_MailTrackerOrders_1 ON Staging.MailTrackerOrders (CustomerID,catalogcode)

    PRINT 'STEP 3: End - Create index'
    SELECT Getdate()

    -- Create Orders table with RFM information from Mailing History by RFM table created in step1
    PRINT 'STEP 4: BEGIN - Create Orders table with RFM information from Mailing History by RFM table created in step1'
    SELECT Getdate()

    -- dump transaction rfm with no_log

    drop table Staging.MailTrackerOrdersByRFM

    SELECT OBR.MatchCustomerid,OBR.Adcode,OBR.AdcodeName, OBR.CatalogCode, OBR.CatalogName, OBR.CustomerSince,
        OBR.MatchLevel, OBR.OldCampaignID, OBR.OldCampaignName, OBR.StartDate, OBR.StopDate, MHBR.SeqNum,
        MHBR.CustomerSegment, MHBR.FlagMailed, MHBR.MultiOrSingle,
        OBR.NetOrderAmount, OBR.OrderID, MHBR.RFMCells, MHBR.ComboID, MHBR.SubjRank
    INTO Staging.MailTrackerOrdersByRFM
    FROM Staging.MailTrackerOrders OBR LEFT OUTER JOIN
        Staging.MailTrackerMailingHistory MHBR ON OBR.MatchCustomerID = MHBR.CustomerID
                        AND OBR.CatalogCode = MHBR.CatalogCode	-- This used to be at adcode level when first created. In order include lost code and mismatch purchases, changed to catalog code

    create clustered index IX_MailTrackerOrdersByRFM_1 on Staging.MailTrackerOrdersByRFM (MatchCustomerID,AdCode,SeqNum,SubjRank)

    PRINT 'STEP 4: END - Create Orders table with RFM information from Mailing History by RFM table created in step1'
    SELECT Getdate()


    PRINT 'STEP 5: BEGIN - Update ComboID for new and existing customers'
    SELECT Getdate()

    -- If there was no match between customers and customersince > startdate of the mailing, then they are new customers
    UPDATE Staging.MailTrackerOrdersByRFM
    SET ComboID = 'CCN2M_NewCust'
    WHERE Matchlevel = 0
    and customersince > startdate

    -- If there was no match between customers and customersince <= startdate of the mailing, then they are pass arounds for existing customers
    UPDATE Staging.MailTrackerOrdersByRFM
    SET ComboID = 'CCN2M_ExistingCust'
    WHERE Matchlevel = 0
    and customersince <= startdate

    -- If there was a match and comboID is listed as null, then add comboID
    UPDATE obr2
    SET Obr2.ComboID = mhn.ComboID
    --select obr2.matchcustomerid, obr2.adcode,obr2.adcodename, mhn.adcode, mac.name, obr2.catalogcode,mhn.catalogcode,mhn.comboid
    from Staging.MailTrackerOrdersByRFM obr2 JOIN
        Staging.MailTrackerMailingHistory mhn on obr2.Matchcustomerid = mhn.customerid
                        and obr2.catalogcode = mhn.catalogcode
        JOIN
        Staging.MktAdCodes mac on mhn.adcode = mac.adcode
    where obr2.comboid is null and obr2.matchlevel >0 --LIKE 'CCN2M%Adcode' --


    PRINT 'STEP 5: END - Update ComboID for new and existing customers'
    SELECT Getdate()

    -- CREATE table MailTrackerSales with Orders tables for left outer join
    PRINT 'STEP 6: BEGIN - CREATE table MailTrackerSales'
    SELECT Getdate()


    DROP TABLE Staging.MailTrackerSales
    
    SELECT OBR2.Adcode, OBR2.AdcodeName, OBR2.CatalogCode, OBR2.CatalogName, OBR2.OldCampaignID, OBR2.OldCampaignName, 
        OBR2.StartDate, OBR2.StopDate, OBR2.CustomerSegment, OBR2.FlagMailed,
        ISNULL(OBR2.MultiOrSingle,'') AS MultiOrSingle,
        ISNULL(OBR2.SeqNum,0) as SeqNum, ISNULL(OBR2.RFMCells,'') AS RFMCells,
        ISNULL(OBR2.ComboID,'') as ComboID, ISNULL(OBR2.SubjRank,'NA') AS SubjRank, 
        CASE WHEN OBR2.ComboID LIKE 'CCN2M%' THEN 0
             ELSE MHBR2.TotalMailed
        END AS TotalMailed, SUM(OBR2.NetOrderAmount) AS TotalSales, COUNT(OBR2.ORDERID) AS TotalOrders
    INTO Staging.MailTrackerSales
    FROM Staging.MailTrackerOrdersByRFM OBR2 LEFT OUTER JOIN
        (SELECT  ISNULL(MHBR.SeqNum,0) AS SeqNum, ISNULL(MHBR.RFMCells,'') AS RFMCells, 
            ISNULL(MHBR.ComboID,'') as ComboID, ISNULL(MHBR.CustomerSegment,'') AS CustomerSegment,
            MHBR.FlagMailed,MHBR.Adcode, MHBR.Catalogcode, 
            ISNULL(MHBR.SubjRank,'NA') AS SubjRank, COUNT(MHBR.CustomerID) AS TotalMailed
        FROM Staging.MailTrackerMailingHistory MHBR
        GROUP BY ISNULL(MHBR.SeqNum,0), ISNULL(MHBR.RFMCells,''), 
            ISNULL(MHBR.ComboID,''), ISNULL(MHBR.CustomerSegment,''),
            MHBR.FlagMailed,MHBR.Adcode, MHBR.Catalogcode, 
            ISNULL(MHBR.SubjRank,'NA'))MHBR2 ON MHBR2.Adcode = OBR2.Adcode 
                            AND ISNULL(MHBR2.SeqNum,0) = ISNULL(OBR2.SeqNum,0)
                            AND ISNULL(MHBR2.SubjRank,'NA') = ISNULL(OBR2.SubjRank,'NA')
    GROUP BY OBR2.Adcode, OBR2.AdcodeName, OBR2.CatalogCode, OBR2.CatalogName, OBR2.OldCampaignID, OBR2.OldCampaignName, 
        OBR2.StartDate, OBR2.StopDate, OBR2.CustomerSegment, OBR2.FlagMailed,ISNULL(OBR2.MultiOrSingle,''),
        ISNULL(OBR2.SeqNum,0), ISNULL(OBR2.RFMCells,''),
        ISNULL(OBR2.ComboID,''), ISNULL(OBR2.SubjRank,'NA'), 
        CASE WHEN OBR2.ComboID LIKE 'CCN2M%' THEN 0
             ELSE MHBR2.TotalMailed
        END
    --ORDER BY OBR2.CampaignID, OBR2.CatalogCode, OBR2.Adcode, OBR2.SeqNum, OBR2.SubjRank

    PRINT 'STEP 6: END - CREATE table MailTrackerSales'
    SELECT Getdate()

    -- dump transaction rfm with no_log

    -- Insert remaining counts information with MHBR for left outer join
    PRINT 'STEP 7: BEGIN - Insert remaining counts information with MHBR for left outer join into table MailTrackerSales'
    SELECT Getdate()

    INSERT INTO Staging.MailTrackerSales
    SELECT Distinct ISNULL(MHBR2.Adcode,''),  ISNULL(MHBR2.AdcodeName,''), ISNULL(MHBR2.CatalogCode,''), 
        ISNULL(MHBR2.CatalogName,''), ISNULL(MHBR2.OldCampaignID,''), ISNULL(MHBR2.OldCampaignName,''), 
        ISNULL(MHBR2.StartDate,''), ISNULL(MHBR2.StopDate,''), ISNULL(MHBR2.CustomerSegment,''), 
        ISNULL(MHBR2.FlagMailed,''), ISNULL(MHBR2.MultiOrSingle,0) as MultiOrSingle,
        ISNULL(MHBR2.SeqNum,0) as SeqNum, ISNULL(MHBR2.RFMCells,'') AS RFMCells,
        ISNULL(MHBR2.ComboID,'') as ComboID, ISNULL(MHBR2.SubjRank,'NA') AS SubjRank, 
        MHBR2.TotalMailed, ISNULL(OBR2.TotalSales,0) TotalSales, ISNULL(OBR2.TotalOrdered,0) TotalOrders
    FROM (SELECT  ISNULL(MHBR.SeqNum,0) AS SeqNum, ISNULL(MHBR.RFMCells,'') AS RFMCells, 
            ISNULL(MHBR.ComboID,'') as ComboID, MHBR.Adcode,MHBR.AdcodeName,
            MHBR.Catalogcode, MHBR.CatalogName, MHBR.OldCampaignID, MHBR.OldCampaignName,
            MHBR.StartDate, MHBR.StopDate,MHBR.CustomerSegment, MHBR.FlagMailed,
            ISNULL(MHBR.MultiOrSingle,0) as MultiOrSingle,
            ISNULL(MHBR.SubjRank,'NA') AS SubjRank, COUNT(MHBR.CustomerID) AS TotalMailed
        FROM Staging.MailTrackerMailingHistory MHBR 
    	join @CodeValues cv on cv.Code = 
		    case @CodeType
    	    	when 'Campaign' then MHBR.OldCampaignID
    		    when 'Catalog' then MHBR.CatalogCode
		    end            
--      WHERE MHBR.CampaignID IN (435, 436, 440, 434, 443, 444, 459, 466, 471, 472, 473,551)
        GROUP BY MHBR.SeqNum, MHBR.RFMCells, MHBR.ComboID, MHBR.Adcode, MHBR.AdcodeName,
            MHBR.Catalogcode, MHBR.CatalogName, MHBR.OldCampaignID, MHBR.OldCampaignName,
            MHBR.StartDate, MHBR.StopDate,MHBR.CustomerSegment, MHBR.FlagMailed,
            ISNULL(MHBR.MultiOrSingle,0),
            ISNULL(MHBR.SubjRank,'NA'))MHBR2  LEFT OUTER JOIN 
        (SELECT ISNULL(SeqNum,0) AS SeqNum, ISNULL(RFMCells,'') AS RFMCells, 
            ISNULL(ComboID,'') as ComboID, Adcode,  Catalogcode, 
            ISNULL(SubjRank,'NA') AS SubjRank, COUNT(MatchCustomerID) AS TotalOrdered, 
            SUM(NetOrderAmount) AS TotalSales
        FROM Staging.MailTrackerOrdersByRFM
        GROUP BY SeqNum, RFMCells, ComboID, Adcode, 
            Catalogcode, ISNULL(SubjRank,'NA'))OBR2 ON MHBR2.Adcode = OBR2.Adcode
                                AND ISNULL(MHBR2.SeqNum,0) = ISNULL(OBR2.SeqNum,0)
                                AND ISNULL(MHBR2.SubjRank,'NA') = ISNULL(OBR2.SubjRank,'NA')		
    WHERE  OBR2.SeqNum is null and OBR2.SubjRank is null and OBR2.catalogcode is null
    --ORDER BY MHBR2.CatalogCode, MHBR2.Adcode, MHBR2.SubjRank, MHBR2.SeqNum
    
    update Staging.MailTrackerSales
    set FlagMailed = 2
    where comboid like '%CCN%'


    PRINT 'STEP 8: Delete rows if the original table already has the data'

--    select count(*)
--    from Staging.SalesByRFM t
--	join @CodeValues cv on t.CampaignID = cv.Code    
    
--    where campaignid in (435, 436, 440, 434, 443, 444, 459, 466, 471, 472, 473,551)
    -- 2010 IDs -- where campaignid in (373, 374, 376, 377, 378, 379, 384, 386, 391,390,326,386)
    
    if @EmptyFactsTable = 'Yes'
    begin
    	truncate table Marketing.SalesByRFM
    end
    else if @EmptyFactsTable = 'No'
    begin
        delete t
        from Marketing.SalesByRFM t
        join @CodeValues cv on cv.Code = 
            case @CodeType
                when 'Campaign' then t.CampaignID
                when 'Catalog' then t.CatalogCode
            end            
	end        
    
--    where campaignid in (435, 436, 440, 434, 443, 444, 459, 466, 471, 472, 473,551)
    -- 2010 IDs -- where campaignid in (373, 374, 376, 377, 378, 379, 384, 386, 391,390,326,386)

    INSERT INTO Marketing.SalesByRFM
    select * from Staging.MailTrackerSales


    PRINT 'STEP 8: END - Update final table'
    SELECT Getdate()


    /*
    -------------------------------------------------------------------------------------------------------
    select top 10 * from marketingdm.dbo.adcodesall

    select * from superstardw.dbo.mktcampaign
    where CampaignID BETWEEN 248 and 252

    UPDATE STATISTICS MailingHistory

    -- QC Begin

    -- QC1: QC for Sales and Orders information

    select ACA.Catalogcode, count(distinct customerid) CustCount,sum(netorderamount)TotalSales,
         count(orderid) TotalOrders
    from ccqdw.dbo.orders o join
        marketingdm.dbo.adcodesall aca on o.adcode = aca.adcode
    where aca.campaignID BETWEEN 248 and 252 
    and netorderamount between 11 and 1499
    and StatusCode IN (10,20,40,50,0,2,3,1)
    and dateOrdered between aca.startdate and dateadd(day,3,dateadd(wk,2,stopdate))
    group by ACA.Catalogcode
    order by 1

    -- QC2: QC for Mailed counts

    select ACA.CampaignID, ACA.CampaignName, 		
        ACA.Catalogcode, ACA.CatalogName,	
        count(MH.customerid) CustCount	
    from rfm..mailinghistory mh join		
        marketingdm.dbo.adcodesall aca on mh.adcode = aca.adcode	
    where aca.campaignID between 248 and 252		
    group by ACA.CampaignID, ACA.CampaignName, ACA.Catalogcode, ACA.CatalogName, MH.FlagHoldout		
    order by 1, 3		

    -- QC END


    -- Try Full outer join
    DROP TABLE MarketingDM.dbo.SalesByRFM_FullJoin

    -- dump transaction rfm with no_log
    SELECT OBR2.Adcode, OBR2.AdcodeName, OBR2.CatalogCode, OBR2.CatalogName, OBR2.CampaignID, OBR2.CampaignName, 
        OBR2.StartDate, OBR2.StopDate, OBR2.CustomerSegment, OBR2.FlagMailed,
        ISNULL(OBR2.MultiOrSingle,'') AS MultiOrSingle,
        ISNULL(OBR2.SeqNum,0) as SeqNum, ISNULL(OBR2.RFMCells,'') AS RFMCells,
        ISNULL(OBR2.ComboID,'') as ComboID, ISNULL(OBR2.SubjRank,'NA') AS SubjRank, 
        CASE WHEN OBR2.ComboID LIKE 'CCN2M%' THEN 0
             ELSE MHBR2.TotalMailed
        END AS TotalMailed, SUM(OBR2.NetOrderAmount) AS TotalSales, COUNT(OBR2.ORDERID) AS TotalOrders
    INTO MarketingDM.dbo.SalesByRFM_FullJoin
    FROM RFM.dbo.Orders_byRFMUpdate2 OBR2 FULL OUTER JOIN
        (SELECT  ISNULL(MHBR.SeqNum,0) AS SeqNum, ISNULL(MHBR.RFMCells,'') AS RFMCells, 
            ISNULL(MHBR.ComboID,'') as ComboID, ISNULL(MHBR.CustomerSegment,'') AS CustomerSegment,
            MHBR.FlagMailed,MHBR.Adcode, MHBR.Catalogcode, 
            ISNULL(MHBR.SubjRank,'NA') AS SubjRank, COUNT(MHBR.CustomerID) AS TotalMailed
        FROM RFM.dbo.MailingHistory_byRFM_Update MHBR
        GROUP BY ISNULL(MHBR.SeqNum,0), ISNULL(MHBR.RFMCells,''), 
            ISNULL(MHBR.ComboID,''), ISNULL(MHBR.CustomerSegment,''),
            MHBR.FlagMailed,MHBR.Adcode, MHBR.Catalogcode, 
            ISNULL(MHBR.SubjRank,'NA'))MHBR2 ON MHBR2.Adcode = OBR2.Adcode -- PR Changed to catalogcode instead of adcode level join 
                                AND ISNULL(MHBR2.SeqNum,0) = ISNULL(OBR2.SeqNum,0)
                                AND ISNULL(MHBR2.SubjRank,'NA') = ISNULL(OBR2.SubjRank,'NA')
    GROUP BY OBR2.Adcode, OBR2.AdcodeName, OBR2.CatalogCode, OBR2.CatalogName, OBR2.CampaignID, OBR2.CampaignName, 
        OBR2.StartDate, OBR2.StopDate, OBR2.CustomerSegment, OBR2.FlagMailed,ISNULL(OBR2.MultiOrSingle,''),
        ISNULL(OBR2.SeqNum,0), ISNULL(OBR2.RFMCells,''),
        ISNULL(OBR2.ComboID,''), ISNULL(OBR2.SubjRank,'NA'), 
        CASE WHEN OBR2.ComboID LIKE 'CCN2M%' THEN 0
             ELSE MHBR2.TotalMailed
        END


    */    
end
GO
