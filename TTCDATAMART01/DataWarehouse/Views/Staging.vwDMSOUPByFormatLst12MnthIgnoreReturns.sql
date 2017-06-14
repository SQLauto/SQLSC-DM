SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Staging].[vwDMSOUPByFormatLst12MnthIgnoreReturns]
AS


select b.CustomerID,
	a.OrderID, 
	b.Dateordered, 
	b.NetOrderAmount,
	b.ShippingCharge, 
	b.DiscountAmount, 
	b.Tax,
	b.OrderSource,
	b.AdCode,
	--Max(case when a.FormatMedia in ('C','M') then 1 else 0 end) FlagCD,
	sum(case when a.FormatMedia in ('C','M') then a.Totalsales else 0 end) CDSales,
	sum(case when a.FormatMedia in ('C','M') then a.TotalQuantity else 0 end) CDUnits,
	sum(case when a.FormatMedia in ('C','M') then a.TotalParts else 0 end) CDParts,
	--max(case when a.FormatMedia in ('D','M') then 1 else 0 end) FlagDVD,
	sum(case when a.FormatMedia in ('D','M') then a.Totalsales else 0 end) DVDSales,
	sum(case when a.FormatMedia in ('D','M') then a.TotalQuantity else 0 end) DVDUnits,
	sum(case when a.FormatMedia in ('D','M') then a.TotalParts else 0 end) DVDParts,
	--max(case when a.FormatMedia in ('A') then 1 else 0 end) FlagAudioTape,
	sum(case when a.FormatMedia in ('A') then a.Totalsales else 0 end) AudioTapeSales,
	sum(case when a.FormatMedia in ('A') then a.TotalQuantity else 0 end) AudioTapeUnits,
	sum(case when a.FormatMedia in ('A') then a.TotalParts else 0 end) AudioTapeParts,
	--max(case when a.FormatMedia in ('V') then 1 else 0 end) FlagVHS,
	sum(case when a.FormatMedia in ('V') then a.Totalsales else 0 end) VHSSales,
	sum(case when a.FormatMedia in ('V') then a.TotalQuantity else 0 end) VHSUnits,
	sum(case when a.FormatMedia in ('V') then a.TotalParts else 0 end) VHSParts,
	--max(case when a.FormatMedia in ('DL') then 1 else 0 end) FlagAudioDL,
	sum(case when a.FormatMedia in ('DL') then a.Totalsales else 0 end) AudioDLSales,
	sum(case when a.FormatMedia in ('DL') then a.TotalQuantity else 0 end) AudioDLUnits,
	sum(case when a.FormatMedia in ('DL') then a.TotalParts else 0 end) AudioDLParts,
	--max(case when a.FormatMedia in ('DV') then 1 else 0 end) FlagVideoDL,
	sum(case when a.FormatMedia in ('DV') then a.Totalsales else 0 end) VideoDLSales,
	sum(case when a.FormatMedia in ('DV') then a.TotalQuantity else 0 end) VideoDLUnits,
	sum(case when a.FormatMedia in ('DV') then a.TotalParts else 0 end) VideoDLParts,
	--max(case when left(a.StockItemID,2) = 'PT' then 1 else 0 end) FlagTranscript,
	sum(case when left(a.StockItemID,2) = 'PT' then a.Totalsales else 0 end) TranscriptSales,
	sum(case when left(a.StockItemID,2) = 'PT' then a.TotalQuantity else 0 end) TranscriptUnits,
	sum(case when left(a.StockItemID,2) = 'PT' then a.TotalParts else 0 end) TranscriptParts,
	--max(case when left(a.StockItemID,2) = 'DT' then a.Totalsales else 0 end) FlagDigitalTranscript,
	sum(case when left(a.StockItemID,2) = 'DT' then a.Totalsales else 0 end) DigitalTranscriptSales,
	sum(case when left(a.StockItemID,2) = 'DT' then a.TotalQuantity else 0 end) DigitalTranscriptUnits,
	sum(case when left(a.StockItemID,2) = 'DT' then a.TotalParts else 0 end) DigitalTranscriptParts,
	--max(case when left(a.StockItemID,2) in ('DA','DV','DT') then 1 else 0 end) FlagDigital,
	sum(case when left(a.StockItemID,2) in ('DA','DV','DT') then a.Totalsales else 0 end) DigitalSales,
	sum(case when left(a.StockItemID,2) in ('DA','DV','DT') then a.TotalQuantity else 0 end) DigitalUnits,
	sum(case when left(a.StockItemID,2) in ('DA','DV','DT') then a.TotalParts else 0 end) DigitalParts,
	--max(case when left(a.StockItemID,2) in ('PC','PM','PA','PV','PD','PT') then 1 else 0 end) FlagPhysical,
	sum(case when left(a.StockItemID,2) in ('PC','PM','PA','PV','PD','PT') then a.Totalsales else 0 end) PhysicalSales,
	sum(case when left(a.StockItemID,2) in ('PC','PM','PA','PV','PD','PT') then a.TotalQuantity else 0 end) PhysicalUnits,
	sum(case when left(a.StockItemID,2) in ('PC','PM','PA','PV','PD','PT') then a.TotalParts else 0 end) PhysicalParts,
	sum(a.TotalSales) TotalMerchandizeSales,
	sum(a.TotalQuantity) TotalMerchandizeUnits,
	sum(a.TotalParts) TotalMerchandizeParts
from Marketing.DMPurchaseOrderItems a with (nolock) join
	Marketing.DMPurchaseOrdersIgnoreReturns b with (nolock) on a.OrderID = b.OrderID join
	(select distinct customerid, OrderID from Staging.MostRecent3OrdersLst12MnthCDCR) c on b.OrderID = c.OrderID
group by b.CustomerID, 
		a.OrderID, 
		b.DateOrdered, 
		b.NetOrderAmount, 
		b.ShippingCharge, 
		b.DiscountAmount, 
		b.Tax,
		b.OrderSource,
		b.AdCode








GO
