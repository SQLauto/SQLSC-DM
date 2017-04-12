SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[spReportSurveyHardBounces]
@ReportDate datetime
AS
/* This report is used to pull and remove people that have hard bounces that came
   through the survey system - since it is not integrated into our regular systems
   Date Written: 2009-07-20 tom jones, TTC
   Last Updated: 2010-02-11 tlj Updated to include new aol 'hard bounces' per Postmaster blog
		         2011-12-16 tlj change type to 'bouncetype'
*/

declare @EmailDate char(12)

-- This gives the date in a 'yyyy-mm-dd' format that is used in the log file naming conventions.
set @EmailDate = '%' + replace(convert(varchar(10),@ReportDate,111),'/','-') + '%'

select email, [bouncetype], BounceDate = @ReportDate
 from sm_aggregate_log 
where logname like @Emaildate
and bouncetype between 2001 and 2999
and MailingID = '00000'
and email not like '%teach12%'
union
select email, [bouncetype], bounceDate= @ReportDate
 from sm_aggregate_log 
where logname like @Emaildate
and email like '%@aol.com%'
and bounce like '%Temporary lookup failure%'


GO
GRANT EXECUTE ON  [dbo].[spReportSurveyHardBounces] TO [public]
GO
GRANT EXECUTE ON  [dbo].[spReportSurveyHardBounces] TO [TEACHCO\OLTP_DATA Group]
GO
