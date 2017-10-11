SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE View [Archive].[VW_TGCPlus_DS_GroupBy]
as
 select
 -- MinDSDate,
  MinDSDateMonth,MinDSDateQuarter,MinDSDateYearMonth,MinDSDateYear,
IntlCampaignID,IntlCampaignName,IntlMD_Country,IntlMD_Audience,IntlMD_Channel,IntlMD_ChannelID,IntlMD_PromotionType,IntlMD_PromotionTypeID,
IntlMD_Year,IntlSubDate,IntlSubWeek,IntlSubMonth,IntlSubYear,IntlSubPlanID,IntlSubPlanName,IntlSubType,IntlSubPaymentHandler,
SubDate,SubWeek,SubMonth,SubYear,SubPlanID,SubPlanName,SubType,SubPaymentHandler,TGCCustFlag,
IntlDSbilling_cycle_period_type,IntlDSsubscription_plan_id,IntlDSpayment_handler,IntlDSuso_offer_id
,SubDSbilling_cycle_period_type,SubDSsubscription_plan_id,SubDSpayment_handler,SubDSuso_offer_id
, Count(distinct CustomerID)Total 
, Count(distinct case when DS = 0 and DS_Entitled = 1 and DS_ValidDS > 0 and (cancelled + suspended = 0 ) then CustomerID end )  as DS0Counts
, Count(distinct case when DS = 1 and DS_Entitled = 1 and DS_ValidDS > 0  then CustomerID end )  as DS1Counts
, Count(distinct case when DS = 2 and DS_Entitled = 1 and DS_ValidDS > 0  then CustomerID end )  as DS2Counts
, Count(distinct case when DS = 3 and DS_Entitled = 1 and DS_ValidDS > 0  then CustomerID end )  as DS3Counts
, Count(distinct case when DS = 4 and DS_Entitled = 1 and DS_ValidDS > 0  then CustomerID end )  as DS4Counts
, Count(distinct case when DS = 5 and DS_Entitled = 1 and DS_ValidDS > 0  then CustomerID end )  as DS5Counts
, Count(distinct case when DS = 6 and DS_Entitled = 1 and DS_ValidDS > 0  then CustomerID end )  as DS6Counts
, Count(distinct case when DS = 7 and DS_Entitled = 1 and DS_ValidDS > 0  then CustomerID end )  as DS7Counts
, Count(distinct case when DS = 8 and DS_Entitled = 1 and DS_ValidDS > 0  then CustomerID end )  as DS8Counts
, Count(distinct case when DS = 9 and DS_Entitled = 1 and DS_ValidDS > 0  then CustomerID end )  as DS9Counts
, Count(distinct case when DS = 10 and DS_Entitled = 1 and DS_ValidDS > 0  then CustomerID end )  as DS10Counts
, Count(distinct case when DS = 11 and DS_Entitled = 1 and DS_ValidDS > 0  then CustomerID end )  as DS11Counts
, Count(distinct case when DS = 12 and DS_Entitled = 1 and DS_ValidDS > 0  then CustomerID end )  as DS12Counts
, Count(distinct case when DS = 13 and DS_Entitled = 1 and DS_ValidDS > 0  then CustomerID end )  as DS13Counts
, Count(distinct case when DS = 14 and DS_Entitled = 1 and DS_ValidDS > 0  then CustomerID end )  as DS14Counts
, Count(distinct case when DS = 15 and DS_Entitled = 1 and DS_ValidDS > 0  then CustomerID end )  as DS15Counts
, Count(distinct case when DS = 16 and DS_Entitled = 1 and DS_ValidDS > 0  then CustomerID end )  as DS16Counts
, Count(distinct case when DS = 17 and DS_Entitled = 1 and DS_ValidDS > 0  then CustomerID end )  as DS17Counts
, Count(distinct case when DS = 18 and DS_Entitled = 1 and DS_ValidDS > 0  then CustomerID end )  as DS18Counts
, Count(distinct case when DS = 19 and DS_Entitled = 1 and DS_ValidDS > 0  then CustomerID end )  as DS19Counts
, Count(distinct case when DS = 20 and DS_Entitled = 1 and DS_ValidDS > 0  then CustomerID end )  as DS20Counts
, Count(distinct case when DS = 21 and DS_Entitled = 1 and DS_ValidDS > 0  then CustomerID end )  as DS21Counts
, Count(distinct case when DS = 22 and DS_Entitled = 1 and DS_ValidDS > 0  then CustomerID end )  as DS22Counts 
, Count(distinct case when DS = 23 and DS_Entitled = 1 and DS_ValidDS > 0  then CustomerID end )  as DS23Counts
, Count(distinct case when DS = 24 and DS_Entitled = 1 and DS_ValidDS > 0  then CustomerID end )  as DS24Counts
 from Archive.Vw_TGCPlus_DS_Working
 --where customerid in (1009276,1177119,1228043)
group by --MinDSDate,
MinDSDateMonth,MinDSDateQuarter,MinDSDateYearMonth,MinDSDateYear,
IntlCampaignID,IntlCampaignName,IntlMD_Country,IntlMD_Audience,IntlMD_Channel,IntlMD_ChannelID,IntlMD_PromotionType,IntlMD_PromotionTypeID,
IntlMD_Year,IntlSubDate,IntlSubWeek,IntlSubMonth,IntlSubYear,IntlSubPlanID,IntlSubPlanName,IntlSubType,IntlSubPaymentHandler,
SubDate,SubWeek,SubMonth,SubYear,SubPlanID,SubPlanName,SubType,SubPaymentHandler,TGCCustFlag,
IntlDSbilling_cycle_period_type,IntlDSsubscription_plan_id,IntlDSpayment_handler,IntlDSuso_offer_id
,SubDSbilling_cycle_period_type,SubDSsubscription_plan_id,SubDSpayment_handler,SubDSuso_offer_id
GO
