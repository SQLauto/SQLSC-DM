CREATE TABLE [Mapping].[EmailTypeConversionTable]
(
[CatalogCode] [int] NOT NULL,
[CatalogName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailId] [int] NULL,
[Flag_DoublePunch] [tinyint] NULL,
[EmailOfferID] [int] NULL
) ON [PRIMARY]
GO
