SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE View [Marketing].[Vw_EPC_Prospect_EmailPull]  
as  

select cast(EPC.Email as varchar(51)) as Emailaddress,
	EPC.NewCourseAnnouncements,
	EPC.FreeLecturesClipsandInterviews,
	EPC.ExclusiveOffers,
	EPC.Frequency as EmailFrequency ,  
	EPC.MagentoDaxMapped_Flag,
	ECI.magento_created_date,
	case when P.Store_id  = 1 then 'US'
		 when P.Store_id  = 2 then 'uk_en'
		 when P.Store_id  = 3 then 'au_en'
		 else ECI.store_country end as store_country,
	case when P.Store_id  = 1 then 'US'
		 when P.Store_id  = 2 then 'UK'
		 when P.Store_id  = 3 then 'AU'
		 else ECI.website_country end as website_country
from DataWarehouse.Marketing.epc_preference EPC 
left join MagentoImports..Email_Customer_Information ECI 
on epc.Email = RTRIM(LTRIM(ECI.subscriber_email)) 
left join MagentoImports..epc_preference p
on rtrim(ltrim(p.email)) = EPC.Email
where EPC.Subscribed = 1 
and EPC.Snoozed = 0 
and EPC.hardbounce = 0 and EPC.Softbounce = 0 and EPC.Blacklist = 0  
and isnull(EPC.CustomerID ,'')=''
and EPC.Email like '%@%'
/* Only include after 35 days end of Prospect wave VB 3/7/2017 */
AND epc.Email NOT IN (SELECT RTRIM(LTRIM(email)) FROM MagentoImports..epc_preference p WHERE p.registration_source_id = 7 AND DATEDIFF(d,p.created_date,GETDATE())>35 ) 
GO
