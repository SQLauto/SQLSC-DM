SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE proc [dbo].[SP_Calc_RFI] 
as
Begin

return 0

/* this is the RFI template*/


/*Email_Offers2015 mapping */

/*

Insert into Mapping.Email_Offers2015    select  501,'Starting at $19.95/$14.95' 
Insert into Mapping.Email_Offers2015    select  502,'NO OFFER' 
Insert into Mapping.Email_Offers2015    select  503,'Buy One, Get One 50% Off' 
Insert into Mapping.Email_Offers2015    select  504,'$20 Off $100' 
Insert into Mapping.Email_Offers2015    select  505,'10% Off Plus Free Shipping' 
Insert into Mapping.Email_Offers2015    select  506,'10% Off Any Order' 
Insert into Mapping.Email_Offers2015    select  507,'$15 Off 2 or More Plus Free Shipping' 
Insert into Mapping.Email_Offers2015    select  508,'$15 Off 2 or More' 
Insert into Mapping.Email_Offers2015    select  509,'20% Off 3 or More Plus Free Shipping' 
Insert into Mapping.Email_Offers2015    select  510,'20% Off 3 or More' 
Insert into Mapping.Email_Offers2015    select  511,'Buy 2, Get 1 FREE' 
Insert into Mapping.Email_Offers2015    select  515,'20% Off $150' 
Insert into Mapping.Email_Offers2015    select  516,'15% Off $100' 
Insert into Mapping.Email_Offers2015    select  517,'50% Off Sale Price' 
Insert into Mapping.Email_Offers2015    select  519,'UP TO 90% OFF' 
Insert into Mapping.Email_Offers2015    select  520,'15% Off 2 or More' 
Insert into Mapping.Email_Offers2015    select  521,'$10 OFF ' 
Insert into Mapping.Email_Offers2015    select  522,'25% Off $200' 
Insert into Mapping.Email_Offers2015    select  523,'Up to 80% Off' 
Insert into Mapping.Email_Offers2015    select  524,'Free Shipping' 
Insert into Mapping.Email_Offers2015    select  527,'$15 Off $125 PLUS Free Shipping' 
Insert into Mapping.Email_Offers2015    select  528,'$15 Off $125' 
Insert into Mapping.Email_Offers2015    select  529,'20% Off $200 PLUS Free Shipping' 
Insert into Mapping.Email_Offers2015    select  531,'$.99 Shipping' 
Insert into Mapping.Email_Offers2015    select  532,'Free 2-Day Shipping' 
Insert into Mapping.Email_Offers2015    select  535,'$25 Off 2 or More' 
Insert into Mapping.Email_Offers2015    select  536,'$4.95 Shipping' 
Insert into Mapping.Email_Offers2015    select  538,'$15 Off $100 or 20% Off $200' 
Insert into Mapping.Email_Offers2015    select  539,'15% Off $75' 
Insert into Mapping.Email_Offers2015    select  540,'20% Off Any Order' 
Insert into Mapping.Email_Offers2015    select  541,'$20 Off $125' 
Insert into Mapping.Email_Offers2015    select  543,'20% Off $100' 
Insert into Mapping.Email_Offers2015    select  544,'Free Shipping Plus 15% Off 2 or More Sets' 
Insert into Mapping.Email_Offers2015    select  545,'Up to 90% Off PLUS 20% Off $150' 
Insert into Mapping.Email_Offers2015    select  546,'$15 Off $100 Plus 99 Cent Shipping' 
Insert into Mapping.Email_Offers2015    select  547,'$15 off $100' 
Insert into Mapping.Email_Offers2015    select  548,'10% OFF $50, 15% OFF $100, 20% OFF $150' 
Insert into Mapping.Email_Offers2015    select  549,'$20 Off 2 or More' 
Insert into Mapping.Email_Offers2015    select  550,'Buy One, Get One 40% Off' 
Insert into Mapping.Email_Offers2015    select  551,'$25 Off $125' 
Insert into Mapping.Email_Offers2015    select  552,'20% Off 2 or More' 
Insert into Mapping.Email_Offers2015    select  554,'PM8 Pricing' 
Insert into Mapping.Email_Offers2015    select  555,'10% Off $50' 
Insert into Mapping.Email_Offers2015    select  557,'Buy 3, Get 1 Free' 
Insert into Mapping.Email_Offers2015    select  558,'$10 OFF Any Order OR $20 Off $100' 
Insert into Mapping.Email_Offers2015    select  559,'Free Shipping and Free Tote' 
Insert into Mapping.Email_Offers2015    select  560,'$20 Off $100 PLUS Free Shipping' 
Insert into Mapping.Email_Offers2015    select  561,'15% Off 2 or More Sets Plus Free Shipping' 
Insert into Mapping.Email_Offers2015    select  562,'15% Off $75 PLUS Free Shipping' 
Insert into Mapping.Email_Offers2015    select  563,'15% Off $75 ' 
Insert into Mapping.Email_Offers2015    select  565,'$10 Off Any Order OR $25 Off $150' 
Insert into Mapping.Email_Offers2015    select  568,'$10 Off $50 for "Likes"' 
Insert into Mapping.Email_Offers2015    select  570,'10 % off $50 OR 15% off $100' 
Insert into Mapping.Email_Offers2015    select  571,'Free Messanger Bag with Purchase' 
Insert into Mapping.Email_Offers2015    select  572,'$20 Off $70' 
Insert into Mapping.Email_Offers2015    select  573,'25% off $150 ' 
Insert into Mapping.Email_Offers2015    select  574,'$2.95 Shipping' 
Insert into Mapping.Email_Offers2015    select  575,'314 Courses on Sale + Free Math Course Download & Free Shipping' 
Insert into Mapping.Email_Offers2015    select  576,'Buy One, Get One Additional 25% Off' 
Insert into Mapping.Email_Offers2015    select  578,'25% Off $100' 
Insert into Mapping.Email_Offers2015    select  580,'Free reusable grocery bag with every purchase' 
Insert into Mapping.Email_Offers2015    select  581,'15% Off All Orders' 
Insert into Mapping.Email_Offers2015    select  583,'15% Off All Sets' 
Insert into Mapping.Email_Offers2015    select  584,'$50 Off $200' 
Insert into Mapping.Email_Offers2015    select  585,'10% Off $100 or 20% Off $200 PLUS Free Shipping (US Only); PLUS $10 off (Canada/Int''l) ' 
Insert into Mapping.Email_Offers2015    select  587,'15% Off $150' 
Insert into Mapping.Email_Offers2015    select  588,'Free Journal' 
Insert into Mapping.Email_Offers2015    select  591,'Free Journal PLUS Free Shipping' 
Insert into Mapping.Email_Offers2015    select  592,'$30 Off $150' 
Insert into Mapping.Email_Offers2015    select  593,'$10 Off PLUS Free Tote Bag' 
Insert into Mapping.Email_Offers2015    select  595,'$30 Off $150 Plus Free Shipping' 
Insert into Mapping.Email_Offers2015    select  597,'$10 Off PLUS Free Journal' 
Insert into Mapping.Email_Offers2015    select  598,'20% Off 2 or more Sets' 
Insert into Mapping.Email_Offers2015    select  599,'$50 Off $250 Plus Free Shipping' 
Insert into Mapping.Email_Offers2015    select  600,'10% Off 1 Course OR 20% Off 2 or more' 
Insert into Mapping.Email_Offers2015    select  601,'$30 Off ' 
Insert into Mapping.Email_Offers2015    select  603,'Spend $150, Get a Download Course Free' 
Insert into Mapping.Email_Offers2015    select  604,'Courses Starting at $19.95/ $14.95 PLUS $4.95 Shipping' 
Insert into Mapping.Email_Offers2015    select  606,'Buy 3, Get 1 Free PLUS FREE Shipping' 
Insert into Mapping.Email_Offers2015    select  607,'All clearance courses 80% Off' 
Insert into Mapping.Email_Offers2015    select  608,'PM5 Pricing' 
Insert into Mapping.Email_Offers2015    select  609,'$20 Off $100 PLUS Free Travel Mug)' 
Insert into Mapping.Email_Offers2015    select  611,'$15 Off $100 PLUS Messanger Bag  ' 
Insert into Mapping.Email_Offers2015    select  612,'$20 Off $100 PLUS Free Tote' 
Insert into Mapping.Email_Offers2015    select  613,'20% Off $100 PLUS Free Shipping' 
Insert into Mapping.Email_Offers2015    select  614,'20% Off $150 Plus Free Shipping' 
Insert into Mapping.Email_Offers2015    select  615,'20% Off 2 or More Sets, Plus Free Shipping' 
Insert into Mapping.Email_Offers2015    select  616,'Up to 90% Off Plus $30 Off $150 & Free Shipping' 
Insert into Mapping.Email_Offers2015    select  617,'Free Shipping PLUS Buy 1, Get 1 40% Off' 
Insert into Mapping.Email_Offers2015    select  619,'personalized course with SUT' 
Insert into Mapping.Email_Offers2015    select  622,'15% off $75; 20% off $150; 25% off $250' 
Insert into Mapping.Email_Offers2015    select  623,'$25 off $250' 
Insert into Mapping.Email_Offers2015    select  624,'15% off $100 or 20% off $200' 
Insert into Mapping.Email_Offers2015    select  625,'10% off $150' 
Insert into Mapping.Email_Offers2015    select  626,'30% off $100' 
Insert into Mapping.Email_Offers2015    select  627,'$10 off any order, OR Free Messenger bag on $150+' 
Insert into Mapping.Email_Offers2015    select  628,'$15 off $100 or Buy 3, Get 1 Free' 
Insert into Mapping.Email_Offers2015    select  629,'$40 off $200' 
Insert into Mapping.Email_Offers2015    select  630,'10% off $100; 15% off $200; 20% off $300' 
Insert into Mapping.Email_Offers2015    select  631,'FREE Course with any order over $100' 
Insert into Mapping.Email_Offers2015    select  632,'$25 off $100' 
Insert into Mapping.Email_Offers2015    select  633,'15% Off' 
Insert into Mapping.Email_Offers2015    select  634,'20% off $125' 
Insert into Mapping.Email_Offers2015    select  635,'$20 off $150' 
Insert into Mapping.Email_Offers2015    select  636,'Up to 90% off Plus $30 Off $150' 

*/


select * from Datawarehouse.Mapping.Email_Offers
select * from Datawarehouse.Mapping.Email_Offers2015

-- Take this time to move the conversion mapping table to Datawarehouse
--select * 
--into Datawarehouse.Mapping.EmailTypeConversionTable
--from datawarehouse.mapping.EmailTypeConversionTable


----- RFI Starts Here

if object_id('Mapping.EmailTypeConversionTable2015')  is not null 
Drop table Datawarehouse.Mapping.EmailTypeConversionTable2015

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
 into Datawarehouse.Mapping.EmailTypeConversionTable2015
 from DataWarehouse.Marketing.EmailTrackerNew E
 left join [staging].[EmailTypeConversion2015] S
 on E.catalogCode = S.catalogCode
 left join mapping.vwAdcodesAll V
 on E.catalogCode = V.catalogCode
 where YearOfEmailSent =2015
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
join datawarehouse.mapping.EmailTypeConversionTable2015 b on a.CatalogCode=b.catalogcode
left join DataWarehouse.Mapping.Email_Offers2015 c on b.emailofferid = c.EmailOfferID
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


--select Flag_DoublePunch,count(*) from  Datawarehouse.dbo.EmailReportPrep1
--group by Flag_DoublePunch
--order by 1


select count(*) from Datawarehouse.dbo.EmailReportPrep1


drop table Datawarehouse.Marketing.Email_RFI_Report

insert into Datawarehouse.Marketing.Email_RFI_Report
select * --into Datawarehouse.Marketing.Email_RFI_Report
from Datawarehouse.dbo.EmailReportPrep1


select * from  Datawarehouse.Marketing.Email_RFI_Report

--truncate table Datawarehouse.Marketing.Email_RFI_Report

--insert into Datawarehouse.Marketing.Email_RFI_Report
--select *from Datawarehouse.dbo.EmailReportPrep1

/*
Delete F from Datawarehouse.Marketing.Email_RFI_Report f
join Datawarehouse.dbo.EmailReportPrep1  s
on f.CatalogCode = S.CatalogCode


select count(*),f.EmailYear from Datawarehouse.Marketing.Email_RFI_Report f
 group by f.EmailYear

insert into Datawarehouse.Marketing.Email_RFI_Report
(campaignid,campaignName,CatalogCode,catalogname,StartDate,EmailYear,EmailMonth,StopDate,TotalEmailed,TotalSales,TotalOrders,TotalCourseParts,
TotalCourseSales,TotalCourseUnits,EmailID,EmailType,Flag_DoublePunch,EmailOfferID,EmailOffer,Recency,Interval,Frequency,PriorRunDate,ReportDate,FrequencyByYear)
select 
campaignid,campaignName,CatalogCode,catalogname,StartDate,EmailYear,EmailMonth,StopDate,TotalEmailed,TotalSales,TotalOrders,TotalCourseParts,
TotalCourseSales,TotalCourseUnits,EmailID,cast(EmailType as varchar(255)),Flag_DoublePunch,EmailOfferID,cast(EmailOffer as varchar(100)),Recency,Interval,Frequency,PriorRunDate,ReportDate,FrequencyByYear
 from Datawarehouse.dbo.EmailReportPrep1
  
 


 select * from Datawarehouse.Marketing.Email_RFI_Report
 where emailyear=2015
 and EmailOfferID is NULL

 select * from Datawarehouse.Mapping.Email_Offers2015



 select * from Datawarehouse.Marketing.Email_RFI_Report f
left  join  [staging].[EmailTypeConversion2015]S
on f.CatalogCode = S.CatalogCode 
where  emailyear=2015 and f.EmailOfferID is NULL


select * from [staging].[EmailTypeConversion2015]S
where catalogcode in (
 select distinct catalogcode from Datawarehouse.Marketing.Email_RFI_Report
 where emailyear=2015
 and EmailOfferID is NULL)

 */

 

 --select * into Datawarehouse.archive.Email_RFI_Report_20160519 from Datawarehouse.Marketing.Email_RFI_Report


 --Add MD_Country


 --MD_Country
 --select * from DataWarehouse.Mapping.vwAdcodesAll
 --where CatalogCode =35233


 --Alter table Datawarehouse.Marketing.Email_RFI_Report add MD_Country varchar(50)

 --update F
 --set f.MD_Country = c.MD_Country
 ----select c.*,f.* 
 --from Datawarehouse.Marketing.Email_RFI_Report f
 --join (select distinct catalogcode,MD_Country from  DataWarehouse.Mapping.vwAdcodesAll) C
 --on c.CatalogCode=f.CatalogCode

 
-- update a
--set Flag_DoublePunch = case when catalogname like '%DP%' then 1
--			when catalogname like '%TP%' then 2 
--			else 0 end from Datawarehouse.Marketing.Email_RFI_Report a
--where EmailYear=2015
 
 End

GO
