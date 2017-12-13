SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Staging].[SP_Load_tgc_upsell_RECC_SEG]
as
Begin 


--Active Multi's
exec Staging.SP_Load_tgc_upsell_RECC_AM_SEG

--Active Single's
exec Staging.SP_Load_tgc_upsell_RECC_AS_SEG

--In-Active Multi's
exec Staging.SP_Load_tgc_upsell_RECC_IM_SEG


--DeepSwamp Multi's
exec Staging.SP_Load_tgc_upsell_RECC_DM_SEG

--Deep Swamp Single's
exec Staging.SP_Load_tgc_upsell_RECC_DS_SEG



/* Final Load */

If object_id ('Datawarehouse.staging.tgc_upsell_RECC_SEG') is not null
Drop table Datawarehouse.staging.tgc_upsell_RECC_SEG

select * into Datawarehouse.staging.tgc_upsell_RECC_SEG
from
(select CustomerID, Segment
from Datawarehouse.staging.tgc_upsell_RECC_AM_SEG
union all
select CustomerID, Segment
from Datawarehouse.staging.tgc_upsell_RECC_AS_SEG
union all
select CustomerID, Segment
from Datawarehouse.staging.tgc_upsell_RECC_DM_SEG
union all
select CustomerID, Segment
from Datawarehouse.staging.tgc_upsell_RECC_DS_SEG
union all
select CustomerID, Segment
from Datawarehouse.staging.tgc_upsell_RECC_IM_SEG) a



End
GO
