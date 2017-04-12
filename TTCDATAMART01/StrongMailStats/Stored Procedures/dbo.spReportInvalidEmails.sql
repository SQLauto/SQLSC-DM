SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create procedure [dbo].[spReportInvalidEmails]
@ReportDate datetime
AS
/* This routine is used to get a list of invalid emails from a given date
   Date Written: 2009-06-12 tom jones, TTC
*/
declare @EmailDate char(12)

-- This gives the date in a 'yyyy-mm-dd' format that is used in the log file naming conventions.
set @EmailDate = '%' + replace(convert(varchar(10),@ReportDate,111),'/','-') + '%'

select customerid, emailaddress, LastAgent = isnull(agentlastmodified,'WebSite') 
from superstar..customers where emailaddress in (
select email 
 from sm_aggregate_log 
where logname like @Emaildate
and type between 8000 and 8999)
GO
GRANT EXECUTE ON  [dbo].[spReportInvalidEmails] TO [public]
GO
GRANT EXECUTE ON  [dbo].[spReportInvalidEmails] TO [TEACHCO\OLTP_DATA Group]
GO
