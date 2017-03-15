SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Mapping].[Vw_TGCPlus_ConsumptionByPlatform]
AS

	select a.pfm as Platform,
		a.useragent as Browser,
		a.countryisocode as CountryCode,
		a.CountryName,
	  case when b.film_type IS null and b.course_id > 0 then 'Episode'       
	  when b.film_type IS null and isnull(b.course_id,'0') = 0 then 'Trailer'      
	  else b.film_type      
	  end as FilmType,     
	  b.genre as SubjectCategory,    
	  Year(a.tstamp) as YearPlayed,      
	  Month(a.tstamp) as MonthPlayed,      
	  staging.getmonday(a.tstamp) as WeekPlayed,      
	  cast(a.tstamp as date) as DatePlayed,      
	  sum(case when pa = 'PLAY' then 1 else 0 end) as NumOfPlays,      
	  convert(float,(sum(case when pa = 'PING' then 1 else 0 end)  * 30.0)) as StreamedSeconds,    
	  convert(float,(sum(case when pa = 'PING' then 1 else 0 end)  * 30.0)/60) as StreamedMinutes,    
	  count(distinct a.uid) UniqueCustcount ,    
	  c.MaxConsumptionDate,  
	  d.ReportDate    
	from Archive.TGCPlus_VideoEvents a       
		  join Archive.TGCPlus_Film b on a.vid = b.uuid  
		  ,(select MAX(tstamp) MaxConsumptionDate from Archive.TGCPlus_VideoEvents)c    
		  ,(select DMLastUpdateESTDateTime as ReportDate from Archive.TGCPlus_VideoEvents)d
	where tstamp >= '9/28/2015' 
	group by a.pfm,
		a.useragent,
		a.countryisocode,
		a.CountryName,
	  case when b.film_type IS null and b.course_id > 0 then 'Episode'       
	  when b.film_type IS null and isnull(b.course_id,'0') = 0 then 'Trailer'      
	  else b.film_type      
	  end,     
	  b.genre,    
	  Year(a.tstamp),      
	  Month(a.tstamp),      
	  staging.getmonday(a.tstamp),      
	  cast(a.tstamp as date),
	  c.MaxConsumptionDate,  
	  d.ReportDate  
	


GO
