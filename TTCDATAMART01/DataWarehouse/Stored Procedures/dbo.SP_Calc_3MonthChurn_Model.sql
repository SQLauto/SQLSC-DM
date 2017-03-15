SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[SP_Calc_3MonthChurn_Model] @Date datetime = null
As
Begin
/**********************************************************************************************************************************
Deploy the churn model to identify customers who are least likely to repurchase in their first 12 months, and thus the contact
strategy can be implemented to these customers, in order to reduce overall cost and increase profit.

Model deployments are in 3 steps:
1) Pull customers who made their first purchases on the date 3 months prior to the score date, and did not re-purchase within 3 months.
2) Prepare model variables for the model.
3) Apply the model to the customers pulled and rank them based on model scores.

SCORE_DATE: the date to score customers
WEBVISIT_TABLE: the table includes web visiting information (Three columns: CustomerID, VisitDate and prodviews)

**********************************************************************************************************************************/


--SCORE_DATE to change:  12/24/2014
--WEBVISIT_TABLE to change: testsummary.dbo.HYANG_CHURNMODEL_WEBVISIT

--Customers who made initial purchase on the date 3 months prior to SCORE_DATE, but did not re-purchase within 3 months since initial purchases.

--declare @Date datetime  

/* Set Date if not passed as a variable */
	If @Date is null
	Begin
	Set @Date = cast(getdate() as date)
	End

/*Start and End Dates*/
	select dateadd(Month, -3, @Date) as StartDate ,@Date as EndDate


/*Calculating EPC pref change based on customer-email and then using max email pref changes for the customer*/
	Select  CustomerID,max(CNT)EmailPrefCount
	Into #EmailPref
	From 
		(
			select CustomerID, Email, count(*) CNT
				from (Select CustomerID, Email,Snoozed,NewCourseAnnouncements,FreeLecturesClipsandInterviews,ExclusiveOffers,Frequency 
     					from DataWarehouse.Archive.epc_preference_audit_trail
						where CustomerID is not null and ChangeDate between dateadd(Month, -3, @Date) and @Date
						group by CustomerID, Email,Snoozed,NewCourseAnnouncements,FreeLecturesClipsandInterviews,ExclusiveOffers,Frequency
					  ) EPC
				Group by CustomerID, Email
		) EPCCustomeridEmail
	Group by CustomerID

/*Calculating Mail pref change based on customerid and not inclusing email changes*/

	Select Customerid,Count(*)MailPrefCount
	Into #MailPref
	from(select Customerid,FlagMail,FlagMailPref,FlagNonBlankMailAddress 
		From  DataWarehouse.Archive.CustomerOptinTracker
		where CustomerID is not null and AsOfDate between dateadd(Month, -3, @Date) and @Date
		group by Customerid,FlagMail,FlagMailPref,FlagNonBlankMailAddress
		) MailPref
	Group by Customerid

	Select * into #WebVisits
	from Datawarehouse.Archive.Omni_Churn_Model_Webvisit
	where VisitDate between dateadd(Month, -3, @Date)+1 and @Date  /*Adding 1 day so that we dont consider the initial purchase day's visit*/

	Select isnull(E.Customerid,M.Customerid) Customerid, case when (isnull(EmailPrefCount,1)+ isnull(MailPrefCount,1))>2 then  (isnull(EmailPrefCount,0)+ isnull(MailPrefCount,0))-1 
	else (isnull(EmailPrefCount,0)+ isnull(MailPrefCount,0)) end as PrefChangeCounts
		Into #PrefChanges
		from #EmailPref E
		full outer join #MailPref M
		On E.CustomerID = M.CustomerID


	CREATE TABLE #Customers (
		[CustomerID] [nvarchar](20) NULL,
		[FirstDateOrdered] [datetime] NULL,
		[FirstDateOrdered3Mon] [datetime] NULL,
		[FirstName] [varchar](50) NULL,
		[Gender] [varchar](1) NULL,
		[Age] [int] NULL,
		[IntlSales] [float] NULL,
		[IntlSubjectPref] [varchar](3) NULL,
		[IntlOrderSource] [varchar](1) NULL,
		[OptCount] [int] NULL,
		[VisitRecencyDays] [int] NULL,
		[prodview] [int] NULL,
		[IntlSales_bin] [int] NULL,
		[Age_bin] [int] NULL,
		[Gender_Male] [int] NULL,
		[IntlSubjectPref1] [int] NULL,
		[IntlSubjectPref2] [int] NULL,
		[IntlSubjectPref3] [int] NULL,
		[IntlSubjectPref4] [int] NULL,
		[IntlSubjectPref5] [int] NULL,
		[IntlSubjectPref6] [int] NULL,
		[IntlOrderSource1] [int] NULL,
		[IntlOrderSource2] [int] NULL,
		[IntlOrderSource3] [int] NULL,
		[IntlOrderSource4] [int] NULL,
		[VisitRecencyDays_log] [float] NULL,
		[Logit] [float] NULL,
		[ModelScore] [float] NULL
	) 

	Insert into #Customers (CustomerID,FirstDateOrdered,FirstDateOrdered3Mon)
		select t.CustomerID,
		t.FirstDateOrdered,
		t.FirstDateOrdered3Mon
		--into #Customers
		from
		(select distinct CustomerID,
		  DateOrdered FirstDateOrdered,
		  dateadd(Month, 3, dateordered) FirstDateOrdered3Mon
		  from DataWarehouse.Marketing.DMPurchaseOrders
		  where SequenceNum=1 and
		  BillingCountryCode='US' and
		  convert(date,DateOrdered)=dateadd(Month, -3, @Date)) t
		  where t.CustomerID not in
		  (select distinct CustomerID from
		  DataWarehouse.Marketing.DMPurchaseOrders
		  where SequenceNum>1 and
		  convert(date,DateOrdered) between dateadd(Month, -3, @Date) and @Date)



/*Pull model variables.*/

		--alter table #Customers add
		--FirstName varchar(50),
		--Gender varchar(1),
		--Age int,
		--IntlSales float,
		--IntlSubjectPref varchar(3),
		--IntlOrderSource varchar(1),
		--OptCount int,
		--VisitRecencyDays int,
		--prodview int


		update t1 set
		t1.FirstName=upper(t2.FirstName),
		t1.Gender=t2.Gender,
		t1.Age=round(datediff(day,t2.DateOfBirth,t1.FirstDateOrdered)/365.25-0.5,0),
		t1.IntlSales=t3.IntlPurchAmount,
		t1.IntlSubjectPref=t3.IntlSubjectPref,
		t1.IntlOrderSource=t3.IntlOrderSource,
		t1.OptCount=t4.OptCount,
		t1.VisitRecencyDays=datediff(day,t5.VisitDateLatest,t1.FirstDateOrdered3mon),
		t1.prodview=t5.prodview
		from #Customers t1
		left outer join DataWarehouse.marketing.CampaignCustomerSignature t2 
		on t1.CustomerId=t2.CustomerID
		left outer join DataWarehouse.marketing.DMCustomerStatic t3 
		on t1.CustomerID=t3.CustomerID
		left outer join (select a.CustomerID, Sum(PrefChangeCounts) as OptCount 
						 from #Customers a 
						 left outer join #PrefChanges b /*DataWarehouse.Archive.CustomerOptinTracker b */
						 on a.CustomerID=b.CustomerID /*and convert(date,b.AsOfDate) between a.FirstDateOrdered and a.FirstDateOrdered3mon*/
						 group by a.CustomerID) t4 
		on t1.CustomerID=t4.CustomerID 
		left outer join (select CustomerID, sum(prodview) prodview,max(VisitDate) VisitDateLatest
								from (select c.CustomerID,d.prodview,convert(date,d.VisitDate,120) VisitDate
											from #Customers c
											left outer join #WebVisits d /*Datawarehouse.Archive.Omni_Churn_Model_Webvisit*/
											on c.CustomerID=d.CustomerID /*and convert(date,d.VisitDate) between c.FirstDateOrdered and c.FirstDateOrdered3mon	*/
									) e
						group by e.CustomerID) t5 
		on t1.CustomerID=t5.CustomerID

/* Update VisitRecencyDays to null where VisitRecencyDays are negative due to daydiff and 3 months issue*/

update #Customers
set VisitRecencyDays = null
where VisitRecencyDays<0




/*check the distribution of gender, replace missing by first name*/
		select Gender, count(*)
		from #Customers
		group by Gender



/*Impute variable missing values*/
		update t1 set
		t1.Gender=(case when t1.Gender='U' then t2.Gender else t1.Gender end),
		t1.Age=(case when t1.Age is null then 62 else t1.Age end),
		t1.IntlSales=(case when t1.IntlSales is null then 79.9 else t1.IntlSales end),
		t1.OptCount=(case when t1.OptCount is null then 1 else t1.OptCount end),
		t1.VisitRecencyDays=(case when t1.VisitRecencyDays is null then 200 else t1.VisitRecencyDays end),
		t1.prodview=(case when t1.prodview is null then 0 else t1.prodview end)
		from
		#Customers t1
		left outer join	Datawarehouse.Mapping.GENDER_LOOKUP  t2 
		on t1.FirstName=t2.FirstName
 

/*check the distribution of gender, replace missing by first name*/
		select Gender, count(*)
		from #Customers
		group by Gender

/*Create transformation of model varibles*/

		--alter table #Customers add
		--IntlSales_bin int,
		--Age_bin int,
		--Gender_Male int,
		--IntlSubjectPref1 int,
		--IntlSubjectPref2 int,
		--IntlSubjectPref3 int,
		--IntlSubjectPref4 int,
		--IntlSubjectPref5 int,
		--IntlSubjectPref6 int,
		--IntlOrderSource1 int,
		--IntlOrderSource2 int,
		--IntlOrderSource3 int,
		--IntlOrderSource4 int,
		--VisitRecencyDays_log float,
		--Logit float,
		--ModelScore float


		update #Customers set
		IntlSales_bin=(case when IntlSales <= 49.95 then 1
							when IntlSales <= 62.45 then 2
							when IntlSales <= 109.9 then 3
							when IntlSales <= 204.75 then 4
							else 5 end),
		Age_bin=(case when Age <= 46 then 1
					  when Age <= 62 then 2
					  else 3 end),
		IntlSubjectPref1=(case when IntlSubjectPref in ('MH','AH') then 1 else 0 end),
		IntlSubjectPref2=(case when IntlSubjectPref in ('PH','FA') then 1 else 0 end),
		IntlSubjectPref3=(case when IntlSubjectPref in ('SC','RL') then 1 else 0 end),
		IntlSubjectPref4=(case when IntlSubjectPref in('LIT','FW') then 1 else 0 end),
		IntlSubjectPref5=(case when IntlSubjectPref in ('PR','EC') then 1 else 0 end),
		IntlSubjectPref6=(case when IntlSubjectPref='HS' or IntlSubjectPref is null then 1 else 0 end),
		IntlOrderSource1=(case when IntlOrderSource='M' then 1 else 0 end),
		IntlOrderSource2=(case when IntlOrderSource='P' then 1 else 0 end),
		IntlOrderSource3=(case when IntlOrderSource='W' then 1 else 0 end),
		IntlOrderSource4=(case when IntlOrderSource not in ('M','P','W') then 1 else 0 end),
		VisitRecencyDays_log=log(VisitRecencyDays+1),
		Gender_Male=(case when Gender='M' then 1 else 0 end)
 

		--Calculate model scores
		update #Customers set
		Logit =                            (        0.4729    )+
		Age_bin                          * (       -0.1236    )+
		OptCount                         * (        0.3479    )+
		IntlSales_bin                    * (       -0.1298    )+
		VisitRecencyDays_log             * (        0.2554    )+
		Gender_Male                      * (       -0.2350    )+
		prodview                         * (       -0.0218    )+
		IntlSubjectPref2                 * (        0.2056    )+
		IntlSubjectPref3                 * (        0.3135    )+
		IntlSubjectPref4                 * (        0.4031    )+
		IntlSubjectPref5                 * (        0.5095    )+
		IntlSubjectPref6                 * (        0.6780    )+
		IntlOrderSource2                 * (        0.1641    )+
		IntlOrderSource3                 * (        0.2426    )+
		IntlOrderSource4                 * (        0.1692    )

		update #Customers set
		ModelScore = 1/(1+exp(-1*Logit))


select *  from #Customers


--(823 row(s) affected)
		
		/*Delete if it was run again on the same day*/

		Delete from DataWarehouse.Archive.Customer_3MonthChurn_Model_Averages
		where Cast(DMLastupdatedate as date) = @Date


/*QC, check the mean of all model predictors and scores*/
		Insert into DataWarehouse.Archive.Customer_3MonthChurn_Model_Averages
		select dateadd(Month, -3, @Date) as StartDate ,
		@Date as EndDate,
		avg(Age_bin*1.0) Avg_Age,
		avg(OptCount*1.0) Avg_OptCount,
		avg(IntlSales_bin*1.0) Avg_IntlSales,
		avg(VisitRecencyDays_log) Avg_VisitRecencyDays,
		avg(gender_male*1.0) Avg_Male,
		avg(prodview*1.0) Avg_ProdView,
		avg(IntlSubjectPref2*1.0) Avg_IntlSubjectPref2,
		avg(IntlSubjectPref3*1.0) Avg_IntlSubjectPref3,
		avg(IntlSubjectPref4*1.0) Avg_IntlSubjectPref4,
		avg(IntlSubjectPref5*1.0) Avg_IntlSubjectPref5,
		avg(IntlSubjectPref6*1.0) Avg_IntlSubjectPref6,
		avg(IntlOrderSource2*1.0) IntlOrderSource2,
		avg(IntlOrderSource3*1.0) IntlOrderSource3,
		avg(IntlOrderSource4*1.0) IntlOrderSource4,
		min(ModelScore) Min_ModelScore,
		max(ModelScore) Max_ModelScore,
		avg(ModelScore) Avg_ModelScore,
		getdate() as DMLastupdatedate
		from #Customers

		/* Delete data if it was run again on the same day*/
		Delete from DataWarehouse.marketing.Customer_3MonthChurn_Model 
		where Acquireddate = dateadd(Month, -3, @Date)


		Insert Into DataWarehouse.marketing.Customer_3MonthChurn_Model 
		(CustomerID, ModelScore,Acquireddate,DMUpdateddate,Decile  )
		select C.CustomerID, C.ModelScore,dateadd(Month, -3, @Date),getdate(),case when c.ModelScore>=0.9422180 then 1
														 when c.ModelScore>=0.932371  then 2
														 when c.ModelScore>=0.9258123  then 3
														 when c.ModelScore>=0.9177596  then 4
														 when c.ModelScore>=0.9105493  then 5
														 when c.ModelScore>=0.9019219  then 6
														 when c.ModelScore>=0.8919450  then 7
														 when c.ModelScore>=0.8807303  then 8
														 when c.ModelScore>=0.8623876  then 9
														 else 10 end  as Decile
 
		from #Customers C
		left join DataWarehouse.marketing.Customer_3MonthChurn_Model M
		on C.CustomerID = M.CustomerID
		where M.CustomerID is null /*Do not insert again for Customers who have been calculated earlier*/

	/*Update Customer FlagEmail value at time of madel score calculation 4/25/2016 julia had requested change and also backfilled for previous customers*/
		Update M
		set M.FlagEmail = C.FlagEmail
		from DataWarehouse.marketing.Customer_3MonthChurn_Model M
		join DataWarehouse.Marketing.CampaignCustomerSignature C
		on M.CustomerID = C.CustomerID
		where Cast(DMUpdateddate as date) = Cast(getdate() as date)


/*

select * from DataWarehouse.Archive.epc_preference_audit_trail
where customerid in (51381959)
order by ChangeDate desc

 select * from DataWarehouse.Marketing.Customer_3MonthChurn_Model


select C.CustomerID,max(ChangeDate) MAX_ChangeDate
into #EPC_MAX_ChangeDate
from DataWarehouse.Marketing.Customer_3MonthChurn_Model C
left join DataWarehouse.Archive.epc_preference_audit_trail EPC
on EPC.CustomerID = C.CustomerID
and C.DMUpdateddate>=ChangeDate
group by  C.CustomerID


select C.CustomerID,C.MAX_ChangeDate,
EPC.Blacklist,EPC.HardBounce,EPC.SoftBounce, EPC.Subscribed,EPC.Email
Into #EPC
from #EPC_MAX_ChangeDate c
Left join DataWarehouse.Archive.epc_preference_audit_trail EPC
on EPC.CustomerID = C.CustomerID
and EPC.ChangeDate=c.MAX_ChangeDate


		select Customerid, max(FlagValidEmail) as FlagValidEmail,isnull(max(FlagEmailPref),0) as FlagEmailPref ,max(FlagEmail) as FlagEmail
		into #CustomerEmailPref 
			from  (select Customerid,Email,FlagValidEmail, FlagEmailPref 
					,case when FlagValidEmail + FlagEmailPref = 2 then 1 else 0 end as FlagEmail 
					from	(
							select CustomerID, Email,
							case when Blacklist+SoftBounce+HardBounce = 0 and Email like '%@%' 
								then 1 else 0 end as FlagValidEmail,Subscribed as FlagEmailPref
							from #EPC
							where CustomerID is not null
							)a
				  )b
			group by CustomerID 


--34,540


 select m.*,C.FlagEmail,c.FlagEmailPref,c.FlagValidEmail from DataWarehouse.Marketing.Customer_3MonthChurn_Model m
 left join #CustomerEmailPref c
 on m.CustomerID = c.CustomerID
 where FlagEmailPref	= 1 and FlagValidEmail =1

 select FlagEmail,FlagValidEmail,FlagEmailPref,count(*) 
 From DataWarehouse.Marketing.CampaignCustomerSignature
 group by FlagEmail	,FlagValidEmail	,FlagEmailPref


 
 		Update M
		set M.FlagEmail = C.FlagEmail
		--select M.*
		from DataWarehouse.marketing.Customer_3MonthChurn_Model M
		join #CustomerEmailPref C
		on M.CustomerID = C.CustomerID
		where Cast(DMUpdateddate as date) < Cast(getdate() as date)
*/

Drop table #Customers
Drop table #MailPref
Drop table #EMailPref
Drop table #PrefChanges

End



 



GO
