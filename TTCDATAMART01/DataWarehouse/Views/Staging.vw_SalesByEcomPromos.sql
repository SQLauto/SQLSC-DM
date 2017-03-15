SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Staging].[vw_SalesByEcomPromos]
AS
			
select Year(a.DateOrdered) YearOrdered,		
		month(a.DateOrdered) MonthOrdered,
		Staging.GetMonday(a.dateordered) WeekOrdered,
		a.PromotionType as PromotionTypeID,
		b.PromotionType,
		COUNT(a.OrderID) TotalOrders,
		SUM(a.NetOrderAmount) TotalSales,
		GETDATE() as ReportDate
from DataWarehouse.Marketing.DMPurchaseOrders a join		
	(select * from MarketingCubes..DimPromotionType	
	where PromotionTypeFlag2 = 'Ecom')b on a.PromotionType = b.PromotionTypeID	
where a.DateOrdered >= '1/1/2013'		
group by Year(a.DateOrdered) ,		
		month(a.DateOrdered) ,
		Staging.GetMonday(a.dateordered),
		a.PromotionType ,
		b.PromotionType
	


GO
