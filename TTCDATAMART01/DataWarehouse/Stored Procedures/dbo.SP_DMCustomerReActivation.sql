SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_DMCustomerReActivation]
as
Begin

/* All Customers Who Were Swamps Or Deeper*/
--select CustomerID, MIN(DateOrdered) DateOrdered, Min(SequenceNum)SequenceNum
--into #CustReactivation 
--from DataWarehouse.Marketing.DMPurchaseOrders
--where NewSegprior >=6
--and NewSegprior not in (8,9,10) /*Except Active Multi */
--group by CustomerID
--having MIN(DateOrdered)>= '2010/01/01' /*ReActivation Calculation Date Filter*/
select DM.CustomerID, DateOrdered,DM.CustomerID + '-'+convert(char(8), DateOrdered, 112) as CustomerKey , Min(DM.SequenceNum)SequenceNum 
into #CustReactivation
from DataWarehouse.Marketing.DMPurchaseOrders DM
where NewSegprior >=6 and NewSegprior not in (8,9,10) /*Except Active Multi */
and DM.DateOrdered>= '2010/01/01'
group by DM.CustomerID,DM.DateOrdered



If OBJECT_ID ('DataWarehouse.Marketing.DMCustomerReActivation') is not null
Drop table DataWarehouse.Marketing.DMCustomerReActivation

select CR.CustomerKey,DM.OrderID,DM.CustomerID,DM.OrderSource,DM.DateOrdered,DM.SequenceNum,DM.DownStreamDays,DM.DaysSinceLastPurchase,DM.CSRID,DM.CSRID_actual,DM.CatalogCode,DM.AdCode,
DM.PromotionType,DM.FlagCouponRedm,DM.DiscountAmount,DM.NetOrderAmount,DM.FlagSplitShipment,DM.FinalSales,DM.TotalCourseQuantity,DM.TotalCourseParts,DM.TotalCourseSales,
DM.TotalTranscriptQuantity,DM.TotalTranscriptParts,DM.TotalTranscriptSales,DM.PriorPurchaseOrderAmount,DM.PriorPurchaseOrderSource,DM.PriorPurchaseAdcode,DM.BillingCountryCode,
DM.FlagDVDatCDProspect,DM.FlagEmailOrder,DM.CustomerSegmentPrior,DM.FrequencyPrior,DM.NewsegPrior,DM.NamePrior,DM.A12mfPrior,DM.PriorSales,DM.PriorOrders,DM.PriorAOS,
DM.ConcatenatedPrior,DM.RecencyPrior,DM.MonetaryValuePrior,DM.Age,DM.AgeBin,DM.FlagDigitalPhysical,DM.FlagAudioVideo,DM.CustomerSegment2Prior,DM.CustomerSegmentFnlPrior,
DM.GiftFlag,DM.ShipRegion,DM.ShipCountryCode,DM.BillingRegion,DM.Coupon,DM.CouponDesc
Into DataWarehouse.Marketing.DMCustomerReActivation
from #CustReactivation CR 
inner join DataWarehouse.Marketing.DMPurchaseOrders DM
On CR.CustomerID = DM.CustomerID
and CR.DateOrdered = DM.DateOrdered
and CR.SequenceNum = DM.SequenceNum


If OBJECT_ID ('DataWarehouse.Marketing.DMCustomerReActivationOrders') is not null
Drop table DataWarehouse.Marketing.DMCustomerReActivationOrders


select DMCR.CustomerKey,DM.OrderID,DM.CustomerID,DM.OrderSource,DM.DateOrdered,(DM.SequenceNum-DMCR.SequenceNum+1)as SequenceNum,(DM.DownStreamDays-DMCR.DownStreamDays) as DownStreamDays,
DM.DaysSinceLastPurchase,DM.CSRID,DM.CSRID_actual,DM.CatalogCode,DM.AdCode,DM.PromotionType,DM.FlagCouponRedm,DM.DiscountAmount,DM.NetOrderAmount,DM.FlagSplitShipment,
DM.FinalSales,DM.TotalCourseQuantity,DM.TotalCourseParts,DM.TotalCourseSales,DM.TotalTranscriptQuantity,DM.TotalTranscriptParts,DM.TotalTranscriptSales,DM.PriorPurchaseOrderAmount,
DM.PriorPurchaseOrderSource,DM.PriorPurchaseAdcode,DM.BillingCountryCode,DM.FlagDVDatCDProspect,DM.FlagEmailOrder,DM.CustomerSegmentPrior,DM.FrequencyPrior,DM.NewsegPrior,
DM.NamePrior,DM.A12mfPrior,DM.PriorSales,DM.PriorOrders,DM.PriorAOS,DM.ConcatenatedPrior,DM.RecencyPrior,DM.MonetaryValuePrior,DM.Age,DM.AgeBin,DM.FlagDigitalPhysical,
DM.FlagAudioVideo,DM.CustomerSegment2Prior,DM.CustomerSegmentFnlPrior,DM.GiftFlag,DM.ShipRegion,DM.ShipCountryCode,DM.BillingRegion,DM.Coupon,DM.CouponDesc
Into DataWarehouse.Marketing.DMCustomerReActivationOrders
from DataWarehouse.Marketing.DMCustomerReActivation DMCR 
inner join DataWarehouse.Marketing.DMPurchaseOrders DM
On DM.CustomerID = DMCR.CustomerID
and DM.DateOrdered >= DMCR.DateOrdered



drop table #CustReactivation


--Calculate DownstreamMonthly Contact
Exec [dbo].[SP_CustomerReactivation_Contact_DownStream]

--Calculate Reactivation Orders
Exec [Staging].[LoadDMCustomerReactivationStaticNew]
End



GO
