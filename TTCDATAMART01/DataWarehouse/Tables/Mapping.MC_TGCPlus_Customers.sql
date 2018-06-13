CREATE TABLE [Mapping].[MC_TGCPlus_Customers]
(
[MatchDate] [datetime] NULL,
[AsofDate] [date] NULL,
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IntlSubType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagPlusStatus] [int] NULL,
[PaymentHandler] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDPaidAmt] [float] NULL,
[LTDPaidAmtBins] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
