SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE Proc [Staging].[SP_Load_Snag_Film_1]
as

Begin


--Create table Datawarehouse.archive.TGCPlus_Film
--(
--id					bigint  NOT Null,
--version					bigint Null,
--android_poster_image_url					varchar(255)  Null,
--cue_points					varchar(255)  Null,
--description					varchar(8000)  Null,
--film_type					varchar(1000)  Null,
--geo_restrictions					varchar(255)  Null,
--imdb_id					varchar(255)  Null,
--log_line					varchar(5000)  Null,
--poster_image_url					varchar(255)  Null,
--rating					varchar(255)  Null,
--release_date					datetime  Null,
--runtime					bigint  Null,
--season_id					bigint  Null,
--seo_title					varchar(255)  Null,
--show_id					bigint  Null,
--status					varchar(255)  Null,
--thumbnail_url					varchar(255)  Null,
--title					varchar(255)  Null,
--tmdb_id					varchar(255)  Null,
--video_image_url					varchar(255)  Null,
--widget_image_url					varchar(255)  Null,
--year					varchar(255)  Null,
--site_id					bigint  Null,
--uuid					varchar(255)  Null,
--update_date					datetime  Null,
--primary_category_id					int  NOT Null,
--LastupdatedDate datetime not null default(getdate())
--)

/*********************Load into Clean table*********************/

Truncate table Datawarehouse.archive.TGCPlus_Film_1

insert into Datawarehouse.archive.TGCPlus_Film_1
 (   id,version,android_poster_image_url,cue_points,description,film_type,geo_restrictions,imdb_id,log_line,poster_image_url,rating,release_date,runtime
,season_id,seo_title,show_id,status,thumbnail_url,title,tmdb_id,video_image_url,widget_image_url,year,site_id,uuid,update_date,primary_category_id,episode_number 
)

select    id,case when version is null or version = 'Null' then null else Cast(version as bigint) end as version,android_poster_image_url,cue_points
,description,film_type,geo_restrictions,imdb_id,log_line,poster_image_url,rating
,case when release_date is null or release_date = 'Null' then null else Cast(release_date as datetime) end as release_date
,case when runtime is null or runtime = 'Null' then null else Cast(runtime as bigint) end as runtime
,case when season_id is null or season_id = 'Null' then null else Cast(season_id as bigint) end as season_id
,seo_title,case when show_id is null or show_id = 'Null' then null else Cast(show_id as bigint) end as show_id
,status,thumbnail_url,title,tmdb_id,video_image_url,widget_image_url,year
,case when site_id is null or site_id = 'Null' then null else Cast(site_id as bigint) end as site_id,uuid
,case when update_date is null or update_date = 'Null' then null else Cast(update_date as datetime) end as update_date,primary_category_id
,case when episode_number is null or episode_number = 'Null' then null else Cast(episode_number as int) end as episode_number
from  Datawarehouse.staging.Snag_ssis_Film

 
End 


    
    



GO
