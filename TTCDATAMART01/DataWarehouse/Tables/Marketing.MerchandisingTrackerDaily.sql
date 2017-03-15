CREATE TABLE [Marketing].[MerchandisingTrackerDaily]
(
[FlagAudioVideo] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Courseid] [int] NULL,
[AbbrvCourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Topic] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseParts] [dbo].[udtCourseParts] NULL,
[OrderYear] [int] NULL,
[OrderMonth] [int] NULL,
[OrderWeek] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WeekSince] [int] NULL,
[OrderDate] [date] NULL,
[CountryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRS_RLS_YR] [int] NULL,
[CRS_RLS_MO] [int] NULL,
[CRS_RLS_DT] [datetime] NULL,
[CustomerType] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatMedia] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StockItemID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSource] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MD_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalUnits] [int] NULL,
[TotalParts] [dbo].[udtCourseParts] NULL,
[Sales] [money] NULL,
[ReportDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
