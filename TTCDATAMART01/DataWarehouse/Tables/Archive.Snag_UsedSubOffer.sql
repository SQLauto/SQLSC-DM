CREATE TABLE [Archive].[Snag_UsedSubOffer]
(
[id] [bigint] NOT NULL,
[version] [bigint] NOT NULL,
[applied_at] [datetime] NULL,
[offer_id] [bigint] NULL,
[offer_code_applied] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[redeemed_at] [datetime] NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_date] [datetime] NULL,
[DMLastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__Snag_Used__Lastu__43FC9B4A] DEFAULT (getdate())
) ON [PRIMARY]
GO
