SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Staging].[vwEmailableCustomers]
AS
	with cteEmailableCustomers(CustomerID, Email) as
	(
   		select 
   			c.CustomerID,
   			c.Email
		from Staging.Customers c (nolock)
		join Staging.AccountPreferences ap (nolock) on ap.CustomerID = c.CustomerID
		where 
    		ap.PreferenceID = 'OfferEMail'
			and c.Email like '%@%'
            and c.Email not like '%@home.com'
            and c.Email not like '%@attbi.com'
	)
    select 
    	c.CustomerID
    from cteEmailableCustomers c (nolock)
	except
    (
    	select ie.CustomerID
		from Legacy.InvalidEmails ie (nolock)
        where isnull(ie.CustomerID, '0') <> '0'
        union
        select c.CustomerID
	    from cteEmailableCustomers c (nolock)
	    join Legacy.InvalidEmails ie (nolock) on c.Email = ie.EmailAddress        
	)
GO
