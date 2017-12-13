SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[vw_tgcplus_RFM] 
as
select 
dateadd(day, -1, a.AsofDate) AsofDate, 
a.CustomerID,
a.IntlSubDate, 
a.LTDPaidAmt,
a.DateLastPlayed,
isnull(a.StreamedMinutes,0) StreamedMinutes,
isnull(a.DaysSinceLastStream,0) DaysSinceLastStream,
a.Tenure, 
isnull(a.MinutesPerDay, 0) MinutesPerDay, 
Recency_Decile, Frequency_Decile, Monetary_Decile, 
(100 * [Recency_Decile])+(100 * [Frequency_Decile]) RF,
(Monetary_Decile * 100) MonetaryScore,
b.IntlMD_Channel, b.IntlSubPaymentHandler, b.IntlSubPlanID, b.IntlSubPlanName, b.IntlSubType, 
b.SubType, b.DSMonthCancelled_New, b.DS, b.BillingRank, b.Reactivated, 
b.SubPaymentHandler, b.SubPlanName, b.SubPlanID, b.DSLTDAmount, b.DSLTDNetAmount,
b.Gender, b.AgeBin, b.EmailAddress, b.TGCCustFlag
from Marketing.TGCPlus_RFM (nolock) a left join archive.Vw_TGCPlus_CustomerSignature (nolock) b on a.CustomerID = b.CustomerID
GO
