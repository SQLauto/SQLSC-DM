SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Mapping].[Vw_TGCPlus_ValidSubscriptionPlan]
AS

	select *
	from DataWarehouse.Archive.TGCPlus_SubscriptionPlan
	--where ID in (39,40,43,44,57,58,42,55,67,68,71,79, 80, 90, 96, 130,136,156,128,129, 167, 168,181)
	where ID NOT IN (11,12,25,26,27,28,29,30,31,32,33,34,35,36,47,53,56, 61,62,63,64,65,66,75,76,89, 95,103)
GO
