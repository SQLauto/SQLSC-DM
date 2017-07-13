SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE View [Archive].[Vw_Tb_Indirect_Sales]

as
Select Final.*, 
c.City, c.ZipCodeType, isnull(c.EstimatedPopulation,0) as Population
, getdate() as DMlastupdated
from
(
select 
a.*,
case   
       when CountryCode = 'US' then right('00000' + a.PostalCode,5) else a.PostalCode end as ZipCode,
b.CourseName,
b.CourseName as Title, 
b.ReleaseDate as TGC_ReleaseDate,
b.SubjectCategory, b.SubjectCategory2,
b.Topic, b.SubTopic,
b.TGCPlusSubjectCategory,
b.PrimaryWebCategory, b.PrimaryWebSubcategory
from archive.VW_Indirect_sales (nolock) a
       left join staging.vw_dmcourse (nolock) b on a.CourseID = b.CourseID
) as Final
left join mapping.ZipCodes (nolock) c on Final.ZipCode = c.ZipCode


GO
