SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Staging].[SP_MC_TGC_ContactPreferenceExtended] @AsofDate Date = Null 
as
Begin

/*
If We want last month to refresh then we do not need to pass any parameters.
*/

if @AsofDate is null
begin
select @AsofDate =  Cast(DATEADD(month, DATEDIFF(month, 0, getdate()), 0) as date)
End

Declare @SQL Nvarchar(4000) , @AsofDateInt varchar(8)  

set @AsofDateInt = CONVERT(VARCHAR(10),@AsofDate, 112)

If Datepart(d,@AsofDate)<> 1
begin

print 'Incorrect Date parameter'
return 0
End

Truncate table [staging].[MC_TGC_ContactPreferenceExtended]



	set @SQL = 	'If object_id(''Staging.MC_TGC_ContactPreferenceExtended_Email'') is not null
				Begin 
				Drop table Staging.MC_TGC_ContactPreferenceExtended_Email
				End 

  select Customerid, 
		count(*) as DistinctEmailCounts,
		max(Case when NewCourseAnnouncements = 1 then 1 else 0 end) NewCourseAnnouncements,
		max(Case when FreeLecturesClipsandInterviews = 1 then 1 else 0 end)FreeLecturesClipsandInterviews,	
		max(Case when ExclusiveOffers = 1 then 1 else 0 end)ExclusiveOffers,
		max(Case when Frequency in (1,2,3) then 1 else 0 end)Frequency,
		max(FlagValidEmail) as FlagValidEmail,
		max(FlagEmail) as FlagEmailable
   into Staging.MC_TGC_ContactPreferenceExtended_Email         
   from  (select 
				Customerid,
				Email,
				case when Blacklist+SoftBounce+HardBounce = 0 and Email like ''%@%'' then 1 else 0 end AS FlagValidEmail, 
				case when (case when Blacklist+SoftBounce+HardBounce = 0 and Email like ''%@%'' then 1 else 0 end) + Subscribed = 2 
					 then 1 
					 else 0 end as FlagEmail ,
				NewCourseAnnouncements,
				FreeLecturesClipsandInterviews,
				ExclusiveOffers,
				Frequency        
				from DataWarehouse.Archive.epc_preference' + Cast(@AsofDateInt as Varchar(8)) + '    
				where isnull(CustomerID,'''') <>''''
			)a        
			       
   group by CustomerID 


   If object_id(''Staging.MC_TGC_ContactPreferenceExtended_mail'') is not null
				Begin 
				Drop table Staging.MC_TGC_ContactPreferenceExtended_mail
				End 

   	  SELECT Customerid, FlagMailPref,FlagMail 
	  into Staging.MC_TGC_ContactPreferenceExtended_mail
	  from DataWarehouse.Archive.CampaignCustomerSignature'+ Cast(@AsofDateInt as Varchar(8)) + '    
	  where isnull(CustomerID,'''') <>'''' '

	  Exec (@SQL)


	If object_id('Staging.MC_TGC_ContactPreferenceExtended') is not null
				Begin 
				Drop table Staging.MC_TGC_ContactPreferenceExtended
				End 

	  select @AsofDate as AsofDate,Coalesce(M.CustomerID,E.CustomerID) CustomerID, 
		Isnull(E.DistinctEmailCounts,0)DistinctEmailCounts,
		Isnull(E.NewCourseAnnouncements,0)NewCourseAnnouncements,
		Isnull(E.FreeLecturesClipsandInterviews,0)FreeLecturesClipsandInterviews,
		Isnull(E.ExclusiveOffers,0)ExclusiveOffers,
		Isnull(E.Frequency,0)Frequency,
		Isnull(E.FlagValidEmail,0)FlagValidEmail,
		Isnull(E.FlagEmailable,0)FlagEmailable,
		Isnull(M.FlagMail,0)FlagMail,
		Isnull(M.FlagMailPref,0)FlagMailPref
		into Staging.MC_TGC_ContactPreferenceExtended
	  from Staging.MC_TGC_ContactPreferenceExtended_mail M
	  full outer join Staging.MC_TGC_ContactPreferenceExtended_Email  E
	  on E.CustomerID = M.CustomerID


--Deletes
	   delete A from [Marketing].[MC_TGC_ContactPreferenceExtended] A
	   join [staging].[MC_TGC_ContactPreferenceExtended] S
	   on S.Asofdate = A.AsofDate

--Inserts
insert into [Marketing].[MC_TGC_ContactPreferenceExtended]
(Asofdate,Customerid,DistinctEmailCounts,NewCourseAnnouncements,FreeLecturesClipsandInterviews,ExclusiveOffers,Frequency,FlagValidEmail,FlagEmailable,FlagMailPref,FlagMail)

select Asofdate,Customerid,DistinctEmailCounts,NewCourseAnnouncements,FreeLecturesClipsandInterviews,ExclusiveOffers,Frequency,FlagValidEmail,FlagEmailable,FlagMailPref,FlagMail
from [staging].[MC_TGC_ContactPreferenceExtended]


/*

--Historical data load example


insert into [Marketing].[MC_TGC_ContactPreferenceExtended]
(Asofdate,Customerid,DistinctEmailCounts,NewCourseAnnouncements,FreeLecturesClipsandInterviews,ExclusiveOffers,Frequency,FlagValidEmail,FlagEmailable,FlagMailPref,FlagMail)


select 
Asofdate,
Customerid,
Case when FlagEmailable + FlagEmailValid + FlagEmailPref > 0 then 1 else 0 end as DistinctEmailCounts,
FlagEmailPref as NewCourseAnnouncements,
FlagEmailPref as FreeLecturesClipsandInterviews,
FlagEmailPref as ExclusiveOffers,
FlagEmailPref as Frequency,
FlagEmailValid as FlagValidEmail,
FlagEmailable,
FlagMailPref,
FlagMailable
from DataWarehouse.Marketing.DMCustomerDynamic
where Year(AsOfDate) = 2012


*/
End
GO
