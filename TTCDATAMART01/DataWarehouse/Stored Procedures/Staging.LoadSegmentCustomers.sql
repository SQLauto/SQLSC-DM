SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[LoadSegmentCustomers]
AS
BEGIN
	set nocount on
	
    truncate table Staging.SegmentCustomers    
    
    INSERT INTO Staging.SegmentCustomers
    (
    	CustomerID, 
        IntlSubjectPref, 
        IntlFormatAVPref,
        Gender, 
        SegmentGroup
    )
    SELECT DISTINCT 
    	DPO.CustomerID, 
        'AR', 
        isnull(DMC.IntlFormatAVPref, 'XX'),
        ISNULL(DMC.Gender, 'U') As Gender, 
        CASE 
        	WHEN DMC.Gender IS NULL THEN  'AR' + DMC.IntlFormatAVPref + 'F'
            WHEN DMC.Gender = '' THEN  'AR' + DMC.IntlFormatAVPref + 'F'
            WHEN DMC.Gender = 'M' THEN 'AR' + DMC.IntlFormatAVPref + 'M'
            WHEN DMC.Gender = 'F' THEN 'AR' + DMC.IntlFormatAVPref + 'F'
            WHEN DMC.Gender = 'N' THEN 'AR' + DMC.IntlFormatAVPref + 'M'
            WHEN DMC.Gender = 'U' THEN 'AR' + DMC.IntlFormatAVPref + 'F'
            ELSE 'AR' + DMC.IntlFormatAVPref + 'F'
        END As SegmentGroup
    FROM Marketing.DMPurchaseOrderItems DPOI (nolock)
    INNER JOIN Marketing.DMPurchaseOrders DPO (nolock) ON DPOI.OrderID = DPO.OrderID 
    INNER JOIN Marketing.DMCustomerStatic DMC (nolock) ON DPO.CustomerID = DMC.CustomerID
    WHERE DPO.SequenceNum = 1 AND
        DPOI.CourseID = 499 AND
        DPOI.FormatMedia <> 'T' AND
        DPOI.FlagReturn = 0 AND
        DMC.IntlFormatAVPref <> 'HS' 
        
    INSERT INTO Staging.SegmentCustomers 
    (
    	CustomerID, 
        IntlSubjectPref, 
        IntlFormatAVPref,
        Gender, 
        SegmentGroup
    )
    SELECT DISTINCT
    	DPO.CustomerID, 
        'CA', 
        'XX', 
        ISNULL(DMC.Gender, 'U') As Gender, 
        CASE 
        	WHEN DMC.Gender IS NULL THEN 'CAXXF'
            WHEN DMC.Gender = '' THEN 'CAXXF'
            WHEN DMC.Gender = 'M' THEN 'CAXXM'
            WHEN DMC.Gender = 'F' THEN 'CAXXF'
            WHEN DMC.Gender = 'N' THEN 'CAXXM'
            WHEN DMC.Gender = 'U' THEN 'CAXXF'
            ELSE 'CAXXF'
        END As SegmentGroup
    FROM Marketing.DMPurchaseOrderItems DPOI (nolock)
    INNER JOIN Marketing.DMPurchaseOrders DPO (nolock) ON DPOI.OrderID = DPO.OrderID 
    INNER JOIN Marketing.DMCustomerStatic DMC (nolock) ON DPO.CustomerID = DMC.CustomerID
    left join Staging.SegmentCustomers sc (nolock) on sc.CustomerID = dmc.CustomerID
    WHERE 	
    	DPO.SequenceNum = 1 AND
        DPOI.CourseID = 177 AND
        DPOI.FormatMedia <> 'T' AND
        DPOI.FlagReturn = 0 AND 
        DMC.IntlFormatAVPref <> 'HS' AND
        sc.CustomerID is null
        
    InsERT INTO Staging.SegmentCustomers 
    (
    	CustomerID, 
        IntlSubjectPref, 
        IntlFormatAVPref,
        Gender, 
        SegmentGroup
    )
    SELECT DISTINCT 
    	DPO.CustomerID, 
        'AR', 
        DMC.IntlFormatAVPref, 
        ISNULL(DMC.Gender, 'U') As Gender, 
        CASE 
        	WHEN DMC.Gender IS NULL THEN  'AN' + 'XX' + 'F'
            WHEN DMC.Gender = '' THEN  'AN' + 'XX' + 'F'
            WHEN DMC.Gender = 'M' THEN 'AN' + 'XX' + 'M'
            WHEN DMC.Gender = 'F' THEN 'AN' + 'XX' + 'F'
            WHEN DMC.Gender = 'N' THEN 'AN' + 'XX' + 'M'
            WHEN DMC.Gender = 'U' THEN 'AN' + 'XX' + 'F'
            ELSE 'AN' + 'XX' + 'F'
        END As SegmentGroup
    FROM Marketing.DMPurchaseOrderItems DPOI (nolock)
    INNER JOIN Marketing.DMPurchaseOrders DPO (nolock) ON DPOI.OrderID = DPO.OrderID 
    INNER JOIN Marketing.DMCustomerStatic DMC (nolock) ON DPO.CustomerID = DMC.CustomerID
	left join Staging.SegmentCustomers sc (nolock) on sc.CustomerID = dmc.CustomerID    
    WHERE 	
    	DPO.SequenceNum = 1 AND
        DPOI.CourseID = 160 AND
        DPOI.FormatMedia <> 'T' AND
        DPOI.FlagReturn = 0 AND
        DMC.IntlFormatAVPref <> 'HS' AND
        sc.CustomerID is null

    INSERT INTO Staging.SegmentCustomers 
    (
    	CustomerID, 
        IntlSubjectPref, 
        IntlFormatAVPref,
        Gender, 
        SegmentGroup
    )
    SELECT DISTINCT 
    	DPO.CustomerID, 
        REPLACE(DMC.IntlSubjectPref, 'LIT', 'LT') As IntlSubjectPref, 
        DMC.IntlFormatAVPref, 
        ISNULL(DMC.Gender, 'U') As Gender, 
        CASE 	
        	WHEN DMC.Gender IS NULL THEN  REPLACE(DMC.IntlSubjectPref, 'LIT', 'LT') + DMC.IntlFormatAVPref + 'F'
            WHEN DMC.Gender = '' THEN  REPLACE(DMC.IntlSubjectPref, 'LIT', 'LT') + DMC.IntlFormatAVPref + 'F'
            WHEN DMC.Gender = 'M' THEN REPLACE(DMC.IntlSubjectPref, 'LIT', 'LT') + DMC.IntlFormatAVPref + 'M'
            WHEN DMC.Gender = 'F' THEN REPLACE(DMC.IntlSubjectPref, 'LIT', 'LT') + DMC.IntlFormatAVPref + 'F'
            WHEN DMC.Gender = 'N' THEN REPLACE(DMC.IntlSubjectPref, 'LIT', 'LT') + DMC.IntlFormatAVPref + 'M'
            WHEN DMC.Gender = 'U' THEN REPLACE(DMC.IntlSubjectPref, 'LIT', 'LT') + DMC.IntlFormatAVPref + 'F'
            ELSE REPLACE(DMC.IntlSubjectPref, 'LIT', 'LT') + DMC.IntlFormatAVPref + 'F'
        END As SegmentGroup
    FROM Marketing.DMPurchaseOrderItems DPOI (nolock)
    INNER JOIN Marketing.DMPurchaseOrders DPO (nolock) ON DPOI.OrderID = DPO.OrderID 
    INNER JOIN Marketing.DMCustomerStatic DMC (nolock) ON DPO.CustomerID = DMC.CustomerID
    left join Staging.SegmentCustomers sc (nolock) on sc.CustomerID = dmc.CustomerID
    WHERE 	
    	DPO.SequenceNum = 1 AND
        DPOI.FormatMedia <> 'T' AND
        DPOI.FlagReturn = 0 AND
        DMC.IntlFormatAVPref <> 'HS' AND
        sc.CustomerID is null
        
    UPDATE Staging.SegmentCustomers 
    SET SegmentGroup = REPLACE(SegmentGroup, 'M ', 'VI')
    WHERE SUBSTRING(SegmentGroup, 3, 2) = 'M ' 
    
    INSERT INTO Staging.SegmentCustomers 
    (
    	CustomerID, 
        IntlSubjectPref, 
        IntlFormatAVPref,
        Gender, 
        SegmentGroup
    )
    SELECT DISTINCT 
	    DPO.CustomerID, 
        'XX' As IntlSubjectPref, 
        'HS', 
        ISNULL(DMC.Gender, 'U') As Gender, 
        CASE 	
        	WHEN DMC.Gender IS NULL THEN  'XXHSF'
            WHEN DMC.Gender = '' THEN  'XXHSF'
            WHEN DMC.Gender = 'M' THEN 'XXHSM'
            WHEN DMC.Gender = 'F' THEN 'XXHSF'
            WHEN DMC.Gender = 'N' THEN 'XXHSM'
            WHEN DMC.Gender = 'U' THEN 'XXHSF'
            ELSE 'XXHSF'
        END As SegmentGroup
    FROM Marketing.DMPurchaseOrderItems DPOI (nolock)
    INNER JOIN Marketing.DMPurchaseOrders DPO (nolock) ON DPOI.OrderID = DPO.OrderID 
    INNER JOIN Marketing.DMCustomerStatic DMC (nolock) ON DPO.CustomerID = DMC.CustomerID
    left join Staging.SegmentCustomers sc (nolock) on sc.CustomerID = dmc.CustomerID
    WHERE 	
    	DPO.SequenceNum = 1 AND
        DPOI.FormatMedia <> 'T' AND
        DPOI.FlagReturn = 0 AND
        DMC.IntlFormatAVPref = 'HS' AND
        sc.CustomerID is null
        
    UPDATE Staging.SegmentCustomers
    SET SegmentGroup =  
        CASE 	
        	WHEN Gender IS NULL THEN  'XXHSF'
            WHEN Gender = '' THEN  'XXHSF'
            WHEN Gender = 'M' THEN 'XXHSM'
            WHEN Gender = 'F' THEN 'XXHSF'
            WHEN Gender = 'N' THEN 'XXHSM'
            WHEN Gender = 'U' THEN 'XXHSF'
            ELSE 'XXHSF'
        END 
    WHERE LEFT(SegmentGroup, 2) = 'HS' 
    
	DELETE FROM Staging.SegmentCustomers 
    where SegmentGroup in (' AUM', 'XAUM', ' AUF')
END
GO
