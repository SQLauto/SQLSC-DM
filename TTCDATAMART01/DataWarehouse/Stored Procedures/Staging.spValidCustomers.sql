SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [Staging].[spValidCustomers]
AS

	TRUNCATE TABLE Mapping.RFMlkValidCustomers

	INSERT INTO Mapping.RFMlkValidCustomers
	SELECT RDS.CustomerID, getdate() As MaxDate
                /*INTO DMValidCustomers*/
                FROM Marketing.RFM_DATA_SPECIAL RDS, Staging.Customers C
/*                        SUperSTarDW.dbo.AcctAddress AA*/
              

                WHERE RDS.CustomerID = C.CustomerID AND
                        C.BuyerType > 3 AND
                        c.State IN (SELECT Region FROM Mapping.RFMlkValidRegion) AND
                        (c.PostalCode BETWEEN '00500' AND '99999')

	
		delete vc 
        from Mapping.RFMlkValidCustomers vc
		left join
        ( 
        	select ap.CustomerID
        	from Staging.AccountPreferences ap (nolock) 
    		where ap.PreferenceID = 'OfferMail'
		) ap on vc.CustomerID = ap.CustomerID
        where ap.CustomerID is null          	         

		delete vc
        from Mapping.RFMlkValidCustomers vc 
        join Staging.Customers c (nolock) on vc.CustomerID = c.CustomerID
        where c.CustGroup = 'Library'
GO
