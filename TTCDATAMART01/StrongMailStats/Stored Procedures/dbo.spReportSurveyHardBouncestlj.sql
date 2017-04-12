SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE Procedure [dbo].[spReportSurveyHardBouncestlj]
@ReportDate datetime
AS
/* This report is used to pull and remove people that have hard bounces that came
   through the survey system - since it is not integrated into our regular systems
   Date Written: 2009-07-20 tom jones, TTC
   Last Updated: 2010-02-11 tlj Updated to include new aol 'hard bounces' per Postmaster blog
*/

declare @EmailDate char(12)

-- This gives the date in a 'yyyy-mm-dd' format that is used in the log file naming conventions.
set @EmailDate = '%' + replace(convert(varchar(10),@ReportDate,111),'/','-') + '%'

select email, [type], BounceDate = @ReportDate
into #tmpBounce
 from sm_aggregate_log 
where logname like @Emaildate
and type between 2001 and 2999
and MailingID = '00000'
and email not like '%teach12%'

Insert into #tmpBounce
select email, [type], bounceDate= @ReportDate
 from sm_aggregate_log 
where logname like @Emaildate
and email like '%@aol.com%'
and bounce like '%Temporary lookup failure%'

select * from #tmpBounce

GO
GRANT EXECUTE ON  [dbo].[spReportSurveyHardBouncestlj] TO [TEACHCO\OLTP_DATA Group]
GO
