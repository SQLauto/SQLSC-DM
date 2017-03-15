SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE Proc [Staging].[SP_ProcessUpsell_test_20160125]
as
Set nocount on

Begin

/* This SP populates the base Upsell tables on staging and then loads to final Archive.tgc_upsell_* tables.

	Process is controlled by DataWarehouse.Mapping.TGC_Upsell_Control activeflag = 1

	Key tables:  
	Control table: DataWarehouse.Mapping.TGC_Upsell_Control

	Key Logic tables and SP's used in Logic are in the Logic mapping table: DataWarehouse.Mapping.TGC_Upsell_Logic


 */

   BEGIN TRY
    BEGIN TRANSACTION


	Select LogicID, 0 as processed
	Into #Logic
	from DataWarehouse.Mapping.TGC_Upsell_Control
	where FlagActive = 1
	Group by LogicID

	Select LogicID,LocationID, 0 as processed
	Into #Location
	from DataWarehouse.Mapping.TGC_Upsell_Control
	where FlagActive = 1
	Group by LogicID,LocationID

	Declare @LogicId int,@LocationID int, @SQL nvarchar(4000), @CustList nvarchar(200), @ListCourse nvarchar(200),@LogicStoreProc nvarchar(200)


/*Truncate Customer List table*/
	Truncate Table Archive.tgc_upsell_customer_list

/*Truncate List Course rank table*/
	Truncate Table Archive.tgc_upsell_cart
	Truncate Table Archive.tgc_upsell_just_for_you
	Truncate Table Archive.tgc_upsell_my_digital_library
	Truncate Table Archive.tgc_upsell_product_detail_page
	Truncate Table Archive.tgc_upsell_you_may_like


	While Exists (select 1 from #Logic where processed = 0)
		Begin

			select top 1 @LogicId = LogicId from #Logic where processed = 0

			select @CustList =L.CustomerListTable, @ListCourse = L.RankTable,@LogicStoreProc = L.StoredProc from DataWarehouse.Mapping.TGC_Upsell_Logic L
			Where LogicId = @LogicId

			/* Execute the Logic Store Procedure to refill the CustomerList table and List Course rank table*/
			Print '/* Executing' + @LogicStoreProc + '*/' 
			--Exec (@LogicStoreProc)
			Print '/* Executed SP: ' + @LogicStoreProc + '*/' 

			print '--------------------------------------------------------'
			Print '/*Customer List table :'  + @CustList + '*/' 
			print '--------------------------------------------------------'
			--/*Load Customer List Data into Archive.tgc_upsell_customer_list based on @LogicId*/

			set @SQL = '
						If object_id('''+ @CustList +''') is not null
			
						Insert into Archive.tgc_upsell_customer_list (dax_customer_id,location_id,test_rank,list_id)
						Select CL.Customerid,C.LocationID,C.TestRank,CL.ListId 
						from DataWarehouse.'+ @CustList +' CL
						join DataWarehouse.Mapping.TGC_Upsell_Control C 
						on C.LogicID = ' + cast(@LogicId as varchar(10)) +     ' /* Load Customer List Data based on @LogicId */
						Where FlagActive = 1 '

				--Print @SQL
				Exec (@SQL)


	/*List Course ranking load*/
		While Exists (select 1 from #Location where processed = 0 and LogicId = @LogicId)
			Begin

				select top 1 @LocationID = LocationID from #Location where processed = 0 and LogicId = @LogicId

				If @LocationID = 1
				Begin

				Set @SQL = '
						If object_id('''+ @ListCourse +''') is not null
			
						Insert into Archive.tgc_upsell_cart (list_id,course_id,recommended_course_rank,recommended_course_id)
						Select ListID,CourseID,DisplayOrdeR,UpsellCourseID 
						from DataWarehouse.'+ @ListCourse +' CL
						'

				--Print @SQL
				Exec (@SQL)

				print '--------------------------------------------------------'
				Print '/*List Course Rank table :'  + @ListCourse + ' inserted into Location 1*/' 
				print '--------------------------------------------------------'

				End


				If @LocationID = 2
				Begin

				Set @SQL = '
						If object_id('''+ @ListCourse +''') is not null
			
						Insert into Archive.tgc_upsell_just_for_you (list_id,recommended_course_rank,recommended_course_id)
						Select ListID,DisplayOrdeR,UpsellCourseID 
						from DataWarehouse.'+ @ListCourse +' CL
						Where CourseID = 0' /* Only Courseid = 0*/

				--Print @SQL
				Exec (@SQL)

				print '--------------------------------------------------------'
				Print '/*List Course Rank table :'  + @ListCourse + ' inserted into Location 2 Archive.tgc_upsell_just_for_you*/' 
				print '--------------------------------------------------------'

				End

				If @LocationID = 3
				Begin

				Set @SQL = '
						If object_id('''+ @ListCourse +''') is not null
			
						Insert into Archive.tgc_upsell_my_digital_library (list_id,recommended_course_rank,recommended_course_id)
						Select ListID,DisplayOrdeR,UpsellCourseID 
						from DataWarehouse.'+ @ListCourse +' CL
						Where CourseID = 0'/* Only Courseid = 0*/

				--Print @SQL
				Exec (@SQL)

				print '--------------------------------------------------------'
				Print '/*List Course Rank table :'  + @ListCourse + ' inserted into Location 3 Archive.tgc_upsell_my_digital_library*/' 
				print '--------------------------------------------------------'

				End

				If @LocationID = 4
				Begin

				Set @SQL = '
						If object_id('''+ @ListCourse +''') is not null
			
						Insert into Archive.tgc_upsell_product_detail_page (list_id,course_id,recommended_course_rank,recommended_course_id)
						Select ListID,CourseID,DisplayOrdeR,UpsellCourseID 
						from DataWarehouse.'+ @ListCourse +' CL
						'

				--Print @SQL
				Exec (@SQL)

				print '--------------------------------------------------------'
				Print '/*List Course Rank table :'  + @ListCourse + ' inserted into Location 4 Archive.tgc_upsell_product_detail_page*/' 
				print '--------------------------------------------------------'

				End



				If @LocationID = 5
				Begin
				
				Set @SQL = '
						If object_id('''+ @ListCourse +''') is not null
			
						Insert into Archive.tgc_upsell_you_may_like (list_id,course_id,recommended_course_rank,recommended_course_id)
						Select ListID,CourseID,DisplayOrdeR,UpsellCourseID 
						from DataWarehouse.'+ @ListCourse +' CL
						'

				--Print @SQL
				Exec (@SQL)

				print '--------------------------------------------------------'
				Print '/*List Course Rank table :'  + @ListCourse + ' inserted into Location 5 Archive.tgc_upsell_you_may_like*/' 
				print '--------------------------------------------------------'

				End


				select  @LogicId as ProcessedLogicId,@LocationID as ProcessedLocationID

				Update #Location
				set processed = 1
				where LogicId = @LogicId 
				and LocationID = @LocationID

			End


	select  @LogicId as ProcessedLogicId
	Update #Logic
	set processed = 1
	where LogicId = @LogicId 

	End 


   COMMIT TRANSACTION
  END TRY


  BEGIN CATCH
    IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;
 
    DECLARE @ErrorNumber INT = ERROR_NUMBER();
    DECLARE @ErrorLine INT = ERROR_LINE();
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
 
    PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
    PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
  END CATCH


 END


GO
