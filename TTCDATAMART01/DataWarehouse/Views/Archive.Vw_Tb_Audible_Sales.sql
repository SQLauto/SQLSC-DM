SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[Vw_Tb_Audible_Sales]
as
select 
a.*,
a.ReportDate as Report_Month, 
a.ReleaseDate as Release_Date, 
a.CourseID as Course_ID, 
b.CourseName,
b.CourseName as Title, 
b.ReleaseDate as TGC_ReleaseDate,
b.SubjectCategory, b.SubjectCategory2,
b.Topic, b.SubTopic,
b.TGCPlusSubjectCategory,
b.PrimaryWebCategory, b.PrimaryWebSubcategory,
b.CourseParts
from archive.VW_Indirect_sales (nolock) a
	left join staging.vw_dmcourse (nolock) b on a.CourseID = b.CourseID 
where a.PartnerName = 'Audible';



GO
