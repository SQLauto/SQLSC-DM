CREATE TABLE [Staging].[ssis_FB_TGCPlus_Raw]
(
[Campaign] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportingStarts] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportingEnds] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Reach] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [float] NULL,
[Impressions] [float] NULL,
[Clicks] [float] NULL,
[UniqueClicks] [float] NULL,
[Actions] [float] NULL,
[AmountSpent] [float] NULL,
[Age] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Account] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdSet] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ad] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompleteRegistrationFacebookPixel] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompleteRegistrationFacebookPixelby1d_click] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
