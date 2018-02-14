SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
    
    
CREATE Proc [dbo].[SP_Load_Omni_TGC_App_Downloads]     @AppCode varchar(10)          
as          
          
Begin          
          
if @AppCode  =  'Android'           
          
 Begin          
           
          
    
 select       
   Date,      
   userID,      
   MobileDeviceType,      
   MobileDevice as MobileDevice,      
   US.LectureDownloaded as MediaName,      
   Coalesce(courseid,L.course_id) as  courseid,    
   Coalesce(LectureNum,L.lecture_number) as LectureNumber,      
   'Android' APP,      
 Case when right(LectureDownloaded,4) in ('.mp3','.m4b') then 'Audio'    
  when right(LectureDownloaded,4) in ('.wmv','.m4v') then 'Video'    
  when LectureDownloaded like '%Audio%' then 'Audio'     
  when LectureDownloaded like '%Video%' then 'Video'    
  when LectureDownloaded like 'ZA%' then 'Audio'     
  when LectureDownloaded like 'ZV%' then 'Video'    
  Else 'NA'    
 end as FormatType,      
   L.duration as Lecture_duration,      
   AppId,      
   GeoSegmentationCountries,  
   Allvisits      
 into #omni_TGC_Apps_Downloads_Android    
 from  Staging.omni_TGC_ssis_AndroidDownloads   US    
 left join DataWarehouse.Mapping.MagentoCourseLectureExport   Map    
 on substring(US.LectureDownloaded,1,len(US.LectureDownloaded)-4)  =   Map.MediaName     
   left join (select distinct Course_id,lecture_number,audio_brightcove_id as brightcove_id, audio_duration as duration, 'Audio' as Format    
      from   imports.magento.lectures L    
      left join Imports.magento.catalog_product_entity E     
      on L.product_id = E.entity_id    
      where default_course_number is NULL and audio_brightcove_id is not NULL    
      union     
      select distinct Course_id,lecture_number,video_brightcove_id as brightcove_id, Video_duration as duration, 'Video' as Format    
      from   imports.magento.lectures L    
      left join Imports.magento.catalog_product_entity E     
      on L.product_id = E.entity_id    
      where default_course_number is NULL and video_brightcove_id is not null    
      ) L     
 on l.brightcove_id = us.LectureDownloaded    
   left join imports.magento.lectures Akamai      
   on Akamai.akamai_download_id =  substring(US.LectureDownloaded,1,len(US.LectureDownloaded)-4)        
          
   --Delete data if already loaded for this           
   delete A from  archive.omni_TGC_Apps_Downloads A          
   join #omni_TGC_Apps_Downloads_Android S          
   on A.date = S.date and A.App = S.App          
           
   insert into Archive.omni_TGC_Apps_Downloads          
   (Date,userID,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,App,AppId,DownloadedFormatType,Lecture_duration,GeoSegmentationCountries,Allvisits)          
          
   select Date,userID,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,App,AppId,FormatType,Lecture_duration,GeoSegmentationCountries,Allvisits    
   from #omni_TGC_Apps_Downloads_Android          
          
    
          
 IF OBJECT_ID('tempdb..#omni_TGC_Apps_Downloads_Android') IS NOT NULL          
    DROP TABLE #omni_TGC_Apps_Downloads_Android          
            


/*Update Final table [Archive].[Omni_TGC_Downloads] */  
  
  
	  Declare @AndroidMaxActionDate Date  
	  select  @AndroidMaxActionDate = max(Actiondate)    
	  from [Archive].[Omni_TGC_Downloads]  
	  where platform = 'Android'  
  
	  select @AndroidMaxActionDate = isnull(@AndroidMaxActionDate,'2015/01/01')  
	  select @AndroidMaxActionDate as '@AndroidMaxActionDate'  

		select Map.CustomerID,
		Min(Map.MarketingCloudVisitorID)as MarketingCloudVisitorID,
		Omni.userID,  
		Date,
		MobileDeviceType,
		MobileDevice,
		MediaName,
		courseid,
		LectureNumber,
		1 as DeviceConnected, 
		App, 
		DownloadedFormatType,
		Lecture_duration,
		Appid,
		GeoSegmentationCountries,  
		Sum(Case when Allvisits>= 1 then 1 else 0 end)MediaViews
		into #Android  
		from DataWarehouse.Archive.Omni_TGC_Apps_Downloads omni (nolock)          
		left join (select CustomerID,web_user_id,min(MarketingCloudVisitorID)MarketingCloudVisitorID 
					from DataWarehouse.mapping.Customerid_Userid_MarketingCloudID 
					group by CustomerID,web_user_id
					) Map  
		on Map.web_user_id = Omni.userID  
		where Omni.App = 'Android' and Omni.Date > @AndroidMaxActionDate
		group by Map.CustomerID,Omni.userID,Date,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,App,DownloadedFormatType,Lecture_duration,Appid,GeoSegmentationCountries  
 


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
		  Omni.AppId,
		  App as [Platform],
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


		Delete A from [Archive].[Omni_TGC_Downloads] A  
	    join  #AndroidFinal S  
	    on A.PlatForm = S.PlatForm and A.Actiondate = S.Actiondate  

		Insert into [Archive].[Omni_TGC_Downloads]
		(Actiondate,CustomerID,MagentoUserID,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,CourseID,LectureNumber,Action,TotalActions,FlagOnline,StreamedOrDownloadedFormatType,
		Lecture_duration,GeoSegmentationCountries,BrowserOrAppVersion,Platform,FormatPurchased,orderid,StockItemID,BillingCountryCode,DateOrdered,TransactionType) 

		select  Actiondate,CustomerID,MagentoUserID,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,CourseID,LectureNumber,Action,TotalActions,
		FlagOnline,StreamedOrDownloadedFormatType,Lecture_duration,GeoSegmentationCountries,APPID as [BrowserOrAppVersion] ,Platform,FormatPurchased,orderid,StockItemID,BillingCountryCode,DateOrdered,TransactionType
		from #AndroidFinal

          
 End          
          
           
Else if @AppCode  =  'Ios'           
          
 Begin          
          
     
    
 select       
   Date,      
   userID,      
   MobileDeviceType,      
   MobileDevice as MobileDevice,      
   US.LectureDownloaded as MediaName,      
   Coalesce(courseid,L.course_id) as  courseid,    
   Coalesce(LectureNum,L.lecture_number) as LectureNumber,      
   'IOS' APP,      
 Case when right(LectureDownloaded,4) in ('.mp3','.m4b') then 'Audio'    
  when right(LectureDownloaded,4) in ('.wmv','.m4v') then 'Video'    
  when LectureDownloaded like '%Audio%' then 'Audio'     
  when LectureDownloaded like '%Video%' then 'Video'    
  when LectureDownloaded like 'ZA%' then 'Audio'     
  when LectureDownloaded like 'ZV%' then 'Video'    
  Else 'NA'    
 end as FormatType,      
   L.duration as Lecture_duration,      
   AppId,      
   GeoSegmentationCountries,  
   Allvisits      
 into #omni_TGC_Apps_Downloads_IOS    
 from  Staging.omni_TGC_ssis_IOSDownloads   US    
 left join DataWarehouse.Mapping.MagentoCourseLectureExport   Map    
 on substring(US.LectureDownloaded,1,len(US.LectureDownloaded)-4)  =   Map.MediaName     
   left join (select distinct Course_id,lecture_number,audio_brightcove_id as brightcove_id, audio_duration as duration, 'Audio' as Format    
      from   imports.magento.lectures L    
      left join Imports.magento.catalog_product_entity E     
      on L.product_id = E.entity_id    
      where default_course_number is NULL and audio_brightcove_id is not NULL    
      union     
      select distinct Course_id,lecture_number,video_brightcove_id as brightcove_id, Video_duration as duration, 'Video' as Format    
      from   imports.magento.lectures L    
      left join Imports.magento.catalog_product_entity E     
      on L.product_id = E.entity_id    
      where default_course_number is NULL and video_brightcove_id is not null    
      ) L     
 on l.brightcove_id = us.LectureDownloaded    
   left join imports.magento.lectures Akamai      
   on Akamai.akamai_download_id =  substring(US.LectureDownloaded,1,len(US.LectureDownloaded)-4)        
          
   --Delete data if already loaded for this           
   delete A from  archive.omni_TGC_Apps_Downloads A          
   join #omni_TGC_Apps_Downloads_IOS S          
   on A.date = S.date and A.App = S.App          
           
   insert into Archive.omni_TGC_Apps_Downloads          
   (Date,userID,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,App,AppId,DownloadedFormatType,Lecture_duration,GeoSegmentationCountries,Allvisits)          
          
   select Date,userID,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,App,AppId,FormatType,Lecture_duration,GeoSegmentationCountries ,Allvisits   
   from #omni_TGC_Apps_Downloads_IOS          
              
          
 IF OBJECT_ID('tempdb..#omni_TGC_Apps_Downloads_IOS') IS NOT NULL          
 DROP TABLE #omni_TGC_Apps_Downloads_IOS          
            

/*Update Final table [Archive].[Omni_TGC_Downloads] */  
  
  
	  Declare @IOSMaxActionDate Date  
	  select  @IOSMaxActionDate = max(Actiondate)    
	  from [Archive].[Omni_TGC_Downloads]  
	  where platform = 'IOS'  
  
	  select @IOSMaxActionDate = isnull(@IOSMaxActionDate,'2015/01/01')  
	  select @IOSMaxActionDate as '@IOSMaxActionDate'  

		select Map.CustomerID,
		Min(Map.MarketingCloudVisitorID)as MarketingCloudVisitorID,
		Omni.userID,  
		Date,
		MobileDeviceType,
		MobileDevice,
		MediaName,
		courseid,
		LectureNumber,
		1 as DeviceConnected, 
		App, 
		DownloadedFormatType,
		Lecture_duration,
		Appid,
		GeoSegmentationCountries,  
		Sum(Case when Allvisits>= 1 then 1 else 0 end)MediaViews
		into #IOS  
		from DataWarehouse.Archive.Omni_TGC_Apps_Downloads omni (nolock)          
		left join (select CustomerID,web_user_id,min(MarketingCloudVisitorID)MarketingCloudVisitorID 
					from DataWarehouse.mapping.Customerid_Userid_MarketingCloudID 
					group by CustomerID,web_user_id
					) Map  
		on Map.web_user_id = Omni.userID  
		where Omni.App = 'IOS' and Omni.Date > @IOSMaxActionDate
		group by Map.CustomerID,Omni.userID,Date,MobileDeviceType,MobileDevice,MediaName,courseid,LectureNumber,App,DownloadedFormatType,Lecture_duration,Appid,GeoSegmentationCountries  
 


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
		  Omni.AppId,
		  App as [Platform],
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


		Delete A from [Archive].[Omni_TGC_Downloads] A  
	    join  #IOSFinal S  
	    on A.PlatForm = S.PlatForm and A.Actiondate = S.Actiondate  

		Insert into [Archive].[Omni_TGC_Downloads]
		(Actiondate,CustomerID,MagentoUserID,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,CourseID,LectureNumber,Action,TotalActions,FlagOnline,StreamedOrDownloadedFormatType,
		Lecture_duration,GeoSegmentationCountries,BrowserOrAppVersion,Platform,FormatPurchased,orderid,StockItemID,BillingCountryCode,DateOrdered,TransactionType) 

		select  Actiondate,CustomerID,MagentoUserID,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,CourseID,LectureNumber,Action,TotalActions,
		FlagOnline,StreamedOrDownloadedFormatType,Lecture_duration,GeoSegmentationCountries,APPID as [BrowserOrAppVersion] ,Platform,FormatPurchased,orderid,StockItemID,BillingCountryCode,DateOrdered,TransactionType
		from #IOSFinal
          
 END          
          
                
End    
  
GO
