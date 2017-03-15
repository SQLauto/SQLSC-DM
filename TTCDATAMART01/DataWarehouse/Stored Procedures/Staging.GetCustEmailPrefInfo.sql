SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
  
CREATE PROC [Staging].[GetCustEmailPrefInfo]  
 @CustInfo varchar(60),  
 @CustInfoType varchar(1),  
 @Days int = 40  
  
  
AS   
  
/* Preethi Ramanujam  3/6/2014  
 To get customer's Email Preference Information  
*/  
  
Declare @CustID nvarchar(20), @ErrorMsg varchar(400), @Email varchar(100)  
  
set @CustID = null  
set @Email = null  
  
If @CustInfoType = 'C'  
 set @CustID = @CustInfo  
else if @CustInfoType = 'E'  
 select @CustID = customerID,  
  @Email = @CustInfo  
 from DataWarehouse.Marketing.epc_preference  
 where Email = @CustInfo  
  
   
IF @CustID IS NULL  
BEGIN   
 /* Check if we can get the DL control version of catalogcode *****/  
 SET @ErrorMsg = 'No CustomerID was found for ' + @CustInfoType + ': ' + @CustInfo  
 PRINT @ErrorMsg  
 Return  
END  
  
  
-- Get customer inforamtion  
select CustomerID, FirstName, LastName, CustomerSince, EmailAddress  
 ,NewSeg, Name, a12mf, CustomerSegmentFnl, CustomerSegmentNew  
 ,FlagEmail, FlagEmailPref, FlagValidEmail   
from DataWarehouse.Marketing.CampaignCustomerSignature  
where CustomerID = @CustID  
  
---- Get customer optin tracker inforamtion from DAX     
--select * from DAXImports..TTC_AUDITCUSTOPTINCHANGES  
--where CUSTACCOUNT = @CustID  
--order by MODIFIEDDATETIME, OPTINID  
  
---- Get customer optin tracker inforamtion     
--select * from Archive.CustomerOptinTracker  
--where CustomerID = @CustID  
--order by AsOfDate  

  
if @Email is not null  
select *  
from Marketing.epc_preference  
where (email = @Email  or CustomerID = @CustID )
  
  
if @Email is not null  
select email, joined, entitled_dt, subscription_plan_id, b.name as SubscriptionName  
from DataWarehouse.Archive.TGCPlus_User a left join  
 Archive.TGCPlus_SubscriptionPlan b on a.subscription_plan_id = b.id  
where email = @Email  
  
  
-- Get Customer EPC History  
if @Email is not null  
select a.*  
from MagentoImports..epc_preference_history a join  
 MagentoImports..epc_preference b on a.preference_id = b.preference_id  
where b.email = @Email  
order by a.change_date desc  
  
if @Email is not null  
select *  
from MagentoImports..epc_preference_history   
where change_type like '%email%'  
and value_old = @Email  

if @Email is not null
select *
from Archive.epc_preference_audit_trail
where email = @Email
order by ChangeDate
  
-- Get customer 40 days Email contacts  
select a.CustomerID, a.StartDate, a.EmailAddress, a.Adcode, b.AdcodeName  
from Archive.EmailhistoryCurrentYear a join  
 Mapping.vwAdcodesAll b on a.AdCode = b.AdCode  
where a.StartDate >= DATEADD(DAY,-(@Days),GETDATE())  
and a.customerid  = @CustID  
order by a.StartDate desc  
   
  
  
  
  
  
GO
