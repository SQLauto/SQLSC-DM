SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Proc [dbo].[SP_Load_Omni_TGC_Web_Streaming]     @CountryCode varchar(3)
as

Begin

if @CountryCode  =  'AU' 

	Begin
		select 
		Date,
		MarketingCloudVisitorID,
		MobileDeviceType,
		MobileDevice,
		AU.MediaName,
		courseid,
		LectureNum as LectureNumber,
		DeviceConnected,
		MediaViews,
		MediaTimePlayed,
		Watched25pct,
		Watched50pct,
		Watched75pct,
		Watched95pct,
		MediaCompletes,
		'AU' [Countrycode],
		Case when Akamai.akamai_download_id =  AU.MediaName
			   then case when Akamai.audio_duration is not null AND Akamai.video_duration is not null 
								then 'BOTH' 
								when Akamai.audio_duration is not null 
								then 'Audio' 
								when Akamai.video_duration is not null 
								then 'Video' else null 
					   end 
			   else 
					  case when LA.audio_duration is not null 
							  then 'Audio' 
							  when LV.video_duration is not null 
							  then 'Video' else null 
					  end 
		End
		FormatType,
		Case 
		when la.audio_brightcove_id =  AU.MediaName then LA.audio_duration
		when lv.video_brightcove_id =  AU.MediaName then LV.video_duration
		when Akamai.akamai_download_id =  AU.MediaName then coalesce(Akamai.video_duration,Akamai.audio_duration)
		end Lecture_duration,
		Browser,
		GeoSegmentationCountries
		Into #omni_TGC_Web_Streaming_AU
		from  Staging.omni_TGC_ssis_AUStreaming AU
		left join DataWarehouse.Mapping.MagentoCourseLectureExport Map
		on Map.MediaName = AU.MediaName
		left join imports.magento.lectures LA
		on la.audio_brightcove_id =  AU.MediaName
		left join imports.magento.lectures LV
		on lv.video_brightcove_id =  AU.MediaName
		left join imports.magento.lectures Akamai
		on Akamai.akamai_download_id =  AU.MediaName


		--Delete data if already loaded for this 
		delete A from  archive.Omni_TGC_Web_Streaming A
		join #omni_TGC_Web_Streaming_AU S
		on A.date = S.date and A.Countrycode = S.Countrycode


		Insert Into  archive.Omni_TGC_Web_Streaming
		(Date,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,MediaViews,MediaTimePlayed,Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,
		Countrycode,FormatType,Lecture_duration,Browser,GeoSegmentationCountries)

		select Date,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,MediaViews,MediaTimePlayed,Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,
		Countrycode,FormatType,Lecture_duration,Browser,GeoSegmentationCountries 
		from #omni_TGC_Web_Streaming_AU


	IF OBJECT_ID('tempdb..#omni_TGC_Web_Streaming_AU') IS NOT NULL
    DROP TABLE #omni_TGC_Web_Streaming_AU

	End




Else if @CountryCode  =  'UK' 

	Begin


			select 
			Date,
			MarketingCloudVisitorID,
			MobileDeviceType,
			MobileDevice,
			UK.MediaName,
			courseid,
			LectureNum as LectureNumber,
			DeviceConnected,
			MediaViews,
			MediaTimePlayed,
			Watched25pct,
			Watched50pct,
			Watched75pct,
			Watched95pct,
			MediaCompletes,
			'UK' [Countrycode],
			Case when Akamai.akamai_download_id =  UK.MediaName
				then case when Akamai.audio_duration is not null AND Akamai.video_duration is not null 
								then 'BOTH' 
								when Akamai.audio_duration is not null 
								then 'Audio' 
								when Akamai.video_duration is not null 
								then 'Video' else null 
						end 
				else 
						case when LA.audio_duration is not null 
								then 'Audio' 
								when LV.video_duration is not null 
								then 'Video' else null 
						end 
			End
			FormatType,
			Case 
			when la.audio_brightcove_id =  UK.MediaName then LA.audio_duration
			when lv.video_brightcove_id =  UK.MediaName then LV.video_duration
			when Akamai.akamai_download_id =  UK.MediaName then coalesce(Akamai.video_duration,Akamai.audio_duration)
			end Lecture_duration,
			Browser,
			GeoSegmentationCountries
			Into #omni_TGC_Web_Streaming_UK
			from  Staging.omni_TGC_ssis_UKStreaming UK
			left join DataWarehouse.Mapping.MagentoCourseLectureExport Map
			on Map.MediaName = UK.MediaName
			left join imports.magento.lectures LA
			on la.audio_brightcove_id =  UK.MediaName
			left join imports.magento.lectures LV
			on lv.video_brightcove_id =  UK.MediaName
			left join imports.magento.lectures Akamai
			on Akamai.akamai_download_id =  UK.MediaName


			--Delete data if already loaded for this 
			delete A from  archive.Omni_TGC_Web_Streaming A
			join #omni_TGC_Web_Streaming_UK S
			on A.date = S.date and A.Countrycode = S.Countrycode


			Insert Into archive.Omni_TGC_Web_Streaming
			(Date,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,MediaViews,MediaTimePlayed,Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,
			Countrycode,FormatType,Lecture_duration,Browser,GeoSegmentationCountries)

			select Date,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,MediaViews,MediaTimePlayed,Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,
			Countrycode,FormatType,Lecture_duration,Browser,GeoSegmentationCountries 
			from #omni_TGC_Web_Streaming_UK


	IF OBJECT_ID('tempdb..#omni_TGC_Web_Streaming_UK') IS NOT NULL
    DROP TABLE #omni_TGC_Web_Streaming_UK

	END


Else if @CountryCode  =  'US' 

	Begin


			select 
			Date,
			MarketingCloudVisitorID,
			MobileDeviceType,
			MobileDevice,
			US.MediaName,
			courseid,
			LectureNum as LectureNumber,
			DeviceConnected,
			MediaViews,
			MediaTimePlayed,
			Watched25pct,
			Watched50pct,
			Watched75pct,
			Watched95pct,
			MediaCompletes,
			'US' [Countrycode],
			Case when Akamai.akamai_download_id =  US.MediaName
					then case when Akamai.audio_duration is not null AND Akamai.video_duration is not null 
									then 'BOTH' 
									when Akamai.audio_duration is not null 
									then 'Audio' 
									when Akamai.video_duration is not null 
									then 'Video' else null 
							end 
					else 
							case when LA.audio_duration is not null 
									then 'Audio' 
									when LV.video_duration is not null 
									then 'Video' else null 
							end 
			End
			FormatType,
			Case 
			when la.audio_brightcove_id =  US.MediaName then LA.audio_duration
			when lv.video_brightcove_id =  US.MediaName then LV.video_duration
			when Akamai.akamai_download_id =  US.MediaName then coalesce(Akamai.video_duration,Akamai.audio_duration)
			end Lecture_duration,
			Browser,
			GeoSegmentationCountries
			Into #omni_TGC_Web_Streaming_US
			from  Staging.omni_TGC_ssis_USStreaming US
			left join DataWarehouse.Mapping.MagentoCourseLectureExport Map
			on Map.MediaName = US.MediaName
			left join imports.magento.lectures LA
			on la.audio_brightcove_id =  US.MediaName
			left join imports.magento.lectures LV
			on lv.video_brightcove_id =  US.MediaName
			left join imports.magento.lectures Akamai
			on Akamai.akamai_download_id =  US.MediaName


			--Delete data if already loaded for this 
			delete A from  archive.Omni_TGC_Web_Streaming A
			join #omni_TGC_Web_Streaming_US S
			on A.date = S.date and A.Countrycode = S.Countrycode


			Insert Into archive.Omni_TGC_Web_Streaming
			(Date,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,MediaViews,MediaTimePlayed,Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,
			Countrycode,FormatType,Lecture_duration,Browser,GeoSegmentationCountries)

			select Date,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,MediaViews,MediaTimePlayed,Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,
			Countrycode,FormatType,Lecture_duration,Browser,GeoSegmentationCountries 
			from #omni_TGC_Web_Streaming_US


	IF OBJECT_ID('tempdb..#omni_TGC_Web_Streaming_US') IS NOT NULL
    DROP TABLE #omni_TGC_Web_Streaming_US


	END



End
GO
