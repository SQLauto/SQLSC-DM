SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[vw_TGCPlus_WeeklyPaidSubs] as
select 
AsofDate,
IntlSubType,
IntlMD_Channel,
IntlSubPaymentHandler, SubPaymentHandler, 
IntlSubPlanID, 
c.recurring_payment_amount as IntlRecurringPaymentAmount, c.recurring_payment_currency_code as IntlRecurringPaymentCurrencyCode, 
convert(varchar,c.billing_cycle_period_multiplier) + '_' +  c.billing_cycle_period_type as IntlSubType2,
d.recurring_payment_amount as SubRecurringPaymentAmount, d.recurring_payment_currency_code as SubRecurringPaymentCurrencyCode, 
convert(varchar,c.billing_cycle_period_multiplier) + '_' +  c.billing_cycle_period_type as SubType2,   
SubPlanID, 
IntlSubPlanName, SubPlanName, SubType, 
case when TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag,
a.Country,
b.ContinentName, 
Count(*) PaidSubs
from archive.tgcplus_customersignature_wkly (nolock) a
	left join mapping.TGCPlusCountry (nolock) b on a.country = b.Country
	left join Archive.TGCPlus_SubscriptionPlan (nolock) c on a.IntlSubPlanID = c.ID 
	left join Archive.TGCPlus_SubscriptionPlan (nolock) d on a.SubPlanID = d.ID 
where CustStatusFlag >=0 and PaidFlag = 1
group by
AsofDate, 
IntlSubType,
IntlMD_Channel,
IntlSubPaymentHandler, SubPaymentHandler, 
IntlSubPlanID, c.recurring_payment_amount, c.recurring_payment_currency_code,  
SubPlanID, 
IntlSubPlanName, SubPlanName,  SubType, 
TGCCustFlag,
a.country, b.ContinentName,
convert(varchar,c.billing_cycle_period_multiplier) + '_' +  c.billing_cycle_period_type,
d.recurring_payment_amount, d.recurring_payment_currency_code, 
convert(varchar,c.billing_cycle_period_multiplier) + '_' +  c.billing_cycle_period_type; 

GO
