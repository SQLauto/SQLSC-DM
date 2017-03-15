SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [Staging].[SP_FBA_Load_Course]
as
Begin

/* Only Inserting Values*/

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'FBA_CourseSales_TEMP')
        DROP TABLE Staging.FBA_CourseSales_TEMP 

	select cast(getdate() as date) ReportDate,
		year(a.Purchase_date) OrderYear,
		Month(a.Purchase_date) OrderMonth,
		staging.GetMonday(a.Purchase_date) OrderWeek,
		cast(a.Purchase_date as date) OrderDate,
		year(a.payments_date) PaymentYear,
		Month(a.payments_date) PaymentMonth,
		staging.GetMonday(a.payments_date) PaymentWeek,
		cast(a.payments_date as date) PaymentDate,
		a.sku,
		b.CourseID,
		b.MediaTypeID,
		c.AbbrvCourseName,
		c.CourseParts,
		c.SubjectCategory2,
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
	into Staging.FBA_CourseSales_TEMP
	from Archive.FBA_Sales a
		join DataWarehouse.Staging.invitem b on a.sku = b.StockItemID
		left join DataWarehouse.Mapping.dmcourse c on b.CourseID = c.courseID
	group by 
		year(a.Purchase_date),
		Month(a.Purchase_date),
		staging.GetMonday(a.Purchase_date),
		cast(a.Purchase_date as date),
		year(a.payments_date),
		Month(a.payments_date),
		staging.GetMonday(a.payments_date),
		cast(a.payments_date as date),
		a.sku,
		b.CourseID,
		b.MediaTypeID,
		c.AbbrvCourseName,
		c.CourseParts,
		c.SubjectCategory2,
		currency
			

	truncate table Marketing.FBA_CourseSales	
	
	insert into Marketing.FBA_CourseSales
	select * 
	from Staging.FBA_CourseSales_TEMP

 
End
GO
