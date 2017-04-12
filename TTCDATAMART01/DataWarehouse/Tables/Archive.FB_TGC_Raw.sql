CREATE TABLE [Archive].[FB_TGC_Raw]
(
[Campaign] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportingStarts] [date] NULL,
[ReportingEnds] [date] NULL,
[Reach] [int] NULL,
[Frequency] [float] NULL,
[Impressions] [float] NULL,
[Clicks] [float] NULL,
[UniqueClicks] [float] NULL,
[Actions] [float] NULL,
[AmountSpent] [float] NULL,
[PurchaseConversionValueFacebookPixel] [float] NULL,
[PurchaseConversionValueFacebookPixelby1d_click] [float] NULL,
[PurchaseFacebookPixel] [float] NULL,
[PurchaseFacebookPixelby1d_click] [float] NULL,
[Age] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Account] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Adset] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ad] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastupdated] [datetime] NULL CONSTRAINT [DF__FB_TGC_Ra__DMLas__4012CD21] DEFAULT (getdate())
) ON [PRIMARY]
GO
