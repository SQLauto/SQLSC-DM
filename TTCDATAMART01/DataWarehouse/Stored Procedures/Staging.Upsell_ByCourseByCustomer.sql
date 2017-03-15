SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[Upsell_ByCourseByCustomer]
AS
BEGIN
    set nocount on

	if object_id('staging.TempUpsellBCBC_Cust') is not null drop table staging.TempUpsellBCBC_Cust

	-- use course level upsell for customer online upsell..

	select 
		t1.CustomerID,
		t1.CourseID,
		t1.Parts as CourseParts,
		t1.SubjectCategory2,
		t3.PreferredCategory2,
		sum(t1.TotalSales) Sales,
		CONVERT(Float,0.0) CourseSat
	into staging.TempUpsellBCBC_Cust
	from Marketing.DMPurchaseOrderItems t1
	join (select customerid, max(convert(date, dateordered)) MaxOrderDate from Marketing.DMPurchaseOrders 
			group by customerid) t2 on t1.CustomerID=t2.CustomerID 
								and convert(date,t1.DateOrdered)=t2.MaxOrderDate
	join (select CustomerID, PreferredCategory2 from Marketing.CampaignCustomerSignature
			group by CustomerID, PreferredCategory2) t3 on t2.CustomerID=t3.CustomerID
	group by 
		t1.CustomerID,
		t1.CourseID,
		t1.Parts,
		t1.SubjectCategory2,
		t3.PreferredCategory2

	-- Update Course SAT
	update a
	set CourseSat=b.PostReleaseCourseSat
	from staging.TempUpsellBCBC_Cust a
	join Mapping.DMCourse b
	on a.CourseID=b.CourseID
	--(4872901 row(s) affected)

	-- if the course is not in valid course list, drop them.
	if object_id('Staging.TempUpsellBCBC_ValidCourse') is not null drop table Staging.TempUpsellBCBC_ValidCourse
										
	select distinct CourseID,ReleaseDate
	into Staging.TempUpsellBCBC_ValidCourse									
	from Staging.vwGetCourseList
	
	delete a
	from staging.TempUpsellBCBC_Cust a left join
		Staging.TempUpsellBCBC_ValidCourse b on a.CourseID = b.CourseID
	where b.CourseID is null
		

	--- Rank by sales
	if object_id('Staging.TempUpsellBCBC_CourseRank1') is not null drop table Staging.TempUpsellBCBC_CourseRank1
	
	select *, rank() over (partition by customerid order by Sales desc) as SalesRank
	into Staging.TempUpsellBCBC_CourseRank1
	from staging.TempUpsellBCBC_Cust

	delete from Staging.TempUpsellBCBC_CourseRank1 where CustomerID = ''

	if object_id('Staging.TempUpsellBCBC_CourseRank2') is not null drop table Staging.TempUpsellBCBC_CourseRank2

	select *, CONVERT(int,0) MatchPrefSubj
	into Staging.TempUpsellBCBC_CourseRank2
	from Staging.TempUpsellBCBC_CourseRank1
	where SalesRank=1


	--- If one of the courses matches preferred category, delete other courses in the same order

	update Staging.TempUpsellBCBC_CourseRank2 set MatchPrefSubj=1
	where PreferredCategory2=SubjectCategory2
	and CustomerID in (select CustomerID from Staging.TempUpsellBCBC_CourseRank2
						group by CustomerID
						having COUNT(courseID)>1)


	delete from Staging.TempUpsellBCBC_CourseRank2
	-- select * from Staging.TempUpsellBCBC_CourseRank2
	where MatchPrefSubj = 0
	and CustomerID in (select distinct CustomerID from Staging.TempUpsellBCBC_CourseRank2
						where MatchPrefSubj=1)


	if object_id('Staging.TempUpsellBCBC_Cust2') is not null drop table Staging.TempUpsellBCBC_Cust2

	select *, rank() over (partition by customerid order by CourseSat desc) as Rank2
	into staging.TempUpsellBCBC_Cust2
	from Staging.TempUpsellBCBC_CourseRank2



	if object_id('Staging.TempUpsellBCBC_Cust22') is not null drop table Staging.TempUpsellBCBC_Cust22

	select *, rank() over (partition by customerid order by CourseID desc) as Rank3
	into staging.TempUpsellBCBC_Cust22
	from staging.TempUpsellBCBC_Cust2
	where Rank2=1


	--if object_id('Staging.TempUpsellBCBC_CourseSelection') is not null drop table Staging.TempUpsellBCBC_CourseSelection

	--select t1.CustomerID, t1.CourseID, t2.UpsellCourseID, t2.DisplayOrder
	--into Staging.TempUpsellBCBC_CourseSelection
	--from (select * from staging.TempUpsellBCBC_Cust22
	--		where Rank3=1) t1
	--join Marketing.Upsell_CourseLevelReccos_HouseWeb t2 on t1.CourseID=t2.CourseID
	
	-- include others with default ranking..
	insert into staging.TempUpsellBCBC_Cust22 (CustomerID, CourseID, Rank3)
	select distinct a.CustomerID,
		1 as CourseID,
		1 as Rank3
	from Marketing.CampaignCustomerSignature a left join
		staging.TempUpsellBCBC_Cust22 b on a.CustomerID = b.CustomerID
	where b.CustomerID is null

	-- Load final Customer and Rank tables
	
	if object_id('Marketing.Upsell_Cust_Course') is not null drop table Marketing.Upsell_Cust_Course

	select distinct customerID, CourseID
	into Marketing.Upsell_Cust_Course
	from staging.TempUpsellBCBC_Cust22
	where Rank3 = 1

	----if object_id('Marketing.Upsell_Rank_ByCourse') is not null drop table Marketing.Upsell_Rank_ByCourse

	----select *
	----into Marketing.Upsell_Rank_ByCourse
	----from Marketing.Upsell_CourseLevelReccos_HouseWeb
	----where CourseID in (select distinct courseid
	----					from Marketing.Upsell_Cust_Course)
	----and DisplayOrder <= 175
	----order by 1,3

	-- Drop working tables
	drop table staging.TempUpsellBCBC_Cust
	drop table Staging.TempUpsellBCBC_ValidCourse
	drop table Staging.TempUpsellBCBC_CourseRank1	
	drop table Staging.TempUpsellBCBC_CourseRank2
	drop table Staging.TempUpsellBCBC_Cust2
	drop table staging.TempUpsellBCBC_Cust22
		

END
GO
