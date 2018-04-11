SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Archive].[vw_TGCPLUS_RetentionWaterfallChart] as
select asofdate1, SubPaymentHandler1, IntlMD_Channel1, SubPlanName1, SubPlanID1, TGCCustFlag1, Category, sum(value) as Value
from (
select *,
case when PaidFlag1=1 and PaidFlag2=0
and CustStatusFlag1!=-1 and CustStatusFlag2!=-1  then 1 
when CustStatusFlag2=-1 and CustStatusFlag1!=-1
and PaidFlag1=1 then 1
when SubType2='Month'
and PaidFlag2=1
and CustStatusFlag2!=-1 and CustStatusFlag1=-1 then -1 
when SubType2='Year'
and PaidFlag2=1
and CustStatusFlag2!=-1 and CustStatusFlag1=-1 then -1
when intlsubweek1=DATEADD(day,-5, AsofDate1)
and IntlSubType1='Month'
and PaidFlag1=1
and CustStatusFlag1!=-1 then 1
when intlsubweek1=DATEADD(day,-5, AsofDate1)
and IntlSubType1='Year'
and PaidFlag1=1
and CustStatusFlag1!=-1 then 1 else 0 end as 'Value',
case when PaidFlag1=1 and PaidFlag2=0 and 
CustStatusFlag1!=-1 and CustStatusFlag2!=-1  then 'FreeTrialConversion'
when CustStatusFlag2=-1 and CustStatusFlag1!=-1
and PaidFlag1=1 then 'Reactivations'
when SubType2='Month'
and PaidFlag2=1
and CustStatusFlag2!=-1 and CustStatusFlag1=-1 then 'PaidMonthlyCancellations'
when SubType2='Year'
and PaidFlag2=1
and CustStatusFlag2!=-1 and CustStatusFlag1=-1 then 'PaidAnnualCancellations'
when intlsubweek1=DATEADD(day,-5, AsofDate1)
and IntlSubType1='Month'
and PaidFlag1=1
and CustStatusFlag1!=-1 then 'NewMonthlyPaid'
when intlsubweek1=DATEADD(day,-5, AsofDate1)
and IntlSubType1='Year'
and PaidFlag1=1
and CustStatusFlag1!=-1 then 'NewAnnualPaid' else '' end as 'Category'
from 
(select asofdate as AsOfDate1, uuid as uuid1, PaidFlag as PaidFlag1,CustStatusFlag as CustStatusFlag1,SubPaymentHandler as SubPaymentHandler1, SubType as SubType1, IntlSubType as IntlSubType1,IntlSubWeek as IntlSubWeek1,SubPlanName as SubPlanName1,IntlMD_Channel as IntlMD_Channel1, SubPlanID as SubPlanID1, TGCCustFlag as TGCCustFlag1 from datawarehouse.archive.TGCPlus_CustomerSignature_Wkly (nolock) where asofdate>='2017-01-01') a
left join 
(select asofdate as AsOfDate2, uuid as uuid2, PaidFlag as PaidFlag2,CustStatusFlag as CustStatusFlag2,SubPaymentHandler as SubPaymentHandler2, SubType as SubType2, IntlSubType as IntlSubType2,IntlSubWeek as IntlSubWeek2,SubPlanName as SubPlanName2, IntlMD_Channel as IntlMD_Channel2, SubPlanID as SubPlanID2, TGCCustFlag as TGCCustFlag2 from datawarehouse.archive.TGCPlus_CustomerSignature_Wkly (nolock) where asofdate>='2017-01-01') b 
on b.uuid2=a.uuid1 and b.AsofDate2=DATEADD(DAY, -7, a.AsofDate1)
group by AsOfDate1,asofdate2,uuid1,uuid2,PaidFlag1,PaidFlag2,CustStatusFlag1,CustStatusFlag2,SubPaymentHandler1,SubPaymentHandler2,SubType1,SubType2,IntlSubType1,IntlSubType2,IntlSubWeek1,IntlSubWeek2,SubPlanName1,SubPlanName2,IntlMD_Channel1,IntlMD_Channel2,SubPlanID1,SubPlanID2,TGCCustFlag1,TGCCustFlag2
) c where c.category!='' group by c.AsOfDate1, c.Category, c.SubPlanName1,c.IntlMD_Channel1,c.SubPaymentHandler1,c.SubPlanID1,c.TGCCustFlag1

union 

select asOfDate1,
SubPaymentHandler1,
IntlMD_Channel1,
SubPlanName1,
SubPlanID1,
TGCCustFlag1,
'NetPaid' as 'Category',
sum(CurrentPaid)-sum(PWPaid) as 'Value'
from (
select *,
case when custstatusflag1 in ('0','1')
and paidflag1=1 then 1 else 0 end as CurrentPaid,
case when custstatusflag2 in ('0','1')
and paidflag2=1 then 1 else 0 end as PWPaid
from 
(select asofdate as AsOfDate1, uuid as uuid1, PaidFlag as PaidFlag1,CustStatusFlag as CustStatusFlag1,SubPaymentHandler as SubPaymentHandler1, SubType as SubType1, IntlSubType as IntlSubType1,IntlSubWeek as IntlSubWeek1,SubPlanName as SubPlanName1,IntlMD_Channel as IntlMD_Channel1, SubPlanID as SubPlanID1, TGCCustFlag as TGCCustFlag1 from datawarehouse.archive.TGCPlus_CustomerSignature_Wkly (nolock) where asofdate>='2017-01-01') a
left join 
(select asofdate as AsOfDate2, uuid as uuid2, PaidFlag as PaidFlag2,CustStatusFlag as CustStatusFlag2,SubPaymentHandler as SubPaymentHandler2, SubType as SubType2, IntlSubType as IntlSubType2,IntlSubWeek as IntlSubWeek2,SubPlanName as SubPlanName2, IntlMD_Channel as IntlMD_Channel2, SubPlanID as SubPlanID2, TGCCustFlag as TGCCustFlag2 from datawarehouse.archive.TGCPlus_CustomerSignature_Wkly (nolock) where asofdate>='2017-01-01') b 
on b.uuid2=a.uuid1 and b.AsofDate2=DATEADD(DAY, -7, a.AsofDate1)
group by AsOfDate1,asofdate2,uuid1,uuid2,PaidFlag1,PaidFlag2,CustStatusFlag1,CustStatusFlag2,SubPaymentHandler1,SubPaymentHandler2,SubType1,SubType2,IntlSubType1,IntlSubType2,IntlSubWeek1,IntlSubWeek2,SubPlanName1,SubPlanName2,IntlMD_Channel1,IntlMD_Channel2,SubPlanID1,SubPlanID2,TGCCustFlag1,TGCCustFlag2
) c group by c.AsOfDate1, c.SubPlanName1,c.IntlMD_Channel1,c.SubPaymentHandler1,c.SubPlanID1,c.TGCCustFlag1

union

select asOfDate1,
SubPaymentHandler1,
IntlMD_Channel1,
SubPlanName1,
SubPlanID1,
TGCCustFlag1,
'CurrentPaid' as 'Category',
sum(CurrentPaid) as 'Value'
from (
select *,
case when custstatusflag1 in ('0','1')
and paidflag1=1 then 1 else 0 end as CurrentPaid,
case when custstatusflag2 in ('0','1')
and paidflag2=1 then 1 else 0 end as PWPaid
from 
(select asofdate as AsOfDate1, uuid as uuid1, PaidFlag as PaidFlag1,CustStatusFlag as CustStatusFlag1,SubPaymentHandler as SubPaymentHandler1, SubType as SubType1, IntlSubType as IntlSubType1,IntlSubWeek as IntlSubWeek1,SubPlanName as SubPlanName1,IntlMD_Channel as IntlMD_Channel1, SubPlanID as SubPlanID1, TGCCustFlag as TGCCustFlag1 from datawarehouse.archive.TGCPlus_CustomerSignature_Wkly (nolock) where asofdate>='2017-01-01') a
left join 
(select asofdate as AsOfDate2, uuid as uuid2, PaidFlag as PaidFlag2,CustStatusFlag as CustStatusFlag2,SubPaymentHandler as SubPaymentHandler2, SubType as SubType2, IntlSubType as IntlSubType2,IntlSubWeek as IntlSubWeek2,SubPlanName as SubPlanName2, IntlMD_Channel as IntlMD_Channel2, SubPlanID as SubPlanID2, TGCCustFlag as TGCCustFlag2 from datawarehouse.archive.TGCPlus_CustomerSignature_Wkly (nolock) where asofdate>='2017-01-01') b 
on b.uuid2=a.uuid1 and b.AsofDate2=DATEADD(DAY, -7, a.AsofDate1)
group by AsOfDate1,asofdate2,uuid1,uuid2,PaidFlag1,PaidFlag2,CustStatusFlag1,CustStatusFlag2,SubPaymentHandler1,SubPaymentHandler2,SubType1,SubType2,IntlSubType1,IntlSubType2,IntlSubWeek1,IntlSubWeek2,SubPlanName1,SubPlanName2,IntlMD_Channel1,IntlMD_Channel2,SubPlanID1,SubPlanID2,TGCCustFlag1,TGCCustFlag2
) c group by c.AsOfDate1, c.SubPlanName1,c.IntlMD_Channel1,c.SubPaymentHandler1,c.SubPlanID1,c.TGCCustFlag1
;

GO
