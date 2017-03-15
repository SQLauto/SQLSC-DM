SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[SP_Amazon_Load_Streaming]
as
Begin

/* Only Inserting Values*/


delete a from Archive.Amazon_streaming a
join staging.Amazon_ssis_Streaming s
on a.partner = S.partner and a.ReportDate = S.ReportDate


 insert into Archive.Amazon_streaming (Partner,CountryCode,ReportDate,vendor_sku,content_type,ReleaseDate,AvailableDate,CourseID,series_or_movie_title,season_number,episode_number,episode_name,total_number_of_streams,total_number_of_minutes_streamed,Average_minutes_streamed)
 select  Partner,CountryCode,ReportDate,vendor_sku,content_type,ReleaseDate,AvailableDate,CourseID,series_or_movie_title,season_number,episode_number,episode_name,total_number_of_streams,total_number_of_minutes_streamed,Average_minutes_streamed
 from staging.Amazon_ssis_Streaming

 
End
GO
