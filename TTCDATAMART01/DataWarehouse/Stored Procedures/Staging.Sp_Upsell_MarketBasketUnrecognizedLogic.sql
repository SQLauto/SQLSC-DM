SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [Staging].[Sp_Upsell_MarketBasketUnrecognizedLogic]
as
Begin


	/*************** Tables list ****************/

--Source  Tables:  TestSummary.dbo.US_MBA_RecommendList New table: staging.TGC_upsell_MBA_CourseRank

--Final Tables:  Staging.Logic_3CustomerList	 Staging.Logic_3ListCourseRank

--Logic Moved to new Datamart Staging.Calc_TGC_Upsell_MBA  New table: staging.TGC_upsell_MBA_CourseRank

	/*************** Tables list ****************/

		select 'Default' as Segment,
				PrimaryCourseid as CourseView,
				SecondaryCourseid as CourseRec,
				FinalRank as Rank
			into #MBA
		from staging.TGC_upsell_MBA_CourseRank

		SELECT segment
		Into #segment
		FROM  #MBA -- testsummary.dbo.US_MBA_RecommendList
		where segment='DEFAULT'
		group by  segment


		INSERT INTO mapping.tgc_upsell_logic_list 
					(logicid, 
					listname) 
		SELECT a.logicid, 
				a.segmentgroup 
		FROM   (SELECT DISTINCT -3 AS LogicID,segment segmentgroup
				FROM  #segment)a 
				LEFT JOIN mapping.tgc_upsell_logic_list f 
					ON a.logicid = f.logicid 
						AND a.segmentgroup = f.listname 
		WHERE  f.listname IS NULL 
		ORDER  BY 2 


	/********************* Truncate tables ************************/

		truncate table Staging.Logic_3CustomerList	 
		truncate table Staging.Logic_3ListCourseRank

	/********************* Truncate tables ************************/


	/******************* Unrecognized List ID*******************/
	declare @ListId smallint
	select @ListId = ListID
		  FROM   mapping.tgc_upsell_logic_list LL 
		  where LL.logicid = -3 
		  and ListName = 'Default'

	select @ListId
	/******************* Load Customer Segments*******************/

		  INSERT INTO staging.Logic_3CustomerList 
					  (customerid, 
					   listid) 
		  SELECT -1 as customerid, @ListId listid 
 
	/******************* Load Customer Segments*******************/

    /******** Load Segment course ranks***************************/


		Insert into Staging.Logic_3ListCourseRank

			SELECT	 @ListId as listid, 
					 c.CourseView, 
					 row_number() over(partition by @ListId,c.CourseView order by c.rank) as rank,
					 c.CourseRec
			FROM #MBA C--testsummary.dbo.US_MBA_RecommendList C
			where  c.CourseView <> c.CourseRec
			and segment = 'DEFAULT'
			and c.rank <=501
			
    /******** Load Segment course ranks***************************/


	Delete from Staging.Logic_3ListCourseRank
	where DisplayOrder>500

End




GO
