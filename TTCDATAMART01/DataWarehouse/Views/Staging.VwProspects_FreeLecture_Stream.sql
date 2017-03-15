SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Staging].[VwProspects_FreeLecture_Stream]
AS

select CAST(a.WEBDATECOLLECTED as date) as WebDate,
	a.PROSPECTID, a.CUSTACCOUNT, a.EMAILADDRESS,
	a.EMAILCONFIRMED, a.INITIALSOURCECODE, b.AdcodeName,
	a.WEBDATECOLLECTED, a.MODIFIEDDATETIME, 
	a.CREATEDDATETIME, a.ISACCOUNTWHENCREATED,
	a.INITIALUSERAGENT,
	c.CourseID, c.LectureNumber, c.CategoryName, 
	c.DisplayOrder, c.LectureFormat, c.DisplayLectureTitle, 
	c.FromCourseID, c.FromLectureNumber,
	c.progress, c.LastStreamedDate,
	GETDATE() as ReportDate
from DAXImports..TTCPROSPECTS a left join
	DataWarehouse.Mapping.vwAdcodesAll b on a.INITIALSOURCECODE = b.AdCode left join
	((select * 
	from superstardw..WebStreamingProgress a join
		(select a.CategoryID, CategoryName, b.FreeLectureID, b.DisplayOrder, c.LectureFormat,
			c.DisplayLectureTitle, c.FromCourseID, c.FromLectureNumber
		 from superstardw..WebFreeLectureCategory a join
			superstardw..WebFreeLecturesIncluded b on a.CategoryID = b.CategoryID join
			superstardw..WebFreeLectures c on b.FreeLectureID = c.FreeLectureID) b on a.CourseID = b.CategoryID
																					and a.LectureNumber = b.FreeLectureID
	where a.LastStreamedDate >= '4/23/2014'))c on a.CUSTACCOUNT = c.Customerid
-- where WEBDATECOLLECTED between '12/6/2013' and GETDATE()  -- PR changed this date to new date to avoid issues with categoryID reuse -- 4/23/2014
where WEBDATECOLLECTED between '4/23/2014' and GETDATE()  


GO
