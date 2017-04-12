SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[spReportSpamComplaintstlj] 
@ReportDate datetime
AS
/* This routine is used to get a list of spam complaint emails from a given date
   Date Written: 2009-06-12 tom jones, TTC
   Last Updated: 2009-07-15 tlj Updated to include complaints - since they aren't always 
                            done by cust service (saw 1/2 not updated within 1 day)
                 2011-12-16 changed 'type' to bouncetype
                 2012-11-08 tlj Removed the bounce filters from the selection
*/
declare @EmailDate char(12)

-- This gives the date in a 'yyyy-mm-dd' format that is used in the log file naming conventions.
set @EmailDate = '%' + replace(convert(varchar(10),@ReportDate,111),'/','-') + '%'

select distinct email, bounce
 from sm_aggregate_log 
where logname like @Emaildate
and bounce = 'complaint'
order by email
/* 2011-11-08 tlj Removed 
and 
((bouncetype = 1001 and bounce like '%filters%') or
  bounce = 'Complaint')
)
*/

select distinct email , bounce
 from sm_aggregate_log 
where logname like @Emaildate
and (
(bouncetype = 1001 and bounce like '%filters%') or
  bounce = 'Complaint')
  order by email



GO
