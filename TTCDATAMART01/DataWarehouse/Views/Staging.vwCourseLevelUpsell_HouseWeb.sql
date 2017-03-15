SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Staging].[vwCourseLevelUpsell_HouseWeb]
AS


select a.CourseID, b.CourseName, b.CourseParts, b.BundleFlag,
	a.UpsellCourseID, c.AbbrvCourseName as UpsellCourseName, 
	c.CourseParts UpsellCourseParts,
	a.DisplayOrder
from DataWarehouse.Marketing.Upsell_CourseLevelReccos_HouseWeb a join
	DataWarehouse.Mapping.DMCourse b on a.CourseID = b.CourseID join
	DataWarehouse.Mapping.DMCourse c on a.UpsellCourseID = c.CourseID


GO
