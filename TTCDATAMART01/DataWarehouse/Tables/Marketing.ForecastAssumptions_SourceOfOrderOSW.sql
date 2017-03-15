CREATE TABLE [Marketing].[ForecastAssumptions_SourceOfOrderOSW]
(
[YearCreated] [int] NULL,
[ForecastYear] [int] NULL,
[DateCreated] [datetime] NOT NULL,
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
[FlagWave] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RFMStatus] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mf] [int] NULL,
[Newseg] [int] NULL,
[NewOrExisting] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlPurchaseDate] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_ForecastAssumptions_SourceOfOrderOSW_cust] ON [Marketing].[ForecastAssumptions_SourceOfOrderOSW] ([CustomerID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_ForecastAssumptions_SourceOfOrderOSW_cs] ON [Marketing].[ForecastAssumptions_SourceOfOrderOSW] ([CustomerSince]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_ForecastAssumptions_SourceOfOrderOSW_do] ON [Marketing].[ForecastAssumptions_SourceOfOrderOSW] ([DateOrdered]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_ForecastAssumptions_SourceOfOrderOSW_ord] ON [Marketing].[ForecastAssumptions_SourceOfOrderOSW] ([OrderID]) ON [PRIMARY]
GO
