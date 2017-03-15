CREATE TABLE [Staging].[amazon_ssis_AIV]
(
[CountryCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Partner] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportDate] [datetime] NULL,
[Format] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PurchaseChannel] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReleaseDate] [datetime] NULL,
[AvailableDate] [datetime] NULL,
[PurchaseDate] [datetime] NULL,
[ContentType] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASIN] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VendorSku] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [float] NULL,
[CourseTitle] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LectureNumber] [float] NULL,
[LectureTitle] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Unit] [float] NULL,
[Revenue] [float] NULL
) ON [PRIMARY]
GO
