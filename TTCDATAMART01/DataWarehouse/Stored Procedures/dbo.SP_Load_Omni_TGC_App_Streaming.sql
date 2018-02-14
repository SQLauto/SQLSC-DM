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
   Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,App,StreamedFormatType,Lecture_duration,AppID,GeoSegmentationCountries)        
        
   select Date,userID,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,MediaViews,cast(replace(MediaTimePlayed,'.00','') as int)MediaTimePlayed,        
   Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,App,FormatType,Lecture_duration,AppID,GeoSegmentationCountries        
   from #omni_TGC_Apps_Streaming_Android        
        

/*Update Final table [Archive].[Omni_TGC_Streaming] */


		Declare @AndroidMaxActionDate Date
		select  @AndroidMaxActionDate = max(Actiondate)  
		from [Archive].[Omni_TGC_Streaming]
		where platform = 'Android'

		select @AndroidMaxActionDate = isnull(@AndroidMaxActionDate,'2015/01/01')
		select @AndroidMaxActionDate

 
		select Map.CustomerID,
		Min(Map.MarketingCloudVisitorID)as MarketingCloudVisitorID,
		Omni.userID,  
		Date,
		MobileDeviceType,
		MobileDevice,
		MediaName,
		courseid,
		LectureNumber,
		Isnull(DeviceConnected,1)DeviceConnected, 
		--StreamedCountryCode, 
		StreamedFormatType,
		Lecture_duration,
		App,
		AppId,
		GeoSegmentationCountries,  
		Sum(cast (MediaViews as int))MediaViews,  
		sum(cast (MediaTimePlayed as int))MediaTimePlayed,  
		sum(cast (Watched25pct as int))Watched25pct,  
		sum(cast (Watched50pct as int))Watched50pct, 
		sum(cast (Watched75pct as int))Watched75pct,  
		sum(cast (Watched95pct as int))Watched95pct,  
		sum(cast (MediaCompletes as int))MediaCompletes  
		into #Android  
		from DataWarehouse.Archive.Omni_TGC_Apps_Streaming omni (nolock)          
		left join (select CustomerID,web_user_id,min(MarketingCloudVisitorID)MarketingCloudVisitorID 
					from DataWarehouse.mapping.Customerid_Userid_MarketingCloudID 
					group by CustomerID,web_user_id
				) Map  
		on Map.web_user_id = Omni.userID  
		Where omni.App = 'Android' and Omni.Date > @AndroidMaxActionDate
		group by Map.CustomerID,Omni.userID,Date,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,App,Appid,StreamedFormatType,Lecture_duration,GeoSegmentationCountries  

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
		  Omni.App as [Platform],
		  Omni.AppId,
		  do.MediaTypeID as FormatPurchased,         
		  do.orderid ,              
		  do.StockItemID,              
		  cast(ord.BillingCountryCode as char(2)) as BillingCountryCode,          
		  DO.[DateOrdered],
		  Case when do.StockItemID is not null then 'Purchased'
			   when Omni.MediaName like '%Promo%' then 'Promotional'
			   when Omni.MediaName like '%free%' then 'Free'
			   else 'NA'
		  end as TransactionType
		into #AndroidFinal            
		  from #Android omni  
		  left join (  select omni.customerid,
							  omni.CourseID,  
							  max(q.StockItemID) as StockItemID , 
							  Min(cast(q.DateOrdered as DATETime)) as DateOrdered , 
							  max(a.MediaTypeID)as MediaTypeID ,MIN(q.OrderID)as OrderID      /*Changed to min to reflect min order date date*/                                   
							  from #Android omni (nolock)                 
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
			join #AndroidFinal S
			on A.PlatForm = S.PlatForm and A.Actiondate = S.Actiondate

			insert into [Archive].[Omni_TGC_Streaming] 
			(Actiondate,CustomerID,MagentoUserID,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,CourseID,LectureNumber,Action,TotalActions,
			MediaTimePlayed,Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,FlagOnline,StreamedOrDownloadedFormatType,Lecture_duration,
			GeoSegmentationCountries,BrowserOrAppVersion,Platform,FormatPurchased,orderid,StockItemID,BillingCountryCode,DateOrdered,TransactionType)
			   
			select
			Actiondate,CustomerID,MagentoUserID,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,CourseID,LectureNumber,Action,TotalActions,MediaTimePlayed,
			Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,FlagOnline,StreamedOrDownloadedFormatType,Lecture_duration,GeoSegmentationCountries,APPID as [BrowserOrAppVersion],Platform,
			FormatPurchased,orderid,StockItemID,BillingCountryCode,DateOrdered,TransactionType
			from #AndroidFinal

        
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
   Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,App,StreamedFormatType,Lecture_duration,AppID,GeoSegmentationCountries)        
        
   select Date,userID,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,MediaViews,cast(replace(MediaTimePlayed,'.00','') as int)MediaTimePlayed,        
   Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,App,FormatType,Lecture_duration,AppID,GeoSegmentationCountries        
   from #omni_TGC_Apps_Streaming_IOS        
        


/*Update Final table [Archive].[Omni_TGC_Streaming] */


		Declare @IOSMaxActionDate Date
		select  @IOSMaxActionDate = max(Actiondate)  
		from [Archive].[Omni_TGC_Streaming]
		where platform = 'IOS'

		select @IOSMaxActionDate = isnull(@IOSMaxActionDate,'2015/01/01')
		select @IOSMaxActionDate

 
		select Map.CustomerID,
		Min(Map.MarketingCloudVisitorID)as MarketingCloudVisitorID,
		Omni.userID,  
		Date,
		MobileDeviceType,
		MobileDevice,
		MediaName,
		courseid,
		LectureNumber,
		Isnull(DeviceConnected,1)DeviceConnected, 
		--StreamedCountryCode, 
		StreamedFormatType,
		Lecture_duration,
		App,
		AppId,
		GeoSegmentationCountries,  
		Sum(cast (MediaViews as int))MediaViews,  
		sum(cast (MediaTimePlayed as int))MediaTimePlayed,  
		sum(cast (Watched25pct as int))Watched25pct,  
		sum(cast (Watched50pct as int))Watched50pct, 
		sum(cast (Watched75pct as int))Watched75pct,  
		sum(cast (Watched95pct as int))Watched95pct,  
		sum(cast (MediaCompletes as int))MediaCompletes  
		into #IOS  
		from DataWarehouse.Archive.Omni_TGC_Apps_Streaming omni (nolock)          
		left join (select CustomerID,web_user_id,min(MarketingCloudVisitorID)MarketingCloudVisitorID 
					from DataWarehouse.mapping.Customerid_Userid_MarketingCloudID 
					group by CustomerID,web_user_id
				) Map  
		on Map.web_user_id = Omni.userID  
		Where omni.App = 'IOS' and Omni.Date > @IOSMaxActionDate
		group by Map.CustomerID,Omni.userID,Date,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,App,Appid,StreamedFormatType,Lecture_duration,GeoSegmentationCountries  

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
		  Omni.App as [Platform],
		  Omni.AppId,
		  do.MediaTypeID as FormatPurchased,         
		  do.orderid ,              
		  do.StockItemID,              
		  cast(ord.BillingCountryCode as char(2)) as BillingCountryCode,          
		  DO.[DateOrdered],
		  Case when do.StockItemID is not null then 'Purchased'
			   when Omni.MediaName like '%Promo%' then 'Promotional'
			   when Omni.MediaName like '%free%' then 'Free'
			   else 'NA'
		  end as TransactionType
		into #IOSFinal            
		  from #IOS omni  
		  left join (  select omni.customerid,
							  omni.CourseID,  
							  max(q.StockItemID) as StockItemID , 
							  Min(cast(q.DateOrdered as DATETime)) as DateOrdered , 
							  max(a.MediaTypeID)as MediaTypeID ,MIN(q.OrderID)as OrderID      /*Changed to min to reflect min order date date*/                                   
							  from #IOS omni (nolock)                 
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
			join #IOSFinal S
			on A.PlatForm = S.PlatForm and A.Actiondate = S.Actiondate

			insert into [Archive].[Omni_TGC_Streaming] 
			(Actiondate,CustomerID,MagentoUserID,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,CourseID,LectureNumber,Action,TotalActions,
			MediaTimePlayed,Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,FlagOnline,StreamedOrDownloadedFormatType,Lecture_duration,
			GeoSegmentationCountries,BrowserOrAppVersion,Platform,FormatPurchased,orderid,StockItemID,BillingCountryCode,DateOrdered,TransactionType)
			   
			select
			Actiondate,CustomerID,MagentoUserID,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,CourseID,LectureNumber,Action,TotalActions,MediaTimePlayed,
			Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,FlagOnline,StreamedOrDownloadedFormatType,Lecture_duration,GeoSegmentationCountries,APPID as [BrowserOrAppVersion],Platform,
			FormatPurchased,orderid,StockItemID,BillingCountryCode,DateOrdered,TransactionType
			from #IOSFinal
        
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
   Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,App,StreamedFormatType,Lecture_duration,AppID,GeoSegmentationCountries)        
        
   select Date,userID,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,MediaViews,MediaTimePlayed * 60 as MediaTimePlayed,  /*Convert to Seconds*/      
   Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,App,FormatType,Lecture_duration,AppID,GeoSegmentationCountries        
   from #omni_TGC_Apps_Streaming_ROKU        
        
        

/*Update Final table [Archive].[Omni_TGC_Streaming] */


		Declare @ROKUMaxActionDate Date
		select  @ROKUMaxActionDate = max(Actiondate)  
		from [Archive].[Omni_TGC_Streaming]
		where platform = 'ROKU'

		select @ROKUMaxActionDate = isnull(@ROKUMaxActionDate,'2015/01/01')
		select @ROKUMaxActionDate

 
		select Map.CustomerID,
		Min(Map.MarketingCloudVisitorID)as MarketingCloudVisitorID,
		Omni.userID,  
		Date,
		MobileDeviceType,
		MobileDevice,
		MediaName,
		courseid,
		LectureNumber,
		Isnull(DeviceConnected,1)DeviceConnected, 
		--StreamedCountryCode, 
		StreamedFormatType,
		Lecture_duration,
		App,
		AppId,
		GeoSegmentationCountries,  
		Sum(cast (MediaViews as int))MediaViews,  
		sum(cast (MediaTimePlayed as int))MediaTimePlayed,  
		sum(cast (Watched25pct as int))Watched25pct,  
		sum(cast (Watched50pct as int))Watched50pct, 
		sum(cast (Watched75pct as int))Watched75pct,  
		sum(cast (Watched95pct as int))Watched95pct,  
		sum(cast (MediaCompletes as int))MediaCompletes  
		into #ROKU  
		from DataWarehouse.Archive.Omni_TGC_Apps_Streaming omni (nolock)          
		left join (select CustomerID,web_user_id,min(MarketingCloudVisitorID)MarketingCloudVisitorID 
					from DataWarehouse.mapping.Customerid_Userid_MarketingCloudID 
					group by CustomerID,web_user_id
				) Map  
		on Map.web_user_id = Omni.userID  
		Where omni.App = 'ROKU' and Omni.Date > @ROKUMaxActionDate
		group by Map.CustomerID,Omni.userID,Date,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DeviceConnected,App,Appid,StreamedFormatType,Lecture_duration,GeoSegmentationCountries  

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
		  Omni.App as [Platform],
		  Omni.AppId,
		  do.MediaTypeID as FormatPurchased,         
		  do.orderid ,              
		  do.StockItemID,              
		  cast(ord.BillingCountryCode as char(2)) as BillingCountryCode,          
		  DO.[DateOrdered],
		  Case when do.StockItemID is not null then 'Purchased'
			   when Omni.MediaName like '%Promo%' then 'Promotional'
			   when Omni.MediaName like '%free%' then 'Free'
			   else 'NA'
		  end as TransactionType
		into #ROKUFinal            
		  from #ROKU omni  
		  left join (  select omni.customerid,
							  omni.CourseID,  
							  max(q.StockItemID) as StockItemID , 
							  Min(cast(q.DateOrdered as DATETime)) as DateOrdered , 
							  max(a.MediaTypeID)as MediaTypeID ,MIN(q.OrderID)as OrderID      /*Changed to min to reflect min order date date*/                                   
							  from #ROKU omni (nolock)                 
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
			join #ROKUFinal S
			on A.PlatForm = S.PlatForm and A.Actiondate = S.Actiondate

			insert into [Archive].[Omni_TGC_Streaming] 
			(Actiondate,CustomerID,MagentoUserID,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,CourseID,LectureNumber,Action,TotalActions,
			MediaTimePlayed,Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,FlagOnline,StreamedOrDownloadedFormatType,Lecture_duration,
			GeoSegmentationCountries,BrowserOrAppVersion,Platform,FormatPurchased,orderid,StockItemID,BillingCountryCode,DateOrdered,TransactionType)
			   
			select
			Actiondate,CustomerID,MagentoUserID,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,CourseID,LectureNumber,Action,TotalActions,MediaTimePlayed,
			Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes,FlagOnline,StreamedOrDownloadedFormatType,Lecture_duration,GeoSegmentationCountries,APPID as [BrowserOrAppVersion],Platform,
			FormatPurchased,orderid,StockItemID,BillingCountryCode,DateOrdered,TransactionType
			from #ROKUFinal
        
 END        
        
        
        
End
GO
