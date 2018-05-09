CREATE TABLE [Staging].[MC_TGC_DailyConsumptionBase_TEMP]
(
[CustomerID] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Actiondate] [date] NOT NULL,
[CourseID] [int] NULL,
[LectureNumber] [int] NULL,
[FormatPurchased] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionType] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Action] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TotalActions] [int] NULL,
[MediaTimePlayed] [numeric] (18, 6) NULL,
[CourseLecture] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
