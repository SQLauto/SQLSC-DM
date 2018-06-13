CREATE TABLE [Staging].[Comcast_ssis_SignatureCollection]
(
[Rank] [int] NULL,
[CourseID] [int] NULL,
[LectureNumber] [int] NULL,
[Title] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssetID] [int] NULL,
[Network] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LectureRunTime] [float] NULL,
[AvgViewTime] [float] NULL,
[UniqueSetTopBoxes] [int] NULL,
[HouseHolds] [int] NULL,
[Views] [int] NULL,
[AvgVideoCompletionPct] [float] NULL,
[ReportDate] [datetime] NULL
) ON [PRIMARY]
GO
