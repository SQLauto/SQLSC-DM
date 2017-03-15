SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Staging].[UpdateEmailTracker]
    @StartDate DATETIME = '1/1/1900',
    @EndDate Datetime = '1/1/1900',
    @EmptyFactsTable varchar(3) = 'No' -- 'Yes'/'No'    
AS
	set nocount on

    -- Email Tracker: Ecampaigns.dbo.EmailTracker_Update
    -- Preethi Ramanujam New	8/1/2008

    IF @StartDate = '1/1/1900'
        select @StartDate = dateadd(week, -2, convert(datetime,convert(varchar,DateAdd(Day, 1, getdate() - Day(getdate()) + 1) -1,101)))

    PRINT 'StartDate = ' + Convert(varchar,@StartDate)

    IF @EndDate = '1/1/1900'
        select @EndDate = CONVERT(datetime,CONVERT(varchar,getdate(),101))

    PRINT '@EndDate = ' + Convert(varchar,@EndDate)

    -- SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
    SELECT EH.*, ACA.AdcodeName, ACA.CatalogCode, ACA.CatalogName, ACA.OldCampaignID, 
            ACA.OldCampaignName, ACA.StartDate CCTblStartDate, ACA.StopDate, ACA.PiecesMailed
	into #tempEmails            
    FROM Archive.EmailHistory EH (nolock) LEFT OUTER JOIN
        Mapping.vwAdcodesAll ACA (nolock) ON EH.Adcode = ACA.Adcode
    WHERE EH.StartDate between @StartDate and @EndDate
    
    SELECT O.CustomerID, O.OrderID, O.Adcode, O.DateOrdered, O.OrderSource, O.NetOrderAmount,
		O.TotalCourseSales, O.TotalCourseParts, O.TotalCourseQuantity,
        ACA.AdcodeName, ACA.CatalogCode, ACA.CatalogName, ACA.OldCampaignID, 
        ACA.OldCampaignName, ACA.StartDate, ACA.StopDate
	into #tempOrders        
   -- FROM Staging.vwOrders O (nolock) JOIN
	FROM Marketing.DMPurchaseOrders O (nolock) JOIN
        Mapping.vwAdcodesAll ACA (nolock) ON O.Adcode = ACA.Adcode
    WHERE O.DateOrdered >= @StartDate
    AND O.NetOrderAmount BETWEEN 0 AND 1500
    AND ACA.OldCampaignID in (163,164,165,392,398,406,405,404,403,549,550,555,596)
     
    --IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Email_SalesAndOrders_Update')
    --	DROP TABLE ECampaigns.dbo.Email_SalesAndOrders_Update
    truncate table Staging.Email_SalesAndOrders_Update
    insert INTO Staging.Email_SalesAndOrders_Update
    SELECT EH.OldCampaignID, EH.OldCampaignName, EH.CatalogCode, EH.CatalogName,EH.Adcode, EH.AdcodeName,  
        EH.StartDate AS EHistStartDate, EH.CCTblStartDate, EH.StopDate, 
        EH.CustomerID, EH.PiecesMailed AS TotalEmailed, 
        EH.ComboID, RCL.SeqNum, RCL.CustomerSegment, RCL.MultiOrSingle,
        RCL.NewSeg, RCL.Name, RCL.A12mf, 
        CASE WHEN eh.FlagHoldout = 0 then 1
             WHEN eh.FlagHoldout = 1 then 0
             ELSE ''
        END AS FlagEmailed,
        O.OrderSource,
        SUM(ISNULL(O.NetOrderAmount,0)) TotalSales, Count(O.OrderID) TotalOrders,
        SUM(isnull(o.TotalCourseSales,0)) TotalCourseSales,
        SUM(isnull(o.TotalCourseQuantity,0)) TotalCourseUnits,
        SUM(isnull(o.TotalCourseParts,0)) TotalCourseParts
    FROM 
        (SELECT DISTINCT SeqNum, ComboID, Active, CustomerSegment, MultiOrSingle, NewSeg, Name, A12mf
        FROM Mapping.RFMComboLookup (nolock))RCL LEFT OUTER JOIN
        
        #tempEmails EH ON RCL.ComboID = CASE WHEN EH.ComboID = 'Inq' THEN '25-10000 Mo Inq' 
                                             ELSE ISNULL(EH.ComboID,'Unknown')
                                        END 
        LEFT OUTER JOIN
		#tempOrders O ON O.CustomerID = EH.CustomerID AND O.CatalogCode = EH.CatalogCode
    GROUP BY EH.OldCampaignID, EH.OldCampaignName, EH.CatalogCode, EH.CatalogName,EH.Adcode, EH.AdcodeName,  
        EH.StartDate,EH.CCTblStartDate,EH.StopDate, EH.CustomerID, EH.PiecesMailed,
        EH.ComboID, RCL.SeqNum, RCL.CustomerSegment, RCL.MultiOrSingle,
        RCL.NewSeg, RCL.Name, RCL.A12mf,
        CASE WHEN eh.FlagHoldout = 0 then 1
             WHEN eh.FlagHoldout = 1 then 0
             ELSE ''
        END,
        O.OrderSource
    Order by EH.StartDate, EH.OldCampaignID, EH.CatalogCode, EH.Adcode


    --Create clustered index IX_Email_SalesAndOrders_Update_1 
    --on ECampaigns.dbo.Email_SalesAndOrders_Update (CustomerID, Adcode)


    -- Missing from EmailHistory Table

    /*
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Email_SalesAndOrders_Update_2')
        DROP TABLE ECampaigns..Email_SalesAndOrders_Update_2

    SELECT TOP 0 *
    INTO ECampaigns..Email_SalesAndOrders_Update_2
    FROM ECampaigns..Email_SalesAndOrders_Update

    set transaction isolation level read uncommitted
    */

--    DECLARE @CatCode INT, @Count INT, @counter int
--    set @counter = 0

    truncate table Staging.Email_SalesAndOrders_Update_2    
	INSERT into Staging.Email_SalesAndOrders_Update_2
    select 
    	Ord.OldCampaignID, 
        Ord.OldCampaignName,
        Ord.CatalogCode, 
        Ord.CatalogName, 
        Ord.Adcode, 
        Ord.AdcodeName, 
        '' as EHistStartDate, 
        ord.StartDate as CCTblStartDate, 
        ord.StopDate, 
        ord.CustomerID, 
        ord.PiecesMailed,
        'CCN2M' ComboID,
        101 SeqNum, 
        'CCN2M' CustomerSegment, 
        Null MultiOrSingle, 
        NULL NewSeg, 
        Null Name, 
        NULL A12mf, 
        1 FlagEmailed,
        Ord.OrderSource,
        TotalSales, 
        TotalOrders,
        TotalCourseSales,
        TotalCourseUnits,
        TotalCourseParts
	from (select distinct CatalogCode from Staging.Email_SalesAndOrders_Update (nolock)) t
    cross apply Staging.GetEmailTrackerSalesOrder(t.CatalogCode) ord

    

/*    DECLARE MyCursor CURSOR FOR
    SELECT  CatalogCode,Count(CatalogCode) CatCount 
    FroM  Staging.Email_SalesAndOrders_Update
    group by catalogcode

        OPEN MyCursor
        FETCH NEXT FROM MyCursor INTO @CatCode, @Count
    		
        WHILE @@FETCH_STATUS = 0
            BEGIN
            SET @Counter = @Counter + 1

            PRINT Convert(varchar,@Counter) + '. CatalogCode is: ' + Convert(varchar,@catcode)

    --		set nocount on

            INSERT into ECampaigns..Email_SalesAndOrders_Update_2
            select Ord.CampaignID, Ord.CampaignName,Ord.CatalogCode, Ord.CatalogName, Ord.Adcode, Ord.AdcodeName, 
    --			ord.StartDate, ord.StopDate,Ord.CustomerID, 'CCn2M' ComboID,101 SeqNum, 'CCN2M' CustomerSegment, 
                '' as EHistStartDate, ord.StartDate as CCTblStartDate, ord.StopDate, ord.CustomerID, 
                ord.PiecesMailed,
                'CCN2M' ComboID,101 SeqNum, 'CCN2M' CustomerSegment, 
                Null MultiOrSingle, NULL NewSeg, Null Name, NULL A12mf, 1 FlagEmailed,Ord.OrderSource,
                sum(ord.NetOrderAmount)TotalSales, sum(ord.TotalOrders) TotalOrders--Ord.*, eso.*
            from 
                (select ACA.Adcode, ACA.AdcodeName, ACA.CatalogCode, ACA.CatalogName, ACA.CampaignID, ACA.CampaignName, 
                    ACA.StartDate, ACA.StopDate,O.customerID, ACA.PiecesMailed,
                    O.Ordersource,sum(netOrderamount)NetOrderAmount,count(orderid) TotalOrders
                FrOM ccqdw.dbo.Orders O JOIN
                    Marketingdm.dbo.Adcodesall ACA ON O.Adcode=ACA.adcode 
                    --join ECampaigns.dbo.Email_SalesAndOrders_Update eson on eson.CatalogCode = aca.catalogCode
              WHERE netorderamount between 10 and 1500
                AND ACA.CatalogCode = @CatCode
                group by ACA.Adcode, ACA.AdcodeName, ACA.CatalogCode, ACA.CatalogName, ACA.CampaignID, ACA.CampaignName, 
                    ACA.StartDate, ACA.StopDate,O.customerid,ACA.PiecesMailed,O.Ordersource)Ord 
                left outer join
                (select ACA.CatalogCode,O.customerID,sum(TotalSales) TS,Sum(TotalOrders) TotalOrders
                FrOM  ECampaigns.dbo.Email_SalesAndOrders_Update O JOIN
                    Marketingdm.dbo.Adcodesall ACA ON O.Adcode=ACA.adcode
                WHERE ACA.CatalogCode = @CatCode
                group by ACA.CatalogCode,customerID)eso on ord.Catalogcode = eso.catalogcode and ord.customerID = eso.customerid
            where eso.customerID is null
            group by Ord.Adcode, Ord.AdcodeName, Ord.CatalogCode, Ord.CatalogName, 
                Ord.CampaignID, Ord.CampaignName, ord.StartDate, ord.StopDate, 
                Ord.CustomerID, Ord.PiecesMailed, Ord.OrderSource

            FETCH NEXT FROM MyCursor INTO @CatCode, @Count

            END
        CLOSE MyCursor
        DEALLOCATE MyCursor*/



    INSERT INTO Staging.Email_SalesAndOrders_Update
    SELECT CampaignID, CampaignName, CatalogCode, CatalogName, Adcode, 
        AdcodeName, EHistStartDate, CCTblStartDate, StopDate, '' as CustomerID, TotalEmailed, ComboID, SeqNum, 
        CustomerSegment, MultiOrSingle, NewSeg, Name, A12mf, FlagEmailed, 
        OrderSource, TotalSales, TotalOrders,
        TotalCourseSales, TotalCourseUnits, TotalCourseParts
    FrOM Staging.Email_SalesAndOrders_Update_2

--    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Email_SalesAndOrders_Update_Summary')
--        DROP TABLE ECampaigns.dbo.Email_SalesAndOrders_Update_Summary
	
    truncate table Staging.Email_SalesAndOrders_Update_Summary
	insert INTO Staging.Email_SalesAndOrders_Update_Summary
    SELECT CampaignID, CampaignName, CatalogCode, CatalogName, Adcode, AdcodeName, EHistStartDate, 
        CCTblStartDate, Month(CCTblStartDate) AS CCTblStartMonth,
        Year(CCTblStartDate) AS CCTblStartYear, StopDate, TotalEmailed, 
        ComboID, SeqNum, CustomerSegment, MultiOrSingle, NewSeg, Name, A12mf, OrderSource, FlagEmailed,
        Count(DISTINCT CustomerID) CustCount, SUM(TotalSales) TotalSales, SUM(TotalOrders) TotalOrders,
        SUM(TotalCourseSales) TotalCourseSales,
        SUM(TotalCourseUnits) TotalCourseUnits,
        SUM(TotalCourseParts) TotalCourseParts
    FROM Staging.Email_SalesAndOrders_Update
    GROUP BY CampaignID, CampaignName, CatalogCode, CatalogName, Adcode, AdcodeName, EHistStartDate, 
        CCTblStartDate, Month(CCTblStartDate),
        Year(CCTblStartDate), StopDate, TotalEmailed,
        ComboID, SeqNum, CustomerSegment, MultiOrSingle, NewSeg, Name, A12mf, OrderSource, FlagEmailed

    -- Update ECampaigns.dbo.Email_SalesAndOrders_Summary with the additions.

    -- First delete the catalog codes from the summary table
    
    if @EmptyFactsTable = 'Yes'
    begin
    	truncate table Marketing.Email_SalesAndOrders_Summary
    end
    
    DELETE A
    FROM Marketing.Email_SalesAndOrders_Summary A JOIN
        (SELECT Distinct catalogCode 
        FrOM Staging.Email_SalesAndOrders_Update_Summary)B ON A.CatalogCode = B.CatalogCode

    INSERT INTO Marketing.Email_SalesAndOrders_Summary
    SELECT CampaignID, CampaignName, 
			CatalogCode, CatalogName, 
			Adcode, AdcodeName, 
			EHistStartDate, CCTblStartDate, 
			CCTblStartMonth, CCTblStartYear, StopDate, 
			TotalEmailed, 
			ComboID, SeqNum, CustomerSegment, MultiOrSingle, 
			NewSeg, Name, A12mf, 
			OrderSource, FlagEmailed, CustCount, 
			TotalSales, TotalOrders, 
			getdate(), getdate(),
			TotalCourseSales, TotalCourseUnits, TotalCourseParts
    FROM Staging.Email_SalesAndOrders_Update_Summary
    
    update Marketing.Email_SalesAndOrders_Summary
    set TableUpdateDate = getdate()
GO
