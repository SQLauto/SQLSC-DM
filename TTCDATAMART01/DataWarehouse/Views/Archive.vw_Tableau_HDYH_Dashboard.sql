SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[vw_Tableau_HDYH_Dashboard] as
Select
a.*,
c.*,
b.IntlSubDate as SignatureSubDate,
b.IntlMD_Channel as SignatureChannel,
b.uuid as Signatureuuid,
b.IntlCampaignID as SignatureCampaignID,
b.IntlMD_PromotionType as SignaturePromotionType
from
(
select c.uuid, 
c.IntlSubDate, 
c.IntlSubMonth, 
c.IntlSubYear,
c.IntlSubPlanID,
c.IntlCampaignName, 
c.IntlMD_Channel, 
EventLabel, 
Action,
DeviceCategory, 
CASE
    WHEN answervalue is null THEN 1
    WHEN answervalue is not null then answervalue
END as answervalue
from DataWarehouse.Marketing.TGCPlus_CustomerSignature (nolock) c
left join (
select s1.UUID, 
EventLabel, 
Action,
DeviceCategory, 
answervalue 
from DataWarehouse.Archive.Vw_GA_Survey s1 
left join (
	select uuid, 
	cast(1 as float)/count(uuid) as answervalue 
	from DataWarehouse.Archive.Vw_GA_Survey (nolock)
	group by uuid
) s2 on s1.uuid=s2.UUID) s3 on s3.UUID=c.uuid
where IntlSubDate>='2016-04-01' and Action='How did you hear about us'
) as A
right join
	Archive.vw_tgcplus_customersignature (nolock) b on a.uuid = b.uuid
full outer join
	(select *, cast(EventTime as date) as EventDate from DataWarehouse.Archive.TGCPLus_AppsFlyer_AppEvents (nolock) where eventname='Subscription' and MediaSource is not null) c on a.uuid = c.CustomerUserID and a.IntlSubDate = c.EventDate

; 

GO
