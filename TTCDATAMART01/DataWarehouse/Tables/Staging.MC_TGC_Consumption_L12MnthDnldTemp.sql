CREATE TABLE [Staging].[MC_TGC_Consumption_L12MnthDnldTemp]
(
[Customerid] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOrdered] [datetime] NULL,
[StartDate] [date] NULL,
[MinActionDate] [date] NULL,
[MaxActionDate] [date] NULL,
[FormatPurchased] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalDnlds] [int] NULL,
[CoursesDnld] [int] NULL,
[LecturesDnld] [int] NULL,
[FlagDnld] [int] NOT NULL
) ON [PRIMARY]
GO
