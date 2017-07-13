SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[Vw_Tb_Audible_QuarterlyReport]
as
SELECT 
a.*,
b.CourseName,
b.PrimaryWebCategory
FROM archive.Audible_Quarterly (nolock) a left join staging.VW_DMCourse (nolock) b on a.CourseID = b.CourseID
where a.ProductID not like '%FR%';



--select * from archive.Vw_Tb_Audible_Sales (nolock) 


GO
