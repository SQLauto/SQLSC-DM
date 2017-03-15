SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE Proc [Staging].[SP_Load_Snag_Series_1]
as

Begin

--Create table Datawarehouse.archive.TGCPlus_Series
--(
--id	 bigint  NOT Null,
--version	 bigint  Null,
--description	 varchar(5000)  Null,
--title	 varchar(255)  Null,
--site_id	 bigint  Null,
--banner_image 	varchar(255)  Null,
--mobile_image 	varchar(255)  Null,
--poster_image 	varchar(255)  Null,
--uuid	 	varchar(255)  Null,
--video_image	 	varchar(255)  Null,
--update_date	 	datetime  Null,
--LastupdatedDate datetime not null default(getdate())
--)

/*********************Load into Clean table*********************/

Truncate table Datawarehouse.archive.TGCPlus_Series

insert into Datawarehouse.archive.TGCPlus_Series
 (  id,version,description,title,site_id,banner_image,mobile_image,poster_image,uuid,video_image,update_date,course_id )

select    id,case when version is null or version = 'Null' then null else Cast(version as bigint) end as version,description
,title, case when site_id is null or site_id = 'Null' then null else Cast(site_id as bigint) end as site_id
,banner_image,mobile_image,poster_image,uuid,video_image
,case when update_date is null or update_date = 'Null' then null else Cast(update_date as datetime) end as update_date
,case when course_id is null or course_id = 'Null' then null else Cast(course_id as bigint) end as course_id
from  Datawarehouse.staging.Snag_ssis_Series
 
End 


GO
