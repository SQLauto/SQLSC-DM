CREATE TABLE [Archive].[Comcast_SignatureCollection]
(
[Comcast_SignatureCollection_ID] [int] NOT NULL IDENTITY(1, 1),
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
[ReportDate] [datetime] NULL,
[DMLastupdated] [datetime] NULL CONSTRAINT [DF__Comcast_S__DMLas__6CB263B0] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[Comcast_SignatureCollection] ADD CONSTRAINT [PK__Comcast___91A9563431182E90] PRIMARY KEY CLUSTERED  ([Comcast_SignatureCollection_ID]) ON [PRIMARY]
GO
