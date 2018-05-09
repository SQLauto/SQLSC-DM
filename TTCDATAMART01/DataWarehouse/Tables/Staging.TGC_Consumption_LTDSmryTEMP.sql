CREATE TABLE [Staging].[TGC_Consumption_LTDSmryTEMP]
(
[CustomerID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AsOfDate] [date] NULL,
[TotalPlays_LTD] [int] NOT NULL,
[StreamedMins_LTD] [numeric] (38, 2) NOT NULL,
[CoursesStreamed_LTD] [int] NOT NULL,
[LecturesStreamed_LTD] [int] NOT NULL,
[FlagStreamed_LTD] [int] NOT NULL,
[TotalPlays_DVD_LTD] [int] NOT NULL,
[StreamedMins_DVD_LTD] [numeric] (38, 2) NOT NULL,
[CoursesStreamed_DVD_LTD] [int] NOT NULL,
[LecturesStreamed_DVD_LTD] [int] NOT NULL,
[FlagStreamed_DVD_LTD] [int] NOT NULL,
[TotalPlays_CD_LTD] [int] NOT NULL,
[StreamedMins_CD_LTD] [numeric] (38, 2) NOT NULL,
[CoursesStreamed_CD_LTD] [int] NOT NULL,
[LecturesStreamed_CD_LTD] [int] NOT NULL,
[FlagStreamed_CD_LTD] [int] NOT NULL,
[TotalPlays_DownloadV_LTD] [int] NOT NULL,
[StreamedMins_DownloadV_LTD] [numeric] (38, 2) NOT NULL,
[CoursesStreamed_DownloadV_LTD] [int] NOT NULL,
[LecturesStreamed_DownloadV_LTD] [int] NOT NULL,
[FlagStreamed_DownloadV_LTD] [int] NOT NULL,
[TotalPlays_DownloadA_LTD] [int] NOT NULL,
[StreamedMins_DownloadA_LTD] [numeric] (38, 2) NOT NULL,
[CoursesStreamed_DownloadA_LTD] [int] NOT NULL,
[LecturesStreamed_DownloadA_LTD] [int] NOT NULL,
[FlagStreamed_DownloadA_LTD] [int] NOT NULL,
[TotalDnlds_LTD] [int] NOT NULL,
[CoursesDnld_LTD] [int] NOT NULL,
[LecturesDnld_LTD] [int] NOT NULL,
[FlagDnld_LTD] [int] NOT NULL,
[TotalDnlds_DownloadV_LTD] [int] NOT NULL,
[CoursesDnld_DownloadV_LTD] [int] NOT NULL,
[LecturesDnld_DownloadV_LTD] [int] NOT NULL,
[FlagDnld_DownloadV_LTD] [int] NOT NULL,
[TotalDnlds_DownloadA_LTD] [int] NOT NULL,
[CoursesDnld_DownloadA_LTD] [int] NOT NULL,
[LecturesDnld_DownloadA_LTD] [int] NOT NULL,
[FlagDnld_DownloadA_LTD] [int] NOT NULL
) ON [PRIMARY]
GO