SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE proc [dbo].[SP_MagentoLecturelistImport]
as

Begin



  BEGIN TRY
    BEGIN TRANSACTION

Select cast(course_id as int)course_id,cast(lecture_number as int) lecture_number,	audio_brightcove_id	,video_brightcove_id,	akamai_download_id	
,replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(rtrim(ltrim(title)),'â','a'),'€','l'),'”',''),'™',''),'&#',''),'Ã','A'),'¡',''),'Ã','A'),'º',''),'©s','')Title,GETDATE() as UpdatedDate
into #Temp
from [staging].[MagentoCourseLectureExport] 

Truncate table [Mapping].[MagentoCourseLectureExport] 

insert into [Mapping].[MagentoCourseLectureExport] 

select audio_brightcove_ID as MediaName, course_id as CourseID,
      lecture_number as LectureNum,
      Title,
      'Audio' as FormatType,
      b.LectureLength,
      b.NumLecture,
      c.CourseParts
from #Temp a left join
      DataWarehouse.Staging.MktCourse b on a.course_id = b.CourseID left join
      DataWarehouse.Mapping.DMCourse c on a.course_id = c.CourseID
where isnull(audio_brightcove_ID,'') <> ''
union
select Video_brightcove_ID as MediaName, course_id as CourseID,
      lecture_number as LectureNum,
      Title,
      'Video' as FormatType,
      b.LectureLength,
      b.NumLecture,
      c.CourseParts
from #Temp a left join
      DataWarehouse.Staging.MktCourse b on a.course_id = b.CourseID left join
      DataWarehouse.Mapping.DMCourse c on a.course_id = c.CourseID
where isnull(Video_brightcove_ID,'') <> ''
union
select akamai_download_id as MediaName, course_id as CourseID,
      lecture_number as LectureNum,
      Title,
      'Unknown' as FormatType,
      b.LectureLength,
      b.NumLecture,
      c.CourseParts
from #Temp a left join
      DataWarehouse.Staging.MktCourse b on a.course_id = b.CourseID left join
      DataWarehouse.Mapping.DMCourse c on a.course_id = c.CourseID
where isnull(akamai_download_id,'') <> ''

Drop table #Temp

    COMMIT TRANSACTION
  END TRY

/* Removed after discussion with Michael on 9/18/2015*/
--update  [Mapping].[MagentoCourseLectureExport]
--set MediaName = case when MediaName like 'TGC%' then 'Brightcove 3:'+ MediaName else MediaName end 

  BEGIN CATCH
    IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;
 
    DECLARE @ErrorNumber INT = ERROR_NUMBER();
    DECLARE @ErrorLine INT = ERROR_LINE();
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
 
    PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
    PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
  END CATCH



end

 

GO
