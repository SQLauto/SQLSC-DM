CREATE TABLE [Mapping].[DLREmail_MailedAdcodes]
(
[EmailDLRID] [int] NOT NULL,
[EmailDLRName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MailedAdcode] [int] NOT NULL,
[EmailAdcode] [int] NOT NULL,
[Subjectline] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Segment] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
