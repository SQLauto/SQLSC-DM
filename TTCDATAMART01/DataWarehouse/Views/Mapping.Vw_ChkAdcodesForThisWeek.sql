SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE View [Mapping].[Vw_ChkAdcodesForThisWeek]
as

select *
	,DataWarehouse.Staging.GetSunday(getdate()) as WeekBegins
	,DataWarehouse.Staging.GetSunday(dateadd(week,1,getdate())) WeekEnds
from DataWarehouse.Mapping.vwAdcodesAll
where StopDate >= DataWarehouse.Staging.GetSunday(getdate())
and StartDate < DataWarehouse.Staging.GetSunday(dateadd(week,1,getdate()))



GO
