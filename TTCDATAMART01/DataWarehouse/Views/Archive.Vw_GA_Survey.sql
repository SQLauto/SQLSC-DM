SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create View [Archive].[Vw_GA_Survey]
as

select S2.* from 
		(Select Uuid,Action, max(cast(DMLastupdated as date)) Max_DMLastupdated
		from archive.GA_Survey
		Group by Uuid,Action) S1
join archive.GA_Survey S2
on S1.UUID = S2.UUID and S1.Action = S2.Action
GO
