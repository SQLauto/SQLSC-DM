SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[Vw_TGC_DigitalConsumptionDS]
AS  
select a.*
,			b.DSSales
,			c.DaysCourseActivity
,			case when DaysCourseActivity between 0 and 7 then '1 Week'
			when DaysCourseActivity between 8 and 14 then '2 Weeks'
			when DaysCourseActivity between 15 and 21 then '3 Weeks'
			when DaysCourseActivity between 22 and 28 then '4 Weeks'
			when DaysCourseActivity between 29 and 35 then '5 Weeks'
			when DaysCourseActivity between 36 and 42 then '6 Weeks'
			when DaysCourseActivity between 43 and 49 then '7 Weeks'
			when DaysCourseActivity between 50 and 56 then '8 Weeks'
			else '>8 Weeks' end as WeekCourseBin
from DataWarehouse.Archive.vw_TGC_Digital_CourseCompletion as a
left join (select a.Customerid, courseid, lastcourseactivity, FirstCourseActivity, sum(NetOrderAmount) as DSSales
			from DataWarehouse.Archive.vw_TGC_Digital_CourseCompletion as a
			join DataWarehouse.Marketing.DMPurchaseOrders as b
			on a.Customerid=b.customerid
			where DateOrdered > LastCourseActivity
			group by a.Customerid, courseid, lastcourseactivity,FirstCourseActivity) as b
on a.Customerid=b.CustomerID and a.Courseid=b.Courseid
join (select Customerid, courseid, lastcourseactivity, FirstCourseActivity, DATEDIFF(day,FirstCourseActivity,LastCourseActivity) as DaysCourseActivity
		from DataWarehouse.Archive.vw_TGC_Digital_CourseCompletion
		group by Customerid, courseid, lastcourseactivity, FirstCourseActivity) as c
on a.Customerid=c.CustomerID and a.Courseid=c.Courseid
GO
