SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [Staging].[LoadNewCustomersEmailPrefChanges]
(
	@Days int = 30
)
AS
BEGIN
	set nocount on
    
    if object_id('Staging.NewCustomersEmailPrefChanges') is not null drop table Staging.NewCustomersEmailPrefChanges

    select 
        o.CustomerID,
        cast(o.DateOrdered as date) as FirstOrderDate,
        cast(ti.FlagEmailPref as tinyint) as InitialEmailPref,
        cast(te.FlagEmailPref as tinyint) as EndingEmailPref
	into Staging.NewCustomersEmailPrefChanges        
    from Marketing.DMPurchaseOrders o (nolock)
    join Archive.CustomerOptinTracker ti (nolock) on ti.CustomerID = o.CustomerID
    join Archive.CustomerOptinTracker te (nolock) on te.CustomerID = o.CustomerID
    cross apply (select max(t.AsOfDate) LastChangedDate from Archive.CustomerOptinTracker t (nolock) where t.AsOfDate <= cast(o.DateOrdered as date) and t.CustomerID = o.CustomerID) cai
    cross apply (select max(t.AsOfDate) LastChangedDate from Archive.CustomerOptinTracker t (nolock) where t.AsOfDate <= cast(dateadd(day, @Days, o.DateOrdered) as date) and t.CustomerID = o.CustomerID) cae
    where 
        SequenceNum = 1
        and ti.AsOfDate = cai.LastChangedDate
        and te.AsOfDate = cae.LastChangedDate
    
END
GO
