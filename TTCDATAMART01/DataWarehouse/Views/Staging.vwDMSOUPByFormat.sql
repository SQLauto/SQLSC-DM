SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Staging].[vwDMSOUPByFormat]
AS


select a.OrderID, b.Dateordered, 
	sum(case when a.FormatMedia in ('C','M') then a.Totalsales else 0 end) CDSales,
	sum(case when a.FormatMedia in ('C','M') then a.TotalQuantity else 0 end) CDUnits,
	sum(case when a.FormatMedia in ('C','M') then a.TotalParts else 0 end) CDParts,
	sum(case when a.FormatMedia in ('D','M') then a.Totalsales else 0 end) DVDSales,
	sum(case when a.FormatMedia in ('D','M') then a.TotalQuantity else 0 end) DVDUnits,
	sum(case when a.FormatMedia in ('D','M') then a.TotalParts else 0 end) DVDParts,
	sum(case when a.FormatMedia in ('A') then a.Totalsales else 0 end) AudioTapeSales,
	sum(case when a.FormatMedia in ('A') then a.TotalQuantity else 0 end) AudioTapeUnits,
	sum(case when a.FormatMedia in ('A') then a.TotalParts else 0 end) AudioTapeParts,
	sum(case when a.FormatMedia in ('V') then a.Totalsales else 0 end) VHSSales,
	sum(case when a.FormatMedia in ('V') then a.TotalQuantity else 0 end) VHSUnits,
	sum(case when a.FormatMedia in ('V') then a.TotalParts else 0 end) VHSParts,
	sum(case when a.FormatMedia in ('DL') then a.Totalsales else 0 end) AudioDLSales,
	sum(case when a.FormatMedia in ('DL') then a.TotalQuantity else 0 end) AudioDLUnits,
	sum(case when a.FormatMedia in ('DL') then a.TotalParts else 0 end) AudioDLParts,
	sum(case when a.FormatMedia in ('DV') then a.Totalsales else 0 end) VideoDLSales,
	sum(case when a.FormatMedia in ('DV') then a.TotalQuantity else 0 end) VideoDLUnits,
	sum(case when a.FormatMedia in ('DV') then a.TotalParts else 0 end) VideoDLParts,
	sum(case when a.FormatMedia in ('T') then a.Totalsales else 0 end) TranscriptSales,
	sum(case when a.FormatMedia in ('T') then a.TotalQuantity else 0 end) TranscriptUnits,
	sum(case when a.FormatMedia in ('T') then a.TotalParts else 0 end) TranscriptParts,
	sum(case when a.FormatMedia in ('DT') then a.Totalsales else 0 end) DigitalTranscriptSales,
	sum(case when a.FormatMedia in ('DT') then a.TotalQuantity else 0 end) DigitalTranscriptUnits,
	sum(case when a.FormatMedia in ('DT') then a.TotalParts else 0 end) DigitalTranscriptParts,
	sum(case when a.FormatMedia in ('DL','DV','DT') then a.Totalsales else 0 end) DigitalSales,
	sum(case when a.FormatMedia in ('DL','DV','DT') then a.TotalQuantity else 0 end) DigitalUnits,
	sum(case when a.FormatMedia in ('DL','DV','DT') then a.TotalParts else 0 end) DigitalParts,
	sum(case when a.FormatMedia in ('C','M','A','V','D','T') then a.Totalsales else 0 end) PhysicalSales,
	sum(case when a.FormatMedia in ('C','M','A','V','D','T') then a.TotalQuantity else 0 end) PhysicalUnits,
	sum(case when a.FormatMedia in ('C','M','A','V','D','T') then a.TotalParts else 0 end) PhysicalParts
from DataWarehouse.staging.ValidPurchaseOrderItems a with (nolock) join
	DataWarehouse.Marketing.DMPurchaseOrders b with (nolock) on a.OrderID = b.OrderID
-- where FlagReturn = 0
group by a.OrderID, b.DateOrdered



GO
