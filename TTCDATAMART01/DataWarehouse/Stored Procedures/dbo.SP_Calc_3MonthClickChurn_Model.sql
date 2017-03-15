SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[SP_Calc_3MonthClickChurn_Model] @Date datetime = null
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


--SCORE_DATE to change:  4/6/2016
--BIZAARVoice INSERTDATE to change: 4/4/2016

	--declare @Date datetime
/* Set Date if not passed as a variable */
	If @Date is null
	Begin
	Set @Date = cast(getdate() as date)
	End

/*Start and End Dates*/
	select dateadd(Month, -3, @Date) as StartDate ,@Date as EndDate

/* EPC Emails and Clicks*/
	select CustomerID , Email as emailaddress, max(ChangeDate) as MaxChangeDate
	into #EPCEmail
	from Datawarehouse.archive.epc_preference_audit_trail
	where ChangeDate between dateadd(Month, -3, @Date) and @Date
	group by CustomerID , Email

	select EPC.Customerid,Count(distinct EPC.Emailaddress) EmailCnts,  Count(*) as EmailClickCount 
	into #EPCEmailClick
	from #EPCEmail EPC 
	join LstMgr.dbo.SM_TRACKING_LOG SM
	on EPC.Emailaddress = SM.Email
	where convert(date,DateStamp) between dateadd(Month, -3, @Date) and  @Date
	and ttype = 'click'
	group by EPC.Customerid

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


	Select isnull(E.Customerid,M.Customerid) Customerid, case when (isnull(EmailPrefCount,1)+ isnull(MailPrefCount,1))>2 then  (isnull(EmailPrefCount,0)+ isnull(MailPrefCount,0))-1 
	else (isnull(EmailPrefCount,0)+ isnull(MailPrefCount,0)) end as PrefChangeCounts
		Into #PrefChanges
		from #EmailPref E
		full outer join #MailPref M
		On E.CustomerID = M.CustomerID

		
--BV ratings
	select Courseid,a.AverageOverallRating 
	into #BVRatings 
	from DataWarehouse.Archive.BV_Ratings a
	where Inserteddate in (select max(Inserteddate) from DataWarehouse.Archive.BV_Ratings where inserteddate <= @Date)


	select t.CustomerID,
	t.FirstDateOrdered,
	t.FirstDateOrdered3Mon,
	t.IntlOrderID
	into #Customers
	from
	( select distinct CustomerID,
	  DateOrdered FirstDateOrdered,
	  dateadd(Month, 3, dateordered) FirstDateOrdered3Mon,
	  OrderID IntlOrderID
	  from DataWarehouse.Marketing.DMPurchaseOrders
	  where SequenceNum=1 and BillingCountryCode='US' and convert(date,DateOrdered)= dateadd(Month, -3, @Date)   
	 ) t
	  where t.CustomerID not in
	  (select distinct CustomerID from
	  DataWarehouse.Marketing.DMPurchaseOrders
	  where SequenceNum>1 and
	  convert(date,DateOrdered) between dateadd(Month, -3, @Date) and  @Date )


/*Pull model variables.*/

	alter table #Customers add
	EmailClickCount int,
	FirstName varchar(50),
	Gender varchar(1),
	Age int,
	IntlSales float,
	IntlSubjectPref varchar(3),
	OptCount int,
	AvgOverallRating float
	--,
	--EmailAddress varchar(50)


	update t1 set
	t1.FirstName=upper(t2.FirstName),
	t1.Gender=t2.Gender,
	t1.Age=round(datediff(day,t2.DateOfBirth,t1.FirstDateOrdered)/365.25-0.5,0),
	t1.IntlSales=t3.IntlPurchAmount,
	t1.IntlSubjectPref=t3.IntlSubjectPref,
	t1.OptCount=t4.PrefChangeCounts,
	t1.EmailClickCount=t5.EmailClickCount
	--t1.EmailAddress=upper(t5.EmailAddress)
	from #Customers t1
	left outer join DataWarehouse.marketing.CampaignCustomerSignature t2 
	on t1.CustomerId=t2.CustomerID
	left outer join
	DataWarehouse.marketing.DMCustomerStatic t3 
	on t1.CustomerID=t3.CustomerID
	left outer join #PrefChanges t4
	on t1.CustomerID=t4.CustomerID
	--(select a.CustomerID, count(*) OptCount from
	--  #Customers a 
	--  left outer join
	--  DataWarehouse.Archive.CustomerOptinTracker b on
	--  a.CustomerID=b.CustomerID and
	--  convert(date,b.AsOfDate) between a.FirstDateOrdered and a.FirstDateOrdered3mon
	--  group by a.CustomerID) t4 on
	--t1.CustomerID=t4.CustomerID
	--left join DataWarehouse.Marketing.DMCustomerStaticEmail 
	--left join #EPCEmail t5 on
	--t1.CustomerID=t5.CustomerID and t5.EmailAddress is not null
	left join #EPCEmailClick t5
	on t1.CustomerID=t5.CustomerID


	--update t1
	--set t1.EmailClickCount=t2.EmailClickCount
	--from #Customers t1
	--left outer join
	--(select upper(Email) EmailAddress, count(*) EmailClickCount
	--from
	--LstMgr.dbo.SM_TRACKING_LOG
	--where (Email is not null)
	--and convert(date,DateStamp) between dateadd(Month, -3, @Date) and  @Date
	--and ttype='click'
	--group by Email) t2 on
	--t1.EmailAddress=t2.EmailAddress


--BV ratings

		select 
		c.customerid,
		OrderID,
		dmoi.Courseid,
		OrderItemID,
		StockItemID,
		TotalSales,
		RANK() over(partition by OrderID order by OrderItemID, TotalParts desc, DMOi.CourseID ) CrsRank
		Into #BVRatingsOrderCourseRank
		from #customers C
		join DataWarehouse.Marketing.DMPurchaseOrderItems DMOI
		on C.Customerid = DMOI.Customerid
		join superstardw.dbo.InvItem Inv
		on DMOI.StockItemID=Inv.UserStockItemID
		where DateOrdered between dateadd(Month, -3, @Date) and  @Date
		and Inv.MediaTypeID in ('DVD','CD','DownloadV','DownloadA','Audio','VHS')

		Delete from #BVRatingsOrderCourseRank
		where CrsRank>5

		alter table #BVRatingsOrderCourseRank
		add AverageOverallRating float

		update t1
		set t1.AverageOverallRating=t2.AverageOverallRating
		from #BVRatingsOrderCourseRank t1
		join #BVRatings t2 
		on t1.CourseID=t2.CourseID

		Update C 
		set AvgOverallRating = AverageOverallRating
		from #customers C
		join (select Customerid,avg(AverageOverallRating)AverageOverallRating 
				from  #BVRatingsOrderCourseRank 
				group by Customerid 
			) BV
		on C.Customerid = BV.Customerid
		
	
	--Impute variable missing values
		update t1 set
		t1.Gender=(case when t1.Gender='U' then t2.Gender else t1.Gender end),
		t1.Age=coalesce(t1.Age,62),
		t1.IntlSales=coalesce(t1.IntlSales,79.9),
		t1.OptCount=coalesce(t1.OptCount,1),
		t1.EmailClickCount=coalesce(t1.EmailClickCount,0),
		t1.AvgOverallRating=coalesce(t1.AvgOverallRating,0)
		from #Customers t1
		left outer join Mapping.GENDER_LOOKUP t2 on
		t1.FirstName=t2.FirstName
	
	--select 
	--OrderID,
	--OrderItemID,
	--StockItemID,
	--TotalParts,
	--t2.CourseID,
	--TotalSales
	--into #BVRating
	--from #Customers t1
	--join 
	--(select OrderID, OrderItemID, StockItemID, TotalParts, CourseID, TotalSales
	--from
	--DataWarehouse.Marketing.DMPurchaseOrderItems
	--where convert(date,DateOrdered)=dateadd(Month, -3, '4/6/2016')) t2
	--on t1.IntlOrderID=t2.OrderID
	--join superstardw.dbo.InvItem t3
	--on t2.StockItemID=t3.UserStockItemID
	--where t3.MediaTypeID in ('DVD','CD','DownloadV','DownloadA','Audio','VHS')

--select 
--OrderID,
--OrderItemID,
--StockItemID,
--TotalSales,
--RANK() over(partition by OrderID order by OrderItemID, TotalParts desc, CourseID ) CrsRank
--into #BVRatingCrsRank
--from #BVRating

--delete from #BVRatingCrsRank
--where CrsRank>5

--alter table #BVRatingCrsRank
--add AverageOverallRating float

--update t1
--set t1.AverageOverallRating=t2.AverageOverallRating
--from #BVRatingCrsRank t1
--join
--(select CourseID, AverageOverallRating
--from DataWarehouse.Archive.BV_Ratings
--where convert(date,InsertedDate)='4/4/2016') t2 on
--substring(t1.StockItemID,3,4)=t2.CourseID
--(3125 row(s) affected)

--select * from #BVRatingCrsRank

--update t1
--set t1.AvgOverallRating=t2.AverageOverallRating
--from #Customers t1
--left outer join
--(select OrderID, avg(AverageOverallRating) AverageOverallRating
--from #BVRatingCrsRank
--group by OrderID) t2 on
--t1.IntlOrderID=t2.OrderID
----(1560 row(s) affected)

--select * from #Customers

--check the distribution of gender, replace missing by first name
--select Gender, count(*)
--from #Customers
--group by Gender

--Gender 
-------- -----------
--U      295
--F      595
--M      670


----Impute variable missing values
--update t1 set
--t1.Gender=(case when t1.Gender='U' then t2.Gender else t1.Gender end),
--t1.Age=coalesce(t1.Age,62),
--t1.IntlSales=coalesce(t1.IntlSales,79.9),
--t1.OptCount=coalesce(t1.OptCount,1),
--t1.EmailClickCount=coalesce(t1.EmailClickCount,0),
--t1.AvgOverallRating=coalesce(t1.AvgOverallRating,0)
--from
--#Customers t1
--left outer join
--TestSummary.dbo.HYANG_GENDER_LOOKUP t2 on
--t1.FirstName=t2.FirstName
--(1560 row(s) affected)


----check the distribution of gender after impute
--select Gender, count(*)
--from #Customers
--group by Gender

--Gender 
-------- -----------
--NULL   82
--F      691
--M      787

--Create transformation of model varibles

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
	ClickCnt_log float,
	Average_Overall_Rating_bin int,
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
	Average_Overall_Rating_bin=(case when AvgOverallRating<=4.5 then 1 else 2 end),
	IntlSubjectPref1=(case when IntlSubjectPref in ('MH','AH') then 1 else 0 end),
	IntlSubjectPref2=(case when IntlSubjectPref in ('PH','FA') then 1 else 0 end),
	IntlSubjectPref3=(case when IntlSubjectPref in ('SC','RL') then 1 else 0 end),
	IntlSubjectPref4=(case when IntlSubjectPref in('LIT','FW') then 1 else 0 end),
	IntlSubjectPref5=(case when IntlSubjectPref in ('PR','EC') then 1 else 0 end),
	IntlSubjectPref6=(case when IntlSubjectPref='HS' or IntlSubjectPref is null then 1 else 0 end),
	Gender_Male=(case when Gender='M' then 1 else 0 end),
	ClickCnt_log=(case when EmailClickCount is not null then log(EmailClickCount+1) else 0 end);
 

--Calculate model scores
	update #Customers set
	Logit =                            (        2.2575    )+
	Age_bin      * (       -0.0641    )+
	Average_Overall_Rating_bin       * (       -0.1381    )+
	ClickCnt_log                     * (       -0.5272    )+
	OptCount                         * (        0.3160    )+
	IntlSales_bin                    * (       -0.1264    )+
	gender_male                      * (       -0.2078    )+
	IntlSubjectPref2                 * (        0.2327    )+
	IntlSubjectPref3                 * (        0.2910    )+
	IntlSubjectPref4                 * (        0.3928    )+
	IntlSubjectPref5                 * (        0.6709    )+
	IntlSubjectPref6                 * (        0.8137    )

	update #Customers set
	ModelScore = 1/(1+exp(-1*Logit))

 

--QC, check the mean of all model predictors and scores
	insert into DataWarehouse.Archive.Customer_3MonthClickChurn_Model_Averages
	select avg(Age_bin*1.0) Avg_Age,
	avg(Average_Overall_Rating_bin*1.0) Avg_Overall_Rating,
	avg(ClickCnt_log*1.0) Avg_ClickCnt,
	avg(OptCount*1.0) Avg_OptCount,
	avg(gender_male*1.0) Avg_Male,
	avg(IntlSales_bin*1.0) Avg_IntlSales,
	avg(IntlSubjectPref2*1.0) Avg_IntlSubjectPref2,
	avg(IntlSubjectPref3*1.0) Avg_IntlSubjectPref3,
	avg(IntlSubjectPref4*1.0) Avg_IntlSubjectPref4,
	avg(IntlSubjectPref5*1.0) Avg_IntlSubjectPref5,
	avg(IntlSubjectPref6*1.0) Avg_IntlSubjectPref6,
	min(ModelScore) Min_ModelScore,
	max(ModelScore) Max_ModelScore,
	avg(ModelScore) Avg_ModelScore,
	getdate()
	from #Customers

	select CustomerID, ModelScore 
	from #Customers
	order by  ModelScore desc


		Insert Into DataWarehouse.marketing.Customer_3MonthClickChurn_Model 
		(CustomerID, ModelScore,Acquireddate,DMUpdateddate,Decile  )
		select C.CustomerID, C.ModelScore,dateadd(Month, -3, @Date),getdate(),case when c.ModelScore>=0.94536 then 1
														 when c.ModelScore>=0.93594  then 2
														 when c.ModelScore>=0.92908  then 3
														 when c.ModelScore>=0.92207  then 4
														 when c.ModelScore>=0.91411  then 5
														 when c.ModelScore>=0.90485  then 6
														 when c.ModelScore>=0.89381  then 7
														 when c.ModelScore>=0.87763  then 8
														 when c.ModelScore>=0.84838  then 9
														 else 10 end  as Decile
 
		from #Customers C
		left join DataWarehouse.marketing.Customer_3MonthClickChurn_Model M
		on C.CustomerID = M.CustomerID
		where M.CustomerID is null  /*Do not insert again for Customers who have been calculated earlier*/

	/*Update Customer FlagEmail value at time of madel score calculation 4/25/2016 julia had requested change and also backfilled for previous customers*/
		Update M
		set M.FlagEmail = C.FlagEmail
		from DataWarehouse.marketing.Customer_3MonthClickChurn_Model M
		join DataWarehouse.Marketing.CampaignCustomerSignature C
		on M.CustomerID = C.CustomerID
		where Cast(DMUpdateddate as date) = Cast(getdate() as date)

		
Drop table #EPCEmail
Drop table #EPCEmailClick
Drop table #EmailPref
Drop table #MailPref
Drop table #PrefChanges
Drop table #BVRatings
Drop table #Customers
Drop table #BVRatingsOrderCourseRank


End



GO
