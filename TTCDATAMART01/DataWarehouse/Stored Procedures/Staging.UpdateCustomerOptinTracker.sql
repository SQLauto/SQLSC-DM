SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [Staging].[UpdateCustomerOptinTracker]
AS

BEGIN
    set nocount on

    delete ot
    from Archive.CustomerOptinTracker ot
    where ot.AsOfDate = (select top 1 cast(cs.FMPullDate as date) from Marketing.CampaignCustomerSignature cs (nolock))
	
    -- add new customers:
    insert into Archive.CustomerOptinTracker 
    (
        CustomerID,
        AsOfDate,
        FlagEmail,
        FlagValidEmail,
        FlagEmailPref,
        FlagMail,
        FlagMailPref,
        FlagNonBlankMailAddress,
        EmailAddress
    )
    select 
        cs.CustomerID,
        cs.FMPullDate,
        cs.FlagEmail,
        cs.FlagValidEmail,
        cs.FlagEmailPref,
        cs.FlagMail,
        cs.FlagMailPref,
        cs.FlagNonBlankMailAddress,
        cs.EmailAddress
	from Marketing.CampaignCustomerSignature cs (nolock)
    left join Archive.CustomerOptinTracker ot (nolock) on ot.CustomerID = cs.CustomerID
    where ot.CustomerID is null     
    
    -- add updates for existing flags as needed:
    ;with cteCustomers(AsOfDate, CustomerID) as
    (
        select max(ot.AsOfDate), ot.CustomerID
        from Archive.CustomerOptinTracker ot (nolock)
        group by ot.CustomerID
    )
    insert into Archive.CustomerOptinTracker 
    (
        CustomerID,
        AsOfDate,
        FlagEmail,
        FlagValidEmail,
        FlagEmailPref,
        FlagMail,
        FlagMailPref,
        FlagNonBlankMailAddress,
        EmailAddress
    )
    select 
        cs.CustomerID,
        cs.FMPullDate,
        cs.FlagEmail,
        cs.FlagValidEmail,
        cs.FlagEmailPref,
        cs.FlagMail,
        cs.FlagMailPref,
        cs.FlagNonBlankMailAddress,
        cs.EmailAddress
    from cteCustomers c
    join Archive.CustomerOptinTracker ot (nolock) on ot.AsOfDate = c.AsOfDate and ot.CustomerID = c.CustomerID
    join Marketing.CampaignCustomerSignature cs (nolock) on cs.CustomerID = ot.CustomerID and cast(cs.FMPullDate as date) > ot.AsOfDate 
		and 
		(	cs.FlagEmail <> ot.FlagEmail 
			or cs.FlagValidEmail <> ot.FlagValidEmail 
			or cs.FlagEmailPref <> ot.FlagEmailPref 
			or cs.FlagMail <> ot.FlagMail
			or cs.FlagMailPref <> ot.FlagMailPref
			or cs.FlagNonBlankMailAddress <> ot.FlagNonBlankMailAddress
            or cs.EmailAddress <> ot.EmailAddress
		)        
    
END
GO
