SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [Staging].[SP_VL_Load_VideoEvents]     
as    
Begin    


/*Update Previous Counts*/
exec SP_TGCPlus_UpdatePreviousCounts @TGCPlusTableName = 'TGCPlus_VideoEvents'


/*Update Staging Table to remove Text qualifier*/

Update [Staging].[VL_ssis_VideoEvents]
set
aid = Replace( aid , '"' ,'' ), 
apod = Replace( apod , '"' ,'' ), 
apos = Replace( apos , '"' ,'' ), 
cid = Replace( cid , '"' ,'' ), 
cityname = Replace( cityname , '"' ,'' ), 
continent = Replace( continent , '"' ,'' ), 
countryisocode = Replace( countryisocode , '"' ,'' ), 
countryname = Replace( countryname , '"' ,'' ), 
dp1 = Replace( dp1 , '"' ,'' ), 
dp2 = Replace( dp2 , '"' ,'' ), 
dp3 = Replace( dp3 , '"' ,'' ), 
dp4 = Replace( dp4 , '"' ,'' ), 
dp5 = Replace( dp5 , '"' ,'' ), 
latitude = Replace( latitude , '"' ,'' ), 
longitude = Replace( longitude , '"' ,'' ), 
origip = Replace( origip , '"' ,'' ), 
pa = cast(Replace( pa , '"' ,'' ) as varchar(25)), 
pfm = Replace( pfm , '"' ,'' ), 
ref = Replace( ref , '"' ,'' ), 
subdivision1 = Replace( subdivision1 , '"' ,'' ), 
subdivision2 = Replace( subdivision2 , '"' ,'' ), 
subdivision3 = Replace( subdivision3 , '"' ,'' ), 
timezone = Replace( timezone , '"' ,'' ), 
tstamp = Replace( tstamp , '"' ,'' ), 
uid = Replace( uid , '"' ,'' ), 
uip = Replace( uip , '"' ,'' ), 
url = Replace( url , '"' ,'' ), 
useragent = Replace( useragent , '"' ,'' ), 
vid = Replace( vid , '"' ,'' ), 
vpos = Replace( vpos , '"' ,'' )

    
/*Truncate and Load */    
--Truncate table [Archive].[TGCPlus_VideoEvents]     

Print 'Deleted video events for below dates'  
select cast(tstamp as date) from Datawarehouse.staging.VL_ssis_VideoEvents group by cast(tstamp as date)

/* removed due to Download on device and stream later data */
delete from  Datawarehouse.archive.TGCPlus_VideoEvents    
where cast(tstamp as date) in (select cast(tstamp as date) from Datawarehouse.staging.VL_ssis_VideoEvents group by cast(tstamp as date))    
    
Print 'Inserting'  
insert into [Archive].TGCPlus_VideoEvents     
( aid,cid,pfm,vid,uid,origip,tstamp,useragent,ref,url,pa,vpos,apos,apod,dp1,dp2,dp3,dp4,dp5,continent,countryname,countryisocode,cityname,latitude    
,longitude,timezone,subdivision1,subdivision2,subdivision3,uip    
,DMLastUpdateESTDateTime)    
    
select     
aid,cid,pfm,vid,uid,origip,Cast(tstamp as DateTime) tstamp,useragent,ref,url,pa,Cast(vpos as BigInt)vpos,Cast(apos as BigInt)apos,apod,dp1,dp2,dp3,dp4,dp5    
,continent,countryname,countryisocode,cityname,Cast(latitude as Real) latitude,Cast(longitude as Real) longitude,timezone,subdivision1,subdivision2,subdivision3,uip    
,GETDATE() as DMLastUpdateESTDateTime     
from [Staging].VL_ssis_VideoEvents     
  
  

/*Update Counts*/
exec SP_TGCPlus_UpdateCurrentCounts @TGCPlusTableName = 'TGCPlus_VideoEvents'
 
    
END  




GO
