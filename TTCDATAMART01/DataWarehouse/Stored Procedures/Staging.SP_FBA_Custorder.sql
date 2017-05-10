SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE Proc [Staging].[SP_FBA_Custorder]
as

Begin

--drop table #temp    
select distinct buyer_email, buyer_name,       
       replace([buyer_name],' ','') +replace([ship_address_1],' ','') + replace([ship_city],' ','') + replace([ship_state],' ','') + replace(left([ship_postal_code],5),' ','') addressName,
       replace([ship_address_1],' ','') + replace([ship_city],' ','') + replace([ship_state],' ','') + replace(left([ship_postal_code],5),' ','') address
into #temp   
from Archive.FBA_Sales a   
       
--drop table #tempsig 
select customerid, FirstName, LastName, Address1, Address2, Address3, City,State, CustomerSegmentFnl, 
       NewSeg, Name, A12mf, ComboID,
       CustomerSegment, Frequency, 
       customerSegment + '_' + case when frequency = 'F2' then 'Multi' 
                                               when frequency = 'F1' then 'Single' 
                                               else '' end as CustomerSegmentFrcst,
       PostalCode,
       replace(FirstName,' ','') + replace(LastName,' ','') +  replace(Address1,' ','') + replace(Address2,' ','') +  replace(Address3,' ','') + replace(city,' ','') + replace(state,' ','') 
	   + replace(left([postalcode],5),' ','') addresscomboName,
       replace(Address1,' ','') + replace(Address2,' ','') +  replace(Address3,' ','') + replace(city,' ','') + replace(state,' ','') + replace(left([postalcode],5),' ','') addresscombo
       into #tempsig
from Marketing.CampaignCustomerSignature       

/*Commenting below code as we are only doing overlay matches begining with August Overlay file on 8/22 */       

/*       
--drop table #temp2
select *,    
       case when a.addressname = b.addresscomboname then 1 else 0 end as TGCCust
into #temp2
from #temp a 
       left join #tempsig b on a.addressname = b.addresscomboname
union
select *,    
       case when a.address = b.addresscombo then 1 else 0 end as TGCCust
from #temp a 
       left join #tempsig b on a.address = b.addresscombo
*/

/* FBA Customer overlay based on WD Merge dupes*/
--Drop table #Dedup
select distinct ccs.customerid, ccs.FirstName, ccs.LastName, ccs.Address1, ccs.Address2, ccs.Address3, ccs.City,ccs.State, ccs.CustomerSegmentFnl, 
       ccs.NewSeg, ccs.Name, ccs.A12mf, ccs.ComboID,
       ccs.CustomerSegment, ccs.Frequency, 
       ccs.customerSegment + '_' + case when ccs.frequency = 'F2' then 'Multi' 
                                               when ccs.frequency = 'F1' then 'Single' 
                                               else '' end as CustomerSegmentFrcst,
       ccs.PostalCode,
       replace(ccs.FirstName,' ','')   + replace(ccs.LastName,' ','')  +  replace(ccs.Address1,' ','') + replace(ccs.Address2,' ','') +  replace(ccs.Address3,' ','') 
	   + replace(ccs.city,' ','') + replace(ccs.state,' ','') + replace(left(ccs.postalcode,5),' ','') addresscomboName,
       replace(ccs.Address1,' ','') + replace(ccs.Address2,' ','') +  replace(ccs.Address3,' ','') 
	   + replace(ccs.city,' ','') + replace(ccs.state,' ','') + replace(left(ccs.postalcode,5),' ','') addresscombo,
	   FBACA.buyer_email,FBACA.buyer_name
into #Dedup
from Marketing.CampaignCustomerSignature    ccs
join (select fba.*
		from DataWarehouse.Mapping.FBA_Merge_Dupes FBA
		join (Select FBACustomerid,min(Merge_Date) Merge_Date
			from DataWarehouse.Mapping.FBA_Merge_Dupes 
			where acctno is not null and Rank = 1
			group by FBACustomerid
			)FBA2
		on FBA.FBACustomerid = FBA2.FBACustomerid 
		and FBA.Merge_Date = FBA2.Merge_Date
		and Rank = 1 
	) FBA on ccs.customerid = fba.acctno
join DataWarehouse.Mapping.FBA_Customer_Address FBACA
on FBA.FBACustomerid = FBACA.FBA_AddressID


--drop table #temp2
select a.buyer_email,a.buyer_name,addressName,address,customerid,FirstName,LastName,Address1,Address2,Address3,City,State,
CustomerSegmentFnl,NewSeg,Name,A12mf,ComboID,CustomerSegment,Frequency,CustomerSegmentFrcst,PostalCode,addresscomboName,addresscombo,    
       case when b.CustomerID is null then 0 else 1 end as TGCCust
into #temp2
from #temp a 
       left join #Dedup b on a.buyer_name = b.buyer_name and a.buyer_email = b.buyer_email	


select *
from #temp2
where TGCCust = 1
order by buyer_email, newseg


--select * from DataWarehouse.Mapping.FBA_Merge_Dupes


--drop table #tempdel
select buyer_email, buyer_name,count(buyer_email) counts, max(isnull(newseg,100))MaxNewSeg
into #tempdel
from #temp2
where TGCCust = 1
group by buyer_email, buyer_name
having count(buyer_email) > 1
order by buyer_email



delete a
--select * 
from #temp2 a join
       #tempdel b on a.buyer_email = b.buyer_email
                    and isnull(a.NewSeg,100) = b.MaxNewSeg
where TGCCust = 1

select *
from DataWarehouse.Archive.FBA_Sales
where buyer_email in (select buyer_email
                                 from #temp2
                                 group by buyer_email
                                 having count(buyer_email) > 1)
order by buyer_email

select *
-- delete 
from #temp2
where buyer_email in (select buyer_email
                                 from #temp2
                                 group by buyer_email
                                 having count(buyer_email) > 1)
and TGCCust =0
order by buyer_email


------------Tab 3 ******************************
--drop table #fnl1
select cast(getdate() as date) ReportDate,
       a.buyer_email,a.buyer_name,a.address,a.customerid,
       a.FirstName,a.LastName,a.Address1,a.Address2,a.Address3,a.City,a.State,
       a.CustomerSegmentFnl,a.NewSeg,a.Name,a.A12mf,a.ComboID,a.CustomerSegment,
       a.Frequency,a.CustomerSegmentFrcst,a.PostalCode,a.addresscombo,a.TGCCust, 
       sum(b.item_price) ItemPrice, sum(b.item_tax) ItemTax, 
       sum(b.item_promotion_discount) ItemDiscount,
       sum(b.shipping_price) ShippingPirce, 
       sum(b.shipping_tax) ShippingTax, 
       sum(b.ship_promotion_discount) ShippingDiscount,
       sum(b.quantity_shipped) Units,
       count(distinct b.amazon_order_id) Orders,
       sum(b.item_price + b.shipping_price + b.gift_wrap_price + b.item_promotion_discount + b.ship_promotion_discount) NetOrderAmount,
       sum(b.item_tax + b.shipping_tax + b.gift_wrap_tax) as TotalTax
into #fnl1
from #temp2 a left join
       DataWarehouse.Archive.FBA_Sales b on a.buyer_email = b.buyer_email
group by a.buyer_email,a.buyer_name,a.address,a.customerid,
       a.FirstName,a.LastName,a.Address1,a.Address2,a.Address3,a.City,a.State,
       a.CustomerSegmentFnl,a.NewSeg,a.Name,a.A12mf,a.ComboID,a.CustomerSegment,
       a.Frequency,a.CustomerSegmentFrcst,a.PostalCode,a.addresscombo,a.TGCCust

select *
from #fnl1

if object_id('Marketing.FBA_CustOrder') is not null
drop table DataWarehouse.Marketing.FBA_CustOrder


select * into DataWarehouse.Marketing.FBA_CustOrder from  #fnl1


End
GO
