SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE View [Archive].[Vw_TGCPlus_DS_Working]      
as      
select       
DS.CustomerID,      
DSDate,      
DS,      
currentDS,      
MinDSDate,      
Month(MinDSDate)MinDSDateMonth,      
Year(MinDSDate)MinDSDateYear,      
DatePart(Quarter,MinDSDate)MinDSDateQuarter,      
Cast (Year(MinDSDate) as varchar(4)) + Case when len(Cast(Month(MinDSDate) as varchar(2)))<2 then '0' + Cast(Month(MinDSDate) as varchar(2)) else Cast(Month(MinDSDate) as varchar(2)) end MinDSDateYearMonth,      
MaxDS,      
MaxDSDate,      
DS_Service_period_from,      
DS_Service_period_to,      
DS_ValidDS,      
DS_Entitled,      
completed_at,      
billing_cycle_period_type,      
subscription_plan_id,      
payment_handler,      
BillingRank,      
pre_tax_amount,      
Refunded,      
RefundedAmount,      
Amount,      
NetAmount,      
DSSplits,      
PAS_Cancelled_date,      
PAS_DeferredSuspension_date,      
PAS_Suspended_date,       
Cancelled,Suspended,      
DeferredSuspension,      
uso_offer_id,      
uso_offer_code_applied,      
IntlCampaignID,       
IntlCampaignName,      
IntlMD_Country,      
IntlMD_Audience,      
IntlMD_Channel,       
IntlMD_ChannelID,      
IntlMD_PromotionType,      
IntlMD_PromotionTypeID,       
IntlMD_Year,      
IntlSubDate,      
IntlSubWeek,      
IntlSubMonth,      
IntlSubYear,      
IntlSubPlanID,       
IntlSubPlanName,      
IntlSubType,      
IntlSubPaymentHandler,      
SubDate,      
SubWeek,      
SubMonth,      
SubYear,      
SubPlanID,      
SubPlanName,      
SubType,      
SubPaymentHandler,      
TransactionType,      
TGCCustFlag,      
RegDate,      
RegMonth,      
RegYear,      
LTDAmount,      
LTDNetAmount,      
IntlDSbilling_cycle_period_type,      
IntlDSsubscription_plan_id,      
IntlDSpayment_handler,      
IntlDSAmount,      
IntlDSuso_offer_id,      
SubDSbilling_cycle_period_type,      
SubDSsubscription_plan_id,      
SubDSpayment_handler,      
SubDSAmount,      
SubDSuso_offer_id ,    
Reactivated   ,  
LTDPaymentRank,  
LTDNetPaymentRank,
FreeTrialDays  
from  Datawarehouse.Archive.TGCplus_DS DS      
join Datawarehouse.marketing.TGCPlus_CustomerSignature C      
on DS.Customerid = C.Customerid      
--where DS.customerid in (2891701,2939985,2979541,3515647,3375086,3593477)       
--and DS_ValidDS > 0 
GO
