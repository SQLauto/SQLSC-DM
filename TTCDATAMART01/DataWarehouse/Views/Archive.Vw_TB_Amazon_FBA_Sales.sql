SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create view [Archive].[Vw_TB_Amazon_FBA_Sales]
AS
-- Amazon FBA Sales Query
select 
a.*,
b.CourseName,
b.ReleaseDate,
b.Topic, b.SubTopic, b.SubjectCategory,
b.PrimaryWebCategory, b.PrimaryWebSubCategory
from marketing.FBA_coursesales (nolock) a
left join Staging.vw_dmcourse (nolock) b 
on a.courseid = b.courseid


GO
