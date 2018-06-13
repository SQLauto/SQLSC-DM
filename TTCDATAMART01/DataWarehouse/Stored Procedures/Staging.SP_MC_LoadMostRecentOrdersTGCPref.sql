SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[SP_MC_LoadMostRecentOrdersTGCPref]
	@AsOfDate datetime = null
AS
BEGIN
	set nocount on
    set @AsOfDate = isnull(@AsOfDate, getdate())    
    
    select *
    into #MROData
    from Staging.MC_MostRecent3OrdersTGCPref (nolock)
    where 1=2

    insert into #MROData
    (
        CustomerID, 
        OrderID,     
        DateOrdered, 
		Adcode,
		MD_ChannelID,
		MD_Channel,
		MD_ChannelRU,
        OrderItemID, 
        CourseID,
        Parts,
        SubjectCategory2,
        OrderSource,
        FormatMedia,
        FormatAV,
        FormatPD,
		OrderRecencyRank
    )
    select 
        ccp.CustomerID,
        ccp.OrderID,
        ccp.DateOrdered,
		ccp.Adcode,
		ccp.MD_ChannelID,
		ccp.MD_Channel,
		ccp.MD_ChannelRU,
        oi.OrderItemID,
        oi.CourseID,
        oi.TotalParts as Parts,
        oi.SubjectCategory2,
        ccp.OrderSource,
        oi.FormatMedia,
        oi.FormatAV,
        case when left(oi.StockItemID,2) in ('DA','DV') then 'Digital' else 'Physical' end as FormatPD,
		ccp.OrderRecencyRank
    from 
    (
    	select distinct  
            CustomerID, 
            OrderID, 
            DateOrdered,
            OrderSource,
			po.Adcode,
			va.ChannelID as MD_ChannelID,
			va.MD_Channel,
			va.MD_ChannelRU,
			dense_rank() over (partition by po.CustomerID order by po.DateOrdered desc, po.OrderID desc) as OrderRecencyRank         
	    from Marketing.DMPurchaseOrdersIgnoreReturns po (nolock)
		left join Mapping.vwAdcodesAll va on po.adcode = va.AdCode
    	where po.DateOrdered < @AsOfDate
    ) ccp
    join Staging.ValidPurchaseOrderItemsIgnoreReturns oi (nolock) on ccp.OrderID = oi.OrderID
    where 
    	ccp.OrderRecencyRank <= 3
        and oi.FormatMedia <> 'T'

		truncate table Staging.MC_MostRecent3OrdersTGCPref
    	insert into Staging.MC_MostRecent3OrdersTGCPref
	    select * from #MROData (nolock)
 
end

GO
