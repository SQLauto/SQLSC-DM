SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE procedure [dbo].[spReportFailuresByDomain]
@ReportDate datetime,
@DomainName varchar(100)
AS
/* This routine is used to get a list of emails for a given domain
   Date Written: 2009-07-02 tom jones, TTC
*/
declare @EmailDate char(12)
set @DomainName = '%@' + @DomainName + '%'

-- This gives the date in a 'yyyy-mm-dd' format that is used in the log file naming conventions.
set @EmailDate = '%' + replace(convert(varchar(10),@ReportDate,111),'/','-') + '%'

select email, bounce
into #DomainStats
 from sm_aggregate_log 
where logname like @Emaildate
and email like @DomainName

select Bounces = count(distinct email) ,  bounce
from #DomainStats
group by bounce 
order by bounce

select distinct * from #DomainStats order by email





GO
GRANT EXECUTE ON  [dbo].[spReportFailuresByDomain] TO [public]
GO
GRANT EXECUTE ON  [dbo].[spReportFailuresByDomain] TO [TEACHCO\OLTP_DATA Group]
GO
