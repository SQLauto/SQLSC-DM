SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create View [Archive].[Vw_TGCPlus_CustomerSignatureAll]
as
select  
AsofDate,CustomerID,uuid,EmailAddress,TGCCustomerID,CountryCode,IntlCampaignID,IntlCampaignName,IntlMD_Country,IntlMD_Audience,IntlMD_Channel,
IntlMD_ChannelID,IntlMD_PromotionType,IntlMD_PromotionTypeID,IntlMD_Year,IntlSubDate,IntlSubWeek,IntlSubMonth,IntlSubYear,IntlSubPlanID,IntlSubPlanName
IntlSubType,IntlSubPaymentHandler,SubDate,SubWeek,SubMonth,SubYear,SubPlanID,SubPlanName,SubType,SubPaymentHandler,TransactionType,CustStatusFlag,PaidFlag
LTDPaidAmt,LastPaidDate,LastPaidWeek,LastPaidMonth,LastPaidYear,LastPaidAmt,DSDayCancelled,DSMonthCancelled,DSDayDeferred,TGCCustFlag,TGCCustSegmentFcst,TGCCustSegmentFnl
MaxSeqNum,FirstName,LastName,Gender,Age,AgeBin,HouseHoldIncomeBin,EducationBin,address1,address2,address3,city,state,country,ZipCode,RegDate,RegMonth,RegYear,IntlPaidAmt,IntlPaidDate 
from DataWarehouse.Marketing.TGCPlus_CustomerSignature
union ALL
select  
AsofDate,CustomerID,uuid,EmailAddress,TGCCustomerID,CountryCode,IntlCampaignID,IntlCampaignName,IntlMD_Country,IntlMD_Audience,IntlMD_Channel,
IntlMD_ChannelID,IntlMD_PromotionType,IntlMD_PromotionTypeID,IntlMD_Year,IntlSubDate,IntlSubWeek,IntlSubMonth,IntlSubYear,IntlSubPlanID,IntlSubPlanName
IntlSubType,IntlSubPaymentHandler,SubDate,SubWeek,SubMonth,SubYear,SubPlanID,SubPlanName,SubType,SubPaymentHandler,TransactionType,CustStatusFlag,PaidFlag
LTDPaidAmt,LastPaidDate,LastPaidWeek,LastPaidMonth,LastPaidYear,LastPaidAmt,DSDayCancelled,DSMonthCancelled,DSDayDeferred,TGCCustFlag,TGCCustSegmentFcst,TGCCustSegmentFnl
MaxSeqNum,FirstName,LastName,Gender,Age,AgeBin,HouseHoldIncomeBin,EducationBin,address1,address2,address3,city,state,country,ZipCode,RegDate,RegMonth,RegYear,IntlPaidAmt,IntlPaidDate 
from DataWarehouse.Marketing.TGCPlus_CustomerSignatureRegs

GO
