SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/


CREATE view [Marketing].[vw_PD_Consumption] as (
  select a.*, b.ReleaseDate, c.title ,c.seriestitle,d.TGCPlusSubjectCategory,d.CourseName, pc.ContinentName, pc.RegionName, pc.RegionCode, pc.Country from Marketing.TGCPlus_VideoEvents_smry a left join mapping.TGC_CourseReleasesDates b
on a.courseid=b.courseid
left join [DataWarehouse].[Archive].[TGCPlus_Film] c on c.uuid=a.Vid and a.episodeNumber=c.episode_number


left join   [DataWarehouse].[Staging].[Vw_DMCourse] d on a.courseid=d.CourseID

left join mapping.TGCPlusCountry pc on pc.Alpha2Code= a.CountryCode where BundleFlag = 0 and FlagTGCPlusCourse = 1
and streamedmins > 0 and b.BU='TGCPlus'



)
GO
