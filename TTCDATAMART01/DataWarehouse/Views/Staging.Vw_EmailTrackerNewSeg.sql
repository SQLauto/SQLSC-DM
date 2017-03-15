SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Staging].[Vw_EmailTrackerNewSeg]
AS
    
    select a.*,
		Year(a.EhistStartDate) EmailYear,
		month(a.EHistStartDate) EmailMonth,
		isnull(b.CustomerSegment2, a.CustomerSegment) as CustomerSegment2, 
		isnull(b.CustomerSegmentFnl, a.CustomerSegment) as CustomerSegmentFnl 
    from Marketing.Email_SalesAndOrders_Summary a 
		 left join (select distinct NewSeg, Name, A12mf, CustomerSegment2, CustomerSegmentFnl 
					from Mapping.RFMComboLookup
					where name is not null) b on a.NewSeg = b.NewSeg
										and a.Name = b.Name
										and a.a12mf = b.A12mf
	where CCTblStartYear >= 2013
	

GO
