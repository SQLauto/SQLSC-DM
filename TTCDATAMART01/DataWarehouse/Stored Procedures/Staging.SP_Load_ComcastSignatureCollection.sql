SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[SP_Load_ComcastSignatureCollection]    
as    
Begin    
    
 
 Delete A 
 from staging.Comcast_ssis_SignatureCollection S
 join Archive.Comcast_SignatureCollection A
 on a.ReportDate = S.ReportDate


 insert into Archive.Comcast_SignatureCollection
 (Rank,CourseID,LectureNumber,Title,AssetID,Network,LectureRunTime,AvgViewTime,UniqueSetTopBoxes,HouseHolds,Views,AvgVideoCompletionPct,ReportDate)

  select Rank,CourseID,LectureNumber,Title,AssetID,Network,LectureRunTime,AvgViewTime,UniqueSetTopBoxes,HouseHolds,Views,AvgVideoCompletionPct,ReportDate 
  from staging.Comcast_ssis_SignatureCollection
    
End    
    
GO
