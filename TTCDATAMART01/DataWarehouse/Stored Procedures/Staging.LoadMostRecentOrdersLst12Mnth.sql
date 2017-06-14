SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[LoadMostRecentOrdersLst12Mnth]
	@AsOfDate datetime = null,    
    @Process varchar(50) = ''
AS
BEGIN
	set nocount on
	set @AsOfDate = isnull(@AsOfDate, getdate())   
	
	select @Process = case when @Process = '' then 'CDCR' else @Process end 
    
	 select *
    into #MROData
    from Staging.MostRecent3OrdersLst12Mnth (nolock)
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
        FormatAD,
		StockItemID,
		OrderRecencyRank,
		Adcode
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
        oi.FormatAD,
		oi.StockItemID,
		ccp.OrderRecencyRank,
		ccp.AdCode
    from 
    (
    	select distinct  
            CustomerID, 
            OrderID, 
            DateOrdered,
            OrderSource,
			Adcode,
			dense_rank() over (partition by po.CustomerID order by po.DateOrdered desc) as OrderRecencyRank         
	    --from Marketing.CompleteCoursePurchase po (nolock)
		from Marketing.DMPurchaseOrdersIgnoreReturns po (nolock) --order by CustomerID, OrderRecencyRank
    	where po.DateOrdered < @AsOfDate
		--and po.StockItemID not like '[pd]t%'
    ) ccp
--    join Staging.ValidPurchaseOrderItems oi (nolock) on ccp.OrderID = oi.OrderID -- NB! remove returns or not?
    join Marketing.DMPurchaseOrderItems oi (nolock) on ccp.OrderID = oi.OrderID
    left join Mapping.PCASubjectCategories sc (nolock) on sc.courseid = oi.CourseID
    where 
    	ccp.OrderRecencyRank <= 3
        and oi.FormatMedia <> 'T'

		
		select a.*
		into #MROData2
		from #MROData a join
			(select customerid, max(dateordered) dateordered
			from #MROData
			group by customerid)b on a.customerid = b.customerid
									and	a.dateordered between dateadd(month,-12,b.dateordered) and b.dateordered
		order by a.customerid, a.orderrecencyrank, a.orderitemid


	if @Process in ('CustomerSubjectMatrix', 'CSM')
    begin
		truncate table Staging.MostRecent3OrdersLst12MnthCSM
    	insert into Staging.MostRecent3OrdersLst12MnthCSM
	    select * from #MROData2 (nolock)
    end
	else if @Process in ('CustomerDynamicCourseRank', 'CDCR')
    begin
		truncate table Staging.MostRecent3OrdersLst12MnthCDCR
    	insert into Staging.MostRecent3OrdersLst12MnthCDCR
	    select * from #MROData2 (nolock)
    end
	else if @Process in ('UpsellRecos', 'UR')
    begin
		truncate table Staging.MostRecent3OrdersLst12Mnth
    	insert into Staging.MostRecent3OrdersLst12Mnth
	    select * from #MROData2 (nolock)
    end
end
GO
