SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[LoadRFMHistory]
	@parmDate DATETIME
AS
    declare 
    	@effDate DATETIME,
		@beginDate 	DATETIME,
		@endDate	DATETIME,
		@startDate datetime		        
begin
	set nocount on
    
    if (datepart(weekday, @parmDate) <> 1 )
        BEGIN
            Print 'Date supplied is not a Sunday'
            RETURN 
        END
        
	--truncate table Archive.RFMHistory        

    WHILE @parmDate < GetDATE()
	BEGIN
        Print @parmDate
        SET @effDate = @parmDate - 7
        Print 'EffectiveDate - ' + CONVERT(VARCHAR(10), @effDate, 101) 
    	
        EXECUTE Staging.LoadRFMData @parmDate, 'RFMHistory'
    	
        INSERT INTO Archive.RFMHistory 
        (
        	CustomerID, 
            RFM, 
            EffectiveDate, 
            a12mf, 
            cnt_of_orderID, 
            ProcessingDate,
            FlagDRTV
        )
        SELECT 
        	rfm.CustomerID, 
            Concatenated, 
            @effDate, 
            a12mf, 
            CountOfOrderID, 
            @parmDate,
			cs.FlagDRTV            
        FROM Staging.RFMDataRH rfm (nolock)
    	join Marketing.DMCustomerStatic cs (nolock) on cs.CustomerID = rfm.CustomerID
        
         SET @parmDate = DATEADD(dd, 7, @parmDate)
     END
  
	/* Start RFM Movement process */
	     
	SET @startDate =(SELECT MIN(EffectiveDate) FROM Archive.RFMHistory) /* '2/18/2007' -- when we have to start from the middle*/

	SET @beginDate = @startDate 
	WHILE @beginDate < GETDATE()
	 BEGIN
		print @beginDate	
		print @endDate
		
		SET @endDate = @beginDate + 7
		select @begindate, @endDate
		EXECUTE Staging.spMKT_CreateRFMMovement_New @beginDate, @endDate
		SET @beginDate = @endDate
	end        
     
    /* Generate Reports*/
    truncate table Staging.RFMHistoryNewQC
	insert INTO Staging.RFMHistoryNewQC
    SELECT Count(CustomerID) CustCount, EffectiveDate
    FROM Archive.RFMHistory (nolock)
    GROUP BY EffectiveDate
    ORDER BY 1

	truncate table Staging.RFMFinalCountsBySeg
	insert INTO Staging.RFMFinalCountsBySeg
    SELECT count(rh.customerid) as customers, rh.effectivedate, rh.processingdate, 
        ri.NewSeg, rn.Name, rh.a12mf, rh.FlagDRTV
    FROM Archive.RFMHistory rh (nolock) join 
        Mapping.RFMlkValidCustomers VC (nolock) on rh.Customerid = VC.Customerid join
         Mapping.RFMInfo ri (nolock) ON rh.rfm=ri.Concatenated JOIN
         Mapping.RFMnewsegs rn (nolock) ON ri.NewSeg = rn.NewSeg
    GROUP BY  rh.effectivedate, rh.processingdate, ri.NewSeg, rn.Name, rh.a12mf, rh.FlagDRTV
    
/*
	truncate TABLE Staging.RFMCountsBySegment
	insert INTO Staging.RFMCountsBySegment
    SELECT count(rh.customerid) as CustomerCount, rh.EffectiveDate, rh.ProcessingDate, rh.rfm, rh.a12mf
    FROM Archive.RFMHistory rh (nolock) join 
        Mapping.RFMlkValidCustomers VC (nolock) on rh.Customerid = VC.Customerid
    GROUP BY rh.EffectiveDate, rh.ProcessingDate, rh.rfm, rh.a12mf

	truncate TABLE Staging.RFMFinalCountsBySeg
    SELECT Customers=Sum(CustomerCount), r.effectivedate, r.processingdate, 
        ri.NewSeg, rn.Name, r.a12mf
    INTO Staging.RFMFinalCountsBySeg
    FROM Staging.RFMCountsBySegment r (nolock) JOIN
         Mapping.RFMInfo ri (nolock) ON r.rfm=ri.Concatenated JOIN
         Mapping.RFMnewsegs rn (nolock) ON ri.NewSeg = rn.NewSeg
    GROUP BY  r.effectivedate, r.processingdate, ri.NewSeg, rn.Name, r.a12mf
*/    

end
GO
