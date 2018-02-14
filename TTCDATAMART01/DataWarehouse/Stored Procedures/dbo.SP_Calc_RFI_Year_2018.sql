SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE proc [dbo].[SP_Calc_RFI_Year_2018] 
as
Begin

--return 0

--insert into [Mapping].[offer_offercodeid_2018] 

--select '$25 Off $200',	704 
--Union select '$20 Off $80',	705
--Union select 'Up to 25% Off',	706
--Union select 'Free Roku w/ Any Order',	707
--Union select '20% Off $150 + Free Tote',	708
--Union select '$10 Off $50;  $25 Off $100;  $40 Off $150',	709
--Union select '15% Off DVD/CD or 20% Off Digital',	710
--Union select '10% Off Digital; Free Delivery',	711
--Union select '20% Off Sets + Free Tote',	712
--order by 2
 
    

select top 10 * from [Mapping].[offer_offercodeid_2018]
select top 10 * from  [Mapping].[adcode_offercodeid_2018]

update [Mapping].[adcode_offercodeid_2018]
set OfferCodeID = 502
where adcode in (select distinct adcode from DataWarehouse.Archive.EmailHistory2017FrequencyTestHoldouts)



--select * from Datawarehouse.Mapping.Email_Offers
--select * from Datawarehouse.Mapping.Email_Offers2015

-- Take this time to move the conversion mapping table to Datawarehouse
--select * 
--into Datawarehouse.Mapping.EmailTypeConversionTable
--from datawarehouse.mapping.EmailTypeConversionTable

--select top 10 * from [staging].[EmailTypeConversion2015]
if object_id('staging.EmailTypeConversion2018')  is not null 
drop table staging.EmailTypeConversion2018

select CatalogCode,CatalogName,MA.Adcode,MO.Offer as EmailOffer,MA.OfferCodeID as EmailOfferID 
into  [staging].[EmailTypeConversion2018]
from [Mapping].[adcode_offercodeid_2018] MA 
join [Mapping].[offer_offercodeid_2018] MO 
on MO.OfferCodeID = MA.OfferCodeID
join Mapping.vwAdcodesAll v 
on MA.AdCode = v.AdCode


----- RFI Starts Here

if object_id('Mapping.EmailTypeConversionTable2018')  is not null 
Drop table Datawarehouse.Mapping.EmailTypeConversionTable2018

 select E.CatalogCode,E.CatalogName
 --,replace(E.MD_CampaignName,'Email: ','') as EmailType
 -- ,V.MD_CampaignID as EmailID
 , case when E.CatalogName like '%DP%' then 1
		when E.CatalogName like '%TP%' then 2
		when E.CatalogName like '%QP%' then 3
	else 0 end as Flag_DoublePunch
 , S.EmailOfferId
 ,v.MD_PromotionTypeID as MD_PromotionTypeID 
 ,v.MD_PromotionType as MD_PromotionType 
 ,v.MD_CampaignId
 ,V.MD_CampaignName
 ,V.MD_Country
 into Datawarehouse.Mapping.EmailTypeConversionTable2018
 from DataWarehouse.Marketing.EmailTrackerNew E
 left join [staging].[EmailTypeConversion2018] S
 on E.catalogCode = S.catalogCode
 left join mapping.vwAdcodesAll V
 on E.catalogCode = V.catalogCode
 where YearOfEmailSent =2018
 group by E.CatalogCode,E.CatalogName,S.EmailOfferId,V.MD_CampaignID,v.MD_PromotionTypeID,v.MD_PromotionType,v.MD_CampaignId,V.MD_CampaignName,V.MD_Country
 


if object_id('dbo.EmailReportPrep1_ByYear')  is not null 
drop table datawarehouse.dbo.EmailReportPrep1_ByYear


select b.MD_CampaignId as CampaignId ,b.MD_CampaignName as campaignName,b.MD_PromotionTypeID as PromotionTypeID, b.MD_PromotionType as PromotionType,b.MD_Country as Country,
    a.CatalogCode, a.catalogname, 
	EhiststartDate as StartDate, YEAR(EhiststartDate) as EmailYear,
	MONTH(EhiststartDate) as EmailMonth,
	CustomerSegmentFnl, customerSegment +  case when MultiOrSingle = 'Multi' then '_Multi' 
														when MultiOrSingle = 'Single' then '_Single' 
														else '' end as CustomerSegmentFrcst,
	a.StopDate, Sum(a.TotalEmailed) as TotalEmailed,
	Sum(TotalSales) as TotalSales, SUM(TotalOrders) as TotalOrders,
	Sum(TotalCourseParts) as TotalCourseParts, SUM(TotalCourseSales) as TotalCourseSales,
	Sum(TotalCourseUnits) as TotalCourseUnits,
	--b.EmailID, b.EmailType,
	b.Flag_DoublePunch, 
	b.EmailOfferID, c.EmailOffer,
	CONVERT(int, null) as Recency,
	CONVERT(int, Null) as Interval, CONVERT(Int,Null) as Frequency,CONVERT(Int,Null) as FrequencyByYear,CONVERT(Int,Null) as FrequencyByCampiagn,
	CONVERT(Datetime, Null) as PriorRunDate, GETDATE() as ReportDate
	
into datawarehouse.dbo.EmailReportPrep1_ByYear
from datawarehouse.Marketing.EmailtrackerNew a
join datawarehouse.mapping.EmailTypeConversionTable2018 b on a.CatalogCode=b.catalogcode
left join (select offer as EmailOffer, OfferCodeID as EmailOfferId from [Mapping].[offer_offercodeid_2018]) c on b.emailofferid = c.EmailOfferID
Left join DataWarehouse.Mapping.vwAdcodesAll V on a.CatalogCode=v.catalogcode
where --a.CustomerSegment='Active' and 
a.FlagEmailed=1
GROUP BY b.MD_CampaignId ,b.MD_CampaignName,b.MD_PromotionTypeID , b.MD_PromotionType,b.MD_Country, a.CatalogCode, a.catalogname, EhiststartDate,
a.StopDate, CustomerSegment, CustomerSegmentFnl,--b.EmailID, b.EmailType, 
b.Flag_DoublePunch, b.EmailOfferID, c.EmailOffer, YEAR(EhiststartDate), MONTH(EhiststartDate), customerSegment +  case when MultiOrSingle = 'Multi' then '_Multi' 
														when MultiOrSingle = 'Single' then '_Single' 
														else '' end

create index IX_EmailReportPrep1_ByYear1 on datawarehouse.dbo.EmailReportPrep1_ByYear(campaignid)
create index IX_EmailReportPrep1_ByYear2 on datawarehouse.dbo.EmailReportPrep1_ByYear(CatalogCode)


/*Only Frequency */ 
if object_id ('tempdb..#EmailReportPrep2_ByFrequency') is not null
drop table  #EmailReportPrep2_ByFrequency
select distinct campaignid,
		Country,
		startdate,
		--year(startdate)startdate_year, 
		--month(startdate)startdate_Month,
		dense_rank() over (partition by CampaignId,Country order by startdate /*year(startdate),month(startdate)*/) as Rank3
into #EmailReportPrep2_ByFrequency
from Datawarehouse.dbo.EmailReportPrep1_ByYear
order by CampaignID,Country,  rank3

update A
set a.frequency=b.rank3
from Datawarehouse.dbo.EmailReportPrep1_ByYear a
join #EmailReportPrep2_ByFrequency b
on a.campaignid=b.campaignid --and year(startdate)=startdate_year  and Month(startdate)=startdate_Month  
and b.startdate=a.startdate
and a.Country=b.Country


/*By Campaign Frequency */
if object_id ('tempdb..#EmailReportPrep2_ByCampaignFrequency') is not null
drop table  #EmailReportPrep2_ByCampaignFrequency
select distinct campaignid,
		Country,
		StopDate,
		--year(startdate)startdate_year, 
		--month(startdate)startdate_Month,
		dense_rank() over (partition by CampaignId,Country order by StopDate /*year(startdate),month(startdate)*/) as Rank3
into #EmailReportPrep2_ByCampaignFrequency
from Datawarehouse.dbo.EmailReportPrep1_ByYear
--where campaignid=164
order by CampaignID,Country,  rank3

update A
set a.FrequencyByCampiagn=b.rank3
from Datawarehouse.dbo.EmailReportPrep1_ByYear a
join #EmailReportPrep2_ByCampaignFrequency b
on a.campaignid=b.campaignid   
and b.StopDate=a.StopDate
and a.Country=b.Country



update A
set a.PriorRunDate=b.StartDate
From Datawarehouse.dbo.EmailReportPrep1_ByYear a
join
(select *, (FrequencyByCampiagn+1) as FrequencyByCampiagn1 from Datawarehouse.dbo.EmailReportPrep1_ByYear) b
on  a.campaignid=b.campaignid and a.FrequencyByCampiagn=b.FrequencyByCampiagn1 and a.Country=b.Country 



if object_id('tempdb..#EmailReportPrep2_ByFrequencyYear')  is not null 
drop table #EmailReportPrep2_ByFrequencyYear

select distinct campaignid,
	Country,
	emailyear,
	Startdate, 
	dense_rank() over (partition by CampaignId, Country,EmailYear order by Startdate) as Rank3
into #EmailReportPrep2_ByFrequencyYear
from Datawarehouse.dbo.EmailReportPrep1_ByYear
order by CampaignID, emailyear,Country, rank3

update A
set a.FrequencyByYear=b.rank3
from Datawarehouse.dbo.EmailReportPrep1_ByYear a
join #EmailReportPrep2_ByFrequencyYear b
on a.campaignid=b.campaignid 
and a.EmailYear=b.EmailYear 
and a.Startdate=b.Startdate 
 and a.Country=b.Country

update A
set a.interval=DATEDIFF(day,priorrundate,startdate) 
from Datawarehouse.dbo.EmailReportPrep1_ByYear a

update A
set a.interval=0 
from Datawarehouse.dbo.EmailReportPrep1_ByYear a
where interval is null

update A
set a.recency=DATEDIFF(day,startdate,GETDATE()) 
from Datawarehouse.dbo.EmailReportPrep1_ByYear a


if object_id('dbo.EmailReportPrep1')  is not null 
drop table Datawarehouse.dbo.EmailReportPrep1

select *
into Datawarehouse.dbo.EmailReportPrep1
from Datawarehouse.dbo.EmailReportPrep1_ByYear


select count(*)Cnts_EmailReportPrep1 from Datawarehouse.dbo.EmailReportPrep1

if object_id('Marketing.Email_RFI_Report2018')  is not null 
drop table Datawarehouse.Marketing.Email_RFI_Report2018
 

select * 
into Datawarehouse.Marketing.Email_RFI_Report2018
from Datawarehouse.dbo.EmailReportPrep1


select count(*)Cnts_Email_RFI_Report2018 from  Datawarehouse.Marketing.Email_RFI_Report2018


 
 End


GO
