SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_Stripe_GDPR_CleanUp]  
as  
  
Begin  
  
 select * into #Stripe_GDPR   
 from datawarehouse.archive.TGCPlus_GDPR_ForgetMe_AuditTrail  
 Where Datediff(d,DateAdded,getdate())<=30 --CleanupCompleted = 0  

 select * from datawarehouse.archive.TGCPlus_GDPR_ForgetMe_AuditTrail
  
 While Exists (select top 1 * from #Stripe_GDPR where CleanupCompleted = 0)  
  
  Begin  
  
   Declare @GDPRUUID varchar(255), @GDPREmail varchar(255)   
  
   select top 1 @GDPRUUID = uuid, @GDPREmail = EmailAddress  from #Stripe_GDPR  
   where CleanupCompleted = 0  
   order by uuid   
  
   select @GDPRUUID as '@GDPRUUID',@GDPREmail as '@GDPREmail'  
  
  select Prev_Email as Email   
  into #Email  
  from DataWarehouse.Archive.TGCPlus_user_Audit_trail where uuid = @GDPRUUID  
  union   
  select Email from DataWarehouse.Archive.TGCPlus_user_Audit_trail where uuid = @GDPRUUID   
         
  Print 'Archive.Stripe_transactions'  
      update  a 
	  set 
	  CustomerDescription = Null,
	  CustomerEmail = @GDPREmail,
	  CardLast4 = 0000,
	  CardName = null,
	  CardAddressLine1 = null,
	  CardAddressLine2 = null,	
	  userEmail_metadata = @GDPREmail,
	  DMLastupdated =  getdate()
	  --select top 10 *   
      from Archive.Stripe_transactions  a
      where CustomerEmail in (select * from #Email ) or userId_metadata = @GDPRUUID  
     
 
  
  Print 'Archive.Stripe_transactions_report'  
      update  a 
	  set 
	  CustomerDescription = Null,
	  CustomerEmail = @GDPREmail,
	  CardLast4 = 0000,
	  CardName = null,
	  CardAddressLine1 = null,
	  CardAddressLine2 = null,	
	  userEmail_metadata = @GDPREmail,
	  DMLastupdated =  getdate()
	  --select top 10 *   
      from Archive.Stripe_transactions_report  a
      where CustomerEmail in (select * from #Email ) or userId_metadata = @GDPRUUID  
     
   update #Stripe_GDPR  
   set CleanupCompleted = 1  
   where uuid = @GDPRUUID  
  
  
    update A 
  Set A.DMLastUpdateESTDateTime = getdate(),
  StripeCompleted = 1
  --select * 
  from datawarehouse.archive.TGCPlus_GDPR_ForgetMe_AuditTrail  A
  where A.uuid = @GDPRUUID  

  End  
  


End  


GO
