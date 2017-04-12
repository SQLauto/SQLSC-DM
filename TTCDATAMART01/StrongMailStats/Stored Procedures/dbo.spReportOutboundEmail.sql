SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[spReportOutboundEmail] 
@ReportDate datetime
AS
Declare @startdate datetime,
	    @enddate datetime
select @startdate = dbo.beginofday(@ReportDate),
	    @EndDate = dbo.endofday(@reportdate)
select mailid = convert(int,mailingid), ExternalIP = case when outboundIP = '66.77.15.201' then '254' 
                                                          when outboundIP = '66.77.15.202' then '253' else 'unknown' end,
count(*) from sm_success_log where datestamp between @startdate and @enddate
and isnumeric(mailingid) = 1
group by case when outboundIP = '66.77.15.201' then '254' 
               when outboundIP = '66.77.15.202' then '253' else 'unknown' end, mailingId
order by mailingid, 
case when outboundIP = '66.77.15.201' then '254' 
     when outboundIP = '66.77.15.202' then '253' else 'unknown' end

GO
GRANT EXECUTE ON  [dbo].[spReportOutboundEmail] TO [TEACHCO\OLTP_DATA Group]
GO
