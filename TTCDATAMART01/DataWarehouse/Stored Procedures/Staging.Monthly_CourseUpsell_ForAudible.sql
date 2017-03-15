SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Staging].[Monthly_CourseUpsell_ForAudible] 

AS

/* PR - 6/4/2014 - to create monthly Course upsell file for Audible.

-- Final table: rfm..CourseUpsellForAudible_YYYYMMDD

-- loads the final file under the folder: \\File1\Groups\Marketing\Marketing Strategy and Analytics\UPsellRanking\UpsellCourseAffinity
-- with name: CourseUpsellForAudible_YYYYMMDDFNL.txt
-- in pipe separated format

*/



	-- 1 need to create the Same Order Course affinity using last 12 months data
	-- Exclude seq# 1
						
	if object_id('Staging.TempAudible_CourseList') is not null
	drop table Staging.TempAudible_CourseList
												
	select distinct CourseID,ReleaseDate
	into Staging.TempAudible_CourseList									
	from DataWarehouse.Staging.vwGetADLCourseList


	if object_id('Staging.TempAudible_CourseListCust') is not null
	drop table Staging.TempAudible_CourseListCust
	/*
	select distinct CustomerID, CourseID
	into Staging.TempAudible_CourseListCust								
	from DataWarehouse.Marketing.CompleteCoursePurchase
	where CourseID in (select distinct CourseID 
					from DataWarehouse.Staging.vwGetADLCourseList)
	and DateOrdered >= DATEADD(month, -12, getdate())
	and StockItemID like '[pd][ac]%'
	and OrderID in (select distinct OrderID
				from DataWarehouse.Marketing.DMPurchaseOrders
				where DateOrdered >= DATEADD(month, -12, getdate())
				and PromotionType in (select distinct promotiontypeid 
									from MarketingCubes..DimPromotionType
									where PromotionTypeFlag like '%house%'))
				*/ --Performance improvement

	select * into #CompleteCoursePurchase 
	from DataWarehouse.Marketing.CompleteCoursePurchase 
	where DateOrdered >= DATEADD(month, -12, getdate())
	and StockItemID like '[pd][ac]%'

	select distinct OrderID into #Orders
	from DataWarehouse.Marketing.DMPurchaseOrders
	where DateOrdered >= DATEADD(month, -12, getdate())
		and PromotionType in (select distinct promotiontypeid 
								from MarketingCubes..DimPromotionType
								where PromotionTypeFlag like '%house%')


	select Distinct CustomerID, CourseID 
	into Staging.TempAudible_CourseListCust
	from #CompleteCoursePurchase
	where courseid in (select distinct CourseID From DataWarehouse.Staging.vwGetADLCourseList)
	and OrderID in (select distinct OrderID from #Orders)

				select  * from MarketingCubes..DimPromotionType
				where PromotionTypeFlag like '%house%'

		
	TRUNCATE TABLE Staging.TempAudible_CourseAffinityCustCount

	Declare @CourseID varchar(5)

	DECLARE MyCursor2 CURSOR
			FOR
			SELECT CourseID
			FROM Staging.TempAudible_CourseList
			order by 1
			
			/*- BEGIN Second Cursor for courses within the PreferredCategory*/
			OPEN MyCursor2
			FETCH NEXT FROM MyCursor2 INTO @CourseID

			WHILE @@FETCH_STATUS = 0
			BEGIN
			/*- Assign rank based on sales for the course id within the PreferredCategory*/
	        
			Print 'CourseID : ' + @CourseID
	       
	    	if object_id('Staging.TempAudible_CourseListCustCourse') is not null
			drop table Staging.TempAudible_CourseListCustCourse
 	        
			select *
			into Staging.TempAudible_CourseListCustCourse
			from Staging.TempAudible_CourseListcust 
			where Courseid = @CourseID
	        
				   insert into Staging.TempAudible_CourseAffinityCustCount
					select @CourseID as CourseID1, 
							a.CourseID as CourseID2,
							COUNT(a.CustomerID)
					from Staging.TempAudible_CourseListCust a join
						Staging.TempAudible_CourseListCustCourse b on a.customerid = b.customerid					
					group by a.CourseID						

						
						
			print '-------------------------------------------------------------'

				FETCH NEXT FROM MyCursor2 INTO @CourseID
			END
			CLOSE MyCursor2
			DEALLOCATE MyCursor2
	     
	if object_id('Staging.TempAudible_CourseListRank') is not null
	drop table Staging.TempAudible_CourseListRank
	
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
		((rank() over (partition by a.CourseID1 order by a.CustCount desc, c.CourseParts desc, c.Releasedate desc, a.CourseID2))-1) as Rank
	into Staging.TempAudible_CourseListRank
	from Staging.TempAudible_CourseAffinityCustCount a join
		DataWarehouse.Mapping.DMCourse b on a.CourseID1 = b.CourseID join
		DataWarehouse.Mapping.DMCourse c on a.CourseID2 = c.CourseID


	declare @total float
	select @total = SUM(CustCount)
	from Staging.TempAudible_CourseListRank
	where RANK = 0

	if object_id('Staging.TempAudible_CourseListRank2') is not null
	drop table Staging.TempAudible_CourseListRank2
	
	select *, (convert(float,CustCount)/@total)*100 as PrcntCount
	into Staging.TempAudible_CourseListRank2
	from Staging.TempAudible_CourseListRank
	where RANK = 0

	select *
	from Staging.TempAudible_CourseListRank2
	where PrcntCount <=  0.04
							

	if object_id('Staging.TempAudible_CourseListflexed') is not null
	drop table Staging.TempAudible_CourseListflexed
			
	select *,
		case when MainSubjCat = UpsellSubjCat and UpsellDaysSinceRls between 0 and 15 then Custcount * 10
			when  MainSubjCat = UpsellSubjCat and UpsellDaysSinceRls between 16 and 30 then Custcount * 5
			when MainSubjCat = UpsellSubjCat and  UpsellDaysSinceRls between 31 and 60 then Custcount * 4
			when MainSubjCat = UpsellSubjCat and  UpsellDaysSinceRls between 61 and 90 then Custcount * 3
			when MainSubjCat = UpsellSubjCat and  UpsellDaysSinceRls between 91 and 150 then Custcount * 2.5
			when MainSubjCat = UpsellSubjCat and  UpsellDaysSinceRls between 151 and 180 then Custcount * 2
			else Custcount * 1
		end as CustCount2
	into Staging.TempAudible_CourseListflexed	
	from Staging.TempAudible_CourseListRank
	where mainCourseID in (select maincourseid 
							from Staging.TempAudible_CourseListRank2
							where PrcntCount > 0.04)
	and MainDaysSinceRls > 90						
	union
	select *, CustCount
	from  Staging.TempAudible_CourseListRank
	where mainCourseID not in (select maincourseid 
							from Staging.TempAudible_CourseListRank2
							where PrcntCount > 0.04)
	union
	select *, CustCount
	from  Staging.TempAudible_CourseListRank
	where mainCourseID in (select maincourseid 
							from Staging.TempAudible_CourseListRank2
							where PrcntCount > 0.04)
	and MainDaysSinceRls < 90	


	-- Drop Soundtracks FROM MAIN CourseID
	delete
	-- select *
	from Staging.TempAudible_CourseListflexed 
	where maincourseid in (select distinct CourseID
						from DataWarehouse.Staging.InvItem
						where KanbanTypeID like '%soundtrack%')

					
	-- Drop Soundtracks from UPSELL CourseID
	delete
	-- select *
	from Staging.TempAudible_CourseListflexed 
	where upsellcourseid in (select distinct CourseID
						from DataWarehouse.Staging.InvItem
						where KanbanTypeID like '%soundtrack%')


	if object_id('Staging.TempAudible_CourseAffinityCustRanking') is not null
	drop table Staging.TempAudible_CourseAffinityCustRanking
	
	select *, 
	((rank() over (partition by maincourseid 
					order by CustCount2 desc, 
							upsellCourseParts desc, 
							upsellReleaseDate desc, 
							upsellcourseid))-1) as Rank2
	into Staging.TempAudible_CourseAffinityCustRanking
	 from Staging.TempAudible_CourseListflexed
	 

	 update Staging.TempAudible_CourseAffinityCustRanking
	 set rank = RANK + 8.5
	 where upsellcourseid in (select distinct courseid
							from DataWarehouse.Mapping.DMCourse
							where FlagCLRCourse = 1)
	 
	if object_id('Marketing.Upsell_CourseLevelReccos_Audible_AudioOnly') is not null
	drop table Marketing.Upsell_CourseLevelReccos_Audible_AudioOnly
			 
	select MainCourseID as CourseID,
		UpsellCourseID,
		convert(float,Rank2) as DisplayOrder,
		convert(varchar(50),'Audible') VendorCode,
		CAST(getdate() as date) UpdateDate
	into Marketing.Upsell_CourseLevelReccos_Audible_AudioOnly	
	 from Staging.TempAudible_CourseAffinityCustRanking
	 where rank2 > 0


	-- Create final files for Abacus/Epsilon
	declare @AudibleTable varchar(100),
		@Qry varchar(8000),
		@AudibleTable2 varchar(100)
		
	select @AudibleTable = 'rfm..CourseUpsellForAudible_' + CONVERT(varchar,getdate(),112)

	select @AudibleTable2 = 'CourseUpsellForAudible_' + CONVERT(varchar,getdate(),112)


IF EXISTS(SELECT name FROM rfm.sys.tables WHERE name = @AudibleTable2)
	begin
		set @Qry = 'Drop table ' + @AudibleTable
		print @Qry
		exec (@Qry)				
	end	
			
	-- To send final data to Audible
	set @Qry = 'select a.CourseID, b.CourseName,
					 a.UpsellCourseID, c.CourseName as UpsellCourseName,
					 DisplayOrder, UpdateDate
				 into ' + @AudibleTable + ' 
				 from Marketing.Upsell_CourseLevelReccos_Audible_AudioOnly a join
					mapping.DMCourse b on a.courseid = b.courseid join
					mapping.DMCourse c on a.UpsellCourseid = c.CourseID
				 where DisplayOrder <= 15
				 order by 1,5'
				
	print @Qry
	exec (@Qry)		
			

	 
	 -- Run this to transfer the table to the folder:
	-- \\File1\Groups\Marketing\Marketing Strategy and Analytics\UPsellRanking\UpsellCourseAffinity\AudibleUpsell -- too long
	-- so transfer to one folder above to upsellcourseaffinity
	exec staging.ExportTableToPipeText rfm, dbo, @AudibleTable2, '\\File1\Groups\Marketing\Marketing Strategy and Analytics\UPsellRanking\UpsellCourseAffinity'
	
	
	TRUNCATE TABLE Staging.TempAudible_CourseAffinityCustCount
	drop table Staging.TempAudible_CourseAffinityCustRanking
	drop table Staging.TempAudible_CourseList
	drop table Staging.TempAudible_CourseListCust
	drop table Staging.TempAudible_CourseListRank
	drop table Staging.TempAudible_CourseListRank2
	drop table Staging.TempAudible_CourseListflexed
	drop table Staging.TempAudible_CourseListCustCourse
	


GO
