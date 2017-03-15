SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create Proc [dbo].[SP_Dax_Wrh_Coupons]
as
Begin

truncate table datawarehouse.Marketing.Coupons

insert into datawarehouse.Marketing.Coupons
			(Coupon,CouponDesc,StartDate,StopDate,CouponNumber,CurrencyCode,SpecialShipping,ShippingAmount,PHSCHEDULENAME,CouponMin,CouponMax,
			CouponValue,CouponType,Voided,PercentOff,BonusItemPercentOff,ApplyToMultipleItems,ItemThreshold )

	select jscouponid as Coupon,JSCOUPONDESC as CouponDesc,JSFROMDATE as StartDate,JSTODATE as StopDate,JSCOUPONNUMBER as CouponNumber,
	CURRENCYCODE as CurrencyCode,SpecialShipping,ShippingAmount,PHSCHEDULENAME,CouponMin,CouponMax,CouponValue,CouponType,Voided,PercentOff,
	BonusItemPercentOff,ApplyToMultipleItems,ItemThreshold 
	from DAXImports..Load_coupons

END
GO
