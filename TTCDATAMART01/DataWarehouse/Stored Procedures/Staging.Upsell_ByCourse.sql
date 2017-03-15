SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[Upsell_ByCourse]
AS
BEGIN
    set nocount on
	 
	if object_id('Staging.CourseAffinityCustCount') is not null drop table Staging.CourseAffinityCustCount
	 
	create table Staging.CourseAffinityCustCount
	(CourseID1 int,
	CourseID2 int,
	CustCount int)


	if object_id('Staging.ValidCourse') is not null drop table Staging.ValidCourse
										
	select distinct CourseID,ReleaseDate
	into Staging.ValidCourse									
	from Staging.vwGetCourseList


	if object_id('Staging.TempCustCourse') is not null drop table Staging.TempCustCourse
										
	select distinct ccp.CustomerID, ccp.CourseID
	into Staging.TempCustCourse								
	from Marketing.CompleteCoursePurchase ccp join
		(select distinct a.OrderID
		from Marketing.DMPurchaseOrders a join
			Mapping.vwAdcodesAll b on a.AdCode = b.AdCode
		where DateOrdered >= DATEADD(month, -12, getdate())
		and b.AudienceID = 1)o on ccp.OrderID = o.orderid
	where CourseID in (select distinct CourseID 
					from Staging.vwGetCourseList)

		
	-- Create Ranking based on sales
	Declare @CourseID varchar(5)

	DECLARE MyCursor2 CURSOR
			FOR
			SELECT CourseID
			FROM Staging.ValidCourse
			order by 1
			
			/*- BEGIN Second Cursor for courses within the PreferredCategory*/
			OPEN MyCursor2
			FETCH NEXT FROM MyCursor2 INTO @CourseID

			WHILE @@FETCH_STATUS = 0
			BEGIN
			/*- Assign rank based on sales for the course id within the PreferredCategory*/
	        
			Print 'CourseID : ' + @CourseID
	        
			drop table Staging.TempCustCourseCourse
	        
			select *
			into Staging.TempCustCourseCourse
			from Staging.TempCustCourse 
			where Courseid = @CourseID
	        
				   insert into Staging.CourseAffinityCustCount
					select @CourseID as CourseID1, 
							a.CourseID as CourseID2,
							COUNT(a.CustomerID)
					from Staging.TempCustCourse a join
						Staging.TempCustCourseCourse b on a.customerid = b.customerid					
					group by a.CourseID						

					
				--select * from Staging.CourseAffinityCustCount	
						
			print '-------------------------------------------------------------'

				FETCH NEXT FROM MyCursor2 INTO @CourseID
			END
			CLOSE MyCursor2
			DEALLOCATE MyCursor2
	        

	-- Create Temporary Course Rank table
	if object_id('Staging.TempCourseRank') is not null drop table Staging.TempCourseRank

	select a.CourseID1 as MainCourseID,
		b.AbbrvCourseName as MainCourseName,
		b.ReleaseDate as MainReleaseDate,
		DATEDIFF(day,b.ReleaseDate, GETDATE()) as MainDaysSinceRls,
		b.CourseParts as MainCourseParts,
		b.SubjectCategory2 as MainSubjCat,
		a.CourseID2 as UpsellCourseID,
		c.AbbrvCourseName as UpsellCourseName,
		c.ReleaseDate as UpsellReleaseDate,
		DATEDIFF(day,c.ReleaseDate, GETDATE()) as UpsellDaysSinceRls,
		c.CourseParts as UpsellCourseParts,
		c.SubjectCategory2 as UpsellSubjCat,
		a.CustCount,
		((rank() over (partition by a.CourseID1 order by a.CustCount desc, b.CourseParts desc, a.CourseID2))-1) as Rank
	into Staging.TempCourseRank
	from Staging.CourseAffinityCustCount a join
		Mapping.DMCourse b on a.CourseID1 = b.CourseID join
		Mapping.DMCourse c on a.CourseID2 = c.CourseID


	declare @total float
	select @total = SUM(CustCount)
	from Staging.TempCourseRank
	where RANK = 0

	-- Create Temporary Course Rank #2 table
	if object_id('Staging.TempCourseRank2') is not null drop table Staging.TempCourseRank2

	select *, (convert(float,CustCount)/@total)*100 as PrcntCount
	into Staging.TempCourseRank2
	from Staging.TempCourseRank
	where RANK = 0


	-- add flex factors
	if object_id('Staging.TempFlexed') is not null drop table Staging.TempFlexed
							
	select *,
		case when MainSubjCat = UpsellSubjCat and UpsellDaysSinceRls between 0 and 15 then Custcount * 10
			when  MainSubjCat = UpsellSubjCat and UpsellDaysSinceRls between 16 and 30 then Custcount * 5
			when MainSubjCat = UpsellSubjCat and  UpsellDaysSinceRls between 31 and 60 then Custcount * 4
			when MainSubjCat = UpsellSubjCat and  UpsellDaysSinceRls between 61 and 90 then Custcount * 3
			when MainSubjCat = UpsellSubjCat and  UpsellDaysSinceRls between 91 and 150 then Custcount * 2.5
			when MainSubjCat = UpsellSubjCat and  UpsellDaysSinceRls between 151 and 180 then Custcount * 2
			else Custcount * 1
		end as CustCount2
	into Staging.TempFlexed	
	from Staging.TempCourseRank
	where mainCourseID in (select maincourseid 
							from Staging.TempCourseRank2
							where PrcntCount > 0.04)
	and MainDaysSinceRls > 90						
	union
	select *, CustCount
	from  Staging.TempCourseRank
	where mainCourseID not in (select maincourseid 
							from Staging.TempCourseRank2
							where PrcntCount > 0.04)
	union
	select *, CustCount
	from  Staging.TempCourseRank
	where mainCourseID in (select maincourseid 
							from Staging.TempCourseRank2
							where PrcntCount > 0.04)
	and MainDaysSinceRls < 90												
	-- (216438 row(s) affected)

	---- delete if the courseID and upsell CourseID are the same
	--delete 
	--from Staging.TempFlexed	
	--where MainCourseID = UpsellCourseID
	
	-- add flex factors
	if object_id('Staging.CourseAffinityCustRanking') is not null drop table Staging.CourseAffinityCustRanking

	select *, 
	((rank() over (partition by maincourseid order by CustCount2 desc, upsellCourseParts desc, upsellcourseid))-1) as Rank2
	into Staging.CourseAffinityCustRanking
	 from Staging.TempFlexed

	-- To create default Ranking
	
	select * from Staging.CourseAffinityCustRanking
	truncate table datawarehouse.mapping.WebLP_InputCourse

	insert into datawarehouse.mapping.WebLP_InputCourse
	select CourseID, 0
	from Staging.ValidCourse
	
	exec [Staging].[CreateWebLandingPageData] 'Web', 'RankBySales', 12, 'US', 'Upsell', '1/1/2025', '1/1/2025',1
	
	insert into Staging.CourseAffinityCustRanking (MainCourseID, UpsellCourseID, Rank2)
	select 1 as CourseID,
		CourseID as UpsellCouirseID,
		rank as DisplayOrder
	from lstmgr.dbo.WebLP_US_20250101_Upsell_CourseRank
	
	declare @updateTime datetime
	select @updateTime = GETDATE()

	Truncate table Marketing.Upsell_CourseLevelReccos_HouseWeb	

	insert into Marketing.Upsell_CourseLevelReccos_HouseWeb	
	select distinct MainCourseID as CourseID,
		UpsellCourseID,
		convert(float,Rank2) as DisplayOrder,
		convert(varchar(5),'US') CountryCode,
		@updateTime as UpdateDate
	 from Staging.CourseAffinityCustRanking
	 where rank2 > 0
	 and MainCourseID <> UpsellCourseID

	-- run sets update and load into the main table.
	exec [Staging].[Upsell_BySet]		
	
	insert into Marketing.Upsell_CourseLevelReccos_HouseWeb
	select BundleID,
			UpsellCourseID,
			DisplayOrder,
			'US' as CountryCode,
			@updateTime
	from Marketing.UpsellForSets	
	

	-- drop all the working tables
	drop table Staging.CourseAffinityCustCount
	drop table Staging.ValidCourse	    
	drop table Staging.TempCustCourse
	drop table Staging.TempCourseRank
	drop table Staging.TempCourseRank2
	drop table Staging.TempFlexed
	drop table Staging.CourseAffinityCustRanking
    	
    	
END
GO
