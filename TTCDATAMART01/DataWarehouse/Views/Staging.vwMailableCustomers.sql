SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Staging].[vwMailableCustomers]
AS
    SELECT 	
	    C.CustomerID 
    FROM Staging.Customers C (nolock)
    INNER JOIN Staging.AccountPreferences ap (nolock) ON C.CustomerID = Ap.CustomerID 
    where
        c.State IN (SELECT Region FROM Mapping.RFMlkValidRegion (nolock)) 
        AND c.PostalCode BETWEEN '00500' AND '99999'	
        and ap.PreferenceID = 'OfferMail'
GO
