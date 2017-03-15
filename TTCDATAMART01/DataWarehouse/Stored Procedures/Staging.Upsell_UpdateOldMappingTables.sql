SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[Upsell_UpdateOldMappingTables]
AS
BEGIN
	set nocount on

    truncate table Mapping.UpsellCourseRank    
    ;with cteSegmentGroupSales(SegmentGroup, CourseID, [Rank])
    as
    (
   	    select 
      	    SegmentGroup,
			CourseID,         
	        rank() over (partition by SegmentGroup order by TotalSales desc, CourseParts, CourseID)
	    from 
        ( 
            select 
                SegmentGroup, 
                CourseID, 
                Parts as CourseParts, 
                SUM(TotalSales) TotalSales
            from Staging.TempUpsell_SegmentCustomersSingles sc (nolock)
            join Marketing.DMPurchaseOrderItems poi (nolock) on sc.CustomerID = poi.CustomerID
            where DateOrdered between DATEADD(year, -1, getdate()) and GETDATE()
            group by SegmentGroup, CourseID, Parts
        ) t
    )
    insert into Mapping.UpsellCourseRank
    (
		[Rank],
		CourseID,        
    	SegmentGroup
    )
    select 
        [Rank],
		CourseID,         
        SegmentGroup
    from cteSegmentGroupSales
    where [Rank] <= 30
    
    truncate table Mapping.CourseOfferMaster
    ;with cteSegmentGroupSales(PastOrdersBin, SubjectPreferenceID, CourseID, [Rank])
    as
    (
    	select
	        PastOrdersBin,
    	    SubjectPreferenceID,
	        CourseID, 
    	    rank() over (partition by SubjectPreferenceID, PastOrdersBin order by TotalSales desc, CourseParts, CourseID)
		from        
        (
            select 
                SubjectPreferenceID, 
                PastOrdersBin,
                CourseID, 
                Parts as CourseParts, 
                SUM(TotalSales) TotalSales
            from Staging.TempUpsell_SegmentCustomersMultis sc (nolock)
            join Marketing.DMPurchaseOrderItems poi (nolock) on sc.CustomerID = poi.CustomerID
            where DateOrdered between DATEADD(year, -1, getdate()) and GETDATE()
            group by SubjectPreferenceID, PastOrdersBin, CourseID, Parts
        ) t
    )
    insert into Mapping.CourseOfferMaster
    (
        PastOrdersBin,
        SubjectPreferenceID,
        CourseID, 
        [Rank]
    )
    select
        PastOrdersBin,
        SubjectPreferenceID,
        CourseID, 
        [Rank]
    from cteSegmentGroupSales
    where PastOrdersBin in ('00-01', '02-03', '04-07') and [Rank] <= 30
    union
    select
        PastOrdersBin,
        SubjectPreferenceID,
        CourseID, 
        [Rank]
    from cteSegmentGroupSales
    where PastOrdersBin = '08-18' and [Rank] <= 50
    union
    select
        PastOrdersBin,
        SubjectPreferenceID,
        CourseID, 
        [Rank]
    from cteSegmentGroupSales
    where PastOrdersBin = '19-1000' and [Rank] <= 70
    
END
GO
