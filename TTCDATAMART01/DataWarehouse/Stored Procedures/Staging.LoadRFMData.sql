SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [Staging].[LoadRFMData]
	@AsOfDate datetime = null,
    @Process varchar(50) = 'Generic'
as
	declare 
    	@a12mF_EndDate datetime,
    	@a12mF_StartDate datetime, 
    	@DSStartDate datetime, 
    	@DSEndDate datetime, 
		@DSDays int, 
	    @MaxDays int
begin
	set nocount on
    
    set @AsOfDate = coalesce(@AsOfDate, getdate())    

    SET @a12mF_EndDate = @AsOfDate
    SET @a12mF_StartDate = DateAdd(year,-1,@AsOfDate)
    SET @DSStartDate = @AsOfDate
    SET @DSEndDate = DateAdd(day, -1, DateAdd(month,1,@AsOfDate))
    SET @DSDays = DateDiff(Day, @DSStartDate, @DSEndDate)

	select *
    into #RFMData
    from Marketing.RFM_DATA_SPECIAL (nolock)
    where 1=2
        
    ;with Orders(CustomerID, OrderID, OrderDate, NetOrderAmount) as
    (
        SELECT
            CustomerID,
            OrderID,
            DateOrdered,
            NetOrderAmount
        FROM Staging.vwOrders o (nolock) 
        WHERE 
            CatalogOrder = 'F' 
            AND StatusCode IN (0, 1, 2, 3, 12, 13)
            and NetOrderAmount > 0 
            and o.DateOrdered < @AsOfDate
            and o.orderid not like 'RET%'  -- PR 5/7/2014 -- To avoid counting returns for frequency if there are any positve returns
    )
    INSERT INTO #RFMData
    (
        CustomerID,
        CountOfOrderID,
        MaxOfDate,
        SumOfPaymentsToDate,
        DropDate,
        a12mF_EndDate,
        a12mF_StartDate,
        DSStartDate,
        DSEndDate,
        DSDays
    )
    select
        o.CustomerID, 
        count(o.OrderID), 
        max(o.OrderDate), 
        sum(o.NetOrderAmount),
        @AsOfDate,
        @a12mF_EndDate,
        @a12mF_StartDate, 
        @DSStartDate,
        @DSEndDate,
        @DSDays
    from Orders o (nolock) 
    group by o.CustomerID
        
    select @MaxDays = max(DaysOld) 
    from Mapping.RecencyDays (nolock) 
        
    UPDATE #RFMData
    Set
        DaysOld = case when DateDiff(day, MaxOfDate, DropDate) > @MaxDays then @MaxDays
        else DateDiff(day, MaxOfDate, DropDate)  end,
        AvgOrder = ROUND(CAST (SumOfPaymentsToDate AS float)/CountOfOrderID, 4)
        
    UPDATE rfm
    SET rfm.Recency = rd.Recency
    from #RFMData rfm
    join Mapping.RecencyDays rd (nolock) on rd.DaysOld = rfm.DaysOld
        
    UPDATE #RFMData
    SET 
        MonetaryValue =
        CASE
            WHEN AvgOrder > 220 THEN 'M3'
            WHEN AvgOrder > 100 THEN 'M2'
            ELSE 'M1'
        END,
        Frequency =
        CASE
            WHEN CountOfOrderID = 1 THEN 'F1'
            ELSE 'F2'
        END,
        Concatenated = 
        RTRIM(Recency) + 
        CASE
            WHEN CountOfOrderID = 1 THEN 'F1'
            ELSE 'F2'
        END +
        CASE
            WHEN AvgOrder > 220 THEN 'M3'
            WHEN AvgOrder > 100 THEN 'M2'
            ELSE 'M1'
        END,

        /* 05/15/2003 added start date for sales for 6-month */
        a12mF_StartDate = 
        case 
            when Recency = 'R01' then DateAdd(day,-183,@AsOfDate)
            else a12mF_StartDate 
        end
        
    ;with Orders(CustomerID, OrdersCount) as
    (
        SELECT
            o.CustomerID,
            count(OrderID)
        FROM Staging.vwOrders o (nolock) 
        join #RFMData rfm on rfm.CustomerID = o.CustomerID
        WHERE
            o.StatusCode IN (0, 1, 2, 3, 12, 13)
            and o.NetOrderAmount > 0 
            and o.DateOrdered >= rfm.a12mF_StartDate 
            and o.DateOrdered < @a12mF_EndDate
            and o.orderid not like 'RET%'    -- PR 5/7/2014 -- To avoid counting returns for frequency if there are any positve returns
        group by o.CustomerID            
        
    )
    update rfm
    set rfm.CountOfOrderID1 = o.OrdersCount
    from #RFMData rfm
    join Orders o (nolock) on o.CustomerID = rfm.CustomerID
        
        UPDATE #RFMData
        SET a12mF =
            CASE
                WHEN CountOfOrderID1 > 2 THEN 3
                WHEN CountOfOrderID1 > 1 THEN 2
            ELSE 1
            END
        where Concatenated LIKE 'R01F2%'
            
        UPDATE #RFMData
        SET a12mF =
           CASE
               WHEN CountOfOrderID1 > 1 THEN 2
               ELSE 1
           END
        where Concatenated LIKE 'R02F2%'

        UPDATE #RFMData
        SET a12mF = 
        case
            when (Concatenated Like 'R01F2%' Or Concatenated Like 'R02F2%') then 1
            else 0
        end
        WHERE a12mF IS Null 

	if @Process = 'Generic'
    begin
		truncate table Marketing.RFM_DATA_SPECIAL
    	insert into Marketing.RFM_DATA_SPECIAL
	    select * from #RFMData (nolock)
    end
    else if @Process in ('WelcomePackage', 'WP')
    begin
		truncate table Staging.RFMDataWP
    	insert into Staging.RFMDataWP
	    select * from #RFMData (nolock)
    end
    else if @Process in ('WeeklyRFMReport', 'WRFM')
    begin
		truncate table Staging.RFM_DATA_SPECIAL_FC
    	insert into Staging.RFM_DATA_SPECIAL_FC
	    select * from #RFMData (nolock)
    end
    else if @Process in ('MidwaySpendTrack', 'MST')
    begin
		truncate table Staging.RFMDataMST
    	insert into Staging.RFMDataMST
	    select * from #RFMData (nolock)
    end
    else if @Process in ('RFMHistory', 'RH')
    begin
		truncate table Staging.RFMDataRH
    	insert into Staging.RFMDataRH
	    select * from #RFMData (nolock)
    end
    
end
GO
