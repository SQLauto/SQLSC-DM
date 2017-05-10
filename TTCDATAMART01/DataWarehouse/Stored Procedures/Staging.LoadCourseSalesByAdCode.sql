SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Staging].[LoadCourseSalesByAdCode]
	@Year int = -1
AS
begin
	set nocount on

	if @Year = -1 set @Year = year(getdate())
    
  	if object_id('Staging.CourseSalesbyAdCode') is not null drop table Staging.CourseSalesbyAdCode
    
    ;with cteOrdersAggregates(CatalogCode, AdCode, CourseID, BundleID, StockItemID, TotalSales, TotalOrders, TotalUnits) as
    (
    	select 
        	a.CatalogCode, 
            a.Adcode, 
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
	        and a.StartDate between convert(date, '12/1/' + convert(varchar(4), @Year - 2)) and convert(date, '12/31/' + convert(varchar(4), @Year))
	        AND OI.TotalSales Between 1 and 1500
    	    --AND (B.Promotiontype in ('Catalog','Convertalog','Catalog International','Letter Mailings',
        	--    'OutsideMailing','HighSchoolMail','SwampSpecific','Newsletter',
         --       'Catalog Prospecting International','MAGAZINE','Magalog','ShippingCatalog',
         --       'E-campaign','E-campaign_Int','Other','Magnificent7','MagBacks','Radio')
               -- or a.ChannelID in (1,2,4,5,6,20)) -- PR 5/2/2017 Need all channels by Joe
			AND a.ChannelID in (select distinct MD_ChannelID
								from Mapping.MktDim_Channel)
        GROUP BY   a.CatalogCode, a.Adcode, OI.CourseID, OI.BundleID, StockItemID
    )
    select 
		oa.CatalogCode, 
       	oa.AdCode, 
       	oa.CourseID, 
       	oa.BundleID, 
        oa.StockItemID,
       	oa.TotalSales, 
       	oa.TotalOrders, 
        oa.TotalUnits,
        a.CatalogName, 
        a.AdcodeName, 
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
        a.PromotiontypeID,
        A.PromotionType,
        MC.CourseName as CourseLongName, 
        MC.AbbrvCourseName as CourseName, 
        MC.CourseParts, 
        MC.SubjectCategory2, 
		MC2.CourseName AS BundleName,       
		II.MediaTypeID,
		convert(varchar(25),'') AS SubjectMailed,
       	GETDATE() as ReportDate
	into Staging.CourseSalesbyAdCode
	from cteOrdersAggregates oa (nolock)
    join Mapping.vwAdcodesAll A (nolock) on a.AdCode = oa.AdCode
	left join Mapping.DMPromotionType B (nolock) ON A.CatalogCode = B.CatalogCode     
	join Mapping.DMCourse MC (nolock) ON Oa.CourseID = MC.CourseID
	join Mapping.DMCourse MC2 (nolock) ON Oa.BundleID = MC2.CourseID
    join Staging.InvItem ii (nolock) on Oa.Stockitemid = ii.StockItemID

    UPDATE Staging.CourseSalesbyAdCode
    SET SubjectMailed = left(CatalogName, charindex(' ',catalogname, 1)-1)
    where PromotionType in ('MAGAZINE','Magalog','Newsletter')

    UPDATE Staging.CourseSalesbyAdCode
    SET SubjectMailed = 'LIT'
    where SubjectMailed = 'LT'

    UPDATE Staging.CourseSalesbyAdCode
    SET SubjectMailed = 'RL'
    where SubjectMailed = 'RG'

    UPDATE Staging.CourseSalesbyAdCode
    SET SubjectMailed = 'AH'
    where SubjectMailed = 'AH3'
    
  	if object_id('Marketing.CourseSalesbyAdCode') is not null drop table Marketing.CourseSalesbyAdCode
    alter schema Marketing transfer Staging.CourseSalesbyAdCode
end
GO
