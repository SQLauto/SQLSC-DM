SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [staging].[SP_TTCProd_to_DaxImportsStage_ExportSalesOrder]
@startdate datetime = '1/1/2012'
As
/* This routine is used to export sales order information to the datamart tables.
   Date Written: 2011-04-25 tom jones, tgc
   Last Updated: 2011-04-26 tlj Added orderitems
				 2011-04-29 tlj Added Coupons and other markup items
				 2011-05-18 tlj Added specific orders
				 2011-06-02 tlj Removed PH 'where' clause to get all misc charges.
								Only moved post-dax orders (non-numeric sales ids).
								Removed Bad data from testing from payments inserts.
				2011-07-16 tlj Added shipdate as confirmed delivery date
				2011-09-02 tlj Added Web Reference Number
				2011-09-13 tlj Added Check Number and CCExpiration Month/Year.
				2011-09-14 tlj Adding additional columns as required for datamart
				2011-10-27 tlj add recid to payments output and removed temp tables that 
								are not needed.  Removed date selection criteria - not used
								in first iteration of this.
				2012-01-05 tlj Changed to only take orders entered after go-live (@startdate).
				2012-01-09 tlj Run Taxes from order totals table
				2012-01-11 tlj 2nd pass for invoiced PH
				2012-01-12 tlj 2nd pass to include Coupons.]
				2012-01-16 tlj Updated Merchandise total - omit itemdelivered from calculation.
				2012-01-20 tlj Added Discount percentage calculation to 'other charges'
				2012-01-27 tlj Updated tax calculation to use same calculation as invoices.
				2012-02-03 tlj Updated to use correct column in determining whether taxes are > 0
				               Updated taxes sign to be positive if the order had a positive merchandise total.
				               Updated PH/other values on returns to be set at the line level.
				               Use TaxTrans for returns taxes
				2012-02-15 tlj Updated to have all returned items be 'itemsold' 
							   Prepped for MarkupTrans application of taxes for coupons and PH.
				2012-02-16 tlj Added Markup trans taxes to total taxes charged.		
				2012-04-18 tlj Updated tax trans joins 		
				2013-12-05 JCP Added AffiliateSubID field as blank.		
				2013-12-18 tlj Added AffiliateSubID from salestable (after was added on web).
				2014-06-03 tlj Changed to use the jskittype column to determine items sold vs. delivered and to compute
				               total merchandise.
			    2014-06-03 tlj Testing change to make start date 5/1/2014.
			    2014-06-04 tlj Changed start date to be parameter - changed sales table to temp
			                   table on last 2 complations - no need to go back to original sales table.
				2014-10-24 tlj Mark Inserts workbench items as ItemDelivered.	
				2014-11-04 tlj Mark Associated Items (jsLinetype = 2) as ItemDelivered	
				2014-11-05 tlj Added CrossSell to OrderLines	                   		
				2017/01/09 BondugulaV Conversion to TTCProd2009 to DaxImports Staging. (spExportSalesOrder)		               
*/   
/* Pull all orders that have not been closed or cancelled
   Note that this is somewhat different than our original specs
      
*/  
Begin

truncate table DaxImports.staging.DAX_OrderExport
truncate table DaxImports.staging.DAX_OrderPaymentsExport
truncate table DaxImports.staging.DAX_OrderItemExport
Truncate table DaxImports.staging.DAX_OrderCouponsExport

	select orderid = st.Salesid,
	Customerid = st.custaccount,
	InvoiceAccount = st.InvoiceAccount,
	deliveryMode = st.DLVMODE,
	OrderStatus = st.SALESSTATUS,
	st.SalesType,
	st.CURRENCYCODE,
	ShipToName = st.deliveryname,
	ShiptoAddress = st.Deliverystreet,
	ShipToCity = st.deliverycity,
	ShipToState = st.deliveryState,
	ShipToZip = st.DELIVERYZIPCODE,
	ShipToCountryCode = st.DELIVERYCOUNTRYREGIONID ,
	OrderChannel = st.JSCHANNEL,
	Ordersource = st.SALESORIGINID,
	SourceCode =st.JSSOURCEID,
	st.CUSTGROUP,
	MultipleDeliveries = CONVERT(int,0),
	Orderdate = st.CREATEDDATETIME,
	csrid = st.CREATEDBY,
	ModifiedDate = st.modifieddatetime,
	st.modifiedby,
	TotalMerchandise = CONVERT(money,0.00),
	TotalTaxes = CONVERT(money,0.00),
	TotalShipping = CONVERT(money,0.00),
	TotalCoupons = CONVERT(money,0.00),
	OtherCharges = CONVERT(money,0.00),
	BillingName = ct.name,
	BillingAddress1 = ct.JSSTREET1,
	BillingAddress2 = ct.JSSTREET2,
	BillingAddress3 = ct.JSSTREET3,
	BillingCity = ct.city,
	BillingState = ct.State,
	BillingZip = ct.ZIPCODE,
	BillingCountryCode = ct.COUNTRYREGIONID,
	WebReference = st.JSWEBSALESID,
	-- the following are new  and we need to code for these.
	ST.JSGIFTFLAG,
	ST.JSGIFTMESSAGE,
	ST.TAXGROUP,
	st.Purchid,
	st.jsdeliveryphone,
	st.jsShipComplete,
	-- end of new items
	st.DISCPERCENT,
	st.RECID,
	AffiliateSubID

	into #tsalesorders
	from TTCPROD2009..SALESTABLE st (nolock)
	join TTCPROD2009..CUSTTABLE ct (nolock)
	on ct.DATAAREAID in ('sco','vc1')
	and st.CUSTACCOUNT = ct.ACCOUNTNUM
	where
	st.dataareaid = 'sco' and st.createddatetime > @startdate
	and isnumeric(st.SALESID) = 0

	select st.orderid,Postage=SUM(case when markupcode = 'PH' then VALUE else 0 end) ,
	Coupons = SUM(case when markupcode = 'CP' then VALUE else 0 end),
	Othercharges = SUM(case when markupcode not in ('cp','ph') then Value else 0 end),
	Taxes = SUM(TAXAMOUNT)
	into #SalesPostage
	from #tsalesorders st
	join TTCPROD2009..MARKUPTRANs mt
	on mt.DATAAREAID = 'sco' 
	and st.recid = mt.TRANSRECID
	and TRANSTABLEID = 366
	--and MARKUPCODE = 'PH'
	group by st.orderid

/* 2012-01-11 tlj Added Invoiced Postage section and combine the output */
/* 2012-01-12 tlj Added coupons and other charges to the output on the second pass */

	Insert into #SalesPostage
	select st.orderid,
	Postage=SUM(case when markupcode = 'PH' then VALUE else 0 end) ,
	Coupons = SUM(case when markupcode = 'CP' then VALUE else 0 end),
	Othercharges = SUM(case when markupcode not in ('cp','ph') then Value else 0 end),
	Taxes = SUM(TAXAMOUNT)
	from #tsalesorders st
	JOIN TTCPROD2009..MARKUPTRANS PH (nolock)
		  ON PH.DATAAREAID = 'sco'
		  and ST.RECID = PH.JSSAVEDRECID
		  AND PH.JSSAVEDTABLEID = 366
	group by st.orderid

/* 2012-02-03 tom jones - discovered that PH on returns is handled on the line level */

	Insert into #SalesPostage
	select st.orderid,
	Postage=SUM(case when markupcode = 'PH' then VALUE else 0 end) ,
	Coupons = SUM(case when markupcode = 'CP' then VALUE else 0 end),
	Othercharges = SUM(case when markupcode not in ('cp','ph') then Value else 0 end),
	Taxes = SUM(taxamount)
	from #tsalesorders st
	join TTCPROD2009..SALESLINE sl
	on sl.DATAAREAID = 'sco'
	and ST.orderid = sl.salesid 
	JOIN TTCPROD2009..MARKUPTRANS PH (nolock)
		  ON PH.DATAAREAID = 'sco'
		  and sl.RECID = PH.TRANSRECID
		  AND PH.TRANSTABLEID = 359
	where ST.orderid like 'ret%'
	group by st.orderid


	Insert into #SalesPostage
	select st.orderid,
	Postage=SUM(case when markupcode = 'PH' then VALUE else 0 end) ,
	Coupons = SUM(case when markupcode = 'CP' then VALUE else 0 end),
	Othercharges = SUM(case when markupcode not in ('cp','ph') then Value else 0 end),
	Taxes = SUM(taxamount)
	from #tsalesorders st
	join TTCPROD2009..SALESLINE sl
	on sl.DATAAREAID = 'sco'
	and ST.orderid = sl.salesid 
	JOIN TTCPROD2009..MARKUPTRANS PH (nolock)
		  ON PH.DATAAREAID = 'sco'
		  and sl.RECID = PH.JSSAVEDRECID
		  AND PH.JSSAVEDTABLEID = 359
	where ST.orderid like 'ret%'
	group by st.orderid


	select orderid, Postage = SUM(Postage),
	Coupons = SUM(coupons),
	OtherCharges = SUM(othercharges),
	Taxes = SUM(Taxes)
	into #SalesPostageFinal
	from #SalesPostage
	group by orderid

create index #tmporder_oid on #SalesPostageFinal (orderid)

/* TODO - update taxes here from #salesPostage -- don't want to do it tonight before having time to 
   check - 2012-02-15 tlj */
	Update #tsalesorders
	set TotalShipping = sp.Postage,
		TotalCoupons = sp.coupons,
		OtherCharges = sp.otherCharges	
	from #tsalesorders ts
	join #SalesPostageFinal sp
	on ts.orderid = sp.orderid

-- 2012-01-27 tlj Update Taxes
-- 2012-04-18 tlj Update join to jstaxworktrans to use indexed values

	SELECT DISTINCT salesid = ST.orderid, tx.TAXCODE, TaxesCharged = -1 * SUM(TX.SOURCETAXAMOUNTCUR)
	into #TAXItems
		From #tsalesorders ST (nolock)
		JOIN TTCPROD2009..JSTAXWORKTRANS TX (nolock)
		ON TX.DATAAREAID = 'sco' 
		AND TX.SOURCETABLEID in (230, 359)
		and ST.RECID = TX.SOURCERECID
		AND TX.TAXCODE <> 'UKI'
	where TX.SOURCETAXAMOUNTCUR <> 0
	Group by St.orderid, TX.TAXCODE

-- 2012-02-03 tlj use taxtrans for returns
-- 2012-04-18 tlj Add Dataareaid to TaxTrans Join

	Insert into #TAXItems
	select sl.salesid, tt.taxcode, TotalTax = sum(taxamount)
		From #tsalesorders ST (nolock)
		join TTCPROD2009..SALESLINE sl
		on sl.DATAAREAID = 'sco'
		and St.orderid = sl.salesid
		join TTCPROD2009..taxtrans  tt
		on sl.DATAAREAID = tt.DATAAREAID
		and sl.inventtransid = TT.inventtransid	
		AND Tt.TAXCODE <> 'UKI'
	where  st.orderid like 'RET%'
	--and TX.SOURCETAXAMOUNTCUR <> 0
	Group by sl.SALESID, Tt.TAXCODE


	select salesid, TotalOrderTaxes = SUM(TaxesCharged)
	into #TotalTaxes
	from #TaxItems 
	group by salesid


--2012-04-18 tlj added dataareaid tojoin 

	insert into DaxImports.staging.DAX_OrderPaymentsExport
	select Orderid = pt.salesid,
	pt.LINENUM,pt.recid,Pt.PaymMode, pt.status, pt.ccvendor, pt.CURRENCYCODE,
	pt.AMOUNT, pt.CHECKNUMBER, pt.CCEXPIRATIONMONTH, pt.CCEXPIRATIONYEAR
	from 
	--salestable st
	#tsalesorders st
	join TTCPROD2009..JSCUSTPAYMTABLE pt
	on pt.DATAAREAID = 'sco'
	and st.INVOICEACCOUNT = pt.CUSTACCOUNT
	and st.orderid = pt.SALESID
	order by st.orderid, LINENUM

-- 2011-10-26 tlj direct import to the items table
--2012-04-18 tlj Added dataareaid to salesline join

	Insert into DaxImports.staging.Dax_OrderItemExport
	select orderid = sl.salesid,
	OrderItemid = sl.LINENUM,
	sl.ITEMID,
	SalesStatus,
	Quantity = sl.SALESQTY,
	sl.SALESPRICE,
	sl.CURRENCYCODE,
	sl.SALESTYPE,
	sl.DLVMODE,
	sl.DELIVERYNAME,
	sl.DELIVERYSTREET,
	sl.deliverycity,
	sl.DELIVERYSTATE,
	sl.DELIVERYZIPCODE,
	sl.DELIVERYCOUNTRYREGIONID,
	sl.JSSOURCEID,
	sl.JSLISTPRICE,
	sl.JSPRICEOVERRIDE,
	sl.JSREASONCODE,
	sl.JSORIGINALSALESID,
	LineType = case when sl.SALESID like 'ret%' then 'ItemSold'
					when sl.JSINSERTWAVE = 1 then 'ItemDelivered'
					when RTRIM(sl.JSKITTYPE) = 2 then 'ItemDelivered' 
					when rtrim(sl.jslinetype)= 2 then 'ItemDelivered'
					else 'ItemSold' end,
	-- old code		when RTRIM(sl.LINEHEADER) = '' then 'ItemSold' else 'ItemDelivered' end,
	--				when ISNULL(fl.OrderitemInt,0) = 0 then 'ItemDelivered' else 'ItemSold' end,
	Shipdate = sl.confirmeddlv,
	sl.jsCrossSell
	from #tsalesorders t
	join TTCPROD2009..SALESLINE sl
	on sl.DATAAREAID = 'sco'
	and t.orderid = sl.SALESID
	/*
	left join #FirstLineItem fl
	on sl.salesid = fl.salesid
	and convert(float,sl.LINENUM) = fl.FirstLine
	*/
	order by sl.SALESID, 
	convert(float,sl.LINENUM)

	select orderid, discpercent into #Discounts 
	from #tsalesorders where discpercent <> 0
	

/*
We will have to drop the recid off of tsalesorders
*/
	Alter table #tsalesorders drop column recid;
	Alter table #tsalesorders drop column discpercent;

	insert into DaxImports.staging.DAX_OrderExport
	select * from #tsalesorders

/*Removed as no schema available BondugulaV 2017/01/09 instead using temp table (#working_OrderTotals) */
--truncate table DaxImports.staging.working_OrderTotals
--insert into DaxImports.staging.working_OrderTotals(orderid, MerchandiseTotal)

	select orderid, SUM(quantity * salesprice) as MerchandiseTotal
	into #working_OrderTotals
	from DaxImports.staging.Dax_OrderitemExport
	where LineType = 'ItemSold'
	group by orderid 

	update DaxImports.staging.DAX_OrderExport
	set TotalMerchandise = W.MerchandiseTotal,
	OtherCharges = OtherCharges - Round(( W.MerchandiseTotal * ISNULL(Discpercent,0.00)/100.00),2)
	from DaxImports.staging.DAX_OrderExport oe
	join #working_OrderTotals w
	on oe.orderid = w.orderid
	left join #Discounts d
	on w.orderid = d.orderid

	Update DaxImports.staging.DAX_OrderExport
	set TotalTaxes = case when (TotalMerchandise+TotalCoupons+TotalShipping) > 0 then ABS(St.TotalOrderTaxes) else
					 -1 * ABS(st.TotalOrderTaxes) end
	from DaxImports.staging.DAX_OrderExport ts
	join #TotalTaxes st
	on ts.orderid = st.salesid



	insert into DaxImports.staging.DAX_OrderCouponsExport
	select distinct C.salesid , Coupon = c.JSCOUPONID, CouponDesc = jsc.JSCOUPONDESC
	from TTCPROD2009..JSCOUPONSSALESTABLE c
	join TTCPROD2009..JSCOUPONS jsc
	on c.JSCOUPONID = jsc.JSCOUPONID
	where ISNUMERIC(c.SALESID) = 0

End
GO
