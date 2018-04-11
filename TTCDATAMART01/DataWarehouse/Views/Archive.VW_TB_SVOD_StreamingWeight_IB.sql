SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE View [Archive].[VW_TB_SVOD_StreamingWeight_IB]
AS

/*
Select
CourseID, CourseName, PrimaryWebCategory, SVOD_Flag, cast(TSTAMP as Date) TSTAMP, sum(SM) as SM
from
(
select 
a.CourseID, b.CourseName, b.PrimaryWebCategory, 
case   
       when SVOD.CourseID is null then 0 else 1 end as SVOD_Flag, 
a.TSTAMP,
sum(a.StreamedMins) as SM
from [dbo].[VW_TGCplus_Consumption_Smry_Tableau] (nolock) a 
       left join Staging.Vw_DMCourse (nolock) b on a.courseid = b.CourseID
       left join (select Distinct CourseID from archive.Amazon_streaming (nolock)) SVOD on a.courseid = SVOD.CourseID
where a.CourseID is not NULL and a.CourseID > 0

group by a.CourseID, a.TSTAMP, SVOD.CourseID, b.CourseName, b.PrimaryWebCategory
) as agg
group by CourseID, CourseName, PrimaryWebCategory, SVOD_Flag, TSTAMP
*/
Select
CourseID, CourseName, PrimaryWebCategory, SVOD_Flag, EOMonth(TSTAMP) TSTAMP, sum(SM) as SM, getdate() as DMLastupdated
from
(
select 
a.CourseID, b.CourseName, b.PrimaryWebCategory, 
case when SVOD.CourseID is null 
        then 0 else 1 
        end as SVOD_Flag, 
a.TSTAMP,
sum(a.StreamedMins) as SM
from Datawarehouse.Marketing.TGCplus_Consumption_Smry (nolock) a 
join Staging.Vw_DMCourse (nolock) b 
on a.courseid = b.CourseID   
left join (select courseid, min(availableDate) availableDate 
                     from archive.Amazon_streaming (nolock) 
                     group by courseid
                ) SVOD 
on a.courseid = SVOD.CourseID and a.TSTAMP>=SVOD.availableDate
where a.CourseID > 0
group by a.CourseID, a.TSTAMP, SVOD.CourseID, b.CourseName, b.PrimaryWebCategory
) as agg
group by CourseID, CourseName, PrimaryWebCategory, SVOD_Flag, EOMonth(TSTAMP)

GO
