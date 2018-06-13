CREATE TABLE [Staging].[MC_TGC_Consumption_L12MnthStrmTempAll_TEST]
(
[Customerid] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOrdered] [date] NULL,
[StartDate] [date] NULL,
[MinActionDate] [date] NULL,
[MaxActionDate] [date] NULL,
[TotalPlays] [int] NULL,
[StreamedMins] [numeric] (18, 2) NULL,
[CoursesStreamed] [int] NULL,
[LecturesStreamed] [int] NULL,
[FlagStreamed] [int] NOT NULL
) ON [PRIMARY]
GO
