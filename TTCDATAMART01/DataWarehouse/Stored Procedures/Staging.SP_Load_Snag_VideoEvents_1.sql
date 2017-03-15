SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE Proc [Staging].[SP_Load_Snag_VideoEvents_1]
as

Begin


/***************** Data cleanup and Load to Final Table. ***************** */

--Create table Datawarehouse.archive.TGCPlus_VideoEvents_1
--(
--aid varchar	(256) Null,
--cid	varchar	(256) Null,
--pfm	varchar	(256) Null,
--vid	varchar	(256) Null,
--uid	varchar	(256) Null,
--origip	varchar	(256) Null,
--tstamp	Datetime Null,
--useragent varchar (256)	Null,
--ref	varchar	(1024) Null,
--url	varchar	(1024) Null,
--pa	varchar	(25) Null,
--vpos	int	Null,
--apos	int	Null,
--apod	varchar	(256) Null,
--dp1	varchar	(1024)	Null,
--dp2	varchar	(1024)	Null,
--dp3	varchar	(1024)	Null,
--dp4	varchar	(1024)	Null,
--dp5	varchar	(1024)	Null,
--continent	varchar	(128)	Null,
--countryname	varchar	(128)	Null,
--countryisocode	varchar	(128)	Null,
--cityname	varchar	(128)	Null,
--latitude	Real Null,
--longitude	Real Null,
--timezone	varchar	(256)	Null,
--subdivision1	varchar	(256)	Null,
--subdivision2	varchar	(256)	Null,
--subdivision3	varchar	(256)	Null,
--uip				varchar	(256)	Null,
--LastupdatedDate datetime not null default(getdate())
--) 


/*********************Load into Clean table*********************/


delete from  Datawarehouse.archive.TGCPlus_VideoEvents_1
where tstamp >= (select cast(MIN(tstamp) as date) from Datawarehouse.staging.Snag_ssis_VideoEvents )


insert into Datawarehouse.archive.TGCPlus_VideoEvents_1
(aid,cid ,pfm,vid,uid,origip,tstamp,useragent,ref,url,pa,vpos,apos,apod,dp1,dp2,dp3,dp4,dp5,continent,countryname,countryisocode,cityname,
latitude,longitude,timezone,subdivision1,subdivision2,subdivision3,uip)

select 
aid,cid ,pfm,vid,uid,origip,case when tstamp is null then null else CAST(tstamp as datetime) end as tstamp,useragent,ref,url,pa
,case when vpos is null then null else cast(vpos as int ) end as vpos,
case when apos is null then null else cast(apos as int) end as apos,
apod,dp1,dp2,dp3,dp4,dp5,continent,countryname,countryisocode,cityname,
case when latitude is null then null else cast(latitude as real) end as latitude,
case when longitude is null then null else cast(longitude as real) end as longitude,timezone,subdivision1,subdivision2,subdivision3,uip
from  Datawarehouse.staging.Snag_ssis_VideoEvents

End 

 



GO
