SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Staging].[LoadWPCustomers]
/*	
	Last Updated:  2007-04-03 tlj Corrected pmtstatus of 4 from Orders table (should have been orderitems)
			from undocumented  update done in the last week be EL.

			8/30/2007 PR Changed procedure to use rfm_buildSpecial_ED instead of rfm_buildSpecial 
			which is used by many other processes.
			8/30/2007 PR Modified the where clause to look at the correct history table.
			Was WPHistory instead of WPArchiveNew.
			8/30/2007 PR Added 'New' to avoid deleting Returning Customers.

*/
	@pullDate	DATETIME,
	@startDate 	DATETIME,  /* Has to be a SUNDAY*/
	@endDate	DATETIME,  /* Has to be @startDate + 7 Days (Next Sunday)	*/
    @Process varchar(10)
as
	declare
    	@Preference varchar(10)
begin
	set nocount on

	select *
    into #WPCustomers
    from Staging.WPMailCustomers (nolock)
    where 0=1
    
    set @Preference = 
    case
    	when @Process = 'MailPull' then 'OfferMail'
       	when @Process = 'EmailPull' then 'OfferEMail'
    end

	insert into #WPCustomers
		(CustomerID, FirstName, LastName, EMailAddress, Address1, Address2,
		City, 
		Region, 
		PostalCode, 
		CustomerSinceDate, 
		MinOrderIDinPeriod, 
        MinPurchDateInPeriod,
		MatchCode,
        PackageType,
        ReviewedFlag,
        BuyerType,
        PrintPendingFlag,
        PrintFlag,
		PullDate,
		StartDate,
		EndDate
        )
	SELECT 	C.CustomerID, C.FirstName, C.LastName, C.Email, c.Address1, c.Address2 + ' ' + c.Address3, 
		c.City, 
		c.State, 
		c.PostalCode, 
		C.CustomerSince, 
		MIN(O.OrderID) As MinOrderIDinPeriod, 
		MIN(O.DateOrdered) As MinPurchDateinPeriod, 
		(LEFT(C.LastName, 5) + LEFT(c.PostalCode, 5) + LEFT(c.Address1, 5) + LEFT(C.FirstName, 5)) MatchCode,
        'Existing',
        1,
        0,
        0,
        0,
        @pullDate,
        @startDate,
        @endDate        
	FROM Staging.Customers C
    join Staging.vwOrders O on C.CustomerID = O.CustomerID
    join Staging.AccountPreferences ap on ap.CustomerID = c.CustomerID
    join Staging.vwOrderItems OI on o.OrderID = OI.OrderID
	WHERE 	
		ap.PreferenceID = @Preference
        and c.CustGroup <> 'Library' and
		O.StatusCode <> 4 AND
		(convert(datetime, convert(varchar(10), o.DateOrdered, 101)) BETWEEN @startDate AND @endDate - 1) AND
		OI.StockItemID LIKE '[PSD][AVCD]%'
        and not (c.FirstName LIKE 'Account%' or c.FirstName LIKE 'Acquisition%')
	GROUP BY C.CustomerID, C.FirstName, C.LastName, c.EMail, c.Address1, c.Address2 + ' ' + c.Address3,
		c.City, 
		c.State, 
		c.PostalCode, 
		C.CustomerSince

	/* Flag Buyers 'New' or 'Returning' Or 'Existing'            */

	exec Staging.LoadRFMData @AsOfDate = @endDate, @Process = 'WelcomePackage'     
	UPDATE wpc
	SET 
    	wpc.PackageType = 'New',
		Wpc.Newseg = RI.NewSeg, 
		Wpc.NewSegName = RN.Name,
		Wpc.A12MF = RDS.a12mF		        
    from #WPCustomers wpc
    join Staging.RFMDataWP RDS on rds.CustomerID = wpc.CustomerID
    join Mapping.RFMInfo RI on RDS.Concatenated = RI.Concatenated
    left join Mapping.RFMNewSegs RN on RI.NewSeg = RN.NewSeg
	where RI.NewSeg IN (1, 2) 

	exec Staging.LoadRFMData @AsOfDate = @startDate, @Process = 'WelcomePackage'
	UPDATE wpc
	SET 
    	wpc.PackageType = 'Returning',
		Wpc.Newseg = RI.NewSeg, 
		Wpc.NewSegName = RN.Name,
		Wpc.A12MF = RDS.a12mF		        
    from #WPCustomers wpc
    join Staging.RFMDataWP RDS on rds.CustomerID = wpc.CustomerID
    join Mapping.RFMInfo RI on RDS.Concatenated = RI.Concatenated
    left join Mapping.RFMNewSegs RN on RI.NewSeg = RN.NewSeg
	where RI.NewSeg >= 16

	if @Process = 'MailPull'
    begin
    	delete from #WPCustomers
        where PostalCode <= '00500' or PostalCode >= '99999'	
        
        /* delete New Customers who exist in the WPHistory Table*/
        DELETE FROM #WPCustomers
            WHERE PackageType = 'New' AND
            CustomerID IN (SELECT DISTINCT(CustomerID) FROM
                        Staging.WPHistory)

        /* delete Returning Customers who exist in the WPHistory Table*/
        /* but have purchased within the last 2 years*/

        DELETE FROM #WPCustomers WHERE 
            PackageType = 'Returning' AND
            CustomerID IN (SELECT DISTINCT(CustomerID) FROM
                    Archive.WPArchiveNew WHERE StartDate BETWEEN @startDate AND DATEADD(YY, -2, @startDate)) /* PR - 8/30/2007 - Changed to point to new History table.*/

        DELETE FROM #WPCustomers WHERE 
            CustomerID IN (SELECT DISTINCT(CustomerID) FROM
                    Staging.WPLetterSend_Archive)

        DELETE FROM #WPCustomers WHERE 
            PackageType = 'New' AND /* PR - 8/30/2007 - added this to where clause to avoid removing 'Returning' Customers*/
            CustomerID IN (SELECT DISTINCT(CustomerID) FROM
                    Archive.WPArchiveNew)
    
		truncate table Staging.WPMailCustomers	
    	insert into Staging.WPMailCustomers
	    select * from #WPCustomers (nolock)
    end
	else if @Process = 'EmailPull'
    begin
		truncate table Staging.WPEmailCustomers	
    	insert into Staging.WPEmailCustomers
	    select * from #WPCustomers (nolock)
    end
    
end
GO
