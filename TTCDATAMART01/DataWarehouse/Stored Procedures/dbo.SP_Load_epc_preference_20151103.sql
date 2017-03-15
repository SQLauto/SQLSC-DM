SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE Proc [dbo].[SP_Load_epc_preference_20151103]
as

Begin

Declare @SQL nvarchar(1000), @Date Varchar(10) = CONVERT(varchar,  GETDATE(), 112)

If DATEPART(d,getdate()) = 1
/* Create SnapShot*/
Begin 

set @SQL = 'select * into archive.epc_preference' + @Date + ' from Marketing.epc_preference'
exec (@SQL)

Print 'EPC Preference Monthly Snapshot Table Created'

End



Truncate table Staging.Temp_epc_preference

/*
/* Exclusion List*/

insert into Staging.Temp_epc_preference

select p.Email
,max(p.snooze_start_date)snooze_start_date,max(p.snooze_end_date)snooze_end_date
,max(case when p.snooze_start_date <= GETDATE() and p.snooze_end_date>= GETDATE() then 1 else 0 end) [Snoozed]
,max(case when O.name = 'New Course Announcements'  then 1 else 0 end) [NewCourseAnnouncements]
,max(case when O.name = 'Free Lectures, Clips and Interviews'  then 1 else 0 end) [FreeLecturesClipsandInterviews]
,max(case when O.name = 'Exclusive Offers' then 1 else 0 end) [ExclusiveOffers]
,max(case when F.name = '1 per week' then 3 
		  when F.name = '2–3 per week' then 2
		  when F.name = 'I’d like to receive all exclusive offers' then 1
		  else 0 end) [Frequency]
--,max(case when F.name = '1 per week' then 1 else 0 end) [1perweek]
--,max(case when F.name = '2–3 per week' then 1 else 0 end) [2-3perweek]
--,max(case when F.name = 'I’d like to receive all exclusive offers' then 1 else 0 end) [ALL]
,max(case when S.category = 'Hard Bounce' then 1 else 0 end) [HardBounce]
,max(case when S.category = 'Blacklist' then 1 else 0 end) [Blacklist]
,max(case when SB.Soft_bounce_flag = 1 then 1 else 0 end) [SoftBounce]
from staging.epc_ssis_preference p 
join staging.epc_ssis_preference_option PO on p.preference_id = po.preference_id
left join staging.epc_ssis_option O on O.option_id = PO.option_id
left join staging.epc_ssis_frequency F on F.frequency_id = PO.frequency_id
left join staging.epc_ssis_email_status S on S.email = P.email
left join Staging.epc_ssis_Soft_Bounce SB on p.email = SB.email
group by p.Email 

/* Inclusion List  Forcing the Emails to Subscribe to all available options default set to 1 (Else)*/


insert into Staging.Temp_epc_preference

select p.Email
,null as snooze_start_date
,null snooze_end_date
,max(case when p.snooze_start_date <= GETDATE() and p.snooze_end_date>= GETDATE() then 1 else 0 end) [Snoozed]
,max(case when O.name = 'New Course Announcements'  then 1 else 1 end) [NewCourseAnnouncements]
,max(case when O.name = 'Free Lectures, Clips and Interviews'  then 1 else 1 end) [FreeLecturesClipsandInterviews]
,max(case when O.name = 'Exclusive Offers' then 1 else 1 end) [ExclusiveOffers]
,max(case when F.name = '1 per week' then 3 
		  when F.name = '2–3 per week' then 2
		  when F.name = 'I’d like to receive all exclusive offers' then 1
		  else 1 end) [Frequency]
,max(case when S.category = 'Hard Bounce' then 1 else 0 end) [HardBounce]
,max(case when S.category = 'Blacklist' then 1 else 0 end) [Blacklist]
,max(case when SB.Soft_bounce_flag = 1 then 1 else 0 end) [SoftBounce]
from staging.epc_ssis_preference p 
left join staging.epc_ssis_preference_option PO on p.preference_id = po.preference_id
left join staging.epc_ssis_option O on O.option_id = PO.option_id
left join staging.epc_ssis_frequency F on F.frequency_id = PO.frequency_id
left join staging.epc_ssis_email_status S on S.email = P.email
left join Staging.epc_ssis_Soft_Bounce SB on p.email = SB.email
left join Staging.Temp_epc_preference mkt on p.email= mkt.email
where mkt.email is null
group by p.Email 

*/

/* Inclusion List only */

insert into Staging.Temp_epc_preference
(Email,snooze_start_date,snooze_end_date,Snoozed,NewCourseAnnouncements,FreeLecturesClipsandInterviews,ExclusiveOffers,Frequency,
Subscribed,HardBounce,Blacklist,SoftBounce,CustomerID,MagentoDaxMapped_Flag,ChildCustomerid,Child_Flag)
select rtrim(ltrim(p.Email))Email
,max(p.snooze_start_date)snooze_start_date,max(p.snooze_end_date)snooze_end_date
,max(case when p.snooze_start_date <= GETDATE() and p.snooze_end_date>= GETDATE() then 1 else 0 end) [Snoozed]
,max(case when O.name = 'New Course Announcements'  then 1 else 0 end) [NewCourseAnnouncements]
,max(case when O.name = 'Free Lectures, Clips and Interviews'  then 1 else 0 end) [FreeLecturesClipsandInterviews]
,max(case when O.name = 'Exclusive Offers' then 1 else 0 end) [ExclusiveOffers]
,max(case when F.name = '1 per week' then 3 
		  when F.name = '2–3 per week' then 2
		  when F.name = 'I’d like to receive all exclusive offers' then 1
		  else 0 end) [Frequency]
--,max(case when F.name = '1 per week' then 1 else 0 end) [1perweek]
--,max(case when F.name = '2–3 per week' then 1 else 0 end) [2-3perweek]
--,max(case when F.name = 'I’d like to receive all exclusive offers' then 1 else 0 end) [ALL]
,cast(MAX(case when po.preference_id IS Null then 0 else 1 end) as int)as Subscribed
,max(case when S.category = 'Hard Bounce' then 1 else 0 end) [HardBounce]
,max(case when S.category = 'Blacklist' then 1 else 0 end) [Blacklist]
,max(case when SB.Soft_bounce_flag = 1 then 1 else 0 end) [SoftBounce]
,null as CustomerID
,0 as MagentoDaxMapped_Flag
,null as ChildCustomerid
,0 as Child_Flag
from staging.epc_ssis_preference p 
left join staging.epc_ssis_preference_option PO on p.preference_id = po.preference_id
left join staging.epc_ssis_option O on O.option_id = PO.option_id
left join staging.epc_ssis_frequency F on F.frequency_id = PO.frequency_id
left join staging.epc_ssis_email_status S on S.email = P.email
left join Staging.epc_ssis_Soft_Bounce SB on p.email = SB.email
group by rtrim(ltrim(p.Email))  


/* Load from Magento and Dax, use Root accounts if available */


select 
 EPC.Email
,case when isnull(M.subscriber_email,'') <> '' then 1 else 0 end as MagentoDaxMapped_Flag
,case when isnull(Cust.JSMERGEDROOT,'') <> '' then Cust.Customerid end as ChildCustomerid
,case when isnull(Cust.JSMERGEDROOT,'') = '' then 0 else 1 end Child_Flag
,CCS.CustomerID
,ROW_NUMBER() over( partition by EPC.Email order by isnull(CCS.NewSeg,100),CCS.LastOrderDate desc) RNK
into #Email
from Staging.Temp_epc_preference EPC
left join MagentoImports..Email_Customer_Information M on M.subscriber_email = EPC.Email
left join DAXImports..CustomerExport Cust on M.dax_customer_id = Cust.Customerid
left join DataWarehouse.Marketing.CampaignCustomerSignature CCS
on CCS.CustomerID = case when isnull(Cust.JSMERGEDROOT,'') <> '' then Cust.JSMERGEDROOT else Cust.Customerid end
--where CCS.CustomerID  <> '' /* 20151005 Code Removed to allow missing customerids */

select Email, COUNT(*) from #Email
group by Email
having COUNT(*)>1


/* Updating records that do have mapping but dont have a valid Customer id*/

update E 
set MagentoDaxMapped_Flag = 0
,ChildCustomerid = null
,Child_Flag = 0
--select * 
from #Email E
where CustomerID is null and MagentoDaxMapped_Flag = 1 


select * from #Email
where MagentoDaxMapped_Flag=1
and CustomerID is null  



/* records that do have mapping Email and can be mapped to a valid dax Customer id*/

select 
 EPC.Email
,0 as MagentoDaxMapped_Flag
,case when isnull(Cust.JSMERGEDROOT,'') <> '' then Cust.Customerid end as ChildCustomerid
,case when isnull(Cust.JSMERGEDROOT,'') = '' then 0 else 1 end Child_Flag
,CCS.CustomerID
,ROW_NUMBER() over( partition by EPC.Email order by isnull(CCS.NewSeg,100),CCS.LastOrderDate desc ,Cust.JSMERGEDROOT desc) RNK
into #Email1
from #Email EPC
join DAXImports..CustomerExport Cust on EPC.EMAIL = Cust.EMAIL
Join DataWarehouse.Marketing.CampaignCustomerSignature CCS
on CCS.CustomerID = case when isnull(Cust.JSMERGEDROOT,'') = '' then Cust.Customerid else Cust.JSMERGEDROOT end
where MagentoDaxMapped_Flag = 0 


--drop table #email1

/* Removing duplicates that have valid email and dax id's*/



delete from #Email1
where RNK >1

select Email,customerid, COUNT(*) from #Email1
group by Email,customerid
having COUNT(*)>1


/* Updating the email and dax id's information */

update E
set E.ChildCustomerid = E1.ChildCustomerid
,E.Child_Flag = E1.Child_Flag
,E.CustomerID = E1.CustomerID
,E.RNK = E1.RNK
,E.MagentoDaxMapped_Flag = E1.MagentoDaxMapped_Flag
from #Email E
inner join #Email1 E1
on E.Email = E1.Email


Update EPC
set Epc.Customerid = E.CustomerID
,EPC.MagentoDaxMapped_Flag = E.MagentoDaxMapped_Flag
,EPC.ChildCustomerid = E.ChildCustomerid
,EPC.Child_Flag=E.Child_Flag
from Staging.Temp_epc_preference EPC
inner join #Email E
on E.Email = Epc.Email

Update EPC
set EPC.MagentoDaxMapped_Flag = 0 ,EPC.CustomerID = null
from Staging.Temp_epc_preference EPC
where isnull(CustomerID,'') = '' 


drop table #email
drop table #email1

Update EPC
set EPC.HardBounce = 0,
	EPC.Blacklist = 0,
	EPC.SoftBounce = 0,
	EPC.Reinstated = 1
from Staging.Temp_epc_preference EPC
inner join Staging.[epc_Reinstated_Email] Re
on Re.Email = EPC.Email


/*Inserting Test IDs*/
insert into Staging.Temp_epc_preference 
(Email,snooze_start_date,snooze_end_date,Snoozed,NewCourseAnnouncements,FreeLecturesClipsandInterviews,ExclusiveOffers,Frequency,Subscribed,HardBounce
,Blacklist,SoftBounce,CustomerID,	MagentoDaxMapped_Flag,	ChildCustomerid,Child_Flag,	Reinstated)
 
select distinct Emailaddress,null snooze_start_date,	null snooze_end_date,0	Snoozed,1 as NewCourseAnnouncements,1 as FreeLecturesClipsandInterviews,1 as ExclusiveOffers,1 as Frequency,1 as Subscribed,0 as HardBounce,0 as Blacklist,0 as SoftBounce,9999999 as CustomerID,1 as MagentoDaxMapped_Flag,null	ChildCustomerid,0 as	Child_Flag,0 as	Reinstated
from   DataWarehouse.Mapping.LCM_WelcomeEmails_TestIDs
 

/*Change Tracking*/
/* I - Inserted */
/* U - Updated/Changed */
/* D - Deleted */


/*Inserted - New*/
Insert into Archive.epc_preference_audit_trail 
select 'New',Temp.Email,Temp.snooze_start_date,Temp.snooze_end_date,Temp.Snoozed,Temp.NewCourseAnnouncements,Temp.FreeLecturesClipsandInterviews,Temp.ExclusiveOffers,Temp.Frequency,
Temp.Subscribed,Temp.HardBounce,Temp.Blacklist,Temp.SoftBounce,Temp.CustomerID,Temp.MagentoDaxMapped_Flag,Temp.ChildCustomerid,Temp.Child_Flag,GETDATE()
from Staging.Temp_epc_preference Temp
left join Marketing.epc_preference EPC
on EPC.Email = Temp.Email
where EPC.Email is null


/*Deleted - Removed*/
Insert into Archive.epc_preference_audit_trail 
select 'Removed',EPC.Email,EPC.snooze_start_date,EPC.snooze_end_date,EPC.Snoozed,EPC.NewCourseAnnouncements,EPC.FreeLecturesClipsandInterviews,EPC.ExclusiveOffers,EPC.Frequency,
EPC.Subscribed,EPC.HardBounce,EPC.Blacklist,EPC.SoftBounce,EPC.CustomerID,EPC.MagentoDaxMapped_Flag,EPC.ChildCustomerid,EPC.Child_Flag,GETDATE()
from  Marketing.epc_preference EPC
left join Staging.Temp_epc_preference Temp
on EPC.Email = Temp.Email
where Temp.Email is null



/*Updated - Changed*/
Insert into Archive.epc_preference_audit_trail 
select   'Changed',Temp.Email,Temp.snooze_start_date,Temp.snooze_end_date,Temp.Snoozed,Temp.NewCourseAnnouncements,Temp.FreeLecturesClipsandInterviews,Temp.ExclusiveOffers,Temp.Frequency,
Temp.Subscribed,Temp.HardBounce,Temp.Blacklist,Temp.SoftBounce,Temp.CustomerID,Temp.MagentoDaxMapped_Flag,Temp.ChildCustomerid,Temp.Child_Flag,GETDATE()
from  Marketing.epc_preference EPC
join Staging.Temp_epc_preference Temp
on EPC.Email = Temp.Email
where  epc.snooze_start_date <> Temp.snooze_start_date 
or epc.snooze_end_date <> Temp.snooze_end_date 
or epc.Snoozed <> Temp.Snoozed
or epc.NewCourseAnnouncements <> Temp.NewCourseAnnouncements
or epc.FreeLecturesClipsandInterviews <> Temp.FreeLecturesClipsandInterviews
or epc.ExclusiveOffers <> Temp.ExclusiveOffers
or epc.Frequency <> Temp.Frequency
or epc.Subscribed <> Temp.Subscribed
or epc.HardBounce <> Temp.HardBounce
or epc.Blacklist <> Temp.Blacklist
or epc.SoftBounce <> Temp.SoftBounce
or epc.CustomerID <> Temp.CustomerID
or epc.MagentoDaxMapped_Flag <> Temp.MagentoDaxMapped_Flag
or epc.ChildCustomerid <> Temp.ChildCustomerid
or epc.Child_Flag <> Temp.Child_Flag

/*Change Tracking Completed*/

Declare @PrevCount int,@NewCount int
select  @PrevCount = Counts from DataWarehouse.Archive.epc_preference_Snapshot
where NewCourseAnnouncements = 1 
and FreeLecturesClipsandInterviews = 1 
and ExclusiveOffers	=1 
and Frequency = 1
and Snoozed	= 0
and Subscribed	= 1
and SnapShotDate = (select MAX(SnapShotDate) from DataWarehouse.Archive.epc_preference_Snapshot ) 

select  @NewCount = COUNT(*) from DataWarehouse.Staging.Temp_epc_preference
where NewCourseAnnouncements = 1 
and FreeLecturesClipsandInterviews = 1 
and ExclusiveOffers	=1 
and Frequency = 1
and Snoozed	= 0
and Subscribed	= 1
and HardBounce = 0 
and SoftBounce = 0 
and Blacklist = 0 
group by NewCourseAnnouncements,FreeLecturesClipsandInterviews,ExclusiveOffers,Frequency,snoozed,Subscribed 
 
select @PrevCount as '@PrevCount', @NewCount as '@NewCount'


/*Only if change is less than */
 if 1.*(@PrevCount-@NewCount)/(@PrevCount)< 0.01 
		 Begin 
				  Begin Tran
					Truncate Table Marketing.epc_preference

					insert into Marketing.epc_preference 
					select * from Staging.Temp_epc_preference 

					/*Create SnapShot*/
					Insert into DataWarehouse.Archive.epc_preference_Snapshot
					select NewCourseAnnouncements,FreeLecturesClipsandInterviews,ExclusiveOffers,Frequency,Snoozed,Subscribed ,COUNT(*) Counts, GETDATE() as SnapShotDate 
					from DataWarehouse.Marketing.epc_preference
					where HardBounce = 0 and SoftBounce = 0 and Blacklist = 0 
					group by NewCourseAnnouncements,FreeLecturesClipsandInterviews,ExclusiveOffers,Frequency,snoozed,Subscribed 
					order by 1,2,3,4,5,6,7

				Commit Tran
		 End 
 else 
 
	/*Send Failure Email*/
		Begin

			DECLARE @p_body as nvarchar(max), @p_subject as nvarchar(max)
			DECLARE @p_recipients as nvarchar(max), @p_profile_name as nvarchar(max)
			SET @p_profile_name = N'DL datamart alerts'
			SET @p_recipients = N'~dldatamartalerts@TEACHCO.com'
			SET @p_subject = N'EPC Failure - Check Preferences or Change Threshold in SP_Load_epc_preference'
			SET @p_body = '<b>EPC Failure - Check Preferences or Change Threshold in SP_Load_epc_preference</b>.'
			EXEC msdb.dbo.sp_send_dbmail
			  @profile_name = @p_profile_name,
			  @recipients = @p_recipients,
			  @body = @p_body,
			  @body_format = 'HTML',
			  @subject = @p_subject

		End

End









GO
