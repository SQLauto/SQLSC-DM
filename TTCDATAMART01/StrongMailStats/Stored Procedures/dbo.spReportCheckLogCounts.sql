SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE procedure [dbo].[spReportCheckLogCounts]
@StartDate datetime,
@EndDate Datetime = NULL
AS
/* This routine is used to make sure that the dbloaded is running
   Date Written: 2009-07-20 tom jones, TTC
   Last Updated: 2013-03-19 added variable enddate
*/
set @enddate = isnull(@enddate, getdate())

declare @EmailDate char(12)

Create Table #LogCounts
(ReportDate datetime,
 FailureCounts int)


-- This gives the date in a 'yyyy-mm-dd' format that is used in the log file naming conventions.
set @EmailDate = '%' + replace(convert(varchar(10),@StartDate,111),'/','-') + '%'

set @StartDate = dbo.beginofday(@StartDate)

While @StartDate < @enddate
begin
	Insert into #LogCounts
	Select @StartDate, count(*)  
	from sm_aggregate_log 
	where logname like @Emaildate

	set @StartDate = @StartDate + 1
	set @EmailDate = '%' + replace(convert(varchar(10),@StartDate,111),'/','-') + '%'
end

select * from #LogCounts order by ReportDate



GO
GRANT EXECUTE ON  [dbo].[spReportCheckLogCounts] TO [TEACHCO\OLTP_DATA Group]
GO
