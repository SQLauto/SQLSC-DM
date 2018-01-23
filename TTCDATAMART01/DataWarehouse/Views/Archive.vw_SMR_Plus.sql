SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[vw_SMR_Plus] as
Select 
UserAgg.*,
Revenue.RevenueRatio
from
(
Select id as CustomerID, cast(tstamp as date) tstamp,TC.courseid, DMC.CourseName, genre, IntlSubDate, IntlSubType, CustStatusFlag, SubDate, IntlMD_Channel, 
case when TGCCustFlag = 1 then 1 else 0 end as TGCCustFlag, 
case
	when IntlSubType = 'MONTH' and cast(tstamp as date) >= IntlSubDate and cast(tstamp as date) <= dateadd(day, 30, IntlSubDate) then 'Free Minutes' 
	else 'Paid Minutes' end as MinuteType, 
cast(dateadd(d, -1, dateadd(m, datediff(m, 0, tstamp)+1, 0)) as date) RevenueDate, 
sum(StreamedMins) as StreamedMins
from archive.Vw_TGCPlus_TableauConsumptionData (nolock) TC left join staging.vw_dmcourse (nolock) DMC on TC.courseid = DMC.courseid
where ExtremeIndicator = 'Regular' and TC.courseid > 0 and FilmType = 'Episode'  and DMC.BundleFlag = 0
group by 
id, cast(tstamp as date), TC.courseid, DMC.CourseName, genre, IntlSubDate, IntlSubType, CustStatusFlag, SubDate, IntlMD_Channel, TGCCustFlag, 
cast(dateadd(d, -1, dateadd(m, datediff(m, 0, tstamp)+1, 0)) as date) 
) as UserAgg
	right join
(
 Select
 a.YearMonth, a.RevenueDate, a.Revenue, C.SM, (a.Revenue/C.SM ) RevenueRatio
 from
 (Select YearMonth, RevenueDate, Revenue from mapping.TGCPlus_Revenue_FromAccting (nolock)) as  a
	left join
		(
		select 
cast(dateadd(d, -1, dateadd(m, datediff(m, 0, tstamp)+1, 0)) as date) EndMonth, 
sum(StreamedMins) as SM
 from archive.Vw_TGCPlus_TableauConsumptionData (nolock) a 
 where courseid > 0 and year(cast(dateadd(d, -1, dateadd(m, datediff(m, 0, tstamp)+1, 0)) as date)) >= 2016 and ExtremeIndicator = 'Regular' and FilmType = 'Episode'
 group by cast(dateadd(d, -1, dateadd(m, datediff(m, 0, tstamp)+1, 0)) as date)
		) as C on a.RevenueDate = c.EndMonth
) as Revenue 
	on UserAgg.RevenueDate = Revenue.RevenueDate
; 
GO
