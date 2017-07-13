CREATE TABLE [Mapping].[Zipcodes]
(
[Zipcode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCodeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Latitude] [float] NULL,
[Longitude] [float] NULL,
[Location] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaxReturnsFiled] [int] NULL,
[EstimatedPopulation] [int] NULL,
[TotalWages] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [PK_Zipcodes] ON [Mapping].[Zipcodes] ([Zipcode]) ON [PRIMARY]
GO
