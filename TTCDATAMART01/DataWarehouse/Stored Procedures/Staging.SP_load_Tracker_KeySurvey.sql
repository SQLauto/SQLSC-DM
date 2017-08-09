SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Staging].[SP_load_Tracker_KeySurvey]
as

Begin

  BEGIN TRY
    BEGIN TRANSACTION

/* This SP is for loading the Tracker_Keysurvey data Report table (Datawarehouse.marketing.Tracker_KeySurvey)*/

/* Update Default values */
	update  Staging.Tracker_ssis_KeySurvey
	set PROFPRESENTSAT_Value = replace(PROFPRESENTSAT_Value,'.00','')
	update  Staging.Tracker_ssis_KeySurvey
	set GUIDEBOOKSAT_Value = replace(GUIDEBOOKSAT_Value,'.00','')
	update  Staging.Tracker_ssis_KeySurvey
	set LEARN_New_or_Valuable_Value = replace(LEARN_New_or_Valuable_Value,'.00','')
	update  Staging.Tracker_ssis_KeySurvey
	set COURSESAT = replace(COURSESAT,'.00','')
	update  Staging.Tracker_ssis_KeySurvey
	set Course_Price_Value = replace(Course_Price_Value,'.00','')
	update  Staging.Tracker_ssis_KeySurvey
	set VISUALSAT_Value = replace(VISUALSAT_Value,'.00','')
	update  Staging.Tracker_ssis_KeySurvey
	set PROFPRESENTSAT_Value = replace(PROFPRESENTSAT_Value,'','9999')
	update  Staging.Tracker_ssis_KeySurvey
	set GUIDEBOOKSAT_Value = replace(GUIDEBOOKSAT_Value,'','9999')
	update  Staging.Tracker_ssis_KeySurvey
	set LEARN_New_or_Valuable_Value = replace(LEARN_New_or_Valuable_Value,'','9999')
	update  Staging.Tracker_ssis_KeySurvey
	set COURSESAT = replace(COURSESAT,'','9999')
	update  Staging.Tracker_ssis_KeySurvey
	set Course_Price_Value = replace(Course_Price_Value,'','9999')
	update  Staging.Tracker_ssis_KeySurvey
	set VISUALSAT_Value = replace(VISUALSAT_Value,'','9999')
 

	select 
	Survey_Year_Month,Year,cast(Survey_Date as date) Survey_Date,CustomerID,F1_F2,Order_Source,GENSAT_Value,
	GENSAT_BIN_LABEL,GENSAT_VB,RPLIKELI_VALUE,RPLIKELI_BIN_LABEL,RPLIKELI_VB,PRIORRECOMM_Value,
	LIKELIRECOMM_Value,LIKELIRECOMM_BIN_Label,LIKELIRECOMM_VB,CUSTEFFORT_Value,CUSTEFFORT_Label,
	CUSTEFFORT_VB,CATSAT_Value,CATSAT_BIN_Label,CATSATVB,Email_Freq_Value,Email_Freq_BIN_Label,
	CAT_Freq_Value,CAT_Freq_BIN_Label,COURSESELECTSAT_Value,COURSESELECTSAT_BIN_Label,
	cast(		(Replace(   (Replace(	(replace(COURSEID,'(',''))		,')','')),'#VALUE!' ,''))			as int)COURSEID,
	COURSENAME,MEDIATYPE,StreamCourse,DL_Experience,Streaming_Experience,cast(COURSESAT as int)COURSESAT,COURSESAT_BIN_Label
	COURSESATVB,cast(LEARN_New_or_Valuable_Value as int)LEARN_New_or_Valuable_Value,LEARN_New_or_ValuableBIN_Label,
	cast(Course_Price_Value as int)Course_Price_Value,Course_Price_Value_BIN_Label,cast(PROFPRESENTSAT_Value as int)PROFPRESENTSAT_Value,
	PROFPRESENTSAT_BIN_Label,cast(VISUALSAT_Value as int)VISUALSAT_Value,VISUALSAT_BIN_Label,
	cast(GUIDEBOOKSAT_Value as int) GUIDEBOOKSAT_Value,GUIDEBOOKSAT_BIN_Label,WEBSITE_EASENAV_Value,
	WEBSITE_EASENAV_BIN_Label,WEBSITE_LAYOUT,WEBSITE_LAYOUT_BIN,WEBSITE_ACCURACY,WEBSITE_ACCURACY_BIN,
	ACSI_Ideal_Course,ACSI_Ideal_Course_BIN,ACSI_Expectations,ACSI_Expectations_BIN,Backlog,
	Backlog_Number,MajorProblems,Contacted_CSR,Problem_Detail,Problem_Resolved,Android_App_SAT,
	iPad_app_SAT,Apple_Smartphone_app_SAT,The_Torch_SAT
	into #KeySurvey
	from Staging.Tracker_ssis_KeySurvey

--Delete from Datawarehouse.Archive.Tracker_KeySurvey_Raw
--Where cast(DMlastupdated as date) = cast(getdate() as date)

		--Insert into Datawarehouse.Archive.Tracker_KeySurvey_Raw
		--select *,getdate() as DMlastupdated
		--from #KeySurvey

/* Load data to final Qtrly Report table */
/* Adding all into the final report*/
--Truncate table Datawarehouse.marketing.Tracker_KeySurvey

Insert 	Into Datawarehouse.marketing.Tracker_KeySurvey
----------------------------------------------------------------------------------------------
-- Course Sat Report
----------------------------------------------------------------------------------------------
-- 1
select Year(Survey_date) as Year,  
	MONTH(Survey_date) as Month, 
	Survey_date,
	CourseID, 
	CourseName, 
	'BOOKLETSAT' as QuestionCode, 
		case when MediaType in ('Audio Streaming','Audio Download') then 'DownloadA' 
		when MediaType in ('Video Download','Video Streaming') then 'DownloadV' 
		when MediaType in ('Digital Video Disc (DVD)') then 'DVD'
		when MediaType in ('Compact Disc (CD)') then 'CD'
		else MediaType end as MediaType, 
	sum(case when GUIDEBOOKSAT_Value in (9,10) then 1 else 0 end) as NineTens, 
	sum(case when GUIDEBOOKSAT_Value between 0 and 8 then 1 else 0 end) as ZeroEights  -- PR -- 1/25/2014 -- change 1 to 8 to 0 to 8 based change in scale in keysurvey
	,getdate() as ReportRunDate
from #KeySurvey
group by Year(Survey_date),  MONTH(Survey_date),Survey_date, CourseID, CourseName, 
		case when MediaType in ('Audio Streaming','Audio Download') then 'DownloadA' 
			when MediaType in ('Video Download','Video Streaming') then 'DownloadV' 
			when MediaType in ('Digital Video Disc (DVD)') then 'DVD'
			when MediaType in ('Compact Disc (CD)') then 'CD'
			else MediaType
		end
union
-- 2
select Year(Survey_date) as Year,  
	MONTH(Survey_date) as Month, 
	Survey_date,
	CourseID, 
	CourseName, 
	'LearnNewOrValuable' as QuestionCode, 
		case when MediaType in ('Audio Streaming','Audio Download') then 'DownloadA' 
		when MediaType in ('Video Download','Video Streaming') then 'DownloadV' 
		when MediaType in ('Digital Video Disc (DVD)') then 'DVD'
		when MediaType in ('Compact Disc (CD)') then 'CD'
		else MediaType end as MediaType, 
	sum(case when LEARN_New_or_Valuable_Value in (9,10) then 1 else 0 end) as NineTens, 
	sum(case when LEARN_New_or_Valuable_Value between 0 and 8 then 1 else 0 end) as ZeroEights  -- PR -- 1/25/2014 -- change 1 to 8 to 0 to 8 based change in scale in keysurvey
	,getdate() as ReportRunDate
from #KeySurvey
group by Year(Survey_date),  MONTH(Survey_date),Survey_date, CourseID, CourseName, 
		case when MediaType in ('Audio Streaming','Audio Download') then 'DownloadA' 
			when MediaType in ('Video Download','Video Streaming') then 'DownloadV' 
			when MediaType in ('Digital Video Disc (DVD)') then 'DVD'
			when MediaType in ('Compact Disc (CD)') then 'CD'
			else MediaType
		end
union
-- 3
select Year(Survey_date) as Year,  
	MONTH(Survey_date) as Month, 
	Survey_date,
	CourseID, 
	CourseName, 
	'COURSESAT' as QuestionCode, 
		case when MediaType in ('Audio Streaming','Audio Download') then 'DownloadA' 
		when MediaType in ('Video Download','Video Streaming') then 'DownloadV' 
		when MediaType in ('Digital Video Disc (DVD)') then 'DVD'
		when MediaType in ('Compact Disc (CD)') then 'CD'
		else MediaType end as MediaType, 
	sum(case when COURSESAT in (9,10) then 1 else 0 end) as NineTens, 
	sum(case when COURSESAT between 0 and 8 then 1 else 0 end) as ZeroEights  -- PR -- 1/25/2014 -- change 1 to 8 to 0 to 8 based change in scale in keysurvey
	,getdate() as ReportRunDate
from #KeySurvey
group by Year(Survey_date),  MONTH(Survey_date),Survey_date, CourseID, CourseName, 
		case when MediaType in ('Audio Streaming','Audio Download') then 'DownloadA' 
			when MediaType in ('Video Download','Video Streaming') then 'DownloadV' 
			when MediaType in ('Digital Video Disc (DVD)') then 'DVD'
			when MediaType in ('Compact Disc (CD)') then 'CD'
			else MediaType
		end
union
-- 4 
select Year(Survey_date) as Year,  
	MONTH(Survey_date) as Month, 
	Survey_date,
	CourseID, 
	CourseName, 
	'COURSEVALUESAT' as QuestionCode, 
		case when MediaType in ('Audio Streaming','Audio Download') then 'DownloadA' 
		when MediaType in ('Video Download','Video Streaming') then 'DownloadV' 
		when MediaType in ('Digital Video Disc (DVD)') then 'DVD'
		when MediaType in ('Compact Disc (CD)') then 'CD'
		else MediaType end as MediaType, 
	sum(case when Course_Price_Value in (9,10) then 1 else 0 end) as NineTens, 
	sum(case when Course_Price_Value between 0 and 8 then 1 else 0 end) as ZeroEights  -- PR -- 1/25/2014 -- change 1 to 8 to 0 to 8 based change in scale in keysurvey
	,getdate() as ReportRunDate
from #KeySurvey
group by Year(Survey_date),  MONTH(Survey_date),Survey_date, CourseID, CourseName, 
		case when MediaType in ('Audio Streaming','Audio Download') then 'DownloadA' 
			when MediaType in ('Video Download','Video Streaming') then 'DownloadV' 
			when MediaType in ('Digital Video Disc (DVD)') then 'DVD'
			when MediaType in ('Compact Disc (CD)') then 'CD'
			else MediaType
		end	
union
-- 5 
select Year(Survey_date) as Year,  
	MONTH(Survey_date) as Month, 
	Survey_date,
	CourseID, 
	CourseName, 
	'PRESENTSAT' as QuestionCode, 
		case when MediaType in ('Audio Streaming','Audio Download') then 'DownloadA' 
		when MediaType in ('Video Download','Video Streaming') then 'DownloadV' 
		when MediaType in ('Digital Video Disc (DVD)') then 'DVD'
		when MediaType in ('Compact Disc (CD)') then 'CD'
		else MediaType end as MediaType, 
	sum(case when PROFPRESENTSAT_Value in (9,10) then 1 else 0 end) as NineTens, 
	sum(case when PROFPRESENTSAT_Value between 0 and 8 then 1 else 0 end) as ZeroEights  -- PR -- 1/25/2014 -- change 1 to 8 to 0 to 8 based change in scale in keysurvey
	,getdate() as ReportRunDate
from #KeySurvey
group by Year(Survey_date) ,  MONTH(Survey_date),Survey_date, CourseID, CourseName, 
		case when MediaType in ('Audio Streaming','Audio Download') then 'DownloadA' 
			when MediaType in ('Video Download','Video Streaming') then 'DownloadV' 
			when MediaType in ('Digital Video Disc (DVD)') then 'DVD'
			when MediaType in ('Compact Disc (CD)') then 'CD'
			else MediaType
		end	
union
-- 6 
select Year(Survey_date) as Year,  
	MONTH(Survey_date) as Month, 
	Survey_date,
	CourseID, 
	CourseName, 
	'VISUALSAT' as QuestionCode, 
		case when MediaType in ('Audio Streaming','Audio Download') then 'DownloadA' 
		when MediaType in ('Video Download','Video Streaming') then 'DownloadV' 
		when MediaType in ('Digital Video Disc (DVD)') then 'DVD'
		when MediaType in ('Compact Disc (CD)') then 'CD'
		else MediaType end as MediaType, 
	sum(case when VISUALSAT_Value in (9,10) then 1 else 0 end) as NineTens, 
	sum(case when VISUALSAT_Value between 0 and 8 then 1 else 0 end) as ZeroEights  -- PR -- 1/25/2014 -- change 1 to 8 to 0 to 8 based change in scale in keysurvey
	,getdate() as ReportRunDate
from #KeySurvey
group by Year(Survey_date) ,  MONTH(Survey_date),Survey_date, CourseID, CourseName, 
		case when MediaType in ('Audio Streaming','Audio Download') then 'DownloadA' 
			when MediaType in ('Video Download','Video Streaming') then 'DownloadV' 
			when MediaType in ('Digital Video Disc (DVD)') then 'DVD'
			when MediaType in ('Compact Disc (CD)') then 'CD'
			else MediaType
		end	



    COMMIT TRANSACTION
  END TRY



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


End



GO
