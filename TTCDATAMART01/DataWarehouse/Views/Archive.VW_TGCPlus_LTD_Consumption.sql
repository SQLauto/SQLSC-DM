SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create View [Archive].[VW_TGCPlus_LTD_Consumption] 
as

select U.id,U.Email,isnull(Count(PA),0) * 1.* 30 StreamedSeconds
from DataWarehouse.Archive.TGCPlus_User U
left join DataWarehouse.Archive.TGCPlus_VideoEvents V
on U.uuid = V.Uid 
where PA = 'PING'  
group by id,U.Email 
 
GO
