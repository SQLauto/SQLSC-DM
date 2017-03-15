SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [Staging].[UpdateNewCoursePerf]
	@StartDate DATETIME = '1/1/1900',
	@EndDate DATETIME = '1/1/1900',
	@DateSpanSales INT = 3,
	@DeBugCode INT = 1
AS

--- Proc Name: 	Staging.NewCoursePerfUpdate
--- Purpose:	
---		
--- Special Tables Used: 
---
--- Updates:
--- Name		Date		Comments
--- Preethi Ramanujam 	01/07/2009	New
--- Preethi Ramanujam 	08/20/2014  Add 1 Month OverAll, CourseDriven and NewCourse sales


--- Declare variables
begin
	set nocount on

    DECLARE @ErrorMsg VARCHAR(400)   --- Error message for error handling.

    IF @StartDate = '1/1/1900'
       BEGIN
        IF @EndDate = '1/1/1900'
           BEGIN
            SELECT @StartDate = CONVERT(DATETIME, CONVERT(VARCHAR(10),  DATEADD(month,-3,GETDATE()), 101))
            SELECT @EndDate = CONVERT(DATETIME, CONVERT(VARCHAR(10),  GETDATE(), 101))
           END 
        ELSE
           SELECT @StartDate = DATEADD(MONTH, -3, @EndDate)
       END
    ELSE
       BEGIN
        IF @EndDate = '1/1/1900'
            SELECT @EndDate = DATEADD(MONTH, 3, @StartDate)
       END


    IF @DebugCode = 1 
       BEGIN
        PRINT 'StartDate = ' + CONVERT(VARCHAR, @StartDate, 101)
        PRINT 'EndDate = ' + CONVERT(VARCHAR, @EndDate, 101)
       END

    -- Check to make sure EndDate is greater than StartDate

    IF @DeBugCode = 1 PRINT 'Check to make sure EndDate is greater than StartDate'

    IF @StartDate >= @EndDate
    BEGIN	
        SET @ErrorMsg = 'EndDate is smaller than StartDate'
        RAISERROR(@ErrorMsg,15,1)
        RETURN
    END

    -- Special Case
    UPDATE Mapping.DMCourse
    set Releasedate = '5/7/2010'
    where courseid = 9123

    UPDATE Mapping.DMCourse
    set Releasedate = '11/18/2011'
    where courseid = 9144

    UPDATE Mapping.DMCourse
    set Releasedate = '11/17/2012'
    where courseid in (8276,9253)
    
set transaction isolation level read uncommitted

    -- Get the list of NewCourses released in the time range
    PRINT 'Step1: Get the list of NewCourses released in the time range'

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Step1_NCP_NewCoursesUpdt')
        DROP TABLE Staging.Step1_NCP_NewCoursesUpdt
        
    SELECT a.CourseID, a.CourseName, a.AbbrvCourseName, a.CourseParts, a.SubjectCategory, 
        a.SubjectCategory2, a.PDSubjectCategory, a.ReleaseDate, Year(a.ReleaseDate) ReleaseYear, 
        a.PreReleaseCoursePref CoursePrefScore, PreReleaseSubjectMultiplier SubjMultiplier_PreRel, 
        (PreReleaseCoursePref * PreReleaseSubjectMultiplier) AdjPrefScore_PreRel, 
        (PreReleaseCoursePref * PreReleaseSubjectMultiplier * a.CourseParts) AdjPrefPoints_PreRel, 
        convert(float,0.0) SubjMultiplier_Current,
        convert(float,0.0) AdjPrefScore_Current, convert(float,0.0) AdjPrefPoints_Current,
        a.TotalPaidImages, a.TotalFreeImages, 
        (a.TotalPaidImages + a.TotalFreeImages) TotalImages,
        convert(float,(a.TotalPaidImages + a.TotalFreeImages))/convert(float,CourseParts) TotalImagesPerPart,
        PostReleaseCourseSat, b.CatalogCode, B.Name CatalogName, b.StartDate Cat_StartDate,
        b.StopDate AS Cat_StopDate, b.MailConsolidateID, MailConsolidateName,
        CONVERT(Int,0) TotalActivesMailed,
        CONVERT(Money,0) OverallSales_ActRecips_03Mo, CONVERT(Int,0) OverallOrders_ActRecips_03Mo,
        CONVERT(Money,0) CourseSales_ActRecips_03Mo, CONVERT(Int,0) CourseOrders_ActRecips_03Mo,
        CONVERT(Money,0) CourseDrvnSales_ActRecips_03Mo, CONVERT(Int,0) CourseDrvnOrders_ActRecips_03Mo,
        CONVERT(Money,0) OverallSales_ActRecips_CatLf, CONVERT(Int,0) OverallOrders_ActRecips_CatLf,
        CONVERT(Money,0) CourseSales_ActRecips_CatLf, CONVERT(Int,0) CourseOrders_ActRecips_CatLf,
        CONVERT(Money,0) CourseDrvnSales_ActRecips_CatLf, CONVERT(Int,0) CourseDrvnOrders_ActRecips_CatLf,
        CONVERT(Money,0) OverallSales_ActRecips_Coded, CONVERT(Int,0) OverallOrders_ActRecips_Coded,
        CONVERT(Money,0) CourseSales_ActRecips_Coded, CONVERT(Int,0) CourseOrders_ActRecips_Coded,
        CONVERT(Money,0) CourseDrvnSales_ActRecips_Coded, CONVERT(Int,0) CourseDrvnOrders_ActRecips_Coded,
        CONVERT(Money,0) OverallSales_ActRecips_01Mo, CONVERT(Int,0) OverallOrders_ActRecips_01Mo, --- Preethi Ramanujam 	08/20/2014  Add 1 Month OverAll, CourseDriven and NewCourse sales
        CONVERT(Money,0) CourseSales_ActRecips_01Mo, CONVERT(Int,0) CourseOrders_ActRecips_01Mo,
        CONVERT(Money,0) CourseDrvnSales_ActRecips_01Mo, CONVERT(Int,0) CourseDrvnOrders_ActRecips_01Mo
    INTO Staging.Step1_NCP_NewCoursesUpdt
    FROM Mapping.DMCourse a JOIN
        (select b.*, a.MailConsolidateID, a.MailConsolidateName from Mapping.DMPromotionType a join
        Staging.MktCatalogCodes b on a.catalogcode = b.catalogCode
        where DimPromotionID = 607 or a.CatalogCode in (22077, 22408,27006) -- added 22077 for Xmaslog (sky watch) and 22408 for Ninja (Spirits course)) 27006 for TurningPointsMedievalHstry
        and description not like '%tail%')b on  datediff(day, a.releasedate, b.StartDate) between -7 and 7
    WHERE ReleaseDate BETWEEN @StartDate and @EndDate
    AND ReleaseDate < GETDATE()
    AND a.BundleFlag = 0

--    CREATE CLUSTERED INDEX IX_Step1_NCP_NewCoursesUpdt on Staging.Step1_NCP_NewCoursesUpdt(CourseID)

SELECT * FROM Staging.Step1_NCP_NewCoursesUpdt

    -- Check if there are any catalogs that do not have mail consolidate ID
    PRINT 'Step 1b: Check if there are any catalogs that do not have mail consolidate ID'

    DECLARE @ChkMC INT

    SELECT @ChkMC = COUNT(*)
    FROM Staging.Step1_NCP_NewCoursesUpdt
    WHERE ISNULL(mailconsolidateID,0) < 1

    IF @ChkMC > 0
       BEGIN
        PRINT 'Following Catalogcodes do not have Mail consolidate ID in DMPromotionType table'
        PRINT 'Please add them and rerun the procedure'
        SELECT DISTINCT CatalogCode 
        FROM Staging.Step1_NCP_NewCoursesUpdt
        WHERE ISNULL(MailConsolidateID,0) < 1
        RETURN
       END

    -- Get Active mail recipients
    PRINT 'Step2: Get Active mail recipients'

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Step2_NCP_CustomerListUpdt')
        DROP TABLE Staging.Step2_NCP_CustomerListUpdt

    SELECT MH.CustomerID,MH.AdCode,MH.NewSeg,MH.Name,MH.a12mf,MH.Concatenated,MH.FlagHoldOut,MH.ComboID,MH.SubjRank,MH.PreferredCategory2,MH.StartDate
		, ACA.Catalogcode, ACA.CatalogName, ACA.StartDate as Cat_StartDate, ACA.StopDate as Cat_StopDate,
		RFM.CustomerSegment, RFM.MultiOrsingle,
        CONVERT(Money,0) OverallSales_ActRecips_03Mo, CONVERT(Int,0) OverallOrders_ActRecips_03Mo,
        CONVERT(Money,0) CourseSales_ActRecips_03Mo, CONVERT(Int,0) CourseOrders_ActRecips_03Mo,
        CONVERT(Money,0) CourseDrvnSales_ActRecips_03Mo, CONVERT(Int,0) CourseDrvnOrders_ActRecips_03Mo,
        CONVERT(Money,0) OverallSales_ActRecips_CatLf, CONVERT(Int,0) OverallOrders_ActRecips_CatLf,
        CONVERT(Money,0) CourseSales_ActRecips_CatLf, CONVERT(Int,0) CourseOrders_ActRecips_CatLf,
        CONVERT(Money,0) CourseDrvnSales_ActRecips_CatLf, CONVERT(Int,0) CourseDrvnOrders_ActRecips_CatLf,
        CONVERT(Money,0) OverallSales_ActRecips_Coded, CONVERT(Int,0) OverallOrders_ActRecips_Coded,
        CONVERT(Money,0) CourseSales_ActRecips_Coded, CONVERT(Int,0) CourseOrders_ActRecips_Coded,
        CONVERT(Money,0) CourseDrvnSales_ActRecips_Coded, CONVERT(Int,0) CourseDrvnOrders_ActRecips_Coded,
        CONVERT(Money,0) OverallSales_ActRecips_01Mo, CONVERT(Int,0) OverallOrders_ActRecips_01Mo,  --- Preethi Ramanujam 	08/20/2014  Add 1 Month OverAll, CourseDriven and NewCourse sales
        CONVERT(Money,0) CourseSales_ActRecips_01Mo, CONVERT(Int,0) CourseOrders_ActRecips_01Mo,
        CONVERT(Money,0) CourseDrvnSales_ActRecips_01Mo, CONVERT(Int,0) CourseDrvnOrders_ActRecips_01Mo
    INTO Staging.Step2_NCP_CustomerListUpdt
    FROM [Archive].[MailhistoryCurrentYear] MH (nolock) JOIN    /*MailingHistory2014 20160428 vik */
        Mapping.vwAdcodesAll ACA ON ACA.Adcode = MH.Adcode JOIN
        (SELECT DISTINCT CatalogCode, CatalogName, Cat_StartDate, Cat_StopDate
        FROM Staging.Step1_NCP_NewCoursesUpdt) NC ON ACA.CatalogCode = NC.CatalogCode  JOIN
        (SELECT Distinct ComboID,MultiOrsingle, CustomerSegment
        FROM Mapping.rfmComboLookup
        WHERE CustomerSegment = 'Active')RFM ON MH.ComboID = RFM.ComboID
    WHERE FlagHoldout = 0

    CREATE CLUSTERED INDEX IX_Step2_NCP_CustomerListUpdt1 on Staging.Step2_NCP_CustomerListUpdt (CatalogCode)
    CREATE INDEX IX_Step2_NCP_CustomerListUpdt2 on Staging.Step2_NCP_CustomerListUpdt (CustomerID)

    -- Get TotalMailed

    PRINT 'Step3: Get TotalMailed'

    UPDATE A
    SET A.TotalActivesMailed = B.CustCount
    FROM Staging.Step1_NCP_NewCoursesUpdt A JOIN
        (SELECT Catalogcode, CatalogName, Count(CustomerID) CustCount
        FROM Staging.Step2_NCP_CustomerListUpdt
        GROUP BY Catalogcode, CatalogName)B ON A.Catalogcode = B.Catalogcode


    -- Create Orders Table for the recipients

    PRINT 'Step4: Create Orders Table for the recipients'

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Step3_NCP_OrdersUpdt')
        DROP TABLE Staging.Step3_NCP_OrdersUpdt

    SELECT A.*, convert(int, 0) MailConsolidateID, O.OrderID, O.DateOrdered, O.Adcode OrderAdcode, 
        MA.AdcodeName AS OrderAdcodeName,
        MA.CatalogCode AS OrderCatalogcode, MA.CatalogName AS OrderCatalogName,
        convert(int, 0) OrderMailConsolidateID,
        O.Ordersource, O.NetOrderAmount,
        O.Shippingcharge, OI.CourseID, OI.StockItemID, OI.TotalQuantity,
        OI.TotalSales, OI.Salesprice
    INTO Staging.Step3_NCP_OrdersUpdt
    FROM Staging.Step2_NCP_CustomerListUpdt A 
		JOIN Marketing.DMPurchaseOrders O ON O.CustomerID  = A.CustomerID
									and O.DateOrdered BETWEEN a.Cat_StartDate AND DATEADD(day, 92, a.Cat_StartDate) 
		JOIN Marketing.DMPurchaseOrderItems OI ON OI.customerid = O.CustomerID 
										and OI.OrderID = O.Orderid 
		JOIN Mapping.vwAdcodesAll MA ON O.Adcode = MA.Adcode
    WHERE O.NetOrderAmount  BETWEEN 0 and 1500
    
--- Preethi Ramanujam 	08/20/2014  Add 1 Month OverAll, CourseDriven and NewCourse sales
    PRINT 'Step4b: Create 1 month Orders Table for the recipients'

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Step3_NCP_OrdersUpdt_1Month')
        DROP TABLE Staging.Step3_NCP_OrdersUpdt_1Month

    SELECT A.*, convert(int, 0) MailConsolidateID, O.OrderID, O.DateOrdered, O.Adcode OrderAdcode, 
        MA.AdcodeName AS OrderAdcodeName,
        MA.CatalogCode AS OrderCatalogcode, MA.CatalogName AS OrderCatalogName,
        convert(int, 0) OrderMailConsolidateID,
        O.Ordersource, O.NetOrderAmount,
        O.Shippingcharge, OI.CourseID, OI.StockItemID, OI.TotalQuantity,
        OI.TotalSales, OI.Salesprice
    INTO Staging.Step3_NCP_OrdersUpdt_1Month
    FROM Staging.Step2_NCP_CustomerListUpdt A 
		JOIN Marketing.DMPurchaseOrders O ON O.CustomerID  = A.CustomerID
									and O.DateOrdered BETWEEN a.Cat_StartDate AND DATEADD(day, 30, a.Cat_StartDate) 
		JOIN Marketing.DMPurchaseOrderItems OI ON OI.customerid = O.CustomerID 
										and OI.OrderID = O.Orderid 
		JOIN Mapping.vwAdcodesAll MA ON O.Adcode = MA.Adcode
    WHERE O.NetOrderAmount  BETWEEN 0 and 1500
    
/*

-- PR commented as it was taking hours and not complete. Using the updated query above. 
-- 2/28/2014

    SELECT A.*, convert(int, 0) MailConsolidateID, O.OrderID, O.DateOrdered, O.Adcode OrderAdcode, 
        MA.AdcodeName AS OrderAdcodeName,
        MA.CatalogCode AS OrderCatalogcode, MA.CatalogName AS OrderCatalogName,
        convert(int, 0) OrderMailConsolidateID,
        O.Ordersource, O.NetOrderAmount,
        O.Shippingcharge, OI.CourseID, OI.StockItemID, OI.TotalQuantity,
        OI.TotalSales, OI.Salesprice
    INTO Staging.Step3_NCP_OrdersUpdt
    FROM Staging.Step2_NCP_CustomerListUpdt A JOIN
        Marketing.DMPurchaseOrders O ON O.CustomerID  = A.CustomerID JOIN
        Marketing.DMPurchaseOrderItems OI ON OI.customerid = O.CustomerID and OI.OrderID = O.Orderid JOIN
        (SELECT DISTINCT CatalogCode, Cat_StartDate
        FROM Staging.Step1_NCP_NewCoursesUpdt) C ON A.Catalogcode = C.Catalogcode JOIN
        Mapping.vwAdcodesAll MA ON O.Adcode = MA.Adcode
    WHERE O.DateOrdered BETWEEN C.Cat_StartDate AND DATEADD(day, 92, C.Cat_StartDate)
    AND O.NetOrderAmount  BETWEEN 0 and 1500
*/
    
    -- ORDER BY A.CustomerID
    -- select * from Staging.Step1_NCP_NewCoursesUpdt
    -- select * from Staging.Step3_NCP_OrdersUpdt

--    CREATE CLUSTERED INDEX IX_Step3_NCP_OrdersUpdt1 on Staging.Step3_NCP_OrdersUpdt (CatalogCode,Adcode)
--    CREATE INDEX IX_Step3_NCP_OrdersUpdt2 on Staging.Step3_NCP_OrdersUpdt (CustomerID)
--    CREATE INDEX IX_Step3_NCP_OrdersUpdt3 on Staging.Step3_NCP_OrdersUpdt (OrderAdcode)
--    CREATE INDEX IX_Step3_NCP_OrdersUpdt4 on Staging.Step3_NCP_OrdersUpdt (OrderCatalogcode)
--    CREATE INDEX IX_Step3_NCP_OrdersUpdt5 on Staging.Step3_NCP_OrdersUpdt (DateOrdered)

    update a
    set a.MailconsolidateID = b.MailConsolidateID
    FROM Staging.Step3_NCP_OrdersUpdt a JOIN
        Staging.Step1_NCP_NewCoursesUpdt b on a.Catalogcode = B.Catalogcode

    update a
    set a.OrderMailConsolidateID = b.MailConsolidateID
    FROM Staging.Step3_NCP_OrdersUpdt a JOIN
        (SELECT distinct Catalogcode, MailConsolidateID
        from Staging.Step1_NCP_NewCoursesUpdt) b on a.OrderCatalogcode = B.Catalogcode


    -- Get Overall sales for 3 months since Course release date

    PRINT 'Step5: Get Overall sales for 3 months since Course release date'

    UPDATE A
    SET A.OverallSales_ActRecips_03Mo = B.OverallSales,
        A.OverallOrders_ActRecips_03Mo = B.OverallOrders
    FROM Staging.Step1_NCP_NewCoursesUpdt A JOIN
        (SELECT CatalogCode, Count(DISTINCT OrderID) OverallOrders, SUM(TotalSales) OverallSales
        from Staging.Step3_NCP_OrdersUpdt
        where TotalSales between 0 and 1500
        group by catalogcode)B ON A.Catalogcode = B.CatalogCode


    PRINT 'Step5b: Get Overall sales for 1 month since Course release date'

    UPDATE A
    SET A.OverallSales_ActRecips_01Mo = B.OverallSales,
        A.OverallOrders_ActRecips_01Mo = B.OverallOrders
    FROM Staging.Step1_NCP_NewCoursesUpdt A JOIN
        (SELECT CatalogCode, Count(DISTINCT OrderID) OverallOrders, SUM(TotalSales) OverallSales
        from Staging.Step3_NCP_OrdersUpdt_1Month
        where TotalSales between 0 and 1500
        group by catalogcode)B ON A.Catalogcode = B.CatalogCode
        
        
    -- Get Course sales for 3 months since Course release date

    PRINT 'Step6: Get Course sales for 3 months since Course release date'

    UPDATE A
    SET A.CourseSales_ActRecips_03Mo = B.OverallSales,
        A.CourseOrders_ActRecips_03Mo = B.OverallOrders
    FROM Staging.Step1_NCP_NewCoursesUpdt A JOIN
        (SELECT CatalogCode, CourseID, 
            Count(DISTINCT OrderID) OverallOrders, SUM(TotalSales) OverallSales
        from Staging.Step3_NCP_OrdersUpdt
        where TotalSales between 0 and 1500
        group by catalogcode, CourseID)B ON A.Catalogcode = B.CatalogCode and A.Courseid = B.CourseID

    PRINT 'Step6b: Get Course sales for 1 month since Course release date'

    UPDATE A
    SET A.CourseSales_ActRecips_01Mo = B.OverallSales,
        A.CourseOrders_ActRecips_01Mo = B.OverallOrders
    FROM Staging.Step1_NCP_NewCoursesUpdt A JOIN
        (SELECT CatalogCode, CourseID, 
            Count(DISTINCT OrderID) OverallOrders, SUM(TotalSales) OverallSales
        from Staging.Step3_NCP_OrdersUpdt_1Month
        where TotalSales between 0 and 1500
        group by catalogcode, CourseID)B ON A.Catalogcode = B.CatalogCode and A.Courseid = B.CourseID
        
    -- Get Course driven sales for 3 months since Course release date

    PRINT 'Step7: Get Course driven sales for 3 months since Course release date'

    UPDATE A
    SET A.CourseDrvnSales_ActRecips_03Mo = B.OverallSales,
        A.CourseDrvnOrders_ActRecips_03Mo = B.OverallOrders
    FROM Staging.Step1_NCP_NewCoursesUpdt A JOIN
        (SELECT O.Catalogcode, CO.CourseID, COUNT(Distinct O.OrderID) OverallOrders,
            SUM(O.TotalSales) OverallSales
        from Staging.Step3_NCP_OrdersUpdt O JOIN
            (SELECT DISTINCT O.OrderID, O.CourseID
            FrOM Staging.Step3_NCP_OrdersUpdt O JOIN
                (SELECT Distinct CourseID
                FrOM Staging.Step1_NCP_NewCoursesUpdt)NC ON O.CourseID = NC.CourseID)CO
                                        ON CO.OrderID = O.OrderID
        WHERE O.TotalSales BETWEEN 0 and 1500
        GROUP BY O.Catalogcode, CO.CourseID)B ON A.Catalogcode = B.CatalogCode and A.Courseid = B.CourseID


    PRINT 'Step7b: Get Course driven sales for 1 month since Course release date'

    UPDATE A
    SET A.CourseDrvnSales_ActRecips_01Mo = B.OverallSales,
        A.CourseDrvnOrders_ActRecips_01Mo = B.OverallOrders
    FROM Staging.Step1_NCP_NewCoursesUpdt A JOIN
        (SELECT O.Catalogcode, CO.CourseID, COUNT(Distinct O.OrderID) OverallOrders,
            SUM(O.TotalSales) OverallSales
        from Staging.Step3_NCP_OrdersUpdt_1Month O JOIN
            (SELECT DISTINCT O.OrderID, O.CourseID
            FrOM Staging.Step3_NCP_OrdersUpdt_1Month O JOIN
                (SELECT Distinct CourseID
                FrOM Staging.Step1_NCP_NewCoursesUpdt)NC ON O.CourseID = NC.CourseID)CO
                                        ON CO.OrderID = O.OrderID
        WHERE O.TotalSales BETWEEN 0 and 1500
        GROUP BY O.Catalogcode, CO.CourseID)B ON A.Catalogcode = B.CatalogCode and A.Courseid = B.CourseID
        
        
    -- Get Coded Overall sales for the catalogCodes

    PRINT 'Step8: Get Coded Overall sales for the catalogCodes'

    UPDATE A
    SET A.OverallSales_ActRecips_Coded = B.OverallSales,
        A.OverallOrders_ActRecips_Coded = B.OverallOrders
    FROM Staging.Step1_NCP_NewCoursesUpdt A JOIN
        (SELECT CatalogCode, Count(DISTINCT OrderID) OverallOrders, SUM(TotalSales) OverallSales
        from Staging.Step3_NCP_OrdersUpdt
        where TotalSales between 0 and 1500
        and OrderMailConsolidateID = MailConsolidateID
        group by catalogcode)B ON A.Catalogcode = B.CatalogCode

    -- Get Coded Course sales for these catalogcodes

    PRINT 'Step9: Get Coded Course sales for these catalogcodes'

    UPDATE A
    SET A.CourseSales_ActRecips_Coded = B.OverallSales,
        A.CourseOrders_ActRecips_Coded = B.OverallOrders
    FROM Staging.Step1_NCP_NewCoursesUpdt A JOIN
        (SELECT CatalogCode, CourseID, Count(DISTINCT OrderID) OverallOrders, SUM(TotalSales) OverallSales
        from Staging.Step3_NCP_OrdersUpdt
        where TotalSales between 0 and 1500
        and OrderMailConsolidateID = MailConsolidateID
        group by catalogcode, CourseID)B ON A.Catalogcode = B.CatalogCode AND A.CourseID = B.CourseID

select * from Staging.Step1_NCP_NewCoursesUpdt

    -- Get Course driven Coded sales

    PRINT 'Step10: Get Course driven Coded sales'

    UPDATE A
    SET A.CourseDrvnSales_ActRecips_Coded = B.OverallSales,
        A.CourseDrvnOrders_ActRecips_Coded = B.OverallOrders
    FROM Staging.Step1_NCP_NewCoursesUpdt A JOIN
        (SELECT O.Catalogcode, CO.CourseID, COUNT(Distinct O.OrderID) OverallOrders,
            SUM(O.TotalSales) OverallSales
        from Staging.Step3_NCP_OrdersUpdt O JOIN
            (SELECT DISTINCT O.OrderID, O.CourseID
            FrOM Staging.Step3_NCP_OrdersUpdt O JOIN
                (SELECT Distinct CourseID
                FrOM Staging.Step1_NCP_NewCoursesUpdt)NC ON O.CourseID = NC.CourseID)CO
                                        ON CO.OrderID = O.OrderID
        WHERE O.TotalSales BETWEEN 0 and 1500
        and O.OrderMailConsolidateID = O.MailConsolidateID
        GROUP BY O.Catalogcode, CO.CourseID)B ON A.Catalogcode = B.CatalogCode and A.Courseid = B.CourseID


    -- Create Orders Table for the recipients for life of catalog

    PRINT 'Step11: Create Orders Table for the recipients for life of catalog'

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Step9_NCP_Orders_CatLFUpdt')
        DROP TABLE Staging.Step9_NCP_Orders_CatLFUpdt

    SELECT A.*, convert(int, 0) MailConsolidateID, O.OrderID, O.DateOrdered, O.Adcode OrderAdcode, 
        MA.AdcodeName AS OrderAdcodeName,
        MA.CatalogCode AS OrderCatalogcode, MA.CatalogName AS OrderCatalogName,
        convert(int, 0) OrderMailConsolidateID,
        O.Ordersource, O.NetOrderAmount,
        O.Shippingcharge, OI.CourseID, OI.StockItemID, OI.TotalQuantity,
        OI.TotalSales, OI.Salesprice
    INTO Staging.Step9_NCP_Orders_CatLFUpdt
    FROM Staging.Step2_NCP_CustomerListUpdt A 
		JOIN Marketing.DMPurchaseOrders O ON O.CustomerID  = A.CustomerID 
										AND O.DateOrdered BETWEEN a.Cat_StartDate AND DATEADD(day, 1, a.Cat_StopDate) 
		JOIN Marketing.DMPurchaseOrderItems OI ON OI.customerid = O.CustomerID and OI.OrderID = O.Orderid 
        JOIN Mapping.vwAdcodesAll MA ON O.Adcode = MA.Adcode
    WHERE O.NetOrderAmount  BETWEEN 0 and 1500
    
/*  
-- PR commented as it was taking hours and not complete. Using the updated query above. 
-- 2/28/2014
  
    SELECT A.*, convert(int, 0) MailConsolidateID, O.OrderID, O.DateOrdered, O.Adcode OrderAdcode, 
        MA.AdcodeName AS OrderAdcodeName,
        MA.CatalogCode AS OrderCatalogcode, MA.CatalogName AS OrderCatalogName,
        convert(int, 0) OrderMailConsolidateID,
        O.Ordersource, O.NetOrderAmount,
        O.Shippingcharge, OI.CourseID, OI.StockItemID, OI.TotalQuantity,
        OI.TotalSales, OI.Salesprice
    INTO Staging.Step9_NCP_Orders_CatLFUpdt
    FROM Staging.Step2_NCP_CustomerListUpdt A JOIN
        Marketing.DMPurchaseOrders O ON O.CustomerID  = A.CustomerID JOIN
        Marketing.DMPurchaseOrderItems OI ON OI.customerid = O.CustomerID and OI.OrderID = O.Orderid JOIN
        (SELECT DISTINCT CatalogCode, Cat_StartDate, Cat_StopDate
        FROM Staging.Step1_NCP_NewCoursesUpdt) C ON A.Catalogcode = C.Catalogcode JOIN
        Mapping.vwAdcodesAll MA ON O.Adcode = MA.Adcode
    WHERE O.DateOrdered BETWEEN C.Cat_StartDate AND DATEADD(day, 1, C.Cat_StopDate)
    AND O.NetOrderAmount  BETWEEN 0 and 1500
    -- ORDER BY A.CustomerID
*/


--    CREATE CLUSTERED INDEX IX_Step9_NCP_Orders_CatLFUpdt1 on Staging.Step9_NCP_Orders_CatLFUpdt (CatalogCode,Adcode)
--    CREATE INDEX IX_Step9_NCP_Orders_CatLFUpdt2 on Staging.Step9_NCP_Orders_CatLFUpdt (CustomerID)
--    CREATE INDEX IX_Step9_NCP_Orders_CatLFUpdt3 on Staging.Step9_NCP_Orders_CatLFUpdt (OrderAdcode)
--    CREATE INDEX IX_Step9_NCP_Orders_CatLFUpdt4 on Staging.Step9_NCP_Orders_CatLFUpdt (OrderCatalogcode)
--    CREATE INDEX IX_Step9_NCP_Orders_CatLFUpdt5 on Staging.Step9_NCP_Orders_CatLFUpdt (DateOrdered)

    -- Get Overall sales for Life of the catalog

    PRINT 'Step12: Get Overall sales for Life of the catalog'

    UPDATE A
    SET A.OverallSales_ActRecips_CatLf = B.OverallSales,
        A.OverallOrders_ActRecips_CatLf = B.OverallOrders
    FROM Staging.Step1_NCP_NewCoursesUpdt A JOIN
        (SELECT CatalogCode, Count(DISTINCT OrderID) OverallOrders, SUM(TotalSales) OverallSales
        from Staging.Step9_NCP_Orders_CatLFUpdt
        where TotalSales between 0 and 1500
        group by catalogcode)B ON A.Catalogcode = B.CatalogCode

    -- Get Course sales  for Life of the catalog

    PRINT 'Step13: Get Course sales  for Life of the catalog'

    UPDATE A
    SET A.CourseSales_ActRecips_CatLf = B.OverallSales,
        A.CourseOrders_ActRecips_CatLf = B.OverallOrders
    FROM Staging.Step1_NCP_NewCoursesUpdt A JOIN
        (SELECT CatalogCode, CourseID, 
            Count(DISTINCT OrderID) OverallOrders, SUM(TotalSales) OverallSales
        from Staging.Step9_NCP_Orders_CatLFUpdt
        where TotalSales between 0 and 1500
        group by catalogcode, CourseID)B ON A.Catalogcode = B.CatalogCode and A.Courseid = B.CourseID

    -- Get Course driven  for Life of the catalog

    PRINT 'Step14: Get Course driven sales for  for Life of the catalog'

    UPDATE A
    SET A.CourseDrvnSales_ActRecips_CatLf = B.OverallSales,
        A.CourseDrvnOrders_ActRecips_CatLf = B.OverallOrders
    FROM Staging.Step1_NCP_NewCoursesUpdt A JOIN
        (SELECT O.Catalogcode, CO.CourseID, COUNT(Distinct O.OrderID) OverallOrders,
            SUM(O.TotalSales) OverallSales
        from Staging.Step9_NCP_Orders_CatLFUpdt O JOIN
            (SELECT DISTINCT O.OrderID, O.CourseID
            FrOM Staging.Step9_NCP_Orders_CatLFUpdt O JOIN
                (SELECT Distinct CourseID
                FrOM Staging.Step1_NCP_NewCoursesUpdt)NC ON O.CourseID = NC.CourseID)CO
                                        ON CO.OrderID = O.OrderID
        WHERE O.TotalSales BETWEEN 0 and 1500
        GROUP BY O.Catalogcode, CO.CourseID)B ON A.Catalogcode = B.CatalogCode and A.Courseid = B.CourseID

    UPDATE Staging.Step1_NCP_NewCoursesUpdt
    SET releaseyear = releaseyear + 1
    WHERE month(releasedate) = 12

    -- Update Main table

    PRINT 'Step15: Update the main table'

    DELETE MT
    FROM Marketing.Step1_NCP_NewCourses MT JOIN
        (SELECT DISTINCT CourseID, Catalogcode
        FROM Staging.Step1_NCP_NewCoursesUpdt)Tmp ON MT.CourseID = Tmp.CourseID 
                                and MT.CatalogCode = Tmp.CatalogCode

select * from Staging.Step1_NCP_NewCoursesUpdt

    INSERT INTO Marketing.Step1_NCP_NewCourses
    SELECT * FROM Staging.Step1_NCP_NewCoursesUpdt

    -- Special Case
    UPDATE Mapping.DMCourse
    set Releasedate = '4/7/2010'
    where courseid = 9123

    UPDATE Mapping.DMCourse
    set Releasedate = '11/28/2011'
    where courseid = 9144
    
    -- Drop Xmaslog for Dec courses
	Delete from Marketing.Step1_NCP_NewCourses
	where CourseID in (3466,1933,9144,1730)
	and CatalogCode in (22077)

    -- Drop xmaslog for Dec courses for 2012
	Delete from Marketing.Step1_NCP_NewCourses
	where CourseID in (9253,2140,6610,9231,9382)
	and MailConsolidateName = '2012 XmasLog'

    -- Drop xmaslog course from Dec catalog for 2012
	Delete from Marketing.Step1_NCP_NewCourses
	where CourseID in (8276)
	and MailConsolidateName = 'DECCAT2012 2012'    

    -- Drop xmaslog for Dec courses for 2013
	Delete from Marketing.Step1_NCP_NewCourses
	where CourseID in (1740,1997,2201,3021,7912)
	and MailConsolidateName = 'XmaSlog2013 2013'

    -- Drop xmaslog course from Dec catalog for 2013
	Delete from Marketing.Step1_NCP_NewCourses
	where CourseID in (2291)
	and MailConsolidateName = 'DECCAT2013 2013'    	
	
    PRINT 'END Staging.NewCoursePerfUpdate'

end
GO
