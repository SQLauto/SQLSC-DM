CREATE TABLE [Marketing].[TGCPlus_RFM]
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
[Monetary_Decile] [int] NULL,
[RF_Score] [int] NULL,
[Monetary_Score] [int] NULL,
[RFMGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrentFlag] [bit] NULL,
[DMLastupdated] [datetime] NOT NULL
) ON [PRIMARY]
GO
