CREATE TABLE [Mapping].[Email_adcode_old]
(
[EmailID] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Adcode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AdcodeName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Startdate] [datetime] NOT NULL,
[EndDate] [datetime] NOT NULL,
[Subjectline] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SegmentGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TestFlag] [bit] NULL,
[CourseFlag] [bit] NULL,
[MaxCourses] [int] NULL,
[EmailCompletedFlag] [bit] NULL,
[Countrycode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[split_percentage] [int] NULL,
[primary_adcode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
