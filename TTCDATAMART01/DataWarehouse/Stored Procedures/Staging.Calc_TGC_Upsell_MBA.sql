SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Staging].[Calc_TGC_Upsell_MBA]
as
Begin
  
/******** pull active courses ********/
select * 
into #ValidCourses
from DataWarehouse.Mapping.vwGetCurrentActiveCourseList
where ReleaseDate< DATEADD(month,-2,cast(getdate() as date))
order by ReleaseDate

/********** past 5 year purchase **********/

/*
select distinct 
t1.CustomerID, 
t2.OrderID
into #temp1
from (select distinct CustomerID
		from DataWarehouse.Marketing.CampaignCustomerSignature
		where NewSeg in (3,4,5,8,9,10)
		and comboid not like '%highschool%'
		and CountryCode in ('US','USA')) t1
join (select distinct 
		CustomerID, 
		OrderID, 
		SequenceNum
		from
		DataWarehouse.Marketing.DMPurchaseOrders
		where BillingCountryCode in ('US','USA')
		and convert(date,DateOrdered) between dateadd(year,-5,'6/6/2017') and '6/6/2017') t2 
on t1.CustomerID=t2.CustomerID 
*/
 
/*
select distinct 
ccs.CustomerID, 
ccp.OrderID
into #temp1
from DataWarehouse.Marketing.CampaignCustomerSignature ccs
join DataWarehouse.marketing.completecoursepurchase ccp
on ccs.customerid = ccp.customerid
and ccp.DateOrdered between dateadd(year,-5,getdate()) and getdate()
where NewSeg in (3,4,5,8,9,10)
and ccs.comboid not like '%highschool%'
and ccs.CountryCode in ('US','USA')  	 
*/		  


 

select distinct 
ccs.CustomerID, 
--ccp.OrderID
ccp.courseid
into #CustPurchasedCourse
from DataWarehouse.Marketing.CampaignCustomerSignature ccs
join DataWarehouse.marketing.completecoursepurchase ccp
on ccs.customerid = ccp.customerid
and ccp.DateOrdered between dateadd(year,-5,getdate()) and getdate()
join #ValidCourses c on c.courseid = ccp.courseid
where NewSeg in (3,4,5,8,9,10)
and ccs.comboid not like '%highschool%'
and ccs.CountryCode in ('US','USA')  	
and substring(ccp.StockItemID, 1,2) not in ('PT','DT')


/*Julia to check # of courses in the code: only those active multis who purchased more than 1 course in the past 5 years*/
delete c1 from #CustPurchasedCourse c1
join (select customerid from #CustPurchasedCourse
	  group by customerid
	  having count(courseid) = 1 )c2
on c1.customerid = c2.customerid

Declare @TotalCustCount int ,@TotalCourseCount int
select @TotalCustCount = count(distinct customerid) , @TotalCourseCount = count(distinct courseid)  
from #CustPurchasedCourse

select @TotalCustCount as '@TotalCustCount',@TotalCourseCount as '@TotalCourseCount'

/*
DistinctCustCount   DistinctcourseidCount
-----------------	---------------------
311466				647

(1 row(s) affected)
*/


--select top 10 * from #CustPurchasedCourse



/**************Course Mapping ************/

 

select v1.Courseid as PrimaryCourseid,v2.Courseid SecondaryCourseid
into #CourseMatrix
from #ValidCourses v1, #ValidCourses v2
where  v1.Courseid <> v2.Courseid


--select top 10 * from  #CourseMatrix 


--select count(*) from #CustPurchasedCourse
--where Courseid =863
/*Possible while loop in future with courseid filter*/
select C1.courseid courseid1, C2.Courseid as Courseid2,count(distinct c1.customerid) CustomerCnts  
into #BothCoursesPurchased
from #CustPurchasedCourse C1
join #CustPurchasedCourse C2
on c1.customerid = c2.customerid
where C1.courseid <> C2.Courseid
group by C1.courseid , C2.Courseid

select Courseid, count(customerid) CustomerCnts
into #CourseCnts
from #CustPurchasedCourse
group by Courseid
 
/*
select customerid from #CustPurchasedCourse
where courseid =  1132	
intersect
select customerid from #CustPurchasedCourse
where courseid = 1511	

--417,418
--419,256

--drop table #Calc 
*/

select C.*,
cast(Courseparts as int)SecondaryCourseparts,
 c1.CustomerCnts as PrimaryCoursePurchaseCnts,
 c2.CustomerCnts as  SecondaryCoursePurchaseCnts, 
 I.CustomerCnts as BothCoursesPurchaseCounts, 
 @TotalCustCount as TotalCustomerCnts
Into #Calc
from  #CourseMatrix C
left join #CourseCnts C1 on c1.courseid = primaryCourseid
left join #CourseCnts C2 on c2.courseid = SecondaryCourseid
left join #BothCoursesPurchased I on courseid1 = primaryCourseid and courseid2 = SecondaryCourseid
left join #ValidCourses v on v.courseid = SecondaryCourseid
 
/*
select * from #Calc
where primarycourseid = 1132
and secondarycourseid = 1511

select * from #Calc
where secondarycourseid = 1132
and primarycourseid = 1511
*/

/*
PrimaryCourseid	SecondaryCourseid	primaryCourseidCnts	SecondaryCourseidCnts	IntersectCounts
755	869		4536	6989	473
755	1100	4536	3110	205
755	1200	4536	938		95
755	6100	4536	5884	215
755	4863	4536	6269	385
*/

/*
select * from #CourseCnts
where courseid = 1132
select * from #CourseCnts
where courseid = 1511

Select Count(*) from (
select customerid from #CustPurchasedCourse
where courseid =  1132	
intersect
select customerid from #CustPurchasedCourse
where courseid = 1511 )a	
*/

select a.CourseID,sum(Sales) as Sales, count(a.OrderID) as Orders, ROW_NUMBER() over(order by sum(a.Sales) desc) as Rank
Into #Bestsellers
from(select distinct 
       OrderID, 
       t1.CourseID,
       sum(t1.Amount) Sales
       from DataWarehouse.marketing.completecoursepurchase t1
       join #ValidCourses t2
       on t1.CourseID=t2.CourseID
       where DateOrdered between DATEADD(year,-2,getdate()) and getdate()
       and t1.CourseID is not null
       and substring (StockItemID,1,2) not in ('PT','DT')
       group by OrderID,t1.CourseID) as a
group by a.CourseID
having count(a.OrderID) >200

--Add Additional Columns for Calculation based on the below logic.
/*

A	B	C	D	E	F	G	H	I	J	K	L	
Ananalysis_Unit (CourseView)	Associate_Unit (CourseRec)	Associate_Unit_Part	Analysis_Unit_Freq	Associate_Unit_Freq	Co_Occur_Freq	Total_Cust	Support (F/G)	Confidence (F/D)	Expected_Confidence (E/G)	Lift (I/J)	Adj. Score (sqrt(H*I*K))	Rank
101	102	3	1,000	2,100	500	250,000	0.002	0.50	0.0084	59.52	0.244	2
101	103	2	1,000	1,120	750	250,000	0.003	0.75	0.0045	167.41	0.614	1
101	104	2	1,000	800	200	250,000	0.0008	0.20	0.0032	62.50	0.100	3


*/

alter table #Calc add Support Float,Confidence Float, ExpectedConfidence float,Lift Float, AdjScore float 
 
update #Calc
set Support = (BothCoursesPurchaseCounts*1./TotalCustomerCnts) ,
Confidence = (BothCoursesPurchaseCounts*1./PrimaryCoursePurchaseCnts) , 
ExpectedConfidence = (SecondaryCoursePurchaseCnts*1./TotalCustomerCnts) 

update #Calc
set Lift = Confidence/ExpectedConfidence

update #Calc
set AdjScore =  SQRT (  Support*Confidence*Lift )
 

 truncate table staging.TGC_upsell_MBA_CourseRank
 insert into staging.TGC_upsell_MBA_CourseRank
 Select *,
 Row_number() over(partition by PrimaryCourseid order by AdjScore desc,SecondaryCourseparts desc) as FinalRank 
 ,Getdate() as DMLastUpdated
 --into staging.TGC_upsell_MBA_CourseRank
 from #Calc
 
 /* Load BestSeller Ranking as Course 0 for defaults */

 insert into staging.TGC_upsell_MBA_CourseRank (PrimaryCourseid,SecondaryCourseid,FinalRank)
 select 0 as PrimaryCourseid,Courseid as SecondaryCourseid,rank as FinalRank
 from #Bestsellers

 
 select PrimaryCourseid, count(SecondaryCourseid) CourseCounts, min(FinalRank)min_FinalRank, max(FinalRank) max_FinalRank
 from staging.TGC_upsell_MBA_CourseRank
 group by PrimaryCourseid
 order by PrimaryCourseid
 
End 
GO
