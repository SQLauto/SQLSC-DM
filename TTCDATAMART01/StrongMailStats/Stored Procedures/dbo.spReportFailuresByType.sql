SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


Create procedure [dbo].[spReportFailuresByType]
@ReportDate datetime,
@ReasonType int
AS
/* This routine is used to get a list of emails for a given type
   Date Written: 2009-06-16 tom jones, TTC
*/
declare @EmailDate char(12)

-- This gives the date in a 'yyyy-mm-dd' format that is used in the log file naming conventions.
set @EmailDate = '%' + replace(convert(varchar(10),@ReportDate,111),'/','-') + '%'

select email, bounce
 from sm_aggregate_log 
where logname like @Emaildate
and type = @ReasonType


GO
GRANT EXECUTE ON  [dbo].[spReportFailuresByType] TO [public]
GO
GRANT EXECUTE ON  [dbo].[spReportFailuresByType] TO [TEACHCO\OLTP_DATA Group]
GO
