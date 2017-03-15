SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [Staging].[GetEmailTrackerSalesOrder]
(
	@CatalogCode int
)
returns table
as
	return
    
    select Ord.OldCampaignID, Ord.OldCampaignName,Ord.CatalogCode, 
		Ord.CatalogName, Ord.Adcode, Ord.AdcodeName, 
        '' as EHistStartDate, ord.StartDate, ord.StopDate, ord.CustomerID, 
        ord.PiecesMailed,
        'CCN2M' ComboID,101 SeqNum, 'CCN2M' CustomerSegment, 
        Null MultiOrSingle, NULL NewSeg, Null Name, NULL A12mf, 1 FlagEmailed,Ord.OrderSource,
        sum(ord.NetOrderAmount)TotalSales, sum(ord.TotalOrders) TotalOrders,
        SUM(ord.TotalCourseSales) TotalCourseSales,
        SUM(ord.TotalCourseUnits) TotalCourseUnits,
        SUM(ord.TotalCourseParts) TotalCourseParts
    from 
        (
            select ACA.Adcode, ACA.AdcodeName, ACA.CatalogCode, ACA.CatalogName, ACA.OldCampaignID, ACA.OldCampaignName, 
            ACA.StartDate, ACA.StopDate,O.customerID, ACA.PiecesMailed,
            O.Ordersource,sum(netOrderamount)NetOrderAmount,count(orderid) TotalOrders,
            SUM(O.TotalCourseSales) TotalCourseSales,
			SUM(O.TotalCourseQuantity) TotalCourseUnits,
			SUM(O.TotalCourseParts) TotalCourseParts
       -- FrOM Staging.vwOrders O (nolock) JOIN
			FrOM marketing.DMPurchaseOrders O (nolock) JOIN
            Mapping.vwAdcodesall ACA (nolock) ON O.Adcode=ACA.adcode 
        WHERE netorderamount between 0 and 1500
        AND ACA.CatalogCode = @CatalogCode
        group by ACA.Adcode, ACA.AdcodeName, ACA.CatalogCode, ACA.CatalogName, ACA.OldCampaignID, ACA.OldCampaignName, 
            ACA.StartDate, ACA.StopDate,O.customerid,ACA.PiecesMailed,O.Ordersource
        ) Ord 
        left outer join
        (select ACA.CatalogCode,O.customerID,sum(TotalSales) TS,Sum(TotalOrders) TotalOrders
        FrOM  Staging.Email_SalesAndOrders_Update O (nolock) JOIN
            Mapping.vwAdcodesall ACA (nolock) ON O.Adcode=ACA.adcode
        WHERE ACA.CatalogCode = @CatalogCode
        group by ACA.CatalogCode,customerID)eso on ord.Catalogcode = eso.catalogcode and ord.customerID = eso.customerid
    where eso.customerID is null
    group by Ord.Adcode, Ord.AdcodeName, Ord.CatalogCode, Ord.CatalogName, 
        Ord.OldCampaignID, Ord.OldCampaignName, ord.StartDate, ord.StopDate, 
                Ord.CustomerID, Ord.PiecesMailed, Ord.OrderSource
GO
