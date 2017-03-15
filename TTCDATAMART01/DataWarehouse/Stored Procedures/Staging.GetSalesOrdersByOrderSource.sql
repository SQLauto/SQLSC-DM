SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [Staging].[GetSalesOrdersByOrderSource]
AS
BEGIN
    set nocount on
    
	truncate table Staging.SalesOrdersByOrderSource    
	insert into Staging.SalesOrdersByOrderSource
    (
    	Sales,
        TotalOrders,
    	OrderSource,
        YearOrdered,
        MonthOrdered,
        CurrencyCode
    )    
    select 
        sum(o.netorderamount) Sales, 
        count(O.OrderID)  TotalOrders, 
        o.OrderSource, 
        Year(dateordered) YearOrdered,
        MONTH(dateordered) MonthOrdered,
        o.CurrencyCode
    from Staging.vworders o (nolock)
    where dateordered >= convert(date, '1/1/' + convert(char(4), year(getdate()) - 4))
    group by ordersource, Year(dateordered)	, MONTH(dateordered), o.CurrencyCode
    order by Year(dateordered), MONTH(dateordered), ordersource
    
END
GO
