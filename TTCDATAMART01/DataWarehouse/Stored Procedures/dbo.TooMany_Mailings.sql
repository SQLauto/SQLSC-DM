SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[TooMany_Mailings] as


Select distinct CustomerID into #temp1 FROM Staging.Customer_TooMany_Mailings

where customerId  not in  ( select distinct CustomerId from Mapping.Customers_TooManyMailings) and customerid is not null

Select CustomerID  from #temp1

Insert into Mapping.Customers_TooManyMailings

Select a.*, 'Yes' as FlagMainCatalogOnly  , getdate() as InsertDate from #temp1 a


drop table #temp1

	
GO
