CREATE TABLE [Archive].[FB_TGCPlus_Raw_20180221_del]
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
[Age] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Account] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdSet] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ad] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompleteRegistrationFacebookPixel] [float] NULL,
[CompleteRegistrationFacebookPixelby1d_click] [float] NULL,
[Dmlastupdated] [datetime] NULL
) ON [PRIMARY]
GO
