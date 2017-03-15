CREATE TABLE [Staging].[Indirect_ssis_Sales]
(
[CountryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartnerName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportDate] [date] NULL,
[Format] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReleaseDate] [datetime] NULL,
[CourseID] [int] NULL,
[LectureNumber] [int] NULL,
[Units] [int] NULL,
[Revenue] [real] NULL,
[PurchaseChannel] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
