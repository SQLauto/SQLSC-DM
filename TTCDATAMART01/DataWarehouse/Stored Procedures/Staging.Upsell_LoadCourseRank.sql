SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[Upsell_LoadCourseRank]
AS
BEGIN
    set nocount on
    
    truncate table Marketing.Upsell_CourseRank
    
    PRINT 'Start staging.LoadMostRecentOrders'
	exec Staging.LoadMostRecentOrders null, 'UR'        
	PRINT 'END staging.LoadMostRecentOrders'

    PRINT 'Start staging.Upsell_LoadSegmentCustomersSingles'
    exec Staging.Upsell_LoadSegmentCustomersSingles
    ;with cteSegmentGroupSales(SegmentGroup, CourseID, CourseParts, TotalSales)
    as
    (
        select 
            SegmentGroup, 
            poi.CourseID, 
            Parts as CourseParts, 
            SUM(TotalSales) TotalSales
        from Staging.TempUpsell_SegmentCustomersSingles sc (nolock)
        join Marketing.DMPurchaseOrderItems poi (nolock) on sc.CustomerID = poi.CustomerID 
        join (SELECT DISTINCT CourseID  -- To exclude discountinued courses
				FROM Staging.Invitem 
				WHERE forsaleonweb=1 
				AND forsaletoconsumer=1 
				AND InvStatusID in ('Active','Disc')
				AND itemcategoryid in ('course','bundle'))Crs ON poi.CourseID = Crs.CourseID
        where DateOrdered between DATEADD(year, -1, getdate()) and GETDATE()
        group by SegmentGroup, poi.CourseID, Parts
    )
    insert into Marketing.Upsell_CourseRank
    (
    	SegmentGroup,
        CourseID,
        [Rank],
        LastUpdateDate
    )
    select 
        SegmentGroup, 
        CourseID, 
        rank() over (partition by SegmentGroup order by TotalSales desc, CourseParts, CourseID) as [Rank],
        getdate()
    from cteSegmentGroupSales
    PRINT 'END staging.Upsell_LoadSegmentCustomersSingles'
    
    PRINT 'Start staging.Upsell_LoadSegmentCustomersMultis'    
	exec Staging.Upsell_LoadSegmentCustomersMultis    
    ;with cteSegmentGroupSales(SubjectPreferenceID, PastOrdersBin, CourseID, CourseParts, TotalSales)
    as
    (
        select 
            SubjectPreferenceID, 
            PastOrdersBin,
            poi.CourseID, 
            Parts as CourseParts, 
            SUM(TotalSales) TotalSales
        from Staging.TempUpsell_SegmentCustomersMultis sc (nolock)
        join Marketing.DMPurchaseOrderItems poi (nolock) on sc.CustomerID = poi.CustomerID
        join (SELECT DISTINCT CourseID  -- To exclude discountinued courses
				FROM Staging.Invitem 
				WHERE forsaleonweb=1 
				AND forsaletoconsumer=1 
				AND InvStatusID in ('Active','Disc')
				AND itemcategoryid in ('course','bundle'))Crs ON poi.CourseID = Crs.CourseID
        where DateOrdered between DATEADD(year, -1, getdate()) and GETDATE()
        group by SubjectPreferenceID, PastOrdersBin, poi.CourseID, Parts
    )
    insert into Marketing.Upsell_CourseRank
    (
    	SegmentGroup,
        CourseID,
        [Rank],
        LastUpdateDate
    )
    select 
        SubjectPreferenceID + PastOrdersBin, 
        CourseID, 
        rank() over (partition by SubjectPreferenceID, PastOrdersBin order by TotalSales desc, CourseParts, CourseID) as [Rank],
        getdate()
    from cteSegmentGroupSales
	PRINT 'END staging.Upsell_LoadSegmentCustomersMultis'

	exec Staging.Upsell_LoadCustomerSegmentGroup

	truncate table Mapping.DMCourseRanking

	;with cteSales(CRComboID, SubjectPref, Gender, LTDPurchasesBin, CourseID, Parts, TotalSales) as
	(
		select 
		--	cr.CRComboID, 
			cr.CRComboIDOrig,
			cr.SubjectPref, 
			cr.Gender, 
		--	cr.LTDPurchasesBinOffer, 
			cr.LTDPurchasesBin,
			oi.CourseID, 
			oi.Parts, 
			SUM(oi.TotalSales) TotalSales
		from marketing.CustomerDynamicCourseRank cr (nolock)
		join Marketing.DMPurchaseOrderItems oi (nolock) on cr.CustomerID = oi.CustomerID
        join (SELECT DISTINCT CourseID  -- To exclude discountinued courses
				FROM Staging.Invitem 
				WHERE forsaleonweb=1 
				AND forsaletoconsumer=1 
				AND InvStatusID in ('Active','Disc')
				AND itemcategoryid in ('course','bundle'))Crs ON oi.CourseID = Crs.CourseID
		where oi.DateOrdered between DATEADD(year, -1, getdate()) and GETDATE()
		--group by cr.CRComboID, cr.SubjectPref, cr.Gender, cr.LTDPurchasesBinOffer, oi.CourseID, oi.Parts
		group by cr.CRComboIDOrig, cr.SubjectPref, cr.Gender, cr.LTDPurchasesBin, oi.CourseID, oi.Parts
	)
	insert into Mapping.DMCourseRanking
	(
		CRComboID, 
		R3SubjectPrefRev, 
		Gender, 
		LTDPurchasesBin, 
		CourseID, 
		Total,
		[Rank]
	) 
	select 
		CRComboID, 
		SubjectPref, 
		Gender, 
		LTDPurchasesBin, 
		CourseID, 
		TotalSales,
		rank() over (partition by CRComboID order by TotalSales desc, Parts, CourseID) as [Rank]
	from cteSales

	update Mapping.DMCourseRanking
	set CRCComboID = CRComboID + '-' + replicate('0', 4 - len([Rank])) + cast([Rank] as varchar(4))    

	-- 5/4/12/SK: the following is temporary and will be removed when TS is ready for a new tables format    
	PRINT 'Start staging.Upsell_UpdateOldMappingTables'    
    exec Staging.Upsell_UpdateOldMappingTables
   	PRINT 'END staging.Upsell_UpdateOldMappingTables'   
    	
END
GO
