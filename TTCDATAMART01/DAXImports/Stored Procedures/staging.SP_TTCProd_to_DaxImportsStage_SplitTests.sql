SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [staging].[SP_TTCProd_to_DaxImportsStage_SplitTests]
AS
/* This routine is used to export split test data to the ExportTables database
   Date Written: 2012-02-08 tom jones, TGC
   Last Updated: 2013-05-13 tlj Don't pull calc type in splittests (not needed by datamart yet).
   
				 2017/01/09 Bondugulav Conversion to TTCProd2009 to DaxImports Staging. (spExportSplitTests)
*/

Begin

Truncate table DaxImports.staging.DAX_TTCMKTCUSTOMEROFFERSINTERNAL
Truncate table DaxImports.staging.DAX_TTCMKTSPLITTESTS
Truncate table DaxImports.staging.DAX_TTCMKTSPLITTESTSCENARIOS

Insert into DaxImports.staging.DAX_TTCMKTSPLITTESTS

select SPLITNAME,STARTDATE,ENDDATESCHEDULED,ENDDATEACTUAL,MAXASSIGNMENTS,ACTIVE,MODIFIEDDATETIME,MODIFIEDBY,CREATEDDATETIME,CREATEDBY,RECVERSION,RECID	
from TTCPROD2009..TTCMKTSPLITTESTS

Insert into DaxImports.staging.DAX_TTCMKTSPLITTESTSCENARIOS
select * from TTCPROD2009..TTCMKTSPLITTESTSCENARIOS

Insert into DaxImports.staging.DAX_TTCMKTCUSTOMEROFFERSINTERNAL
select * from TTCPROD2009..TTCMKTCUSTOMEROFFERSINTERNAL
where CREATEDDATETIME > '2/1/2012'


End

GO
