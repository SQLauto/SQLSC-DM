SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [Staging].[Sp_Upsell_DefaultUnRecognizedLogic] @top INT = 20 
AS 
  BEGIN 
  /* This Procedure Staging.SP_UpsellCourseRankingOnly will reload the UpsellCourse rank for the Unrecognized login and the code is trying to mimic previous logic*/
      ----------------------/*Step1 Load Valid Courses for Ranking*/--------------------- 
      TRUNCATE TABLE mapping.upsellcourserank_inputcourse 

      /*Load Courses for Ranking*/ 
      INSERT INTO mapping.upsellcourserank_inputcourse 
      SELECT courseid, 
             0 
      FROM   staging.vwgetcourselist 

      ------------------/*Create Initial Course Rank*/------------------ 
      EXEC staging.Sp_upsellcourserankingonly 

      -- SELECT a.Sumsales,a.CourseID,a.PreferredCategory, a.Rank    
      --FROM lstmgr..WebLP_US_20160309_UpsellAnonyms_CourseRank  a 
      --select * from SuperStarDW.dbo.MktCourse 
      --select distinct PreferredCategory from datawarehouse.mapping.UpsellCourseRank_US_Unrecognized_CourseRank
      --drop table #SubjectCategory 
      ------------------/*Convert Initial Course Rank to SubjectCategoryId*/------------------  
      ------------------/*Load SubjectCategoryId based on Course SubjectCategory2*/------------------  
      SELECT subjectcategoryid, 
             preferredcategory, 
             courseid, 
             [rank], 
             Cast(Row_number() 
                    OVER( 
                      partition BY subjectcategoryid 
                      ORDER BY [rank]) AS FLOAT) AS RNK, 
             subjectcategoryid2 
      INTO   #subjectcategory 
      FROM   (SELECT S.courseid, 
                     preferredcategory, 
                     rank, 
                     CASE 
                       WHEN preferredcategory IN ( 'GEN' ) THEN 900 
                       WHEN preferredcategory IN ( 'EC' ) THEN 901 
                       WHEN preferredcategory IN ( 'HS' ) THEN 902 
                       WHEN preferredcategory IN ( 'MSC', 'VA' ) THEN 904 
                       WHEN preferredcategory IN ( 'LIT' ) THEN 905 
                       WHEN preferredcategory IN ( 'PH' ) THEN 907 
                       WHEN preferredcategory IN ( 'RL' ) THEN 909 
                       WHEN preferredcategory IN ( 'SCI', 'MTH' ) THEN 910 
                       WHEN preferredcategory IN ( 'AH', 'MH' ) THEN 918 
                       WHEN preferredcategory IN ( 'PR' ) THEN 926 
                       WHEN preferredcategory IN ( 'FW' ) THEN 927 
                       ELSE null 
                     END AS SubjectCategoryId, 
                     CASE 
                       WHEN subjectcategory2 IN ( 'GEN' ) THEN 900 
                       WHEN subjectcategory2 IN ( 'EC' ) THEN 901 
                       WHEN subjectcategory2 IN ( 'HS' ) THEN 902 
                       WHEN subjectcategory2 IN ( 'MSC', 'VA' ) THEN 904 
                       WHEN subjectcategory2 IN ( 'LIT' ) THEN 905 
                       WHEN subjectcategory2 IN ( 'PH' ) THEN 907 
                       WHEN subjectcategory2 IN ( 'RL' ) THEN 909 
                       WHEN subjectcategory2 IN ( 'SCI', 'MTH' ) THEN 910 
                       WHEN subjectcategory2 IN ( 'AH', 'MH' ) THEN 918 
                       WHEN subjectcategory2 IN ( 'PR' ) THEN 926 
                       WHEN subjectcategory2 IN ( 'FW' ) THEN 927 
                       ELSE null 
                     END AS SubjectCategoryID2 
              FROM 
      datawarehouse.mapping.upsellcourserank_us_unrecognized_courserank 
      S 
      JOIN datawarehouse.mapping.dmcourse C 
        ON C.courseid = S.courseid)a 
      WHERE  subjectcategoryid IS NOT NULL 

      /* Set Default for SubjectCategoryId = 900 */ 
      UPDATE #subjectcategory 
      SET    subjectcategoryid2 = 900 
      WHERE  subjectcategoryid = 900 

      ------------------/*Load SubjectCategoryId based on Course SubjectCategory2*/------------------ 
     ------------------/*Update rank based on @top values when course SubjectCategoryId based equal to Course SubjectCategory2*/------------------  
      --drop table #SubjectCategoryTEMPRank 
      SELECT *, 
             Cast(Row_number() 
                    OVER( 
                      partition BY subjectcategoryid 
                      ORDER BY rnk) AS FLOAT) AS FinalRANK 
      INTO   #subjectcategorytemprank 
      FROM   #subjectcategory 
      WHERE  subjectcategoryid = subjectcategoryid2 

      --Declare @TOP int =10 --So we can select top courses that match the current segment 
      UPDATE s 
      SET    rnk = 1. * finalrank / @TOP 
      --select * ,1.*FinalRANK/10  
      FROM   #subjectcategory S 
             JOIN #subjectcategorytemprank S1 
               ON S.subjectcategoryid = S1.subjectcategoryid 
                  AND S.courseid = S1.courseid 
      WHERE  finalrank <= @TOP 

      ------------------/*Calculate min course rank in each SubjectCategoryId and courseid as it could repeat in the segments where there are multiple*/------------------  
      --drop table #MinCourseRNK 
      SELECT subjectcategoryid, 
             courseid, 
             Min(rnk)RNK 
      INTO   #mincoursernk 
      FROM   #subjectcategory 
      GROUP  BY subjectcategoryid, 
                courseid 
      ORDER  BY 1, 
                3, 
                2 

      ------------------/*Load into #finalRank */------------------  
      --Drop table #FinalRNK 
      SELECT subjectcategoryid, 
             courseid, 
             Cast(Row_number() 
                    OVER( 
                      partition BY subjectcategoryid 
                      ORDER BY rnk) AS FLOAT)DisplayOrder 
      INTO   #finalrnk 
      FROM   #mincoursernk 
      ORDER  BY 1, 
                3 

      /*
	  SELECT * 
      FROM   #finalrnk 
      ORDER  BY 1, 
                3 

      SELECT subjectcategoryid, 
             courseid, 
             Count(*) 
      FROM   #finalrnk 
      GROUP  BY subjectcategoryid, 
                courseid 
      HAVING Count(*) > 1 
	  */
  /* --------------------------------Part 2 Creating the ranking on Course level ------------------------------------*/ 
      --select * from DataWarehouse.Staging.CCUpSellAnonymous 
      IF Object_id('staging.Logic_1ListCourseRank') IS NOT NULL 
        DROP TABLE staging.logic_1listcourserank 

      SELECT Cast(1 AS SMALLINT)                        AS ListID, 
             'Deafult Unrecognized'                      AS ListName, 
             Cast(C.courseid AS SMALLINT)                AS Courseid, 
             Cast(Rank() 
                    OVER( 
                      partition BY C.subjectcategoryid, C.courseid 
                      ORDER BY displayorder) AS SMALLINT)DisplayOrder, 
             Cast(CCUP.courseid AS SMALLINT)             AS UpsellCourseID, 
             Getdate()                                   AS DMLastUpdated 
      INTO   staging.logic_1listcourserank 
      FROM   #finalrnk CCUP 
             JOIN (SELECT c.courseid, 
                          CASE 
                            WHEN c.subjectcategoryid IN ( 901, 902, 904, 905, 
                                                          907, 909, 910, 918, 
                                                          926, 927 ) 
                          /* to get course level rank for courses that do not have SubjectCategoryID map*/
                          THEN c.subjectcategoryid 
                            ELSE 900 
                          END AS SubjectCategoryId 
                   FROM   datawarehouse.mapping.dmcourse c 
                          JOIN datawarehouse.staging.vwgetcourselist ac 
                            ON c.courseid = ac.courseid 
                   UNION 
                   --Default value to 0 
                   SELECT 0, 
                          900)C 
               ON C.subjectcategoryid = ccup.subjectcategoryid 
      WHERE  C.courseid <> CCUP.courseid 

	  delete from staging.logic_1listcourserank 
	  where DisplayOrder>500

      SELECT 'Duplpicates in Courseid and UpsellCourseid' AS Duplpicates, 
             listid, 
             courseid, 
             upsellcourseid, 
             Count(*) 
      FROM   staging.logic_1listcourserank 
      GROUP  BY listid, 
                courseid, 
                upsellcourseid 
      HAVING Count(*) > 1 
      ORDER  BY 2 DESC 

      SELECT 'Duplpicates in Courseid and DisplayOrder' AS Duplpicates, 
             listid, 
             courseid, 
             displayorder, 
             Count(*) 
      FROM   staging.logic_1listcourserank 
      GROUP  BY listid, 
                courseid, 
                displayorder 
      HAVING Count(*) > 1 
      ORDER  BY 2 DESC 

	  /*
      SELECT courseid, 
             Count(*) 
      FROM   staging.logic_1listcourserank (nolock)
      GROUP  BY courseid 
      ORDER  BY 2 DESC 
		*/

       /*Load into Customer Segment table Staging.Logic1CustomerList */ 
      TRUNCATE TABLE staging.logic_1customerlist 

      INSERT INTO staging.Logic_1CustomerList 
                  (customerid, 
                   listid) 
      SELECT -1 customerid, 1 as listid 

  
  
  END 

GO
