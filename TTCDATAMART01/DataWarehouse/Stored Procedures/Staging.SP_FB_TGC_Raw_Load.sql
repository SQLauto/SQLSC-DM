SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE Proc [Staging].[SP_FB_TGC_Raw_Load]   
as      
Begin      
    
 

INSERT INTO Archive.[FB_TGC_Raw]
SELECT [Campaign], 
  CAST([ReportingStarts] AS DATE) [ReportingStarts], 
  CAST([ReportingEnds] AS DATE) [ReportingEnds],
  CAST([Reach] AS int) [Reach],
  [Frequency],
  [Impressions],
  [Clicks],
  [UniqueClicks],
  [Actions],
  [AmountSpent],
  CAST([PurchaseConversionValueFacebookPixel] AS float) [PurchaseConversionValueFacebookPixel],
  CAST([PurchaseConversionValueFacebookPixelby1d_click] AS float) [PurchaseConversionValueFacebookPixelby1d_click],
  CAST([PurchaseFacebookPixel] AS float) [PurchaseFacebookPixel],
  CAST([PurchaseFacebookPixelby1d_click] AS float) [PurchaseFacebookPixelby1d_click],
  CAST([Age] AS VARCHAR(20)) [Age],
  CAST([Gender] AS VARCHAR(20)) [Gender],
  CAST([Account] AS VARCHAR(100)) [Account],
  [AdSet],
  Ad,
  GETDATE()
  FROM staging.[ssis_FB_TGC_Raw]
  WHERE Campaign IS NOT NULL





INSERT INTO [Archive].[FB_TGC_AdCodes]

SELECT DISTINCT Campaign, Adset, Ad , right(ad,6)
FROM Archive.[FB_TGC_Raw] a
WHERE adset NOT IN
    (SELECT adset 
     FROM DataWarehouse.Archive.fb_tgc_adcodes)
	 	 and a.ad not like 'Post:%' and 
a.ad not like 'Job:%' 
 
END 

GO
