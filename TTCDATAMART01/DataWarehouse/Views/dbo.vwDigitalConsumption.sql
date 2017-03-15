SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  View [dbo].[vwDigitalConsumption]
as

select hist.*,ord.CustomerSegmentPrior,ord.FrequencyPrior,ord.CustomerSegmentFnlPrior,ord.NamePrior,ord.NewsegPrior,ord.A12mfPrior
from [Archive].[DigitalConsumptionHistory] hist
left join Marketing.DMPurchaseOrders ord
on hist.OrderID=ord.OrderID
GO
