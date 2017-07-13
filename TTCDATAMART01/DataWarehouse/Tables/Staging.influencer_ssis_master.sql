CREATE TABLE [Staging].[influencer_ssis_master]
(
[UniqueID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Program] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Date] [datetime] NULL,
[SpotEndDate] [datetime] NULL,
[OfferID] [float] NULL,
[Description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceCode1advertisedURL] [float] NULL,
[SourceCode2shortURL] [float] NULL,
[SourceCode3TGCRedirect] [float] NULL,
[StartWeek] [datetime] NULL,
[StartMonth] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartYear] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OnScreenLink] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VideoDescriptionLink] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RedirectHTML] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DescriptionLinkShortURLRedirectsto] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TheGreatCoursescomURL] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TheGreatCoursescomRedirectHTML] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateURLsSetUp] [datetime] NULL,
[DateIOSigned] [datetime] NULL,
[Invoice] [float] NULL,
[DateInvoicePassedtoAccounting] [datetime] NULL,
[SpotCost] [money] NULL,
[MonthforBudget] [float] NULL,
[dmlastupdated] [datetime] NULL CONSTRAINT [DF__influence__dmlas__2D23219A] DEFAULT (getdate())
) ON [PRIMARY]
GO