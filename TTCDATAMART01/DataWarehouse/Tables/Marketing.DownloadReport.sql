CREATE TABLE [Marketing].[DownloadReport]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOrdered] [datetime] NULL,
[OrderYear] [int] NULL,
[OrderMonth] [int] NULL,
[CustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mf] [int] NULL,
[Age] [int] NULL,
[Gender] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagAudioVideo] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Format_VDL] [int] NULL,
[Format_ADL] [int] NULL,
[Subject_AH] [int] NULL,
[Subject_EC] [int] NULL,
[Subject_FA] [int] NULL,
[Subject_BL] [int] NULL,
[Subject_LIT] [int] NULL,
[Subject_MH] [int] NULL,
[Subject_PH] [int] NULL,
[Subject_PR] [int] NULL,
[Subject_RL] [int] NULL,
[Subject_SCI] [int] NULL,
[Subject_MTH] [int] NULL,
[TotalLecturePurchased] [int] NULL,
[DS01Mo_TotalLectureDownloaded] [int] NULL,
[DS03Mo_TotalLectureDownloaded] [int] NULL,
[DS06Mo_TotalLectureDownloaded] [int] NULL,
[DS09Mo_TotalLectureDownloaded] [int] NULL,
[DS12Mo_TotalLectureDownloaded] [int] NULL,
[DS01Mo_TotDownloadBin] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DS03Mo_TotDownloadBin] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DS06Mo_TotDownloadBin] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DS09Mo_TotDownloadBin] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DS12Mo_TotDownloadBin] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
