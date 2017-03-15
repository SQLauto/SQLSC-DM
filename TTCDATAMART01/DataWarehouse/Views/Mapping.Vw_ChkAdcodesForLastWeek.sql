SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE View [Mapping].[Vw_ChkAdcodesForLastWeek]
as

select *
	,DataWarehouse.Staging.GetSunday(dateadd(week,-1,getdate())) as WeekBegins
	,DataWarehouse.Staging.GetSunday(getdate()) WeekEnds
from DataWarehouse.Mapping.vwAdcodesAll
where StopDate >= DataWarehouse.Staging.GetSunday(dateadd(week,-1,getdate()))
and StartDate < DataWarehouse.Staging.GetSunday(getdate())



GO
