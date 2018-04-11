SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [Staging].[LoadMostRecentOrdersTGCPref]
	@AsOfDate datetime = null
AS
BEGIN
	set nocount on
    set @AsOfDate = isnull(@AsOfDate, getdate())    
    
    select *
   -- into #MROData
    from Staging.MostRecent3OrdersTGCPref (nolock)
    where 1=2

    insert into #MROData
    (
        CustomerID, 
        OrderID,     
        DateOrdered, 
        OrderItemID, 
        CourseID,
        TotalParts,
        SubjectCategory2,
        OrderSource,
        FormatMedia,
        FormatAV,
        FormatAD
    )
    select 
        ccp.CustomerID,
        ccp.OrderID,
        ccp.DateOrdered,
        oi.OrderItemID,
        oi.CourseID,
        oi.TotalParts,
        oi.SubjectCategory2,
        ccp.OrderSource,
        oi.FormatMedia,
        oi.FormatAV,
        case when left(oi.StockItemID,2) in ('DA','DV') then 'Digital' else 'Physical' end as FormatAD
    from 
    (
    	select distinct  
            CustomerID, 
            OrderID, 
            DateOrdered,
            OrderSource,
			dense_rank() over (partition by po.CustomerID order by po.DateOrdered desc) as OrderRecencyRank         
	    from Marketing.CompleteCoursePurchase po (nolock)
    	where po.DateOrdered < '3/1/2018' --@AsOfDate
    ) ccp
    join Marketing.DMPurchaseOrderItems oi (nolock) on ccp.OrderID = oi.OrderID
    where 
    	ccp.OrderRecencyRank <= 3
        and oi.FormatMedia <> 'T'

		truncate table Staging.MostRecent3OrdersTGCPref
    	insert into Staging.MostRecent3OrdersTGCPref
	    select * from #MROData (nolock)
 
end
GO
