SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

    
    
CREATE Proc [Staging].[SP_VL_Load_Film_20160325]    
as    
Begin    
    
     
/*Truncate and Load */    
Truncate table [Archive].[TGCPlus_Film]    
    
insert into [Archive].[TGCPlus_Film]    
(id,version,android_poster_image_url,cue_points,film_type,geo_restrictions,imdb_id,log_line,poster_image_url,rating,release_date,runtime,season_id,seo_title    
,show_id,status,thumbnail_url,title,tmdb_id,video_image_url,widget_image_url,year,site_id,uuid,update_date,genre,episode_number ,seriestitle,Course_id,custvidmeta1,custvidmeta2    
,custvidmeta3,custvidmeta4,custvidmeta5,DMLastUpdateESTDateTime)    
    
select id,cast(version as bigint)version,android_poster_image_url,cue_points,film_type,geo_restrictions,imdb_id,log_line,poster_image_url,rating,    
cast(release_date as datetime) release_date ,cast(runtime as Bigint)runtime,cast(season_id as Bigint)season_id,seo_title    
,cast(show_id as BigInt) show_id,status,thumbnail_url,ltrim(rtrim(title)),tmdb_id,video_image_url,widget_image_url,year,cast(site_id as Bigint) site_id,uuid    
,Cast(update_date as DateTime) update_date,genre,episode_number ,ltrim(rtrim(seriestitle)),Course_id,custvidmeta1,custvidmeta2    
,custvidmeta3,custvidmeta4,custvidmeta5, GETDATE() as DMLastUpdateESTDateTime     
from [Staging].VL_ssis_Film    
    
    
END    
  
  
  

GO
