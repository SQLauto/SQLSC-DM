SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE Proc [dbo].[sp_omni_streaming_archive]            
as            
            
begin            
          
/*UpStaging.Temp_epc_preference missing Customerid's from Userid*/          
update omni          
set omni.customerID = webuser.customerID           
--select distinct webuser.customerID,webuser.userID            
from staging.Omni_Streaming_DataLoad omni (nolock)            
left join          
(            
select distinct u.web_user_id as userID,Dax_Customer_ID as customerID          
from MagentoImports.dbo.Email_Customer_Information u          
--join DataWarehouse.Marketing.CampaignCustomerSignature c            
--on c.CustomerID=u.dax_customer_id          
) webuser           
on omni.userid  = webuser.userID          
WHERE omni.userid IS NOT NULL   /*Data Issue with null values*/        
AND webuser.customerID <>''          
and webuser.userID<>''          
--group by webuser.customerID,webuser.userID            
          
          
/*Grouping for data consistency*/            
select  cast([date] as DATE) [DATE],        
            case when isnull(cust.JSMERGEDROOT,'') <> '' then cust.JSMERGEDROOT        
            else omni.customerID end as CustomerID,        
            omni.Userid,        
            courseid,         
            lecture_number,       
            media_type,       
            transaction_type,        
            platform,        
            device ,        
            action,        
            sum(cast(total_actions as int)) as total_actions,         
            SUM( cast(replace(replace(stream_seconds,' ',''),CHAR(13),'') as float)) as stream_seconds ,        
            MIN([Medianame]) as [Medianame],        
            omni.Country as StreamedWebsite,            
            case when isnull(cust.JSMERGEDROOT,'') <> '' then omni.customerID        
            else null end as [PrevCustomerID],        
            case when isnull(cust.JSMERGEDROOT,'') <> '' then cast('' as varchar(200))        
            else cast(null as varchar(200)) end as  [PrevUserID],        
            SUM( cast(case when patindex('%[a-z]%', omni.Video_Length)> 0 then 1 end as float)) as VideoLength        
into #temp          
from staging.Omni_Streaming_DataLoad omni          
join DAXImports..CustomerExport Cust on omni.CustomerID = Cust.Customerid            
where omni.customerID <> ''         
group by cast([date] as DATE),omni.customerid,userid,courseid, lecture_number,media_type,transaction_type,platform,device ,action,cust.JSMERGEDROOT,omni.Country        
        
      
/* Downloads data with streaming seconds FIX */      
    
update #temp    
set stream_seconds = 0    
where action = 'Download'    
    
    
       
/*Update missing PrevUserid and Userid from Userid-CustomerID mapping*/          
        
update omni          
set omni.[PrevUserID] = omni.[UserID],        
 omni.[UserID] = webuser.[userID]           
--select distinct webuser.customerID,webuser.userID ,omni.userid   ,OMNI.customerID,webuser.customerID        
from #temp omni (nolock)            
left join          
(            
select distinct u.web_user_id as userID,Dax_Customer_ID as customerID          
from MagentoImports.dbo.Email_Customer_Information u--DataWarehouse.dbo.AllMagentoEmailFromMarkL_20150312 u          
--join DataWarehouse.Marketing.CampaignCustomerSignature c            
--on c.CustomerID=u.dax_customer_id          
) webuser           
on omni.CustomerID  = webuser.customerID          
WHERE omni.PrevCustomerID IS NOT NULL   /*Data Issue with null values*/        
--AND isnull(webuser.userID,'') <> ''         
        
        
        
--select * from #temp WHERE PrevCustomerID IS NOT NULL          
        
insert into [Staging].[TempDigitalConsumptionHistory]        
(StreamingDate,CustomerID,MagentoUserID,CourseID,LectureNumber,AudioVideo,FormatPurchased,SubjectCategory2,TransactionType,        
[Platform],Device,Action,TotalActions,StreamSeconds,VideoLength,OrderID,StockItemID,BillingCountryCode,DateOrdered,StreamedWebsite,PrevCustomerID,PrevMagentoUserID)        
select            
cast([Date] as date) Streamingdate,            
omni.CustomerID,         
omni.UserID as MagentoUserID,            
omni.CourseID,            
omni.lecture_number as LectureNumber,           
case when do.MediaTypeID in ('Audio','CD','DownloadA') then 'Audio'        
     when do.MediaTypeID in ('VHS','DVD','DownloadV') then 'Video'        
     else isnull(Omni.media_type,'Unknown') end as [AudioVideo],        
do.MediaTypeID as FormatPurchased ,           
do.[SubjectCategory2],         
[Transaction_type] ,            
[Platform] ,            
case when device = 'Other' then 'Desktop'        
      else device end as [Device],            
[Action] ,            
case when stream_seconds like '%e%' then 1 else total_actions end as total_actions ,      /*Streaming seconds in scientific format*/      
case when stream_seconds like '%e%' then Omni.VideoLength else stream_seconds end as stream_seconds,  /*Streaming seconds in scientific format*/      
Omni.VideoLength,            
do.orderid ,            
do.StockItemID,            
coalesce(cast(ord.BillingCountryCode as char(2)),ccs.countrycode) as BillingCountryCode,        
DO.[DateOrdered],        
omni.[StreamedWebsite],        
omni.[PrevCustomerID],        
omni.[PrevUserid] as PrevMagentoUserID        
          
from #temp omni (nolock)        
left join Marketing.CampaignCustomerSignature ccs (nolock)            
on omni.customerID = ccs.CustomerID            
left join             
(            
   select omni.customerid,omni.CourseID,        
              max(q.StockItemID) as StockItemID ,        
              Min(cast(q.DateOrdered as DATETime)) as DateOrdered ,        
              max(a.MediaTypeID)as MediaTypeID ,        
              MIN(q.OrderID)as OrderID ,     /*Changed to min to reflect min order date date*/    
              max(SubjectCategory2) as SubjectCategory2        
        
   from #temp omni (nolock)            
   left join DataWarehouse.Marketing.dmpurchaseorderitems (nolock)q            
   on omni.CustomerID = q.CustomerID and omni.CourseID= q.CourseID and omni.[date]>=cast(q.DateOrdered as DATE)        
   inner join staging.InvItem (nolock)a            
   on q.StockItemID=a.StockItemID            
   where a.MediaTypeID in  ('CD','DownloadA','DownloadV ','DVD','StreamA', 'StreamV','DVDCD','Audio','VHS')            
   group by omni.customerid,omni.CourseID           
)DO            
on DO.customerID=omni.customerID and DO.CourseID = omni.CourseID and omni.[date] >= cast(DO.DateOrdered as DATE)           
left join Marketing.dmpurchaseOrders ord(nolock)             
on ord.CustomerID=DO.customerID and ord.OrderID = DO.OrderID            
            
        
  update omni        
  set [AudioVideo] =      case when do.MediaTypeID in ('Audio','CD','DownloadA') then 'Audio'        
                               when do.MediaTypeID in ('VHS','DVD','DownloadV') then 'Video'        
                          else isnull(omni.[AudioVideo],'Unknown') end,        
   FormatPurchased = do.MediaTypeID,           
   SubjectCategory2 = do.[SubjectCategory2],         
   orderid = do.orderid ,            
   StockItemID = do.StockItemID,            
   BillingCountryCode = coalesce(cast(ord.BillingCountryCode as char(2)),ccs.countrycode),        
   [DateOrdered]= DO.[DateOrdered]        
  from [Staging].[TempDigitalConsumptionHistory] omni (nolock)        
  left join Marketing.CampaignCustomerSignature ccs (nolock)            
  on omni.customerID = ccs.CustomerID            
  left join             
  (            
     select omni.customerid,q.CourseID,        
   max(q.StockItemID) as StockItemID ,        
   Min(cast(q.DateOrdered as DATETime)) as DateOrdered ,        
   max(a.MediaTypeID)as MediaTypeID ,        
   MIN(q.OrderID)as OrderID ,    /*Changed to min to reflect min order date date*/    
   max(q.SubjectCategory2) as SubjectCategory2        
     from [Staging].[TempDigitalConsumptionHistory] omni             
     left join DataWarehouse.Marketing.dmpurchaseorderitems (nolock)q            
     on omni.CustomerID = q.CustomerID         
     and case when omni.CourseID in(6101,6102,6103,6104,6105) then 6100 else omni.CourseID end = q.CourseID         
     and omni.[Streamingdate]>=cast(q.DateOrdered as DATE)        
     inner join staging.InvItem (nolock)a            
     on q.StockItemID=a.StockItemID            
     where a.MediaTypeID in  ('CD','DownloadA','DownloadV ','DVD','StreamA', 'StreamV','DVDCD','VHS','Audio')            
     group by omni.customerid,q.CourseID           
  )DO            
  on DO.customerID=omni.customerID         
  and DO.CourseID = case when omni.CourseID in(6101,6102,6103,6104,6105) then 6100 else omni.CourseID end        
  and omni.[Streamingdate] >= cast(DO.DateOrdered as DATE)          
  left join Marketing.dmpurchaseOrders ord(nolock)             
  on ord.CustomerID=DO.customerID and ord.OrderID = DO.OrderID            
  where omni.CourseID in(6101,6102,6103,6104,6105)  --Previously not updated due to bundling issue        
  and omni.orderid is null --Previously not updated due to bundling issue        
  and do.OrderID is not null        
  
  
/*Insert into final table*/  
            
Insert into [Archive].[DigitalConsumptionHistory]   
( StreamingDate, CustomerID, CourseID, LectureNumber, AudioVideo, FormatPurchased, SubjectCategory2  
, TransactionType, Platform, Device, Action, TotalActions, StreamSeconds, OrderID, StockItemID, BillingCountryCode, DateOrdered  
, StreamedWebsite, PrevCustomerID, MagentoUserID, VideoLength, PrevMagentoUserID)  
select * from [Staging].[TempDigitalConsumptionHistory]   
  
truncate table [Staging].[TempDigitalConsumptionHistory]   
drop table #temp     
            
end        
GO
