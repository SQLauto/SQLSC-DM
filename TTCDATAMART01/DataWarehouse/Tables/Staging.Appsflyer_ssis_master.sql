CREATE TABLE [Staging].[Appsflyer_ssis_master]
(
[Platform] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaSource] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Campaign] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdCode] [int] NULL,
[Cost] [money] NULL,
[CampaignStartYearMonth] [int] NULL,
[CampaignEndYearMonth] [int] NULL
) ON [PRIMARY]
GO
