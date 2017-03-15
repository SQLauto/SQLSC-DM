SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[spMagento_ExportCustomerSegments]
AS
/* This routine is used to pull Customer segments groups and associated courses
   Date Written: 2014-02-21 tom jones, TGC
*/
truncate table Upsell_CustomerSegments

select distinct SegmentGroup 
into #upsellgroups
from Datawarehouse.Marketing.Upsell_CustomerSegmentGroup

set rowcount 0
set nocount on
select segmentgroup,course_id = CourseID, displayorder=Rank
into #UpsellSegments
from Datawarehouse.Marketing.Upsell_CourseRank
where SegmentGroup in (
select distinct segmentgroup from #upsellgroups)
order by segmentgroup, DisplayOrder

declare @upsellcount int
select @upsellcount= count(*) from #UpsellSegments

insert into #UpsellSegments values('Expected Records', @upsellcount,0)


Insert into Upsell_CustomerSegments 
select * from #upsellsegments order by case when displayorder = 0 then '' else segmentgroup end, displayorder
GO
