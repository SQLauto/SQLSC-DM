SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[Upsell_CombineForSplitTest]
AS
BEGIN

	declare @SQLStatement varchar(8000),
			@Date varchar(8),
			@BkpRankTable varchar(50),
			@BkpCustTable varchar(50)

	-- Run control upsell load
	exec Staging.Upsell_LoadCourseRank
	
	-- Run Course level upsell load
	exec Staging.Upsell_ByCourse
	
	-- Run by Course by customer for test segment group
	exec Staging.Upsell_ByCourseByCustomer

	select @Date = CONVERT(varchar,getdate(),112),
		@BkpRankTable = 'Marketing.Upsell_CourseRank' + @Date,
		@BkpCustTable = 'Marketing.Upsell_CustomerSegmentGroup' + @Date
	
	-- backup the table and then make changes.
    if object_id(@BkpRankTable) is not null 
     begin
		set @SQLStatement = 'drop table ' + @BkpRankTable
		exec (@SQLStatement)
    end

	set @SQLStatement = 'select * into ' + @BkpRankTable + ' from Marketing.Upsell_CourseRank'
	exec (@SQLStatement)	

	-- backup the customer table and then make changes.
    if object_id(@BkpCustTable) is not null 
     begin
		set @SQLStatement = 'drop table ' + @BkpCustTable
		exec (@SQLStatement)
    end

	set @SQLStatement = 'select * into ' + @BkpCustTable + ' from Marketing.Upsell_CustomerSegmentGroup'
	exec (@SQLStatement)	
	
	
	delete from Marketing.Upsell_CourseRank
	where RANK > 175
	
	insert into Marketing.Upsell_CourseRank
	select UpsellCourseID, 
		DisplayOrder as Rank, 
		CourseID as SegmentGroup, 
		cast(GETDATE() as date) LastUpdateDate
	from Marketing.Upsell_CourseLevelReccos_HouseWeb
	where CourseID in (select distinct courseid
						from Marketing.Upsell_Cust_Course)
	and DisplayOrder <= 150
	order by 3,2

	-- Create unique customer list
	if object_id('Staging.CCupsellSplitUniqueCust') is not null drop table Staging.CCupsellSplitUniqueCust
	
	select distinct customerid 
	into Staging.CCupsellSplitUniqueCust
	from Marketing.CampaignCustomerSignatureUpsellSplit
	where CustGroup like '%Test%'

	update a
	set a.segmentGroup = b.CourseID
	-- select a.*, b.courseid 
	from Marketing.Upsell_CustomerSegmentGroup a join
		Marketing.upsell_Cust_course b on a.CustomerID = b.customerid join
		Staging.CCupsellSplitUniqueCust c on b.customerid = c.customerid
	

    if object_id('Staging.TempLastOrder') is not null Drop table Staging.TempLastOrder
    
	select distinct a.CustomerID, a.DateOrdered, a.OrderID, a.SequenceNum
	into Staging.TempLastOrder
	from Marketing.DMPurchaseOrders a join
		Staging.CCupsellSplitUniqueCust c on a.CustomerID = c.customerid join
		(select customerID, MAX(SequenceNum) MaxSeq
		from Marketing.DMPurchaseOrders 
		group by CustomerID)b on a.CustomerID = b.CustomerID
							and a.SequenceNum = b.MaxSeq	
	
	insert into Marketing.Upsell_CustomerSegmentGroup
	select b.CustomerID, b.CourseID, d.DateOrdered, cast(GETDATE() as date) as LastUpdateDate
	from Marketing.upsell_Cust_course b left join
		Marketing.Upsell_CustomerSegmentGroup a on a.CustomerID = b.customerid join
		Staging.CCupsellSplitUniqueCust c on b.customerid = c.customerid join
		Staging.TempLastOrder d on b.customerid = d.CustomerID
	where a.CustomerID is null 
  	
    	
END
GO
