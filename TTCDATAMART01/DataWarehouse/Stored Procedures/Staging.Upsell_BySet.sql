SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[Upsell_BySet]
AS
BEGIN
    set nocount on

	if object_id('Staging.CourseAffinityCustCountSETS') is not null drop table Staging.CourseAffinityCustCountSETS

	create table Staging.CourseAffinityCustCountSETS
	(CourseID1 int,
	CourseID2 int,
	CustCount int)


	if object_id('Staging.TempSets') is not null drop table Staging.TempSets
										
	select distinct CourseID,ReleaseDate
	into Staging.TempSets									
	from Mapping.DMCourse 
	where BundleFlag = 1
	and CourseID not in (select distinct BundleID
						from Mapping.BundleComponents a left join
							Staging.vwGetCourseList b on a.CourseID = b.CourseID
						where b.CourseID is null)
						

	if object_id('Staging.TempSetCourse') is not null drop table Staging.TempSetCourse

	select a.CourseID as BundleID,
		b.CourseID,
		c.CourseParts,
		RANK() over (partition by BundleID order by c.courseparts desc, b.courseid) as Rank
	into Staging.TempSetCourse
	from Staging.TempSets a join
		Mapping.BundleComponents b on a.courseid = b.BundleID join
		datawarehouse.mapping.dmcourse c on b.courseid = c.courseid


	-- Get the individual course upsells from course upsell
	if object_id('Staging.TempSetCourseRank') is not null drop table Staging.TempSetCourseRank
	
	select a.*, 
		B.UpsellCourseID, 
		b.DisplayOrder, 
		b.CountryCode, 
		convert(float,convert(varchar, DisplayOrder) + '.' + CONVERT(varchar,RANK)) as FinalRank
	into Staging.TempSetCourseRank
	from Staging.TempSetCourse a join
		Datawarehouse.Marketing.Upsell_CourseLevelReccos_HouseWeb b on a.courseid = b.CourseID
	order by 1,8


	if object_id('Staging.TempSetCleanup') is not null drop table Staging.TempSetCleanup
	
	select BundleID, UpsellCourseID, MIN(FinalRank) DisplayOrder, Countrycode
	into Staging.TempSetCleanup
	from Staging.TempSetCourseRank
	group by BundleID, UpsellCourseID,Countrycode
	order by 1,3

	-- Remove courses that are in the set
	delete a
	from Staging.TempSetCleanup a join
		Mapping.BundleComponents b on a.bundleid = b.BundleID
											and a.upsellcourseid = b.CourseID

		
	-- create final rank
	if object_id('Staging.TempSetFnlRank') is not null drop table Staging.TempSetFnlRank

	select bundleID,
		 UpsellcourseID, 
		 RANK() Over (Partition by bundleID order by displayOrder) displayOrder,
		CountryCode
	into Staging.TempSetFnlRank
	from Staging.TempSetCleanup
	 
	 
	-- Make sure there are no duplicates
	if object_id('Staging.TempDupeAlert') is not null drop table Staging.TempDupeAlert
	
	select bundleid, 
		upsellcourseid, 
		COUNT(upsellcourseid) Count
	into Staging.TempDupeAlert
	from Staging.TempSetFnlRank
	group by bundleid, upsellcourseid
	having COUNT(upsellcourseid) > 1
	order by 1,2


	-- Create sets upsell table
	truncate table Marketing.UpsellForSets

	insert into Marketing.UpsellForSets
	select a.BundleID,
		b.CourseName as BundleName,
		b.ReleaseDate as MainReleaseDate,
		DATEDIFF(day,b.ReleaseDate, GETDATE()) as MainDaysSinceRls,
		b.CourseParts as MainCourseParts,
		b.SubjectCategory2 as MainSubjCat,
		a.UpsellCourseID,
		c.AbbrvCourseName as UpsellCourseName,
		c.ReleaseDate as UpsellReleaseDate,
		DATEDIFF(day,c.ReleaseDate, GETDATE()) as UpsellDaysSinceRls,
		c.CourseParts as UpsellCourseParts,
		c.SubjectCategory2 as UpsellSubjCat,
		a.DisplayOrder,
		GETDATE() ReportDate
	from Staging.TempSetFnlRank a join
		Mapping.DMCourse b on a.BundleID = b.CourseID join
		Mapping.DMCourse c on a.UpsellCourseID = c.CourseID
	order by 1, a.DisplayOrder


END
GO
