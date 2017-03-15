SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE View [Archive].[Vw_TGCPlus_SchoolAct_Consumption]
as
		
select a.email, 		
	case when a.email like '%sssas%' then 'SSSAS'	
		when a.email like '%wmpcs%' then 'WMPCS'	
		when a.email like '%odtgc%' then 'OfficeDepot'
		else 'Other'
	end as CustGroup,	
	cast(a.joined as date) as RegisteredDate,	
	cast(a.entitled_dt as date) as SubscribedDate,	
	--a.full_name,	
	--a.TGCPluscampaign as CampaignAdcode,	
	--b.AdcodeName as CampaignName,	
	--b.MD_Channel, b.MD_PromotionType, b.MD_CampaignName,	
	c.TSTAMP, 	
	c.courseid, 	
	d.seriestitle as CourseName,	
	c.episodeNumber as LectureNumber,	
	d.title as LectureName,	
	d.genre as SubjectCategory,	
	c.MaxVPOS,	
	c.FilmType,	
	c.StreamedMins,
	c.lectureRunTime,
	c.pings,
	c.plays,
	c.Platform
from DataWarehouse.Archive.TGCPlus_User a left join		
	DataWarehouse.Mapping.vwAdcodesAll b on a.TGCPluscampaign = b.AdCode left join	
	DataWarehouse.Marketing.TGCplus_VideoEvents_Smry_TestAccts c on a.uuid = c.UUID left join	
	DataWarehouse.Archive.TGCPlus_Film d on c.Vid = d.uuid	
where a.email like '%WMPCS%+%' or a.email like '%SSSAS%+%'	or a.email like '%odtgc%+%'	

GO
