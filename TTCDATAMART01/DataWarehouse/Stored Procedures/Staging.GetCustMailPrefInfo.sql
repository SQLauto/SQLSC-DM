SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
  
CREATE PROC [Staging].[GetCustMailPrefInfo]  
 @CustInfo varchar(60),  
 @CustInfoType varchar(1),  
 @Days int = 40  
  
AS   
  
/* Preethi Ramanujam  3/6/2014  
 To get customer's Email Preference Information  
*/  
  
Declare @CustID nvarchar(20), @ErrorMsg varchar(400)  
  
set @CustID = null  
  
If @CustInfoType = 'C'  
 set @CustID = @CustInfo  
else if @CustInfoType = 'E'  
 select @CustID = customerID  
 from Marketing.epc_preference  
 where Email = @CustInfo  
  
   
IF @CustID IS NULL  
BEGIN   
 /* Check if we can get the DL control version of catalogcode *****/  
 SET @ErrorMsg = 'No Customer was found for ' + @CustInfoType + ': ' + @CustInfo  
 PRINT @ErrorMsg  
 Return  
END  
  
  
-- Get customer inforamtion  
select CustomerID, FirstName, LastName, CustomerSince, EmailAddress,  
 FlagMail, FlagValidRegionUS,  
 Address1, Address2, Address3, City, State, PostalCode, CountryCode  
from Marketing.CampaignCustomerSignature  
where CustomerID = @CustID   
  
-- Get customer inforamtion  
select CustomerID, FirstName, LastName, CustomerSince, NewSeg, Name, a12mf, ComboID  
from Marketing.CampaignCustomerSignature  
where CustomerID = @CustID   
  
-- Get customer optin tracker inforamtion   
select * from Archive.CustomerOptinTracker  
where CustomerID = @CustID  
order by AsOfDate  
  
-- Get optin from DAX Table  
select * from DAXImports..TTC_AUDITCUSTOPTINCHANGES  
where CUSTACCOUNT = @CustID  
and OPTINID = 'OfferMail'  
order by MODIFIEDDATETIME   
  
  
-- Get customer 40 days Mail contacts  
select a.CustomerID, a.StartDate, a.Adcode, b.AdcodeName  
from Archive.MailHistoryCurrentYear a join  
 Mapping.vwAdcodesAll b on a.AdCode = b.AdCode  
where a.StartDate >= DATEADD(DAY,-(@Days),GETDATE())  
and a.customerid  = @CustID  
order by a.StartDate desc  
   
  
  
  
  
  
  
GO
