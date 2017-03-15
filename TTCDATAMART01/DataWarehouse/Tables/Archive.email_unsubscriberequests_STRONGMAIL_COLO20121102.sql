CREATE TABLE [Archive].[email_unsubscriberequests_STRONGMAIL_COLO20121102]
(
[Unsubscribe_ID] [int] NOT NULL,
[Customerid] [int] NULL,
[EMailAddr] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateApplied] [datetime] NULL,
[CampaignFileName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
