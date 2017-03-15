SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROC [Staging].[CreateIWBReport] 
	@StartDate datetime = null
AS 

/* Preethi Ramanujam 	3/12/2012
	To get the list of Courses that are active in a mail piece
*/

    set @StartDate = isnull(@StartDate, convert(datetime,convert(varchar,dateadd(month,-3,getdate()),101)))

	PRINT '@StartDate = ' + convert(varchar,@StartDate)

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TempIWB1')	
	drop table staging.TempIWB1

	select do.*, c.Description as OrderStatusDescription
	into staging.TempIWB1
	from DAXImports..DAX_OrderExport do left join
		(select distinct DaxStatus, Description
			from Mapping.LegacyDAX_OrderStatus)c on do.OrderStatus = c.DAXStatus 
		where orderdate >= @StartDate

	create index ix_TempIWB1 on staging.TempIWB1 (OrderID)

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Temp_IWB_StatusCheckReport')
	drop table Staging.Temp_IWB_StatusCheckReport	

	declare @today datetime
	select @today = GETDATE()

	Select YEAR(a.OrderDate) YearOrdered,
		MONTH(a.Orderdate) MonthOrdered,
		Staging.GetMonday(a.OrderDate) WeekOf,
		case when a.BillingCountryCode in ('CA','US','AU','GB') then a.BillingCountryCode
			else 'Other'
		end as BillingCountryCode,
		case when a.ShipToCountryCode in ('CA','US','AU','GB') then a.ShipToCountryCode
			else 'Other'
		end as ShipToCountryCode,
		a.CurrencyCode,
		a.OrderStatus,
		a.OrderStatusDescription,
		a.Ordersource,
		a.SourceCode as Adcode,
		va.AdcodeName,
		va.CatalogCode,
		Va.CatalogName,
		B.ItemID,
		lii.Description as ItemName,
		case when b.orderid like 'RET%' then 'Return'
			else 'Sales'
		end as OrderType,
		ISNULL(new.SequenceNum,0) as FlagNewCust,
		@today as ReportDate,
		sum(b.Quantity) TotalCount,
		COUNT(distinct a.orderid) TotalOrders
	into Staging.Temp_IWB_StatusCheckReport	
	from staging.TempIWB1 a 
		join 
		DAXImports..DAX_OrderItemExport b on a.orderid = b.orderid 
		left join
		Mapping.vwAdcodesAll va on a.SourceCode = va.AdCode
		left join
		(select OrderID, SequenceNum
		 from Marketing.DMPurchaseOrders
		where SequenceNum = 1)New on b.orderid = New.OrderID 
		left join
		DAXImports..Load_InvItem lii on b.ITEMID = lii.UserStockItemID
	where b.OrderItemid = 0
	group by YEAR(a.OrderDate),
		MONTH(a.Orderdate),
		Staging.GetMonday(a.OrderDate),
		case when a.BillingCountryCode in ('CA','US','AU','GB') then a.BillingCountryCode
			else 'Other'
		end,
		case when a.ShipToCountryCode in ('CA','US','AU','GB') then a.ShipToCountryCode
			else 'Other'
		end,
		a.CurrencyCode,
		a.OrderStatus,
		a.OrderStatusDescription,
		a.Ordersource,
		a.SourceCode,
		va.AdcodeName,
		va.CatalogCode,
		Va.CatalogName,	
		b.ITEMID,
		lii.Description,
		case when b.orderid like 'RET%' then 'Return'
			else 'Sales'
		end,
		ISNULL(new.SequenceNum,0)
	order by 1,2	

	truncate table Marketing.IWB_StatusCheckReport	
	
	insert into Marketing.IWB_StatusCheckReport	
	select * from Staging.Temp_IWB_StatusCheckReport	
	
	drop table Staging.Temp_IWB_StatusCheckReport	
	drop table staging.TempIWB1
	
GO
