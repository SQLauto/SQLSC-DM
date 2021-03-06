CREATE TABLE [Marketing].[MC_TGC_DailyConsumptionHistory]
(
[CustomerID] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AsOfDate] [date] NULL,
[CourseID] [int] NULL,
[LectureNumber] [int] NULL,
[CourseLecture] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalPlays] [int] NOT NULL,
[StreamedMins] [numeric] (38, 2) NOT NULL,
[FlagStreamed] [int] NOT NULL,
[TotalPlays_DVD] [int] NOT NULL,
[StreamedMins_DVD] [numeric] (38, 2) NOT NULL,
[FlagStreamed_DVD] [int] NOT NULL,
[TotalPlays_CD] [int] NOT NULL,
[StreamedMins_CD] [numeric] (38, 2) NOT NULL,
[FlagStreamed_CD] [int] NOT NULL,
[TotalPlays_DownloadV] [int] NOT NULL,
[StreamedMins_DownloadV] [numeric] (38, 2) NOT NULL,
[FlagStreamed_DownloadV] [int] NOT NULL,
[TotalPlays_DownloadA] [int] NOT NULL,
[StreamedMins_DownloadA] [numeric] (38, 2) NOT NULL,
[FlagStreamed_DownloadA] [int] NOT NULL,
[TotalDnlds] [int] NOT NULL,
[FlagDnld] [int] NOT NULL,
[TotalDnlds_DownloadV] [int] NOT NULL,
[FlagDnld_DownloadV] [int] NOT NULL,
[TotalDnlds_DownloadA] [int] NOT NULL,
[FlagDnld_DownloadA] [int] NOT NULL,
[DMLastUpdateDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MC_TGC_DailyConsumptionHistory_Customerid] ON [Marketing].[MC_TGC_DailyConsumptionHistory] ([CustomerID]) ON [PRIMARY]
GO
