CREATE TABLE [Marketing].[TGCPlus_RFMBKPDEL]
(
[AsofDate] [date] NULL,
[CustomerID] [bigint] NULL,
[IntlSubDate] [date] NULL,
[LTDPaidAmt] [float] NULL,
[DateLastPlayed] [date] NULL,
[StreamedMinutes] [numeric] (38, 1) NULL,
[DaysSinceLastStream] [int] NULL,
[Tenure] [int] NULL,
[MinutesPerDay] [numeric] (38, 6) NULL,
[Recency_Decile] [int] NULL,
[Frequency_Decile] [int] NULL,
[Monetary_Decile] [int] NULL
) ON [PRIMARY]
GO
