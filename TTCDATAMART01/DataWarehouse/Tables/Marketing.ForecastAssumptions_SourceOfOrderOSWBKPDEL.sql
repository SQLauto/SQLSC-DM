CREATE TABLE [Marketing].[ForecastAssumptions_SourceOfOrderOSWBKPDEL]
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
[NewOrExisting] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlPurchaseDate] [datetime] NULL
) ON [PRIMARY]
GO
