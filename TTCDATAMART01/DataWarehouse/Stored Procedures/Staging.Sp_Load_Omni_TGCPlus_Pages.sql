SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [Staging].[Sp_Load_Omni_TGCPlus_Pages]
as
Begin

--Deletes
Delete from Archive.Omni_TGCPlus_Pages
where Date in (Select distinct cast(Date as datetime)Date from Staging.Omni_TGCPlus_ssis_Pages)

--Inserts
insert into Archive.Omni_TGCPlus_Pages
( Date,MarketingCloudVisitorID,Pages,AllVisits)

select cast(Date as datetime)Date,MarketingCloudVisitorID,Pages,AllVisits
from Staging.Omni_TGCPlus_ssis_Pages

End

GO
