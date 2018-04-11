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

select s.courseid, min(tstamp) ReleaseDate into #temp from datawarehouse.marketing.TGCplus_VideoEvents_Smry s
where s.courseid is not null and s.courseid not in ( select distinct courseid from datawarehouse.mapping.TGC_CourseReleasesDates where BU='TGCPlus') 

group by s.courseid


IF NOT EXISTS(SELECT 1 FROM datawarehouse.mapping.TGC_CourseReleasesDates WHERE BU = @BU)
insert into datawarehouse.mapping.TGC_CourseReleasesDates 
select @BU, a.* , getdate() as DMLastUpdated from #temp a


end 






if @BU ='TGC'
begin

select C.courseid, min(ReleaseDate) ReleaseDate into #temp2 from  [DataWarehouse].[Mapping].[DMCourse] C where BundleFlag = 0 and courseid >  99 
AND C.courseid is not null AND C.COURSEID NOT IN ( 4951,4952,4953,4954,4955,4956,4957,4958)  and C.courseid not in ( select distinct courseid from datawarehouse.mapping.TGC_CourseReleasesDates where BU='TGC') 
GROUP BY C.CourseID


IF NOT EXISTS(SELECT 1 FROM datawarehouse.mapping.TGC_CourseReleasesDates WHERE BU = @BU)
insert into datawarehouse.mapping.TGC_CourseReleasesDates 
select @BU, a.* , getdate() as DMLastUpdated from #temp2 a

END


if @BU ='AIV'
BEGIN


  SELECT  a.courseID,  min(AvailableDate) as ReleaseDate INTO #AIV
  FROM DataWarehouse.Archive.Amazon_streaming A WHERE A.COURSEID NOT IN ( select distinct courseid from datawarehouse.mapping.TGC_CourseReleasesDates where BU='AIV') 
  group by A.CourseID



IF NOT EXISTS(SELECT 1 FROM datawarehouse.mapping.TGC_CourseReleasesDates WHERE BU = @BU)
 insert into [DataWarehouse].[Mapping].[TGC_CourseReleasesDates] 
 select @BU, V.* , getdate() as DMLastUpdated from #AIV V
 END


 
 IF @BU='Audible'
 BEGIN

  
  SELECT au.CourseID, datawarehouse.Staging.getmonday(min(WeekEnding)) as Releasedate INTO #AUDIBLE
   FROM DataWarehouse.Archive.Audible_Weekly_Sales AU WHERE AU.CourseID NOT IN ( select distinct courseid from datawarehouse.mapping.TGC_CourseReleasesDates where BU='Audible')
  group by courseid


IF NOT EXISTS(SELECT 1 FROM datawarehouse.mapping.TGC_CourseReleasesDates WHERE BU = @BU)
 insert into [DataWarehouse].[Mapping].[TGC_CourseReleasesDates] 
 select @BU, aud.*, getdate() as DMLastUpdated from #AUDIBLE aud

 end	

GO
