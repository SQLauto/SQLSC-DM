CREATE TABLE [Staging].[OrdAllctn_LW_BudCodePromoMapping]
(
[BudsCatalogCode] [int] NULL,
[BudsCategoryName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PromoFieldID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PromoFieldName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PromoValueID] [int] NULL,
[PromoValueName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PriceTypeID] [int] NULL,
[MD_PriceType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryID] [int] NULL,
[MD_Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
