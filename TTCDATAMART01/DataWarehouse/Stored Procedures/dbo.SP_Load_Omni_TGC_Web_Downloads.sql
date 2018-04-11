SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


    
CREATE Proc [dbo].[SP_Load_Omni_TGC_Web_Downloads]     @CountryCode varchar(3)          
as          
          
Begin          
          
if @CountryCode  =  'AU'           
          
 Begin          
     
 update Staging.omni_TGC_ssis_AUDownloads     
 set LectureDownloaded = replace(LectureDownloaded,'%27','''')    
 where LectureDownloaded  like '%ThePhilosopher%27sToolkit%'    
    
   select       
   Date,      
   MarketingCloudVisitorID,UserId,      
   MobileDeviceType,      
   Null as MobileDevice,      
   AU.LectureDownloaded as MediaName,      
   courseid,      
   LectureNum as LectureNumber,      
   'AU' [Countrycode],      
 Case when right(LectureDownloaded,4) in ('.mp3','.m4b') then 'Audio'    
  when right(LectureDownloaded,4) in ('.wmv','.m4v') then 'Video'    
  when LectureDownloaded like '%Audio%' then 'Audio'     
  when LectureDownloaded like '%Video%' then 'Video'    
  when LectureDownloaded like 'ZA%' then 'Audio'     
  when LectureDownloaded like 'ZV%' then 'Video'    
  Else 'NA'    
 end as FormatType,      
   Case       
  when la.audio_brightcove_id =  substring(AU.LectureDownloaded,1,len(AU.LectureDownloaded)-4)  then LA.audio_duration      
  when lv.video_brightcove_id =  substring(AU.LectureDownloaded,1,len(AU.LectureDownloaded)-4)  then LV.video_duration      
  when Akamai.akamai_download_id = substring(AU.LectureDownloaded,1,len(AU.LectureDownloaded)-4)      
  and (right(LectureDownloaded,4) in ('.mp3','.m4b') or  LectureDownloaded like '%Audio%' or LectureDownloaded like 'ZA%' ) then Akamai.audio_duration    
  when Akamai.akamai_download_id = substring(AU.LectureDownloaded,1,len(AU.LectureDownloaded)-4)     
  and (right(LectureDownloaded,4) in ('.wmv','.m4v') or LectureDownloaded like '%Video%' or LectureDownloaded like 'ZV%' ) then Akamai.video_duration    
 end Lecture_duration,      
   Browser,      
   GeoSegmentationCountries,  
   AllVisits      
Into #omni_TGC_Web_Downloaded_AU    
 from  Staging.omni_TGC_ssis_AUDownloads   AU    
 left join DataWarehouse.Mapping.MagentoCourseLectureExport   Map    
 on substring(AU.LectureDownloaded,1,len(AU.LectureDownloaded)-4)  =   Map.MediaName     
   left join imports.magento.lectures LA      
   on la.audio_brightcove_id =  AU.LectureDownloaded and la.default_course_number is NULL    
   left join imports.magento.lectures LV      
   on lv.video_brightcove_id =  AU.LectureDownloaded and lv.default_course_number is NULL    
   left join imports.magento.lectures Akamai      
   on Akamai.akamai_download_id =  substring(AU.LectureDownloaded,1,len(AU.LectureDownloaded)-4)     
          
          
  --Delete data if already loaded for this           
  delete A from  archive.Omni_TGC_Web_downloads A          
  join #omni_TGC_Web_Downloaded_AU S          
  on A.date = S.date and A.DownloadedCountrycode = S.Countrycode          
          
          
  Insert Into  archive.Omni_TGC_Web_downloads          
  (Date,MarketingCloudVisitorID,UserId,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DownloadedCountryCode,DownloadedFormatType,Lecture_duration,Browser,GeoSegmentationCountries,AllVisits)          
          
  select Date,MarketingCloudVisitorID,UserId,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,CountryCode,FormatType,Lecture_duration,Browser,GeoSegmentationCountries,AllVisits          
  from #omni_TGC_Web_Downloaded_AU          


	--Missing Course update    
	exec SP_Load_Omni_TGC_UpdateMissingCourse_Downloads          
          
 IF OBJECT_ID('tempdb..#omni_TGC_Web_Downloaded_AU') IS NOT NULL          
    DROP TABLE #omni_TGC_Web_Downloaded_AU          




/*Update Final table [Archive].[Omni_TGC_Downloads] */  
  
  
  Declare @AUMaxActionDate Date  
  select  @AUMaxActionDate = max(Actiondate)    
  from [Archive].[Omni_TGC_Downloads]  
  where platform = 'AU Web'  
  
  select @AUMaxActionDate = isnull(@AUMaxActionDate,'2015/01/01')  
  select @AUMaxActionDate as '@AUMaxActionDate'  


		select Map.CustomerID,
		Min(coalesce(Omni.MarketingCloudVisitorID,Map.MarketingCloudVisitorID))as MarketingCloudVisitorID,
		Omni.userID,  
		Date,
		MobileDeviceType,
		MobileDevice,
		MediaName,
		courseid,
		LectureNumber,
		1 as DeviceConnected, 
		DownloadedCountryCode, 
		DownloadedFormatType,
		Lecture_duration,
		Browser,
		GeoSegmentationCountries,  
		Sum(Case when Allvisits>= 1 then 1 else 0 end)MediaViews
		into #DownloadsAU  
		from DataWarehouse.Archive.Omni_TGC_WEb_Downloads omni (nolock)          
		left join (select CustomerID,web_user_id,min(MarketingCloudVisitorID)MarketingCloudVisitorID 
					from DataWarehouse.mapping.Customerid_Userid_MarketingCloudID 
					group by CustomerID,web_user_id
					) Map  
		on Map.web_user_id = Omni.userID  
		Where Omni.DownloadedCountryCode = 'AU' and Omni.Date > @AUMaxActionDate
		group by Map.CustomerID,Omni.userID,Date,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DownloadedCountryCode,DownloadedFormatType,Lecture_duration,Browser,GeoSegmentationCountries  

  
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
		  'Download' as Action,
		  omni.MediaViews as TotalActions,
		  Case when DeviceConnected = 0 then 0 else 1 end as FlagOnline,  
		  Isnull(DownloadedFormatType,'NA')StreamedOrDownloadedFormatType,  
		  Lecture_duration,  
		  Omni.GeoSegmentationCountries,  
		  Omni.Browser,
		  Case when Omni.DownloadedCountryCode = 'AU' then 'AU Web'
			   when Omni.DownloadedCountryCode = 'UK' then 'UK Web'
			   when Omni.DownloadedCountryCode = 'US' then 'US Web'
			   else Omni.DownloadedCountryCode
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

		into #DownloadsAUFinal            
		  from #DownloadsAU omni  
		  left join (  select omni.customerid,
							  omni.CourseID,  
							  max(q.StockItemID) as StockItemID , 
							  Min(cast(q.DateOrdered as DATETime)) as DateOrdered , 
							  max(a.MediaTypeID)as MediaTypeID ,MIN(q.OrderID)as OrderID      /*Changed to min to reflect min order date date*/                                   
							  from #DownloadsAU omni (nolock)                 
							  left join DataWarehouse.Marketing.dmpurchaseorderitems (nolock)q                 
							  on omni.CustomerID = q.CustomerID and omni.CourseID= q.CourseID and omni.[date]>=cast(q.DateOrdered as DATE)             
							  inner join staging.InvItem (nolock)a                 
							  on q.StockItemID=a.StockItemID                 
							  where a.MediaTypeID in  ('CD','DownloadA','DownloadV ','DVD','StreamA', 'StreamV','DVDCD','Audio','VHS')         
	           
							  group by omni.customerid,omni.CourseID   
					 )DO   on DO.customerID=omni.customerID and DO.CourseID = omni.CourseID and omni.[date] >= cast(DO.DateOrdered as DATE)             
			left join Marketing.dmpurchaseOrders ord(nolock)               
			on ord.CustomerID=DO.customerID and ord.OrderID = DO.OrderID  


			Delete A from [Archive].[Omni_TGC_Downloads] A
			join #DownloadsAUFinal S
			on A.ActionDate = S.ActionDate and A.PlatForm = S.PlatForm


		Insert into [Archive].[Omni_TGC_Downloads]
		(Actiondate,CustomerID,MagentoUserID,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,CourseID,LectureNumber,Action,TotalActions,FlagOnline,StreamedOrDownloadedFormatType,
		Lecture_duration,GeoSegmentationCountries,BrowserOrAppVersion,Platform,FormatPurchased,orderid,StockItemID,BillingCountryCode,DateOrdered,TransactionType) 

		select  Actiondate,CustomerID,MagentoUserID,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,CourseID,LectureNumber,Action,TotalActions,
		FlagOnline,StreamedOrDownloadedFormatType,Lecture_duration,GeoSegmentationCountries,Browser as [BrowserOrAppVersion] ,Platform,FormatPurchased,orderid,StockItemID,BillingCountryCode,DateOrdered,TransactionType
		from #DownloadsAUFinal
          
 End          
          
          
          
          
Else if @CountryCode  =  'UK'           
          
 Begin          
          
          
 update Staging.omni_TGC_ssis_UKDownloads     
 set LectureDownloaded = replace(LectureDownloaded,'%27','''')    
 where LectureDownloaded  like '%ThePhilosopher%27sToolkit%'      
    
   select       
   Date,      
   MarketingCloudVisitorID,UserId,      
   MobileDeviceType,      
   Null as MobileDevice,      
   UK.LectureDownloaded as MediaName,      
   courseid,      
   LectureNum as LectureNumber,      
   'UK' [Countrycode],      
 Case when right(LectureDownloaded,4) in ('.mp3','.m4b') then 'Audio'    
  when right(LectureDownloaded,4) in ('.wmv','.m4v') then 'Video'    
  when LectureDownloaded like '%Audio%' then 'Audio'     
  when LectureDownloaded like '%Video%' then 'Video'    
  when LectureDownloaded like 'ZA%' then 'Audio'     
  when LectureDownloaded like 'ZV%' then 'Video'    
  Else 'NA'    
 end as FormatType,      
   Case       
  when la.audio_brightcove_id =  substring(UK.LectureDownloaded,1,len(UK.LectureDownloaded)-4)  then LA.audio_duration      
  when lv.video_brightcove_id =  substring(UK.LectureDownloaded,1,len(UK.LectureDownloaded)-4)  then LV.video_duration      
  when Akamai.akamai_download_id = substring(Uk.LectureDownloaded,1,len(Uk.LectureDownloaded)-4)      
  and (right(LectureDownloaded,4) in ('.mp3','.m4b') or  LectureDownloaded like '%Audio%' or LectureDownloaded like 'ZA%' ) then Akamai.audio_duration    
  when Akamai.akamai_download_id = substring(Uk.LectureDownloaded,1,len(Uk.LectureDownloaded)-4)     
  and (right(LectureDownloaded,4) in ('.wmv','.m4v') or LectureDownloaded like '%Video%' or LectureDownloaded like 'ZV%' ) then Akamai.video_duration    
 end Lecture_duration,      
   Browser,      
   GeoSegmentationCountries,  
   AllVisits      
Into #omni_TGC_Web_Downloaded_UK    
 from  Staging.omni_TGC_ssis_UKDownloads   UK    
 left join DataWarehouse.Mapping.MagentoCourseLectureExport   Map    
 on substring(UK.LectureDownloaded,1,len(UK.LectureDownloaded)-4)  =   Map.MediaName     
   left join imports.magento.lectures LA      
   on la.audio_brightcove_id =  UK.LectureDownloaded and la.default_course_number is NULL    
   left join imports.magento.lectures LV      
   on lv.video_brightcove_id =  UK.LectureDownloaded and lv.default_course_number is NULL    
   left join imports.magento.lectures Akamai      
   on Akamai.akamai_download_id =  substring(UK.LectureDownloaded,1,len(UK.LectureDownloaded)-4)     
    
          
   --Delete data if already loaded for this           
  delete A from  archive.Omni_TGC_Web_downloads A          
  join #omni_TGC_Web_Downloaded_UK S          
  on A.date = S.date and A.DownloadedCountrycode = S.Countrycode          
          
          
  Insert Into  archive.Omni_TGC_Web_downloads          
  (Date,MarketingCloudVisitorID,UserId,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DownloadedCountryCode,DownloadedFormatType,Lecture_duration,Browser,GeoSegmentationCountries,AllVisits)          
          
  select Date,MarketingCloudVisitorID,UserId,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,CountryCode,FormatType,Lecture_duration,Browser,GeoSegmentationCountries,AllVisits          
  from #omni_TGC_Web_Downloaded_UK          
          

	--Missing Course update    
	exec SP_Load_Omni_TGC_UpdateMissingCourse_Downloads
          
 IF OBJECT_ID('tempdb..#omni_TGC_Web_Downloaded_UK') IS NOT NULL          
    DROP TABLE #omni_TGC_Web_Downloaded_UK          


/*Update Final table [Archive].[Omni_TGC_Downloads] */  
  
  
  Declare @UKMaxActionDate Date  
  select  @UKMaxActionDate = max(Actiondate)    
  from [Archive].[Omni_TGC_Downloads]  
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
		1 as DeviceConnected, 
		DownloadedCountryCode, 
		DownloadedFormatType,
		Lecture_duration,
		Browser,
		GeoSegmentationCountries,  
		Sum(Case when Allvisits>= 1 then 1 else 0 end)MediaViews
		into #DownloadsUK  
		from DataWarehouse.Archive.Omni_TGC_WEb_Downloads omni (nolock)          
		left join (select CustomerID,web_user_id,min(MarketingCloudVisitorID)MarketingCloudVisitorID 
					from DataWarehouse.mapping.Customerid_Userid_MarketingCloudID 
					group by CustomerID,web_user_id
					) Map  
		on Map.web_user_id = Omni.userID  
		Where Omni.DownloadedCountryCode = 'UK' and Omni.Date > @UKMaxActionDate
		group by Map.CustomerID,Omni.userID,Date,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DownloadedCountryCode,DownloadedFormatType,Lecture_duration,Browser,GeoSegmentationCountries  

  
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
		  'Download' as Action,
		  omni.MediaViews as TotalActions,
		  Case when DeviceConnected = 0 then 0 else 1 end as FlagOnline,  
		  Isnull(DownloadedFormatType,'NA')StreamedOrDownloadedFormatType,  
		  Lecture_duration,  
		  Omni.GeoSegmentationCountries,  
		  Omni.Browser,
		  Case when Omni.DownloadedCountryCode = 'AU' then 'AU Web'
			   when Omni.DownloadedCountryCode = 'UK' then 'UK Web'
			   when Omni.DownloadedCountryCode = 'US' then 'US Web'
			   else Omni.DownloadedCountryCode
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

		into #DownloadsUKFinal            
		  from #DownloadsUK omni  
		  left join (  select omni.customerid,
							  omni.CourseID,  
							  max(q.StockItemID) as StockItemID , 
							  Min(cast(q.DateOrdered as DATETime)) as DateOrdered , 
							  max(a.MediaTypeID)as MediaTypeID ,MIN(q.OrderID)as OrderID      /*Changed to min to reflect min order date date*/                                   
							  from #DownloadsUK omni (nolock)                 
							  left join DataWarehouse.Marketing.dmpurchaseorderitems (nolock)q                 
							  on omni.CustomerID = q.CustomerID and omni.CourseID= q.CourseID and omni.[date]>=cast(q.DateOrdered as DATE)             
							  inner join staging.InvItem (nolock)a                 
							  on q.StockItemID=a.StockItemID                 
							  where a.MediaTypeID in  ('CD','DownloadA','DownloadV ','DVD','StreamA', 'StreamV','DVDCD','Audio','VHS')         
	           
							  group by omni.customerid,omni.CourseID   
					 )DO   on DO.customerID=omni.customerID and DO.CourseID = omni.CourseID and omni.[date] >= cast(DO.DateOrdered as DATE)             
			left join Marketing.dmpurchaseOrders ord(nolock)               
			on ord.CustomerID=DO.customerID and ord.OrderID = DO.OrderID  


			Delete A from [Archive].[Omni_TGC_Downloads] A
			join #DownloadsUKFinal S
			on A.ActionDate = S.ActionDate and A.PlatForm = S.PlatForm


		Insert into [Archive].[Omni_TGC_Downloads]
		(Actiondate,CustomerID,MagentoUserID,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,CourseID,LectureNumber,Action,TotalActions,FlagOnline,StreamedOrDownloadedFormatType,
		Lecture_duration,GeoSegmentationCountries,BrowserOrAppVersion,Platform,FormatPurchased,orderid,StockItemID,BillingCountryCode,DateOrdered,TransactionType) 

		select  Actiondate,CustomerID,MagentoUserID,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,CourseID,LectureNumber,Action,TotalActions,
		FlagOnline,StreamedOrDownloadedFormatType,Lecture_duration,GeoSegmentationCountries,Browser as [BrowserOrAppVersion] ,Platform,FormatPurchased,orderid,StockItemID,BillingCountryCode,DateOrdered,TransactionType
		from #DownloadsUKFinal
          
 END          
          
          
Else if @CountryCode  =  'US'           
          
 Begin          
          
          
 update Staging.omni_TGC_ssis_USDownloads     
 set LectureDownloaded = replace(LectureDownloaded,'%27','''')    
 where LectureDownloaded  like '%ThePhilosopher%27sToolkit%'      
          
   select       
   Date,      
   MarketingCloudVisitorID,UserId,      
   MobileDeviceType,      
   Null as MobileDevice,      
   US.LectureDownloaded as MediaName,      
   courseid,      
   LectureNum as LectureNumber,      
   'US' [Countrycode],      
 Case when right(LectureDownloaded,4) in ('.mp3','.m4b') then 'Audio'    
  when right(LectureDownloaded,4) in ('.wmv','.m4v') then 'Video'    
  when LectureDownloaded like '%Audio%' then 'Audio'     
  when LectureDownloaded like '%Video%' then 'Video'    
  when LectureDownloaded like 'ZA%' then 'Audio'     
  when LectureDownloaded like 'ZV%' then 'Video'    
  Else 'NA'    
 end as FormatType,      
   Case       
  when la.audio_brightcove_id =  substring(US.LectureDownloaded,1,len(US.LectureDownloaded)-4)  then LA.audio_duration      
  when lv.video_brightcove_id =  substring(US.LectureDownloaded,1,len(US.LectureDownloaded)-4)  then LV.video_duration      
  when Akamai.akamai_download_id = substring(US.LectureDownloaded,1,len(US.LectureDownloaded)-4)      
  and (right(LectureDownloaded,4) in ('.mp3','.m4b') or  LectureDownloaded like '%Audio%' or LectureDownloaded like 'ZA%' ) then Akamai.audio_duration    
  when Akamai.akamai_download_id = substring(US.LectureDownloaded,1,len(US.LectureDownloaded)-4)     
  and (right(LectureDownloaded,4) in ('.wmv','.m4v') or LectureDownloaded like '%Video%' or LectureDownloaded like 'ZV%' ) then Akamai.video_duration    
 end Lecture_duration,      
   Browser,      
   GeoSegmentationCountries,  
   AllVisits      
Into #omni_TGC_Web_Downloaded_US    
 from  Staging.omni_TGC_ssis_USDownloads   US    
 left join DataWarehouse.Mapping.MagentoCourseLectureExport   Map    
 on substring(US.LectureDownloaded,1,len(US.LectureDownloaded)-4)  =   Map.MediaName     
   left join imports.magento.lectures LA      
   on la.audio_brightcove_id =  US.LectureDownloaded and la.default_course_number is NULL    
   left join imports.magento.lectures LV      
   on lv.video_brightcove_id =  US.LectureDownloaded and lv.default_course_number is NULL    
   left join imports.magento.lectures Akamai      
   on Akamai.akamai_download_id =  substring(US.LectureDownloaded,1,len(US.LectureDownloaded)-4)     
    
          
   --Delete data if already loaded for this           
  delete A from  archive.Omni_TGC_Web_downloads A          
  join #omni_TGC_Web_Downloaded_US S          
  on A.date = S.date and A.DownloadedCountrycode = S.Countrycode          
          
          
  Insert Into  archive.Omni_TGC_Web_downloads          
  (Date,MarketingCloudVisitorID,UserId,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DownloadedCountryCode,DownloadedFormatType,Lecture_duration,Browser,GeoSegmentationCountries,AllVisits)          
          
  select Date,MarketingCloudVisitorID,UserId,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,CountryCode,FormatType,Lecture_duration,Browser,GeoSegmentationCountries,AllVisits         
  from #omni_TGC_Web_Downloaded_US          
          


	--Missing Course update    
	exec SP_Load_Omni_TGC_UpdateMissingCourse_Downloads
          
 IF OBJECT_ID('tempdb..#omni_TGC_Web_Downloaded_US') IS NOT NULL          
    DROP TABLE #omni_TGC_Web_Downloaded_US          
            
      

/*Update Final table [Archive].[Omni_TGC_Downloads] */  
  
  
  Declare @USMaxActionDate Date  
  select  @USMaxActionDate = max(Actiondate)    
  from [Archive].[Omni_TGC_Downloads]  
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
		1 as DeviceConnected, 
		DownloadedCountryCode, 
		DownloadedFormatType,
		Lecture_duration,
		Browser,
		GeoSegmentationCountries,  
		Sum(Case when Allvisits>= 1 then 1 else 0 end)MediaViews
		into #DownloadsUS  
		from DataWarehouse.Archive.Omni_TGC_WEb_Downloads omni (nolock)          
		left join (select CustomerID,web_user_id,min(MarketingCloudVisitorID)MarketingCloudVisitorID 
					from DataWarehouse.mapping.Customerid_Userid_MarketingCloudID 
					group by CustomerID,web_user_id
					) Map  
		on Map.web_user_id = Omni.userID  
		Where Omni.DownloadedCountryCode = 'US' and Omni.Date > @USMaxActionDate
		group by Map.CustomerID,Omni.userID,Date,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,DownloadedCountryCode,DownloadedFormatType,Lecture_duration,Browser,GeoSegmentationCountries  

  
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
		  'Download' as Action,
		  omni.MediaViews as TotalActions,
		  Case when DeviceConnected = 0 then 0 else 1 end as FlagOnline,  
		  Isnull(DownloadedFormatType,'NA')StreamedOrDownloadedFormatType,  
		  Lecture_duration,  
		  Omni.GeoSegmentationCountries,  
		  Omni.Browser,
		  Case when Omni.DownloadedCountryCode = 'AU' then 'AU Web'
			   when Omni.DownloadedCountryCode = 'UK' then 'UK Web'
			   when Omni.DownloadedCountryCode = 'US' then 'US Web'
			   else Omni.DownloadedCountryCode
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

		into #DownloadsUSFinal            
		  from #DownloadsUS omni  
		  left join (  select omni.customerid,
							  omni.CourseID,  
							  max(q.StockItemID) as StockItemID , 
							  Min(cast(q.DateOrdered as DATETime)) as DateOrdered , 
							  max(a.MediaTypeID)as MediaTypeID ,MIN(q.OrderID)as OrderID      /*Changed to min to reflect min order date date*/                                   
							  from #DownloadsUS omni (nolock)                 
							  left join DataWarehouse.Marketing.dmpurchaseorderitems (nolock)q                 
							  on omni.CustomerID = q.CustomerID and omni.CourseID= q.CourseID and omni.[date]>=cast(q.DateOrdered as DATE)             
							  inner join staging.InvItem (nolock)a                 
							  on q.StockItemID=a.StockItemID                 
							  where a.MediaTypeID in  ('CD','DownloadA','DownloadV ','DVD','StreamA', 'StreamV','DVDCD','Audio','VHS')         
	           
							  group by omni.customerid,omni.CourseID   
					 )DO   on DO.customerID=omni.customerID and DO.CourseID = omni.CourseID and omni.[date] >= cast(DO.DateOrdered as DATE)             
			left join Marketing.dmpurchaseOrders ord(nolock)               
			on ord.CustomerID=DO.customerID and ord.OrderID = DO.OrderID  


			Delete A from [Archive].[Omni_TGC_Downloads] A
			join #DownloadsUSFinal S
			on A.ActionDate = S.ActionDate and A.PlatForm = S.PlatForm


		Insert into [Archive].[Omni_TGC_Downloads]
		(Actiondate,CustomerID,MagentoUserID,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,CourseID,LectureNumber,Action,TotalActions,FlagOnline,StreamedOrDownloadedFormatType,
		Lecture_duration,GeoSegmentationCountries,BrowserOrAppVersion,Platform,FormatPurchased,orderid,StockItemID,BillingCountryCode,DateOrdered,TransactionType) 

		select  Actiondate,CustomerID,MagentoUserID,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,CourseID,LectureNumber,Action,TotalActions,
		FlagOnline,StreamedOrDownloadedFormatType,Lecture_duration,GeoSegmentationCountries,Browser as [BrowserOrAppVersion] ,Platform,FormatPurchased,orderid,StockItemID,BillingCountryCode,DateOrdered,TransactionType
		from #DownloadsUSFinal          
          
 END          
          
          
          
End
GO
