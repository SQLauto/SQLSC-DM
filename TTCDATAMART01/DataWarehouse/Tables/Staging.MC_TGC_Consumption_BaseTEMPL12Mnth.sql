CREATE TABLE [Staging].[MC_TGC_Consumption_BaseTEMPL12Mnth]
(
[Customerid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ActionDate] [date] NOT NULL,
[Courseid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LectureNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatPurchased] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Action] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalActions] [int] NULL,
[MediaTimePlayed] [float] NULL,
[CourseLecture] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
