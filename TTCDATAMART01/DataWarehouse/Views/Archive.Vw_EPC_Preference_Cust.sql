SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [Archive].[Vw_EPC_Preference_Cust]
as
select a.CustomerID
,			c.Sub
,			b.Unsub
,			case when Sub=1 and Unsub is null then 'Subscribed'
					when Sub=1 and Unsub=1 then 'Both'
					when Sub is null and Unsub=1 then 'Unsub'
					else null end as SubCategory
from DataWarehouse.Marketing.epc_preference(nolock) as a
left join (select customerid, subscribed, 1 as Unsub
				from DataWarehouse.Marketing.epc_preference(nolock)
				where subscribed=0) as b
				on a.CustomerID=b.CustomerID
left join (select customerid, subscribed, 1 as Sub
				from DataWarehouse.Marketing.epc_preference(nolock)
				where subscribed=1) as c
				on a.CustomerID=c.CustomerID
Group by a.CustomerID, c.Sub, b.Unsub
GO
