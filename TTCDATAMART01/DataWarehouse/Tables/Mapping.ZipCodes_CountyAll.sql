CREATE TABLE [Mapping].[ZipCodes_CountyAll]
(
[ZipCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Latitude] [float] NULL,
[Longitude] [float] NULL,
[City] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[County] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Location] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaxReturnsFiled] [int] NULL,
[EstimatedPopulation] [int] NULL,
[TotalWages] [int] NULL
) ON [PRIMARY]
GO
