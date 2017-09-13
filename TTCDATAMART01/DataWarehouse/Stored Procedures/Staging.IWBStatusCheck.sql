SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [Staging].[IWBStatusCheck] 

AS

/* PR - 1/22/2014 - to create a report with shipping catatlog/inserts
					usage for production team to get some idea about inventory

*/
	

-- identify the orders that do not have OrderItemID 0
/*
  	if object_id('Staging.NoOrderItem0') is not null drop table Staging.NoOrderItem0
	
	select distinct a.orderid
	into staging.NoOrderItem0
	from DAXImports..DAX_OrderItemExport a left join
		(select distinct orderid from DAXImports..DAX_OrderItemExport
		where OrderItemid = 0)b on a.orderid = b.orderid
	where b.orderid is null
*/

-- load the data into working table
  	if object_id('Staging.IWB_StatusCheckReport_TEMP') is not null drop table Staging.IWB_StatusCheckReport_TEMP

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
	into Staging.IWB_StatusCheckReport_TEMP	
	from (select do.*, c.Description as OrderStatusDescription
		from DAXImports..DAX_OrderExport do left join
			(select distinct DaxStatus, Description
				from DataWarehouse.Mapping.LegacyDAX_OrderStatus)c on do.OrderStatus = c.DAXStatus 
			where orderdate >= DATEADD(month,-18,getdate()))a 
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

-- Load the data into final table

	truncate table Marketing.IWB_StatusCheckReport

	Insert into Marketing.IWB_StatusCheckReport
	select * from Staging.IWB_StatusCheckReport_TEMP

GO
