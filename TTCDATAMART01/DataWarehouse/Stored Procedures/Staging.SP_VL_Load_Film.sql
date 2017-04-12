SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


      
CREATE Proc [Staging].[SP_VL_Load_Film]      
as      
Begin      
      

/*Update Previous Counts*/
exec SP_TGCPlus_UpdatePreviousCounts @TGCPlusTableName = 'TGCPlus_FILM'
       
/*Truncate and Load */      
--Truncate table [Archive].[TGCPlus_Film]      

Delete A from [Archive].[TGCPlus_Film] A  
inner join [Staging].VL_ssis_Film  S  
on a.id = s.id  
  
      
insert into [Archive].[TGCPlus_Film]      
(id,version,android_poster_image_url,cue_points,film_type,geo_restrictions,imdb_id,log_line,poster_image_url,rating,release_date,runtime,season_id,seo_title      
,show_id,status,thumbnail_url,title,tmdb_id,video_image_url,widget_image_url,year,site_id,uuid,update_date,genre,episode_number ,seriestitle,Course_id,custvidmeta1,custvidmeta2      
,custvidmeta3,custvidmeta4,custvidmeta5,DMLastUpdateESTDateTime)      

select distinct id,cast(version as bigint)version,android_poster_image_url,cue_points,film_type,geo_restrictions,imdb_id,log_line,poster_image_url,rating,      
cast(release_date as datetime) release_date ,cast(runtime as Bigint)runtime,cast(season_id as Bigint)season_id,seo_title      
,cast(show_id as BigInt) show_id,status,thumbnail_url,ltrim(rtrim(title)),tmdb_id,video_image_url,widget_image_url,year,cast(site_id as Bigint) site_id,uuid      
,Cast(update_date as DateTime) update_date,genre,episode_number ,ltrim(rtrim(seriestitle)),Course_id,custvidmeta1,custvidmeta2      
,custvidmeta3,custvidmeta4,custvidmeta5, GETDATE() as DMLastUpdateESTDateTime       
from [Staging].VL_ssis_Film      
      

update  Archive.TGCPlus_Film
set film_type = case when course_id > 0 
					 then 'Episode'       
					 when isnull(course_id,'0') = 0 
					 then 'Trailer'     
				END 


update  Archive.TGCPlus_Film
set genre =  case when  genre like '%History%' and genre not like '%Philosophy%'  then 'History'
							when  genre like '%Economics & Finance%' then 'Economics & Finance'
							when  genre like '%Food & Wine%' then 'Food & Wine'
							when  genre like '%Health, Fitness & Nutrition%' then 'Health, Fitness & Nutrition'
							when  genre like '%Hobby & Leisure%' then 'Hobby & Leisure'
							when  genre like '%Literature & Language%' then 'Literature & Language'
							when  genre like '%Mathematics%' then 'Mathematics'
							when  genre like '%Science%' then 'Science'
							when  genre like '%Philosophy%Religion%' then 'Philosophy, Religion & Intellectual History'
							when  genre like '%Science%' then 'Science'
							when genre like '%Travel%' then 'Travel'
							when genre like '%Professional%' then 'Professional'
							when genre like '%Music & Fine Art%' then 'Music & Fine Art'								
							when genre like '%Health%Fitness%Nutrition%' then 'Health, Fitness & Nutrition'
						 else genre end
    

/*Update Counts*/
exec SP_TGCPlus_UpdateCurrentCounts @TGCPlusTableName = 'TGCPlus_FILM'
      
END      



GO
