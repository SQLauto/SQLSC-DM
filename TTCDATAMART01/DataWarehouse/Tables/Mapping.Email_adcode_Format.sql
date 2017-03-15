CREATE TABLE [Mapping].[Email_adcode_Format]
(
[EmailID] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Adcode] [int] NULL,
[AdcodeName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Startdate] [datetime] NOT NULL,
[EndDate] [datetime] NOT NULL,
[Subjectline] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SegmentGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TestFlag] [bit] NULL CONSTRAINT [DF__Email_adc__TestF__2A026186] DEFAULT ((0)),
[CourseFlag] [bit] NULL CONSTRAINT [DF__Email_adc__Cours__2AF685BF] DEFAULT ((0)),
[MaxCourses] [int] NULL CONSTRAINT [DF__Email_adc__MaxCo__2BEAA9F8] DEFAULT ((0)),
[EmailCompletedFlag] [bit] NULL CONSTRAINT [DF__Email_adc__Email__2CDECE31] DEFAULT ((0)),
[Countrycode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[split_percentage] [int] NULL CONSTRAINT [DF__Email_adc__split__2DD2F26A] DEFAULT ((100)),
[primary_adcode] [int] NULL,
[DLRAdcode] [int] NULL,
[DLRFlag] [bit] NULL,
[DLRTestFlag] [bit] NULL,
[DLRSplit_percentage] [int] NULL,
[Format] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Priority] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Email_adc__Prior__2EC716A3] DEFAULT ('I’d like to receive all exclusive offers')
) ON [PRIMARY]
GO
