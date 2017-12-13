SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE Proc [Staging].[SP_FBA_Load_Sales]  
as  
Begin  
  
/* Only Inserting Values*/  
  
   
Insert into Archive.FBA_Sales  
select  s.amazon_order_id,   
  s.merchant_order_id,   
  s.shipment_id,   
  s.shipment_item_id,   
  s.amazon_order_item_id,   
  s.merchant_order_item_id,   
  --cast(Substring(replace(s.purchase_date,'t',' '),1, charindex('+',replace(s.purchase_date,'t',' '))-1) as datetime)purchase_date,    --Changed on 10/30/2017
  --cast(Substring(replace(s.payments_date,'t',' '),1, charindex('+',replace(s.payments_date,'t',' '))-1) as datetime)payments_date,    --Changed on 10/30/2017
  --cast(Substring(replace(s.shipment_date,'t',' '),1, charindex('+',replace(s.shipment_date,'t',' '))-1) as datetime)shipment_date,    --Changed on 10/30/2017
  --cast(Substring(replace(s.reporting_date,'t',' '),1, charindex('+',replace(s.reporting_date,'t',' '))-1) as datetime)reporting_date,    --Changed on 10/30/2017
  Dateadd(HH,-Cast(left(right(s.purchase_date,6),3) as int),left(s.purchase_date, 19) )   purchase_date,   
  Dateadd(HH,-Cast(left(right(s.payments_date,6),3) as int),left(s.payments_date, 19) )   payments_date,   
  Dateadd(HH,-Cast(left(right(s.shipment_date,6),3) as int),left(s.shipment_date, 19) )   shipment_date,   
  Dateadd(HH,-Cast(left(right(s.reporting_date,6),3) as int),left(s.reporting_date, 19) ) reporting_date,   
  s.buyer_email,   
  s.buyer_name,   
  s.buyer_phone_number,   
  s.sku,   
  s.product_name,   
  Cast(s.quantity_shipped as Int)quantity_shipped,   
  s.currency,   
  cast(s.item_price as money)item_price,   
  cast(s.item_tax as money)item_tax,   
  cast(s.shipping_price as money)shipping_price,   
  cast(s.shipping_tax as money)shipping_tax,   
  cast(s.gift_wrap_price as money)gift_wrap_price,   
  cast(s.gift_wrap_tax as money)gift_wrap_tax,   
  s.ship_service_level,   
  s.recipient_name,   
  s.ship_address_1,   
  s.ship_address_2,   
  s.ship_address_3,   
  s.ship_city,   
  s.ship_state,   
  s.ship_postal_code,   
  s.ship_country,   
  s.ship_phone_number,   
  s.bill_address_1,   
  s.bill_address_2,   
  s.bill_address_3,   
  s.bill_city,   
  s.bill_state,   
  s.bill_postal_code,   
  s.bill_country,   
  cast(s.item_promotion_discount as Money)item_promotion_discount,   
  cast(s.ship_promotion_discount as Money)ship_promotion_discount,   
  s.carrier,   
  s.tracking_number,   
  --cast(Substring(replace(s.estimated_arrival_date,'t',' '),1, charindex('+',replace(s.estimated_arrival_date,'t',' '))-1) as datetime)estimated_arrival_date,   --Changed on 10/30/2017
  Dateadd(HH,-Cast(left(right(s.estimated_arrival_date,6),3) as int),left(s.estimated_arrival_date, 19) ) estimated_arrival_date,   
  s.fulfillment_center_id,   
  s.fulfillment_channel,   
  s.sales_channel,  
  Getdate() as DMLastupdatedEST   
 from Staging.FBA_ssis_Sales S  
 left join Archive.FBA_Sales A  
 on A.amazon_order_id = S.amazon_order_id  
  and A.amazon_order_item_id = S.amazon_order_item_id  
 where A.amazon_order_id is null  
  
     
  
  
  
/* insert new address into Mapping.FBA_Customer_Address*/  
  
  
  
insert into Mapping.FBA_Customer_Address (buyer_email,buyer_name,recipient_name,ship_address_1,ship_address_2,ship_address_3,ship_city,ship_state,ship_postal_code,ship_country,Initialpurchase_date)  
select FBA.* from  
(select buyer_email,buyer_name,recipient_name, ship_address_1, ship_address_2, ship_address_3, ship_city, ship_state, ship_postal_code, ship_country,min(purchase_date)Initialpurchase_date  
from  Archive.FBA_Sales  
group by buyer_email,buyer_name,recipient_name, ship_address_1, ship_address_2, ship_address_3, ship_city, ship_state, ship_postal_code, ship_country)FBA  
left join Mapping.FBA_Customer_Address Ad  
on Ad.buyer_email = FBA.buyer_email and Ad.recipient_name = FBA.recipient_name and Ad.ship_address_1 = FBA.ship_address_1  
where Ad.buyer_email is null  
  
   
End  
  
GO
