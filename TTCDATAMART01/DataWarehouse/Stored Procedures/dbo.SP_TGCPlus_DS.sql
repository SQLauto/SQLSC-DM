SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROC [dbo].[SP_TGCPlus_DS] 
AS 
  BEGIN 

  --bondugulav 8/10/2017
  /* Calculating DS Days For TGCPLus Customer*/ 
      /* 
      -- Calculating the DS Days Bucket till Customer max entitlement 
      -- Only taking User billing Type = 'PAYMENT' 
      --No Refunds for this calculation 
       
      DS value = 0 is for free trial where the Customer payment = 0 and its the initial entitlement only.
      DS 1 is month since that 
       
      */ 

 SELECT DISTINCT user_id, 
                      completed_at, 
                      billing_cycle_period_type, 
                      type, 
                      pre_tax_amount, 
                      service_period_from, 
                      service_period_to, 
                      subscription_plan_id, 
                      payment_handler 
      INTO   #tgcplus_userbilling 
      FROM   datawarehouse.archive.tgcplus_userbilling ub 
             JOIN datawarehouse.marketing.tgcplus_customersignature cs 
               ON cs.customerid = ub.user_id 
      WHERE  type = 'PAYMENT' 
			AND UB.completed_at>='9/28/2015'

      SELECT user_id, 
             Min(service_period_from) AS Min_service_period_from,
			 Min(service_period_to) AS min_service_period_to, 
			 Max(service_period_to) AS Max_service_period_to 
      INTO   #tgcplus_userbilling_MIN_MAX
      FROM   #tgcplus_userbilling 
      GROUP  BY user_id 


	    

/* Initial Entitlement starting with Free Trail Customers*/
select MM.*,D.date, 
	case when D.Date between cast(Min_service_period_from as date) and Min_service_period_to  /*Free Trial DS0 */
			 THEN 0
		 When  Datepart(d, min_service_period_to) >= Datepart(d, date) 
			 THEN Datediff(m, min_service_period_to, date) 
         ELSE Datediff(m, min_service_period_to, date) + 1
		 End as DS
Into #tgcplus_ds
	FROM   
	 (	   
	 /* Min_service_period_from = Min Service period started from  ********MIN_service_period_to = Initial Entitlement ends on ********Max_service_period_to = Max Entitlement*/
		select MM.user_id,MM.Min_service_period_from, MIN_service_period_to ,MM.Max_service_period_to
			   from #tgcplus_userbilling Ub
			   join #tgcplus_userbilling_MIN_MAX MM
			   on Ub.user_id = MM.User_id
			   and Ub.service_period_from = MM.Min_service_period_from
			   and UB.pre_tax_amount = 0
		) MM 
left join datawarehouse.mapping.date d
		On d.date between cast(MM.MIN_service_period_from as date) and cast(MM.Max_service_period_to as date)

Union 

select MM.*,D.date,
	case  
		   When Datepart(d, min_service_period_from) > Datepart(d, date) 
		   Then Datediff(M,min_service_period_from,D.Date) 
		   else Datediff(M,min_service_period_from,D.Date) + 1
		 End as DS
	FROM   
	 (	   
	 /* Min_service_period_from = Min Service period started from  ********MIN_service_period_to = Initial Entitlement ends on ********Max_service_period_to = Max Entitlement*/
		select MM.user_id,MM.Min_service_period_from, MIN_service_period_to ,MM.Max_service_period_to
			   from #tgcplus_userbilling Ub
			   join #tgcplus_userbilling_MIN_MAX MM
			   on Ub.user_id = MM.User_id
			   and Ub.service_period_from = MM.Min_service_period_from
			   and UB.pre_tax_amount > 0
		) MM 
	left join datawarehouse.mapping.date d
		On d.date between cast(MM.MIN_service_period_from as date) and cast(MM.Max_service_period_to as date)


	  SELECT user_id   AS Customerid, 
			 min_service_period_from,
             min_service_period_to, 
             max_service_period_to, 
             Max(date) DSDate, 
			 ds
	  Into #DS
      FROM   #tgcplus_ds 
      GROUP  BY user_id, 
                min_service_period_from,
				min_service_period_to, 
                max_service_period_to, 
                ds 



		TRUNCATE TABLE datawarehouse.mapping.tgcplus_ds 
		INSERT INTO datawarehouse.mapping.tgcplus_ds 
		select *,
			Isnull(Lag(DSDate) Over( Partition by Customerid order by DSDate), Min_service_period_From)PriorDSDate,getdate()
		from #ds 


  END 




GO
