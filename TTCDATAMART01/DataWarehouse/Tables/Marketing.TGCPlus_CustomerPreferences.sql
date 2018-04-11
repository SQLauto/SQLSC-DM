CREATE TABLE [Marketing].[TGCPlus_CustomerPreferences]
(
[customerid] [bigint] NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredAVCat_LTD] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredCategory_LTD] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredPlayer_LTD] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredPlayerSpeed_LTD] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AsofDate] [date] NULL
) ON [PRIMARY]
GO
