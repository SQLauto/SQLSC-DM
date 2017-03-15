SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [Staging].[Upsell_LoadCustomerSegmentGroup_UKAU]
AS
BEGIN
	set nocount on

    truncate table Marketing.Upsell_CustomerSegmentGroup


    insert into Marketing.Upsell_CustomerSegmentGroup
    (
    	CustomerID,
        SegmentGroup,
        LastOrderDate,
     	LastUpdateDate   
    )
    select 
    	cm.CustomerID,
        cm.SubjectPreferenceID + cm.PastOrdersBin,
        v.LastOrderDate,
        getdate()
        from Staging.TempUpsell_SegmentCustomersMultis cm (nolock)
        join Staging.vwCustomerLastOrderDate v (nolock) on v.CustomerID = cm.CustomerID
    
    insert into Marketing.Upsell_CustomerSegmentGroup
    (
    	CustomerID,
        SegmentGroup,
        LastOrderDate,
     	LastUpdateDate   
    )
    select 
    	cs.CustomerID,
        cs.SegmentGroup,
        v.LastOrderDate,
        getdate()
    from Staging.TempUpsell_SegmentCustomersSingles cs (nolock)
        join Staging.vwCustomerLastOrderDate v (nolock) on v.CustomerID = cs.CustomerID
        left outer join Marketing.Upsell_CustomerSegmentGroup fnl on cs.CustomerID = fnl.CustomerID
    where fnl.CustomerID is null
        

END
GO
