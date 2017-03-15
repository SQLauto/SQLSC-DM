SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Staging].[vwValidPurchaseOrderItems] 
(
	OrderID,
    CourseID,
    OrderItemID,
	DateOrdered,
	TotalSales,
    TotalParts,
	TotalQuantity,
    FormatMedia,
    FormatAV,
    FormatAD,
    SubjectCategory,
    SubjectCategory2,    
    FlagLegacy,
    StockItemID,
    CustomerID
)
AS
	/* legacy (Avaya) order items*/
	select 
        OrderID,
        CourseID,
        OrderItemID,
        DateOrdered,
		TotalSales,
        TotalParts,
		TotalQuantity,
        FormatMedia,
        FormatAV,
        FormatAD,
        SubjectCategory,
        SubjectCategory2,    
        FlagLegacy,
	    StockItemID,
        CustomerID
	from Marketing.DMPurchaseOrderItems poi (nolock)
	where 
		poi.FlagReturn = 'False'
		and poi.FlagPaymentRejected = 'False'
/*		and isnull(poi.PaymentStatus, 1) <> 0*/
		and poi.FlagLegacy = 'True'
		and not exists 
		(
			select poi2.OrderID
			from Marketing.DMPurchaseOrderItems poi2 (nolock)
			where 
				poi.OrderID = poi2.OrderID 
				and poi.StockItemID = poi2.StockItemID 
				and poi2.FlagReturn = 'True'
				and poi.FlagLegacy = 'True'
		)

	union all
    
	/* DAX order items    */
	select 
        OrderID,
        CourseID,
        OrderItemID,
        DateOrdered,
		TotalSales,
        TotalParts,
		TotalQuantity,
        FormatMedia,
        FormatAV,
        FormatAD,
        SubjectCategory,
        SubjectCategory2,    
        FlagLegacy,
	    StockItemID,
        CustomerID
	from Marketing.DMPurchaseOrderItems poi (nolock)
	where 
		poi.FlagReturn = 'False'
		and poi.FlagLegacy = 'False'
		and not exists 
		(
			select poi2.OrderID
			from Marketing.DMPurchaseOrderItems poi2 (nolock)
			where 
				poi.OrderID = poi2.OriginalOrderID 
				and poi.StockItemID = poi2.StockItemID 
				and poi2.FlagReturn = 'True'
				and poi.FlagLegacy = 'False'
		)

GO
