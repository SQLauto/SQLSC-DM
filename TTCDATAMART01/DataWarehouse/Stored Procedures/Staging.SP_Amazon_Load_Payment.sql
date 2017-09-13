SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[SP_Amazon_Load_Payment]
as
Begin


--Deletes 
	delete A from Archive.Amazon_payment A
	join staging.Amazon_ssis_payment S
	On A.Platform = S.Platform
	and A.Country = S.Country
	and A.Category = S.Category
	and A.ReportDate = S.ReportDate


--Inserts
 insert into Archive.Amazon_payment (Platform,Country,CurrencyCode,Category,SubscriptionName,BillingAmount,Subscribers,LicenseFee,BadDebt,NetRoyaltyPayment,CaptionCost,NetPayment,
			EligibleCaptionCost,RemainingBalance,PaymentTerms,PaymentDate,ReportDate)

	select  Platform,
			Country,
			CurrencyCode,
			Category,
			SubscriptionName,
			cast(BillingAmount as float)BillingAmount,
			cast(Subscribers as int)Subscribers,
			cast(LicenseFee as float)LicenseFee,
			cast(BadDebt as float)BadDebt,
			cast(NetRoyaltyPayment as float)NetRoyaltyPayment,
			cast(CaptionCost as float)CaptionCost,
			cast(NetPayment as float)NetPayment,
			cast(EligibleCaptionCost as float)EligibleCaptionCost,
			cast(RemainingBalance as float)RemainingBalance,
			PaymentTerms,
			case when isdate(PaymentDate) = 1 then PaymentDate else null end as PaymentDate,
			ReportDate 
	 from staging.Amazon_ssis_payment
 

 
End 
GO
