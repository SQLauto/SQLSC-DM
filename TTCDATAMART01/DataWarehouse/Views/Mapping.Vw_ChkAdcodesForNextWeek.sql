SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE View [Mapping].[Vw_ChkAdcodesForNextWeek]
as

select *
	,DataWarehouse.Staging.GetSunday(dateadd(week,1,getdate())) WeekBegins
	,DataWarehouse.Staging.GetSunday(dateadd(week,2,getdate())) WeekEnds
from DataWarehouse.Mapping.vwAdcodesAll
where StopDate >= DataWarehouse.Staging.GetSunday(dateadd(week,1,getdate()))
and StartDate < DataWarehouse.Staging.GetSunday(dateadd(week,2,getdate()))


GO
