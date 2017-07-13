SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Staging].[vwOrders]
-- PR 2/12/2016 Removing TAX from NetOrderAmount based on business requirement
(
    FlagLegacy,
	OrderID,
    CustomerID,
    InvoiceAccount,
    DateOrdered,
    StatusCode,
    SalesTypeID,
    CurrencyCode,
    NetOrderAmount,
    AdCode,
    ShipFullName,
    ShipAddress,
    ShipAddress2,
    ShipCity,
    ShipRegion,
    ShipPostalCode,
    ShipCountryCode,
    PmtMethodID,
    PmtStatus,
    CardType,
    CardNum,
    CardExpire,
    ShipMethodID,
    GiftFlag,
    GiftMessage,
    TotalReadyCost,
    TotalReadyTaxCost,
    ShipUpgradeCost,
    PaymentToDate,
    CSRID,
    TaxExemptFlag,
	CatalogOrder,
    OrderSource,
	Instructions,
	WebOrder_Id,
    ShipPhoneNumber,
    RegShipCost,
    Discount,
    ReturnAmt,
    DateModified,
	DiscountReason,
    BillingAddress,
    BillingAddress2,
    BillingCity,
    BillingCountryCode,
    BillingRegion,
    BillingPostalCode,
    AgentLastModified,
    OverrideShipping,
    IncludeShipInTax,
    ItemsReturned,
	TaxRate,
    TaxPaidToDate,
    DiscountAppliedToDate,
    RetShipAmt,
    RetMerchAmt,
    RetTaxAmt,
    ShipEmail,
    DateReturned,
    ZeroCostReason,
    Notes,
    retCouponAmt,
    GST_HSTAmt,
    PST_QSTAmt,
    RetGST_HSTAmt,
    RetPST_QSTAmt,
    ShippingCharge,
    MinShipDate,
    MaxShipDate,
    FlagCouponRedm,
    DiscountAmount,
    OrderChannel,
    CUSTGROUP,
    MultipleDeliveries,
    BillingName,
    BillingAddress3
)
as
    select
        convert(bit , 'True'), 
	    convert(nvarchar(20), o.OrderID), 
        case
            when isnull(c.RootCustomerID, '') = '' then convert(nvarchar(20), o.CustomerID)
            else c.RootCustomerID
        end,
        null, /* InvoiceAccount*/
        O.DateOrdered,
        os.DAXStatus,
        null, /* SalesType*/
        rtrim(ltrim(CurrencyCode)),
        -- o.NetOrderAmount, -- PR 2/12/2016 Removing TAX from NetOrderAmount for US orders based on business requirement
        case when o.ShipCountryCode like '%US%' then (o.NetOrderAmount - o.TotalReadyTaxCost) 
			when o.ShipCountryCode = 'AU' then (o.NetOrderAmount - o.TotalReadyTaxCost) -- Added AU on 6/22 as AU will be charging tax from 7/1
			else o.NetOrderAmount
		end as NetOrderAmount,
        o.AdCode,
	    ShipFullName,
        ShipAddress,
        ShipAddress2,
        ShipCity,
        ShipRegion,
        ShipPostalCode,
        ShipCountryCode,
        pm.DAXMethod,
        PmtStatus,
        ct.DAXID,
        CardNum,
        CardExpire,
        sm.DAXMethod,
        case GiftFlag
        	when 'T' then 1
            else 0
        end as GiftFlag,
        GiftMessage,
        TotalReadyCost,
        TotalReadyTaxCost,
        ShipUpgradeCost,
        PaymentToDate,
        CSRID,
		TaxExemptFlag,
		isnull(CatalogOrder, 'F'),
		OrderSource,
		Instructions,
		WebOrder_Id,
        ShipPhoneNumber,
        RegShipCost,
        Discount,
        ReturnAmt,
        DateModified,
	    DiscountReason,
        BillingAddress,
        BillingAddress2,
        BillingCity,
        BillingCountryCode,
        BillingRegion,
        BillingPostalCode,
        AgentLastModified,
        OverrideShipping,
        IncludeShipInTax,
        ItemsReturned,
        TaxRate,
        TaxPaidToDate,
        DiscountAppliedToDate,
        RetShipAmt,
        RetMerchAmt,
        RetTaxAmt,
        ShipEmail,
        o.DateReturned,
        o.ZeroCostReason,
        o.Notes,
        o.retCouponAmt,
        o.GST_HSTAmt,
        PST_QSTAmt,
        RetGST_HSTAmt,
        RetPST_QSTAmt,
        ShippingCharge,
        MinShipDate,
        MaxShipDate,
        FlagCouponRedm,
        DiscountAmount
        , null /* OrderChannel*/
        , null /* CUSTGROUP*/
        , null /* MultipleDeliveries*/
        , null /* BillingName*/
        , null /* BillingAddress3*/
    FROM Legacy.Orders O (nolock)
    left join Staging.Customers c (nolock) on c.CustomerID = convert(nvarchar(20), o.CustomerID)
    join Mapping.LegacyDAX_OrderStatus os (nolock) on os.LegacyStatus = o.StatusCode
    join Mapping.LegacyDAX_PmtMethodID pm (nolock) on 
    	pm.LegacyID = isNull(convert(varchar(4), PmtMethodID), '0') or
        (PmtMethodID = 4 and pm.LegacyID = convert(varchar(4), PmtMethodID) + ltrim(rtrim(CurrencyCode)))
	join Mapping.LegacyDAX_CardType ct (nolock) on ct.LegacyID = isNull(o.CardType, 0)
    join Mapping.LegacyDAX_ShipMethodID sm (nolock) on sm.LegacyID = isNull(o.ShipMethodID, 0)

	union all
    
    select
        convert(bit, 'False'),     
        o.OrderID, 
        case
            when isnull(c.RootCustomerID, '') = '' then o.CustomerID
            else c.RootCustomerID
        end,
        o.InvoiceAccount,
        o.OrderDate,
        o.OrderStatus,
        o.SalesType,
        o.CurrencyCode,
       -- isnull(o.TotalMerchandise, 0) + isnull(o.TotalTaxes, 0) + isnull(o.TotalShipping, 0) + isnull(o.TotalCoupons, 0) + isnull(o.OtherCharges, 0),    
							 -- PR 2/12/2016 Removing TAX from NetOrderAmount for US orders based on business requirement
       case when o.ShipToCountryCode = 'US' then
					isnull(o.TotalMerchandise, 0) + isnull(o.TotalShipping, 0) + isnull(o.TotalCoupons, 0) + isnull(o.OtherCharges, 0) 
			when o.ShipToCountryCode = 'AU' then
					isnull(o.TotalMerchandise, 0) + isnull(o.TotalShipping, 0) + isnull(o.TotalCoupons, 0) + isnull(o.OtherCharges, 0)  -- Added AU on 6/22 as AU will be charging tax from 7/1
		else isnull(o.TotalMerchandise, 0) + isnull(o.TotalTaxes, 0) + isnull(o.TotalShipping, 0) + isnull(o.TotalCoupons, 0) + isnull(o.OtherCharges, 0)
		end	as NetOrderAmount,    
        o.SourceCode,
	    o.ShipToName,
		o.ShiptoAddress,
        null, /*ShipAddress2*/
        o.ShipToCity,
        o.ShipToState,
        o.ShipToZip,
        o.ShipToCountryCode,
        null, /* op.PaymMode,*/
        null, /* convert(varchar, op.[status]),*/
        null, /* op.ccvendor,*/
        null, /*CardNum*/
        null, /* op.ExpirationMonth + '/' + right(2, op.ExpirationYear),*/
		o.DeliveryMode,
        o.jsGiftFlag,
        o.jsGiftMessage,
        TotalMerchandise,
        isnull(TotalTaxes, 0),
        null, /*ShipUpgradeCost*/
        null, /*op.PaymentToDate,*/
        o.CSRID,
        case
        	when isNull(o.TaxGroup, '') = '' then 'F'
            else 'T'
        end as TaxExemptFlag,
		'F' as CatalogOrder,
		os.OrderSource,
		null, /*Instructions*/
	    WebOrderID,
        o.jsDeliveryPhone,
	    TotalShipping,
        TotalCoupons + OtherCharges,
        null, /*ReturnAmt*/
        o.ModifiedDate,
		null, /*DiscountReason*/
        o.BillingAddress1,
        o.BillingAddress2,
        o.BillingCity,
        o.BillingCountryCode,
        o.BillingState,
        o.BillingZip,
        o.ModifiedBy,
        null, /*OverrideShipping*/
        null, /*IncludeShipInTax*/
        null, /*ItemsReturned*/
        null, /*TaxRate*/
        null, /*TaxPaidToDate*/
        null, /*DiscountAppliedToDate*/
        null, /*RetShipAmt*/
        null, /*RetMerchAmt*/
        null, /*RetTaxAmt*/
        null /*ShipEmail*/
        , null /* DateReturned*/
        , null /* ZeroCostReason*/
        , null /* Notes*/
        , null /* retCouponAmt*/
        , null /* GST_HSTAmt*/
        , null /* PST_QSTAmt*/
        , null /* RetGST_HSTAmt*/
        , null /* RetPST_QSTAmt*/
        , o.TotalShipping
        , MinShipDate
        , MaxShipDate,
		case
        	when isNull(o.TotalCoupons, 0) < 0 then 1
            else 0
        end as FlagCouponRedm
        , o.OtherCharges
        , OrderChannel
        , o.CUSTGROUP
        , MultipleDeliveries
        , BillingName
        , BillingAddress3
    from Staging.Orders O (nolock)
    left join Staging.Customers c (nolock) on c.CustomerID = o.CustomerID
    left join Mapping.LegacyDAX_OrderSource os (nolock) on o.OrderSource = os.[Description]
    where o.OrderSource not in ('RETAIL', 'REPLACE', '') -- to fix issue with empty order source and replacements
						-- PR -- 11/26/2013 -- Added 'B' (for Retail/BtoB like Audible etc.) to filter them from main stream tables. 
    and o.CSRID not in ('tgcso') -- PR -- 3/11/2013 -- to filter all Omni Lite and other orders ingested with $0 amount for upgrades etc.
  --  and o.OrderSource not in ('VEN-PHONE')
	and c.CustGroup not in ('Retail') -- PR -- 11/26/2013 -- to filter Barnes and Nobel which has already been included in order with Regular orderSource other than 'Retail' new for audible.
    and o.AdCode <> 92316 -- PR -- 2/4/2014 -- TS needs to give all streaming items to board/executives and CSR. So, exclude these orders
    

/*    left join 
    (
    	select sum(op.AMOUNT) as PaymentToDate, op.OrderID
		from Staging.OrderPayments op (nolock)
		where op.[status] <> 2
		group by op.OrderID
	) op on o.OrderID = op.OrderID */




GO
