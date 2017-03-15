SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[Upsell_LoadSegmentCustomersSingles]
AS
BEGIN
	set nocount on
    
    if object_id('Staging.TempUpsell_SegmentCustomersSingles') is not null drop table Staging.TempUpsell_SegmentCustomersSingles
	
    SELECT DISTINCT 
    	DPOI.CustomerID, 
        cast('AR' as varchar(5)) as IntlSubjectPref, 
        isnull(DMC.IntlFormatAVPref, 'XX') as IntlFormatAVPref,
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
	INTO Staging.TempUpsell_SegmentCustomersSingles        
    FROM Marketing.DMPurchaseOrderItems DPOI (nolock)
    INNER JOIN Marketing.DMPurchaseOrders DPO (nolock) ON DPOI.OrderID = DPO.OrderID 
    INNER JOIN Marketing.DMCustomerStatic DMC (nolock) ON DPO.CustomerID = DMC.CustomerID
    WHERE 	DPO.SequenceNum = 1 AND
        DPOI.CourseID = 499 AND
        DPOI.FormatMedia <> 'T' AND
        DPOI.FlagReturn = 0 AND
        DMC.IntlFormatAVPref <> 'HS' 
        
    INSERT INTO Staging.TempUpsell_SegmentCustomersSingles
    (
    	CustomerID, 
        IntlSubjectPref, 
        IntlFormatAVPref,
        Gender, 
        SegmentGroup
    )
    SELECT DISTINCT
    	DPOI.CustomerID, 
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
    left join Staging.TempUpsell_SegmentCustomersSingles t (nolock) on t.CustomerID = dmc.CustomerID
    WHERE 	
    	DPO.SequenceNum = 1 AND
        DPOI.CourseID = 177 AND
        DPOI.FormatMedia <> 'T' AND
        DPOI.FlagReturn = 0 AND 
        DMC.IntlFormatAVPref <> 'HS' AND
        t.CustomerID is null
        
    InsERT INTO Staging.TempUpsell_SegmentCustomersSingles
    (
    	CustomerID, 
        IntlSubjectPref, 
        IntlFormatAVPref,
        Gender, 
        SegmentGroup
    )
    SELECT DISTINCT 
    	DPOI.CustomerID, 
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
    left join Staging.TempUpsell_SegmentCustomersSingles t (nolock) on t.CustomerID = dmc.CustomerID    
    WHERE 	
    	DPO.SequenceNum = 1 AND
        DPOI.CourseID = 160 AND
        DPOI.FormatMedia <> 'T' AND
        DPOI.FlagReturn = 0 AND
        DMC.IntlFormatAVPref <> 'HS' AND
        t.CustomerID is null

    INSERT INTO Staging.TempUpsell_SegmentCustomersSingles
    (
    	CustomerID, 
        IntlSubjectPref, 
        IntlFormatAVPref,
        Gender, 
        SegmentGroup
    )
    SELECT DISTINCT 
    	DPOI.CustomerID, 
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
    left join Staging.TempUpsell_SegmentCustomersSingles t (nolock) on t.CustomerID = dmc.CustomerID    
    WHERE 	
    	DPO.SequenceNum = 1 AND
        DPOI.FormatMedia <> 'T' AND
        DPOI.FlagReturn = 0 AND
        DMC.IntlFormatAVPref <> 'HS' AND
        t.CustomerID is null
        
    UPDATE Staging.TempUpsell_SegmentCustomersSingles
    SET SegmentGroup = REPLACE(SegmentGroup, 'M ', 'VI')
    WHERE SUBSTRING(SegmentGroup, 3, 2) = 'M ' 
    
    INSERT INTO Staging.TempUpsell_SegmentCustomersSingles
    (
    	CustomerID, 
        IntlSubjectPref, 
        IntlFormatAVPref,
        Gender, 
        SegmentGroup
    )
    SELECT DISTINCT 
	    DPOI.CustomerID, 
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
    left join Staging.TempUpsell_SegmentCustomersSingles t (nolock) on t.CustomerID = dmc.CustomerID    
    WHERE 	
    	DPO.SequenceNum = 1 AND
        DPOI.FormatMedia <> 'T' AND
        DPOI.FlagReturn = 0 AND
        DMC.IntlFormatAVPref = 'HS' AND
        t.CustomerID is null
        
    UPDATE Staging.TempUpsell_SegmentCustomersSingles
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
    
	DELETE FROM Staging.TempUpsell_SegmentCustomersSingles
    where SegmentGroup in (' AUM', 'XAUM', ' AUF')

END
GO
