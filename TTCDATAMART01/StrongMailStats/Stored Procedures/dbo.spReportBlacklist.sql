SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE Procedure [dbo].[spReportBlacklist] 
@ReportDate datetime
AS
/* This report is used to pull blacklists from a given day's mailings.
   Date Written: 2009-07-21 tom jones, TTC
   Last Updated: 2011-05-07 tlj updated to include 'spam' in selection
				 2011-12-19 tlj Updated to include 'block' in selection
				 2013-06-15 tlj included summary line
   
*/

declare @EmailDate char(12)

-- This gives the date in a 'yyyy-mm-dd' format that is used in the log file naming conventions.
set @EmailDate = '%' + replace(convert(varchar(10),@ReportDate,111),'/','-') + '%'




select distinct domain=substring(email,charindex('@',email) + 1, 20),bounces=count(distinct email), bounce , max(email) as EmailIDDR
into #DomainList
 from sm_aggregate_log 
where logname like @Emaildate
and (bounce like '%blacklist%' or bounce like '%spam%' or bounce like '%block%')
and bounce not like '%personal%'
group by substring(email,charindex('@',email) + 1, 20), bounce
order by substring(email,charindex('@',email) + 1, 20), bounce

Select DomainsBlocked = count(distinct domain), TotalBounces = sum(bounces)
from #DomainList

select * from #domainlist order by domain, bounce


GO
GRANT EXECUTE ON  [dbo].[spReportBlacklist] TO [public]
GO
GRANT EXECUTE ON  [dbo].[spReportBlacklist] TO [TEACHCO\OLTP_DATA Group]
GO
