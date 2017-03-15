SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE Proc [Staging].[SP_Load_TGCPlus_CustomerSignatureRegs]
as

Begin

Declare @DMLastUpdateESTDateTime Datetime


select @DMLastUpdateESTDateTime = isnull(Max(DMLastUpdateESTDateTime),getdate()) from DataWarehouse.Archive.TGCPlus_PaymentAuthorizationStatus

select @DMLastUpdateESTDateTime

/***************** Registered Only Daily Table *************************/

truncate table staging.TGCPlus_CustomerSignatureRegs

insert into staging.TGCPlus_CustomerSignatureRegs
select dateadd(day,-1,convert(date,@DMLastUpdateESTDateTime)) AsofDate, 
	a.id as CustomerID, 
	a.uuid, 
	a.email EmailAddress, 
	c.CustomerID TGCCustomerID, 
	null CountryCode, 
	TGCPluscampaign IntlCampaignID, 
	b.AdcodeName IntlCampaignName, 
	b.MD_Country IntlMD_Country, 
	b.MD_Audience IntlMD_Audience, 
	b.MD_Channel IntlMD_Channel, 
	b.ChannelID IntlMD_ChannelID, 
	b.MD_PromotionType IntlMD_PromotionType, 
	b.MD_PromotionTypeID IntlMD_PromotionTypeID, 
	b.MD_Year IntlMD_Year, 
	null IntlSubDate, 
	null IntlSubWeek, 
	null IntlSubMonth, 
	null IntlSubYear, 
	null IntlSubPlanID, 
	null IntlSubPlanName, 
	null IntlSubType, 
	null IntlSubPaymentHandler, 
	null SubDate, 
	null SubWeek, 
	null SubMonth, 
	null SubYear, 
	null SubPlanID, 
	null SubPlanName, 
	null SubType, 
	null SubPaymentHandler, 
	'RegisteredOnly' TransactionType, 
	null CustStatusFlag, 
	null PaidFlag, 
	null LTDPaidAmt, 
	null LastPaidDate, 
	null LastPaidWeek, 
	null LastPaidMonth, 
	null LastPaidYear, 
	null LastPaidAmt, 
	null DSDayCancelled, 
	null DSMonthCancelled, 
	null DSDayDeferred, 
	case when c.CustomerID is null then 0 else 1 end TGCCustFlag, 
	case when c.Name in ('18m1','18m2','18m3') then 'Active_Multi'
		else c.CustomerSegmentFnl end TGCCustSegmentFcst, 
	c.CustomerSegmentFnl TGCCustSegmentFnl, 
	null MaxSeqNum, 
	null FirstName, 
	null LastName, 
	null Gender, 
	null Age, 
	null AgeBin, 
	null HouseHoldIncomeBin, 
	null EducationBin, 
	null address1, 
	null address2, 
	null address3, 
	null city, 
	null state, 
	null country, 
	null ZipCode, 
	cast(a.joined as date) RegDate,
	month(a.joined) RegMonth,
	year(a.joined) RegYear
from DataWarehouse.Archive.TGCPlus_User a 
	left join
	DataWarehouse.Mapping.vwAdcodesAll b 
							on a.TGCPluscampaign = b.AdCode 
	left join
	(select distinct epc.Email, epc.CustomerID,
		ccs.CustomerSegment, ccs.CustomerSegmentFnl, ccs.Frequency,
		ccs.NewSeg, ccs.Name, ccs.a12mf, ccs.Gender
	from DataWarehouse.Marketing.epc_preference epc 
		join
		DataWarehouse.Marketing.CampaignCustomerSignature ccs on epc.CustomerID = ccs.CustomerID )c on a.email = c.Email
	left join
	DataWarehouse.Archive.TGCPlus_BillingAddress ba on a.uuid = ba.userId
where cast(a.joined as date) > '9/28/2015' 
and a.entitled_dt is null

/* drop customers who are in signature table */

--select a.* 
delete a
from Staging.TGCPlus_CustomerSignatureRegs a 
	join Marketing.TGCPlus_CustomerSignature b on a.EmailAddress = b.EmailAddress


/* Load to final registration table */

truncate table Marketing.TGCPlus_CustomerSignatureRegs

insert into Datawarehouse.Marketing.TGCPlus_CustomerSignatureRegs
select * 
from Datawarehouse.Staging.TGCPlus_CustomerSignatureRegs

/* drop customers who are in signature table */

--select a.* 
--delete a
--from Staging.TGCPlus_CustomerSignatureRegs a 
--	join Marketing.TGCPlus_CustomerSignature b on a.EmailAddress = b.EmailAddress

--select * 
--from Staging.TGCPlus_CustomerSignatureRegs 

/* Load registration data into Signature table */

--select a.* 
--from Staging.TGCPlus_CustomerSignatureRegs a 
--	left join Marketing.TGCPlus_CustomerSignature b on a.uuid = b.uuid
--where b.uuid is null



END
 



GO
