CREATE TABLE [Archive].[indirect_sales_20170622_del]
(
[Indirect_Sales] [int] NOT NULL IDENTITY(1, 1),
[CountryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartnerName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportDate] [datetime] NULL,
[Format] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReleaseDate] [date] NULL,
[CourseID] [int] NULL,
[LectureNumber] [int] NULL,
[Units] [int] NULL,
[Revenue] [real] NULL,
[PurchaseChannel] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Library] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostalCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMlastupdated] [datetime] NULL
) ON [PRIMARY]
GO
