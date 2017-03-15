CREATE TABLE [Mapping].[MktDim_PriceType]
(
[MD_PriceTypeID] [int] NOT NULL IDENTITY(1, 1),
[MD_PriceType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PriceType_Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagActive] [tinyint] NULL CONSTRAINT [DF__MktDim_Pr__FlagA__067C29B9] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[MktDim_PriceType] ADD CONSTRAINT [pk_PriceType_aid] PRIMARY KEY CLUSTERED  ([MD_PriceTypeID]) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[MktDim_PriceType] ADD CONSTRAINT [uc_MktDimPriceType_PriceType] UNIQUE NONCLUSTERED  ([MD_PriceType], [MD_PriceType_Description]) ON [PRIMARY]
GO
