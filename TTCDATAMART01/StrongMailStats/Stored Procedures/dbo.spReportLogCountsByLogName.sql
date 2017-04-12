SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[spReportLogCountsByLogName]
@ReportDate datetime
AS
/* This routine is used to find the log counts for various log files
   for Debugging
   Date Written: 2009-09-14 tom jones, TTC
*/
declare @EmailDate char(12)


-- This gives the date in a 'yyyy-mm-dd' format that is used in the log file naming conventions.
set @EmailDate = '%' + replace(convert(varchar(10),@ReportDate,111),'/','-') + '%'

	Select logname, count(*)  
	from sm_aggregate_log 
	where logname like @Emaildate
	group by logname with rollup
	order by count(*) desc

GO
GRANT EXECUTE ON  [dbo].[spReportLogCountsByLogName] TO [TEACHCO\OLTP_DATA Group]
GO
