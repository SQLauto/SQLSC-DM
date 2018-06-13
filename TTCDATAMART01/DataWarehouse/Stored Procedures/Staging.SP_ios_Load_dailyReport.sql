SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[SP_ios_Load_dailyReport]  @Filename varchar(255) = null  
as        
Begin        
  
Declare @Date date --,@Filename varchar(255) = 'Subscription_85801640_20180530_V1_1.txt'  
        
if @Filename is not null  
begin

set @Filename = replace(@Filename,'_V1_1.','.')

set @Date = CONVERT (date,convert(char(8),replace(right(@Filename,12),'.txt','') ))  
End

  select @Filename, @Date
  
if @Filename is null  
set @Date = cast(getdate() as date)  
  
/*Update Previous Counts*/  
exec SP_TGCPlus_UpdatePreviousCounts @TGCPlusTableName = 'TGCplus_ios_report'  
         
  
  
select @Date as ReportDate,*   
into #ios  
from staging.TGCplus_ssis_ios   
  
select * from #ios  
  
delete from Archive.TGCplus_ios_report  
where reportdate in (select reportdate from #ios)  
  
  
insert into Archive.TGCplus_ios_report (  [ReportDate],[AppName],[AppAppleID],[SubscriptionName],[SubscriptionAppleID],[SubscriptionGroupID],  
    [SubscriptionDuration],[CustomerPrice],[CustomerCurrency],[DeveloperProceeds],[ProceedsCurrency],[PreservedPricing],[ProceedsReason],[Client],  
    [Device],[State],[Country],[ActiveSubscriptions],[ActiveFreeTrials],[MarketingOptIns],ActivePayUpFrontSubscriptions,ActivePayAsYouGoSubscriptions,BillingRetry )  
  
select [ReportDate],[AppName],[AppAppleID],[SubscriptionName],[SubscriptionAppleID],[SubscriptionGroupID],  
    [SubscriptionDuration],[CustomerPrice],[CustomerCurrency],[DeveloperProceeds],[ProceedsCurrency],[PreservedPricing],[ProceedsReason],[Client],  
    [Device],[State],[Country],[ActiveSubscriptions],[ActiveFreeTrials],[MarketingOptIns],ActivePayUpFrontSubscriptions,ActivePayAsYouGoSubscriptions,BillingRetry  from #ios  
  
/*Update Counts*/  
exec SP_TGCPlus_UpdateCurrentCounts @TGCPlusTableName = 'TGCplus_ios_report'  
        
END        
GO
