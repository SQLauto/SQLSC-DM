SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Staging].[vwCC_MonthlyLargeOrders] 
AS

	-- Preethi Ramanujam    3/10/2014 Monthly large order list for customer care

	select a.Orderid,
		a.DateOrdered,
		year(a.DateOrdered) YearOrdered,
		month(a.DateOrdered) MonthOrdered,
		a.OrderSource,
		a.Customerid,
		b.PublicLibrary,
		b.OtherInstitution,
		a.NetOrderAmount,
		a.CurrencyCode,
		GETDATE() as ReportDate
	from datawarehouse.Marketing.DMPurchaseOrders a join
		DataWarehouse.Marketing.CampaignCustomerSignature b on a.CustomerID = b.CustomerID
	where Year(DateOrdered) >= YEAR(DATEADD(year,-2,getdate()))
	--and MONTH(Dateordered) = month(DATEADD(month,-1,getdate()))
	and NetOrderAmount >= 2000


GO
