SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





Create procedure [dbo].[spReportCheckLogCounts_OneDay]
@StartDate datetime
AS
/* This routine is used to make sure that the dbloaded is running
   Date Written: 2009-07-20 tom jones, TTC
*/
declare @EmailDate char(12)

Create Table #LogCounts
(ReportDate datetime,
 FailureCounts int)


-- This gives the date in a 'yyyy-mm-dd' format that is used in the log file naming conventions.
set @EmailDate = '%' + replace(convert(varchar(10),@StartDate,111),'/','-') + '%'

set @StartDate = dbo.beginofday(@StartDate)


Insert into #LogCounts
Select @StartDate, count(*)  
from sm_aggregate_log 
where logname like @Emaildate


select * from #LogCounts order by ReportDate



GO
