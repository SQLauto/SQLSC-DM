CREATE TABLE [Mapping].[MktDim_PromotionType]
(
[MD_PromotionTypeID] [int] NOT NULL IDENTITY(1, 1),
[MD_PromotionType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PromotionType_Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagActive] [tinyint] NULL CONSTRAINT [DF__MktDim_Pr__FlagA__708CE89A] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[MktDim_PromotionType] ADD CONSTRAINT [pk_PromotionType_mid] PRIMARY KEY CLUSTERED  ([MD_PromotionTypeID]) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[MktDim_PromotionType] ADD CONSTRAINT [uc_MktDimPromotionType_Ptn] UNIQUE NONCLUSTERED  ([MD_PromotionType], [MD_PromotionType_Description]) ON [PRIMARY]
GO
