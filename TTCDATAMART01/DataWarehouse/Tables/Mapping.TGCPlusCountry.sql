CREATE TABLE [Mapping].[TGCPlusCountry]
(
[Alpha2Code] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Alpha3Code] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ISONumericCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ISO_3166_2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContinentCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContinentName] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RegionCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RegionName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubRegionCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubRegionName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
