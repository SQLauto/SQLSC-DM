SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[StripeDunningReport]
as
Begin

/*

1) Check Initial failure after 4/15/2017, changed to start from year 2016, Tag this as failire and check to see if there were any previous failure in last 7 days, if exists ignore as initail failure.

2) loop simialarly till max stripe date ignoring if customer has failures in previous7 days. 

3) tie back number of records that were retried based on these initial failures.

4) similarly calculate success,failures and dunning retries.

5) Loop to get the start of failure/Success etc looking back 7 days.    

*/

 

----------------------------------------------------------------------------------------------------------------------------------------------------                                                                                                                                                                                                                    
--------------------------------------------------------------------------/*Stripe transactions*/---------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @Startdate DATE,@Enddate DATE, @loopdate DATE   


Truncate table Archive.Stripe_transactions_report



Insert into Archive.Stripe_transactions_report                                                                                                          
SELECT *                                                                                                      
FROM DataWarehouse.Archive.Stripe_transactions                                                                                                        
--WHERE created >='4/15/2017' /* VL has asked us to consider dunning processes data after this date*/                                                                                                              
WHERE year(created) >=2016                                                                                                             

----------------------------------------------------------------------------------------------------------------------------------------------------                                                                                                                                                                                                                    
------------------------------------------------------------------------/*Initial Failures*/--------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------


SELECT @Startdate = CAST(MIN(created) AS DATE), @Enddate = CAST(Max(created) AS DATE)                                                                                                          
FROM Archive.Stripe_transactions_report                                                                                                        
                                                                                                              
SELECT @Startdate, @Enddate                                                                                                             
SET @loopdate =  @Startdate    

--Initial Load Stripe failures                                                                                                    
SELECT userId_metadata,MIN(created)created                                                                                                            
INTO #InitialStripeFailure                                                                                                       
FROM Archive.Stripe_transactions_report                                                                                                        
WHERE CAST(created AS DATE) = @loopdate                                                                                                        
AND Status ='Failed'                                                                                                             
AND userId_metadata NOT IN (SELECT userId_metadata  FROM Archive.Stripe_transactions WHERE CAST(created AS DATE) BETWEEN DATEADD(d,-8,@loopdate) AND DATEADD(d,-1,@loopdate) )                                                                                                             
GROUP BY userId_metadata                                                                                                         
                                                                                                             
 SET @loopdate = DATEADD(d,1,@loopdate)                                                                                                         
                                                                                                              
       WHILE (@loopdate<= @Enddate)                                                                                                      
                                                                                                              
          BEGIN                                                                                           
                                                                                                             
              INSERT INTO  #InitialStripeFailure                                                                                               
              
			  SELECT userId_metadata,MIN(created)created                                                                                              
              FROM Archive.Stripe_transactions_report                                                                                          
              WHERE CAST(created AS DATE) = @loopdate AND Status ='Failed'                                                                                          
              AND userId_metadata NOT IN (SELECT userId_metadata  FROM Archive.Stripe_transactions WHERE CAST(created AS DATE) BETWEEN DATEADD(d,-8,@loopdate) AND DATEADD(d,-1,@loopdate) )                                                                                         
              GROUP BY userId_metadata                                                                                           
                                                                                                              
              SET @loopdate = DATEADD(d,1,@loopdate)                                                                                           
                                                                                                              
          End                                                                                             
                                                                                                              
                                                                                                              
	SELECT F.*, DATEADD(d,7,F.created)createdplus7days,MAX(S.created)Finalcreated,CardFunding,COUNT(*) AS CardTrials, cast(null as VARCHAR(10)) Status
	INTO #StripeFailures                                                                                                             
	FROM Archive.Stripe_transactions_report s                                                                                                             
	JOIN #InitialStripeFailure F                                                                                                            
	 ON f.userId_metadata = s.userId_metadata                                                                                                              
	 AND S.created BETWEEN F.created AND DATEADD(d,7,F.created)                                                                                                          
	GROUP BY f.userId_metadata ,f.created    ,DATEADD(d,7,F.created),CardFunding                                                                                               
                                                                                                             
	UPDATE cct                                                                                                         
	SET cct.status = s.status                                                                                                       
	FROM #StripeFailures cct                                                                                                        
	JOIN  Archive.Stripe_transactions_report s                                                                                                           
	ON cct.userId_metadata = s.userId_metadata AND cct.Finalcreated = s.created                                                                                                            
                                                                                                             
                                                                                                                                  
	truncate table Archive.Stripe_Failures_Report                                                                                                             

	Insert INTO Archive.Stripe_Failures_Report                                                        

	SELECT * , CASE WHEN Complete + Failed = 1 THEN 'Completed'                                                                                                 
							   WHEN Originalbillingdate IS NULL THEN 'Not in Dunning'                                                                                    
							   ELSE 'Dunning not Completed' END 'DunningCompleted'     
							   , getdate()                                                                          
                                                                                                           
	FROM #StripeFailures SF                                                                                                           
	LEFT JOIN (                                                                                                          
	select  userid,MIN(DeclinedDate)DeclinedDate,MAX(Nextretrydate)Nextretrydate,Originalbillingdate, sum(case when RetryStatus ='RETRY' then 1 else 0 end) + sum(case when RetryStatus ='COMPLETED' then 1 else 0 end)  Retry,                                                                                                        
	sum(case when RetryStatus ='COMPLETED' then 1 else 0 end) as Complete , sum(case when RetryStatus ='SUSPENDED' then 1 else 0 end) Failed                                                                                                          
	from DataWarehouse.Archive.TGCPLus_CreditcardretryReport    
	where declinedcode not in  ('ANDROIDDUNNINGCODE','IOSDUNNINGCODE')        /*Filtered to exclude IOS and Android*/                                                                                                 
	group by userid,Originalbillingdate) ccr                                                                                                        
	ON ccr.UserID =  Sf.userId_metadata AND CAST(created AS DATE) = CAST(ccr.DeclinedDate AS DATE)                                                                                                                
                                                                                                       
----------------------------------------------------------------------------------------------------------------------------------------------------                                                                                                                                                                                                                    
--------------------------------------------------------------------------/*Stripe Success*/--------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
                                                                                                              
                                                                                                  
--DECLARE @Startdate DATE,@Enddate DATE, @loopdate DATE 
SELECT @Startdate = CAST(MIN(created) AS DATE), @Enddate = CAST(Max(created) AS DATE)                                                                                                          
 FROM Archive.Stripe_transactions_report                                                                                                        
                                                                                                              
SELECT @Startdate, @Enddate                                                                                                             
SET @loopdate =  @Startdate                                                                                                             
                                                                                                              
                                                                                                             
                                                                                                       
SELECT userId_metadata,MIN(created)created                                                                                                            
INTO #FirstAttemptStripePasses                                                                                                          
FROM Archive.Stripe_transactions_report                                                                                                        
WHERE CAST(created AS DATE) = @loopdate                                                                                                        
 AND Status ='paid'                                                                                                        
AND userId_metadata NOT IN (SELECT userId_metadata  FROM Archive.Stripe_transactions WHERE CAST(created AS DATE) BETWEEN DATEADD(d,-8,@loopdate) AND DATEADD(d,-1,@loopdate) )                                                                                                             
GROUP BY userId_metadata                                                                                                         
                                                                                                             
 SET @loopdate = DATEADD(d,1,@loopdate)                                                                                                         
                                                                                                              
       WHILE (@loopdate<= @Enddate)                                                                                                      
                                                                                                              
              BEGIN                                                                                           
                                                                                                             
              INSERT INTO  #FirstAttemptStripePasses                                                                                           
              SELECT userId_metadata,MIN(created)created                                                                                              
              FROM Archive.Stripe_transactions_report                                                                                          
              WHERE CAST(created AS DATE) = @loopdate AND Status ='paid'                                                                                            
              AND userId_metadata NOT IN (SELECT userId_metadata  FROM Archive.Stripe_transactions WHERE /* Status <>'paid' and */ CAST(created AS DATE) BETWEEN DATEADD(d,-8,@loopdate) AND DATEADD(d,-1,@loopdate) )                                                                                                
              GROUP BY userId_metadata                                                                                           
                                                                                                              
              SET @loopdate = DATEADD(d,1,@loopdate)                                                                                           
                                                                                                              
       End                                      
       
       
                                                              
Truncate table Archive.Stripe_Success_Report                                                                                                              

Insert INTO Archive.Stripe_Success_Report 
  
SELECT F.*, DATEADD(d,7,F.created)createdplus7days,MAX(S.created)Finalcreated,CardFunding,COUNT(*) AS CardTrials,getdate()                                                                                                        
FROM Archive.Stripe_transactions_report s                                                                                                             
JOIN #FirstAttemptStripePasses F                                                                                                        
 ON f.userId_metadata = s.userId_metadata                                                                                                              
 AND S.created BETWEEN F.created AND DATEADD(d,7,F.created)                                                                                                          
GROUP BY f.userId_metadata ,f.created    ,DATEADD(d,7,F.created),CardFunding                                                                                               
                          
						  
						  
                                                                                               
----------------------------------------------------------------------------------------------------------------------------------------------------                                                                                                                                                                                                                    
-----------------------------------------------------------------/*Stripe All Transactions*/--------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
                                                                                                              
                                                                                                     
       
--DECLARE @Startdate DATE,@Enddate DATE, @loopdate DATE 
SELECT @Startdate = CAST(MIN(created) AS DATE), @Enddate = CAST(Max(created) AS DATE)                                                                                                          
FROM Archive.Stripe_transactions_report                                                                                                        
                                                                                                              
SELECT @Startdate, @Enddate                                                                                                             
SET @loopdate =  @Startdate                                                                                                             
                                                                                                              
                                                                                                             
                                                                                                  
SELECT userId_metadata,MIN(created)created                                                                                                            
INTO #AllStripetransactions                                                                                                      
FROM Archive.Stripe_transactions_report                                                                                                        
WHERE CAST(created AS DATE) = @loopdate                                                                                                        
AND userId_metadata NOT IN (SELECT userId_metadata  FROM Archive.Stripe_transactions WHERE CAST(created AS DATE) BETWEEN DATEADD(d,-8,@loopdate) AND DATEADD(d,-1,@loopdate) )                                                                                                             
GROUP BY userId_metadata                                                                                                         
                                                                                                             
 SET @loopdate = DATEADD(d,1,@loopdate)                                                                                                         
                                                                                                              
       WHILE (@loopdate<= @Enddate)                                                                                                      
                                                                                                              
              BEGIN                                                                                           
                                                                                                             
              INSERT INTO  #AllStripetransactions                                                                                           
              SELECT userId_metadata,MIN(created)created                                                                                              
              FROM Archive.Stripe_transactions_report                                                                                          
              WHERE CAST(created AS DATE) = @loopdate                                                                                            
              AND userId_metadata NOT IN (SELECT userId_metadata  FROM Archive.Stripe_transactions WHERE CAST(created AS DATE) BETWEEN DATEADD(d,-8,@loopdate) AND DATEADD(d,-1,@loopdate) )                                                                                                
              GROUP BY userId_metadata                                                                                           
                                                                                                              
              SET @loopdate = DATEADD(d,1,@loopdate)                                                                                           
                                                                                                              
       End                                      
       
       
       --select userId_metadata, count(*)  from #FirstAttemptStripePasses
       --group by userId_metadata
       --having count(*)>1
                                                              
Truncate table Archive.Stripe_AllTransactions_Report                                                                                                              

Insert INTO Archive.Stripe_AllTransactions_Report  

SELECT F.*, DATEADD(d,7,F.created)createdplus7days,MAX(S.created)Finalcreated,CardFunding,COUNT(*) AS CardTrials,getdate()                                                                                                        
FROM Archive.Stripe_transactions_report s                                                                                                             
JOIN #AllStripetransactions F                                                                                                        
ON f.userId_metadata = s.userId_metadata                                                                                                              
AND S.created BETWEEN F.created AND DATEADD(d,7,F.created)                                                                                                          
GROUP BY f.userId_metadata ,f.created    ,DATEADD(d,7,F.created),CardFunding                                                                                               


---------------------------------------------------------------------------------------------------------------------------------------------------

--Report

/*


--By CreditFunding
select AllStripetransactions.*,DistinctUserUUID_StripeSuccess,DistinctUserUUID_StripeFailures,DistinctUserUUID_StripeFailuresInDunning,DistinctUserUUID_StripeFailuresDunningSuccess from 
(select year(created)CreatedYear, month(created)CreatedMonth,CardFunding, count(distinct userId_metadata) as DistinctUserUUID_AllStripetransactions 
from Archive.Stripe_AllTransactions_Report
group by  year(created) , month(created),CardFunding ) AllStripetransactions

left join (select year(created)CreatedYear, month(created)CreatedMonth,CardFunding , count(distinct userId_metadata) as DistinctUserUUID_StripeSuccess 
from Archive.Stripe_Success_Report
group by  year(created) , month(created),CardFunding  ) StripeSuccess
on AllStripetransactions.CreatedYear = StripeSuccess.CreatedYear 
and AllStripetransactions.CreatedMonth = StripeSuccess.CreatedMonth
and AllStripetransactions.CardFunding = StripeSuccess.CardFunding

left join (select year(created)CreatedYear, month(created)CreatedMonth,CardFunding , count(distinct userId_metadata) as DistinctUserUUID_StripeFailures 
from Archive.Stripe_Failures_Report
group by  year(created) , month(created),CardFunding  )StripeFailures 
on AllStripetransactions.CreatedYear = StripeFailures.CreatedYear 
and AllStripetransactions.CreatedMonth = StripeFailures.CreatedMonth
and AllStripetransactions.CardFunding = StripeFailures.CardFunding

left join (select year(created)CreatedYear, month(created)CreatedMonth,CardFunding , count(distinct userId_metadata) as DistinctUserUUID_StripeFailuresInDunning 
from Archive.Stripe_Failures_Report   
where CardTrials > 1   or Status = 'Paid'
group by  year(created) , month(created),CardFunding  ) StripeFailuresInDunning 
on AllStripetransactions.CreatedYear = StripeFailuresInDunning.CreatedYear 
and AllStripetransactions.CreatedMonth = StripeFailuresInDunning.CreatedMonth
and AllStripetransactions.CardFunding = StripeFailuresInDunning.CardFunding

left join (select year(created)CreatedYear, month(created)CreatedMonth,CardFunding , count(distinct userId_metadata) as DistinctUserUUID_StripeFailuresDunningSuccess 
from Archive.Stripe_Failures_Report   
where status = 'paid'   
group by  year(created) , month(created),CardFunding  )StripeFailuresDunningSuccess  
on AllStripetransactions.CreatedYear = StripeFailuresDunningSuccess.CreatedYear 
and AllStripetransactions.CreatedMonth = StripeFailuresDunningSuccess.CreatedMonth
and AllStripetransactions.CardFunding = StripeFailuresDunningSuccess.CardFunding
where AllStripetransactions.CardFunding = 'credit'
order by 1,2,3

--Overall
select AllStripetransactions.CreatedYear,	AllStripetransactions.CreatedMonth	
,sum(DistinctUserUUID_AllStripetransactions)DistinctUserUUID_AllStripetransactions
,sum(DistinctUserUUID_StripeSuccess) DistinctUserUUID_StripeSuccess
,sum(DistinctUserUUID_StripeFailures) DistinctUserUUID_StripeFailures
,sum(DistinctUserUUID_StripeFailuresInDunning) DistinctUserUUID_StripeFailuresInDunning
,sum(DistinctUserUUID_StripeFailuresDunningSuccess )DistinctUserUUID_StripeFailuresDunningSuccess
from 
(select year(created)CreatedYear, month(created)CreatedMonth,CardFunding, count(distinct userId_metadata) as DistinctUserUUID_AllStripetransactions 
from Archive.Stripe_AllTransactions_Report
group by  year(created) , month(created),CardFunding ) AllStripetransactions

left join (select year(created)CreatedYear, month(created)CreatedMonth,CardFunding , count(distinct userId_metadata) as DistinctUserUUID_StripeSuccess 
from Archive.Stripe_Success_Report
group by  year(created) , month(created),CardFunding  ) StripeSuccess
on AllStripetransactions.CreatedYear = StripeSuccess.CreatedYear 
and AllStripetransactions.CreatedMonth = StripeSuccess.CreatedMonth
and AllStripetransactions.CardFunding = StripeSuccess.CardFunding

left join (select year(created)CreatedYear, month(created)CreatedMonth,CardFunding , count(distinct userId_metadata) as DistinctUserUUID_StripeFailures 
from Archive.Stripe_Failures_Report
group by  year(created) , month(created),CardFunding  )StripeFailures 
on AllStripetransactions.CreatedYear = StripeFailures.CreatedYear 
and AllStripetransactions.CreatedMonth = StripeFailures.CreatedMonth
and AllStripetransactions.CardFunding = StripeFailures.CardFunding

left join (select year(created)CreatedYear, month(created)CreatedMonth,CardFunding , count(distinct userId_metadata) as DistinctUserUUID_StripeFailuresInDunning 
from Archive.Stripe_Failures_Report   
where CardTrials > 1   or Status = 'Paid'
group by  year(created) , month(created),CardFunding  ) StripeFailuresInDunning 
on AllStripetransactions.CreatedYear = StripeFailuresInDunning.CreatedYear 
and AllStripetransactions.CreatedMonth = StripeFailuresInDunning.CreatedMonth
and AllStripetransactions.CardFunding = StripeFailuresInDunning.CardFunding

left join (select year(created)CreatedYear, month(created)CreatedMonth,CardFunding , count(distinct userId_metadata) as DistinctUserUUID_StripeFailuresDunningSuccess 
from Archive.Stripe_Failures_Report   
where status = 'paid'   
group by  year(created) , month(created),CardFunding  )StripeFailuresDunningSuccess  
on AllStripetransactions.CreatedYear = StripeFailuresDunningSuccess.CreatedYear 
and AllStripetransactions.CreatedMonth = StripeFailuresDunningSuccess.CreatedMonth
and AllStripetransactions.CardFunding = StripeFailuresDunningSuccess.CardFunding
group by AllStripetransactions.CreatedYear,	AllStripetransactions.CreatedMonth	
order by 1,2


*/


drop table #InitialStripeFailure
drop table #StripeFailures
drop table #FirstAttemptStripePasses
drop table #AllStripetransactions  

End
GO
