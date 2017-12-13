CREATE TABLE [Mapping].[Email_adcodePR]
(
[EmailID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Adcode] [float] NULL,
[AdcodeName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Startdate] [datetime] NULL,
[EndDate] [datetime] NULL,
[Subjectline] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SegmentGroup] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TestFlag] [float] NULL,
[CourseFlag] [float] NULL,
[MaxCourses] [float] NULL,
[EmailCompletedFlag] [float] NULL,
[Countrycode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[split_percentage] [float] NULL,
[primary_adcode] [float] NULL,
[DLRFlag] [float] NULL,
[DLRAdcode] [float] NULL,
[DLRTestFLAG] [float] NULL,
[DLRsplit_percentage] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Priority] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
