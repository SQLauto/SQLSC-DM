SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[GetDailySales]
AS
	Declare 
    	@Todate Datetime, 
        @StartDate Datetime
BEGIN
    Select @Todate = convert(datetime,convert(varchar,getdate(),101))
    Select @StartDate = DATEADD(yy, -2, DATEADD(yy, DATEDIFF(yy,0,getdate()), 0)) 

    select @Todate, @StartDate
    
	if object_id('Marketing.DailySales') is not null 
    Drop table Marketing.DailySales

    select Year(a.DateOrdered) as Yr, MONTH(a.DateOrdered) as Mo, day(a.dateordered) as Order_Day,
                    COUNT(distinct a.customerid) as customers, COUNT(a.orderid) as orders, 
                    SUM(a.netorderamount) as sales,
                    a.billingcountrycode, isnull(a.currencycode,'USD') CurrencyCode,
                    convert(varchar,getdate(),101) AS ReportDate
    into Marketing.DailySales
    from marketing.dmpurchaseorders a (nolock)
    where a.dateordered between @StartDate and @Todate
    group by a.billingcountrycode, a.CurrencyCode, Year(a.DateOrdered), day(a.dateordered), MONTH(a.DateOrdered)

END
GO
