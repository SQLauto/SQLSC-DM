SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
    
CREATE Proc [Staging].[Sp_Upsell_MarketBasket_SegmentsLogic5]     @ProcessLogic int = 0
as    
Begin    
    



if  @ProcessLogic = 1

Begin    
--Run the Segmentation SP    
    
Exec Staging.SP_Load_tgc_upsell_RECC_SEG    
    
      
/******** pull active courses ********/    
select *     
into #ValidCourses    
from DataWarehouse.Mapping.vwGetCurrentActiveCourseList    
where ReleaseDate< DATEADD(month,-2,cast(getdate() as date))    
order by ReleaseDate    
    
    
/*******************Default Bestseller Logic*******************/    
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
    
/************* Check # of customers and if <500 drop cluster as those customers will get default ranking later ***********/    
    
    
    
select Segment, Row_Number() Over(Order by Segment) As Cluster     
into #ClusterSegmentMap    
from Datawarehouse.staging.tgc_upsell_RECC_SEG    
group by Segment    
    
---MBA Tree Segements --Convert it to ID by Ranks.    
Select a.*,b.customerid    
into #CLUSTERS    
from #ClusterSegmentMap a    
join Datawarehouse.staging.tgc_upsell_RECC_SEG b    
on a.Segment = b.Segment    
    
    
Truncate table archive.tgc_upsell_Logic5CustomerList    
insert into archive.tgc_upsell_Logic5CustomerList    
select *  from #CLUSTERS    
    
       --select * into #CLUSTERS from TESTSUMMARY.DBO.AV_KMEANS_CLUSTERS_CURRENT_09252017    
    
              
       select count(distinct cluster),min(cluster) ,max(cluster) from #CLUSTERS    
    
       delete from #CLUSTERS    
       where  cluster in (    
       select cluster--, count(*)     
       from #CLUSTERS    
       group by cluster    
       having count(*)<500)    
    
    
/************ Customer Purchased Courses in last 5 years**********/    
    
--8920696    
select distinct     
ccs.CustomerID,     
ccp.courseid,    
cluster    
into #CustPurchasedCourse    
from DataWarehouse.Marketing.CampaignCustomerSignature ccs    
join DataWarehouse.marketing.completecoursepurchase ccp    
on ccs.customerid = ccp.customerid    
and ccp.DateOrdered between dateadd(year,-5,getdate()) and getdate()    
join #ValidCourses c on c.courseid = ccp.courseid    
join #CLUSTERS A    
on a.customerid = ccs.customerid    
    
    
    
/**********Julia to check # of courses in the code: only those who purchased more than 1 course in the past 5 years************/    
    
delete c1 from #CustPurchasedCourse c1    
join (select customerid from #CustPurchasedCourse    
         group by customerid    
         having count(distinct courseid) = 1 )c2    
on c1.customerid = c2.customerid    
    
    
/********* Deleteing Clusters where course purchased customer counts are less than 500**********/    
    
       delete from #CustPurchasedCourse    
         where  cluster in (    
         select cluster    
         from #CustPurchasedCourse    
         group by cluster    
         having count(distinct CustomerID)<500)    
    
    
/**************Cluster Course Counts************/    
    
       select cluster,Courseid, count(customerid) CustomerCnts    
       into #CourseCnts    
       from #CustPurchasedCourse    
       group by cluster,Courseid    
    
    
/**************Cluster Course Matrix ************/    
    
       select a.*,rank    
       into #ClusterCourseMatrix    
       from     
       (    
              select *     
              from     
              (select v1.Courseid as PrimaryCourseid,v2.Courseid SecondaryCourseid,cast(v1.Courseparts as int)PrimaryCourseparts,cast(v2.Courseparts as int)SecondaryCourseparts     
              from #ValidCourses v1, #ValidCourses v2    
              where  v1.Courseid <> v2.Courseid)a    
              ,     
    
              (select Cluster,count(distinct customerid) ClusterCustomerCounts     
from #CustPurchasedCourse    
              group by Cluster)b    
       )a    
       left join #Bestsellers best    
       on SecondaryCourseid = best.courseid    
    
Declare @TotalCustCount int ,@TotalCourseCount int, @TotalClusterCount int    
select @TotalCustCount = count(distinct customerid) , @TotalCourseCount = count(distinct courseid)  ,@TotalClusterCount = count(distinct Cluster)    
from #CustPurchasedCourse    
    
select @TotalCustCount as '@TotalCustCount',@TotalCourseCount as '@TotalCourseCount',@TotalClusterCount as '@TotalClusterCount'    
    
/*    
@TotalCustCount @TotalCourseCount @TotalClusterCount    
--------------- ----------------- ------------------    
1102286         654               269    
*/    
    
    
/**************Cluster Purchased Both Courses************/    
    
--Split in 4-5 sets of 100 clusters and loop     
    
    
    
Truncate table Datawarehouse.archive.tgc_upsell_Logic5ListCourseRank    
    
Declare @MinCluster int = 1, @MaxCluster int = 500    
Declare @MinLoopCluster int , @MaxLoopCluster int     
    
set @MinLoopCluster = @MinCluster    
set @MaxLoopCluster =  @MinLoopCluster + 99    
    
       While @MinLoopCluster < @MaxCluster     
    
       Begin    
    
         select @MinLoopCluster '@MinLoopCluster',@MaxLoopCluster '@MaxLoopCluster'    
    
              select     
              C1.Cluster,C1.courseid courseid1, C2.Courseid as Courseid2,count(distinct c1.customerid) CustomerCnts      
              into #BothCoursesPurchased    
              from #CustPurchasedCourse C1    
              join #CustPurchasedCourse C2    
              on c1.customerid = c2.customerid    
              where C1.courseid <> C2.Courseid    
              and C1.Cluster between @MinLoopCluster and @MaxLoopCluster    
              group by c1.Cluster,C1.courseid , C2.Courseid    
    
    
              select min(cluster),max(cluster) from #BothCoursesPurchased    
           
              select C.*,    
              c1.CustomerCnts as PrimaryCoursePurchaseCnts,    
              c2.CustomerCnts as  SecondaryCoursePurchaseCnts,     
              I.CustomerCnts as BothCoursesPurchaseCounts,     
              ClusterCustomerCounts as TotalCustomerCnts,    
              cast(null as Float) as Support,     
              cast(null as Float) as Confidence ,     
              cast(null as Float) as ExpectedConfidence,    
              cast(null as Float) as Lift,     
              Cast(null as Float) as AdjScore     
              Into #Calc    
              from  #ClusterCourseMatrix C    
              left join #CourseCnts C1 on c1.courseid = primaryCourseid and c1.Cluster = c.Cluster    
              left join #CourseCnts C2 on c2.courseid = SecondaryCourseid and c2.Cluster = c.Cluster    
              left join #BothCoursesPurchased I on courseid1 = primaryCourseid and courseid2 = SecondaryCourseid and I.Cluster = c.Cluster    
              where c.Cluster between @MinLoopCluster and @MaxLoopCluster    
    
              update #Calc    
              set Support = (BothCoursesPurchaseCounts*1./TotalCustomerCnts) ,    
              Confidence = (BothCoursesPurchaseCounts*1./PrimaryCoursePurchaseCnts) ,     
              ExpectedConfidence = (SecondaryCoursePurchaseCnts*1./TotalCustomerCnts)     
    
              update #Calc    
              set Lift = Confidence/ExpectedConfidence    
    
              update #Calc    
              set AdjScore =  SQRT (  Support*Confidence*Lift )    
    
/*****************Load into Final Table************************/    
    
              insert into Datawarehouse.archive.tgc_upsell_Logic5ListCourseRank        
              Select * ,Row_number() over(partition by Cluster,PrimaryCourseid order by AdjScore desc,isnull(rank,1000),SecondaryCourseparts desc) as FinalRank    
              from #Calc a    
    
  set @MinLoopCluster =  @MaxLoopCluster + 1    
  set @MaxLoopCluster =  @MinLoopCluster + 99    
    
  Drop table #BothCoursesPurchased    
  Drop table #Calc    
    
End    
  
  
/* Default course 0*/  
insert into Datawarehouse.archive.tgc_upsell_Logic5ListCourseRank (PrimaryCourseid,SecondaryCourseid,Cluster,FinalRank)  
select 0,courseid,Cluster,rank from    
(select distinct cluster from #CustPurchasedCourse )a , #Bestsellers  
  
    
truncate table Datawarehouse.archive.tgc_upsell_Logic5ListCustomerSegment    
insert into Datawarehouse.archive.tgc_upsell_Logic5ListCustomerSegment    
select * from #CLUSTERS    
where cluster in (select distinct cluster from #CustPurchasedCourse)    
     

End --if  @ProcessLogic = 1

    
     
 /*Load Data into Final Tables for Upsell */    
    
    
 /********************* Truncate tables ************************/      
      
 Truncate table Staging.Logic5CustomerList       
 Truncate table Staging.Logic5ListCourseRank       
      
 /********************* Truncate tables ************************/      
    
     
 /*********** Load Customer list ***********/      
    
  INSERT INTO staging.logic5customerlist       
       (customerid,       
        listid)       
    SELECT F.customerid,  LL.ListID     
     FROM   DataWarehouse.mapping.TGC_Upsell_Logic_List LL      
     left join archive.tgc_upsell_Logic5ListCustomerSegment F      
     on  f.cluster = ll.ListName and LL.logicid = 5    
     where F.customerid > 0      
    
  Declare @MaxCustomerListID SmallInt       
        
  select @MaxCustomerListID = ListID      
  from  ( select top 1 listid,count(*)cnt from  [Staging].[Logic5CustomerList]      
    group by listid       
    order by 2 desc      
     ) b      
         
  select @MaxCustomerListID as '@MaxCustomerListID'    
       
   Declare @DefaultListID Smallint    
      
  select @DefaultListID = ListID       
  from mapping.tgc_upsell_logic_list LL       
  where LL.logicid = 5 and ListName = '0'       
    
  select @DefaultListID '@DefaultListID'    
       
    INSERT INTO staging.logic5customerlist       
       (customerid,       
        listid)       
    SELECT CR.customerid,       
     @DefaultListID       
    FROM   DataWarehouse.Marketing.CampaignCustomerSignature CR       
     left join staging.logic5customerlist F      
     on F.CustomerID = Cr.CustomerID      
     where F.CustomerID is null      
     and CR.customerid > 0      
  union       
  select 0, @DefaultListID    
    
    
     
  /********Load Segment Course view Rank ********/      
   Insert into Staging.Logic5ListCourseRank      
      
   SELECT  listid,       
      c.PrimaryCourseid as Courseid,       
      C.FinalRank,      
      c.SecondaryCourseid as UpsellCourseid    
   FROM archive.tgc_upsell_Logic5ListCourseRank C     
   JOIN mapping.tgc_upsell_logic_list LL       
   ON C.Cluster = LL.listname     
   AND LL.logicid = 5       
   Where FinalRank < 501    
       
        
    
   Insert into Staging.Logic5ListCourseRank      
      
   SELECT  @DefaultListID,       
      c.PrimaryCourseid as Courseid,       
      C.FinalRank,      
      c.SecondaryCourseid as UpsellCourseid    
   FROM archive.tgc_upsell_Logic5ListCourseRank C --testsummary.dbo.US_MBA_RecommendList C      
   JOIN mapping.tgc_upsell_logic_list LL       
   ON C.Cluster = LL.listname     
   AND LL.logicid = 5       
   Where FinalRank < 501    
   and LL.ListID=@MaxCustomerListID    
         
      
 /********Load Segment Course view Rank ********/      
     
     
     
End      
     
  
GO
