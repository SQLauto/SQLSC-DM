SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [staging].[SP_TTCProd_to_DaxImportsStage_OrderCredits]
AS
/* This routine is used to get order credits and set them up for export to datamart.
   Date Written: 2012-04-25 tom jones, TGC
   Last Updated: 2012-05-10 tlj Added Truncate table and and insert to ExportTables.

				 2017/01/09 Bondugulav Conversion to TTCProd2009 to DaxImports Staging. (spExportOrderCredits)

*/   

Begin

		select voucher, creditdate = createddatetime, createdby,orderid = origsalesid, customerid = custaccount, totalcredit, reasoncode, reasoncodedescription,
		CURRENCY = CONVERT(varchar(5),''), OriginalOrderdate = CONVERT(datetime,NULL)
		into #ordercredits
		from TTCPROD2009..JSCUSTCREDITTABLE
		where ITEMID = '' and CCSETTLEMENTRECID <> 0

		Update #ordercredits
		set Currency = CURRENCYcode,
			OriginalOrderDate = createddatetime
		from #ordercredits oc
		join TTCPROD2009..SALESTABLE sales
		on sales.DATAAREAID = 'sco'
		and oc.orderid = sales.SALESID


		select voucher, itemid,creditdate = createddatetime, createdby,orderid = origsalesid, customerid = custaccount, totalcredit, reasoncode, reasoncodedescription,
		CURRENCY = CONVERT(varchar(5),''), OriginalOrderdate = CONVERT(datetime,NULL)
		into #orderitemcredits
		from TTCPROD2009..JSCUSTCREDITTABLE
		where ITEMID <> '' and CCSETTLEMENTRECID <> 0
		order by origsalesid, itemid

		Update #orderitemcredits
		set Currency = CURRENCYcode,
			OriginalOrderDate = createddatetime
		from #orderitemcredits oc
		join TTCPROD2009..SALESTABLE sales
		on sales.DATAAREAID = 'sco'
		and oc.orderid = sales.SALESID

	Truncate Table DaxImports.staging.DAX_OrderCreditExport
	Insert into  DaxImports.staging.DAX_OrderCreditExport
	select * from #ordercredits

	Truncate Table DaxImports.staging.DAX_OrderItemCreditExport
	Insert into DaxImports.staging.DAX_OrderItemCreditExport
	select * from #orderitemcredits


END

GO
