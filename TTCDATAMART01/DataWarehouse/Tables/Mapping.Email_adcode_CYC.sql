CREATE TABLE [Mapping].[Email_adcode_CYC]
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
[SubjectCategory] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CYC] [bit] NULL,
[Priority] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Email_adc__Prior__271BD33A] DEFAULT ('I’d like to receive all exclusive offers')
) ON [PRIMARY]
GO
