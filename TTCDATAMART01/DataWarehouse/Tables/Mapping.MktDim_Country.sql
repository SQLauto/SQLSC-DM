CREATE TABLE [Mapping].[MktDim_Country]
(
[MD_CountryID] [int] NOT NULL IDENTITY(1, 1),
[MD_Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MD_CountryName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagActive] [tinyint] NULL CONSTRAINT [DF__MktDim_Co__FlagA__7B0A770D] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[MktDim_Country] ADD CONSTRAINT [pk_Country_cid] PRIMARY KEY CLUSTERED  ([MD_Country]) ON [PRIMARY]
GO
