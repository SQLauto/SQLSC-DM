SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Staging].[LoadDailySpendTracker]
	@Month int = null,
	@Year int = null
as
declare
    @AsOfDate date,
    @ToDate date,
    @LoopDate date
begin
	set nocount on

	set @Month = isnull(@Month, month(getdate()))
	set @Year = isnull(@Year, year(getdate()))    
    
    set @AsOfDate = cast(@Month as varchar(2)) + '/1/' + cast(@Year as varchar(4))
    set @ToDate = dateadd(s, -1, dateadd(mm, datediff(m, 0, @AsOfDate) + 1, 0))
    set @LoopDate = @AsOfDate
    
    exec Staging.LoadRFMData @AsOfDate, 'MidwaySpendTrack'  

  	if object_id('Staging.TempDailySpendTracker') is not null drop table Staging.TempDailySpendTracker
    
    ;with cteOrdersStats
    (
    	CustomerID, DateOrdered, TotalSales, TotalOrders, 
    	TotalCourseParts, TotalCourseQuantity, TotalCourseSales,
        TotalTranscriptParts, TotalTranscriptQuantity, TotalTranscriptSales
    ) as
    (
    	SELECT 
        	O.CustomerID, 
            cast(o.DateOrdered as date) DateOrdered,
            SUM(o.NetOrderAmount) as TotalSales, 
            Count(o.OrderID) as TotalOrders,
            sum(po.TotalCourseParts) as TotalCourseParts,
            sum(po.TotalCourseQuantity) as TotalCourseQuantity,
            sum(po.TotalCourseSales) as TotalCourseSales,
            sum(po.TotalTranscriptParts) as TotalTranscriptParts,
            sum(po.TotalTranscriptQuantity) as TotalTranscriptQuantity,
            sum(po.TotalTranscriptSales) as TotalTranscriptSales
        FROM Staging.vwOrders O (nolock)
		join Marketing.DMPurchaseOrders po (nolock) on o.OrderID = po.OrderID        
        WHERE 
        	cast(o.DateOrdered as date) BETWEEN @AsOfDate AND @ToDate
	        AND o.NetOrderAmount > 0 and o.NetOrderAmount < 1500
        GROUP BY 
			cast(o.DateOrdered as date),
        	O.CustomerID
	)    
    select 
		@AsOfDate as AsOfDate, 
        t.DateOrdered as ToDate,
        Rc.[Active] as IsActive,         
        rfm.Frequency, 
    	rfm.CustomerID,         
        isnull(TotalSales, 0) as TotalSales,
        isnull(TotalOrders, 0) as TotalOrders,
        TotalCourseParts,
        TotalCourseQuantity,
        TotalCourseSales,
        TotalTranscriptParts,
        TotalTranscriptQuantity,
        TotalTranscriptSales/*,
		case when c.CountryCode in ('US','CA','AU','GB') then c.CountryCode
			else 'ROW'
		end as CountryCode*/
	into Staging.TempDailySpendTracker
    from Staging.RFMDataMST rfm (nolock)
    join Mapping.RFMComboLookup rc (nolock) ON rfm.Concatenated = rc.Concatenated and rfm.a12mf = rc.A12mf
    join cteOrdersStats t ON rfm.Customerid = t.CustomerID
	left join Staging.Customers c on rfm.CustomerID = c.CustomerID
    
    delete t
    from Marketing.DailySpendTracker t 
    where t.AsOfDate = @AsOfDate
    
   -- ;with cteRFMStats(IsActive, Frequency, CountOfCustomers, CountryCode) as
    ;with cteRFMStats(IsActive, Frequency, CountOfCustomers) as
    (
        select 
            Rc.[Active] as IsActive,         
            rfm.Frequency, 
            count(rfm.CustomerID) as CountOfCustomers/*,
		case when c.CountryCode in ('US','CA','AU','GB') then c.CountryCode
			else 'ROW'
		end as CountryCode    */     
        from Staging.RFMDataMST rfm (nolock)
        join Mapping.RFMComboLookup rc (nolock) ON rfm.Concatenated = rc.Concatenated and rfm.a12mf = rc.A12mf
		left join Staging.Customers c on rfm.CustomerID = c.CustomerID
        group by
            Rc.[Active],
            rfm.Frequency/*,
		case when c.CountryCode in ('US','CA','AU','GB') then c.CountryCode
			else 'ROW'
		end */
    )        
    insert into Marketing.DailySpendTracker
    (
        AsOfDate,
        ToDate,
        IsActive,
        Frequency,    
        CountOfCustomers,
        AsOfMonth,
        AsOfYear,
        DayOfMonth/*,
		CountryCode*/
    )
    select distinct
        t.AsOfDate,
        t.ToDate,
        t.IsActive,
        t.Frequency,    
        rs.CountOfCustomers,
        @Month,
        @Year,
        day(t.ToDate)/*,
		rs.CountryCode*/
    from Staging.TempDailySpendTracker t (nolock)
    join cteRFMStats rs on t.IsActive = rs.IsActive and t.Frequency = rs.Frequency --and t.CountryCode = rs.CountryCode
    
	while @LoopDate <= @ToDate
    begin
    	--;with cteDailySpendTrackerStats(CountryCode, IsActive, Frequency, CountOfBuyers, 
		;with cteDailySpendTrackerStats(IsActive, Frequency, CountOfBuyers, 
    						TotalOrders, TotalSales, TotalCourseParts, 
    						TotalCourseQuantity, TotalCourseSales,
							TotalTranscriptParts, TotalTranscriptQuantity, 
							TotalTranscriptSales)
        as
        (
            select 
				--tt.CountryCode,
                tt.IsActive,    
                tt.Frequency,
                count(distinct tt.CustomerID) as CountOfBuyers,    
                count(tt.TotalOrders) as TotalOrders,
                sum(tt.TotalSales) as TotalSales,
                sum(tt.TotalCourseParts) as TotalCourseParts,
                sum(tt.TotalCourseQuantity) as TotalCourseQuantity,
                sum(tt.TotalCourseSales) as TotalCourseSales,
                sum(tt.TotalTranscriptParts) as TotalTranscriptParts,
                sum(tt.TotalTranscriptQuantity) as TotalTranscriptQuantity,
                sum(tt.TotalTranscriptSales) as TotalTranscriptSales
            from Staging.TempDailySpendTracker tt (nolock)
            where tt.ToDate <= @LoopDate
            group by 
				--tt.CountryCode,
                tt.Frequency,
                tt.IsActive
		)            
    	update t
		set 
        	t.CountOfBuyers = ts.CountOfBuyers,
            t.TotalOrders = ts.TotalOrders,
            t.TotalSales = ts.TotalSales,
            t.TotalCourseParts = ts.TotalCourseParts,
            t.TotalCourseQuantity = ts.TotalCourseQuantity,
            t.TotalCourseSales = ts.TotalCourseSales,
            t.TotalTranscriptParts = ts.TotalTranscriptParts,
            t.TotalTranscriptQuantity = ts.TotalTranscriptQuantity,
            t.TotalTranscriptSales = ts.TotalTranscriptSales
        from Marketing.DailySpendTracker t
        join cteDailySpendTrackerStats ts on t.IsActive = ts.IsActive and t.Frequency = ts.Frequency-- and t.CountryCode = ts.CountryCode
        where t.ToDate = @LoopDate
        
    	set @LoopDate = dateadd(d, 1, @LoopDate)
    end

  	if object_id('Staging.TempDailySpendTracker') is not null drop table Staging.TempDailySpendTracker    
end
GO
