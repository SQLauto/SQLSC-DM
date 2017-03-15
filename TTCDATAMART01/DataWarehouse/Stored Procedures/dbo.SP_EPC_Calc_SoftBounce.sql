SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE Proc [dbo].[SP_EPC_Calc_SoftBounce]
as
Begin


/* Logic for Reset*/
/*
1) First time Soft bounce is recorded with count of soft bounces.
2) Then Counter starts and is incremented everytime a Soft bounce is recieved and the soft bounce tstamp is updated.
3) The second process to update this table will be included while the emails are being archived to history.
4) We have 2 dates that will help with the Soft bounce Counter, Soft bounce last soft bounce date and last email send dates.
5) Since we have to reset everytime a email is send successfully.
6) We will reset Soft bounce counter to 0 when we send 2 emails and the soft bounce Date is less than the last sent email. (or when greater than datediff of 2 days)

*/


/* Initial Insert */

insert into staging.epc_ssis_Soft_Bounce  

select S.email
	,max(transaction_date) last_Soft_Bounce_date
	,cast(COUNT(*) as int) as Soft_Bounce_Count
	, GETDATE() as last_Email_Sent_date
	,cast(0 as int)Email_Sent_Count
	,cast(0 as int)Soft_bounce_flag  
--into staging.epc_ssis_Soft_Bounce 
from Staging.epc_ssis_email_status S 
left join Staging.epc_ssis_Soft_Bounce SB
on S.email = SB.Email
where S.category = 'Soft Bounce'
and SB.Email is null
group by S.email


/* Update */ 
/* Add new soft bounce counts to previous and update date to latest*/

Update SB
set last_Soft_Bounce_date = S.transaction_date
	, Soft_Bounce_Count = S.Soft_Bounce_Count
from staging.epc_ssis_Soft_Bounce SB 
inner join 
(select  SB.Email,MAX(S.transaction_date) transaction_date,Soft_Bounce_Count + COUNT(S.transaction_date) as Soft_Bounce_Count
from staging.epc_ssis_Soft_Bounce SB
inner join staging.epc_ssis_email_status S 
on S.email = SB.Email
and S.transaction_date > SB.last_Soft_Bounce_date
where S.category = 'Soft Bounce'
group by SB.Email,Soft_Bounce_Count) S
on SB.Email = S.Email


/* Update Soft Bounce Flag where Soft bounce Counter greater than 7*/

Update SB
set Soft_Bounce_flag = 1
from staging.epc_ssis_Soft_Bounce SB 
where Soft_Bounce_Count >=7
and Soft_Bounce_flag <> 1

End

GO
