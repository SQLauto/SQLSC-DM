SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Staging].[Sp_Upsell_MarketBasketLogic]
as

Begin

	/*************** Tables list ****************/

--Source  Tables:  TestSummary.dbo.US_MBA_RecommendList New table: staging.TGC_upsell_MBA_CourseRank

--Final Tables:  Staging.Logic3CustomerList	 Staging.Logic3ListCourseRank

--Logic Moved to new Datamart Staging.Calc_TGC_Upsell_MBA  New table: staging.TGC_upsell_MBA_CourseRank

	/*************** Tables list ****************/

	--Calculate ranking
	exec Staging.Calc_TGC_Upsell_MBA

	select 'Default' as Segment,
			PrimaryCourseid as CourseView,
			SecondaryCourseid as CourseRec,
			FinalRank as Rank
		into #MBA
	from staging.TGC_upsell_MBA_CourseRank

		SELECT segment
		Into #segment
		FROM #MBA--testsummary.dbo.US_MBA_RecommendList
		group by segment

	
			/*Insert new list vales*/ 
		INSERT INTO mapping.tgc_upsell_logic_list 
					(logicid, 
					listname) 
		SELECT a.logicid, 
				a.segmentgroup 
		FROM   (SELECT DISTINCT 3 AS LogicID,segment segmentgroup
				FROM  #segment)a 
				LEFT JOIN mapping.tgc_upsell_logic_list f 
					ON a.logicid = f.logicid 
						AND a.segmentgroup = f.listname 
		WHERE  f.listname IS NULL 
		ORDER  BY 2 

	/********************* Truncate tables ************************/

	Truncate table Staging.Logic3CustomerList	
	Truncate table Staging.Logic3ListCourseRank	

	/********************* Truncate tables ************************/


	/*********** Load Customer list ***********/
		Declare @DefaultListID SmallInt 

		select @DefaultListID = ListID 
		from mapping.tgc_upsell_logic_list LL 
		where LL.logicid = 3 and ListName = 'Default' 
	
		  INSERT INTO staging.logic3customerlist 
					  (customerid, 
					   listid) 
		  SELECT CR.customerid, 
				 @DefaultListID 
		  FROM   DataWarehouse.Marketing.CampaignCustomerSignature CR 
				 left join staging.logic3customerlist F
				 on F.CustomerID = Cr.CustomerID
				 where F.CustomerID is null
				 and CR.customerid > 0
	/*********** Load Customer list ***********/

	/*******  Load default for Customerid = 0  based on most counts *******/

		Declare @DefaultCustomer0ListID smallint
		
		select @DefaultCustomer0ListID = ListID
		from  ( select top 1 listid,count(*)cnt from  [Staging].[Logic3CustomerList]
				group by listid 
				order by 2 desc
			  ) b
		 
		select @DefaultCustomer0ListID as DefaultListID

		Insert into [Staging].[Logic3CustomerList] (CustomerID,ListId)
		select 0,@DefaultCustomer0ListID

	/********Load default for Customerid = 0  based on most counts********/


	/********Load Segment Course view Rank ********/
			Insert into Staging.Logic3ListCourseRank

			SELECT	 listid, 
					 c.CourseView, 
					 row_number() over(partition by listid,c.CourseView order by c.rank),
					 c.CourseRec
			FROM #MBA C --testsummary.dbo.US_MBA_RecommendList C
			JOIN mapping.tgc_upsell_logic_list LL 
			ON C.segment = LL.listname AND LL.logicid = 3 
			where  c.CourseView <> c.CourseRec
			
			Delete from Staging.Logic3ListCourseRank
			where DisplayOrder >500

	/********Load Segment Course view Rank ********/

End

GO
