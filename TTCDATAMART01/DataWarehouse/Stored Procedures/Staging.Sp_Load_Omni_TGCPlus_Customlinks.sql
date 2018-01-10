SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[Sp_Load_Omni_TGCPlus_Customlinks]
as
Begin

--Deletes
Delete from Archive.Omni_TGCPlus_Customlinks
where Date in (Select distinct cast(Date as datetime) from Staging.Omni_TGCPlus_ssis_Customlinks)

--Inserts
insert into Archive.Omni_TGCPlus_Customlinks
( Date,MarketingCloudVisitorID,CustomLink,AllVisits)

select cast(Date as datetime),MarketingCloudVisitorID,CustomLink,AllVisits
from Staging.Omni_TGCPlus_ssis_Customlinks

End
GO
