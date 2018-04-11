SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [Staging].[SP_TGCPLUS_Churn_Working_20180309]
as

Begin
/**********************************************************************Assumptions:********************************************************************** 

Initial Free trial period only (Checked with Ujval and this is what we need to do. ignore billing rank > 1 i.e. second free trial etc..)
DS = 0 and Billing Rank = 1 

if Freedays is null then default to 30 days


******************************************************************************************************************************************************/



 IF OBJECT_ID('staging.TGCPlus_Consumption_FreeTrial') IS NOT NULL          
    DROP TABLE staging.TGCPlus_Consumption_FreeTrial          

select a.customerid
	--,a.EntitlementDays
	--,datediff(d,service_period_from,actual_service_period_to) + 1 as Freedays
	,datediff(d,service_period_from,actual_service_period_to) + 1 as EntitlementDays
	,a.DS_Service_period_from
	,a.DS_Service_period_to
	,b.UUID
	,b.TSTAMP
	,b.Vid
	,b.StreamedMins
	,b.plays
	,b.Platform
	,b.MaxVPOS
	,(b.MaxVpos / 60.0) Max_VPOSMins
	,c.course_id as CourseID
	,c.seriestitle as CourseName
	,c.episode_number as LectureNum
	,c.title as LectureName
	,c.genre as Category
	,(c.Runtime / 60.0) as LectureRunMins
	,case when (b.StreamedMins) > (c.Runtime / 60.0) then (c.Runtime / 60.0) else (b.StreamedMins) end as StreamedMinsCapped
	,case when (b.StreamedMins) > (c.Runtime / 60.0) then (c.Runtime / 60.0) else (b.StreamedMins) end as FINALStreamedMins
	,convert(int,0) as FlagCompletedLecture
	,convert(float,0) as LectureCompletedPrcnt
into staging.TGCPlus_Consumption_FreeTrial 
from DataWarehouse.Archive.tgcplus_ds a
left join DataWarehouse.Marketing.TGCplus_VideoEvents_Smry b on a.CustomerID = b.ID
and b.TSTAMP between a.DS_Service_period_from and a.DS_Service_period_to
left join DataWarehouse.Archive.TGCPlus_Film c on b.Vid = c.uuid
Where a.DS = 0
AND a.BillingRank = 1
AND a.billing_cycle_period_type in  ('MONTH','Day')


-- if watched mins is greater than max vpos, then they streamed the same part multiple times and have not watched the complete lecture
	update staging.TGCPlus_Consumption_FreeTrial 
	set FINALStreamedMins = Max_VPOSMins
	where StreamedMinsCapped - Max_VPOSMins > 1

	-- if they watched more than 95% of the course, then flag as completed.
	update staging.TGCPlus_Consumption_FreeTrial 
	set FlagCompletedLecture = case when isnull(FINALStreamedMins,0)*1./nullif(LectureRunMins,0) >= .90  then 1 else 0 end,
		LectureCompletedPrcnt  = isnull(isnull(FINALStreamedMins,0)*1./nullif(LectureRunMins,0),0)

 IF OBJECT_ID('Marketing.TGCPlus_Consumption_FreeTrial') IS NOT NULL          
    DROP TABLE Marketing.TGCPlus_Consumption_FreeTrial  

select * ,getdate() as DMLastupdated
into Datawarehouse.Marketing.TGCPlus_Consumption_FreeTrial
from staging.TGCPlus_Consumption_FreeTrial 



 ----------------------------------------------------------------------------#FreeDays-----------------------------------------------------------------------------------------------------


--drop table #freedays
select CS.Customerid,service_period_from,datediff(d,service_period_from,actual_service_period_to) + 1 as Freedays,
 Case when  datediff(d,service_period_from,actual_service_period_to) + 1  between 1 and 10 then '1-10 Days'
      when  datediff(d,service_period_from,actual_service_period_to) + 1  between 11 and 20 then '11-20 Days'				
	  when  datediff(d,service_period_from,actual_service_period_to) + 1  between 21 and 32 then '21-32 Days'	
	  else  '>32 Days' end as FreedaysBucket
Into #freedays
from DataWarehouse.archive.vw_tgcplus_customersignature CS
left join DataWarehouse.Archive.tgcplus_DS DS
on CS.CustomerID = DS.CustomerID
where CS.IntlSubType   in  ('MONTH','Day')
AND CS.IntlSubPlanName in ('Monthly Subscription','Monthly Subscription Original','Monthly Plan','Montlhy Subscription')
AND DS.DS = 0
AND DS.BillingRank = 1
AND DS.billing_cycle_period_type in  ('MONTH','Day')
Group by CS.Customerid,service_period_from,datediff(d,service_period_from,actual_service_period_to) + 1,
Case when  datediff(d,service_period_from,actual_service_period_to) + 1  between 1 and 10 then '1-10 Days'
	when  datediff(d,service_period_from,actual_service_period_to) + 1  between 11 and 20 then '11-20 Days'				
	when  datediff(d,service_period_from,actual_service_period_to) + 1  between 21 and 32 then '21-32 Days'	
	else  '>32 Days' end

-----------------------------------------------------------------------Sripe-------------------------------------------------------------------------

/****Stripe cardbrand/funding Start****/
select distinct userid_metadata as uuid, CardBrand, CardFunding 
into #Stripe
from (select  mt.userid_metadata, mt.CardBrand, mt.CardFunding, (mt.DMLastUpdated) UpdateDate 
		from archive.Stripe_transactions (nolock) mt
		inner join ( select userid_metadata, max(Created) MaxDate from archive.stripe_transactions (nolock)
					 group by userid_metadata
					  ) t 
		on mt.userid_metadata = t.userid_metadata and mt.created = t.MaxDate --and mt.CardBrand = t.CardBrand and mt.CardFunding = t.CardFunding
		) as CardType
/****Stripe cardbrand/funding END****/	 
	  
 ----------------------------------------------------------------------SailThru----------------------------------------------------------------------
--drop table #sailthruBrowserName
select id,Variable,value , cast(null as int)Customerid, cast(null as varchar(255))uuid
into #sailthruBrowserName
from sailthru..UserProfileVariable
where Variable like '%browser.0.name%'

update a 
set a.Customerid = m.Customerid
, a.uuid = m.UUID
from #sailthruBrowserName a 
join Sailthru.Mapping.Vw_map_ProfileEmailUUID m
on a.id = m.ProfileID

--get Unique values at customerid level
select Customerid, uuid, max(Value)BrowserSignUp 
into #BrowserSignUp
from #sailthruBrowserName
group by  Customerid, uuid



/****SailThru Finish Ratio cat Start****/
 
select 
CustomerID,
isnull(sum(isnull([1],0))/nullif(sum(isnull([p1],0)),0),0) as Day1_FR,isnull(sum(isnull([2],0))/nullif(sum(isnull([p2],0)),0),0) as Day2_FR,
isnull(sum(isnull([3],0))/nullif(sum(isnull([p3],0)),0),0) as Day3_FR,isnull(sum(isnull([4],0))/nullif(sum(isnull([p4],0)),0),0) as Day4_FR,
isnull(sum(isnull([5],0))/nullif(sum(isnull([p5],0)),0),0) as Day5_FR,isnull(sum(isnull([6],0))/nullif(sum(isnull([p6],0)),0),0) as Day6_FR,
isnull(sum(isnull([7],0))/nullif(sum(isnull([p7],0)),0),0) as Day7_FR,isnull(sum(isnull([8],0))/nullif(sum(isnull([p8],0)),0),0) as Day8_FR,
isnull(sum(isnull([9],0))/nullif(sum(isnull([p9],0)),0),0) as Day9_FR,isnull(sum(isnull([10],0))/nullif(sum(isnull([p10],0)),0),0) as Day10_FR,
isnull(sum(isnull([11],0))/nullif(sum(isnull([p11],0)),0),0) as Day11_FR,isnull(sum(isnull([12],0))/nullif(sum(isnull([p12],0)),0),0) as Day12_FR,
isnull(sum(isnull([13],0))/nullif(sum(isnull([p13],0)),0),0) as Day13_FR,isnull(sum(isnull([14],0))/nullif(sum(isnull([p14],0)),0),0) as Day14_FR,
isnull(sum(isnull([15],0))/nullif(sum(isnull([p15],0)),0),0) as Day15_FR,isnull(sum(isnull([16],0))/nullif(sum(isnull([p16],0)),0),0) as Day16_FR,
isnull(sum(isnull([17],0))/nullif(sum(isnull([p17],0)),0),0) as Day17_FR,isnull(sum(isnull([18],0))/nullif(sum(isnull([p18],0)),0),0) as Day18_FR,
isnull(sum(isnull([19],0))/nullif(sum(isnull([p19],0)),0),0) as Day19_FR,isnull(sum(isnull([20],0))/nullif(sum(isnull([p20],0)),0),0) as Day20_FR,
isnull(sum(isnull([21],0))/nullif(sum(isnull([p21],0)),0),0) as Day21_FR,isnull(sum(isnull([22],0))/nullif(sum(isnull([p22],0)),0),0) as Day22_FR,
isnull(sum(isnull([23],0))/nullif(sum(isnull([p23],0)),0),0) as Day23_FR,isnull(sum(isnull([24],0))/nullif(sum(isnull([p24],0)),0),0) as Day24_FR,
isnull(sum(isnull([25],0))/nullif(sum(isnull([p25],0)),0),0) as Day25_FR,isnull(sum(isnull([26],0))/nullif(sum(isnull([p26],0)),0),0) as Day26_FR,
isnull(sum(isnull([27],0))/nullif(sum(isnull([p27],0)),0),0) as Day27_FR,isnull(sum(isnull([28],0))/nullif(sum(isnull([p28],0)),0),0) as Day28_FR,
isnull(sum(isnull([29],0))/nullif(sum(isnull([p29],0)),0),0) as Day29_FR,isnull(sum(isnull([30],0))/nullif(sum(isnull([p30],0)),0),0) as Day30_FR,
isnull(sum([s1]),0) as Day1_FinishedLectures,isnull(sum([s2]),0) as Day2_FinishedLectures,isnull(sum([s3]),0) as Day3_FinishedLectures,isnull(sum([s4]),0) as Day4_FinishedLectures,isnull(sum([s5]),0) as Day5_FinishedLectures,
isnull(sum([s6]),0) as Day6_FinishedLectures,isnull(sum([s7]),0) as Day7_FinishedLectures,isnull(sum([s8]),0) as Day8_FinishedLectures,isnull(sum([s9]),0) as Day9_FinishedLectures,isnull(sum([s10]),0) as Day10_FinishedLectures,
isnull(sum([s11]),0) as Day11_FinishedLectures,isnull(sum([s12]),0) as Day12_FinishedLectures,isnull(sum([s13]),0) as Day13_FinishedLectures,isnull(sum([s14]),0) as Day14_FinishedLectures,isnull(sum([s15]),0) as Day15_FinishedLectures,
isnull(sum([s16]),0) as Day16_FinishedLectures,isnull(sum([s17]),0) as Day17_FinishedLectures,isnull(sum([s18]),0) as Day18_FinishedLectures,isnull(sum([s19]),0) as Day19_FinishedLectures,isnull(sum([s20]),0) as Day20_FinishedLectures,
isnull(sum([s21]),0) as Day21_FinishedLectures,isnull(sum([s22]),0) as Day22_FinishedLectures,isnull(sum([s23]),0) as Day23_FinishedLectures,isnull(sum([s24]),0) as Day24_FinishedLectures,isnull(sum([s25]),0) as Day25_FinishedLectures,
isnull(sum([s26]),0) as Day26_FinishedLectures,isnull(sum([s27]),0) as Day27_FinishedLectures,isnull(sum([s28]),0) as Day28_FinishedLectures,isnull(sum([s29]),0) as Day29_FinishedLectures,
isnull(sum([s30]),0) as Day30_FinishedLectures
Into #FRUserLevel
from
	( 
	select customerid,DS_Service_period_from,Date,Days as trans_type1, 'p' +  cast(Days as varchar) trans_type2, 's' +  cast(Days as varchar) trans_type3,  
	isnull(sum(FSM) over (Partition by  CustomerID order by days),0)as FSM ,
	isnull(sum(LRM) over (Partition by CustomerID order by days),0)as LRM,
	isnull(sum(FCL) over (Partition by CustomerID order by days),0)as FCL
	from 
		   (
					select C1.customerid,C1.DS_Service_period_from,Date,c1.Days,
					sum(FinalStreamedMins) FSM, sum(LectureRunMins) LRM, sum(FlagCompletedLecture) FCL
					from 
					(
						select Customerid,cast(DS_Service_period_from as date)DS_Service_period_from,cast(D.Date as date)Date,Datediff(d,cast(DS_Service_period_from as date),Date) + 1 as Days   
						from Datawarehouse.Marketing.TGCPlus_Consumption_FreeTrial a(nolock) 
						left join datawarehouse.mapping.Date D 
						on cast(D.Date as date) >= cast(DS_Service_period_from as date) and cast(D.Date as date) < dateadd(d,30,cast(DS_Service_period_from as date))
						--where CustomerID = 2166013
						group by Customerid,cast(DS_Service_period_from as date) ,cast(D.Date as date) ,Datediff(d,cast(DS_Service_period_from as date),Date)
						--order by 4
					)C1
					left Join Datawarehouse.Marketing.TGCPlus_Consumption_FreeTrial C2(nolock) 
					on C1.customerid =  C2.customerid and C1.Date = c2.TSTAMP
					group by C1.customerid,C1.DS_Service_period_from,Date,c1.Days
					--order by 3
		   ) C
	) Src

pivot( sum(FSM) for trans_type1 in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30]) ) as p1
pivot( sum(LRM) for trans_type2 in ([p1],[p2],[p3],[p4],[p5],[p6],[p7],[p8],[p9],[p10],[p11],[p12],[p13],[p14],[p15],[p16],[p17],[p18],[p19],[p20],[p21],[p22],[p23],[p24],[p25],[p26],[p27],[p28],[p29],[p30])) as p2
pivot( sum(FCL) for trans_type3 in ([s1],[s2],[s3],[s4],[s5],[s6],[s7],[s8],[s9],[s10],[s11],[s12],[s13],[s14],[s15],[s16],[s17],[s18],[s19],[s20],[s21],[s22],[s23],[s24],[s25],[s26],[s27],[s28],[s29],[s30])) as p3
group by customerid

/****SailThru Finish Ratio cat End****/



/****SailThru Streaming cat Start****/
 
select 
Customerid,
isnull(sum(isnull([Behind The Scenes],0))/nullif(sum(isnull([pBehind The Scenes],0)),0),0) as BehindtheScenes_FR,
isnull(sum(isnull([Bonus Features],0))/nullif(sum(isnull([pBonus Features],0)),0),0) as BonusFeatures_FR,
isnull(sum(isnull([Economics & Finance],0))/nullif(sum(isnull([pEconomics & Finance],0)),0),0) as Economics_FR,
isnull(sum(isnull([Food & Wine],0))/nullif(sum(isnull([pFood & Wine],0)),0),0) as FoodWine_FR,
isnull(sum(isnull([Health, Fitness & Nutrition],0))/nullif(sum(isnull([pHealth, Fitness & Nutrition],0)),0),0) as Health_FR,
isnull(sum(isnull([History],0))/nullif(sum(isnull([pHistory],0)),0),0) as History_FR,
isnull(sum(isnull([Hobby & Leisure],0))/nullif(sum(isnull([pHobby & Leisure],0)),0),0) as Hobby_FR,
isnull(sum(isnull([Literature & Language],0))/nullif(sum(isnull([pLiterature & Language],0)),0),0) as Literature_FR,
isnull(sum(isnull([Mathematics],0))/nullif(sum(isnull([pMathematics],0)),0),0) as Mathematics_FR,
isnull(sum(isnull([Music & Fine Art],0))/nullif(sum(isnull([pMusic & Fine Art],0)),0),0) as Music_FR,
isnull(sum(isnull([Nat Geo Live],0))/nullif(sum(isnull([pNat Geo Live],0)),0),0) as NatGeo_FR,
isnull(sum(isnull([Philosophy, Religion & Intellectual History],0))/nullif(sum(isnull([pPhilosophy, Religion & Intellectual History],0)),0),0) as Phil_FR,
isnull(sum(isnull([Professional],0))/nullif(sum(isnull([pProfessional],0)),0),0) as Professional_FR,
isnull(sum(isnull([Science],0))/nullif(sum(isnull([pScience],0)),0),0) as Science_FR,
isnull(sum(isnull([Trailers],0))/nullif(sum(isnull([pTrailers],0)),0),0) as Trailers_FR,
isnull(sum(isnull([Travel],0))/nullif(sum(isnull([pTravel],0)),0),0) as Travel_FR
into #GenreUserLevel
from
( 
  Select customerid, Category as trans_type1, 'p' + Category as trans_type2, 
  sum(isnull(FinalStreamedMins,0)) FinalStreamedMins,
  sum(isnull(LectureRunMins,0)) LectureRunMins
  from Datawarehouse.Marketing.TGCPlus_Consumption_FreeTrial (nolock)
  group by customerid, category
  ) s
pivot( sum(FinalStreamedMins)for trans_type1 in ([Behind The Scenes],[Bonus Features],[Economics & Finance],[Food & Wine],[Health, Fitness & Nutrition],[History],
[Hobby & Leisure], [Literature & Language], [Mathematics],[Music & Fine Art],[Nat Geo Live],[Philosophy, Religion & Intellectual History],[Professional],[Science],[Trailers],[Travel])) as p1
pivot( sum(LectureRunMins)for trans_type2 in ([pBehind The Scenes],[pBonus Features],[pEconomics & Finance],[pFood & Wine],[pHealth, Fitness & Nutrition],[pHistory],[pHobby & Leisure], 
[pLiterature & Language], [pMathematics],[pMusic & Fine Art],[pNat Geo Live],[pPhilosophy, Religion & Intellectual History],[pProfessional],[pScience],[pTrailers],[pTravel])) as p2
group by customerid

/****SailThru Streaming cat end****/


/****SailThru Last Streaming date Start****/
 
select a.CustomerID, max(b.tstamp) LastStreamedDate_FreeTrialMonth
into #LSD
from archive.Vw_TGCPlus_CustomerSignature (nolock) a 
left join #freedays F on F.CustomerID = a.CustomerID
left join marketing.TGCplus_VideoEvents_Smry (nolock) b 
on a.customerid = b.ID
where datediff(day, a.IntlSubDate, b.tstamp) <= isnull(Freedays,30)
group by a.CustomerID
/****SailThru Last Streaming date End****/



/****SailThruOpens Rate Start****/
select 
CustomerID,
sum([1]) Day1_OpenRate,sum([2]) Day2_OpenRate,sum([3]) Day3_OpenRate,sum([4]) Day4_OpenRate,sum([5]) Day5_OpenRate,
sum([6]) Day6_OpenRate,sum([7]) Day7_OpenRate,sum([8]) Day8_OpenRate,sum([9]) Day9_OpenRate,sum([10]) Day10_OpenRate,
sum([11])Day11_OpenRate,sum([12])Day12_OpenRate,sum([13])Day13_OpenRate,sum([14])Day14_OpenRate,sum([15])Day15_OpenRate,
sum([16]) Day16_OpenRate,sum([17]) Day17_OpenRate,sum([18]) Day18_OpenRate,sum([19]) Day19_OpenRate,sum([20])Day20_OpenRate,
sum([21])Day21_OpenRate,sum([22])Day22_OpenRate,sum([23])Day23_OpenRate,sum([24])Day24_OpenRate,sum([25])Day25_OpenRate,
sum([26])Day26_OpenRate,sum([27])Day27_OpenRate,sum([28])Day28_OpenRate,sum([29])Day29_OpenRate,sum([30])Day30_OpenRate
into #SailThruOpens
from
(
  select 
                     CustomerID,IntlSubDate,days,
                     isnull(sum(sends) over (Partition by  CustomerID order by days),0) RunningSends,
                     isnull(sum(Opened) over (Partition by  CustomerID order by days),0) RunningOpens,
                     isnull((sum(Opened) over (Partition by  CustomerID order by days)) *1. /(sum(sends) over (Partition by  CustomerID order by days)),0) as OpenRate
                     from
                     (
                                  select C.CustomerID, IntlSubDate,C.days,
                                  Sum(case when B.Customerid is not null then 1 else null end) as sends,
                                  sum(case when NumberofOpens >=1 then 1 else null end) as Opened,
                                  sum(NumberofOpens) as DupesOpened
                                  from  (select  Customerid,IntlSubDate,d.Date  , Datediff(d,IntlSubDate,Date)+ 1 As Days
                                                       from archive.vw_tgcplus_customersignature (nolock) b 
                                                       join datawarehouse.mapping.Date D
                                                       --on cast(D.Date as date) >= IntlSubDate and cast(D.Date as date) <= dateadd(d,30,IntlSubDate)
													   on Cast(D.Date AS date) >= Cast(IntlSubDate AS date) AND Cast(D.Date AS date) < Dateadd(d,30,Cast(IntlSubDate AS date))
                                                        --where CustomerID = 1156199
                                                )C
                                  left join [Archive].[Vw_SailThruProfileMessages] (nolock) b 
                                  on c.CustomerID = b.CustomerID and c.date = cast(b.Send_Datetime as date)
                                  group by C.CustomerID,IntlSubDate,days
                     )a
) source
Pivot(Sum(OpenRate) for [Days] in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30])) as pvt
group by CustomerID ,IntlSubDate
/****SailThruOpens Rate End****/


/****SailThruClicks Rate Start****/
select 
CustomerID,
sum([1]) Day1_ClickRate,sum([2]) Day2_ClickRate,sum([3]) Day3_ClickRate,sum([4]) Day4_ClickRate,sum([5]) Day5_ClickRate,
sum([6]) Day6_ClickRate,sum([7]) Day7_ClickRate,sum([8]) Day8_ClickRate,sum([9]) Day9_ClickRate,sum([10]) Day10_ClickRate,
sum([11]) Day11_ClickRate,sum([12]) Day12_ClickRate,sum([13]) Day13_ClickRate,sum([14]) Day14_ClickRate,sum([15]) Day15_ClickRate,
sum([16]) Day16_ClickRate,sum([17]) Day17_ClickRate,sum([18]) Day18_ClickRate,sum([19]) Day19_ClickRate,sum([20])Day20_ClickRate,
sum([21])Day21_ClickRate,sum([22])Day22_ClickRate,sum([23])Day23_ClickRate,sum([24])Day24_ClickRate,sum([25])Day25_ClickRate,
sum([26])Day26_ClickRate,sum([27])Day27_ClickRate,sum([28])Day28_ClickRate,sum([29])Day29_ClickRate,sum([30])Day30_ClickRate
into #SailThruClicks
from
(
  select 
                     CustomerID,IntlSubDate,days,
                     isnull(sum(sends) over (Partition by  CustomerID order by days),0) RunningSends,
                     isnull(sum(clicks) over (Partition by  CustomerID order by days),0) RunningClicks,
                     isnull((sum(clicks) over (Partition by  CustomerID order by days)) *1. /(sum(sends) over (Partition by  CustomerID order by days)),0) as ClickRate
                     from
                     (
                                  select C.CustomerID, IntlSubDate,C.days,
                                  Sum(case when B.Customerid is not null then 1 else null end) as sends,
                                  sum(case when NumberofClicks >=1 then 1 else null end) as clicks,
                                  sum(NumberofClicks) as DupesClicked
                                  from  (select  Customerid,IntlSubDate,d.Date  , Datediff(d,IntlSubDate,Date) + 1 As Days
                                                       from archive.vw_tgcplus_customersignature (nolock) b 
                                                       join datawarehouse.mapping.Date D
                                                       --on cast(D.Date as date) >= IntlSubDate and cast(D.Date as date) <= dateadd(d,30,IntlSubDate)
													   on Cast(D.Date AS date) >= Cast(IntlSubDate AS date) AND Cast(D.Date AS date) < Dateadd(d,30,Cast(IntlSubDate AS date))
													   --where CustomerID = 1156199
                                                )C
                                  left join [Archive].[Vw_SailThruProfileMessages] (nolock) b 
                                  on c.CustomerID = b.CustomerID and c.date = cast(b.Send_Datetime as date)
                                  group by C.CustomerID,IntlSubDate,days
                     )a

) source
Pivot(Sum(ClickRate) for [Days] in ([0],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30])) as pvt
group by CustomerID ,IntlSubDate
/****SailThruClicks Rate End****/

 
/****SailThruSends Start****/	
select 
CustomerID,
sum([1]) Day1_Sends,sum([2]) Day2_Sends,sum([3]) Day3_Sends,sum([4]) Day4_Sends,sum([5]) Day5_Sends,sum([6]) Day6_Sends,sum([7]) Day7_Sends,sum([8]) Day8_Sends,sum([9]) Day9_Sends,sum([10]) Day10_Sends,
sum([11])Day11_Sends,sum([12])Day12_Sends,sum([13])Day13_Sends,sum([14])Day14_Sends,sum([15])Day15_Sends,sum([16])Day16_Sends,sum([17])Day17_Sends,sum([18])Day18_Sends,sum([19])Day19_Sends,sum([20])Day20_Sends,
sum([21])Day21_Sends,sum([22])Day22_Sends,sum([23])Day23_Sends,sum([24])Day24_Sends,sum([25])Day25_Sends,sum([26])Day26_Sends,sum([27])Day27_Sends,sum([28])Day28_Sends,sum([29])Day29_Sends,sum([30])Day30_Sends
into #SailThruSends
from
(
  select 
                     CustomerID,IntlSubDate,days,
                     isnull(sum(sends) over (Partition by  CustomerID order by days),0) RunningSends,
                     isnull(sum(DupesOpened) over (Partition by  CustomerID order by days),0) RunningOpens,
                     isnull((sum(DupesOpened) over (Partition by  CustomerID order by days)) *1. /(sum(sends) over (Partition by  CustomerID order by days)),0) as OpenRate
                     from
                     (
                                  select C.CustomerID, IntlSubDate,C.days,
                                  Sum(case when B.Customerid is not null then 1 else null end) as sends,
                                  sum(case when NumberofOpens >=1 then 1 else null end) as Opened,
                                  sum(NumberofOpens) as DupesOpened
                                  from  (select  Customerid,IntlSubDate,d.Date  , Datediff(d,IntlSubDate,Date) + 1 as Days
                                                       from archive.vw_tgcplus_customersignature (nolock) b 
                                                       join datawarehouse.mapping.Date D
                                                       --on cast(D.Date as date) >= IntlSubDate and cast(D.Date as date) <= dateadd(d,30,IntlSubDate)
													   on Cast(D.Date AS date) >= Cast(IntlSubDate AS date) AND Cast(D.Date AS date) < Dateadd(d,30,Cast(IntlSubDate AS date))
                                                      --where CustomerID = 1156199
                                                )C
                                  left join [Archive].[Vw_SailThruProfileMessages] (nolock) b 
                                  on c.CustomerID = b.CustomerID and c.date = cast(b.Send_Datetime as date)
                                  group by C.CustomerID,IntlSubDate,days
                     )a
) source
Pivot(Sum(RunningSends) for [Days] in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30])) as pvt
group by CustomerID ,IntlSubDate
/****SailThruSends End****/	


/****SailThru Opens SailThruOpens1 Start****/	
select 
CustomerID,sum([1]) Day1_Opens,sum([2]) Day2_Opens,sum([3]) Day3_Opens,sum([4]) Day4_Opens,sum([5]) Day5_Opens,sum([6]) Day6_Opens,sum([7]) Day7_Opens,sum([8]) Day8_Opens,sum([9]) Day9_Opens,sum([10]) Day10_Opens,
sum([11]) Day11_Opens,sum([12]) Day12_Opens,sum([13]) Day13_Opens,sum([14]) Day14_Opens,sum([15]) Day15_Opens,sum([16]) Day16_Opens,sum([17]) Day17_Opens,sum([18]) Day18_Opens,sum([19]) Day19_Opens,sum([20])Day20_Opens,
sum([21])Day21_Opens,sum([22])Day22_Opens,sum([23])Day23_Opens,sum([24])Day24_Opens,sum([25])Day25_Opens,sum([26])Day26_Opens,sum([27])Day27_Opens,sum([28])Day28_Opens,sum([29])Day29_Opens,sum([30])Day30_Opens
Into #SailThruOpens1
from
(
  select 
                     CustomerID,IntlSubDate,days,
                     isnull(sum(sends) over (Partition by  CustomerID order by days),0) RunningSends,
                     isnull(sum(Opened) over (Partition by  CustomerID order by days),0) RunningOpens,
                     isnull((sum(Opened) over (Partition by  CustomerID order by days)) *1. /(sum(sends) over (Partition by  CustomerID order by days)),0) as OpenRate,
					 isnull(sum(Clicks) over (Partition by CustomerID order by days),0) RunningClicks
                     from
                     (
                                  select C.CustomerID, IntlSubDate,C.days,
                                  Sum(case when B.Customerid is not null then 1 else null end) as sends,
                                  sum(case when NumberofOpens >=1 then 1 else null end) as Opened,
                                  sum(NumberofOpens) as DupesOpened,
								  sum(case when NumberofClicks >=1 then 1 else null end) as Clicks,
								  sum(NumberofClicks) as DupesClicked
                                  from  (select  Customerid,IntlSubDate,d.Date  , Datediff(d,IntlSubDate,Date)+ 1 as Days
                                                       from archive.vw_tgcplus_customersignature (nolock) b 
                                                       join datawarehouse.mapping.Date D
                                                       --on cast(D.Date as date) >= IntlSubDate and cast(D.Date as date) <= dateadd(d,30,IntlSubDate)
													   on Cast(D.Date AS date) >= Cast(IntlSubDate AS date) AND Cast(D.Date AS date) < Dateadd(d,30,Cast(IntlSubDate AS date))
                                                      --where CustomerID = 1156199
                                                )C
                                  left join [Archive].[Vw_SailThruProfileMessages] (nolock) b 
                                  on c.CustomerID = b.CustomerID and c.date = cast(b.Send_Datetime as date)
                                  group by C.CustomerID,IntlSubDate,days
								  --order by 3
                     )a
) source
Pivot(Sum(RunningOpens) for [Days] in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30])) as pvt
group by CustomerID ,IntlSubDate
/****SailThru Opens SailThruOpens1 End****/	

 
/****SailThruRawOpens Start****/	
select 
CustomerID,
sum([1]) Day1_RawOpens,sum([2]) Day2_RawOpens,sum([3]) Day3_RawOpens,sum([4]) Day4_RawOpens,sum([5]) Day5_RawOpens,
sum([6]) Day6_RawOpens,sum([7]) Day7_RawOpens,sum([8]) Day8_RawOpens,sum([9]) Day9_RawOpens,sum([10]) Day10_RawOpens,
sum([11])Day11_RawOpens,sum([12])Day12_RawOpens,sum([13])Day13_RawOpens,sum([14])Day14_RawOpens,sum([15])Day15_RawOpens,
sum([16]) Day16_RawOpens,sum([17]) Day17_RawOpens,sum([18]) Day18_RawOpens,sum([19]) Day19_RawOpens,sum([20])Day20_RawOpens,
sum([21])Day21_RawOpens,sum([22])Day22_RawOpens,sum([23])Day23_RawOpens,sum([24])Day24_RawOpens,sum([25])Day25_RawOpens,
sum([26])Day26_RawOpens,sum([27])Day27_RawOpens,sum([28])Day28_RawOpens,sum([29])Day29_RawOpens,sum([30])Day30_RawOpens
into #SailThruRawOpens
from
(

  select 
        CustomerID,IntlSubDate,days,
        isnull(sum(sends) over (Partition by  CustomerID order by days),0) RunningSends,
        isnull(sum(DupesOpened) over (Partition by  CustomerID order by days),0) RunningOpens,
        isnull((sum(Opened) over (Partition by  CustomerID order by days)) *1. /(sum(sends) over (Partition by  CustomerID order by days)),0) as OpenRate
        from
        (
		select C.CustomerID, IntlSubDate,C.days,
		Sum(case when B.Customerid is not null then 1 else null end) as sends,
		sum(case when NumberofOpens >=1 then 1 else null end) as Opened,
		sum(NumberofOpens) as DupesOpened
		from  (select  Customerid,IntlSubDate,d.Date  , Datediff(d,IntlSubDate,Date)+ 1 as Days
							from archive.vw_tgcplus_customersignature (nolock) b 
							join datawarehouse.mapping.Date D
							--on cast(D.Date as date) >= IntlSubDate and cast(D.Date as date) <= dateadd(d,30,IntlSubDate)
							on Cast(D.Date AS date) >= Cast(IntlSubDate AS date) AND Cast(D.Date AS date) < Dateadd(d,30,Cast(IntlSubDate AS date))
							--where CustomerID = 1156199
					)C
		left join [Archive].[Vw_SailThruProfileMessages] (nolock) b 
		on c.CustomerID = b.CustomerID and c.date = cast(b.Send_Datetime as date)
		group by C.CustomerID,IntlSubDate,days
		--order by 3
        )a
) source
Pivot (Sum(RunningOpens) for [Days] in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30])) as pvt
group by CustomerID ,IntlSubDate
/****SailThruRawOpens End****/	

/****SailThruOptOut Start****/	
SELECT CustomerID, 
Optout_time,sum([1])Day1,sum([2])Day2,sum([3])Day3,sum([4])Day4,sum([5])Day5,sum([6])Day6,sum([7])Day7,sum([8])Day8,sum([9])Day9,sum([10])Day10,
sum([11])Day11,sum([12])Day12,sum([13])Day13,sum([14])Day14,sum([15])Day15,sum([16])Day16,sum([17])Day17,sum([18])Day18,sum([19])Day19,sum([20])Day20,
sum([21])Day21,sum([22])Day22,sum([23])Day23,sum([24])Day24,sum([25])Day25,sum([26])Day26,sum([27])Day27,sum([28])Day28,sum([29])Day29,sum([30])Day30
into #SailThruOptOut
FROM
		(SELECT A.*,
		b.Optout_time,
		CASE
		WHEN datediff(DAY,cast(b.Optout_time AS date), a.Date)>=0 THEN 1
		ELSE 0
		END AS FlagOptout
		FROM	
				(
				SELECT a.CustomerID,
					a.uuid,
					D.Date,
					a.IntlSubDate,
					Datediff(d,a.IntlSubDate, D.Date) + 1 AS Days
				FROM DataWarehouse.Archive.vw_tgcplus_customersignature (nolock) a
				LEFT JOIN DataWarehouse.Mapping.Date D ON Cast(D.Date AS date) >= Cast(a.IntlSubDate AS date)
				AND Cast(D.Date AS date) < Dateadd(d,30,Cast(a.IntlSubDate AS date))
				--WHERE a.CustomerID = 1235162 
				)a
		LEFT JOIN   (SELECT uuid,
		Optout_type,
		Optout_reason,
		Optout_time
		FROM sailthru.[Mapping].[Vw_map_ProfileEmailUUID] (nolock) a
		LEFT JOIN sailthru..UserProfileStatic (nolock) b 
		ON a.ProfileID = b.id ) b ON a.uuid = b.uuid
)SOURCE 
Pivot (Sum(FlagOptout) FOR [Days] IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30]))AS pvt
GROUP BY CustomerID,uuid,IntlSubDate,Optout_time
/****SailThruOptOut End****/

--------------------------------------------------------Omniture----------------------------------------------------------------------------


/****Omni AdobePageActivity Start****/
Select
CustomerID,
sum(case when CustomLink not in ('Account Page: Activate Device', 'Account Page: Change Email', 'Account Page: Change personal info', 'Account Page: Email Preferences','Account Page: Manage Devices') 
then AllVisits else null end) as AdobePageActivity_AccountPage,
Sum(Case when CustomLink like '%Plus FAQ%' then  AllVisits else null end) as AdobePageActivity_FAQ,
Sum(Case when CustomLink not in ('Contact Us Form Submit','Plus Course Page Facebook Click','Plus Course Page Guidebook Click','Plus Course Page Professor Info Click','Plus Course Page Read Reviews Click','Plus Course Page Reviews Submit','Plus Course Page Twitter Click') 
then  AllVisits else null end) as AdobePageActivity_Social,
Sum(Case when CustomLink not in ('Plus - Begin Registration','Plus - Plan Selected - MONTH','Plus - Plan Selected - undefined','Plus - Plan Selected - WEEK','Plus - Plan Selected - YEAR','Plus - Registration Complete','Plus- Offer Code Applied') 
then  AllVisits else null end) as AdobePageActivity_Registration,
Sum(Case when CustomLink not in ('Plus Cancel Subscription - No','Plus Cancel Subscription - Opened Modal','Plus Cancel Subscription - Yes') 
then  AllVisits else null end) as AdobePageActivity_Cancel
into #AdobePageActivity
from
(
select 
a.MarketingCloudVisitorID, a.TGCPlusUserID as uuid,  
b.IntlSubDate, b.CustomerID, 
c.VisitDate, c.CustomLink, c.AllVisits
from archive.omni_tgcplus_mcid_uuid_mapping (nolock) a
	left join archive.vw_tgcplus_customersignature (nolock) b on a.TGCPlusUserID = b.uuid
	left join #freedays f on f.CustomerID = b.CustomerID
	left join
		(
		select cast(date as date) VisitDate, MarketingCloudVisitorID, CustomLink, sum(cast(AllVisits as bigint)) AllVisits
		from archive.omni_tgcplus_customlinks (nolock)
		group by cast(date as date), MarketingCloudVisitorID, CustomLink
		) as c on a.MarketingCloudVisitorID = c.MarketingCloudVisitorID
where a.TGCPlusUserID not in ('')  
and datediff(d, b.IntlSubDate, c.VisitDate)>=0 
and datediff(d, b.IntlSubDate, c.VisitDate)<=coalesce(f.freedays,30) --Freedays if null then default to 30 days
and a.MarketingCloudVisitorID not in ('00000000000000000000000000000000000000')
and b.IntlSubType = 'MONTH' 
) as agg
--where CustomerID = 3713122
group by CustomerID

/****Omni AdobePageActivity End****/

-------------------------------------------------------------TGC Orders------------------------------------------------------------------


/****TGC Sales Pre Start****/
		Select CustomerID, sum(FinalSales) as PrePlusFinalSales, sum(Orders) as PrePlusOrders
		Into #TGCPre
		from 	(select a.CustomerID, a.IntlSubDate, a.TGCCustomerID,b.FinalSales,b.Orders
				from archive.vw_tgcplus_customersignature (nolock) a
				left join (	select 	DM.CustomerID,convert(date, dateOrdered) as OrderDate,sum(FinalSales) as FinalSales,count(OrderID) as Orders
							from marketing.DMPurchaseOrders (nolock) DM
							group by CustomerID, convert(date, dateOrdered)
						) b 
				on a.TGCCustomerID = b.CustomerID
			where a.IntlSubDate > b.OrderDate
				) Pre
		group by CustomerID

/****TGC Sales Pre End****/




/****TGC Sales Post Start****/
Select CustomerID, sum(FinalSales) as PostPlusFinalSales, sum(Orders) as PostPlusOrders
into #TGCPost
from   ( select a.CustomerID, a.IntlSubDate, a.TGCCustomerID,b.FinalSales,b.Orders
		from archive.vw_tgcplus_customersignature (nolock) a
		left join ( select DM.CustomerID,convert(date, dateOrdered) as OrderDate,sum(FinalSales) as FinalSales,count(OrderID) as Orders
					from marketing.DMPurchaseOrders (nolock) DM
					group by CustomerID, convert(date, dateOrdered)
					) b 
		on a.TGCCustomerID = b.CustomerID
		where a.IntlSubDate <= b.OrderDate
		) Post
group by CustomerID
/****TGC Sales Post End****/

-----------------------------------------------------------TGCPlus Streaming--------------------------------------------------------------

/****Complete Streaming info Start****/
	select 
	a.CustomerID, 
	sum(b.plays) as plays,
	sum(b.StreamedMins) as StreamedMinutes,
	count(distinct PrimaryWebCategory) as Categories, 
	count(distinct LectureTitle) as Lectures, 
	count(distinct CourseName) as Courses, 
	count(distinct genre) as Genres
into #CompleteStreaming
	from Datawarehouse.archive.vw_tgcplus_customersignature (nolock) a
		LEFT JOIN Archive.VW_TGCplus_VideoEvents_Smry (nolock) b on a.CustomerID = b.id 
	group by a.CustomerID

/****Complete Streaming info End****/



/****First Streaming info Start****/
select distinct CustomerID, FirstStreamDate, FirstPlatform, FirstBrowser, FirstCourse, FirstLecture, FirstLectureNumber, FirstCategory, FirstGenre, FirstFilmType
into #FirstStreaming
from
(
	select 
	a.CustomerID, convert(date, b.TSTAMP) as FirstStreamDate, b.platform as FirstPlatform,datawarehouse.Staging.RemoveDigits(b.useragent) as FirstBrowser,b.CourseName as FirstCourse, 
	b.PrimaryWebCategory as FirstCategory, b.LectureTitle as FirstLecture, b.episodenumber as FirstLectureNumber, b.genre as FirstGenre, b.FilmType as FirstFilmType
	from Datawarehouse.archive.vw_tgcplus_customersignature (nolock)  a
			LEFT JOIN #freedays f on f.CustomerID = a.CustomerID
			LEFT JOIN Archive.Vw_TGCplus_VideoEvents_Smry (nolock) b on a.CustomerID = b.id 
	where SeqNum = 1 
	and datediff(day, a.IntlSubDate, convert(date, b.TSTAMP))<= coalesce(f.freedays,30)
) as agg
 
/****First Streaming info End****/



/****SevenDaysStreaming Start****/
	select  
	b.CustomerID, 
	count(distinct PrimaryWebCategory) Categories_7days,
	count(distinct courseid) Courses_7days,
	count(distinct lecturetitle) Lectures_7days,
	sum(a.StreamedMins) StreamedMins_7days
Into #SevenDays
	from Archive.VW_TGCplus_VideoEvents_Smry (nolock) a
		left join archive.vw_tgcplus_customersignature (nolock) b 
		on a.id = b.CustomerID
	where datediff(day, b.IntlSubDate, a.tstamp) <= 7 
	group by b.CustomerID

/****SevenDaysStreaming End****/



/****FourteenDaysStreaming Start****/
	select  
	b.CustomerID, 
	count(distinct PrimaryWebCategory) Categories_14days,
	count(distinct courseid) Courses_14days,
	count(distinct lecturetitle) Lectures_14days,
	sum(StreamedMins) StreamedMins_14days
into #FourteenDays
	from Archive.VW_TGCplus_VideoEvents_Smry (nolock) a
			left join archive.vw_tgcplus_customersignature (nolock) b 
			on a.id = b.CustomerID
		where datediff(day, b.IntlSubDate, a.tstamp) <= 14 
		group by b.CustomerID

/****FourteenDaysStreaming End****/


/****ThirtyDaysStreaming Start****/
select  
	b.CustomerID, 
	count(distinct PrimaryWebCategory) Categories_30days,
	count(distinct courseid) Courses_30days,
	count(distinct lecturetitle) Lectures_30days,
	sum(StreamedMins) StreamedMins_30days
into #ThirtyDays
	from Archive.VW_TGCplus_VideoEvents_Smry (nolock) a
		left join archive.vw_tgcplus_customersignature (nolock) b 
		on a.id = b.CustomerID
	where datediff(day, b.IntlSubDate, a.tstamp) <= 30
	--and b.CustomerID = 1393319
	group by b.CustomerID

/****ThirtyDaysStreaming End****/


/****DaybyDay_Consumption Start****/
select Customerid,Sum( [1])Day1,Sum([2])Day2,Sum([3])Day3,Sum([4])Day4,Sum([5])Day5,Sum([6])Day6,Sum([7])Day7,Sum([8])Day8,Sum([9])Day9,Sum([10])Day10
,Sum([11])Day11,Sum([12])Day12,Sum([13])Day13,Sum([14])Day14,Sum([15])Day15,Sum([16])Day16,Sum([17])Day17,Sum([18])Day18,Sum([19])Day19,Sum([20])Day20
,Sum([21])Day21,Sum([22])Day22,Sum([23])Day23,Sum([24])Day24,Sum([25])Day25,Sum([26])Day26,Sum([27])Day27,Sum([28])Day28,Sum([29])Day29,Sum([30])Day30
,Sum([31])Day31
into #DaybyDay_Consumption
from
(
		select 
		CustomerID, 
		days,
		sum(Streamedmins) over (Partition by CustomerID order by days) as RunningTotal
				 
		from 
		(		select Customerid,Days,Sum(Streamedmins)Streamedmins
					from ( 
							SELECT a.CustomerID,a.uuid,D.Date,a.IntlSubDate,Datediff(d,a.IntlSubDate, D.Date) + 1 AS Days
							FROM DataWarehouse.Archive.vw_tgcplus_customersignature (nolock) a
							LEFT JOIN DataWarehouse.Mapping.Date D ON Cast(D.Date AS date) >= Cast(a.IntlSubDate AS date)
							AND Cast(D.Date AS date) < Dateadd(d,31,Cast(a.IntlSubDate AS date))
							--WHERE a.CustomerID = 1393319
						)a
				Left Join Archive.Vw_TGCplus_VideoEvents_Smry v
				on v.id = a.CustomerID and v.tstamp  = a.Date
				group by Customerid,Days  
		)as Streamedmins
		group by Customerid, days, Streamedmins
) as source
Pivot(Sum(RunningTotal) for [Days] in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31])) as pvt
group by Customerid
/****DaybyDay_Consumption END****/



/****DaybyDayGenres Start****/
select Customerid,Sum( [1]) Day1Genres,Sum([2])Day2Genres,Sum([3])Day3Genres,Sum([4])Day4Genres,Sum([5])Day5Genres,Sum([6])Day6Genres,Sum([7])Day7Genres,Sum([8])Day8Genres,Sum([9])Day9Genres,Sum([10])Day10Genres
,Sum([11])Day11Genres,Sum([12])Day12Genres,Sum([13])Day13Genres,Sum([14])Day14Genres,Sum([15])Day15Genres,Sum([16])Day16Genres,Sum([17])Day17Genres,Sum([18])Day18Genres,Sum([19])Day19Genres,Sum([20])Day20Genres
,Sum([21])Day21Genres,Sum([22])Day22Genres,Sum([23])Day23Genres,Sum([24])Day24Genres,Sum([25])Day25Genres,Sum([26])Day26Genres,Sum([27])Day27Genres,Sum([28])Day28Genres,Sum([29])Day29Genres, Sum([30])Day30Genres
,Sum([31])Day31Genres
into #DaybyDayGenres
from
(
select 
CustomerID, 
sum(Genres) over (Partition by CustomerID order by days) as RunningTotal,
days as StreamingDays
from 
(
	select Customerid,Days, Count(distinct genre)Genres
	from ( 
			SELECT a.CustomerID,a.uuid,D.Date,a.IntlSubDate,Datediff(d,a.IntlSubDate, D.Date) + 1 AS Days
			FROM DataWarehouse.Archive.vw_tgcplus_customersignature (nolock) a
			LEFT JOIN DataWarehouse.Mapping.Date D ON Cast(D.Date AS date) >= Cast(a.IntlSubDate AS date)
			AND Cast(D.Date AS date) < Dateadd(d,31,Cast(a.IntlSubDate AS date))
			--WHERE a.CustomerID = 1393319
	)a
	Left Join Archive.Vw_TGCplus_VideoEvents_Smry v
	on v.id = a.CustomerID and v.tstamp  = a.Date
	group by Customerid,Days
) as Genres
group by Customerid, days, Genres
) as source
Pivot(Sum(RunningTotal) for [StreamingDays] in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31])) as pvt
group by CustomerID
/****DaybyDayGenres END****/





/****DaybyDayLectures Start****/
select CustomerID,Sum( [1]) Day1Lectures,Sum([2])Day2Lectures,Sum([3])Day3Lectures,Sum([4])Day4Lectures,Sum([5])Day5Lectures,Sum([6])Day6Lectures,Sum([7])Day7Lectures,Sum([8])Day8Lectures,Sum([9])Day9Lectures,Sum([10])Day10Lectures
,Sum([11])Day11Lectures,Sum([12])Day12Lectures,Sum([13])Day13Lectures,Sum([14])Day14Lectures,Sum([15])Day15Lectures,Sum([16])Day16Lectures,Sum([17])Day17Lectures,Sum([18])Day18Lectures,Sum([19])Day19Lectures,Sum([20])Day20Lectures
,Sum([21])Day21Lectures,Sum([22])Day22Lectures,Sum([23])Day23Lectures,Sum([24])Day24Lectures,Sum([25])Day25Lectures,Sum([26])Day26Lectures,Sum([27])Day27Lectures,Sum([28])Day28Lectures,Sum([29])Day29Lectures, Sum([30])Day30Lectures
,Sum([31])Day31Lectures
into #DaybyDayLectures
from
(
select 
CustomerID, 
sum(Lectures) over (Partition by CustomerID order by days) as RunningTotal,
days as StreamingDays
from 
(
	select Customerid,Days, Count(distinct LectureTitle)Lectures
	from ( 
			SELECT a.CustomerID,a.uuid,D.Date,a.IntlSubDate,Datediff(d,a.IntlSubDate, D.Date) + 1 AS Days
			FROM DataWarehouse.Archive.vw_tgcplus_customersignature (nolock) a
			LEFT JOIN DataWarehouse.Mapping.Date D ON Cast(D.Date AS date) >= Cast(a.IntlSubDate AS date)
			AND Cast(D.Date AS date) < Dateadd(d,30,Cast(a.IntlSubDate AS date))
			--WHERE a.CustomerID = 1393319
	)a
	Left Join Archive.Vw_TGCplus_VideoEvents_Smry v
	on v.id = a.CustomerID and v.tstamp  = a.Date
	group by Customerid,Days
) as Lectures
group by Customerid, days, Lectures
) as source
Pivot(Sum(RunningTotal) for [StreamingDays] in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31])) as pvt
group by CustomerID
/****DaybyDayLectures END****/



------------------------------------------------------------------------------------------------------------------------------------------


select  
a.CustomerID, RIGHT(EmailAddress, LEN(EmailAddress) - CHARINDEX('@', EmailAddress)) Domain, a.DSMonthCancelled_new, country, 
case
	/*
	when IntlSubType = 'MONTH' and SubType = 'MONTH' and CustStatusFlag = -1 and IntlSubPlanName = 'Monthly Subscription - 14 Day Free Trial' and DSDayCancelled<=14 then 'Free Month Cancel'
	when IntlSubType = 'MONTH' and SubType = 'MONTH' and CustStatusFlag = 1 and IntlSubPlanName = 'Monthly Subscription - 14 Day Free Trial' and datediff(d, IntlSubDate, GETDATE()-1)<=14 THEN 'Current Free Trial'
	when IntlSubType = 'MONTH' and SubType = 'MONTH' and CustStatusFlag = 1 and datediff(d, IntlSubDate, GETDATE()-1)<=30 THEN 'Current Free Trial'
	when IntlSubType = 'MONTH' AND SubType = 'MONTH' AND CustStatusFlag = -1 and DSMonthCancelled_New = 0 then 'Free Month Cancel'
	when IntlSubType = 'MONTH' AND SubType = 'MONTH' AND CustStatusFlag = -1 and DSMonthCancelled_New > 0 then 'Paid Month Cancel'
	*/
	WHEN IntlSubType = 'MONTH' AND SubType = 'MONTH' AND CustStatusFlag = 1 
	AND datediff(d, IntlSubDate, GETDATE()-1)<=Freedays	and (LastPaidDate is null OR LastPaidDate < IntlSubDate)		THEN 'Free Trial'

    WHEN IntlSubType = 'MONTH' AND SubType = 'MONTH' AND CustStatusFlag = 1	 
	And (LastPaidDate is null or LastPaidDate< IntlSubDate)																THEN 'Free Trial Completed Not Paid'	

	WHEN IntlSubType = 'MONTH' AND SubType = 'MONTH' AND CustStatusFlag = -1 
	AND LastPaidDate  is null																							THEN 'Free Trial Cancel'

	WHEN IntlSubType = 'MONTH' AND SubType = 'MONTH' AND CustStatusFlag = -1 
	AND (LastPaidDate > service_period_from	or DSMonthCancelled_New >= 0 )												THEN 'Paid Month Cancel'

    when IntlSubType = 'MONTH' AND SubType = 'MONTH' AND CustStatusFlag = 1 then 'Active'
    when IntlSubType = 'MONTH' AND SubType = 'MONTH' AND CustStatusFlag = 0 then 'Suspended'      --- This is similar to the Paid Month Cancel
	when IntlSubType = 'MONTH' and SubType = 'YEAR' and CustStatusFlag = 1 then 'Active'
    when IntlSubType = 'MONTH'  and SubType = 'YEAR' and CustStatusFlag = 0 then 'Active'
    when IntlSubType = 'MONTH' and SubType = 'YEAR' and CustStatusFlag = -1 then 'Paid Month Cancel'
	when IntlSubType = 'YEAR' and SubType = 'YEAR' and CustStatusFlag = 1 then 'Annual'
    when IntlSubType = 'YEAR' and SubType = 'YEAR' and CustStatusFlag = 0 then 'Suspended'
    when IntlSubType = 'YEAR' and SubType = 'YEAR' and CustStatusFlag = -1 then 'Paid Month Cancel' 
	else 'Other' end as PaidType,
case	
	when TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerType,
TGCCustSegmentFnl,
a.Gender, Age, HouseHoldIncomeBin, EducationBin,
a.city, a.State, 
IntlCampaignName,
IntlMD_Channel,
IntlMD_PromotionType,
IntlSubDate,
IntlSubPaymentHandler, 
IntlPaidDate, isnull(IntlPaidAmt,0) as IntlPaidAmt, LastPaidDate, isnull(LTDPaidAmt,0) LTDPaidAmt, isnull(LastPaidAmt,0) LastPaidAmt,
DSDayCancelled, 
b.registered_via_platform, 
--BrowserDeviceAgg.FirstDeviceCategory, 
BrowserDeviceAgg.BrowserSignUp, 
FirstStreaming.FirstStreamDate, 
datediff(d, IntlSubDate, FirstStreaming.FirstStreamDate) as Days_Join_Stream, 
FirstStreaming.FirstPlatform, FirstStreaming.FirstBrowser, FirstStreaming.FirstCourse, FirstStreaming.FirstLecture, FirstStreaming.FirstLectureNumber, FirstStreaming.FirstGenre, FirstStreaming.FirstFilmType,
HouseHoldIncome.HouseholdIncome_Median, HouseholdIncome.ZipPopulation,
isnull(SevenDays.Categories_7Days,0) Categories_7days, isnull(SevenDays.Courses_7Days,0) Courses_7days, isnull(SevenDays.Lectures_7days,0) Lectures_7days, isnull(SevenDays.StreamedMins_7days,0) StreamedMins_7days,
isnull(FourteenDays.Categories_14days,0) Categories_14days, isnull(FourteenDays.Courses_14days,0) Courses_14days, isnull(FourteenDays.Lectures_14days,0) Lectures_14days, isnull(FourteenDays.StreamedMins_14days,0) StreamedMins_14days,
isnull(ThirtyDays.Categories_30days,0) Categories_30days, isnull(ThirtyDays.Courses_30days,0) Courses_30days, isnull(ThirtyDays.Lectures_30days,0) Lectures_30days, isnull(ThirtyDays.StreamedMins_30days,0) StreamedMins_30days,
Stripe.CardBrand, Stripe.CardFunding,
isnull(DaybyDay_Consumption.Day1,0) Day1Consumption,isnull(DaybyDay_Consumption.Day2,0) Day2Consumption,isnull(DaybyDay_Consumption.Day3,0) Day3Consumption,isnull(DaybyDay_Consumption.Day4,0) Day4Consumption,
isnull(DaybyDay_Consumption.Day5,0) Day5Consumption,isnull(DaybyDay_Consumption.Day6,0) Day6Consumption,isnull(DaybyDay_Consumption.Day7,0) Day7Consumption,isnull(DaybyDay_Consumption.Day8,0) Day8Consumption,
isnull(DaybyDay_Consumption.Day9,0) Day9Consumption,isnull(DaybyDay_Consumption.Day10,0) Day10Consumption,isnull(DaybyDay_Consumption.Day11,0) Day11Consumption,isnull(DaybyDay_Consumption.Day12,0) Day12Consumption,
isnull(DaybyDay_Consumption.Day13,0) Day13Consumption,isnull(DaybyDay_Consumption.Day14,0) Day14Consumption,isnull(DaybyDay_Consumption.Day15,0) Day15Consumption,isnull(DaybyDay_Consumption.Day16,0) Day16Consumption,
isnull(DaybyDay_Consumption.Day17,0) Day17Consumption,isnull(DaybyDay_Consumption.Day18,0) Day18Consumption,isnull(DaybyDay_Consumption.Day19,0) Day19Consumption,isnull(DaybyDay_Consumption.Day20,0) Day20Consumption,
isnull(DaybyDay_Consumption.Day21,0) Day21Consumption,isnull(DaybyDay_Consumption.Day22,0) Day22Consumption,isnull(DaybyDay_Consumption.Day23,0) Day23Consumption,isnull(DaybyDay_Consumption.Day24,0) Day24Consumption,
isnull(DaybyDay_Consumption.Day25,0) Day25Consumption,isnull(DaybyDay_Consumption.Day26,0) Day26Consumption,isnull(DaybyDay_Consumption.Day27,0) Day27Consumption,isnull(DaybyDay_Consumption.Day28,0) Day28Consumption,
isnull(DaybyDay_Consumption.Day29,0) Day29Consumption,isnull(DaybyDay_Consumption.Day30,0) Day30Consumption,

isnull(DaybyDayGenres.Day1Genres,0) Day1Genres,isnull(DaybyDayGenres.Day2Genres,0) Day2Genres,isnull(DaybyDayGenres.Day3Genres,0) Day3Genres,isnull(DaybyDayGenres.Day4Genres,0) Day4Genres,
isnull(DaybyDayGenres.Day5Genres,0) Day5Genres,isnull(DaybyDayGenres.Day6Genres,0) Day6Genres,isnull(DaybyDayGenres.Day7Genres,0) Day7Genres,isnull(DaybyDayGenres.Day8Genres,0) Day8Genres,
isnull(DaybyDayGenres.Day9Genres,0) Day9Genres,isnull(DaybyDayGenres.Day10Genres,0) Day10Genres,isnull(DaybyDayGenres.Day11Genres,0) Day11Genres,isnull(DaybyDayGenres.Day12Genres,0) Day12Genres,
isnull(DaybyDayGenres.Day13Genres,0) Day13Genres,isnull(DaybyDayGenres.Day14Genres,0) Day14Genres,isnull(DaybyDayGenres.Day15Genres,0) Day15Genres,isnull(DaybyDayGenres.Day16Genres,0) Day16Genres,
isnull(DaybyDayGenres.Day17Genres,0) Day17Genres,isnull(DaybyDayGenres.Day18Genres,0) Day18Genres,isnull(DaybyDayGenres.Day19Genres,0) Day19Genres,isnull(DaybyDayGenres.Day20Genres,0) Day20Genres,
isnull(DaybyDayGenres.Day21Genres,0) Day21Genres,isnull(DaybyDayGenres.Day22Genres,0) Day22Genres,isnull(DaybyDayGenres.Day23Genres,0) Day23Genres,isnull(DaybyDayGenres.Day24Genres,0) Day24Genres,
isnull(DaybyDayGenres.Day25Genres,0) Day25Genres,isnull(DaybyDayGenres.Day26Genres,0) Day26Genres,isnull(DaybyDayGenres.Day27Genres,0) Day27Genres,isnull(DaybyDayGenres.Day28Genres,0) Day28Genres,
isnull(DaybyDayGenres.Day29Genres,0) Day29Genres,isnull(DaybyDayGenres.Day30Genres,0) Day30Genres,

isnull(DaybyDayLectures.Day1Lectures,0) Day1Lectures, isnull(DaybyDayLectures.Day2Lectures,0) Day2Lectures,isnull(DaybyDayLectures.Day3Lectures,0) Day3Lectures,isnull(DaybyDayLectures.Day4Lectures,0) Day4Lectures,
isnull(DaybyDayLectures.Day5Lectures,0) Day5Lectures,isnull(DaybyDayLectures.Day6Lectures,0) Day6Lectures,isnull(DaybyDayLectures.Day7Lectures,0) Day7Lectures,isnull(DaybyDayLectures.Day8Lectures,0) Day8Lectures,
isnull(DaybyDayLectures.Day9Lectures,0) Day9Lectures,isnull(DaybyDayLectures.Day10Lectures,0) Day10Lectures,isnull(DaybyDayLectures.Day11Lectures,0) Day11Lectures,isnull(DaybyDayLectures.Day12Lectures,0) Day12Lectures,
isnull(DaybyDayLectures.Day13Lectures,0) Day13Lectures,isnull(DaybyDayLectures.Day14Lectures,0) Day14Lectures,isnull(DaybyDayLectures.Day15Lectures,0) Day15Lectures,isnull(DaybyDayLectures.Day16Lectures,0) Day16Lectures,
isnull(DaybyDayLectures.Day17Lectures,0) Day17Lectures,isnull(DaybyDayLectures.Day18Lectures,0) Day18Lectures,isnull(DaybyDayLectures.Day19Lectures,0) Day19Lectures,isnull(DaybyDayLectures.Day20Lectures,0) Day20Lectures,
isnull(DaybyDayLectures.Day21Lectures,0) Day21Lectures,isnull(DaybyDayLectures.Day22Lectures,0) Day22Lectures,isnull(DaybyDayLectures.Day23Lectures,0) Day23Lectures,isnull(DaybyDayLectures.Day24Lectures,0) Day24Lectures,
isnull(DaybyDayLectures.Day25Lectures,0) Day25Lectures,isnull(DaybyDayLectures.Day26Lectures,0) Day26Lectures,isnull(DaybyDayLectures.Day27Lectures,0) Day27Lectures,isnull(DaybyDayLectures.Day28Lectures,0) Day28Lectures, 
isnull(DaybyDayLectures.Day29Lectures,0) Day29Lectures,isnull(DaybyDayLectures.Day30Lectures,0) Day30Lectures,

isnull(AdobePageActivity_AccountPage,0) AdobePageActivity_AccountPageVisits,isnull(AdobePageActivity_FAQ,0) AdobePageActivity_FAQVisits,isnull(AdobePageActivity_Social,0) AdobePageActivity_SocialPageVisits,
isnull(AdobePageActivity_Registration,0) AdobePageActivity_RegistrationPageVisits,isnull(AdobePageActivity_Cancel,0) AdobePageActivity_CancelPageVisits,

isnull(FRUserLevel.Day1_FR,0) Day1_FR,isnull(FRUserLevel.Day2_FR,0) Day2_FR,isnull(FRUserLevel.Day3_FR,0) Day3_FR,isnull(FRUserLevel.Day4_FR,0) Day4_FR,isnull(FRUserLevel.Day5_FR,0) Day5_FR,
isnull(FRUserLevel.Day6_FR,0) Day6_FR,isnull(FRUserLevel.Day7_FR,0) Day7_FR,isnull(FRUserLevel.Day8_FR,0) Day8_FR,isnull(FRUserLevel.Day9_FR,0) Day9_FR,isnull(FRUserLevel.Day10_FR,0) Day10_FR,
isnull(FRUserLevel.Day11_FR,0) Day11_FR,isnull(FRUserLevel.Day12_FR,0) Day12_FR,isnull(FRUserLevel.Day13_FR,0) Day13_FR,isnull(FRUserLevel.Day14_FR,0) Day14_FR,isnull(FRUserLevel.Day15_FR,0) Day15_FR,
isnull(FRUserLevel.Day16_FR,0) Day16_FR,isnull(FRUserLevel.Day17_FR,0) Day17_FR,isnull(FRUserLevel.Day18_FR,0) Day18_FR,isnull(FRUserLevel.Day19_FR,0) Day19_FR,isnull(FRUserLevel.Day20_FR,0) Day20_FR,
isnull(FRUserLevel.Day21_FR,0) Day21_FR,isnull(FRUserLevel.Day22_FR,0) Day22_FR,isnull(FRUserLevel.Day23_FR,0) Day23_FR,isnull(FRUserLevel.Day24_FR,0) Day24_FR,isnull(FRUserLevel.Day25_FR,0) Day25_FR,
isnull(FRUserLevel.Day26_FR,0) Day26_FR,isnull(FRUserLevel.Day27_FR,0) Day27_FR,isnull(FRUserLevel.Day28_FR,0) Day28_FR,isnull(FRUserLevel.Day29_FR,0) Day29_FR,isnull(FRUserLevel.Day30_FR,0) Day30_FR,

isnull(FRUserLevel.Day1_FinishedLectures,0) Day1_FinishedLectures,isnull(FRUserLevel.Day2_FinishedLectures,0) Day2_FinishedLectures,isnull(FRUserLevel.Day3_FinishedLectures,0) Day3_FinishedLectures,
isnull(FRUserLevel.Day4_FinishedLectures,0) Day4_FinishedLectures,isnull(FRUserLevel.Day5_FinishedLectures,0) Day5_FinishedLectures,isnull(FRUserLevel.Day6_FinishedLectures,0) Day6_FinishedLectures,
isnull(FRUserLevel.Day7_FinishedLectures,0) Day7_FinishedLectures,isnull(FRUserLevel.Day8_FinishedLectures,0) Day8_FinishedLectures,isnull(FRUserLevel.Day9_FinishedLectures,0) Day9_FinishedLectures,
isnull(FRUserLevel.Day10_FinishedLectures,0) Day10_FinishedLectures,isnull(FRUserLevel.Day11_FinishedLectures,0) Day11_FinishedLectures,isnull(FRUserLevel.Day12_FinishedLectures,0) Day12_FinishedLectures,
isnull(FRUserLevel.Day13_FinishedLectures,0) Day13_FinishedLectures,isnull(FRUserLevel.Day14_FinishedLectures,0) Day14_FinishedLectures,isnull(FRUserLevel.Day15_FinishedLectures,0) Day15_FinishedLectures,
isnull(FRUserLevel.Day16_FinishedLectures,0) Day16_FinishedLectures,isnull(FRUserLevel.Day17_FinishedLectures,0) Day17_FinishedLectures,isnull(FRUserLevel.Day18_FinishedLectures,0) Day18_FinishedLectures,
isnull(FRUserLevel.Day19_FinishedLectures,0) Day19_FinishedLectures,isnull(FRUserLevel.Day20_FinishedLectures,0) Day20_FinishedLectures,isnull(FRUserLevel.Day21_FinishedLectures,0) Day21_FinishedLectures,
isnull(FRUserLevel.Day22_FinishedLectures,0) Day22_FinishedLectures,isnull(FRUserLevel.Day23_FinishedLectures,0) Day23_FinishedLectures,isnull(FRUserLevel.Day24_FinishedLectures,0) Day24_FinishedLectures,
isnull(FRUserLevel.Day25_FinishedLectures,0) Day25_FinishedLectures,isnull(FRUserLevel.Day26_FinishedLectures,0) Day26_FinishedLectures,isnull(FRUserLevel.Day27_FinishedLectures,0) Day27_FinishedLectures,
isnull(FRUserLevel.Day28_FinishedLectures,0) Day28_FinishedLectures,isnull(FRUserLevel.Day29_FinishedLectures,0) Day29_FinishedLectures,isnull(FRUserLevel.Day30_FinishedLectures,0) Day30_FinishedLectures,

GenreUserLevel.BehindtheScenes_FR,GenreUserLevel.BonusFeatures_FR,GenreUserLevel.Economics_FR,GenreUserLevel.FoodWine_FR,GenreUserLevel.Health_FR,GenreUserLevel.History_FR,GenreUserLevel.Hobby_FR,
GenreUserLevel.Literature_FR,GenreUserLevel.Mathematics_FR,GenreUserLevel.Music_FR,GenreUserLevel.NatGeo_FR,GenreUserLevel.Phil_FR,GenreUserLevel.Professional_FR,GenreUserLevel.Science_FR,GenreUserLevel.Trailers_FR,GenreUserLevel.Travel_FR,

LSD.LastStreamedDate_FreeTrialMonth,

SailThruOpens.Day1_OpenRate,SailThruOpens.Day2_OpenRate,SailThruOpens.Day3_OpenRate,SailThruOpens.Day4_OpenRate,SailThruOpens.Day5_OpenRate
,SailThruOpens.Day6_OpenRate,SailThruOpens.Day7_OpenRate,SailThruOpens.Day8_OpenRate,SailThruOpens.Day9_OpenRate,SailThruOpens.Day10_OpenRate,
SailThruOpens.Day11_OpenRate,SailThruOpens.Day12_OpenRate,SailThruOpens.Day13_OpenRate,SailThruOpens.Day14_OpenRate,SailThruOpens.Day15_OpenRate,
SailThruOpens.Day16_OpenRate,SailThruOpens.Day17_OpenRate,SailThruOpens.Day18_OpenRate,SailThruOpens.Day19_OpenRate,SailThruOpens.Day20_OpenRate,
SailThruOpens.Day21_OpenRate,SailThruOpens.Day22_OpenRate,SailThruOpens.Day23_OpenRate,SailThruOpens.Day24_OpenRate,SailThruOpens.Day25_OpenRate,
SailThruOpens.Day26_OpenRate,SailThruOpens.Day27_OpenRate,SailThruOpens.Day28_OpenRate,SailThruOpens.Day29_OpenRate,SailThruOpens.Day30_OpenRate,

SailThruClicks.Day1_ClickRate,SailThruClicks.Day2_ClickRate,SailThruClicks.Day3_ClickRate,SailThruClicks.Day4_ClickRate,SailThruClicks.Day5_ClickRate,
SailThruClicks.Day6_ClickRate,SailThruClicks.Day7_ClickRate,SailThruClicks.Day8_ClickRate,SailThruClicks.Day9_ClickRate,SailThruClicks.Day10_ClickRate,
SailThruClicks.Day11_ClickRate,SailThruClicks.Day12_ClickRate,SailThruClicks.Day13_ClickRate,SailThruClicks.Day14_ClickRate,SailThruClicks.Day15_ClickRate,
SailThruClicks.Day16_ClickRate,SailThruClicks.Day17_ClickRate,SailThruClicks.Day18_ClickRate,SailThruClicks.Day19_ClickRate,SailThruClicks.Day20_ClickRate,
SailThruClicks.Day21_ClickRate,SailThruClicks.Day22_ClickRate,SailThruClicks.Day23_ClickRate,SailThruClicks.Day24_ClickRate,SailThruClicks.Day25_ClickRate,
SailThruClicks.Day26_ClickRate,SailThruClicks.Day27_ClickRate,SailThruClicks.Day28_ClickRate,SailThruClicks.Day29_ClickRate,SailThruClicks.Day30_ClickRate,

SailThruSends.Day1_Sends,SailThruSends.Day2_Sends,SailThruSends.Day3_Sends,SailThruSends.Day4_Sends,SailThruSends.Day5_Sends
,SailThruSends.Day6_Sends,SailThruSends.Day7_Sends,SailThruSends.Day8_Sends,SailThruSends.Day9_Sends,SailThruSends.Day10_Sends,
SailThruSends.Day11_Sends,SailThruSends.Day12_Sends,SailThruSends.Day13_Sends,SailThruSends.Day14_Sends,SailThruSends.Day15_Sends,
SailThruSends.Day16_Sends,SailThruSends.Day17_Sends,SailThruSends.Day18_Sends,SailThruSends.Day19_Sends,SailThruSends.Day20_Sends,
SailThruSends.Day21_Sends,SailThruSends.Day22_Sends,SailThruSends.Day23_Sends,SailThruSends.Day24_Sends,SailThruSends.Day25_Sends,
SailThruSends.Day26_Sends,SailThruSends.Day27_Sends,SailThruSends.Day28_Sends,SailThruSends.Day29_Sends,SailThruSends.Day30_Sends,

SailThruOpens1.Day1_Opens, SailThruOpens1.Day2_Opens,SailThruOpens1.Day3_Opens,SailThruOpens1.Day4_Opens,SailThruOpens1.Day5_Opens,
SailThruOpens1.Day6_Opens,SailThruOpens1.Day7_Opens,SailThruOpens1.Day8_Opens,SailThruOpens1.Day9_Opens,SailThruOpens1.Day10_Opens,
SailThruOpens1.Day11_Opens,SailThruOpens1.Day12_Opens,SailThruOpens1.Day13_Opens,SailThruOpens1.Day14_Opens,SailThruOpens1.Day15_Opens,
SailThruOpens1.Day16_Opens,SailThruOpens1.Day17_Opens,SailThruOpens1.Day18_Opens,SailThruOpens1.Day19_Opens,SailThruOpens1.Day20_Opens,
SailThruOpens1.Day21_Opens,SailThruOpens1.Day22_Opens,SailThruOpens1.Day23_Opens,SailThruOpens1.Day24_Opens,SailThruOpens1.Day25_Opens,
SailThruOpens1.Day26_Opens,SailThruOpens1.Day27_Opens,SailThruOpens1.Day28_Opens,SailThruOpens1.Day29_Opens,SailThruOpens1.Day30_Opens,

SailThruRawOpens.Day1_RawOpens,SailThruRawOpens.Day2_RawOpens,SailThruRawOpens.Day3_RawOpens,SailThruRawOpens.Day4_RawOpens,SailThruRawOpens.Day5_RawOpens,
SailThruRawOpens.Day6_RawOpens,SailThruRawOpens.Day7_RawOpens,SailThruRawOpens.Day8_RawOpens,SailThruRawOpens.Day9_RawOpens,SailThruRawOpens.Day10_RawOpens,
SailThruRawOpens.Day11_RawOpens,SailThruRawOpens.Day12_RawOpens,SailThruRawOpens.Day13_RawOpens,SailThruRawOpens.Day14_RawOpens,SailThruRawOpens.Day15_RawOpens,
SailThruRawOpens.Day16_RawOpens,SailThruRawOpens.Day17_RawOpens,SailThruRawOpens.Day18_RawOpens,SailThruRawOpens.Day19_RawOpens,SailThruRawOpens.Day20_RawOpens,
SailThruRawOpens.Day21_RawOpens,SailThruRawOpens.Day22_RawOpens,SailThruRawOpens.Day23_RawOpens,SailThruRawOpens.Day24_RawOpens,SailThruRawOpens.Day25_RawOpens,
SailThruRawOpens.Day26_RawOpens,SailThruRawOpens.Day27_RawOpens,SailThruRawOpens.Day28_RawOpens,SailThruRawOpens.Day29_RawOpens,SailThruRawOpens.Day30_RawOpens,

isnull(TGCPre.PrePlusFinalSales,0) PrePlusFinalSales, isnull(TGCPre.PrePlusOrders,0) PrePlusOrders, 
isnull(TGCPost.PostPlusFinalSales,0) PostPlusFinalSales, isnull(TGCPost.PostPlusOrders,0) PostPlusOrders,

isnull(SailThruOptOut.Day1,0) Day1_OptOutIndicator,isnull(SailThruOptOut.Day2,0) Day2_OptOutIndicator,isnull(SailThruOptOut.Day3,0) Day3_OptOutIndicator,
isnull(SailThruOptOut.Day4,0) Day4_OptOutIndicator,isnull(SailThruOptOut.Day5,0) Day5_OptOutIndicator,isnull(SailThruOptOut.Day6,0) Day6_OptOutIndicator,
isnull(SailThruOptOut.Day7,0) Day7_OptOutIndicator,isnull(SailThruOptOut.Day8,0) Day8_OptOutIndicator,isnull(SailThruOptOut.Day9,0) Day9_OptOutIndicator,
isnull(SailThruOptOut.Day10,0) Day10_OptOutIndicator,isnull(SailThruOptOut.Day11,0) Day11_OptOutIndicator,isnull(SailThruOptOut.Day12,0) Day12_OptOutIndicator,
isnull(SailThruOptOut.Day13,0) Day13_OptOutIndicator,isnull(SailThruOptOut.Day14,0) Day14_OptOutIndicator,isnull(SailThruOptOut.Day15,0) Day15_OptOutIndicator,
isnull(SailThruOptOut.Day16,0) Day16_OptOutIndicator,isnull(SailThruOptOut.Day17,0) Day17_OptOutIndicator,isnull(SailThruOptOut.Day18,0) Day18_OptOutIndicator,
isnull(SailThruOptOut.Day19,0) Day19_OptOutIndicator,isnull(SailThruOptOut.Day20,0) Day20_OptOutIndicator,isnull(SailThruOptOut.Day21,0) Day21_OptOutIndicator,
isnull(SailThruOptOut.Day22,0) Day22_OptOutIndicator,isnull(SailThruOptOut.Day23,0) Day23_OptOutIndicator,isnull(SailThruOptOut.Day24,0) Day24_OptOutIndicator,
isnull(SailThruOptOut.Day25,0) Day25_OptOutIndicator,isnull(SailThruOptOut.Day26,0) Day26_OptOutIndicator,isnull(SailThruOptOut.Day27,0) Day27_OptOutIndicator,
isnull(SailThruOptOut.Day28,0) Day28_OptOutIndicator,isnull(SailThruOptOut.Day29,0) Day29_OptOutIndicator,isnull(SailThruOptOut.Day30,0) Day30_OptOutIndicator,

SailThruOptOut.Optout_time
into #Final
--select *
from archive.vw_tgcplus_customersignature (nolock) a
	left join #freedays F on F.CustomerID = a.CustomerID
	left join archive.tgcplus_user (nolock) b on a.uuid = b.uuid
	left join
		(select a.CustomerID, b.Median as HouseholdIncome_Median, b.Mean as HouseholdIncome_Mean, b.Population as ZipPopulation
		from archive.vw_tgcplus_customersignature (nolock) a 
		left join Archive.MedianHouseholdIncome (nolock) b 
		on a.ZipCode = b.ZipCode
		) HouseholdIncome 
	on a.CustomerID = HouseHoldIncome.CustomerID
	
	left join
	(
	select * from #BrowserSignUp 
	--#BrowserDeviceAgg
	) BrowserDeviceAgg on a.uuid = BrowserDeviceAgg.uuid

/****Complete Streaming info Start****/
--left join
--( select * from #CompleteStreaming ) CompleteStreaming 
--on a.CustomerID = CompleteStreaming.CustomerID
/****Complete Streaming info End****/

/****First Streaming info Start****/
left join
( select * from #FirstStreaming ) FirstStreaming 
on a.CustomerID = FirstStreaming.CustomerID
/****First Streaming info End****/

/****TGC Sales Pre Start****/
left join
( select * from #TGCPre ) as TGCPre on a.CustomerID = TGCPre.CustomerID
/****TGC Sales Pre End****/


/****TGC Sales Post Start****/
left join
(select * from #TGCPost ) as TGCPost on a.CustomerID = TGCPost.CustomerID
/****TGC Sales Post End****/

/****SevenDaysStreaming Start****/
left join
( select * from #SevenDays ) as SevenDays 
on a.CustomerID = SevenDays.CustomerID
/****SevenDaysStreaming End****/

/****FourteenDaysStreaming Start****/
left join
( select * from #FourteenDays ) as FourteenDays 
on a.CustomerID = FourteenDays.CustomerID
/****FourteenDaysStreaming End****/

/****ThirtyDaysStreaming Start****/
left join
( select * from #ThirtyDays ) as ThirtyDays 
on a.CustomerID = ThirtyDays.CustomerID
/****ThirtyDaysStreaming End****/

/****Stripe cardbrand/funding Start****/
left join
(select * from #Stripe ) as Stripe 
on a.uuid = Stripe.uuid
/****Stripe cardbrand/funding END****/

/****DaybyDay_Consumption Start****/
left join
( select * from #DaybyDay_Consumption ) as DaybyDay_Consumption 
on a.CustomerID = DaybyDay_Consumption.Customerid 
/****DaybyDay_Consumption END****/

/****DaybyDayGenres Start****/
left join
(select * from #DaybyDayGenres ) as DaybyDayGenres 
on a.CustomerID = DaybyDayGenres.Customerid
/****DaybyDayGenres END****/

/****DaybyDayLectures Start****/
left join
( select * from #DaybyDayLectures ) as DaybyDayLectures 
on a.CustomerID = DaybyDayLectures.CustomerID 
/****DaybyDayLectures END****/

/****Omni AdobePageActivity_AccountPage Start****/
left join
( select * from #AdobePageActivity ) as AdobeAccountPage 
on a.CustomerID = AdobeAccountPage.CustomerID
/****Omni AdobePageActivity_AccountPage End****/

/****SailThru Finish Ratio cat Start****/
left join
( select * from #FRUserLevel ) as FRUserLevel on a.CustomerID = FRUserLevel.CustomerID
/****SailThru Finish Ratio cat End****/

/****SailThru Streaming cat Start****/
left join
( select * from #GenreUserLevel) as GenreUserLevel on a.CustomerID = GenreUserLevel.CustomerID
/****SailThru Streaming cat end****/

/****SailThru Last Streaming date Start****/
left join
( select * from #LSD ) as LSD 
on a.CustomerID = LSD.CustomerID
/****SailThru Last Streaming date End****/

/****SailThruOpens Rate Start****/
left join
( select * from #SailThruOpens ) SailThruOpens 
on a.CustomerID = SailThruOpens.CustomerID
/****SailThruOpens Rate End****/

/****SailThruClicks Rate Start****/
left join
(select * from #SailThruClicks ) SailThruClicks 
on a.CustomerID = SailThruClicks.CustomerID
/****SailThruClicks Rate End****/

/****SailThruSends Start****/	
left join
( Select * from #SailThruSends ) SailThruSends 
on a.CustomerID = SailThruSends.CustomerID
/****SailThruSends End****/	

/****SailThru Opens SailThruOpens1 Start****/	
left join
( select * from #SailThruOpens1 ) SailThruOpens1 
on a.CustomerID = SailThruOpens1.CustomerID
/****SailThru Opens SailThruOpens1 End****/	

/****SailThruRawOpens Start****/	
left join
( Select * from #SailThruRawOpens ) SailThruRawOpens 
on a.CustomerID = SailThruRawOpens.CustomerID
/****SailThruRawOpens End****/	

/****SailThruOptOut Start****/	
	left join
(select * from #SailThruOptOut ) as SailThruOptOut 
on a.CustomerID = SailThruOptOut.CustomerID
/****SailThruOptOut End****/
where 
--country = 'United States' and 
IntlSubType = 'MONTH' 
--and SubType = 'MONTH'
AND IntlSubPlanName in ('Monthly Subscription','Monthly Subscription Original','Monthly Plan','Montlhy Subscription')




/*

/****Omni AdobePageActivity_AccountPage Start****/
left join
(
Select
CustomerID, sum(AllVisits) AdobePageActivity_AccountPage
from
(
select 
a.MarketingCloudVisitorID, a.TGCPlusUserID as uuid,  
b.IntlSubDate, b.CustomerID, 
c.VisitDate, c.CustomLink, c.AllVisits
from archive.omni_tgcplus_mcid_uuid_mapping (nolock) a
	left join archive.vw_tgcplus_customersignature (nolock) b on a.TGCPlusUserID = b.uuid
	left join #freedays f on f.CustomerID = b.CustomerID
	left join
		(
		select cast(date as date) VisitDate, MarketingCloudVisitorID, CustomLink, sum(cast(AllVisits as bigint)) AllVisits
		from archive.omni_tgcplus_customlinks (nolock)
		group by cast(date as date), MarketingCloudVisitorID, CustomLink
		) as c on a.MarketingCloudVisitorID = c.MarketingCloudVisitorID
where a.TGCPlusUserID not in ('')  
and datediff(d, b.IntlSubDate, c.VisitDate)>=0 
and datediff(d, b.IntlSubDate, c.VisitDate)<=coalesce(f.freedays,30) --Freedays if null then default to 30 days
and a.MarketingCloudVisitorID not in ('00000000000000000000000000000000000000')
and b.IntlSubType = 'MONTH' 
and c.CustomLink not in ('Account Page: Activate Device', 'Account Page: Change Email', 'Account Page: Change personal info', 'Account Page: Email Preferences', 'Account Page: Manage Devices')
) as agg
group by CustomerID
) as AdobeAccountPage on a.CustomerID = AdobeAccountPage.CustomerID
/****Omni AdobePageActivity_AccountPage End****/


/****Omni AdobePageActivity_FAQ Start****/
left join
(
Select
CustomerID, sum(AllVisits) AdobePageActivity_FAQ 
from
(
select 
a.MarketingCloudVisitorID, a.TGCPlusUserID as uuid,  
b.IntlSubDate, b.CustomerID, 
c.VisitDate, c.CustomLink, c.AllVisits
from archive.omni_tgcplus_mcid_uuid_mapping (nolock) a
	left join archive.vw_tgcplus_customersignature (nolock) b on a.TGCPlusUserID = b.uuid
	left join #freedays f on f.CustomerID = b.CustomerID
	left join
		(
		select cast(date as date) VisitDate, MarketingCloudVisitorID, CustomLink, sum(cast(AllVisits as bigint)) AllVisits
		from archive.omni_tgcplus_customlinks (nolock)
		group by cast(date as date), MarketingCloudVisitorID, CustomLink
		) as c on a.MarketingCloudVisitorID = c.MarketingCloudVisitorID
where a.TGCPlusUserID not in ('')  
and datediff(d, b.IntlSubDate, c.VisitDate)>=0 
and datediff(d, b.IntlSubDate, c.VisitDate)<=coalesce(f.freedays,30) --Freedays if null then default to 30 days
and a.MarketingCloudVisitorID not in ('00000000000000000000000000000000000000')
and b.IntlSubType = 'MONTH' 
and c.CustomLink like '%Plus FAQ%'
) as agg
group by CustomerID
) as AdobeFAQPage on a.CustomerID = AdobeFAQPage.CustomerID
/****Omni AdobePageActivity_FAQ End****/


/****Omni AdobePageActivity_Social Start****/
left join
(
Select
CustomerID, sum(AllVisits) AdobePageActivity_Social 
from
(
select 
a.MarketingCloudVisitorID, a.TGCPlusUserID as uuid,  
b.IntlSubDate, b.CustomerID, 
c.VisitDate, c.CustomLink, c.AllVisits
from archive.omni_tgcplus_mcid_uuid_mapping (nolock) a
	left join archive.vw_tgcplus_customersignature (nolock) b on a.TGCPlusUserID = b.uuid
	left join #freedays f on f.CustomerID = b.CustomerID
	left join
		(
		select cast(date as date) VisitDate, MarketingCloudVisitorID, CustomLink, sum(cast(AllVisits as bigint)) AllVisits
		from archive.omni_tgcplus_customlinks (nolock)
		group by cast(date as date), MarketingCloudVisitorID, CustomLink
		) as c on a.MarketingCloudVisitorID = c.MarketingCloudVisitorID
where a.TGCPlusUserID not in ('')  
and datediff(d, b.IntlSubDate, c.VisitDate)>=0 
and datediff(d, b.IntlSubDate, c.VisitDate)<=coalesce(f.freedays,30) --Freedays if null then default to 30 days
and a.MarketingCloudVisitorID not in ('00000000000000000000000000000000000000')
and b.IntlSubType = 'MONTH' 
and c.CustomLink not in ('Contact Us Form Submit','Plus Course Page Facebook Click','Plus Course Page Guidebook Click','Plus Course Page Professor Info Click','Plus Course Page Read Reviews Click','Plus Course Page Reviews Submit','Plus Course Page Twitter Click')
) as agg
group by CustomerID
) as AdobeSocialPage on a.CustomerID = AdobeSocialPage.CustomerID
/****Omni AdobePageActivity_Social End****/


/****Omni AdobePageActivity_Registration Start****/
left join
(
Select
CustomerID, sum(AllVisits) AdobePageActivity_Registration
from
(
select 
a.MarketingCloudVisitorID, a.TGCPlusUserID as uuid,  
b.IntlSubDate, b.CustomerID, 
c.VisitDate, c.CustomLink, c.AllVisits
from archive.omni_tgcplus_mcid_uuid_mapping (nolock) a
	left join archive.vw_tgcplus_customersignature (nolock) b on a.TGCPlusUserID = b.uuid
	left join #freedays F on f.customerid = b.CustomerID
	left join
		(
		select cast(date as date) VisitDate, MarketingCloudVisitorID, CustomLink, sum(cast(AllVisits as bigint)) AllVisits
		from archive.omni_tgcplus_customlinks (nolock)
		group by cast(date as date), MarketingCloudVisitorID, CustomLink
		) as c on a.MarketingCloudVisitorID = c.MarketingCloudVisitorID
where a.TGCPlusUserID not in ('')  
and datediff(d, b.IntlSubDate, c.VisitDate)>=0 
and datediff(d, b.IntlSubDate, c.VisitDate)<= coalesce(f.freedays,30) --Freedays if null then default to 30 days
and a.MarketingCloudVisitorID not in ('00000000000000000000000000000000000000')
and b.IntlSubType = 'MONTH' 
and c.CustomLink not in ('Plus - Begin Registration','Plus - Plan Selected - MONTH','Plus - Plan Selected - undefined','Plus - Plan Selected - WEEK','Plus - Plan Selected - YEAR','Plus - Registration Complete','Plus- Offer Code Applied')
) as agg
group by CustomerID
) as AdobeRegistrationPage on a.CustomerID = AdobeRegistrationPage.CustomerID
/****Omni AdobePageActivity_Registration Start****/



/****Omni AdobePageActivity_Cancel Start****/

left join
(
Select
CustomerID, sum(AllVisits) AdobePageActivity_Cancel
from
(
select 
a.MarketingCloudVisitorID, a.TGCPlusUserID as uuid,  
b.IntlSubDate, b.CustomerID, 
c.VisitDate, c.CustomLink, c.AllVisits
from archive.omni_tgcplus_mcid_uuid_mapping (nolock) a
	left join archive.vw_tgcplus_customersignature (nolock) b on a.TGCPlusUserID = b.uuid
	left join #freedays F on F.CustomerID = b.CustomerID
	left join
		(
		select cast(date as date) VisitDate, MarketingCloudVisitorID, CustomLink, sum(cast(AllVisits as bigint)) AllVisits
		from archive.omni_tgcplus_customlinks (nolock)
		group by cast(date as date), MarketingCloudVisitorID, CustomLink
		) as c on a.MarketingCloudVisitorID = c.MarketingCloudVisitorID
where a.TGCPlusUserID not in ('')  
and datediff(d, b.IntlSubDate, c.VisitDate)>=0 
and datediff(d, b.IntlSubDate, c.VisitDate)<= coalesce(f.freedays,30) --Freedays if null then default to 30 days
and a.MarketingCloudVisitorID not in ('00000000000000000000000000000000000000')
and b.IntlSubType = 'MONTH' 
and c.CustomLink not in ('Plus Cancel Subscription - No','Plus Cancel Subscription - Opened Modal','Plus Cancel Subscription - Yes')
) as agg
group by CustomerID
) as AdobeCancelPage on a.CustomerID = AdobeCancelPage.CustomerID

/****Omni AdobePageActivity_Cancel End****/


*/

 IF OBJECT_ID('archive.TGCPLUS_Churn_Working') IS NOT NULL          
    DROP TABLE archive.TGCPLUS_Churn_Working         

select *,Getdate() as DMLastupdated
into Datawarehouse.archive.TGCPLUS_Churn_Working
from #final


End
GO
