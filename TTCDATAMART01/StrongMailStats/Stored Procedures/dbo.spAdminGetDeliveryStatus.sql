SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[spAdminGetDeliveryStatus] 
@FromDate datetime = NULL
AS
set rowcount 0
/*drop table #emailstats
drop table #EmailFinal
*/
declare @todate datetime
set @fromdate = isnull(@fromdate,getdate())
select @fromdate = dbo.beginofday(@fromdate)
select @todate = @fromdate + 1
select logtype, 
Logtypename = 
case logtype when 1 then 'Block' 
		     when 2 then 'MX Connection' 
		     when 3 then 'Invalid Address Format'
		     when 4 then 'Connection Failures'
			 when 5 then 'Complaint'	
			 when 7 then 'Unsubscribe'			 	     
			 else '' end, 
			 
Emails = count(*),
TotalSuccess = convert(int,0)
into #Emailstats
from SM_AGGREGATE_LOG			 
where logdate between @fromdate and @todate
group by logtype,
case logtype when 1 then 'Block' 
		     when 2 then 'MX Connection' 
		     when 3 then 'Invalid Address Format'
			 when 4 then 'Connection Failures'
			 when 5 then 'Complaint'
			 when 7 then 'Unsubscribe'
		     else '' end
		     with rollup
order by logtype

select distinct * into #EmailFinal from #emailstats

declare @TotalSuccess int,
@TotalEmails int
select @TotalSuccess = count(*) from sm_success_log
where datestamp between  @fromdate and @todate

update #EmailFinal set TotalSuccess = @totalSuccess

select @TotalEmails = Emails + totalSuccess
from #EmailFinal
where logtype is null

select distinct *, PctErrors = round(convert(money,100.0 * Emails/ @TotalEmails),2) from #EmailFinal order by logtype

select BounceName  = case  when bounce like '%Comcast Blocked for Spam%' then 'Comcast block'
			  when bounce like '%Comcast Block for Spam%' then 'Comcast block'
					      when bounce like '%refused%' then 'Refused'
					       when bounce like '%blocked - User%'  then 'Refused' 
					      when bounce like '%black%' then 'Blacklist' 
					      when bounce like '%block%' then 'Blacklist' 
					      when bounce like '%rbl%' then 'Blacklist' 
					      when bounce like '%Sender Denied%' then 'Blacklist'
					      when bounce like '%rejected%'  then 'Blacklist' 
					      when bounce like '%spam%' then 'Seen as SPAM' 
					      when bounce like '%junk%' then 'Seen as SPAM' 
					      when bounce like '%unsolicit%' then 'Seen as SPAM' 
					      else 'Other' end
					          ,
TotalEmails = count(*)					      
from sm_aggregate_log where logdate between @fromdate and @todate
and logtype = 1
group by case when bounce like '%Comcast Blocked for Spam%' then 'Comcast block'
			  when bounce like '%Comcast Block for Spam%' then 'Comcast block'
					      when bounce like '%refused%' then 'Refused'
					       when bounce like '%blocked - User%'  then 'Refused' 
					      when bounce like '%black%' then 'Blacklist' 
					      when bounce like '%block%' then 'Blacklist' 
					      when bounce like '%rbl%' then 'Blacklist' 
					      when bounce like '%Sender Denied%' then 'Blacklist'
					      when bounce like '%rejected%'  then 'Blacklist' 
					      when bounce like '%spam%' then 'Seen as SPAM' 
					      when bounce like '%junk%' then 'Seen as SPAM' 
					      when bounce like '%unsolicit%' then 'Seen as SPAM' 
					      else 'Other' end
					      
/* - TO SEE WHAT THE 'OTHER' RECORDS CONTAINS - WAS FOR TESTING OF THE CATEGORIES ABOVE 
select * 				      
from sm_aggregate_log where logdate > '12/27/2013'
and logtype = 1
and case  when bounce like '%Comcast Blocked for Spam%' then 'Comcast block'
			  when bounce like '%Comcast Block for Spam%' then 'Comcast block'
					      when bounce like '%refused%' then 'Refused'
					       when bounce like '%blocked - User%'  then 'Refused' 
					      when bounce like '%black%' then 'Blacklist' 
					      when bounce like '%block%' then 'Blacklist' 
					      when bounce like '%rbl%' then 'Blacklist' 
					      when bounce like '%Sender Denied%' then 'Blacklist'
					      when bounce like '%rejected%'  then 'Blacklist' 
					      when bounce like '%spam%' then 'Seen as SPAM' 
					      when bounce like '%junk%' then 'Seen as SPAM' 
					      when bounce like '%unsolicit%' then 'Seen as SPAM' 
					      else 'Other' end
					       = 'Other'
*/

GO
