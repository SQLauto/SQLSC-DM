CREATE TABLE [Staging].[Audible_ssis_quarterly]
(
[Quarter] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Marketplace] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DigitalISBN] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RoyaltySharepct] [float] NULL,
[Offer] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AlaCarteQty] [float] NULL,
[AlaCarteNetSales] [float] NULL,
[AlaCarteRoyalty] [float] NULL,
[CashQty] [float] NULL,
[CashNetSales] [int] NULL,
[CashRoyalty] [float] NULL,
[CreditsQty] [float] NULL,
[CreditsNetSales] [float] NULL,
[CreditsRoyalty] [float] NULL,
[TotalQty] [float] NULL,
[TotalNetSales] [float] NULL,
[TotalRoyalty] [float] NULL
) ON [PRIMARY]
GO
