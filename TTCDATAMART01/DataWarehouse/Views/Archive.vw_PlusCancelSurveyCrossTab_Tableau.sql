SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[vw_PlusCancelSurveyCrossTab_Tableau] as
Select 
Main.uuid, 
Main.CancelDate,
a.customerid,  
case when a.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerType, a.IntlMD_Channel, a.IntlSubDate, a.IntlSubType, a.IntlSubPaymentHandler, isnull(a.LTDPaidAmt,0) LTDPaidAmt, a.DSDayCancelled,
Cancel.Cancel, Cancel.CancelActions,
Feature.Feature, Feature.FeatureActions
from
 Marketing.TGCPLus_GA_Cancels (nolock) Main
left join marketing.tgcplus_customersignature (nolock) a on Main.uuid = a.uuid
left join
(
select uuid, eventlabel as Cancel, sum(Users) as CancelActions 
from archive.ga_survey (nolock) where Action = 'Cancel Survey - Why are you canceling your Great Courses Plus Subscription' group by uuid, eventlabel  
) Cancel on Main.uuid = Cancel.uuid 
left join
(
select uuid, eventlabel as Feature, sum(Users) as FeatureActions 
from archive.ga_survey (nolock) where Action = 'Cancel Survey - Would the following features reverse your decision to cancel?' group by uuid, eventlabel 
) Feature on Main.uuid = Feature.uuid
where Main.CancelDate > '2017-08-03'  and IIF(a.customerid IS NULL, 1, 0) = 0 and iif(Main.uuid IS NULL,1,0) = 0; 
GO
