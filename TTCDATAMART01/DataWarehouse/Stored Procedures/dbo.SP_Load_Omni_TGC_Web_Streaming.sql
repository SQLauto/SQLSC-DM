SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

      
CREATE Proc [dbo].[SP_Load_Omni_TGC_Web_Streaming]     @CountryCode varchar(3)        
as        
        
Begin        
        
if @CountryCode  =  'AU'         
        
 Begin        
  select         
  Date,        
  MarketingCloudVisitorID,UserId,        
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
  on A.date = S.date and A.StreamedCountrycode = S.Countrycode        
        
        
  Insert Into  archive.Omni_TGC_Web_Streaming        
  (Date,MarketingCloudVisitorID,UserId,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,MediaViews,MediaTimePlayed,Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,        
  StreamedCountrycode,StreamedFormatType,Lecture_duration,Browser,GeoSegmentationCountries)        
        
  select Date,MarketingCloudVisitorID,UserId,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,MediaViews,MediaTimePlayed,Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,        
  Countrycode,FormatType,Lecture_duration,Browser,GeoSegmentationCountries         
  from #omni_TGC_Web_Streaming_AU        
        

	--Missing Course update    	
	exec SP_Load_Omni_TGC_UpdateMissingCourse_Streaming

        
 IF OBJECT_ID('tempdb..#omni_TGC_Web_Streaming_AU') IS NOT NULL        
    DROP TABLE #omni_TGC_Web_Streaming_AU        


/*Update Final table [Archive].[Omni_TGC_Streaming] */


		Declare @AUMaxActionDate Date
		select  @AUMaxActionDate = max(Actiondate)  
		from [Archive].[Omni_TGC_Streaming]
		where platform = 'AU Web'

		select @AUMaxActionDate = isnull(@AUMaxActionDate,'2015/01/01')
		select @AUMaxActionDate

		select Map.CustomerID,
		Min(coalesce(Omni.MarketingCloudVisitorID,Map.MarketingCloudVisitorID))as MarketingCloudVisitorID,
		Omni.userID,  
		Date,
		MobileDeviceType,
		MobileDevice,
		MediaName,
		courseid,
		LectureNumber,
		Isnull(DeviceConnected,1)DeviceConnected, 
		StreamedCountryCode, 
		StreamedFormatType,
		Lecture_duration,
		Browser,
		GeoSegmentationCountries,  
		Sum(cast (MediaViews as int))MediaViews,  
		sum(cast (MediaTimePlayed as int))MediaTimePlayed,  
		sum(cast (Watched25pct as int))Watched25pct,  
		sum(cast (Watched50pct as int))Watched50pct, 
		sum(cast (Watched75pct as int))Watched75pct,  
		sum(cast (Watched95pct as int))Watched95pct,  
		sum(cast (MediaCompletes as int))MediaCompletes  
		into #WebAU  
		from DataWarehouse.Archive.Omni_TGC_WEb_Streaming omni (nolock)          
		left join (select CustomerID,web_user_id,min(MarketingCloudVisitorID)MarketingCloudVisitorID 
					from DataWarehouse.mapping.Customerid_Userid_MarketingCloudID 
					group by CustomerID,web_user_id
				) Map  
		on Map.web_user_id = Omni.userID  
		Where Omni.StreamedCountryCode = 'AU' and Omni.Date > @AUMaxActionDate
		group by Map.CustomerID,Omni.userID,Date,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,StreamedCountryCode,StreamedFormatType,Lecture_duration,Browser,GeoSegmentationCountries  

		  select              
		  cast(Omni.[Date] as date) Actiondate,              
		  omni.CustomerID,           
		  omni.userid as MagentoUserID,     
		  Omni.MarketingCloudVisitorID,           
		  case when Omni.MobileDeviceType = 'Other' then 'Desktop'          
			   else Omni.MobileDeviceType 
		  end as MobileDeviceType,  
		  isnull(Omni.MobileDevice,'NA')as MobileDevice,
		  Omni.MediaName,  
		  omni.CourseID,              
		  omni.LectureNumber,
		  'Stream' as Action,
		  omni.MediaViews as TotalActions,
		  omni.MediaTimePlayed *1./60 as MediaTimePlayed,
		  omni.Watched25pct,
		  omni.Watched50pct,
		  omni.Watched75pct,
		  omni.Watched95pct,
		  omni.MediaCompletes,     
		  Case when DeviceConnected = 0 then 0 else 1 end as FlagOnline,  
		  Isnull(StreamedFormatType,'NA')StreamedOrDownloadedFormatType,  
		  Lecture_duration,  
		  Omni.GeoSegmentationCountries,  
		  Omni.Browser,
		  Case when Omni.StreamedCountryCode = 'AU' then 'AU Web'
			   when Omni.StreamedCountryCode = 'UK' then 'UK Web'
			   when Omni.StreamedCountryCode = 'US' then 'US Web'
			   else Omni.StreamedCountryCode
		  End as [Platform],
		  do.MediaTypeID as FormatPurchased,         
		  do.orderid ,              
		  do.StockItemID,              
		  cast(ord.BillingCountryCode as char(2)) as BillingCountryCode,          
		  DO.[DateOrdered],
		  Case when do.StockItemID is not null then 'Purchased'
			   when Omni.MediaName like '%Promo%' then 'Promotional'
			   when Omni.MediaName like 'PF%' then 'Promotional'
			   when Omni.MediaName like '%free%' then 'Free'
			   else 'NA'
		  end as TransactionType
		into #WebAUFinal            
		  from #WebAU omni  
		  left join (  select omni.customerid,
							  omni.CourseID,  
							  max(q.StockItemID) as StockItemID , 
							  Min(cast(q.DateOrdered as DATETime)) as DateOrdered , 
							  max(a.MediaTypeID)as MediaTypeID ,MIN(q.OrderID)as OrderID      /*Changed to min to reflect min order date date*/                                   
							  from #WebAU omni (nolock)                 
							  left join DataWarehouse.Marketing.dmpurchaseorderitems (nolock)q                 
							  on omni.CustomerID = q.CustomerID and omni.CourseID= q.CourseID and omni.[date]>=cast(q.DateOrdered as DATE)             
							  inner join staging.InvItem (nolock)a                 
							  on q.StockItemID=a.StockItemID                 
							  where a.MediaTypeID in  ('CD','DownloadA','DownloadV ','DVD','StreamA', 'StreamV','DVDCD','Audio','VHS')         
	           
							  group by omni.customerid,omni.CourseID   
					 )DO   on DO.customerID=omni.customerID and DO.CourseID = omni.CourseID and omni.[date] >= cast(DO.DateOrdered as DATE)             
			left join Marketing.dmpurchaseOrders ord(nolock)               
			on ord.CustomerID=DO.customerID and ord.OrderID = DO.OrderID   


			Delete A from [Archive].[Omni_TGC_Streaming] A
			join #WebAUFinal S
			on A.PlatForm = S.PlatForm and A.Actiondate = S.Actiondate

			insert into [Archive].[Omni_TGC_Streaming] 
			(Actiondate,CustomerID,MagentoUserID,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,CourseID,LectureNumber,Action,TotalActions,
			MediaTimePlayed,Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,FlagOnline,StreamedOrDownloadedFormatType,Lecture_duration,
			GeoSegmentationCountries,BrowserOrAppVersion,Platform,FormatPurchased,orderid,StockItemID,BillingCountryCode,DateOrdered,TransactionType)
			select   
			Actiondate,CustomerID,MagentoUserID,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,CourseID,LectureNumber,Action,TotalActions,MediaTimePlayed,
			Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,FlagOnline,StreamedOrDownloadedFormatType,Lecture_duration,GeoSegmentationCountries,Browser as [BrowserOrAppVersion],Platform,
			FormatPurchased,orderid,StockItemID,BillingCountryCode,DateOrdered,TransactionType
			from #WebAUFinal
        
 End        
        
        
        
        
Else if @CountryCode  =  'UK'         
        
 Begin        
        
        
   select         
   Date,        
   MarketingCloudVisitorID,UserId,        
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
   on A.date = S.date and A.StreamedCountrycode = S.Countrycode        
        
        
   Insert Into archive.Omni_TGC_Web_Streaming        
   (Date,MarketingCloudVisitorID,UserId,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,MediaViews,MediaTimePlayed,Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,        
   StreamedCountrycode,StreamedFormatType,Lecture_duration,Browser,GeoSegmentationCountries)        
        
   select Date,MarketingCloudVisitorID,UserId,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,MediaViews,MediaTimePlayed,Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,        
   Countrycode,FormatType,Lecture_duration,Browser,GeoSegmentationCountries         
   from #omni_TGC_Web_Streaming_UK        



	--Missing Course update    	
	exec SP_Load_Omni_TGC_UpdateMissingCourse_Streaming
        
        
 IF OBJECT_ID('tempdb..#omni_TGC_Web_Streaming_UK') IS NOT NULL        
    DROP TABLE #omni_TGC_Web_Streaming_UK        

/*Update Final table [Archive].[Omni_TGC_Streaming] */


		Declare @UKMaxActionDate Date
		select  @UKMaxActionDate = max(Actiondate)  
		from [Archive].[Omni_TGC_Streaming]
		where platform = 'UK Web'

		select @UKMaxActionDate = isnull(@UKMaxActionDate,'2015/01/01')
		select @UKMaxActionDate as '@UKMaxActionDate'
 
		select Map.CustomerID,
		Min(coalesce(Omni.MarketingCloudVisitorID,Map.MarketingCloudVisitorID))as MarketingCloudVisitorID,
		Omni.userID,  
		Date,
		MobileDeviceType,
		MobileDevice,
		MediaName,
		courseid,
		LectureNumber,
		Isnull(DeviceConnected,1)DeviceConnected, 
		StreamedCountryCode, 
		StreamedFormatType,
		Lecture_duration,
		Browser,
		GeoSegmentationCountries,  
		Sum(cast (MediaViews as int))MediaViews,  
		sum(cast (MediaTimePlayed as int))MediaTimePlayed,  
		sum(cast (Watched25pct as int))Watched25pct,  
		sum(cast (Watched50pct as int))Watched50pct, 
		sum(cast (Watched75pct as int))Watched75pct,  
		sum(cast (Watched95pct as int))Watched95pct,  
		sum(cast (MediaCompletes as int))MediaCompletes  
		into #WebUK  
		from DataWarehouse.Archive.Omni_TGC_WEb_Streaming omni (nolock)          
		left join (select CustomerID,web_user_id,min(MarketingCloudVisitorID)MarketingCloudVisitorID 
					from DataWarehouse.mapping.Customerid_Userid_MarketingCloudID 
					group by CustomerID,web_user_id
				) Map  
		on Map.web_user_id = Omni.userID  
		Where Omni.StreamedCountryCode = 'UK' and Omni.Date > @UKMaxActionDate
		group by Map.CustomerID,Omni.userID,Date,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,StreamedCountryCode,StreamedFormatType,Lecture_duration,Browser,GeoSegmentationCountries  

		  select              
		  cast(Omni.[Date] as date) Actiondate,              
		  omni.CustomerID,           
		  omni.userid as MagentoUserID,     
		  Omni.MarketingCloudVisitorID,           
		  case when Omni.MobileDeviceType = 'Other' then 'Desktop'          
			   else Omni.MobileDeviceType 
		  end as MobileDeviceType,  
		  isnull(Omni.MobileDevice,'NA')as MobileDevice,
		  Omni.MediaName,  
		  omni.CourseID,              
		  omni.LectureNumber,
		  'Stream' as Action,
		  omni.MediaViews as TotalActions,
		  omni.MediaTimePlayed *1./60 as MediaTimePlayed,
		  omni.Watched25pct,
		  omni.Watched50pct,
		  omni.Watched75pct,
		  omni.Watched95pct,
		  omni.MediaCompletes,     
		  Case when DeviceConnected = 0 then 0 else 1 end as FlagOnline,  
		  Isnull(StreamedFormatType,'NA')StreamedOrDownloadedFormatType,  
		  Lecture_duration,  
		  Omni.GeoSegmentationCountries,  
		  Omni.Browser,
		  Case when Omni.StreamedCountryCode = 'AU' then 'AU Web'
			   when Omni.StreamedCountryCode = 'UK' then 'UK Web'
			   when Omni.StreamedCountryCode = 'US' then 'US Web'
			   else Omni.StreamedCountryCode
		  End as [Platform],
		  do.MediaTypeID as FormatPurchased,         
		  do.orderid ,              
		  do.StockItemID,              
		  cast(ord.BillingCountryCode as char(2)) as BillingCountryCode,          
		  DO.[DateOrdered],
		  Case when do.StockItemID is not null then 'Purchased'
			   when Omni.MediaName like '%Promo%' then 'Promotional'
			   when Omni.MediaName like 'PF%' then 'Promotional'
			   when Omni.MediaName like '%free%' then 'Free'
			   else 'NA'
		  end as TransactionType
		into #WebUKFinal            
		  from #WebUK omni  
		  left join (  select omni.customerid,
							  omni.CourseID,  
							  max(q.StockItemID) as StockItemID , 
							  Min(cast(q.DateOrdered as DATETime)) as DateOrdered , 
							  max(a.MediaTypeID)as MediaTypeID ,MIN(q.OrderID)as OrderID      /*Changed to min to reflect min order date date*/                                   
							  from #WebUK omni (nolock)                 
							  left join DataWarehouse.Marketing.dmpurchaseorderitems (nolock)q                 
							  on omni.CustomerID = q.CustomerID and omni.CourseID= q.CourseID and omni.[date]>=cast(q.DateOrdered as DATE)             
							  inner join staging.InvItem (nolock)a                 
							  on q.StockItemID=a.StockItemID                 
							  where a.MediaTypeID in  ('CD','DownloadA','DownloadV ','DVD','StreamA', 'StreamV','DVDCD','Audio','VHS')         
	           
							  group by omni.customerid,omni.CourseID   
					 )DO   on DO.customerID=omni.customerID and DO.CourseID = omni.CourseID and omni.[date] >= cast(DO.DateOrdered as DATE)             
			left join Marketing.dmpurchaseOrders ord(nolock)               
			on ord.CustomerID=DO.customerID and ord.OrderID = DO.OrderID   


			Delete A from [Archive].[Omni_TGC_Streaming] A
			join #WebUKFinal S
			on A.PlatForm = S.PlatForm and A.Actiondate = S.Actiondate

			insert into [Archive].[Omni_TGC_Streaming] 
			(Actiondate,CustomerID,MagentoUserID,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,CourseID,LectureNumber,Action,TotalActions,
			MediaTimePlayed,Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,FlagOnline,StreamedOrDownloadedFormatType,Lecture_duration,
			GeoSegmentationCountries,BrowserOrAppVersion,Platform,FormatPurchased,orderid,StockItemID,BillingCountryCode,DateOrdered,TransactionType)
			select   
			Actiondate,CustomerID,MagentoUserID,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,CourseID,LectureNumber,Action,TotalActions,MediaTimePlayed,
			Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,FlagOnline,StreamedOrDownloadedFormatType,Lecture_duration,GeoSegmentationCountries,Browser as [BrowserOrAppVersion],Platform,
			FormatPurchased,orderid,StockItemID,BillingCountryCode,DateOrdered,TransactionType
			from #WebUKFinal

        
 END        
        
        
Else if @CountryCode  =  'US'         
        
 Begin        
        
        
   select         
   Date,        
   MarketingCloudVisitorID,UserId,        
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
   on A.date = S.date and A.StreamedCountrycode = S.Countrycode        
        
        
   Insert Into archive.Omni_TGC_Web_Streaming        
   (Date,MarketingCloudVisitorID,UserId,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,MediaViews,MediaTimePlayed,Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,        
   StreamedCountrycode,StreamedFormatType,Lecture_duration,Browser,GeoSegmentationCountries)        
        
   select Date,MarketingCloudVisitorID,UserId,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,MediaViews,MediaTimePlayed,Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,        
   Countrycode,FormatType,Lecture_duration,Browser,GeoSegmentationCountries         
   from #omni_TGC_Web_Streaming_US        
        

	--Missing Course update    	
	exec SP_Load_Omni_TGC_UpdateMissingCourse_Streaming


        
 IF OBJECT_ID('tempdb..#omni_TGC_Web_Streaming_US') IS NOT NULL        
    DROP TABLE #omni_TGC_Web_Streaming_US        
        

/*Update Final table [Archive].[Omni_TGC_Streaming] */


		Declare @USMaxActionDate Date
		select  @USMaxActionDate = max(Actiondate)  
		from [Archive].[Omni_TGC_Streaming]
		where platform = 'US Web'

		select @USMaxActionDate = isnull(@USMaxActionDate,'2015/01/01')
		select @USMaxActionDate as '@USMaxActionDate'
 
		select Map.CustomerID,
		Min(coalesce(Omni.MarketingCloudVisitorID,Map.MarketingCloudVisitorID))as MarketingCloudVisitorID,
		Omni.userID,  
		Date,
		MobileDeviceType,
		MobileDevice,
		MediaName,
		courseid,
		LectureNumber,
		Isnull(DeviceConnected,1)DeviceConnected, 
		StreamedCountryCode, 
		StreamedFormatType,
		Lecture_duration,
		Browser,
		GeoSegmentationCountries,  
		Sum(cast (MediaViews as int))MediaViews,  
		sum(cast (MediaTimePlayed as int))MediaTimePlayed,  
		sum(cast (Watched25pct as int))Watched25pct,  
		sum(cast (Watched50pct as int))Watched50pct, 
		sum(cast (Watched75pct as int))Watched75pct,  
		sum(cast (Watched95pct as int))Watched95pct,  
		sum(cast (MediaCompletes as int))MediaCompletes  
		into #WebUS  
		from DataWarehouse.Archive.Omni_TGC_WEb_Streaming omni (nolock)          
		left join (select CustomerID,web_user_id,min(MarketingCloudVisitorID)MarketingCloudVisitorID 
					from DataWarehouse.mapping.Customerid_Userid_MarketingCloudID 
					group by CustomerID,web_user_id
				) Map  
		on Map.web_user_id = Omni.userID  
		Where Omni.StreamedCountryCode = 'US' and Omni.Date > @USMaxActionDate
		group by Map.CustomerID,Omni.userID,Date,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,StreamedCountryCode,StreamedFormatType,Lecture_duration,Browser,GeoSegmentationCountries  

		  select              
		  cast(Omni.[Date] as date) Actiondate,              
		  omni.CustomerID,           
		  omni.userid as MagentoUserID,     
		  Omni.MarketingCloudVisitorID,           
		  case when Omni.MobileDeviceType = 'Other' then 'Desktop'          
			   else Omni.MobileDeviceType 
		  end as MobileDeviceType,  
		  isnull(Omni.MobileDevice,'NA')as MobileDevice,
		  Omni.MediaName,  
		  omni.CourseID,              
		  omni.LectureNumber,
		  'Stream' as Action,
		  omni.MediaViews as TotalActions,
		  omni.MediaTimePlayed *1./60 as MediaTimePlayed,
		  omni.Watched25pct,
		  omni.Watched50pct,
		  omni.Watched75pct,
		  omni.Watched95pct,
		  omni.MediaCompletes,     
		  Case when DeviceConnected = 0 then 0 else 1 end as FlagOnline,  
		  Isnull(StreamedFormatType,'NA')StreamedOrDownloadedFormatType,  
		  Lecture_duration,  
		  Omni.GeoSegmentationCountries,  
		  Omni.Browser,
		  Case when Omni.StreamedCountryCode = 'AU' then 'AU Web'
			   when Omni.StreamedCountryCode = 'UK' then 'UK Web'
			   when Omni.StreamedCountryCode = 'US' then 'US Web'
			   else Omni.StreamedCountryCode
		  End as [Platform],
		  do.MediaTypeID as FormatPurchased,         
		  do.orderid ,              
		  do.StockItemID,              
		  cast(ord.BillingCountryCode as char(2)) as BillingCountryCode,          
		  DO.[DateOrdered],
		  Case when do.StockItemID is not null then 'Purchased'
			   when Omni.MediaName like '%Promo%' then 'Promotional'
			   when Omni.MediaName like 'PF%' then 'Promotional'
			   when Omni.MediaName like '%free%' then 'Free'
			   else 'NA'
		  end as TransactionType
		into #WebUSFinal            
		  from #WebUS omni  
		  left join (  select omni.customerid,
							  omni.CourseID,  
							  max(q.StockItemID) as StockItemID , 
							  Min(cast(q.DateOrdered as DATETime)) as DateOrdered , 
							  max(a.MediaTypeID)as MediaTypeID ,MIN(q.OrderID)as OrderID      /*Changed to min to reflect min order date date*/                                   
							  from #WebUS omni (nolock)                 
							  left join DataWarehouse.Marketing.dmpurchaseorderitems (nolock)q                 
							  on omni.CustomerID = q.CustomerID and omni.CourseID= q.CourseID and omni.[date]>=cast(q.DateOrdered as DATE)             
							  inner join staging.InvItem (nolock)a                 
							  on q.StockItemID=a.StockItemID                 
							  where a.MediaTypeID in  ('CD','DownloadA','DownloadV ','DVD','StreamA', 'StreamV','DVDCD','Audio','VHS')         
	           
							  group by omni.customerid,omni.CourseID   
					 )DO   on DO.customerID=omni.customerID and DO.CourseID = omni.CourseID and omni.[date] >= cast(DO.DateOrdered as DATE)             
			left join Marketing.dmpurchaseOrders ord(nolock)               
			on ord.CustomerID=DO.customerID and ord.OrderID = DO.OrderID   


			Delete A from [Archive].[Omni_TGC_Streaming] A
			join #WebUSFinal S
			on A.PlatForm = S.PlatForm and A.Actiondate = S.Actiondate

			insert into [Archive].[Omni_TGC_Streaming] 
			(Actiondate,CustomerID,MagentoUserID,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,CourseID,LectureNumber,Action,TotalActions,
			MediaTimePlayed,Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,FlagOnline,StreamedOrDownloadedFormatType,Lecture_duration,
			GeoSegmentationCountries,BrowserOrAppVersion,Platform,FormatPurchased,orderid,StockItemID,BillingCountryCode,DateOrdered,TransactionType)
			select   
			Actiondate,CustomerID,MagentoUserID,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,CourseID,LectureNumber,Action,TotalActions,MediaTimePlayed,
			Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,FlagOnline,StreamedOrDownloadedFormatType,Lecture_duration,GeoSegmentationCountries,Browser as [BrowserOrAppVersion],Platform,
			FormatPurchased,orderid,StockItemID,BillingCountryCode,DateOrdered,TransactionType
			from #WebUSFinal
        
 END        
        
        
        
End  
  
  
  
   
  
   
  
GO
