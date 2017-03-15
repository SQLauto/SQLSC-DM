SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Proc [dbo].[SP_EPC_SnapShotReport] @SnapShotDate date = null
as
Begin

--Declare @SnapShotDate date
If @SnapShotDate is null
Select @SnapShotDate = cast(MAX(SnapshotDate) as DATE) from DataWarehouse.Archive.epc_preference_Snapshot

select * from DataWarehouse.Archive.epc_preference_Snapshot
where cast(SnapshotDate as date) = @SnapShotDate--(select cast(MAX(SnapshotDate) as DATE) from DataWarehouse.Archive.epc_preference_Snapshot)



End
GO
