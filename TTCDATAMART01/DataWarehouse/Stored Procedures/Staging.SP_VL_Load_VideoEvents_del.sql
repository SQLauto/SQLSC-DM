SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[SP_VL_Load_VideoEvents_del]     
as    
Begin    
    
/*Truncate and Load */    
--Truncate table [Archive].[TGCPlus_VideoEvents_del]     

Print 'Deleted video events for below dates'  
select cast(tstamp as date) from Datawarehouse.staging.VL_ssis_VideoEvents group by cast(tstamp as date)

delete from  Datawarehouse.archive.TGCPlus_VideoEvents_del    
where cast(tstamp as date) in (select cast(tstamp as date) from Datawarehouse.staging.VL_ssis_VideoEvents group by cast(tstamp as date))    
    
Print 'Inserting'  
insert into [Archive].TGCPlus_VideoEvents_del     
( aid,cid,pfm,vid,uid,origip,tstamp,useragent,ref,url,pa,vpos,apos,apod,dp1,dp2,dp3,dp4,dp5,continent,countryname,countryisocode,cityname,latitude    
,longitude,timezone,subdivision1,subdivision2,subdivision3,uip    
,DMLastUpdateESTDateTime)    
    
select     
aid,cid,pfm,vid,uid,origip,Cast(tstamp as DateTime) tstamp,useragent,ref,url,pa,Cast(vpos as BigInt)vpos,Cast(apos as BigInt)apos,apod,dp1,dp2,dp3,dp4,dp5    
,continent,countryname,countryisocode,cityname,Cast(latitude as Real) latitude,Cast(longitude as Real) longitude,timezone,subdivision1,subdivision2,subdivision3,uip    
,GETDATE() as DMLastUpdateESTDateTime     
from [Staging].VL_ssis_VideoEvents     
  
  
    
END  
GO
