CREATE TABLE [Archive].[Amazon_AIV_Payment]
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
[Revenue] [float] NULL,
[DMlastupdated] [datetime] NULL CONSTRAINT [DF__Amazon_AI__DMlas__6A2D94BE] DEFAULT (getdate())
) ON [PRIMARY]
GO
