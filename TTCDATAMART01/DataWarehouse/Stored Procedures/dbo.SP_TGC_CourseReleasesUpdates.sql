SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE proc [dbo].[SP_TGC_CourseReleasesUpdates] @BU varchar(255)

as


/*select  courseid, Min(tstamp)as ReleaseDate, getdate() as DMLastUpdated  into #temp from marketing.TGCplus_VideoEvents_Smry where courseid is not null 
group by courseid order by min(tstamp) desc

select * from #temp


insert into mapping.TGC_CourseReleasesDates 
select 'TGCPlus', a.* from #temp a


select * from  mapping.TGC_CourseReleasesDates 

select * from [DataWarehouse].[Mapping].[DMCourse] where BundleFlag = 0 and courseid < 100 

select CourseID, cast(ReleaseDate as date)  as ReleaseDate, getdate() as DMLastUpdated 
into #t from [DataWarehouse].[Mapping].[DMCourse] where BundleFlag = 0  and courseid >  99 order by CourseID , ReleaseDate


insert into mapping.TGC_CourseReleasesDates 
select 'TGC', b.* from #t b
*/
/*

 insert into [DataWarehouse].[Mapping].[TGC_CourseReleasesDates] 
  SELECT 'AIV' as BU, courseID,  min(AvailableDate) as ReleaseDate, getdate() as DMLastUpdated 
  FROM DataWarehouse.Archive.Amazon_streaming 
  group by CourseID
  order by 2

   insert into [DataWarehouse].[Mapping].[TGC_CourseReleasesDates] 
  SELECT 'Audible' as BU, CourseID, datawarehouse.Staging.getmonday(min(WeekEnding)) as Releasedate, getdate() as DMLastUpdated
   FROM DataWarehouse.Archive.Audible_Weekly_Sales 
  group by courseid
  order by 3 desc


  */

if @BU ='TGCPLus'
begin

select 'TGCPlus' as BU ,s.courseid, min(tstamp) ReleaseDate,getdate() as DMLastUpdated   into #temp from datawarehouse.marketing.TGCplus_VideoEvents_Smry s
where s.courseid is not null    and s.courseid not in ( select distinct courseid from datawarehouse.mapping.TGC_CourseReleasesDates where BU='TGCPlus') 

group by s.courseid




insert into datawarehouse.mapping.TGC_CourseReleasesDates 
select *   from #temp  --where courseid not in ( select distinct courseid from datawarehouse.mapping.TGC_CourseReleasesDates where BU='TGCPlus')


end 






if @BU ='TGC'
begin

select 'TGC' as BU ,C.courseid, min(ReleaseDate) ReleaseDate, Getdate() as DMLastUpdated  into #temp2 from  [DataWarehouse].[Mapping].[DMCourse] C where BundleFlag = 0 and courseid >  99 
AND C.courseid is not null AND C.COURSEID NOT IN ( 4951,4952,4953,4954,4955,4956,4957,4958)  and C.courseid not in ( select distinct courseid from datawarehouse.mapping.TGC_CourseReleasesDates where BU='TGC') 
GROUP BY C.CourseID


insert into datawarehouse.mapping.TGC_CourseReleasesDates 
select  * from #temp2  --where courseid not in ( select distinct courseid from datawarehouse.mapping.TGC_CourseReleasesDates where BU='TGC') 


END


if @BU ='AIV'
BEGIN


  SELECT 'AIV' as bu, a.courseID,  min(AvailableDate) as ReleaseDate, getdate() as DMLastUpdated  INTO #AIV
  FROM DataWarehouse.Archive.Amazon_streaming A WHERE A.COURSEID NOT IN ( select distinct courseid from datawarehouse.mapping.TGC_CourseReleasesDates where BU='AIV') 
  group by A.CourseID



 insert into [DataWarehouse].[Mapping].[TGC_CourseReleasesDates] 
 select  * from #AIV --  where CourseID not in (select distinct courseid from datawarehouse.mapping.TGC_CourseReleasesDates where BU='AIV') 

 END


 
 IF @BU='Audible'
 BEGIN

  SELECT 'Audible' as BU, au.CourseID, datawarehouse.Staging.getmonday(min(WeekEnding)) as Releasedate,  getdate() as DMLastUpdated  INTO #AUDIBLE
   FROM DataWarehouse.Archive.Audible_Weekly_Sales AU WHERE AU.CourseID NOT IN ( select distinct courseid from datawarehouse.mapping.TGC_CourseReleasesDates where BU='Audible')
  group by courseid



 insert into [DataWarehouse].[Mapping].[TGC_CourseReleasesDates] 
 select * from #AUDIBLE --  WHERE CourseID NOT IN ( select distinct courseid from datawarehouse.mapping.TGC_CourseReleasesDates where BU='Audible')

 end	


GO
