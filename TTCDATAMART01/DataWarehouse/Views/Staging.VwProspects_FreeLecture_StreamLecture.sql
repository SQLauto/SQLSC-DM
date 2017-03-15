SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [Staging].[VwProspects_FreeLecture_StreamLecture]
AS

select CAST(a.WEBDATECOLLECTED as date) as WebDate,
	a.PROSPECTID, a.CUSTACCOUNT, a.EMAILADDRESS,
	a.EMAILCONFIRMED, a.INITIALSOURCECODE, b.AdcodeName,
	a.WEBDATECOLLECTED, a.MODIFIEDDATETIME, 
	a.CREATEDDATETIME, a.ISACCOUNTWHENCREATED,
	a.INITIALUSERAGENT,
	c.CourseID, c.LectureNumber, c.LectureFormat, c.DisplayLectureTitle, 
	c.FromCourseID, c.FromLectureNumber,
	c.progress, c.LastStreamedDate,
	GETDATE() as ReportDate
from DAXImports..TTCPROSPECTS a left join
	DataWarehouse.Mapping.vwAdcodesAll b on a.INITIALSOURCECODE = b.AdCode left join
	((select * 
	from superstardw..WebStreamingProgress a join
		(select c.FreeLectureID, c.LectureFormat,
			c.DisplayLectureTitle, c.FromCourseID, c.FromLectureNumber
		 from superstardw..WebFreeLectures c) b on a.LectureNumber = b.FreeLectureID))c on a.CUSTACCOUNT = c.Customerid
where WEBDATECOLLECTED between '12/6/2013' and GETDATE()


GO
