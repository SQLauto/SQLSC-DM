SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

    
CREATE Proc [dbo].[SP_Load_Omni_LC_Streaming]     @LBCode varchar(10) = 'RB'     
as          
          
Begin          
          
if @LBCode  =  'RB'           
          
 Begin          
           
		select distinct MediaName 
		Into #MediaNames
		from Staging.omni_LC_RB_ssis_Streaming
		where MediaName is NOT NULL
		and len(Medianame)<20

		--drop table #MediaNamesFinal
		select MediaName,  
		Case when MediaName like 'ZA%' then Replace(Replace(left(Replace(MediaName,'ZA',''),4),'_',''),'-','')  
				when MediaName like 'ZV%' then Replace(Replace(left(Replace(MediaName,'ZV',''),4),'_',''),'-','')  
				else null end  
				as CourseId,  
		Substring(MediaName,Patindex('%-L%',MediaName)+2,2) as LectureNumber,  
		Case when MediaName like 'ZA%' then 'Audio'  
				when MediaName like 'ZV%' then 'Video'  
				else 'NA'  
				end as StreamedFormatType  
		,Cast(null as int) lecture_duration  
		Into #MediaNamesFinal  
		from #MediaNames  
		where MediaName like 'Z%'  
		--and MediaName Not like '%Free%'  
		Union   
		select MediaName,
		Case when len(MediaName) <=4 then MediaName
				else null end  
				as CourseId,  
		0 as LectureNumber,  
		Case when MediaName like 'ZA%' then 'Audio'  
				when MediaName like 'ZV%' then 'Video'  
				else 'Video'  
				end as StreamedFormatType  
		,Cast(null as int) lecture_duration  
		from #MediaNames  
		where isnumeric(MediaName) = 1     

		update a  
		set a.lecture_duration = l.video_duration  
		from #MediaNamesFinal a  
		join imports.magento.lectures l  
		on a.MediaName = l.video_brightcove_id   

	select 
	LC.Date,
	LC.userID,
	LC.MobileDeviceType,
	LC.MediaName,
	M.CourseId,
	M.LectureNumber,
	M.StreamedFormatType,
	M.lecture_duration,
	cast(LC.MediaViews as int)MediaViews,
	cast(replace(LC.MediaTimePlayed,'.00','') as int) *1./60 as MediaTimePlayed,
	cast(LC.Watched25pct as int)Watched25pct,    
	cast(LC.Watched50pct as int)Watched50pct,   
	cast(LC.Watched75pct as int)Watched75pct,    
	cast(LC.Watched95pct as int)Watched95pct,    
	cast(LC.MediaCompletes as int)MediaCompletes, 
	LC.GeoSegmentationCountries,
	LC.MarketingCloudVisitorID,
	LC.rb_id,
	LC.Browser,
	'RB' as Library
	into #Omni_LC_Streaming
	from Staging.omni_LC_RB_ssis_Streaming LC
	join #MediaNamesFinal M
	on LC.MediaName = M.MediaName

	delete A from Archive.Omni_LC_Streaming A
	join #Omni_LC_Streaming S
	on S.Library = A.Library 
	and S.Date = A.Date

	insert into Archive.Omni_LC_Streaming (Date,userID,MobileDeviceType,MediaName,CourseId,LectureNumber,StreamedFormatType,lecture_duration,MediaViews,
			MediaTimePlayed,Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,GeoSegmentationCountries,
			MarketingCloudVisitorID,rb_id,Browser,Library)

	select Date,userID,MobileDeviceType,MediaName,CourseId,LectureNumber,StreamedFormatType,lecture_duration,MediaViews,
			MediaTimePlayed,Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,GeoSegmentationCountries,
			MarketingCloudVisitorID,rb_id,Browser,Library
	from #Omni_LC_Streaming

    
          
 End          
          
          
End  


GO
