CREATE TABLE [Archive].[Indirect_Sales]
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
[DMlastupdated] [datetime] NULL CONSTRAINT [DF__Indirect___DMlas__557D5BF2] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[Indirect_Sales] ADD CONSTRAINT [PK__Indirect__564DD84A85005615] PRIMARY KEY CLUSTERED  ([Indirect_Sales]) ON [PRIMARY]
GO
