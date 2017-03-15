SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [Staging].[SP_FBA_Load_DailySOUP]
as
Begin

/* Only Inserting Values*/

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'FBA_DailySOUP_TEMP')
        DROP TABLE Staging.FBA_DailySOUP_TEMP 

	select cast(getdate() as date) ReportDate,
		year(payments_date) PaymentYear,
		Month(payments_date) PaymentMonth,
		staging.GetMonday(payments_date) PaymentWeek,
		cast(payments_date as date) PaymentDate,
		year(Purchase_date) OrderYear,
		Month(Purchase_date) OrderMonth,
		staging.GetMonday(Purchase_date) OrderWeek,
		cast(Purchase_date as date) OrderDate,
		currency,
		count(distinct amazon_order_id) Orders,
		count(distinct buyer_email) Customers,
		sum(quantity_shipped) Units,
		sum(item_price) ItemPrice,
		sum(item_tax) ItemTax,
		sum(shipping_price) ShippingPrice,
		sum(shipping_tax) ShippingCharge,
		sum(gift_wrap_price)  GiftWrapPrice,
		sum(gift_wrap_tax) GiftWrapTax,
		sum(item_promotion_discount) ItemDiscount,
		sum(ship_promotion_discount) ShippingDiscount,
		sum(item_price + shipping_price + gift_wrap_price + item_promotion_discount + ship_promotion_discount) NetOrderAmount,
		sum(item_tax + shipping_tax + gift_wrap_tax) as TotalTax
	into Staging.FBA_DailySOUP_TEMP
	from Archive.FBA_Sales
	group by year(payments_date),
		Month(payments_date),
		staging.GetMonday(payments_date),
		cast(payments_date as date),
		year(Purchase_date),
		Month(Purchase_date),
		staging.GetMonday(Purchase_date),
		cast(Purchase_date as date),
		currency


	truncate table Marketing.FBA_DailySOUP	
	
	insert into Marketing.FBA_DailySOUP
	select *
	from Staging.FBA_DailySOUP_TEMP

 
End
GO
