SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[VW_TB_Stripe_Dunning_ByCardFunding] AS
select  
CreatedYear,
CreatedMonth,
subtype, intlsubplanId, IntlMD_Channel, IntlMD_Country, 
CONVERT(DATE,CAST([CreatedYear] AS VARCHAR(4))+'-'+ CAST([CreatedMonth] AS VARCHAR(2))+'-'+ CAST(1 AS VARCHAR(2))) as Date,
CardFunding,
isnull(DistinctUserUUID_AllStripetransactions,0) as StripeAttempts,
isnull(DistinctUserUUID_StripeSuccess,0) as StripeFirstSuccess,
isnull(DistinctUserUUID_StripeFailures,0) as StripeFirstFailures,
isnull(DistinctUserUUID_StripeFailuresinDunning,0) as StripeDunning,
isnull(DistinctUserUUID_StripeFailuresDunningSuccess,0) as StripeDunnSuccess, 
isnull(DistinctUserUUID_StripeFailuresinDunning,0) - isnull(DistinctUserUUID_StripeFailuresDunningSuccess,0) as StripeDunnFailure
from
Archive.VW_Stripe_Dunning_ByCardFunding (nolock);
GO
