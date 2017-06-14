SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE View [Marketing].[Vw_EPC_EmailPull]  
as  

/*  
select EPC.Email as Emailaddress,CCS.CustomerID,EPC.NewCourseAnnouncements,  
  EPC.FreeLecturesClipsandInterviews,EPC.ExclusiveOffers,EPC.Frequency as EmailFrequency ,  
  EPC.MagentoDaxMapped_Flag, EPC.ChildCustomerid,EPC.Child_Flag,EPC.Reinstated,  
  NewSeg, Name, a12mf, ComboID, Concatenated, CustomerSegment, CCS.Frequency, Prefix, FirstName,   
  MiddleName, LastName, Suffix, ccs.EmailAddress as Dax_EmailAddress,FlagEmail,   
  FlagValidEmail, FlagEmailPref, R3PurchWeb, FlagWebLTM18, Address1, Address2, City,  
  State, PostalCode, CountryCode, CountryName, FlagValidRegionUS,FlagInternational, Zip5,   
  FlagMail, FirstUsedAdcode, BuyerType, CustomerType,  
  CustomerSince, LastOrderDate, EndDate, InqDate6Mo, InqDate7_12Mo, InqDate12_24Mo,FlagInq,   
  InqType, FirstInq, DRTVInq,PublicLibrary, OtherInstitution,Gender,  
  CG_Gender,PreferredCategory2, LTDPurchasesBin,CRComboID,NumHits,AH,EC,FA, HS, LIT,MH, PH, RL, SC,   
  PreferredCategory, DateOfBirth, Age, HouseHoldIncomeRange,  
  HouseHoldIncomeBin, Education, EducationConfidence, AgeBin, Address3,   
  FW, PR, SCI, MTH, VA, MSC,Phone, Phone2, MediaFormatPreference, OrderSourcePreference,   
  CompanyName ,SecondarySubjPref, CustomerSegmentNew,FlagMailPref ,FlagNonBlankMailAddress,FlagSharePref, FlagOkToShare,   
  CustomerSegment2, CustomerSegmentFnl
  ,med.MaxOpenDate
  ,case when med.EmailAddress is null then 1 else 0 end as FlagDormantCustomer
from DataWarehouse.Marketing.CampaignCustomerSignature CCS  
inner join DataWarehouse.Marketing.epc_preference EPC on EPC.CustomerID = CCS.CustomerID  
left join DataWarehouse.Legacy.InvalidEmails ie on epc.Email = ie.EmailAddress  and isnull(epc.Reinstated,0) = 0 /*Added to include reinstated emails*/
left join DataWarehouse.Legacy.InvalidEmails ie2 on epc.CustomerID = ie2.CustomerID  and isnull(epc.Reinstated,0) = 0 /*Added to include reinstated emails*/
left join Archive.MaxEmailOpenDate med on med.EmailAddress = epc.Email /* PR 5/18/2017 Added to include dormant customer flag */
where 
ie.EmailAddress is null   
and ie2.CustomerID is null  
and EPC.Subscribed = 1   
and EPC.Snoozed = 0   
and EPC.hardbounce = 0   
and EPC.Softbounce = 0   
and EPC.Blacklist = 0  

*/

SELECT epc.*,med.MaxOpenDate
  ,case when med.EmailAddress is null then 1 else 0 end as FlagDormantCustomer 
  FROM [Marketing].[EPC_EmailPull] epc
  left join (SELECT EmailAddress, MAX(MaxOpenDate) AS MaxOpenDate FROM Archive.MaxEmailOpenDate epc GROUP BY EmailAddress) med 
  ON med.EmailAddress = epc.Emailaddress /* PR 5/18/2017 Added to include dormant customer flag */

GO
