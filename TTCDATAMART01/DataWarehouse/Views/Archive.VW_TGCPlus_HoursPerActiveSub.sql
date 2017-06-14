SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[VW_TGCPlus_HoursPerActiveSub] AS
Select AsofDate, TGCCustomerFlag, Customers, StreamedMinutes from
(
Select 
'2017-03-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '4/1/2017' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2017-03-01' and convert(date, b.tstamp)<= '2017-03-31'
group by a.TGCCustFlag
UNION ALL
select 
'2017-02-28' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '3/1/2017' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2017-02-01' and convert(date, b.tstamp)<= '2017-02-28'
group by a.TGCCustFlag
UNION ALL
select 
'2017-01-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '2/1/2017' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2017-01-01' and convert(date, b.tstamp)<= '2017-01-31'
group by a.TGCCustFlag
UNION ALL
select 
'2016-03-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '4/1/2016' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2016-03-01' and convert(date, b.tstamp)<= '2016-03-31'
group by a.TGCCustFlag
UNION ALL
select 
'2016-02-28' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '3/1/2016' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2016-02-01' and convert(date, b.tstamp)<= '2016-02-28'
group by a.TGCCustFlag
UNION ALL
select 
'2016-01-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '2/1/2016' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2016-01-01' and convert(date, b.tstamp)<= '2016-01-31'
group by a.TGCCustFlag
UNION ALL
select 
'2016-04-30' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '5/1/2016' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2016-04-01' and convert(date, b.tstamp)<= '2016-04-30'
group by a.TGCCustFlag
UNION ALL
select 
'2016-05-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '6/1/2016' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2016-05-01' and convert(date, b.tstamp)<= '2016-05-31'
group by a.TGCCustFlag
UNION ALL
select 
'2016-06-30' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '7/1/2016' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2016-06-01' and convert(date, b.tstamp)<= '2016-06-30'
group by a.TGCCustFlag
UNION ALL
select 
'2016-07-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '8/1/2016' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2016-07-01' and convert(date, b.tstamp)<= '2016-07-31'
group by a.TGCCustFlag
UNION ALL
select 
'2016-08-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '9/1/2016' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2016-08-01' and convert(date, b.tstamp)<= '2016-08-31'
group by a.TGCCustFlag
UNION ALL
select 
'2016-09-30' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '10/1/2016' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2016-09-01' and convert(date, b.tstamp)<= '2016-09-30'
group by a.TGCCustFlag
UNION ALL
select 
'2016-10-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '11/1/2016' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2016-10-01' and convert(date, b.tstamp)<= '2016-10-31'
group by a.TGCCustFlag
UNION ALL
select 
'2016-11-30' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '12/1/2016' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2016-11-01' and convert(date, b.tstamp)<= '2016-11-30'
group by a.TGCCustFlag
UNION ALL
select 
'2016-12-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '01/1/2017' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2016-12-01' and convert(date, b.tstamp)<= '2016-12-31'
group by a.TGCCustFlag
UNION ALL
select
'2017-04-30' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '5/1/2017' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2017-04-01' and convert(date, b.tstamp)<= '2017-04-30'
group by a.TGCCustFlag
UNION ALL
select 
'2017-05-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '6/1/2017' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2017-05-01' and convert(date, b.tstamp)<= '2017-05-31'
group by a.TGCCustFlag
UNION ALL
select 
'2017-06-30' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '7/1/2017' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2017-06-01' and convert(date, b.tstamp)<= '2017-06-30'
group by a.TGCCustFlag
UNION ALL
select 
'2017-07-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '8/1/2017' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2017-07-01' and convert(date, b.tstamp)<= '2017-07-31'
group by a.TGCCustFlag
UNION ALL
select 
'2017-08-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '9/1/2017' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2017-08-01' and convert(date, b.tstamp)<= '2017-08-31'
group by a.TGCCustFlag
UNION ALL
select 
'2017-09-30' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '10/1/2017' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2017-09-01' and convert(date, b.tstamp)<= '2017-09-30'
group by a.TGCCustFlag
UNION ALL
select 
'2017-10-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '11/1/2017' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2017-10-01' and convert(date, b.tstamp)<= '2017-10-31'
group by a.TGCCustFlag
UNION ALL
select 
'2017-11-30' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '12/1/2017' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2017-11-01' and convert(date, b.tstamp)<= '2017-11-30'
group by a.TGCCustFlag
UNION ALL
select 
'2017-12-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '01/1/2018' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2017-12-01' and convert(date, b.tstamp)<= '2017-12-31'
group by a.TGCCustFlag
UNION ALL
select 
'2018-03-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '4/1/2018' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2018-03-01' and convert(date, b.tstamp)<= '2018-03-31'
group by a.TGCCustFlag
UNION ALL
select 
'2018-02-28' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '3/1/2018' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2018-02-01' and convert(date, b.tstamp)<= '2018-02-28'
group by a.TGCCustFlag
UNION ALL
select 
'2018-01-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '2/1/2018' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2018-01-01' and convert(date, b.tstamp)<= '2018-01-31'
group by a.TGCCustFlag
union all
select
'2018-04-30' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '5/1/2018' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2018-04-01' and convert(date, b.tstamp)<= '2018-04-30'
group by a.TGCCustFlag
UNION ALL
select 
'2018-05-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '6/1/2018' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2018-05-01' and convert(date, b.tstamp)<= '2018-05-31'
group by a.TGCCustFlag
UNION ALL
select 
'2018-06-30' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '7/1/2018' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2018-06-01' and convert(date, b.tstamp)<= '2018-06-30'
group by a.TGCCustFlag
UNION ALL
select 
'2018-07-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '8/1/2018' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2018-07-01' and convert(date, b.tstamp)<= '2018-07-31'
group by a.TGCCustFlag
UNION ALL
select 
'2018-08-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '9/1/2018' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2018-08-01' and convert(date, b.tstamp)<= '2018-08-31'
group by a.TGCCustFlag
UNION ALL
select 
'2018-09-30' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '10/1/2018' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2018-09-01' and convert(date, b.tstamp)<= '2018-09-30'
group by a.TGCCustFlag
UNION ALL
select 
'2018-10-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '11/1/2018' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2018-10-01' and convert(date, b.tstamp)<= '2018-10-31'
group by a.TGCCustFlag
UNION ALL
select 
'2018-11-30' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '12/1/2018' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2018-11-01' and convert(date, b.tstamp)<= '2018-11-30'
group by a.TGCCustFlag
UNION ALL
select 
'2018-12-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '01/1/2019' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2018-12-01' and convert(date, b.tstamp)<= '2018-12-31'
group by a.TGCCustFlag
UNION ALL
select 
'2019-03-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '4/1/2019' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2019-03-01' and convert(date, b.tstamp)<= '2019-03-31'
group by a.TGCCustFlag
UNION ALL
select 
'2019-02-28' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '3/1/2019' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2019-02-01' and convert(date, b.tstamp)<= '2019-02-28'
group by a.TGCCustFlag
UNION ALL
select 
'2019-01-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '2/1/2019' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2019-01-01' and convert(date, b.tstamp)<= '2019-01-31'
group by a.TGCCustFlag
union all
select
'2019-04-30' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '5/1/2019' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2019-04-01' and convert(date, b.tstamp)<= '2019-04-30'
group by a.TGCCustFlag
UNION ALL
select 
'2019-05-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '6/1/2019' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2019-05-01' and convert(date, b.tstamp)<= '2019-05-31'
group by a.TGCCustFlag
UNION ALL
select 
'2019-06-30' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '7/1/2019' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2019-06-01' and convert(date, b.tstamp)<= '2019-06-30'
group by a.TGCCustFlag
UNION ALL
select 
'2019-07-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '8/1/2019' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2019-07-01' and convert(date, b.tstamp)<= '2019-07-31'
group by a.TGCCustFlag
UNION ALL
select 
'2019-08-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '9/1/2019' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2019-08-01' and convert(date, b.tstamp)<= '2019-08-31'
group by a.TGCCustFlag
UNION ALL
select 
'2019-09-30' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '10/1/2019' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2019-09-01' and convert(date, b.tstamp)<= '2019-09-30'
group by a.TGCCustFlag
UNION ALL
select 
'2019-10-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '11/1/2019' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2019-10-01' and convert(date, b.tstamp)<= '2019-10-31'
group by a.TGCCustFlag
UNION ALL
select 
'2019-11-30' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '12/1/2019' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2019-11-01' and convert(date, b.tstamp)<= '2019-11-30'
group by a.TGCCustFlag
UNION ALL
select 
'2019-12-31' as AsofDate, 
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag, 
count(distinct a.CustomerID) as Customers, sum(b.StreamedMins) as StreamedMinutes
from DataWarehouse.Marketing.TGCPlus_CustomerSignature_Snapshot (nolock) a
	left join VW_TGCplus_VideoEvents_Smry_Tableau (nolock) b on a.uuid = b.UUID
where a.AsofDate = '01/1/2020' and a.CustStatusFlag <> -1 and convert(date, b.tstamp) >= '2019-12-01' and convert(date, b.tstamp)<= '2019-12-31'
group by a.TGCCustFlag 
 ) as Agg
 where AsofDate <= (Select Max(AsOfDate) from Marketing.TGCPlus_CustomerSignature_Snapshot (nolock))
GO
