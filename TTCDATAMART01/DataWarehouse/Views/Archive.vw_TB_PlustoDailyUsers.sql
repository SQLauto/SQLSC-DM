SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Archive].[vw_TB_PlustoDailyUsers] as
select 
a.*,
b.id, b.joined, 
c.IntlMD_Channel,
c.IntlSubDate, c.IntlSubType, c.IntlSubPaymentHandler,
case
	when c.IntlSubPaymentHandler is NULL then 'Registration' else 'Subscription' end as CustomerType
from TestSummary.dbo.MAS_daily_user_id (nolock) a
	left join DataWarehouse.Archive.tgcplus_user (nolock) b on a.uuid = b.uuid 
	left join DataWarehouse.Marketing.TGCPlus_CustomerSignature (nolock) c on b.ID = c.CustomerID 
where id is not null; 
GO
