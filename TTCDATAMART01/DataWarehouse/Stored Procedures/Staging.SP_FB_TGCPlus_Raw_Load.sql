SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[SP_FB_TGCPlus_Raw_Load]   
as      
Begin      

INSERT INTO Archive.[FB_TGCPlus_Raw]

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
  CAST([Age] AS VARCHAR(20)) [Age],
  CAST([Gender] AS VARCHAR(20)) [Gender],
  CAST([Account] AS VARCHAR(100)) [Account],
  CAST([AdSet] AS VARCHAR(255)) [AdSet] ,
  CAST([Ad] AS VARCHAR(255) ) [Ad] ,
  CAST([CompleteRegistrationFacebookPixel] AS float) [CompleteRegistrationFacebookPixel],
  CAST([CompleteRegistrationFacebookPixelby1d_click] AS float) [CompleteRegistrationFacebookPixelby1d_click],
  GETDATE()
FROM staging.[ssis_FB_TGCPLus_Raw]
WHERE Campaign IS NOT NULL


/*
SELECT  CAST([ReportingStarts] AS DATE) [ReportingStarts],   CAST([ReportingEnds] AS DATE) [ReportingEnds]
FROM staging.[ssis_FB_TGCPLus_Raw]
WHERE Campaign IS NOT NULL
INTERSECT
SELECT ReportingStarts	,ReportingEnds FROM Archive.[FB_TGCPlus_Raw]
WHERE Campaign IS NOT NULL
*/

END 
GO
