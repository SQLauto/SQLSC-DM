CREATE TABLE [dbo].[country_continentDEL]
(
[iso 3166 country] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[continent code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alpha-3] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country-code] [float] NULL,
[iso_3166-2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[region] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sub-region] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[region-code] [float] NULL,
[sub-region-code] [float] NULL,
[Continent Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
