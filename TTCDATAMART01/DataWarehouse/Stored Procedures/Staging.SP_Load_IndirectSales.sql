SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
  
CREATE Proc [Staging].[SP_Load_IndirectSales]  
as  
Begin  
  
/* Only Inserting Values*/  
  
/* Get and update Course Lecture mapping */  
 select courseid,LectureNum  , cast(0 as int)as TotalLectures  
 into #CourseLecture  
 from mapping.MagentoCourseLectureExport  
 group by courseid,LectureNum   
  
 update a   
 set TotalLectures =  b.TotalLectures  
 from #CourseLecture a   
 join (select courseid,max(LectureNum)TotalLectures   
  from #CourseLecture  
  group by courseid  
  ) b  
 on a.CourseID =  b.CourseID  
  
  
  update staging.Indirect_ssis_Sales 
  set ReportDate =  EoMonth(ReportDate)
  where PartnerName = 'Recorded Books LTD'


 /*Full Course Purchase */  
  
 select CountryCode,PartnerName,ReportDate,Format,ReleaseDate,CourseID,LectureNumber,FullCourse,Units,Revenue,PurchaseChannel,Library,State,PostalCode  
 Into #FullCoursePurchase  
 from  staging.Indirect_ssis_Sales  
 where isnull(PartnerName,'') <>''   
 and FullCourse =  1   
  
 update P  
 Set p.ReleaseDate = Cast(c.ReleaseDate as date)  
 from #FullCoursePurchase P   
 left join DataWarehouse.Mapping.DMCourse c  
 on c.courseid = p.courseid  
 where p.ReleaseDate is NULL  
  
  
 select CountryCode,PartnerName,ReportDate,Format,ReleaseDate,f.CourseID,cl.LectureNum as LectureNumber,Units,Revenue*1./TotalLectures as Revenue,PurchaseChannel,Library,State,PostalCode   
 into #FullCoursePurchasefnl  
 from #FullCoursePurchase f  
 left join #CourseLecture cl on f.courseid = cl.courseid  
  
 /*Course Lecture Purchase */  
 select CountryCode,PartnerName,ReportDate,Format,ReleaseDate,CourseID,LectureNumber,FullCourse,Units,Revenue,PurchaseChannel,Library,State,PostalCode  
 into #CourseLecturePurchase  
 from  staging.Indirect_ssis_Sales  
 where PartnerName is not null  
 and Isnull(FullCourse,0) = 0    
  
 update P  
 Set p.ReleaseDate = Cast(c.ReleaseDate as date)  
 from #CourseLecturePurchase P   
 left join DataWarehouse.Mapping.DMCourse c  
 on c.courseid = p.courseid  
 where p.ReleaseDate is NULL  
  
  
   
 select CountryCode,PartnerName,ReportDate,Format,ReleaseDate,CourseID,LectureNumber,sum(Units)Units,Sum(Revenue)Revenue,PurchaseChannel,Library,State,PostalCode  
 Into #final  
 from #CourseLecturePurchase  
 group by CountryCode,PartnerName,ReportDate,Format,ReleaseDate,CourseID,LectureNumber,PurchaseChannel,Library,State,PostalCode  
 Union   
 select CountryCode,PartnerName,ReportDate,Format,ReleaseDate,CourseID,LectureNumber,sum(Units)Units,Sum(Revenue)Revenue,PurchaseChannel,Library,State,PostalCode  
 from #FullCoursePurchasefnl   
 group by CountryCode,PartnerName,ReportDate,Format,ReleaseDate,CourseID,LectureNumber,PurchaseChannel,Library,State,PostalCode  
  
/* Delete Data if the partner and report data exists already */  
Delete a from Archive.Indirect_Sales a   
join (select distinct PartnerName, ReportDate from #final) f  
on a.PartnerName = f.PartnerName and a.ReportDate = f.ReportDate  
  
/* Postal Code check for US where we have library info*/  
update a  
set postalcode  = case  when patindex ('%-%',postalcode) > 0   
      then substring( postalcode, 1 , charindex('-',postalcode )-1 )   
      else postalcode end     
from #final a  
where  CountryCode = 'US' and library is not null  
and patindex('%-%',Postalcode)>1   
  
update a   
set postalcode = case when len(postalcode)<5 then '0' + postalcode  else postalcode end from #final a  
where  CountryCode = 'US' and library is not null  
and len(Postalcode)<5  
  
  
insert into Archive.Indirect_Sales (CountryCode,PartnerName,ReportDate,Format,ReleaseDate,CourseID,LectureNumber,Units,Revenue,PurchaseChannel,Library,State,PostalCode )  
select * from #final  
  
  
  
End  
  
  
   
GO
