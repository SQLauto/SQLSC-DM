SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[spMagento_ExportEmailLander]
AS
/* This routine is used to create the email landing page items.
   Date Written: 12/23/2013 tom jones, TGC
   Last Updated: 2014-03-18 tlj Updated to go to the archive table if no records are in 
                                the landing page data - since this is running and archiving for
                                current, pre-Magento data.
				 2014-05-12 tlj Updated for UTC-8 output - all nvarchar to nvarcha                          
				 2014-09-15 tlj Updated to continuously send most recent data - so that all data can be up to date.
				 2014-09-30 tlj Moved to Production
*/                                

declare @TotalRows int,
		@MoveDate datetime,
		@yesterday datetime = getdate() -1
		
		

Truncate Table  MagentoExports..EmailLander

select email_category = convert(nvarchar(50),CategoryID), email_courseid = courseid, email_displayorder = displayorder, markdown_flag = blnMarkdown, 
special_message = '"' + replace(ISNULL(message,''),'"','""') + '"', date_expires = CONVERT(nvarchar(15), expires,101) 
into #tmpEmailLander
from Reports..MktWebCategoryCourses
set @TotalRows = @@ROWCOUNT

/* 2014-09-15 tlj Changed to pull all non-expired items - so that this can run multiple times to the Web Systems */

	select email_category_arch = convert(nvarchar(50),CategoryID), LastMoveDate = MAX(dateMoved)
	into #LastCategoryUpdate
	from Reports..MktWebCategoryCourses_Archive
	where expires >= @yesterday
	and CategoryID not in 
	(select email_category from 	#tmpEmailLander)
	group by convert(nvarchar(50),CategoryID)
	

	Insert into #tmpEmailLander
	select email_category = convert(nvarchar(50),CategoryID), email_courseid = courseid, email_displayorder = displayorder, markdown_flag = blnMarkdown, 
	special_message = '"' + replace(ISNULL(message,''),'"','""') + '"', date_expires = CONVERT(nvarchar(15), expires,101) 
	from #LastCategoryUpdate lcu
	join Reports..MktWebCategoryCourses_Archive mwc
	on lcu.email_category_arch = mwc.CategoryID
	and lcu.LastMoveDate = mwc.datemoved

/* 2014-09-15 tlj End Changes */
select @TotalRows = COUNT(*) from #tmpEmailLander

insert into #tmpEmailLander values(N'Expected Records',@TotalRows,0,0,'','')

Insert into MagentoExports..EmailLander
select *  from #tmpEmailLander
order by date_expires, email_category, email_displayorder

drop table #tmpEmailLander


GO
