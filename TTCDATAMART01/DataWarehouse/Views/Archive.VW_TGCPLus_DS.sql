SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE View [Archive].[VW_TGCPLus_DS]
as

select  MinDSDate ,billing_cycle_period_type,payment_handler 
,Count(distinct CustomerID)distinctCustomerID
,SUM(Total)Total
,SUM(DS0Counts)DS0Counts
,SUM(DS1Counts)DS1Counts
,SUM(DS2Counts)DS2Counts
,SUM(DS3Counts)DS3Counts
,SUM(DS4Counts)DS4Counts
,SUM(DS5Counts)DS5Counts
,SUM(DS6Counts)DS6Counts
,SUM(DS7Counts)DS7Counts
,SUM(DS8Counts)DS8Counts
,SUM(DS9Counts)DS9Counts
,SUM(DS10Counts)DS10Counts
,SUM(DS11Counts)DS11Counts
,SUM(DS12Counts)DS12Counts
,SUM(DS13Counts)DS13Counts
,SUM(DS14Counts)DS14Counts
,SUM(DS15Counts)DS15Counts
,SUM(DS16Counts)DS16Counts
,SUM(DS17Counts)DS17Counts
,SUM(DS18Counts)DS18Counts
,SUM(DS19Counts)DS19Counts
,SUM(DS20Counts)DS20Counts
,SUM(DS21Counts)DS21Counts
,SUM(DS22Counts)DS22Counts
,SUM(DS23Counts)DS23Counts
,SUM(DS24Counts)DS24Counts
from (
select  MinDSDate ,customerid ,billing_cycle_period_type,payment_handler 
, Count(distinct CustomerID)Total 
, Count(distinct case when DS = 0 and DS_Entitled = 1 then CustomerID end )  as DS0Counts
, Count(distinct case when DS = 1 and DS_Entitled = 1 then CustomerID end )  as DS1Counts
, Count(distinct case when DS = 2 and DS_Entitled = 1 then CustomerID end )  as DS2Counts
, Count(distinct case when DS = 3 and DS_Entitled = 1 then CustomerID end )  as DS3Counts
, Count(distinct case when DS = 4 and DS_Entitled = 1 then CustomerID end )  as DS4Counts
, Count(distinct case when DS = 5 and DS_Entitled = 1 then CustomerID end )  as DS5Counts
, Count(distinct case when DS = 6 and DS_Entitled = 1 then CustomerID end )  as DS6Counts
, Count(distinct case when DS = 7 and DS_Entitled = 1 then CustomerID end )  as DS7Counts
, Count(distinct case when DS = 8 and DS_Entitled = 1 then CustomerID end )  as DS8Counts
, Count(distinct case when DS = 9 and DS_Entitled = 1 then CustomerID end )  as DS9Counts
, Count(distinct case when DS = 10 and DS_Entitled = 1 then CustomerID end )  as DS10Counts
, Count(distinct case when DS = 11 and DS_Entitled = 1 then CustomerID end )  as DS11Counts
, Count(distinct case when DS = 12 and DS_Entitled = 1 then CustomerID end )  as DS12Counts
, Count(distinct case when DS = 13 and DS_Entitled = 1 then CustomerID end )  as DS13Counts
, Count(distinct case when DS = 14 and DS_Entitled = 1 then CustomerID end )  as DS14Counts
, Count(distinct case when DS = 15 and DS_Entitled = 1 then CustomerID end )  as DS15Counts
, Count(distinct case when DS = 16 and DS_Entitled = 1 then CustomerID end )  as DS16Counts
, Count(distinct case when DS = 17 and DS_Entitled = 1 then CustomerID end )  as DS17Counts
, Count(distinct case when DS = 18 and DS_Entitled = 1 then CustomerID end )  as DS18Counts
, Count(distinct case when DS = 19 and DS_Entitled = 1 then CustomerID end )  as DS19Counts
, Count(distinct case when DS = 20 and DS_Entitled = 1 then CustomerID end )  as DS20Counts
, Count(distinct case when DS = 21 and DS_Entitled = 1 then CustomerID end )  as DS21Counts
, Count(distinct case when DS = 22 and DS_Entitled = 1 then CustomerID end )  as DS22Counts 
, Count(distinct case when DS = 23 and DS_Entitled = 1 then CustomerID end )  as DS23Counts
, Count(distinct case when DS = 24 and DS_Entitled = 1 then CustomerID end )  as DS24Counts

from Datawarehouse.archive.tgcplus_DS
where DS_ValidDS > 0
-- and isnull(DS,0)<=24
--and MinDSDate = '8/1/2016'
group by MinDSDate ,customerid,billing_cycle_period_type,payment_handler 
) a
group by  MinDSDate ,billing_cycle_period_type,payment_handler 
GO
