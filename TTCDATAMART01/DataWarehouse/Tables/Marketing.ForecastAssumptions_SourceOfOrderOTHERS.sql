CREATE TABLE [Marketing].[ForecastAssumptions_SourceOfOrderOTHERS]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOrdered] [datetime] NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NetOrderAmount] [money] NULL,
[SequenceNum] [int] NULL,
[NewsegPrior] [int] NULL,
[NamePrior] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A12mfPrior] [int] NULL,
[CustomerSince] [datetime] NULL,
[Adcode] [int] NULL,
[StartDate] [datetime] NULL,
[PromotiontypeID] [smallint] NULL,
[PromotionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[md_channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[md_Promotiontype] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[md_Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagWave] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RFMStatus] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewOrExisting] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlPurchaseDate] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_ForecastAssumptions_SourceOfOrderOTHERS_cust] ON [Marketing].[ForecastAssumptions_SourceOfOrderOTHERS] ([CustomerID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_ForecastAssumptions_SourceOfOrderOTHERS_cs] ON [Marketing].[ForecastAssumptions_SourceOfOrderOTHERS] ([CustomerSince]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_ForecastAssumptions_SourceOfOrderOTHERS_do] ON [Marketing].[ForecastAssumptions_SourceOfOrderOTHERS] ([DateOrdered]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_ForecastAssumptions_SourceOfOrderOTHERS_ord] ON [Marketing].[ForecastAssumptions_SourceOfOrderOTHERS] ([OrderID]) ON [PRIMARY]
GO
