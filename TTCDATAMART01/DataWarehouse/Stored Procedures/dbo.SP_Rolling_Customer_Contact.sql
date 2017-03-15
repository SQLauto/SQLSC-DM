SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[SP_Rolling_Customer_Contact]
as
Begin

	Declare @Currentdate Datetime = cast(GETDATE()as date)
	,@Prior1Yeardate Datetime
	,@Prior9Monthsdate Datetime
	,@Prior6Monthsdate Datetime
	,@Prior3Monthsdate Datetime

	Select @Prior3Monthsdate = DATEADD(Month,-3,@Currentdate)
		,@Prior6Monthsdate = DATEADD(Month,-6,@Currentdate)
		,@Prior9Monthsdate = DATEADD(Month,-9,@Currentdate)
		,@Prior1Yeardate = DATEADD(Year,-1,@Currentdate)

	select  @Currentdate Currentdate
		,@Prior3Monthsdate as Prior3Monthsdate
		,@Prior6Monthsdate as Prior6Monthsdate
		,@Prior9Monthsdate Prior9Monthsdate
		,@Prior1Yeardate as Prior1Yeardate

	Select CustomerID
	, @Currentdate Currentdate
	,@Prior3Monthsdate as Prior3Monthsdate
	,@Prior6Monthsdate as Prior6Monthsdate
	,@Prior9Monthsdate Prior9Monthsdate
	,@Prior1Yeardate as Prior1Yeardate
	Into #Customer
	from DataWarehouse.Marketing.CampaignCustomerSignature (Nolock)

	/*Email Contacts*/ 
	select
		 C.CustomerID
		,Sum(case when StartDate>=Prior3Monthsdate then 1 else 0 end) EmailCntsLast3Month
		,Sum(case when StartDate>=Prior6Monthsdate then 1 else 0 end) EmailCntsLast6Month
		,Sum(case when StartDate>=Prior9Monthsdate then 1 else 0 end) EmailCntsLast9Month
		,Sum(case when StartDate>=Prior1Yeardate then 1 else 0 end) EmailCntsLast1Year
	Into #EmailContacts
	from #Customer C
	join 
		(select CustomerID,StartDate from [Archive].[EmailhistoryCurrentYear]  
		where FlagHoldOut = 0
		union 
		select CustomerID,StartDate from [Archive].[EmailhistoryPrior1Year]
		where FlagHoldOut = 0
		) Email 
	On C.CustomerID =Email.CustomerID and Email.StartDate >= C.Prior1Yeardate 
	Group by C.CustomerID


	/*Mail Contacts*/  
	select
		 C.CustomerID
		,Sum(case when StartDate>=Prior3Monthsdate then 1 else 0 end) MailCntsLast3Month
		,Sum(case when StartDate>=Prior6Monthsdate then 1 else 0 end) MailCntsLast6Month
		,Sum(case when StartDate>=Prior9Monthsdate then 1 else 0 end) MailCntsLast9Month
		,Sum(case when StartDate>=Prior1Yeardate then 1 else 0 end) MailCntsLast1Year
	Into #MailContacts
	from #Customer C
	join 
		(select CustomerID,StartDate from [Archive].[MailhistoryCurrentYear]  
		where FlagHoldOut = 0
		union 
		select CustomerID,StartDate from [Archive].[MailhistoryPrior1Year]
		where FlagHoldOut = 0
		) Email 
	On C.CustomerID =Email.CustomerID and Email.StartDate >= C.Prior1Yeardate 
	Group by C.CustomerID


	/* EPC Mapped Customer emails */ 
	Select Distinct Email,CustomerID
	,@Currentdate Currentdate
	,@Prior3Monthsdate as Prior3Monthsdate
	,@Prior6Monthsdate as Prior6Monthsdate
	,@Prior9Monthsdate Prior9Monthsdate
	,@Prior1Yeardate as Prior1Yeardate
	Into #EPC  
	From DataWarehouse.Marketing.epc_preference (nolock)
	where CustomerID is not null

	/* Email Engagement from SM Tracker Log*/ 
	select * 
	into #Engagement 
	from DataWarehouse.Archive.[SM_TRACKING_LOG] 
	where datestamp>= @Prior1Yeardate

 	select
		 C.CustomerID
		,COUNT(distinct C.Email) as CntOfEmails
		,Sum(case when datestamp>=Prior3Monthsdate And ttype = 'click' then 1 else 0 end) EmailCliksLast3Month
		,Sum(case when datestamp>=Prior6Monthsdate And ttype = 'click' then 1 else 0 end) EmailCliksLast6Month
		,Sum(case when datestamp>=Prior9Monthsdate And ttype = 'click' then 1 else 0 end) EmailCliksLast9Month
		,Sum(case when datestamp>=Prior1Yeardate   And ttype = 'click' then 1 else 0 end) EmailCliksLast1Year
		,Max(case when datestamp>=Prior3Monthsdate And ttype = 'click' then 1 else 0 end) FlagEmailCliksLast3Month
		,Max(case when datestamp>=Prior6Monthsdate And ttype = 'click' then 1 else 0 end) FlagEmailCliksLast6Month
		,Max(case when datestamp>=Prior9Monthsdate And ttype = 'click' then 1 else 0 end) FlagEmailCliksLast9Month
		,Max(case when datestamp>=Prior1Yeardate   And ttype = 'click' then 1 else 0 end) FlagEmailCliksLast1Year
		,Sum(case when datestamp>=Prior3Monthsdate And ttype = 'open' then 1 else 0 end) EmailOpensLast3Month
		,Sum(case when datestamp>=Prior6Monthsdate And ttype = 'open' then 1 else 0 end) EmailOpensLast6Month
		,Sum(case when datestamp>=Prior9Monthsdate And ttype = 'open' then 1 else 0 end) EmailOpensLast9Month
		,Sum(case when datestamp>=Prior1Yeardate   And ttype = 'open' then 1 else 0 end) EmailOpensLast1Year
		,Max(case when datestamp>=Prior3Monthsdate And ttype = 'open' then 1 else 0 end) FlagEmailOpensLast3Month
		,Max(case when datestamp>=Prior6Monthsdate And ttype = 'open' then 1 else 0 end) FlagEmailOpensLast6Month
		,Max(case when datestamp>=Prior9Monthsdate And ttype = 'open' then 1 else 0 end) FlagEmailOpensLast9Month
		,Max(case when datestamp>=Prior1Yeardate   And ttype = 'open' then 1 else 0 end) FlagEmailOpensLast1Year
	Into #CustomerEngagement 
	from #EPC C
	inner join #Engagement E 
	on C.Email = E.Email
	group by C.CustomerId



Begin 
Truncate Table Datawarehouse.marketing.CustomerEngagement

Insert into Datawarehouse.marketing.CustomerEngagement
select C.CustomerID
, C.Currentdate as AsOfDate
, Isnull(CE.CntOfEmails,0) as CntOfEmails
, Isnull(MC.MailCntsLast3Month,0) as MailCntsLast3Month
, Isnull(MC.MailCntsLast6Month,0) as MailCntsLast6Month
, Isnull(MC.MailCntsLast9Month,0) as MailCntsLast9Month
, Isnull(MC.MailCntsLast1Year,0) as MailCntsLast1Year
, Isnull(EC.EmailCntsLast3Month,0) as EmailCntsLast3Month
, Isnull(EC.EmailCntsLast6Month,0) as EmailCntsLast6Month
, Isnull(EC.EmailCntsLast9Month,0) as EmailCntsLast9Month
, Isnull(EC.EmailCntsLast1Year,0) as EmailCntsLast1Year
, Isnull(CE.EmailOpensLast3Month,0) as EmailOpensLast3Month
, Isnull(CE.EmailOpensLast6Month,0) as EmailOpensLast6Month
, Isnull(CE.EmailOpensLast9Month,0) as EmailOpensLast9Month
, Isnull(CE.EmailOpensLast1Year,0) as EmailOpensLast1Year
, Isnull(CE.FlagEmailOpensLast3Month,0) as FlagEmailOpensLast3Month
, Isnull(CE.FlagEmailOpensLast6Month,0) as FlagEmailOpensLast6Month
, Isnull(CE.FlagEmailOpensLast9Month,0) as FlagEmailOpensLast9Month
, Isnull(CE.FlagEmailOpensLast1Year,0) as FlagEmailOpensLast1Year
, Isnull(CE.EmailCliksLast3Month,0) as EmailCliksLast3Month
, Isnull(CE.EmailCliksLast6Month,0) as EmailCliksLast6Month
, Isnull(CE.EmailCliksLast9Month,0) as EmailCliksLast9Month
, Isnull(CE.EmailCliksLast1Year,0) as EmailCliksLast1Year
, Isnull(CE.FlagEmailCliksLast3Month,0) as FlagEmailCliksLast3Month
, Isnull(CE.FlagEmailCliksLast6Month,0) as FlagEmailCliksLast6Month
, Isnull(CE.FlagEmailCliksLast9Month,0) as FlagEmailCliksLast9Month
, Isnull(CE.FlagEmailCliksLast1Year,0) as FlagEmailCliksLast1Year
from 
#Customer C
left join #CustomerEngagement  CE 
on CE.CustomerID = C.CustomerID
left join #EmailContacts  EC 
on EC.CustomerID = C.CustomerID
left join #MailContacts  MC 
on MC.CustomerID = C.CustomerID

END

End




GO
