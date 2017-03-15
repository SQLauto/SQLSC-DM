CREATE TABLE [Archive].[Audible_Quarterly]
(
[Year] [int] NULL,
[Quarter] [int] NULL,
[Marketplace] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NULL,
[DigitalISBN] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RoyaltySharepct] [float] NULL,
[Offer] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AlaCarteQty] [int] NULL,
[AlaCarteNetSales] [float] NULL,
[AlaCarteRoyalty] [float] NULL,
[CashQty] [int] NULL,
[CashNetSales] [int] NULL,
[CashRoyalty] [float] NULL,
[CreditsQty] [float] NULL,
[CreditsNetSales] [float] NULL,
[CreditsRoyalty] [float] NULL,
[TotalQty] [int] NULL,
[TotalNetSales] [float] NULL,
[TotalRoyalty] [float] NULL,
[DMLastupdated] [datetime] NULL CONSTRAINT [DF__Audible_Q__DMLas__03874B20] DEFAULT (getdate())
) ON [PRIMARY]
GO
