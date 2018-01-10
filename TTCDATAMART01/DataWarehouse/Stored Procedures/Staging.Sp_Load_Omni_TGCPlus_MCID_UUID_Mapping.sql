SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [Staging].[Sp_Load_Omni_TGCPlus_MCID_UUID_Mapping]
as
Begin

--Inserts only New ones
insert into Archive.Omni_TGCPlus_MCID_UUID_Mapping
( MarketingCloudVisitorID,TGCPlusUserID,AllVisits)

select S.MarketingCloudVisitorID,S.TGCPlusUserID,S.AllVisits
from Staging.Omni_TGCPlus_ssis_MCID_UUID_Mapping S
left join Archive.Omni_TGCPlus_MCID_UUID_Mapping A
on A.MarketingCloudVisitorID = S.MarketingCloudVisitorID
and isnull(A.TGCPlusUserID,'') = isnull(S.TGCPlusUserID,'')
where A.MarketingCloudVisitorID is null

End
GO
