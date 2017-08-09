SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

     
CREATE Proc [Staging].[SP_VL_Load_CreditcardretryReport]  @Date datetime = null  
as      
Begin      
      
if @Date is null
set @Date = getdate()

/*Update Previous Counts*/
exec SP_TGCPlus_UpdatePreviousCounts @TGCPlusTableName = 'TGCPlus_CreditcardretryReport'
       
select   UserID,RetryCount,RetryStatus,
case when DeclinedDate = 'null' then Null else Cast(DeclinedDate as datetime) end DeclinedDate,
case when Nextretrydate = 'null' then Null else Cast(Nextretrydate as datetime)end Nextretrydate,
case when Originalbillingdate = 'null' then Null else Cast(Originalbillingdate as datetime) end Originalbillingdate,
Declinedcode,DeclinedMessage,PlanId,PaymentHandler   
,@Date as DMlastupdated
--into Datawarehouse.Archive.TGCPLus_CreditcardretryReport
Into #Temp
from [staging].[vl_ssis_CreditcardretryReport]  
 
update #Temp
set PaymentHandler =  replace(PaymentHandler,',','')


Delete a from Datawarehouse.Archive.TGCPLus_CreditcardretryReport a
join #Temp  s on a.UserID = s.UserID and cast(a.DeclinedDate as date)= cast(S.DeclinedDate as date) and a.RetryCount = s.RetryCount
      
insert into Datawarehouse.Archive.TGCPLus_CreditcardretryReport     
Select distinct * from  #Temp     
      
/*Update Counts*/
exec SP_TGCPlus_UpdateCurrentCounts @TGCPlusTableName = 'TGCPlus_CreditcardretryReport'
      
END      

 
GO
