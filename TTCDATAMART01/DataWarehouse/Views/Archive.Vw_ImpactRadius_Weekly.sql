SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE View [Archive].[Vw_ImpactRadius_Weekly]      
as      
      
/*Impact radius*/         
/*      
--CUSTOMER_CONVERTED      
select distinct 8721 as ActionTrackerId,'Oid-' + u.uuid as Oid,'CUSTOMER_CONVERTED' as Reason      
from DataWarehouse.Archive.TGCPlus_User U      
join DataWarehouse.Archive.TGCPlus_UserBilling UB      
on UB.user_id = u.id      
join DataWarehouse.mapping.vwAdcodesAll Ad       
on Ad.AdCode =  u.TGCPluscampaign      
where pre_tax_amount>0      
and     
( /*Yearly*/    
(entitled_dt between dateadd(day,-7,DataWarehouse.Staging.GetSunday(getdate())) and DataWarehouse.Staging.GetSunday(getdate())   and billing_cycle_period_type = 'YEAR')     
Or      
/*Monthly Go back one month*/    
(entitled_dt between dateadd(day,-7,DataWarehouse.Staging.GetSunday(Dateadd(MM,-1,getdate()))) and DataWarehouse.Staging.GetSunday(Dateadd(MM,-1,getdate()))  and billing_cycle_period_type = 'MONTH')    
)    
and Ad.AdCode in (select AdCode from DataWarehouse.mapping.vwAdcodesAll  where MD_Audience like 'Subscription%' and MD_PromotionType like '%affiliate%Impact%radius%' )      
 */   
/*                               
Union ALL      
--CUSTOMER_Cancelled     
select distinct 8721 as ActionTrackerId,'Oid-' + u.uuid as Oid,'CANCELLED' as Reason      
from DataWarehouse.Archive.TGCPlus_User U      
inner join Datawarehouse.Archive.TGCPlus_PaymentAuthorizationStatus S      
on u.id = s.pa_user_id     
join DataWarehouse.mapping.vwAdcodesAll Ad       
on Ad.AdCode =  u.TGCPluscampaign      
where pas_state = 'Cancelled'      
and pas_updated_at between dateadd(day,-7,DataWarehouse.Staging.GetSunday(getdate())) and DataWarehouse.Staging.GetSunday(getdate())      
and Ad.AdCode in (select AdCode from DataWarehouse.mapping.vwAdcodesAll  where MD_Audience like 'Subscription%' and MD_PromotionType like '%affiliate%Impact%radius%' )       
    
*/    
  
   
select distinct 3896 as CampaignId   
    ,8722 as ActionTrackerId  
    ,replace(u.uuid,',','') as OrderId  
    ,replace(u.uuid,',','') as CustomerId  
    ,case   when replace(billing_cycle_period_type,',','') = 'DAY' then 'Daily'  
      when replace(billing_cycle_period_type,',','') = 'MONTH' then 'Monthly'  
      when replace(billing_cycle_period_type,',','') = 'YEAR' then 'Yearly'  
      end  
    as Category /*subscription type Dayly/Monthly/Yearly*/  
    ,'SUBSCRIPTION' as Sku  
    ,replace(pre_tax_amount,',','') as Amount  
    ,1 as Quantity   
    ,RIGHT('00'+ Datename(d,UB.completed_at),2)  
     + '-' + upper(cast(Datename(MONTH,UB.completed_at) as varchar(3)))  
     + '-'+ Datename(YYYY,UB.completed_at)  
     + ' ' + RIGHT('00'+ Datename(HH,UB.completed_at),2)   
     + ':' + RIGHT('00'+ Datename(MI,UB.completed_at),2)   
     + ':' + RIGHT('00'+ Datename(SECOND,UB.completed_at),2)   
     + ' EST'   as EventDate  
  
from DataWarehouse.Archive.TGCPlus_User U      
join (select user_id, MIN(completed_at) as IntlPayment_dt   
   from DataWarehouse.Archive.TGCPlus_UserBilling UB  
   where type = 'PAYMENT' 
    and pre_tax_amount>0 
   group by user_id)IntlPayment  
on IntlPayment.user_id = u.id      
join DataWarehouse.Archive.TGCPlus_UserBilling UB      
on IntlPayment.user_id = UB.user_id and UB.completed_at = IntlPayment.IntlPayment_dt      
join DataWarehouse.mapping.vwAdcodesAll Ad       
on Ad.AdCode =  u.TGCPluscampaign    
left join archive.ImpactRadius_Weekly Archive  
on  archive.OrderId = u.uuid  and Archive.Sku = 'SUBSCRIPTION'
where ub.type='PAYMENT'  
and Archive.OrderId is null  
--and cast(u.entitled_dt as date) between '10/1/2016' and getdate()
and u.entitled_dt between staging.GetSunday(getdate()-7)  and staging.GetSunday(getdate())
and Ad.AdCode in (select AdCode from DataWarehouse.mapping.vwAdcodesAll  where MD_Audience like 'Subscription%' and MD_PromotionType like '%affiliate%Impact%radius%' )       

union

select distinct 3896 as CampaignId   
    ,8722 as ActionTrackerId  
    ,replace(u.uuid,',','') as OrderId  
    ,replace(u.uuid,',','') as CustomerId  
    ,case   when U.IntlSubType = 'DAY' then 'Daily'  
      when U.IntlSubType = 'MONTH' then 'Monthly'  
      when U.IntlSubType = 'YEAR' then 'Yearly'  
      end  
    as Category /*subscription type Monthly/Yearly*/  
    ,'FREETRIAL' as Sku  
    ,convert(money,0.0) as Amount  
    ,1 as Quantity   
    ,RIGHT('00'+ Datename(d,ou.entitled_dt),2)  
     + '-' + upper(cast(Datename(MONTH,ou.entitled_dt) as varchar(3)))  
     + '-'+ Datename(YYYY,ou.entitled_dt)  
     + ' ' + RIGHT('00'+ Datename(HH,ou.entitled_dt),2)   
     + ':' + RIGHT('00'+ Datename(MI,ou.entitled_dt),2)   
     + ':' + RIGHT('00'+ Datename(SECOND,ou.entitled_dt),2)   
     + ' EST'   as EventDate  
  
from DataWarehouse.Marketing.TGCPlus_CustomerSignature U  
join DataWarehouse.Archive.TGCPlus_User ou on u.uuid = ou.uuid    
join DataWarehouse.mapping.vwAdcodesAll Ad       on Ad.AdCode =  u.IntlCampaignID    
left join archive.ImpactRadius_Weekly Archive  on  archive.OrderId = u.uuid  and Archive.sku = 'FREETRIAL'
where TransactionType <> 'Cancelled'
and PaidFlag = 0
and Archive.OrderId is null  
--and cast(ou.entitled_dt as date) between '10/1/2016' and getdate()
and ou.entitled_dt between staging.GetSunday(getdate()-7)  and staging.GetSunday(getdate())
and Ad.AdCode in (select AdCode from DataWarehouse.mapping.vwAdcodesAll  where MD_Audience like 'Subscription%' and MD_PromotionType like '%affiliate%Impact%radius%' )       



GO
