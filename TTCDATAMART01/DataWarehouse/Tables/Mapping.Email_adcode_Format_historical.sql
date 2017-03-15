CREATE TABLE [Mapping].[Email_adcode_Format_historical]
(
[EmailID] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Adcode] [int] NULL,
[AdcodeName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Startdate] [datetime] NOT NULL,
[EndDate] [datetime] NOT NULL,
[Subjectline] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SegmentGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TestFlag] [bit] NULL,
[CourseFlag] [bit] NULL,
[MaxCourses] [int] NULL,
[EmailCompletedFlag] [bit] NULL,
[Countrycode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[split_percentage] [int] NULL,
[primary_adcode] [int] NULL,
[DLRAdcode] [int] NULL,
[DLRFlag] [bit] NULL,
[DLRTestFlag] [bit] NULL,
[DLRSplit_percentage] [int] NULL,
[Format] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Priority] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
