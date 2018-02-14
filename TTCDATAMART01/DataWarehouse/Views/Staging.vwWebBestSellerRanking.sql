SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Staging].[vwWebBestSellerRanking]
AS


	select a.guest_bestsellers_rank as ProspectRank,
		a.course_id as CourseID,
		b.CourseName,
		b.CourseParts as Parts,
		a.Website,
		a.authenticated_bestsellers_rank as HouseRank, 
		a.UpdateDate
	 from Exports.Magento.WebBestSellerRank a
		join Mapping.DMCourse b on a.course_id = b.CourseID


GO
