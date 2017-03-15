SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [Staging].[Sp_Upsell_ModelUnRecognizedLogic] 
AS 
Set Nocount On
BEGIN 

/************************* Unrecognized mode ***************************************/
	/*************** Tables list ****************/

	/*	Unrecognized Logic -2
		US tables  testsummary.dbo.US_CustomerList 
				  testsummary.dbo.US_ReccomendList
	*/
	/*************** Tables list ****************/
	/*
		SELECT  segment
		Into #segment
		FROM   testsummary.dbo.US_ReccomendList
		where segment='DEFAULT'
		group by  segment
		UNION
		SELECT  segment
		FROM   testsummary.dbo.US_CustomerList
		where segment='DEFAULT'
		group by  segment  
		order by 1
	*/
		/*
		update mapping.tgc_upsell_logic_list 
		set ListName = 'Deafult Model Unrecognized'
		where LogicID =-2
		*/

	/*	/*Insert new list vales*/ 
		INSERT INTO mapping.tgc_upsell_logic_list 
					(logicid, 
					listname,ListID) 
		SELECT a.logicid, 
				a.segmentgroup ,2
		FROM   (SELECT DISTINCT -2 AS LogicID,segment segmentgroup
				FROM  #segment)a 
				LEFT JOIN mapping.tgc_upsell_logic_list f 
					ON a.logicid = f.logicid 
						AND a.segmentgroup = f.listname 
		WHERE  f.listname IS NULL 
		ORDER  BY 2 
	*/


	/********************* Truncate tables ************************/

	Truncate table Staging.Logic_2CustomerList	
	Truncate table Staging.Logic_2ListCourseRank	

	/******************* Unrecognized List ID*******************/

	declare @ListId smallint
	select @ListId = ListID
		  FROM   mapping.tgc_upsell_logic_list LL 
		  where LL.logicid = -2 
		  and ListName = 'Deafult Model Unrecognized'

	select @ListId


	/******************* Load Customer Segments*******************/

		  INSERT INTO staging.Logic_2CustomerList 
					  (customerid, 
					   listid) 
		  SELECT -1 as customerid, @ListId listid 
 

    /******** Load Segment course ranks***************************/


		Insert into Staging.Logic_2ListCourseRank

			SELECT	 @ListId as listid, 
					 c.CourseView, 
					 c.rank,
					 c.CourseRec
			FROM testsummary.dbo.US_ReccomendList C
			where  c.CourseView <> c.CourseRec
			and segment = 'DEFAULT'
			


END

GO
