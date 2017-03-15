SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[SP_Amazon_Load_Funnel]
as

Begin

/*
	Delete A 
	--select count(*)
	from Archive.FBA_funnel A 
	where A.FunnelDate >= (select cast(MIn(day) as date) from Staging.FBA_ssis_funnel S)
	
	Insert into Archive.FBA_funnel (ASIN,FunnelDate,Title,Sessions,PageViews,BuyBoxPercentage,UnitsOrdered,OrderedProductSales,TotalOrderItems)
	select ParentASIN,Day as FunnelDate,Title,Sessions,PageViews,BuyBoxPercentage,UnitsOrdered,OrderedProductSales,TotalOrderItems
	from Staging.FBA_ssis_funnel
*/

  BEGIN TRY
    BEGIN TRANSACTION
   
	select count(*) DeletedRecords
	from Archive.FBA_funnel A 
	where cast(A.FunnelDate as date) in (select cast(day as date) from Staging.FBA_ssis_funnel S Group by cast(day as date) )

   	Delete A 
	--select count(*)
	from Archive.FBA_funnel A 
	where cast(A.FunnelDate as date) in (select cast(day as date) from Staging.FBA_ssis_funnel S Group by cast(day as date) )

	--Reseed:
	DECLARE @maxVal INT
	SELECT @maxVal = ISNULL(max(FBA_funnel_Id),0)+1 from Archive.FBA_funnel
	select @maxVal
	DBCC CHECKIDENT('Archive.FBA_funnel', RESEED, @maxVal)
	
	SELECT @maxVal = ISNULL(max(FBA_funnel_Id),0)+1 from Archive.FBA_funnel
	select @maxVal Reseedvalue

	Insert into Archive.FBA_funnel (ASIN,FunnelDate,Title,Sessions,PageViews,BuyBoxPercentage,UnitsOrdered,OrderedProductSales,TotalOrderItems)
	select ParentASIN,Day as FunnelDate,Title,Sessions,PageViews,BuyBoxPercentage,UnitsOrdered,OrderedProductSales,TotalOrderItems
	from Staging.FBA_ssis_funnel

    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION
 
    DECLARE @ErrorNumber INT = ERROR_NUMBER()
    DECLARE @ErrorLine INT = ERROR_LINE()
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
    DECLARE @ErrorState INT = ERROR_STATE()
 
    PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
    PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
  END CATCH



End



 
GO
