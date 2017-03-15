SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[LoadMostRecentOrders]
	@AsOfDate datetime = null,    
    @Process varchar(50) = ''
AS
BEGIN
	set nocount on
    set @AsOfDate = isnull(@AsOfDate, getdate())    
    
    select *
    into #MROData
    from Staging.MostRecent3Orders (nolock)
    where 1=2

    insert into #MROData
    (
        CustomerID, 
        OrderID,     
        DateOrdered, 
        OrderItemID, 
        CourseID,
        Parts,
        SubjectCategory,
        SubjectCategory2,
        SubjectPreferenceID,
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
        oi.SubjectCategory,
        oi.SubjectCategory2,
        sc.SubjectPreferenceID,
        ccp.OrderSource,
        oi.FormatMedia,
        oi.FormatAV,
        oi.FormatAD
    from 
    (
    	select distinct  
            CustomerID, 
            OrderID, 
            DateOrdered,
            OrderSource,
			dense_rank() over (partition by po.CustomerID order by po.DateOrdered desc) as OrderRecencyRank         
	    from Marketing.CompleteCoursePurchase po (nolock)
    	where po.DateOrdered < @AsOfDate
    ) ccp
--    join Staging.ValidPurchaseOrderItems oi (nolock) on ccp.OrderID = oi.OrderID -- NB! remove returns or not?
    join Marketing.DMPurchaseOrderItems oi (nolock) on ccp.OrderID = oi.OrderID
    left join Mapping.PCASubjectCategories sc (nolock) on sc.courseid = oi.CourseID
    where 
    	ccp.OrderRecencyRank <= 3
        and oi.FormatMedia <> 'T'

	if @Process in ('CustomerSubjectMatrix', 'CSM')
    begin
		truncate table Staging.MostRecent3OrdersCSM
    	insert into Staging.MostRecent3OrdersCSM
	    select * from #MROData (nolock)
    end
	else if @Process in ('CustomerDynamicCourseRank', 'CDCR')
    begin
		truncate table Staging.MostRecent3OrdersCDCR
    	insert into Staging.MostRecent3OrdersCDCR
	    select * from #MROData (nolock)
    end
	else if @Process in ('UpsellRecos', 'UR')
    begin
		truncate table Staging.MostRecent3Orders
    	insert into Staging.MostRecent3Orders
	    select * from #MROData (nolock)
    end
end
GO
