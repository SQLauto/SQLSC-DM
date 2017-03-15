SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[spMagento_ExportUpsellAnonymous]
AS
/* This routine is used to get the upsell anonymous table to a staging artea
   prior to sending them to Magento.
   Date Written: 2014-02-21 tom jones, TGC
   Last Updated:
*/
set nocount on

Truncate table UpsellAnonymous

declare @reccount int
select subject_id = convert(varchar(25),SubjectID), course_ID = courseid, displayorder
into #tmpSubject
from Datawarehouse.staging.CCUpSellAnonymous
order by SubjectID, DisplayOrder

select @reccount = @@ROWCOUNT

insert into #tmpsubject values ('Expected Records',@reccount,0)

Insert into UpsellAnonymous 
select * from #tmpsubject
order by ISNUMERIC(subject_id), subject_id


GO
