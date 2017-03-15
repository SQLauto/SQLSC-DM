SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[ProcessOrders]
as
begin
    set nocount on
    
    ;with ShipDates(OrderID, MinShipDate, MaxShipDate) as
    (
        select OrderID, min(oi.ShipDate), max(oi.ShipDate)
        from Staging.OrderItems oi (nolock)
        group by OrderID				
    )
    update o
    set 
        o.MinShipDate = d.MinShipDate,
        o.MaxShipDate = d.MaxShipDate
    from Staging.Orders o     
    join ShipDates d (nolock) on d.OrderID = o.OrderID
    
    ;with RejectedOrders(OrderID) as
    (
        select t.OrderID
        from Staging.OrderPayments t (nolock)
        where t.[status] = 2 
        except 
        select t2.OrderID
        from Staging.OrderPayments t2 (nolock)
        where t2.[status] <> 2
    )
    update o
    set 
        o.PaymentStatus = 
        case
            when isnull(ro.OrderID, '') = '' then 4
            else 2
        end
    from Staging.Orders o
    left join RejectedOrders ro (nolock) on o.OrderID = ro.OrderID
    
    update o
    set     
    	o.ModifiedDate = 
        case
        	when o.ModifiedDateGMT < '1/2/2012' then o.ModifiedDateGMT
            else dbo.GMTToLocalDateTime(o.ModifiedDateGMT)
        end,
    	o.OrderDate = 
        case
        	when o.OrderDateGMT < '1/2/2012' then o.OrderDateGMT
            else dbo.GMTToLocalDateTime(o.OrderDateGMT)
        end,
		o.OrderSource = 
        case
        	when isnull(o.OrderSource, '') = '' then 'PHONE' -- initial bug in DAX for replacements ordered by phone, fixed later
            else o.OrderSource
        end    
    from Staging.Orders o    
    
end
GO
