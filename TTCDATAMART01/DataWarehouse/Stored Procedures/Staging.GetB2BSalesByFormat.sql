SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[GetB2BSalesByFormat]
AS
BEGIN
	set nocount on
    
	 if object_id('staging.TempB2BSales') is not null 
			Drop table staging.TempB2BSales
        
	select GETDATE() as ReportDate,
		year(a.Orderdate) YearOrdered,
		month(a.Orderdate) MonthOrdered,
		DataWarehouse.Staging.GetSunday(a.Orderdate) WeekOrdered,
		cast(a.Orderdate as Date) DateOrdered,
		orderid,
		a.CURRENCYCODE,
		TotalMerchandise,
		TotalCoupons,
		TotalShipping,
		TotalTaxes,
		OtherCharges,
		(TotalMerchandise + TotalCoupons + TotalShipping + TotalTaxes + OtherCharges) NetOrderAmount,
		SourceCode as Adcode,
		Ordersource,
		a.Customerid,
		b.Firstname, 
		b.Lastname,
		c.AdcodeName,
		c.CatalogCode,
		c.CatalogName,
		c.MD_Audience,
		c.MD_Country,
		c.MD_Year,
		c.ChannelID as MD_ChannelID,
		C.MD_Channel,
		c.MD_PromotionTypeID,
		c.MD_PromotionType,
		c.MD_CampaignID,
		c.MD_CampaignName,
		CONVERT(int,0) DVD_Units,
		CONVERT(int,0) CD_Units,
		CONVERT(int,0) VideoDownload_Units,
		CONVERT(int,0) AudioDownload_Units,
		CONVERT(int,0) Transcript_Units,
		CONVERT(int,0) DVD_Parts,
		CONVERT(int,0) CD_Parts,
		CONVERT(int,0) VideoDownload_Parts,
		CONVERT(int,0) AudioDownload_Parts,
		CONVERT(int,0) Transcript_Parts,
		CONVERT(int,0) DVD_Sales,
		CONVERT(int,0) CD_Sales,
		CONVERT(int,0) VideoDownload_Sales,
		CONVERT(int,0) AudioDownload_Sales,
		CONVERT(int,0) Transcript_Sales
	into staging.TempB2BSales	
	from DAXImports..DAX_OrderExport a join
		 (select *
		from DataWarehouse.Mapping.vwAdcodesAll
		where MD_Audience = 'B2B')c on a.SourceCode = c.AdCode join
		DAXImports..CustomerExport b on a.Customerid = b.Customerid 
	where a.Orderdate >= DATEADD(month, DATEDIFF(month, 0, DATEADD(month,-3,getdate())), 0)


	 if object_id('staging.TempB2BSalesFormat') is not null 
			Drop table staging.TempB2BSalesFormat

	select a.orderid, 
		replace(c.MediaTypeID,' ','') FormatMedia,  
		SUM(b.Quantity) TotalUnits,
		sum(b.Quantity * d.CourseParts) TotalParts,
		SUM(b.Quantity * b.SALESPRICE) TotalSales
	into staging.TempB2BSalesFormat	
	from Staging.TempB2BSales a join
		DAXImports..DAX_OrderItemExport b on a.orderid = b.orderid join
		Staging.InvItem c on b.ITEMID = c.StockItemID left join
		Mapping.DMCourse d on c.CourseID = d.CourseID
	where b.LineType = 'ItemSold'
	group by a.orderid, 
		c.MediaTypeID
		
	update a
	set a.DVD_Units = b.TotalUnits,
		a.DVD_Parts = b.TotalParts,
		a.DVD_Sales = b.TotalSales
	from Staging.TempB2BSales a join
		(select * 
		from Staging.TempB2BSalesFormat
		where FormatMedia = 'DVD')b on a.orderid = b.orderid
		

	update a
	set a.CD_Units = b.TotalUnits,
		a.CD_Parts = b.TotalParts,
		a.CD_Sales = b.TotalSales
	from Staging.TempB2BSales a join
		(select * 
		from Staging.TempB2BSalesFormat
		where FormatMedia = 'CD')b on a.orderid = b.orderid
		


	update a
	set a.VideoDownload_Units = b.TotalUnits,
		a.VideoDownload_Parts = b.TotalParts,
		a.VideoDownload_Sales = b.TotalSales
	from Staging.TempB2BSales a join
		(select * 
		from Staging.TempB2BSalesFormat
		where FormatMedia = 'DownloadV')b on a.orderid = b.orderid
		

	update a
	set a.AudioDownload_Units = b.TotalUnits,
		a.AudioDownload_Parts = b.TotalParts,
		a.AudioDownload_Sales = b.TotalSales
	from Staging.TempB2BSales a join
		(select * 
		from Staging.TempB2BSalesFormat
		where FormatMedia = 'DownloadA')b on a.orderid = b.orderid


	update a
	set a.Transcript_Units = b.TotalUnits,
		a.Transcript_Parts = b.TotalParts,
		a.Transcript_Sales = b.TotalSales
	from Staging.TempB2BSales a join
		(select * 
		from Staging.TempB2BSalesFormat
		where FormatMedia in ('Transcript','DownloadT'))b on a.orderid = b.orderid	
		

	delete a
	from marketing.B2BSales a join
		Staging.TempB2BSales b on a.orderid = b.orderid
	

	insert into marketing.B2BSales
	select *
	from Staging.TempB2BSales 

	update a
	set a.ReportDate = b.ReportDate
	from marketing.B2BSales a,
		(select distinct reportdate from Staging.TempB2BSales) b

	Drop table staging.TempB2BSales
	Drop table staging.TempB2BSalesFormat        


END
GO
