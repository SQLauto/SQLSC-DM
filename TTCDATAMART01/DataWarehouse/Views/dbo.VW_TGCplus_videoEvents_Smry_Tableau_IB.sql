SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [dbo].[VW_TGCplus_videoEvents_Smry_Tableau_IB]
as
SELECT 
 b.UUID
      ,b.ID
      ,b.TSTAMP
      ,b.Month
      ,b.Year
      ,b.Week
      ,b.Platform
      ,b.Player
      ,b.FlagAudio
      ,b.FlagOffline
      ,b.Speed
      ,b.useragent
      ,b.Vid
      ,b.courseid
      ,b.episodeNumber
      ,b.FilmType
      ,b.lectureRunTime
      ,b.CountryCode
      ,b.city
      ,b.State
      ,b.timezone
      ,b.plays
      ,b.pings
      ,b.MaxVPOS
      ,b.uip
      ,b.StreamedMins
      ,b.MinTstamp
      ,b.SeqNum
      ,b.Paid_SeqNum
      ,b.PaidFlag
, 0 as flag_padded FROM Datawarehouse.Marketing.TGCplus_Consumption_Smry (nolock) b 
UNION ALL
SELECT d.UUID,d.id ,D.DATE AS tSTAMP, MONTH(D.DATE)Month, YEAR(D.DATE)Year,datepart(wk,D.DATE)Week,NULL as Platform,
null as Player
      , null as FlagAudio
      , null as FlagOffline
      , null as Speed,
NULL as Useragent,NULL as Vid,null as courseid,null as episodenumber,null as FilmType,
null as lectureRunTime	,NUll as CountryCode	,NUll as city	,NUll as State	,NUll as timezone	,0 as plays	,0 as pings	,0 as MaxVPOS	,NUll as uip	,0 as StreamedMins	,NUll as MinTstamp	,NUll as SeqNum	,NUll as Paid_SeqNum,Null as PaidFlag,1 as flag_padded
FROM 
(	/* Get last one years dates */
	select uuid,U.CustomerID as id,d.date  
	from DataWarehouse.Mapping.Date d,Datawarehouse.Marketing.TGCPlus_CustomerSignature U
	where d.date between u.IntlSubDate and cast( getdate()-1 as date)
	--and id = 937720
) d 
left join Datawarehouse.Marketing.TGCplus_Consumption_Smry (nolock) b 
ON d.id = b.ID and d.Date = b.TSTAMP
where   b.ID is null
--and d.id = 937720
 


GO
