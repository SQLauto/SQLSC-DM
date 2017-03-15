SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Mapping].[Vw_TGCPlus_ValidSubscriptionPlan]
AS

	select *
	from DataWarehouse.Archive.TGCPlus_SubscriptionPlan
	where ID in (39,40,43,44,57,58,42,55,67,68,71,79, 80, 90, 96, 130,136,156,128,129, 167, 168)



GO
