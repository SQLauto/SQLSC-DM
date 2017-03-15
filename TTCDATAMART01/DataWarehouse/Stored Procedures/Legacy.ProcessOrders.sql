SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Legacy].[ProcessOrders]
AS
BEGIN
    set nocount on
    
    update o
    set 
        o.MinShipDate = i.MinShipDate,
        o.MaxShipDate = i.MaxShipDate
    from Legacy.Orders o 
    join Legacy.Invoices i (nolock) on i.OrderID = o.OrderID
    
    UPDATE Legacy.Orders
    SET FlagCouponRedm = 'True' 
    WHERE OrderID IN
    (
        SELECT distinct
            OrderID 
        FROM Legacy.OrderItems OI (nolock)
        JOIN Mapping.DMCouponList CL (nolock) ON OI.StockItemID = CL.UserStockItemID
        where CL.FlagCoupon = 1
    )
    
    UPDATE O
    SET O.DiscountAmount = oi.TS
    FROM Legacy.Orders O
    JOIN 
    (
        SELECT 
            OrderID, 
            SUM(isNull(SalesPrice, 0) * isNull(Quantity, 0)) AS TS
        FROM Legacy.OrderItems (nolock)
        WHERE StockItemID LIKE 'CP%' 
        GROUP BY OrderID
    ) oi on o.OrderID = oi.OrderID

END
GO
