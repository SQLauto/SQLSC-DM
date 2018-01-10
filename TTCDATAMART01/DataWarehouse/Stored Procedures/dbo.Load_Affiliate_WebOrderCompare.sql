SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Load_Affiliate_WebOrderCompare]

AS

BEGIN

INSERT INTO Marketing.Affiliate_WebOrderCompare

select cast(getdate() as date) ReportDate,
       c.*,
       a.OrderID, a.Orderdate, (a.TotalMerchandise + a.TotalCoupons + a.TotalShipping + a.OtherCharges) as Sales,
       a.SourceCode as Campaign,
       b.AdcodeName as CampaignName,
       b.CatalogCode as OfferCode, b.CatalogName OfferName,
       b.ChannelID as MD_ChannelID, b.MD_Channel, 
       b.MD_PromotionTypeID, b.MD_PromotionType,
       b.MD_CampaignID, b.MD_CampaignName,
       a.OrderStatus, d.SalesStatusValue as OrderStatusValue
--into Datawarehouse.Marketing.Affiliate_WebOrderCompare
from Mapping.Affiliate_WebOrders c
       left join DAXImports..DAX_OrderExport a  on a.WebOrderID = c.OID
       left join DataWarehouse.Mapping.vwAdcodesAll b on a.SourceCode = b.AdCode
       left join DAXImports..DAX_SalesStatus d on a.OrderStatus = d.SalesStatusCode

END
GO
