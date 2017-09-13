SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[vw_PlusCancelSurvey_Tableau] as
Select 
Main.uuid, 
Main.CancelDate,
a.customerid,  
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerType, a.IntlMD_Channel, a.IntlSubDate, a.IntlSubType, a.IntlSubPaymentHandler, isnull(a.LTDPaidAmt,0) LTDPaidAmt, a.DSDayCancelled,
isnull(Cancel.Cancel_Foundanothersourceforthecontentthatinterestsme,0) Cancel_Foundanothersourceforthecontentthatinterestsme, 
isnull(Cancel.Cancel_Isnotavailableordoesnotperformwellonmypreferredviewingdevice,0) Cancel_Isnotavailableordoesnotperformwellonmypreferredviewingdevice,
isnull(Cancel.Cancel_Notenoughtimetowatchthevideos,0) Cancel_Notenoughtimetowatchthevideos,
isnull(Cancel.Cancel_Priceistoohighforthevalueoftheservice,0) Cancel_Priceistoohighforthevalueoftheservice,
isnull(Cancel.Cancel_Videoprogrammingdidnotmeetmyexpectations,0) Cancel_Videoprogrammingdidnotmeetmyexpectations,
isnull(Feature.[Feature_Ability to pause your subscription for a period of time],0) [Feature_Ability to pause your subscription for a period of time],
isnull(Feature.[Feature_Availability of audio-only courses],0) [Feature_Availability of audio-only courses],
isnull(Feature.[Feature_More content from preferred partners],0) [Feature_More content from preferred partners],
isnull(Feature.[Feature_Special offers related to monthly and annual plans],0) [Feature_Special offers related to monthly and annual plans]
from
 Marketing.TGCPLus_GA_Cancels (nolock) Main
left join marketing.tgcplus_customersignature (nolock) a on Main.uuid = a.uuid
left join
(
SELECT uuid, [1] as [Cancel_Foundanothersourceforthecontentthatinterestsme],[2] as [Cancel_Isnotavailableordoesnotperformwellonmypreferredviewingdevice],
	[3] as [Cancel_Notenoughtimetowatchthevideos],[4] as [Cancel_Priceistoohighforthevalueoftheservice],[5] as [Cancel_Videoprogrammingdidnotmeetmyexpectations],
	[6] as [Cancel_Others]
FROM (SELECT uuid, case  when  Replace(EventLabel,' ','') = 'Foundanothersourceforthecontentthatinterestsme' then 1
		when  Replace(EventLabel,' ','') = 'Isnotavailableordoesnotperformwellonmypreferredviewingdevice' then 2
		when  Replace(EventLabel,' ','') = 'Notenoughtimetowatchthevideos' then 3
		when  Replace(EventLabel,' ','') = 'Priceistoohighforthevalueoftheservice' then 4 
		when  Replace(EventLabel,' ','') = 'Videoprogrammingdidnotmeetmyexpectations' then 5
		else 6 end as EventLabel, users from archive.ga_survey (nolock)
where Action = 'Cancel Survey - Why are you canceling your Great Courses Plus Subscription'
) p PIVOT
(COUNT (users) FOR EventLabel IN([1],[2],[3],[4],[5],[6]) )AS pvt  
) Cancel on Main.uuid = Cancel.uuid 
left join
(

SELECT uuid, [1] as [Feature_Ability to pause your subscription for a period of time],[2] as [Feature_Availability of audio-only courses],
	[3] as [Feature_More content from preferred partners],[4] as [Feature_Special offers related to monthly and annual plans],[5] as [Feature_Others]

FROM (SELECT uuid, case  when  Replace(EventLabel,' ','') = 'Abilitytopauseyoursubscriptionforaperiodoftime' then 1
		when  Replace(EventLabel,' ','') = 'Availabilityofaudio-onlycourses' then 2
		when  Replace(EventLabel,' ','') = 'Morecontentfrompreferredpartners(suchasNationalGeographic,Smithsonian,etc.)' then 3
		when  Replace(EventLabel,' ','') = 'Specialoffersrelatedtomonthlyandannualplans' then 4 
		else 5 end as EventLabel, users from archive.ga_survey (nolock)
where Action = 'Cancel Survey - Would the following features reverse your decision to cancel?'
) p PIVOT
(COUNT (users) FOR EventLabel IN([1],[2],[3],[4],[5],[6]) )AS pvt   
) Feature on Main.uuid = Feature.uuid
where Main.CancelDate > '2017-08-03'  and IIF(a.customerid IS NULL, 1, 0) = 0 and iif(Main.uuid IS NULL,1,0) = 0; 
GO
