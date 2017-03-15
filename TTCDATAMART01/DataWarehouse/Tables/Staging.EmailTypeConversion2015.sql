CREATE TABLE [Staging].[EmailTypeConversion2015]
(
[CatalogCode] [int] NULL,
[CatalogName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Adcode] [int] NULL,
[EmailOffer] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailOfferID] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UNKey_EmailTypeConversion2015] ON [Staging].[EmailTypeConversion2015] ([CatalogCode], [Adcode]) ON [PRIMARY]
GO
