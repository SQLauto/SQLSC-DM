SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Staging].[ProcessCustomers]
as
begin
/* -- PR -- 8/20/2014 -- Update demographics to be from WD table */

	set nocount on
    
    update c
    set c.CountryCode = cc.CountryCodeCorrect
    from Staging.Customers c
    join Mapping.CountryCodeCorrection cc (nolock) on cc.CountryCode = c.CountryCode
    
    update c
	set 
	    --c.Gender = isnull(cg.Gender, 'U'),  
	    c.Gender = isnull(left(cg.Gender,1), 'U'),  -- PR -- 8/20/2014 -- Update demographics to be from WD table 
        c.BuyerType = 1,
        c.MergedCustomerID = 
        case
            when isnull(c.RootCustomerID, '') = '' then c.CustomerID
            else c.RootCustomerID
        end,
		c.CustomerSince = 
        case
        	when c.CustomerSinceGMT < '1/2/2012' then c.CustomerSinceGMT
            else dbo.GMTToLocalDateTime(c.CustomerSinceGMT)
        end,
		c.LastUpdated = 
        case
        	when c.LastUpdatedGMT < '1/2/2012' then c.LastUpdatedGMT
            else dbo.GMTToLocalDateTime(c.LastUpdatedGMT)
        end,            
		c.AddressModifiedDate = 
        case
        	when c.AddressModifiedDateGMT < '1/2/2012' then c.AddressModifiedDateGMT
            else dbo.GMTToLocalDateTime(c.AddressModifiedDateGMT)
        end            
	from Staging.Customers c
	left join Mapping.CustomerOverLay cg (nolock) on cg.CustomerID = c.CustomerID -- PR -- 8/20/2014 -- Update demographics to be from WD table 
	/* changed to inner join on 20160502 */
	--join Mapping.CustomerOverlay_WD cg (nolock) on cg.CustomerID = c.CustomerID	

end

GO
