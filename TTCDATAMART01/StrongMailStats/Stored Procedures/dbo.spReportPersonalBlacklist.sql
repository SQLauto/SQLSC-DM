SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[spReportPersonalBlacklist]
@ReportDate datetime
AS
/* This report is used to pull and remove people that have blocked us with a personal blacklist
   Date Written: 2009-06-12 tom jones, TTC
   Last Updated: 2009-06-15 tlj Added 'is  not accepting email from this sender' 
			     2011-12-16 tlj Changed column 'type' to category.
*/

declare @EmailDate char(12)

-- This gives the date in a 'yyyy-mm-dd' format that is used in the log file naming conventions.
set @EmailDate = '%' + replace(convert(varchar(10),@ReportDate,111),'/','-') + '%'

select email from sm_aggregate_log
where logname like @Emaildate
and ((bouncetype = '1002' and bounce like '%personal%')
or (bouncetype = '1003' and bounce like '%IS NOT ACCEPTING MAIL FROM THIS SENDER%'))

GO
GRANT EXECUTE ON  [dbo].[spReportPersonalBlacklist] TO [public]
GO
GRANT EXECUTE ON  [dbo].[spReportPersonalBlacklist] TO [TEACHCO\OLTP_DATA Group]
GO
