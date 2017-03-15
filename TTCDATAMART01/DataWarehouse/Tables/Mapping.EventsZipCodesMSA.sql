CREATE TABLE [Mapping].[EventsZipCodesMSA]
(
[City] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AreaCode] [int] NULL,
[FIPS] [int] NULL,
[County] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeZone] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DaylightSavings] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MSA] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PMSA] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
