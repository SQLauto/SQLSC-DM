SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[vw_TGCPlus_Roku_Transactions] as
select user_id, event_date, transtype, type, quantity, net_amount,
ROW_NUMBER() OVER(PARTITION by user_id ORDER BY event_date, transtype, product_code) as rn
from (select *, case when transaction_type = 'Purchase' then 'Purchase' else 'Cancellation' end as transtype, case when product_code like '%month%' then 'Month'  when product_code like '%annual%' then 'Annual' end as Type  from archive.tgcplus_roku_transactions) a
where product_code not in ('plana', 'planb'); 
GO
