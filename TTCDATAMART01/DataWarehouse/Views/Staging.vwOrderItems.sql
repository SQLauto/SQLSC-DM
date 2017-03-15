SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Staging].[vwOrderItems]
(
  	OrderItemID,
  	StockItemID,
    OrderID,
    SalesPrice,
    Quantity,
    StatusCode,
    TaxableFlag,
    ShipDate,
    [Description],
    PmtStatus,
    RegPrice,
    CustomerID,
    ReturnShip,
    ReturnCoupon,
    ReturnReason,
    ReplaceReason,
    ReturnFlag,
    ReplaceFlag,
    CURRENCYCODE,
    SALESTYPE
    , DLVMODE
    , DELIVERYNAME
    , DELIVERYSTREET
    , deliverycity
    , DELIVERYSTATE
    , DELIVERYZIPCODE
    , DELIVERYCOUNTRYREGIONID
    , AdCode
    , JSPRICEOVERRIDE
    , JSREASONCODE
    , JSORIGINALSALESID
    , LineType
)
AS
  SELECT 
  	oi.OrderItemID,
  	oi.StockItemID,
    convert( nvarchar, oi.OrderID ),
    oi.SalesPrice,
    oi.Quantity,
    os.DAXStatus,
    TaxableFlag,
    ShipDate,
    oi.[Description],
    oi.PmtStatus,
    RegPrice,
    o.CustomerID,
    ReturnShip,
    ReturnCoupon,
    ReturnReason,
    ReplaceReason,
    ReturnFlag,
    ReplaceFlag
    , null /* CURRENCYCODE*/
    , null /* SALESTYPE*/
    , null /* DLVMODE*/
    , null /* DELIVERYNAME*/
    , null /* DELIVERYSTREET*/
    , null /* deliverycity*/
    , null /* DELIVERYSTATE*/
    , null /* DELIVERYZIPCODE*/
    , null /* DELIVERYCOUNTRYREGIONID*/
    , o.AdCode
    , null /* JSPRICEOVERRIDE*/
    , null /* JSREASONCODE*/
    , null /* JSORIGINALSALESID*/
    , null /* LineType*/
  from Legacy.OrderItems oi (nolock) 
  join Mapping.LegacyDAX_OrderStatus os (nolock) on os.LegacyStatus = oi.StatusCode
  join Legacy.Orders o (nolock) on o.OrderID = oi.OrderID
  
  union all

  SELECT 
  	oi.OrderItemID,  
  	oi.StockItemID,
    oi.OrderID,
    oi.SalesPrice,
    oi.Quantity,
    oi.SalesStatus,
    null, /*TaxableFlag*/
	oi.ShipDate,
    i.[Description],
    o.PaymentStatus, /* PmtStatus */
    JSLISTPRICE
    , o.CustomerID
    , null /* ReturnShip*/
    , null /* ReturnCoupon*/
    , null /* ReturnReason*/
    , null, /* ReplaceReason*/
    case
    	when oi.OrderID like 'ret%' then 1
        else 0
    end as ReturnFlag
    , null /* ReplaceFlag*/
    , oi.CURRENCYCODE
    , oi.SALESTYPE
    , DLVMODE
    , DELIVERYNAME
    , DELIVERYSTREET
    , deliverycity
    , DELIVERYSTATE
    , DELIVERYZIPCODE
    , DELIVERYCOUNTRYREGIONID
    , JSSOURCEID as AdCode
    , JSPRICEOVERRIDE
    , JSREASONCODE
    , JSORIGINALSALESID
    , LineType
  from Staging.OrderItems oi (nolock)
  join Staging.InvItem i (nolock) on i.StockItemID = oi.StockItemID
  join Staging.Orders o (nolock) on o.OrderID = oi.OrderID 
  left join Staging.Customers c (nolock) on c.CustomerID = o.CustomerID -- PR -- 11/26/2013 -- to filter Barnes and Nobel which has already been included in order with Regular orderSource other than 'Retail' new for audible.
  where o.OrderSource not in ('', 'Retail', 'Replace') -- to fix issue with empty order source and replacements
										-- PR -- 11/26/2013 -- Added 'B' (for Retail/BtoB like Audible etc.) to filter them from main stream tables. 
    and o.CSRID not in ('tgcso') -- PR -- 3/11/2013 -- to filter all Omni Lite and other orders ingested with $0 amount for upgrades etc.
   -- and o.OrderSource not in ('VEN-PHONE')  -- PR -- 3/11/2013 -- to filter all Omni Lite and other orders ingested with $0 amount for upgrades etc.  
	and oi.StockItemID not like 's[av]%' -- PR -- 5/30/2013 -- to filter all Omni Streaming items to avoid double counting units on our end.
	and c.CustGroup not in ('Retail') -- PR -- 11/26/2013 -- to filter Barnes and Nobel which has already been included in order with Regular orderSource other than 'Retail' new for audible.
	and o.AdCode <> 92316 -- PR -- 2/4/2014 -- TS needs to give all streaming items to board/executives and CSR. So, exclude these orders
GO
