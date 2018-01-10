SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Staging].[SP_Amazon_Load_weeklySubscription]  
as  
Begin  
  
   
  delete A from  Archive.Amazon_weeklySubscription A  
  join staging.Amazon_ssis_weeklySubscription S  
  on A.Partner = S.Partner   
  and A.CountryCode = S.CountryCode  
  and A.ReportWeek = S.ReportWeek  
  and A.ReportYear = S.ReportYear  
  and A.SubscriptionCategory = S.SubscriptionCategory  
  
  
 insert into Archive.Amazon_weeklySubscription  (Partner,CountryCode,Subscription , ReportYear,ReportWeek,ReportStartDate,ReportEndDate  
         ,SubscriptionCategory,ActiveSubscriptions, NewSubscriptions,CancelledSubscriptions)  
 select  Partner,  
   CountryCode,  
   Subscription ,  
   ReportYear,  
   ReportWeek,  
   ReportStartDate,  
   ReportEndDate,  
   SubscriptionCategory,  
   ActiveSubscriptions,  
   NewSubscriptions,  
   CancelledSubscriptions  
  from staging.Amazon_ssis_weeklySubscription  
  
   
End   
GO
