CREATE TABLE [Staging].[Snag_ssis_UsedSubOffer]
(
[id] [bigint] NULL,
[version] [bigint] NULL,
[applied_at] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[offer_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[offer_code_applied] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[redeemed_at] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
