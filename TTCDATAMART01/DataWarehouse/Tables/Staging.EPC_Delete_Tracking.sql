CREATE TABLE [Staging].[EPC_Delete_Tracking]
(
[EmailAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Priority] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tablename] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeletedTime] [datetime] NULL
) ON [PRIMARY]
GO
