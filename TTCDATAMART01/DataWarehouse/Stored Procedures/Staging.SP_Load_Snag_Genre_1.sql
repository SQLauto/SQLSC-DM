SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE Proc [Staging].[SP_Load_Snag_Genre_1]
as

Begin



/*********************Load into Clean table*********************/

Truncate table Datawarehouse.archive.TGCPlus_Genre_1

insert into Datawarehouse.archive.TGCPlus_Genre_1
 (  id,version,browse_page_title,title,site_id,uuid)

select    id,case when version is null then null else Cast(version as bigint) end as version
,browse_page_title
,title, case when site_id is null or site_id = 'Null' then null else Cast(site_id as bigint) end as site_id
,[uuid]
from  Datawarehouse.staging.Snag_ssis_Genre

 
End 




GO
