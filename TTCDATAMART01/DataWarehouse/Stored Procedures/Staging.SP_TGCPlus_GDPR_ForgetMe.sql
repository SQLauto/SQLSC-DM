SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE Proc [Staging].[SP_TGCPlus_GDPR_ForgetMe]  
as  
  
Begin  
  
  
Insert into archive.TGCPlus_GDPR_ForgetMe_AuditTrail  
(CustomerID,UUID,EmailAddress,DMLastUpdateESTDateTime,DateAdded,CleanupCompleted,CleanupCompletedDatetime,TGCPlusCompleted,StripeCompleted,SailtruCompleted)
select  u.id as CustomerID,  
  u.uuid as UUID,  
  u.email as EmailAddress,  
  u.DMLastUpdateESTDateTime,  
  getdate() as DateAdded,  
  Cast(0 as bit) as CleanupCompleted,  
  cast(null as datetime) as CleanupCompletedDatetime,  
  Cast(0 as bit) as TGCPlusCompleted,  
  Cast(0 as bit) as StripeCompleted,  
  Cast(0 as bit) as SailtruCompleted

from DataWarehouse.Archive.tgcplus_user u  
left join archive.TGCPlus_GDPR_ForgetMe_AuditTrail A  
on a.uuid = u.uuid  
where email like '%@deleted_eu_account.com'  
and a.uuid is null  
  
  
/* GDPR Cleanup Mapping table */  
  if OBJECT_ID('mapping.TGCPlus_GDPR_CleanUp') is not null  
  Drop table mapping.TGCPlus_GDPR_CleanUp  
  
 select TableName, max(uuid)uuid,max(userId)userId,max(customerid)customerid,max(email)email,max(emailaddress)emailaddress,  
 max(userFirstName)userFirstName,max(userLastName)userLastName,max(Firstname)Firstname,max(Lastname)Lastname,max(FullName)FullName,  
 max(line1)line1,max(line2)line2,max(line3)line3,max(Address1)Address1,max(Address2)Address2,max(Address3)Address3,  
 cast(0 as int) Completed  
 into mapping.TGCPlus_GDPR_CleanUp    
 from   
 ( select TABLE_SCHEMA + '.' + TABLE_NAME as TableName,*  
  from INFORMATION_SCHEMA.COLUMNS  
  where TABLE_NAME like '%tgcplus%'  
  and TABLE_NAME not like 'Vw%'  
  and TABLE_NAME not in ('TGCPlus_GDPR_ForgetMe_AuditTrail' , 'TGCPlus_GDPR_CleanUp_AuditTrail','TGCPlus_GDPR_CleanUp','TGCPlus_user_Audit_trail' )  
union   
   
 select TABLE_SCHEMA + '.' + TABLE_NAME as TableName,*  
  from INFORMATION_SCHEMA.COLUMNS  
  where TABLE_NAME in (select TableName from Mapping.TGCPlus_GDPR_Tables)  
  
) P  
pivot ( count(Column_name) for Column_name in (uuid,userId,customerid,email,emailaddress,userFirstName,userLastName,Firstname,Lastname,FullName,line1,line2,line3,Address1,Address2,Address3) )as PVT  
group by TableName  
having sum(email+emailaddress+userFirstName+userLastName+Firstname+Lastname+FullName+line1+line2+line3+Address1+Address2+Address3)>0  
  
  

Update   A
Set 
CleanupCompletedDatetime = DMLastUpdateESTDateTime,
CleanupCompleted = 1,
DMLastUpdateESTDateTime = getdate()
 --select * 
from datawarehouse.archive.TGCPlus_GDPR_ForgetMe_AuditTrail  A
where TGCPlusCompleted	= 1 
and StripeCompleted	= 1 
and SailtruCompleted = 1
and CleanupCompleted = 0
  


End  
GO
