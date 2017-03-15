CREATE TABLE [dbo].[SubjectMigrationAnalysis1to1]
(
[AsOfDate] [date] NULL,
[DAtePulled] [datetime] NOT NULL,
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A12mf] [int] NULL,
[SubjectCategoryPref2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MH] [tinyint] NULL,
[AH] [tinyint] NULL,
[RL] [tinyint] NULL,
[LIT] [tinyint] NULL,
[MTH] [tinyint] NULL,
[SCI] [tinyint] NULL,
[PH] [tinyint] NULL,
[HS] [tinyint] NULL,
[FW] [tinyint] NULL,
[PR] [tinyint] NULL,
[EC] [tinyint] NULL,
[VA] [tinyint] NULL,
[MSC] [tinyint] NULL,
[FlagBoughtCoreCat] [tinyint] NULL,
[FlagBoughtOther] [tinyint] NULL
) ON [PRIMARY]
GO
