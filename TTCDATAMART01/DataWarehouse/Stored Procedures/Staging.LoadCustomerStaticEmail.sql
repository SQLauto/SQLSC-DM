SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[LoadCustomerStaticEmail] 
	@AsOfDate date = null
AS
BEGIN
	set nocount on
    set @AsOfDate = isnull(@AsOfDate, getdate())    
    
    insert into Marketing.DMCustomerStaticEmail
    (
	    CustomerID,
        CustomerSInce,
        EmailAddress,
        FirstName, 
        LastName, 
        FirstUsedAdcode, 
        BuyerType,
        CustGroup,
        FlagEmailable,
        EmailPreferenceValue,
		EmailPreferenceID,        
        MailPreferenceValue,
		MailPreferenceID,        
        DatePulled,
        CountryCode
	)        
    select 
    	c.CustomerID,
        C.CustomerSince,
        C.Email,
        C.FirstName, 
        C.LastName, 
        C.FirstUsedAdcode, 
        C.BuyerType,
        c.CustGroup,
        case 
	        WHEN C.Email LIKE '%@%' and isnull(email.CustomerID, 0) <> 0 then 1
            else 0
        end as FlagEmailable,
        case 
	        WHEN isnull(email.CustomerID, 0) <> 0 then 1
            else 0
        end as EmailPreferenceValue,
        case 
	        WHEN isnull(email.CustomerID, 0) <> 0 then 'OfferEmail'
        end as EmailPreferenceID,
        case 
	        WHEN isnull(mail.CustomerID, 0) <> 0 then 1
            else 0
        end as MailPreferenceValue,
        case 
	        WHEN isnull(mail.CustomerID, 0) <> 0 then 'OfferMail'
        end as MailPreferenceID,
        getdate(),
        c.CountryCode
    from Staging.Customers c (nolock)
    left join (
    	select ap.CustomerID 
        from Staging.AccountPreferences ap (nolock) 
        where ap.PreferenceID = 'OfferEmail' ) as email on email.CustomerID = c.CustomerID
    left join (
    	select ap.CustomerID 
        from Staging.AccountPreferences ap (nolock) 
        where ap.PreferenceID = 'OfferMail' ) as mail on mail.CustomerID = c.CustomerID
	left join Marketing.DMCustomerStaticEmail cse (nolock) on cse.CustomerID = c.CustomerID
    where 
    	cse.CustomerID is null        
        and cast(c.CustomerSince as date) = dateadd(day, -1, @AsOfDate)
END
GO
