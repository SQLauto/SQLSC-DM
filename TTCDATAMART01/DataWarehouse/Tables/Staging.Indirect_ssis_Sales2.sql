CREATE TABLE [Staging].[Indirect_ssis_Sales2]
(
[CountryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartnerName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportDate] [datetime] NULL,
[Format] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReleaseDate] [datetime] NULL,
[CourseID] [int] NULL,
[LectureNumber] [int] NULL,
[FullCourse] [bit] NULL,
[Units] [float] NULL,
[Revenue] [float] NULL,
[PurchaseChannel] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Library] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostalCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
