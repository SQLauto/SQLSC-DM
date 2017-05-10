SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[SP_IndirectSales_Load2]
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


 /*Full Course Purchase */

 select CountryCode,PartnerName,ReportDate,Format,ReleaseDate,CourseID,LectureNumber,FullCourse,Units,Revenue,PurchaseChannel,Library,State,PostalCode
 Into #FullCoursePurchase
 from  staging.Indirect_ssis_Sales2
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
 from  staging.Indirect_ssis_Sales2
 where PartnerName is not null
 and Isnull(FullCourse,0) = 0  

 update P
 Set p.ReleaseDate = Cast(c.ReleaseDate as date)
 from #CourseLecturePurchase P 
 left join DataWarehouse.Mapping.DMCourse c
 on c.courseid = p.courseid
 where p.ReleaseDate is NULL


 insert into Archive.Indirect_Sales2 (CountryCode,PartnerName,ReportDate,Format,ReleaseDate,CourseID,LectureNumber,Units,Revenue,PurchaseChannel,Library,State,PostalCode )
 select CountryCode,PartnerName,ReportDate,Format,ReleaseDate,CourseID,LectureNumber,sum(Units)Units,Sum(Revenue)Revenue,PurchaseChannel,Library,State,PostalCode
 from #CourseLecturePurchase
 group by CountryCode,PartnerName,ReportDate,Format,ReleaseDate,CourseID,LectureNumber,PurchaseChannel,Library,State,PostalCode

 Union 

 select CountryCode,PartnerName,ReportDate,Format,ReleaseDate,CourseID,LectureNumber,sum(Units)Units,Sum(Revenue)Revenue,PurchaseChannel,Library,State,PostalCode
 from #FullCoursePurchasefnl 
 group by CountryCode,PartnerName,ReportDate,Format,ReleaseDate,CourseID,LectureNumber,PurchaseChannel,Library,State,PostalCode


End


 




GO
