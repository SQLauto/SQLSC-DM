SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Staging].[vwValidCustomers]
AS
    SELECT 
    	RDS.CustomerID, 
        getdate() As MaxDate
    FROM Marketing.RFM_DATA_SPECIAL RDS (nolock)
    join Staging.Customers C (nolock) on RDS.CustomerID = C.CustomerID
    join Staging.AccountPreferences ap (nolock) on ap.CustomerID = c.CustomerID
    WHERE  
        C.BuyerType > 3 AND
        c.State IN (SELECT Region FROM Mapping.RFMlkValidRegion (nolock)) AND
        (c.PostalCode BETWEEN '00500' AND '99999') 
        and ap.PreferenceID = 'OfferMail'
        and c.CustGroup <> 'Library'
GO
