SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Staging].[LoadCompleteCoursePurchase]
as
begin
    set nocount on
    
	select *
    into #CompleteCoursePurchase
    from Marketing.CompleteCoursePurchase (nolock)
    where 0=1

    insert into #CompleteCoursePurchase
    (
        OrderID, 
        CustomerID, 
		CourseID,    
        BundleID, 
        Portion,
        Amount,
        SubjectCategory,
        SubjectCategory2,
        DateOrdered,
        StockItemID,
        OrderSource
    )
    select  
    	o.OrderID,
        O.CustomerID, 
        isnull(B.CourseID, i.CourseID) as CourseID,    
        isnull(B.BundleID, 0),         
        isnull(B.Portion, 1),        
        isnull(oi.SalesPrice, 0) * isnull(oi.Quantity, 0) * isnull(B.Portion, 1) as Amount,        
        c.SubjectCategory, 
        c.SubjectCategory2,
        o.DateOrdered,
        OI.StockItemID,
        o.OrderSource        
    FROM Staging.vwOrders O (nolock)
    join Staging.vwOrderItems OI (nolock) on O.OrderID = OI.OrderID
    join Staging.InvItem I (nolock) on OI.StockItemID = I.StockItemID
    left join Mapping.BundleComponents b (nolock) on I.CourseID = B.BundleID        
    join Mapping.DMCourse c (nolock) on c.CourseID = isnull(B.CourseID, i.CourseID)
    WHERE 
        I.StockItemID LIKE '[PDL][AVCDMT]%'
		and O.OrderID not like '%RET%'
        and isnull(oi.SalesPrice, 0) * isnull(oi.Quantity, 0) * isnull(B.Portion, 1) >= 0
		
    /*<recalculate customer's buyer type>*/
    ;with CollegeBuyers(CustomerID) as
    (
        select distinct
            cs.CustomerID
        from #CompleteCoursePurchase cs (nolock)
    )
    update c
        set c.BuyerType = 4
    from Staging.Customers c
    join CollegeBuyers cb (nolock) on cb.CustomerID = c.MergedCustomerID

    ;with HighSchoolBuyers(CustomerID) as
    (
        select distinct
            cs.CustomerID
        from #CompleteCoursePurchase cs (nolock)
        left join 
        (
            select distinct
                CustomerID
            from #CompleteCoursePurchase (nolock)
            where SubjectCategory <> 'HS'
        ) cs2 on cs.CustomerID = cs2.CustomerID
        where 
            cs.SubjectCategory = 'HS'
            and cs2.CustomerID is null
    )
    update c
        set c.BuyerType = 3
    from Staging.Customers c
    join HighSchoolBuyers hsb (nolock) on hsb.CustomerID = c.MergedCustomerID
    /*</recalculate customer's buyer type>*/

    truncate table Marketing.CompleteTranscriptPurchase
    insert into Marketing.CompleteTranscriptPurchase
    select *
	from #CompleteCoursePurchase (nolock)
    where StockItemID like '[PDL][T]%'    

	truncate table Marketing.CompleteCoursePurchase
    insert into Marketing.CompleteCoursePurchase
    select * from #CompleteCoursePurchase (nolock)
	where StockItemID not like '[PDL][T]%'    

end
GO
