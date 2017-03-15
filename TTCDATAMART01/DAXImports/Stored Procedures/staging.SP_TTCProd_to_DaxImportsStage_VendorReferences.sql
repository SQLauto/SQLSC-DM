SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [staging].[SP_TTCProd_to_DaxImportsStage_VendorReferences]
AS
/* This routine is used to export order reference tables (originally for orders imported from LiveOps).
   Date Written: 2012-05-10 tom jones, TGC

				 2017/01/09 Bondugulav Conversion to TTCProd2009 to DaxImports Staging. (spExportVendorReferences)
*/
Begin

truncate table DaxImports.staging.DAX_VendorOrderReference  
  
Insert into DaxImports.staging.DAX_VendorOrderReference
select TTCVENDACCOUNT, TTCVENDKEYID, TTCSALESID, TTCORDERTOTAL, ImportDate = CREATEDDATETIME
 from TTCPROD2009..TTCDRTVORDERIDREF

End
GO
