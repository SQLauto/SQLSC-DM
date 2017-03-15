SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [dbo].[VW_TGCplus_VideoEvents_Smry_Tableau]
as
SELECT *, 0 as flag_padded FROM Datawarehouse.Marketing.TGCplus_VideoEvents_Smry (nolock) b 
UNION ALL
SELECT d.UUID,d.id ,D.DATE AS tSTAMP, MONTH(D.DATE)Month, YEAR(D.DATE)Year,datepart(wk,D.DATE)Week,NULL as Platform,NULL as Useragent,NULL as Vid,null as courseid,null as episodenumber,null as FilmType,
null as lectureRunTime	,NUll as CountryCode	,NUll as city	,NUll as State	,NUll as timezone	,0 as plays	,0 as pings	,0 as MaxVPOS	,NUll as uip	,0 as StreamedMins	,NUll as MinTstamp	,NUll as SeqNum	,NUll as Paid_SeqNum,1 as flag_padded
FROM 
(	/* Get last one years dates */
	select uuid,U.CustomerID as id,d.date  
	from DataWarehouse.Mapping.Date d,Datawarehouse.Marketing.TGCPlus_CustomerSignature U
	where d.date between u.IntlSubDate and cast( getdate()-1 as date)
	--and id = 937720
) d 
left join Datawarehouse.Marketing.TGCplus_VideoEvents_Smry (nolock) b 
ON d.id = b.ID and d.Date = b.TSTAMP
where   b.ID is null
--and d.id = 937720
 

GO
