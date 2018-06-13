CREATE TABLE [Staging].[MC_TGC_Consumption_L12MnthDnldTempAll_TEST]
(
[Customerid] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOrdered] [date] NULL,
[StartDate] [date] NULL,
[MinActionDate] [date] NULL,
[MaxActionDate] [date] NULL,
[TotalDnlds] [int] NULL,
[CoursesDnld] [int] NULL,
[LecturesDnld] [int] NULL,
[FlagDnld] [int] NOT NULL
) ON [PRIMARY]
GO
