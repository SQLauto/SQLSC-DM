SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [Staging].[Sp_Upsell_ModelLogic] 
AS 
Set Nocount On
BEGIN 

	/*************** Tables list ****************/
	/* US tables  testsummary.dbo.US_CustomerList 
				  testsummary.dbo.US_ReccomendList

	International testsummary.dbo.Intl_CustomerList
				  testsummary.dbo.Intl_ReccomendList  
	*/
	/*************** Tables list ****************/

		SELECT  segment
		Into #segment
		FROM   testsummary.dbo.US_ReccomendList
		group by  segment
		UNION
		SELECT  segment
		FROM   testsummary.dbo.US_CustomerList
		group by  segment  
		UNION 
		SELECT  segment
		FROM   testsummary.dbo.Intl_CustomerList
		group by  segment  
		UNION 
		SELECT  segment
		FROM   testsummary.dbo.Intl_ReccomendList
		group by  segment


		/*Insert new list vales*/ 
		INSERT INTO mapping.tgc_upsell_logic_list 
					(logicid, 
					listname) 
		SELECT a.logicid, 
				a.segmentgroup 
		FROM   (SELECT DISTINCT 2 AS LogicID,segment segmentgroup
				FROM  #segment)a 
				LEFT JOIN mapping.tgc_upsell_logic_list f 
					ON a.logicid = f.logicid 
						AND a.segmentgroup = f.listname 
		WHERE  f.listname IS NULL 
		ORDER  BY 2 



	/********************* Truncate tables ************************/

	Truncate table Staging.Logic2CustomerList	
	Truncate table Staging.Logic2ListCourseRank	

	/********************* Truncate tables ************************/



	/******************* Load Customer Segments*******************/

		  INSERT INTO staging.logic2customerlist 
					  (customerid, 
					   listid) 
		  SELECT customerid, 
				 listid 
		  FROM   testsummary.dbo.US_CustomerList CR 
				 JOIN mapping.tgc_upsell_logic_list LL 
				   ON CR.segment = LL.listname 
				   AND LL.logicid = 2 
				   where customerid > 0

		  INSERT INTO staging.logic2customerlist 
					  (customerid, 
					   listid) 
		  SELECT cr.CustomerID, 
				 LL.listid 
		  FROM   testsummary.dbo.Intl_CustomerList CR 
				 JOIN mapping.tgc_upsell_logic_list LL 
				   ON CR.segment = LL.listname AND LL.logicid = 2 
				   left join staging.logic2customerlist cl on cl.CustomerID = cr.CustomerID
				   where cr.customerid > 0 and cl.CustomerID is null
	/******************* Load Customer Segments*******************/

	/*  Load default for Customerid = 0  based on most counts*/

		Declare @DefaultCustomer0ListID smallint
		
		select @DefaultCustomer0ListID = ListID
		from  ( select top 1 listid,count(*)cnt from  [Staging].[Logic2CustomerList]
				group by listid 
				order by 2 desc
			  ) b
		 
		select @DefaultCustomer0ListID as DefaultListID

		Insert into [Staging].[Logic2CustomerList] (CustomerID,ListId)
		select 0,@DefaultCustomer0ListID

	/***************Load For Customers who dont have segments**************/


/************************* Unrecognized mode ***************************************/

/*Moved to anaother logic -2*/
		--Insert into [Staging].[Logic2CustomerList] (CustomerID,ListId)
		--select 0,@DefaultCustomer0ListID

/************************* Unrecognized mode ***************************************/
		Declare @DefaultListID SmallInt 

		select @DefaultListID = ListID 
		from mapping.tgc_upsell_logic_list LL 
		where LL.logicid = 2 and ListName = 'Default' 
	
		  INSERT INTO staging.logic2customerlist 
					  (customerid, 
					   listid) 
		  SELECT CR.customerid, 
				 @DefaultListID 
		  FROM   DataWarehouse.Marketing.CampaignCustomerSignature CR 
				 left join staging.logic2customerlist F
				 on F.CustomerID = Cr.CustomerID
				 where F.CustomerID is null
				 and CR.customerid > 0

	/***************Load For Customers who dont have segments**************/

/*********************************************************************************************/
			 
		Insert into Staging.Logic2ListCourseRank

			SELECT	 listid, 
					 c.CourseView, 
					 c.rank,
					 c.CourseRec
			FROM testsummary.dbo.US_ReccomendList C
			JOIN mapping.tgc_upsell_logic_list LL 
			ON C.segment = LL.listname AND LL.logicid = 2 
			where  c.CourseView <> c.CourseRec


		Insert into Staging.Logic2ListCourseRank

			SELECT	 listid, 
					 c.CourseView, 
					 c.rank,
					 c.CourseRec
			FROM testsummary.dbo.Intl_ReccomendList C
			JOIN mapping.tgc_upsell_logic_list LL 
			ON C.segment = LL.listname AND LL.logicid = 2 
			where  c.CourseView <> c.CourseRec


	Drop table #segment

END
GO
