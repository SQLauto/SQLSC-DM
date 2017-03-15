SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [Staging].[Sp_upsell_defaultlogic] 
AS 
Set Nocount On
  BEGIN 

  /* Proc to load Customer segment ranking and Course Segment ranking for Logic = 1 refer table for more details mapping.TGC_Upsell_Logic_List*/
      /*Load Values to Temp tables to update blanks*/ 
      SELECT * 
      INTO   #upsell_customersegmentgroup 
      FROM   marketing.upsell_customersegmentgroup 
	  where CustomerID>0

      SELECT * 
      INTO   #upsell_courserank 
      FROM   marketing.upsell_courserank 

      /*
	  SELECT Count(*) 
      FROM   #upsell_customersegmentgroup 
      WHERE  segmentgroup LIKE '% %' 

      SELECT Count(*) 
      FROM   #upsell_courserank 
      WHERE  segmentgroup LIKE '% %' 
	  */

      /*Remove Spaces in segment names*/ 
      UPDATE #upsell_courserank 
      SET    segmentgroup = Replace(segmentgroup, ' ', '') 
      WHERE  segmentgroup LIKE '% %' 

      UPDATE #upsell_customersegmentgroup 
      SET    segmentgroup = Replace(segmentgroup, ' ', '') 
      WHERE  segmentgroup LIKE '% %' 

      /*Insert new list vales*/ 
      INSERT INTO mapping.tgc_upsell_logic_list 
                  (logicid, 
                   listname) 
      SELECT a.logicid, 
             a.segmentgroup 
      FROM   (	select 1 as LogicID , 
				'Default Logic1' as segmentgroup
				Union
	  			SELECT DISTINCT 1 AS LogicID, 
                              segmentgroup 
              FROM   #upsell_courserank 
              UNION 
              SELECT DISTINCT 1 AS LogicID, 
                              segmentgroup 
              FROM   #upsell_customersegmentgroup)a 
             LEFT JOIN mapping.tgc_upsell_logic_list f 
                    ON a.logicid = f.logicid 
                       AND a.segmentgroup = f.listname 
      WHERE  f.listname IS NULL 
      ORDER  BY 2 

  /*Load default values*/ 
      --while (select max(courseid) from Staging.Logic1ListCourseRank) <> (select max(courseid) from #T)
      --Begin 
      --Insert into Staging.Logic1ListCourseRank  
      --(ListID,ListName,CourseID,Rank,UpsellCourseID) 
      --select  ListID,ListName,CourseID,Rank,UpsellCourseID   
      --from #T, 
      --(select ListID,ListName,Rank,CourseID as UpsellCourseID  
      --from  #Upsell_CourseRank CR 
      --join mapping.TGC_Upsell_Logic_List LL 
      --on CR.SegmentGroup=LL.ListName)CR 
      --where CourseID  = (select isnull(min(courseid),0) from #T where courseid > (select max(courseid) from Staging.Logic1ListCourseRank) )
      --End   
      IF Object_id('staging.TempLogic1ListCourseRank') IS NOT NULL 
        DROP TABLE datawarehouse.staging.templogic1listcourserank 

      SELECT Cast(LL.listid AS SMALLINT) ListID, 
             rank                        AS DisplayOrder, 
             courseid                    AS UpsellCourseID 
      INTO   datawarehouse.staging.templogic1listcourserank 
      FROM   #upsell_courserank CR 
             JOIN mapping.tgc_upsell_logic_list LL 
               ON CR.segmentgroup = LL.listname 
                  AND LL.logicid = 1 

      --drop table #Course 
      SELECT Cast(courseid AS SMALLINT)Courseid, 
             0                         AS Processed 
      INTO   #course 
      FROM   datawarehouse.staging.vwgetcourselist 
      UNION 
      SELECT 0, 
             0 AS Processed 

      TRUNCATE TABLE staging.logic1listcourserank 

      DECLARE @courseid INT 

      WHILE EXISTS (SELECT TOP 1 courseid 
                    FROM   #course 
                    WHERE  processed = 0) 
        BEGIN 
            SELECT TOP 1 @courseid = courseid 
            FROM   #course 
            WHERE  processed = 0 

            INSERT INTO staging.logic1listcourserank 
            SELECT listid, 
                   c.courseid, 
                   Cast(Rank() 
                          OVER( 
                            partition BY listid, C.courseid 
  ORDER BY displayorder) AS SMALLINT) DisplayOrder, 
                   upsellcourseid 
        FROM   datawarehouse.staging.templogic1listcourserank CR, 
                   #course C 
            WHERE  CR.upsellcourseid <> C.courseid 
                   AND C.courseid = @courseid 

            UPDATE #course 
            SET    processed = 1 
            WHERE  courseid = @courseid 

            PRINT @courseid 
        --select @courseid 
        END 

	/*
      SELECT listid, 
             courseid, 
             Count(*) 
      FROM   staging.logic1listcourserank 
      GROUP  BY listid, 
                courseid 
      ORDER  BY 3 
	*/

      /*Load into Customer Segment table Staging.Logic1CustomerList */ 
      TRUNCATE TABLE staging.logic1customerlist 

      INSERT INTO staging.logic1customerlist 
                  (customerid, 
                   listid) 
      SELECT customerid, 
             listid 
      FROM   #upsell_customersegmentgroup CR 
             JOIN mapping.tgc_upsell_logic_list LL 
               ON CR.segmentgroup = LL.listname 
               AND LL.logicid = 1 


      DROP TABLE #upsell_customersegmentgroup 

      DROP TABLE #upsell_courserank 

      DROP TABLE #course 

	/*  Load default for Customerid = 0  */

		Declare @DefaultListID smallint
		Select @DefaultListID = listid from DataWarehouse.Mapping.TGC_Upsell_Logic_List
		where Logicid=1 and ListName = 'Default Logic1' 
		select @DefaultListID as DefaultListID

		Insert into [Staging].[Logic1ListCourseRank]
		select @DefaultListID as ListID,CourseID,DisplayOrder,UpsellCourseID 
		from  [Staging].[Logic1ListCourseRank] a
		join 
		(select top 1 listid,count(*)cnt from  [Staging].[Logic1CustomerList]
		group by listid 
		order by 2 desc
		)b
		on a.ListId = b.ListId

	/*  Load default for Customerid = 0  */
		Insert into [Staging].[Logic1CustomerList] (CustomerID,ListId)
		select 0,@DefaultListID


	/*  Load default for Customerid's who have not been segemented by the old upsell process */
		Insert into [Staging].[Logic1CustomerList] (CustomerID,ListId)
		  SELECT CR.customerid, @DefaultListID 
		  FROM   DataWarehouse.Marketing.CampaignCustomerSignature CR 
				 left join staging.logic1customerlist F
				 on F.CustomerID = Cr.CustomerID
				 where F.CustomerID is null
				 and CR.customerid > 0
  END 


GO
