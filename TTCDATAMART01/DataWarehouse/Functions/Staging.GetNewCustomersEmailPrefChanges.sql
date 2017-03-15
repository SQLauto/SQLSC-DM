SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [Staging].[GetNewCustomersEmailPrefChanges]
(
	@Days int
)
returns table
as
	return
    
    select 
        o.CustomerID,
        cast(o.DateOrdered as date) as FirstOrderDate,
        cast(ti.FlagEmailPref as tinyint) as InitialEmailPref,
        cast(te.FlagEmailPref as tinyint) as EndingEmailPref
    from Marketing.DMPurchaseOrders o (nolock)
    join Archive.CustomerOptinTracker ti (nolock) on ti.CustomerID = o.CustomerID
    join Archive.CustomerOptinTracker te (nolock) on te.CustomerID = o.CustomerID
    where 
        SequenceNum = 1
        and ti.AsOfDate = (select max(t.AsOfDate) from Archive.CustomerOptinTracker t (nolock) where t.AsOfDate <= cast(o.DateOrdered as date) and t.CustomerID = o.CustomerID)
        and te.AsOfDate = (select max(t.AsOfDate) from Archive.CustomerOptinTracker t (nolock) where t.AsOfDate <= cast(dateadd(day, @Days, o.DateOrdered) as date) and t.CustomerID = o.CustomerID)
GO
