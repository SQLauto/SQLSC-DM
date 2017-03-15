SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [Staging].[Sp_6monthNonEngagedEmails]
as

Begin

/* proc to create NonEngaged Email list in the last 6 months for the current Email Subscription*/

select * 
Into #Temp			
from DataWarehouse.Archive.SM_TRACKING_LOG	 (Nolock)		
where datestamp >= DATEADD(MONTH, -6,convert(datetime,convert(varchar,getdate(),101)))

 select distinct Replace(Email,' ','') Email			
 Into #EngagedEmails			
 from #Temp			
 where ttype in ('open','view','click') 			
	

Truncate table Datawarehouse.marketing.NonEngagedEmails

Insert into Datawarehouse.marketing.NonEngagedEmails
select EPC.Email
from DataWarehouse.Marketing.epc_preference Epc  (Nolock)
left join #EngagedEmails E
on EPC.Email = E.Email
where E.Email is null
and Subscribed = 1
and HardBounce  + Blacklist  + SoftBounce= 0
and len(Substring(EPC.Email,CHARINDEX('@',EPC.Email),len(EPC.Email)))>3
Group by EPC.Email


		select Emailaddress 
		into #EmailHistory
		from DataWarehouse.Archive.EmailhistoryPrior1Year (Nolock)
		where 1 = 0

If datepart(m,Getdate())<7
	Begin 
		Insert into #EmailHistory
		select Emailaddress 
		from DataWarehouse.Archive.EmailhistoryPrior1Year (Nolock)
		where StartDate >=DATEADD(MONTH, -6,convert(datetime,convert(varchar,getdate(),101)))
		group by Emailaddress
		Union 
		select Emailaddress 
		from DataWarehouse.Archive.EmailhistoryCurrentYear (Nolock)
		where StartDate >=DATEADD(MONTH, -6,convert(datetime,convert(varchar,getdate(),101)))
		group by Emailaddress
	End

Else 
	Begin
	Insert into #EmailHistory
		select Emailaddress 
		from DataWarehouse.Archive.EmailhistoryCurrentYear (Nolock)
		where StartDate >=DATEADD(MONTH, -6,convert(datetime,convert(varchar,getdate(),101)))
		group by Emailaddress

	End

/*Add all the emails that were part Email history*/
	Insert into #EmailHistory
	select PRS.Emailaddress from 
	(select emailaddress from DataWarehouse.Archive.EmailhistoryPRSPCT
	where StartDate >=DATEADD(MONTH, -6,convert(datetime,convert(varchar,getdate(),101)))
	Group by emailaddress) PRS
	left join #EmailHistory EH
	on prs.Emailaddress = EH.Emailaddress
	where EH.Emailaddress is null

select top 10  * from Datawarehouse.marketing.NonEngagedEmails
where email not in (select emailaddress from #EmailHistory)

select * from DataWarehouse.Marketing.epc_preference
where Email = 'anthony.viceroy@dasglobal.com'  

select * from DataWarehouse.Marketing.Vw_EPC_EmailPull
where Emailaddress = 'anthony.viceroy@dasglobal.com'  
 
select *
from DataWarehouse.Archive.EmailhistoryCurrentYear (Nolock)
where  Emailaddress = 'anthony.viceroy@dasglobal.com' 

End

GO
