SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_Load_Omni_TGC_App_Streaming]     @AppCode varchar(10)  
as  
  
Begin  
  
if @AppCode  =  'Android'   
  
 Begin  
   
  
   select   
   Date,  
   userID,  
   MobileDeviceType,  
   MobileDevice,  
   Android.MediaName,  
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
   'Android' [App],  
   Case when Akamai.akamai_download_id =  Android.MediaName  
    then case when Akamai.audio_duration is not null AND Akamai.video_duration is not null   
        then 'NA'   
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
   End FormatType,  
   Case   
   when la.audio_brightcove_id =  Android.MediaName then LA.audio_duration  
   when lv.video_brightcove_id =  Android.MediaName then LV.video_duration  
   when Akamai.akamai_download_id =  Android.MediaName then coalesce(Akamai.video_duration,Akamai.audio_duration)  
   end Lecture_duration,  
   AppID,  
   GeoSegmentationCountries  
   Into #omni_TGC_Apps_Streaming_Android  
   from  Staging.omni_TGC_ssis_AndroidStreaming Android  
   left join DataWarehouse.Mapping.MagentoCourseLectureExport Map  
   on Map.MediaName = Android.MediaName  
   left join imports.magento.lectures LA  
   on la.audio_brightcove_id =  Android.MediaName  
   left join imports.magento.lectures LV  
   on lv.video_brightcove_id =  Android.MediaName  
   left join imports.magento.lectures Akamai  
   on Akamai.akamai_download_id =  Android.MediaName  
  
   --Delete data if already loaded for this   
   delete A from  archive.omni_TGC_Apps_Streaming A  
   join #omni_TGC_Apps_Streaming_Android S  
   on A.date = S.date and A.App = S.App  
   
   insert into Archive.omni_TGC_Apps_Streaming  
   (Date,userID,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,MediaViews,MediaTimePlayed,  
   Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,App,FormatType,Lecture_duration,AppID,GeoSegmentationCountries)  
  
   select Date,userID,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,MediaViews,MediaTimePlayed,  
   Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,App,FormatType,Lecture_duration,AppID,GeoSegmentationCountries  
   from #omni_TGC_Apps_Streaming_Android  
  
  
 End  
  
   
Else if @AppCode  =  'Ios'   
  
 Begin  
  
   select   
   Date,  
   userID,  
   MobileDeviceType,  
   MobileDevice,  
   IOS.MediaName,  
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
   'IOS' [App],  
   Case when Akamai.akamai_download_id =  IOS.MediaName  
    then case when Akamai.audio_duration is not null AND Akamai.video_duration is not null   
        then 'NA'   
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
   End FormatType,  
   Case   
   when la.audio_brightcove_id =  IOS.MediaName then LA.audio_duration  
   when lv.video_brightcove_id =  IOS.MediaName then LV.video_duration  
   when Akamai.akamai_download_id =  IOS.MediaName then coalesce(Akamai.video_duration,Akamai.audio_duration)  
   end Lecture_duration,  
   AppID,  
   GeoSegmentationCountries  
   Into #omni_TGC_Apps_Streaming_IOS  
   from  Staging.omni_TGC_ssis_IOSStreaming IOS  
   left join DataWarehouse.Mapping.MagentoCourseLectureExport Map  
   on Map.MediaName = IOS.MediaName  
   left join imports.magento.lectures LA  
   on la.audio_brightcove_id =  IOS.MediaName  
   left join imports.magento.lectures LV  
   on lv.video_brightcove_id =  IOS.MediaName  
   left join imports.magento.lectures Akamai  
   on Akamai.akamai_download_id =  IOS.MediaName  
  
  
   --Delete data if already loaded for this   
   delete A from  archive.omni_TGC_Apps_Streaming A  
   join #omni_TGC_Apps_Streaming_IOS S  
   on A.date = S.date and A.App = S.App  
   
   insert into Archive.omni_TGC_Apps_Streaming  
   (Date,userID,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,MediaViews,MediaTimePlayed,  
   Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,App,FormatType,Lecture_duration,AppID,GeoSegmentationCountries)  
  
   select Date,userID,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,MediaViews,MediaTimePlayed,  
   Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,App,FormatType,Lecture_duration,AppID,GeoSegmentationCountries  
   from #omni_TGC_Apps_Streaming_IOS  
  
  
 END  
  
  
Else if @AppCode  =  'Roku'   
  
 Begin  
  
  
   select   
   Date,  
   userID,  
   MobileDeviceType,  
   MobileDevice,  
   ROKU.MediaName,  
   courseid,  
   LectureNum as LectureNumber,  
   DeviceConnected,  
   MediaViews,  
   MediaTimePlayed ,  
   Watched25pct,  
   Watched50pct,  
   Watched75pct,  
   Watched95pct,  
   MediaCompletes,  
   'ROKU' [App],  
   Case when Akamai.akamai_download_id =  ROKU.MediaName  
       then case when Akamai.audio_duration is not null AND Akamai.video_duration is not null   
         then 'NA'   
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
   End FormatType,  
   Case   
   when la.audio_brightcove_id =  ROKU.MediaName then LA.audio_duration  
   when lv.video_brightcove_id =  ROKU.MediaName then LV.video_duration  
   when Akamai.akamai_download_id =  ROKU.MediaName then coalesce(Akamai.video_duration,Akamai.audio_duration)  
   end Lecture_duration,  
   AppID,  
   GeoSegmentationCountries  
   Into #omni_TGC_Apps_Streaming_ROKU  
   from  Staging.omni_TGC_ssis_ROKUStreaming ROKU  
   left join DataWarehouse.Mapping.MagentoCourseLectureExport Map  
   on Map.MediaName = ROKU.MediaName  
   left join imports.magento.lectures LA  
   on la.audio_brightcove_id =  ROKU.MediaName  
   left join imports.magento.lectures LV  
   on lv.video_brightcove_id =  ROKU.MediaName  
   left join imports.magento.lectures Akamai  
   on Akamai.akamai_download_id =  ROKU.MediaName  
  
  
   --Delete data if already loaded for this   
   delete A from  archive.omni_TGC_Apps_Streaming A  
   join #omni_TGC_Apps_Streaming_ROKU S  
   on A.date = S.date and A.App = S.App  
   
   insert into Archive.omni_TGC_Apps_Streaming  
   (Date,userID,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,MediaViews,MediaTimePlayed,  
   Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,App,FormatType,Lecture_duration,AppID,GeoSegmentationCountries)  
  
   select Date,userID,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,MediaViews,MediaTimePlayed * 60 as MediaTimePlayed,  /*Convert to Seconds*/
   Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,App,FormatType,Lecture_duration,AppID,GeoSegmentationCountries  
   from #omni_TGC_Apps_Streaming_ROKU  
  
  
  
 END  
  
  
  
End
GO
