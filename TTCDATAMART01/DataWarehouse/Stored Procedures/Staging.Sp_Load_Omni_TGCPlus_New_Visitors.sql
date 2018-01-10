SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [Staging].[Sp_Load_Omni_TGCPlus_New_Visitors]
as
Begin

--Deletes
Delete from Archive.Omni_TGCPlus_New_Visitors
where Date in (Select distinct cast(Date as datetime)Date from Staging.Omni_TGCPlus_ssis_New_Visitors)

--Inserts
insert into Archive.Omni_TGCPlus_New_Visitors
( Date,MarketingCloudVisitorID,utm_campaign,UniqueVisitors)

select cast(Date as datetime)Date,MarketingCloudVisitorID,utm_campaign,UniqueVisitors
from Staging.Omni_TGCPlus_ssis_New_Visitors

End
GO
