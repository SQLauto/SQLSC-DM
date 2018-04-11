CREATE TABLE [Archive].[Omni_TGC_PRSPCT_CourseConsmption]
(
[Courseid] [int] NULL,
[CourseName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AbbrvCourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReleaseDate] [datetime] NULL,
[PrimaryWebCategory] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrimaryWebSubcategory] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCPlusSubjectCategory] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DistinctProspectIDCounts] [int] NULL,
[DistinctCustomerid] [int] NULL,
[TotalLectures] [int] NULL,
[TotalActions] [int] NULL,
[TotalMediaTimePlayed] [numeric] (38, 6) NULL,
[PurchasedTotalMediaTimePlayed] [numeric] (38, 6) NULL,
[Purchases] [int] NULL,
[DMLastUpdated] [datetime] NOT NULL
) ON [PRIMARY]
GO
