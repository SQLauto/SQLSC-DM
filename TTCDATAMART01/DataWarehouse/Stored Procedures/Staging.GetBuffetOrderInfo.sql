SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [Staging].[GetBuffetOrderInfo]
AS
BEGIN
	set nocount on
    
    TRUNCATE TABLE Staging.TempBuffetOrders

    INSERT INTO Staging.TempBuffetOrders
    SELECT YEAR(a.DateOrdered) YearOrdered,
        MONTH(a.DateOrdered) MonthOrdered,
        CONVERT(VARCHAR,a.DateOrdered,101) DateOrdered,
        CASE WHEN a.SequenceNum = 1 THEN 'NewCustomer'
            ELSE 'ExistingCustomer'
        END AS CustomerType,
        a.Adcode, B.AdcodeName, b.CatalogCode, b.CatalogName,
        a.PromotionType as PromotionTypeID,
        c.PromotionType as PromotionTypeName,
        a.OrderSource, a.OrderID, a.NetOrderAmount,
        a.ShippingCharge, isnull(a.TotalCourseQuantity, 0), 
        isnull(a.TotalCourseParts, 0),
        CONVERT(varchar,getdate(),101) ReportDate,
        CONVERT(TINYINT,0) as FlagBoughtUpsell801
    FROM Marketing.DMPurchaseOrders a (nolock) join
        Mapping.vwAdcodesAll b (nolock) on a.AdCode = b.Adcode join
        Mapping.DMPromotionType  (nolock) c on a.CatalogCode = c.CatalogCode
    WHERE a.DateOrdered >= '1/1/2011' AND
        a.FlagLowPriceLeader = 1

    UPDATE A
    SET A.FlagBoughtUpsell801 = 1
    FROM Staging.TempBuffetOrders a JOIN
        (SELECT DISTINCT OrderID
        FROM Marketing.DMPurchaseOrderItems (nolock)
        where BundleID = 801)b on a.OrderID = b.OrderID

    TRUNCATE TABLE Staging.BuffetOrders

    INSERT INTO Staging.BuffetOrders
    SELECT * FROM Staging.TempBuffetOrders (nolock)

    TRUNCATE TABLE Staging.TempBuffetOrders

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'BuffetOrders_Agg')
        DROP TABLE Staging.BuffetOrders_Agg

    SELECT YearOrdered, MonthOrdered, DateOrdered, CustomerType,
        Adcode, AdcodeName, CatalogCode, CatalogName,
        PromotionTypeID, PromotionTypeName,
        OrderSource, ReportDate, FlagBoughtUpsell801,
        count(OrderID) TotalOrders, 
        sum(NetOrderAmount) TotalSales,
        sum(ShippingCharge) TotalShippingCharge, 
        sum(TotalCourseQuantity) TotalCourseQuantity, 
        sum(TotalCourseParts) TotalCourseParts
    INTO Staging.BuffetOrders_Agg
    FROM Staging.BuffetOrders (nolock)
    GROUP BY YearOrdered, MonthOrdered, DateOrdered, CustomerType,
        Adcode, AdcodeName, CatalogCode, CatalogName,
        PromotionTypeID, PromotionTypeName,
        OrderSource, ReportDate, FlagBoughtUpsell801

END
GO
