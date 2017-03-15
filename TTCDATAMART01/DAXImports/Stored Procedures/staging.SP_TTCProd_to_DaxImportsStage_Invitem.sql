SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [staging].[SP_TTCProd_to_DaxImportsStage_Invitem] 
AS
/* This routine will be used to export items to the InvItem table from DAX 
   The items in this list are intended to be moved to both test and production as they become available
   and activated on the appropriate intranet systems
   Date written: 12/10/2010 tom jones, TTC
   Last Updated: 12/20/2010 tlj - Added Insert into ExportTables 
                 2011-02-25 tlj - only export numeric courseids
				 2011-05-16 tlj - set nonstockitem to 1 for services (downloads).
				 2012-10-04 tlj - Changed media qty to mutliply by ttcmktcourseparts instead of jsnoofparts.
				 2013-03-06 tlj - For Datamart - push 0 courseid for non-numeric coursedids
				 2017/01/09 BondugulaV  Convertion to TTCProd2009 to DaxImports Staging. (spExportInvitemToDatamart)

*/

Begin 

	Truncate table DaxImports.staging.Load_InvItem_ToDatamart

	Insert into DaxImports.staging.Load_InvItem_ToDatamart
	select itemid, 
			case when ISNUMERIC(jscourseid) = 0 then 0 else JSCOURSEID end,
			Packaging = case JSPACKAGING when 0 then 'NA' when 1 then 'Consumer' when 2 then 'Library' else 'NA2' end
			,Mediatypeid = JSCOURSEMEDIATYPE,
			Formatid = 0,
			Partnumber= case when JSCATEGORY ='Coursepart' and ISNUMERIC(right(rtrim(itemid),1)) = 1 then RIGHT(rtrim(itemid),1) else '0' end,
			Desc1 = ITEMNAME, 
			desc2=itemname,
			jscategory,
			Nonstockitem = case when itemtype = 2 then 1 else 0 end,
			forsalebycc=JSFORSALEBYCC,
			forsaleonweb=JSFORSALEONWEB,
			forsaletolibrary=JSFORSALETOLIBRARY,
			forsaletoconsumer=JSFORSALETOCONSUMER,
			couponcode=NULL,
			Minpurchase=NULL,
			Clearancestatus = 0, 
			ISBN = JSISBN, 
			taxable = 1,
			CONVERT(varchar(4),' ') as [Length], 
			Boxes = 1, 
			CONVERT(varchar(5),NULL) as Units,
			OnOrderQty = 0, 
			OnBackOrderQty = 0,
			OnOrderTotalQty = 0, 
			OnBackOrderTotalQty = 0,
			Guidebooklength= 0, 
			InvstatusID = 'Active',
			TotalOnHandQuantity = 0, 
			TotalBuildableQty = 0 , 
			OKToShipAlone = JSSHIPALONE,
			KanbanTypeID = 
			JSCOURSEMEDIATYPE, 
			Components = ' ',
			[ASSEMBLY]=JSCOURSEMEDIATYPE,
			FORMAT=JSCOURSEMEDIATYPE,
			fabrication = 0,
			Mediaquantity = case when JSCOURSEMEDIATYPE = 'DVD' then 2 * ttcmktcourseparts
								 when JSCOURSEMEDIATYPE = 'CD' then 6 * ttcmktcourseparts
								 else 12 * ttcmktcourseparts end,
			VideoDubbing = CAST( NULL as char(1)),
			Tape1Length = CAST( NULL as char(1)),
			Tape2Length = CAST( NULL as char(1)),
			Tape3Length = CAST( NULL as char(1)),
			Loaders = CAST( NULL as char(1)),
			CassettesinPart = cast(null AS CHAR(1)),
			InvoiceSectionID = 'SHIPPED',
			Pieces = case when JSCOURSEMEDIATYPE = 'DVD' then 2 * ttcmktcourseparts
								 when JSCOURSEMEDIATYPE = 'CD' then 6 * ttcmktcourseparts
								 else 12 * ttcmktcourseparts end,
			CubeSize = JSCUBESIZE,
			Weight = NETWEIGHT,
			IncludeinPickCount = 1,
			DownloadFname = JSDOWNLOADFNAME,
			Downloadfsize = JSDOWNLOADFSIZE,
			dataformat = ' '				 
		from TTCPROD2009..INVENTTABLE
		order by itemid

END
GO
