SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
CREATE procedure [staging].[SP_TTCProd_to_DaxImportsStage_Coupons] 
AS
/* This routine is used to export coupons to the web site.  It currently will run only percent off, fixed shipping,
and fixed amount coupons - since that is what is coded on the web site.
Date Written: 2011-04-08 tom jones The Great Courses
Last Updated: 2011-06-09 tlj Do not include Voi
			  2011-11-12 tlj Added Other std shipping methods.
			  2011-12-14 tlj added fedex sp (smartpost)
			  2011-12-28 tlj Removed Coupon Min/Max equality requirement.
			  2012-07-20 JCP Added coupon restrictions
			  2013-04-04 JCP Added condition that if coupon is default AND free ship, set type to percent off.
			  2014-09-25 tlj Removed Restrictions - output all coupons
			  2014-10-09 tlj set up for datamart export - removed other tables not used for Datamart.
							 Added Canadian PO Box to list of standard shipping methos.
			  2017/01/09 Bondugulav Conversion to TTCProd2009 to DaxImports Staging.	(spDatamartExportCoupons)
*/
Set Nocount on;

Begin 

		select c.jscouponid, c.JSCOUPONDESC,c.JSFROMDATE, c.JSTODATE, c.JSCOUPONNUMBER, c.CURRENCYCODE,
				SpecialShipping = 0, ShippingAmount = CONVERT(money,0), PHSCHEDULENAME,
				CouponMin = MIN(cd.JSCOUPONAMOUNT),CouponMax = MAX(jsCouponAmount), CouponValue = MAX(jscouponvalue),
				CouponType = CASE	WHEN (MIN(JSCOUPONDISCATTR) = 0 AND MAX(JSCOUPONDISCATTR) = 3) THEN 2
									WHEN MAX(JSCOUPONDISCATTR) = 0 THEN 2
									WHEN MAX(JSCOUPONDISCATTR) IN (1,2,3) THEN 1 
									WHEN MAX(JSCOUPONDISCATTR) = 4 THEN CASE MAX(TTCCOUPONOFFERTYPE) 
									WHEN 5 THEN 1 ELSE MAX(TTCCOUPONOFFERTYPE) END
							END,
				JSCOUPONVOIDED = MAX(JSCOUPONVOIDED), 
				PercentOff = CASE WHEN (MIN(JSCOUPONDISCATTR) = 0 AND MAX(JSCOUPONDISCATTR) = 3) THEN MAX(jscouponvalue)
								  WHEN MAX(JSCOUPONDISCATTR) = 0 THEN MAX(jscouponvalue) 
								  WHEN (MAX(JSCOUPONDISCATTR) = 4 AND MAX(TTCCOUPONOFFERTYPE) = 2) THEN MAX(jscouponvalue)
							ELSE 0 END, 
				BonusItemPercentOff = MAX(TTCCOUPONITEMPERCENTOFF),
				ApplyToMultipleItems = MAX(TTCCOUPONMULTIPLEITEMS), ItemThreshold = MAX(ttcItemThreshold)
			into #CouponOutput
			from TTCPROD2009..jscoupons c
			join TTCPROD2009..JSCOUPONDISCOUNT cd
			on c.JSCOUPONID = cd.JSCOUPONID
		-- 2014-09-25 tlj
		--where JSCOUPONVOIDED = 0
			group by C.jscouponid, c.JSCOUPONDESC,c.JSFROMDATE, c.JSTODATE, c.JSCOUPONNUMBER, c.CURRENCYCODE,PHSCHEDULENAME
			--having MIN(JSCOUPONAMOUNT) = MAX(JSCOUPONAMOUNT)
 
			select deliverymode,SCHEDULENAME, MinAmount = MIN(amountPercent),MaxAmount = MAX(amountpercent) 
			into #FixedSchedules
			from TTCPROD2009..JSPHSCHEDULESHIPPINGDEFINE
			WHERE DELIVERYMODE IN ('CA POBox','Ground','Ground Sig','Home','Home Sig','USPS PM','DHL Global', 'USPS Endic',
			'FX Canada','DHL AU','DHL UK', 'FX SP' )
			group by deliverymode,SCHEDULENAME
			having MIN(amountPercent) = MAX(AMOUNTPERCENT)

			update #CouponOutput 
			set specialshipping = 1,
				ShippingAmount = MinAmount
			from #CouponOutput t
			join #fixedSchedules f
			on t.PHSCHEDULENAME = f.schedulename

		Update #CouponOutput
		set CURRENCYCODE = 'USD' where CURRENCYCODE not in ('USD','GBP','AUD')


	truncate table DaxImports.staging.[Load_Coupons_Datamart]

	insert into	   DaxImports.staging.[Load_Coupons_Datamart]
	select * from #CouponOutput


END


GO
