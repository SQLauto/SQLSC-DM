SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


    
CREATE Proc [dbo].[sp_omni_streaming_archive_oldBKP]    
as    
    
begin    
  
  
update omni  
set omni.customerID = webuser.customerID   
--select distinct webuser.customerID,webuser.userID    
from staging.Omni_Streaming_DataLoad omni (nolock)    
left join  
(    
select distinct u.web_user_id as userID,c.CustomerID as customerID  
from MagentoImports.dbo.Magento_ImportWebAccounts_Final u  
join DataWarehouse.Marketing.CampaignCustomerSignature c    
on c.CustomerID=u.dax_customer_id  
) webuser   
on omni.userid  = webuser.userID  
WHERE omni.userid IS NOT NULL   /*Data Issue with null values*/
AND OMNI.customerID<>webuser.customerID  
AND OMNI.customerID=''  
AND webuser.userID IS NOT NULL   
and webuser.userID<>''  
--group by webuser.customerID,webuser.userID    
  
  
--select  customerid, userid,date,courseid,lecture_number,platform,device ,COUNT(*)  
--from staging.Omni_Streaming_DataLoad omni  
--group by customerid, userid,date,courseid,lecture_number,platform,device   
--having COUNT(*)>1  
  
/*  
select * from staging.Omni_Streaming_DataLoad omni  
where customerid=42484417 and userid='003d3872-ea1c-4ad1-a774-fa8e5da6055e' and date='December 25, 2013'  
and CourseID=4123  
*/
  
select  [date],
		case when isnull(cust.JSMERGEDROOT,'') <> '' then cust.JSMERGEDROOT
		else omni.customerID end as CustomerID,
		courseid, 
		lecture_number,
		transaction_type,
		platform,
		device ,
		action,
		sum(cast(total_actions as int)) as total_actions, 
		SUM( cast(stream_seconds as float)) as stream_seconds ,
		MIN([Medianame]) as [Medianame],
		'' as [StreamedWebsite],
		case when isnull(cust.JSMERGEDROOT,'') <> '' then omni.customerID
		else null end as [PrevCustomerID]  
into #temp  
from staging.Omni_Streaming_DataLoad omni  
join DAXImports..CustomerExport Cust on omni.CustomerID = Cust.Customerid    
where omni.customerID <> '' and omni.transaction_type<>'' and total_actions > 0    
group by [date],omni.customerid,courseid, lecture_number,transaction_type,platform,device ,action,cust.JSMERGEDROOT


--insert into archive.Omni_Streaming_history

insert into [Archive].[DigitalConsumptionHistory]

select    
cast([date] as date) Streamingdate,    
omni.CustomerID, 
--omni.userid,    
omni.courseid,    
omni.lecture_number,   
case when do.MediaTypeID in ('CD','DownloadA') then 'Audio'
     when do.MediaTypeID in ('DVD','DownloadV') then 'Video'
     else 'Unknown' end as [AudioVideo],
do.MediaTypeID as FormatPurchased ,   
do.[SubjectCategory2], 
[transaction_type] ,    
[platform] ,    
case when device = 'Other' then 'Desktop'
	 else device end as [device],    
[action] ,    
total_actions ,    
stream_seconds,    
do.orderid ,    
do.StockItemID,    
coalesce(cast(ord.BillingCountryCode as char(2)),ccs.countrycode) as BillingCountryCode,
DO.[DateOrdered],
omni.[StreamedWebsite],
omni.[PrevCustomerID]    
from #temp omni (nolock)
left join Marketing.CampaignCustomerSignature ccs (nolock)    
on omni.customerID = ccs.CustomerID    
left join     
(    
   select omni.customerid,omni.CourseID,
		  max(q.StockItemID) as StockItemID ,
		  MAX(cast(q.DateOrdered as DATE)) as DateOrdered ,
		  max(a.MediaTypeID)as MediaTypeID ,
		  max(q.OrderID)as OrderID ,
		  max(SubjectCategory2) as SubjectCategory2

   from #temp omni (nolock)    
   left join DataWarehouse.Marketing.dmpurchaseorderitems (nolock)q    
   on omni.CustomerID = q.CustomerID and omni.CourseID= q.CourseID and omni.[date]>=cast(q.DateOrdered as DATE)
   inner join staging.InvItem (nolock)a    
   on q.StockItemID=a.StockItemID    
   where a.MediaTypeID in  ('CD','DownloadA','DownloadV ','DVD','StreamA', 'StreamV','DVDCD')    
   group by omni.customerid,omni.CourseID   
)DO    
on DO.customerID=omni.customerID and DO.CourseID = omni.CourseID and omni.[date] >= DO.DateOrdered  
left join Marketing.dmpurchaseOrders ord(nolock)     
on ord.CustomerID=DO.customerID and ord.OrderID = DO.OrderID    
    



	update omni

	set [AudioVideo] =	case when do.MediaTypeID in ('CD','DownloadA') then 'Audio'
						     when do.MediaTypeID in ('DVD','DownloadV') then 'Video'
							 else 'Unknown' end,
			FormatPurchased = do.MediaTypeID,   
			SubjectCategory2 = do.[SubjectCategory2], 
			orderid = do.orderid ,    
			StockItemID = do.StockItemID,    
			BillingCountryCode = coalesce(cast(ord.BillingCountryCode as char(2)),ccs.countrycode),
			[DateOrdered]= DO.[DateOrdered]
			
	from [Archive].[DigitalConsumptionHistory] omni (nolock)
	left join Marketing.CampaignCustomerSignature ccs (nolock)    
	on omni.customerID = ccs.CustomerID    
	left join     
	(    
	   select omni.customerid,q.CourseID,
			  max(q.StockItemID) as StockItemID ,
			  MAX(cast(q.DateOrdered as DATE)) as DateOrdered ,
			  max(a.MediaTypeID)as MediaTypeID ,
			  max(q.OrderID)as OrderID ,
			  max(q.SubjectCategory2) as SubjectCategory2
 
	   from [Archive].[DigitalConsumptionHistory] omni     
	   left join DataWarehouse.Marketing.dmpurchaseorderitems (nolock)q    
	   on omni.CustomerID = q.CustomerID 
	   and case when omni.CourseID in(6101,6102,6103,6104,6105) then 6100 else omni.CourseID end = q.CourseID 
	   and omni.[Streamingdate]>=cast(q.DateOrdered as DATE)
	   inner join staging.InvItem (nolock)a    
	   on q.StockItemID=a.StockItemID    
	   where a.MediaTypeID in  ('CD','DownloadA','DownloadV ','DVD','StreamA', 'StreamV','DVDCD')    
	   group by omni.customerid,q.CourseID   
	)DO    
	on DO.customerID=omni.customerID 
	and DO.CourseID = case when omni.CourseID in(6101,6102,6103,6104,6105) then 6100 else omni.CourseID end
	and omni.[Streamingdate] >= DO.DateOrdered  
	left join Marketing.dmpurchaseOrders ord(nolock)     
	on ord.CustomerID=DO.customerID and ord.OrderID = DO.OrderID    
	where omni.CourseID in(6101,6102,6103,6104,6105)  --Previously not updated due to bundling issue
	and omni.orderid is null --Previously not updated due to bundling issue
	and do.OrderID is not null
    
drop table #temp    
    
end    
 
/*    
select COUNT(*) from staging.Omni_Streaming_DataLoad omni (nolock)   where 
*/


    
/*  
select webuser.*,omni.* from staging.Omni_Streaming_DataLoad omni (nolock)    
left join  
(    
select distinct u.web_user_id as userID,c.CustomerID as customerID  
from MagentoImports.dbo.Magento_ImportWebAccounts_Final u  
join DataWarehouse.Marketing.CampaignCustomerSignature c  on c.CustomerID=u.dax_customer_id  
) webuser   
on omni.userid  = webuser.userID  
  
  
select userid,CAST(userid as varbinary) from staging.Omni_Streaming_DataLoad omni (nolock)    
where Userid =''  
  
select * from staging.Omni_Streaming_DataLoad omni (nolock)    
where omni.userid='bade5ee7-4511-493b-b775-3593b6f85bcf'  
  
select distinct u.web_user_id as userID,c.CustomerID as customerID  
from MagentoImports.dbo.Magento_ImportWebAccounts_Final u  
join DataWarehouse.Marketing.CampaignCustomerSignature c    
on c.CustomerID=u.dax_customer_id  
where u.web_user_id ='bade5ee7-4511-493b-b775-3593b6f85bcf'  
  
  
  
select webuser.customerID,webuser.userID    
from staging.Omni_Streaming_DataLoad omni (nolock)    
left join  
(    
select distinct u.web_user_id as userID,c.CustomerID as customerID  
from MagentoImports.dbo.Magento_ImportWebAccounts_Final u  
join DataWarehouse.Marketing.CampaignCustomerSignature c  on c.CustomerID=u.dax_customer_id  
) webuser   
on omni.userid  = webuser.userID  
WHERE omni.userid IS NOT NULL   
AND OMNI.customerID<>webuser.customerID  
AND OMNI.customerID=''  
AND webuser.userID IS NOT NULL   
and webuser.userID<>''  
group by webuser.customerID,webuser.userID    
  
  
(select distinct u.web_user_id as userID,c.CustomerID as customerID  
from MagentoImports.dbo.Magento_ImportWebAccounts_Final u  
join DataWarehouse.Marketing.CampaignCustomerSignature c    
on c.CustomerID=u.dax_customer_id  
where c.CustomerID is not null and c.CustomerID<>''  
)  
  
--select  * from MagentoImports.dbo.Magento_ImportWebAccounts_Final u  
  
  
--alter table Archive.Omni_Streaming_history add userid varchar(200)  
  
select * from Archive.Omni_Streaming_history  
  
--alter table  staging.Omni_Streaming_DataLoad add medianame varchar(50)  
  
  
select  customerid, userid,date,courseid,lecture_number,transaction_type,platform,device ,action,sum(cast(total_actions as int)) as total_actions, SUM( cast(stream_seconds as float)) as stream_seconds  
into #temp  
from staging.Omni_Streaming_DataLoad omni  
group by customerid, userid,date,courseid,lecture_number,transaction_type,platform,device ,action  
  
  
  
select  customerid,date,courseid,lecture_number,transaction_type,platform,device ,action,sum(cast(total_actions as int)) as total_actions, SUM( cast(stream_seconds as float)) as stream_seconds  
into #temp1  
from staging.Omni_Streaming_DataLoad omni  
group by customerid,date,courseid,lecture_number,transaction_type,platform,device ,action  
  
select customerid  ,date ,courseid ,lecture_number ,transaction_type ,platform ,device ,action ,total_actions ,stream_seconds from #temp  
except  
select customerid  ,date ,courseid ,lecture_number ,transaction_type ,platform ,device ,action ,total_actions ,stream_seconds from #temp1  
  
  
*/


/*
select  customerid, userid,date,courseid,lecture_number,transaction_type,platform,device ,action,sum(cast(total_actions as int)) as total_actions, SUM( cast(stream_seconds as float)) as stream_seconds  
--into #temp  
from staging.Omni_Streaming_DataLoad omni  
group by customerid, userid,date,courseid,lecture_number,transaction_type,platform,device ,action  
 having COUNT(*)>1
 
 
 select 
 [Date]	,customerID,	CourseID,	lecture_number,	media_type,	transaction_type,	platform	,device	,action 	 --,COUNT(*)
 from staging.Omni_Streaming_DataLoad
 group by [Date]	,customerID,	CourseID,	lecture_number,	media_type,	transaction_type,	platform	,device	,action	  
  having COUNT(*)>1
  
  select top 1  [Date]	,customerID,	CourseID,	lecture_number,	media_type,	transaction_type,	platform	,device	,action 	  --,COUNT(*)
 from staging.Omni_Streaming_DataLoad
 
 */
 
 
/*
select * from Archive.Omni_Streaming_history

select    
cast([date] as date) Streamingdate,    
omni.customerID,  
omni.userid,    
omni.courseid,    
omni.lecture_number,    
do.MediaTypeID as media_type ,    
transaction_type ,    
platform ,    
device,    
action ,    
total_actions ,    
stream_seconds,    
do.orderid ,    
do.StockItemID ,    
coalesce(cast(ord.BillingCountryCode as char(2)),ccs.countrycode) as BillingCountryCode    
from staging.Omni_Streaming_DataLoad omni (nolock)    
left join Marketing.CampaignCustomerSignature ccs (nolock)    
on omni.customerID = ccs.CustomerID    
left join     
(    
   select omni.customerid,omni.CourseID,max(q.StockItemID) as StockItemID ,MAX(DateOrdered) as DateOrdered ,max(a.MediaTypeID)as MediaTypeID ,max(q.OrderID)as OrderID    
   from staging.Omni_Streaming_DataLoad omni (nolock)    
   inner join DataWarehouse.Marketing.completecoursepurchase (nolock)q    
   on omni.CustomerID =q.CustomerID and omni.CourseID= q.CourseID    
   inner join staging.InvItem (nolock)a    
   on q.StockItemID=a.StockItemID    
   where a.MediaTypeID in  ('CD','DownloadA','DownloadV ','DVD','StreamA', 'StreamV','DVDCD')    
   group by omni.customerid,omni.CourseID    
)DO    
on DO.customerID=omni.customerID and DO.CourseID = omni.CourseID    
left join Marketing.dmpurchaseOrders ord(nolock)     
on ord.CustomerID=DO.customerID and ord.OrderID = DO.OrderID    
--where omni.customerID <> '' and omni.transaction_type<>'' and total_actions > 0    

*/




GO
