SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[SP_Calc_3MonthChurn_Model_DEL] @Date datetime = null
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

--declare @Date datetime = '12/24/2014'

If @Date is null
Begin
Set @Date = cast(getdate()-1 as date)
End


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
	--from(select Customerid,FlagMail,FlagMailPref,FlagNonBlankMailAddress 
		From  DataWarehouse.Archive.CustomerOptinTracker
		where CustomerID is not null and AsOfDate between dateadd(Month, -3, @Date) and @Date
		--group by Customerid,FlagMail,FlagMailPref,FlagNonBlankMailAddress
		--) MailPref
	Group by Customerid


	Select isnull(E.Customerid,M.Customerid) Customerid,  (isnull(EmailPrefCount,0)+ isnull(MailPrefCount,0))  as PrefChangeCounts
		Into #PrefChanges
		from #EmailPref E
		full outer join #MailPref M
		On E.CustomerID = M.CustomerID



	select dateadd(Month, -3, @Date) as StartDate 
	   ,@Date as EndDate


		select t.CustomerID,
		t.FirstDateOrdered,
		t.FirstDateOrdered3Mon
		into #Customers
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

		alter table #Customers add
		FirstName varchar(50),
		Gender varchar(1),
		Age int,
		IntlSales float,
		IntlSubjectPref varchar(3),
		IntlOrderSource varchar(1),
		OptCount int,
		VisitRecencyDays int,
		prodview int


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
											left outer join Datawarehouse.Archive.Omni_Churn_Model_Webvisit d 
											on c.CustomerID=d.CustomerID and convert(date,d.VisitDate) between c.FirstDateOrdered and c.FirstDateOrdered3mon	
									) e
						group by e.CustomerID) t5 
		on t1.CustomerID=t5.CustomerID


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

		alter table #Customers add
		IntlSales_bin int,
		Age_bin int,
		Gender_Male int,
		IntlSubjectPref1 int,
		IntlSubjectPref2 int,
		IntlSubjectPref3 int,
		IntlSubjectPref4 int,
		IntlSubjectPref5 int,
		IntlSubjectPref6 int,
		IntlOrderSource1 int,
		IntlOrderSource2 int,
		IntlOrderSource3 int,
		IntlOrderSource4 int,
		VisitRecencyDays_log float,
		Logit float,
		ModelScore float


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

--(823 row(s) affected)

/*QC, check the mean of all model predictors and scores*/
		select avg(Age_bin*1.0) Avg_Age,
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
		avg(ModelScore) Avg_ModelScore
		from #Customers

		select CustomerID, ModelScore 
		from #Customers
		order by  ModelScore desc


		Insert Into DataWarehouse.mapping.Customer_modelScore_del 
		(CustomerID, ModelScore)
		select CustomerID, ModelScore 
		from #Customers


--drop table #Customers
--Drop table #MailPref
--Drop table #EMailPref
--Drop table #PrefChanges

End
GO
