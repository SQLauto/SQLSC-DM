CREATE TABLE [Mapping].[email_UnsubscribeRequests]
(
[Customerid] [int] NULL,
[EMailAddr] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateRequested] [datetime] NULL,
[DateApplied] [datetime] NULL,
[CampaignFileName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
