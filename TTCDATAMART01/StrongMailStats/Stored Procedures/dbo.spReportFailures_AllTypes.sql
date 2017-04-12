SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[spReportFailures_AllTypes] 
@ReportDate datetime
AS
/* This routine is used to get errors by type
   Date Written: 2011-06-20 tom jones, TTC
   Last Updated: 2012-05-08 tlj Updated to 
                 2013-06-15 tlj Give totals
  
*/
declare @EmailDate char(12)

-- This gives the date in a 'yyyy-mm-dd' format that is used in the log file naming conventions.
set @EmailDate = '%' + replace(convert(varchar(10),@ReportDate,111),'/','-') + '%'

select ErrorType = bouncetype, bounce, ErrorCount = count(*)
into #tmpErrors
 from sm_aggregate_log 
where logname like @Emaildate
group by bouncetype, bounce
order by bouncetype,bounce

Select TotalErrors = sum(ErrorCount)from #tmpErrors
select * from #tmperrors order by ErrorType,bounce




GO
GRANT EXECUTE ON  [dbo].[spReportFailures_AllTypes] TO [public]
GO
GRANT EXECUTE ON  [dbo].[spReportFailures_AllTypes] TO [TEACHCO\OLTP_DATA Group]
GO
