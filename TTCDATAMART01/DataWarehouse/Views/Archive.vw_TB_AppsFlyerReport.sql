SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[vw_TB_AppsFlyerReport] as
Select distinct
CS.*,
AF.Platform, 
case
       when AF.AttributedTouchType = 'click' then 'Paid'
       when AF.AttributedTouchType = 'impression' then 'Paid'
       else 'Organic' end as TouchType, 
AF.MediaSource, 
AF.Channel, 
AF.KeyWords, 
AF.CampaignID, 
AF.Campaign, 
AF.AdSetID, 
AF.AdSet, 
AF.AdID, 
AF.Ad, 
AF.Region,
AF.CountryCode, 
AF.State, 
AF.City, 
AF.PostalCode,
Lkp.AdCode, 
Lkp.Cost,
case when isnull(CT.DateDiffCol,0) = 0 then 0 else 1 end as VLDataIssueIndicator
from
		(
		select uuid, CustomerID, IntlSubDate, IntlSubPaymentHandler, IntlSubType, CustStatusFlag, DSMonthCancelled_New, DS, BillingRank 
		from Datawarehouse.Archive.vw_tgcplus_customersignature (nolock) 
		where IntlSubDate >= '2017-08-24' 
		and IntlSubDate <= (select max(cast(eventtime as date)) EventDate from Datawarehouse.Marketing.TGCPLus_AppsFlyer_AppEvents (nolock)) 
		and IntlSubPaymentHandler in ('iOS', 'Android')
		) as CS
    left join
		(
		select eventtime, eventname, 
		AttributedTouchType, MediaSource, Channel, Keywords, Campaign, CampaignID, Adset, 
		AdSetID, Ad, AdID, Region, CountryCode, State, City, PostalCode, CustomerUserID, Platform, cast(eventtime as date) as EventDate
		from Datawarehouse.Marketing.TGCPLus_AppsFlyer_AppEvents (nolock) 
		where CustomerUserID not in ('')
		) as AF on CS.uuid = AF.CustomerUserID
    left join
		(SELECT * from DataWarehouse.Staging.appsflyer_ssis_master (nolock)) as Lkp 
		on AF.Platform = Lkp.Platform and AF.Campaign = Lkp.Campaign and AF.MediaSource = Lkp.MediaSource
	left join 
		(select datediff(m,MinDSDate,MaxDSDate) as DateDiffCol , LTDPaymentRank, CustomerID 
		from datawarehouse.archive.tgcplus_ds (nolock) 
		where datediff(m,MinDSDate,MaxDSDate) + 1 < LTDPaymentRank and CurrentDS =1) as CT on CS.Customerid=CT.CustomerID
		; 
GO
