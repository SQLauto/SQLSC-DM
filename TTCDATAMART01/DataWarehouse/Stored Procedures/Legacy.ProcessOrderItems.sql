SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Legacy].[ProcessOrderItems]
AS
BEGIN
    set nocount on
    set transaction isolation level read uncommitted
    	
    /* scrubbing AVAYA bug/feature    */
    update oi
    set oi.StockItemID = substring(oi.Description, 10, 6)
    from Legacy.OrderItems oi
    join Staging.InvItem ii on ii.StockItemID = oi.StockItemID
    join Legacy.Orders o on o.OrderID = oi.OrderID
    where 
        (oi.Quantity < 0 or oi.SalesPrice < 0)
        and (oI.StockItemID LIKE '[P][TM]%' or OI.StockItemID LIKE '[PL][CD]%' or OI.StockItemID LIKE '[PLSD][AV]%') 
        and (o.DateOrdered >= '10/20/2004' OR ShipDate >= '10/20/2004')
        and ii.ItemCategoryID = 'Bundle'
        and substring(oi.[Description], 10, 5) like '[A-Z][A-Z][0-9][0-9][0-9]%'
    
    /* to account for no StockItems starting with S in InvItem    */
	update oi
	set oi.StockItemID = 'P' + substring(oi.StockItemID, 2, 6)
	from Legacy.OrderItems oi
	where 
    	substring(oi.StockItemID, 1, 1) = 'S'
	    and (oI.StockItemID LIKE '[P][TM]%' or OI.StockItemID LIKE '[PL][CD]%' or OI.StockItemID LIKE '[PLSD][AV]%')         
        
	set transaction isolation level read committed        
END
GO
