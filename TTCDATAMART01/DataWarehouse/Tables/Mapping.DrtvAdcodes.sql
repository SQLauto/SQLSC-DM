CREATE TABLE [Mapping].[DrtvAdcodes]
(
[Adcode] [int] NOT NULL,
[AdcodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CatalogCode] [int] NULL,
[CatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagPhoneOrWeb] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagCDOrNoCD] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagNLOrHT] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagW1OrW2] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagOther] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagChannel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConversionCost] [money] NULL,
[PreferredCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagXGC] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[URL] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
