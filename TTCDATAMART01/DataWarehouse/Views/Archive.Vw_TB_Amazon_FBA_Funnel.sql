SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create view [Archive].[Vw_TB_Amazon_FBA_Funnel]
AS
-- Amazon FBA Funnel Query
select 
FunnelDate as Day,
Title,
Sessions,
PageViews,
UnitsOrdered,
OrderedProductSales,
TotalOrderItems,
BuyBoxPercentage, 
case
       when BuyBoxPercentage = 0 then 1 else BuyBoxPercentage end as BuyBox_Percent,
c.CourseName,
c.Topic, c.SubTopic, c.PrimaryWebCategory, c.PrimaryWebSubcategory 
from Archive.FBA_Funnel (nolock) a 
       left join Mapping.FBA_ASIN_Course (nolock) b on a.ASIN = b.ASIN
       left join staging.vw_DMCourse (nolock) c on b.CourseID = c.CourseID
where a.Sessions >= 0

GO
