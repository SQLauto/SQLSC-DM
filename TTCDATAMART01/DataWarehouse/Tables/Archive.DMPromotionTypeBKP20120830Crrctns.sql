CREATE TABLE [Archive].[DMPromotionTypeBKP20120830Crrctns]
(
[CatalogCode] [int] NOT NULL,
[MailingDescription] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MailingType] [int] NOT NULL,
[Category] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PromotionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DimPromotionID] [int] NULL,
[MailConsolidateID] [int] NULL,
[MailConsolidateName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailConsolidateID] [int] NULL,
[EmailConsolidateName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mail_Email_ConsolidateID] [int] NULL,
[Mail_Email_ConsolidateName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
