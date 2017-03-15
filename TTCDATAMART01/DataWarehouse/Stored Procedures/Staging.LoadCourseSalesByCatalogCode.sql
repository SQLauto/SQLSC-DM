SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Staging].[LoadCourseSalesByCatalogCode]
	@Year int = -1
AS
--- Proc Name:    TestSummary.dbo.Get_CourseSalesByCatalogcode 
--- Purpose:      To ALTER  a table with Sales by Course for different catalogcodes 
--- Input Parameters: None
---               
--- Updates:
--- Name          Date        Comments
--- Preethi Ramanujam   1/13/2009   New
begin
	set nocount on
    
	if @Year = -1 set @Year = year(getdate())
    
  	if object_id('Staging.CourseSalesByCatalogCode') is not null drop table Staging.CourseSalesByCatalogCode
    
    ;with cteOrdersAggregates(CatalogCode, CourseID, BundleID, StockItemID, TotalSales, TotalOrders, TotalUnits) as
    (
    	select 
        	a.CatalogCode, 
            OI.CourseID, 
	        OI.BundleID,     
            oi.StockItemID,        
	        sum(OI.TotalSales) TotalSales,
    	    count(distinct Oi.OrderID) TotalOrders, 
        	sum(OI.TotalQuantity) TotalUnits 
        FROM Mapping.vwAdcodesAll A (nolock)
        left join Mapping.DMPromotionType B (nolock) ON A.CatalogCode = B.CatalogCode 
        JOIN Marketing.DMPurchaseOrders O (nolock) ON A.Adcode = O.Adcode 
        join Marketing.DMPurchaseOrderItems OI (nolock) ON oi.OrderID = o.OrderID
        WHERE 
        	O.DateOrdered BETWEEN A.StartDate and dateadd(day,1,A.StopDate)
		    AND A.StartDate > convert(date, '12/1/' + convert(varchar(4) ,(year(getdate()) -4)))            
	        AND OI.TotalSales Between 1 and 1500
    	    AND (B.Promotiontype in ('Catalog','Convertalog','Catalog International','Letter Mailings',
        	    'OutsideMailing','HighSchoolMail','SwampSpecific','Newsletter',
                'Catalog Prospecting International','MAGAZINE','Magalog','ShippingCatalog',
                'E-campaign','E-campaign_Int','Other','Magnificent7','MagBacks', 'Google Banners', 'ECommerceMarketing',
                'GoogleWebAds', 'SearchEngine', 'SearchEnginePPC', 'GoogleWebAds: Buffet', 'Search Engine Buffet','Radio')
               or a.ChannelID in (1,2,4,5,6,20))
        GROUP BY 
            a.CatalogCode, OI.CourseID, OI.BundleID, StockItemID
    )
    select 
		oa.CatalogCode, 
       	oa.CourseID, 
       	oa.BundleID, 
        oa.StockItemID,
       	oa.TotalSales, 
       	oa.TotalOrders, 
        oa.TotalUnits,
        a.CatalogName, 
        A.StartDate,
        a.MD_CampaignID, 
        A.MD_CampaignName, 
        a.AudienceID,
        a.MD_Audience,
        a.ChannelID,
        a.MD_Channel,
        a.CountryID,
        a.MD_Country,
        a.OldCampaignID,
        a.PriceTypeID,
        a.MD_PriceType,
        a.MD_PromotionTypeID,
        a.MD_PromotionType,
        a.PromotionTypeID,
        a.PromotionType,
        MC.CourseName as CourseLongName, 
        MC.AbbrvCourseName as CourseName, 
        MC.CourseParts, 
        MC.SubjectCategory2, 
		MC2.CourseName AS BundleName,       
		II.MediaTypeID,
		convert(varchar(25),'') AS SubjectMailed,
       	GETDATE() as ReportDate
	into Staging.CourseSalesByCatalogCode
	from cteOrdersAggregates oa (nolock)
    join Mapping.vwAdcodesAll A (nolock) on a.CatalogCode = oa.CatalogCode
	left join Mapping.DMPromotionType B (nolock) ON A.CatalogCode = B.CatalogCode     
	join Mapping.DMCourse MC (nolock) ON Oa.CourseID = MC.CourseID
	join Mapping.DMCourse MC2 (nolock) ON Oa.BundleID = MC2.CourseID
    join Staging.InvItem ii (nolock) on Oa.Stockitemid = ii.StockItemID

    UPDATE Staging.CourseSalesByCatalogCode
    SET SubjectMailed = left(CatalogName, charindex(' ',catalogname, 1)-1)
    where PromotionType in ('MAGAZINE','Magalog','Newsletter')

    UPDATE Staging.CourseSalesByCatalogCode
    SET SubjectMailed = 'LIT'
    where SubjectMailed = 'LT'

    UPDATE Staging.CourseSalesByCatalogCode
    SET SubjectMailed = 'RL'
    where SubjectMailed = 'RG'

    UPDATE Staging.CourseSalesByCatalogCode
    SET SubjectMailed = 'AH'
    where SubjectMailed = 'AH3'
    
  	if object_id('Marketing.CourseSalesByCatalogCode') is not null drop table Marketing.CourseSalesByCatalogCode
    alter schema Marketing transfer Staging.CourseSalesByCatalogCode
    
/*
    DECLARE @Count INT, @Count2 INT

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TempCourseSalesbyCatalogCode')
          DROP TABLE Staging.TempCourseSalesbyCatalogCode

    SELECT a.CatalogCode, a.CatalogName, a.Adcode, a.AdcodeName, A.StartDate, 
          convert(varchar(25),'') AS SubjectMailed,
          a.OldCampaignID, A.OldCampaignName, 
        a.AudienceID,
        a.MD_Audience,
        a.ChannelID,
        a.MD_Channel,
        a.CountryID,
        a.MD_Country,
        a.OldCampaignID,
        a.PriceTypeID,
        a.MD_PriceType,
        a.PromotionTypeID,
        a.MD_PromotionType,
          B.PromotionType,
          OI.CourseID, MC.CourseName as CourseLongName, 
          MC.AbbrvCourseName as CourseName, MC.CourseParts, 
          MC.SubjectCategory2, II.MediaTypeID,
          OI.BundleID, MC.CourseName AS BundleName,
          Sum(OI.TotalSales) TotalSales,
          Count(Distinct OI.OrderID) TotalOrders, 
          sum(OI.TotalQuantity) TotalUnits, GETDATE() as ReportDate
    --    sum(case when OI.StockItemID like 'PD%' then TotalSales else 0 end) DVD_Sales,
    --    sum(case when OI.StockItemID like 'PD%' then 1 else 0 end) DVD_Orders,
    --    sum(case when OI.StockItemID like 'PC%' then TotalSales else 0 end) CD_Sales,
    --    sum(case when OI.StockItemID like 'PC%' then 1 else 0 end) CD_Orders,
    --    sum(case when OI.StockItemID like 'PV%' then TotalSales else 0 end) Video_Sales,
    --    sum(case when OI.StockItemID like 'PV%' then 1 else 0 end) Video_Orders,
    --    sum(case when OI.StockItemID like 'PA%' then TotalSales else 0 end) Audio_Sales,
    --    sum(case when OI.StockItemID like 'PA%' then 1 else 0 end) Audio_Orders,
    --    sum(case when OI.StockItemID like 'PT%' then TotalSales else 0 end) Transcript_Sales,
    --    sum(case when OI.StockItemID like 'PT%' then 1 else 0 end) Transcript_Orders,
    --    sum(case when OI.StockItemID like 'DA%' then TotalSales else 0 end) Download_Sales,
    --    sum(case when OI.StockItemID like 'DA%' then 1 else 0 end) Download_Orders
    INTO Staging.TempCourseSalesbyCatalogCode
    FROM Mapping.vwAdcodesAll A  JOIN
          Mapping.DMPromotionType B ON A.CatalogCode = B.CatalogCode JOIN
          Marketing.DMPurchaseOrders O ON A.Adcode = O.Adcode JOIN
          Marketing.DMPurchaseOrderItems OI ON O.CustomerID = OI.CustomerID AND O.OrderID = OI.OrderID JOIN
          Mapping.DMCourse MC ON OI.CourseID = MC.CourseID JOIN
--          SuperStardw.dbo.MktCourse MC2 ON OI.BundleID = MC2.CourseID JOIN
          Staging.InvItem ii on OI.Stockitemid = ii.StockItemID
    WHERE O.DateOrdered BETWEEN A.StartDate and A.StopDate
    AND A.StartDate > convert(datetime, '12/1/' + Convert(varchar,(year(getdate()) -4)))
--	and a.StartDate between convert(date, '12/1/' + convert(varchar, @Year - 1)) and convert(date, '12/31/' + convert(varchar, @Year))
    AND OI.TotalSales Between 1 and 1500
    AND B.Promotiontype in ('Catalog','Convertalog','Catalog International','Letter Mailings',
                'OutsideMailing','HighSchoolMail','SwampSpecific','Newsletter',
                'Catalog Prospecting International','MAGAZINE','Magalog','ShippingCatalog',
                'E-campaign','E-campaign_Int','Other','Magnificent7','MagBacks')
    GROUP BY a.CatalogCode, a.CatalogName, a.Adcode, a.AdcodeName, A.StartDate, a.OldCampaignID, A.OldCampaignName, B.PromotionType, 
          OI.CourseID, MC.CourseName, MC.AbbrvCourseName, MC.CourseParts, MC.SubjectCategory2, II.MediaTypeID,
          OI.BundleID, MC.CourseName,
        a.AudienceID,
        a.MD_Audience,
        a.ChannelID,
        a.MD_Channel,
        a.CountryID,
        a.MD_Country,
        a.OldCampaignID,
        a.PriceTypeID,
        a.MD_PriceType,
        a.PromotionTypeID,
        a.MD_PromotionType

    order by  a.CatalogCode

    SELECT @Count = @@ROWCOUNT
    PRINT '@Count = ' + convert(varchar,@Count)

    UPDATE Staging.TempCourseSalesbyCatalogCode
    SET SubjectMailed = left(CatalogName, charindex(' ',catalogname, 1)-1)
    where PromotionType in ('MAGAZINE','Magalog','Newsletter')

    UPDATE Staging.TempCourseSalesbyCatalogCode
    SET SubjectMailed = 'LIT'
    where SubjectMailed = 'LT'

    UPDATE Staging.TempCourseSalesbyCatalogCode
    SET SubjectMailed = 'RL'
    where SubjectMailed = 'RG'

    UPDATE Staging.TempCourseSalesbyCatalogCode
    SET SubjectMailed = 'AH'
    where SubjectMailed = 'AH3'

    IF @Count > 1
       BEGIN
          IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'CourseSalesbyCatalogCode')
                DROP TABLE Marketing.CourseSalesbyCatalogCode
          
          SELECT *
          INTO Marketing.CourseSalesbyCatalogCode
          FROM Staging.TempCourseSalesbyCatalogCode
          
          SELECT @Count2 = @@ROWCOUNT
          
          IF @Count = @Count2
            BEGIN
                PRINT 'Counts Match'
                DROP TABLE Staging.TempCourseSalesbyCatalogCode
            END
          ELSE
                PRINT 'Counts Do Not Match'
          
       END
    ELSE 
          PRINT 'No Rows found in Staging.TempCourseSalesbyCatalogCode. Please check'

*/
end
GO
