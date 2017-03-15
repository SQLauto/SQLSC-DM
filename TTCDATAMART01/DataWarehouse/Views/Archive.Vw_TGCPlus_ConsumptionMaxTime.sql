SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE View [Archive].[Vw_TGCPlus_ConsumptionMaxTime]
as
select 	MAX(tstamp) MaxTimeStamp
from Marketing.TGCplus_VideoEvents_Smry

GO
