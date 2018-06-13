SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create View [Archive].[Vw_TB_Comcast_SignatureCollection]
as
select 
a.CourseID, b.CourseName, b.PrimaryWebCategory, b.Genre,
a.LectureNumber, a.Title as LectureName,
a.AvgViewTime, a.UniqueSetTopBoxes, a.HouseHolds, a.Views, a.AvgVideoCompletionPct,
a.ReportDate
from Archive.Comcast_SignatureCollection (nolock) a
            left join 
                        ( select CourseID, CourseName, PrimaryWebCategory, TGCPlusSubjectCategory as Genre from staging.Vw_DMCourse (nolock) where flagactive = 1 and bundleflag = 0
                        ) b on a.CourseID = b.CourseID
GO
